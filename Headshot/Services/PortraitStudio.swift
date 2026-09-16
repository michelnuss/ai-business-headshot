import CoreImage
import CoreImage.CIFilterBuiltins
import CoreVideo
import UIKit
import Vision

/// On-device stand-in for the cloud edit.
///
/// It never changes facial geometry. It crops to a head-and-shoulders frame,
/// composites the person onto studio paper, and applies a restrained grade.
enum PortraitStudio {
    static func render(_ image: UIImage) async throws -> UIImage {
        let prepared = image.normalizedOrientation().downscaled(maxDimension: 2048)
        guard let cgImage = prepared.cgImage else { throw HeadshotError.invalidImage }
        let scale = prepared.scale

        let pngData: Data = try await Task.detached(priority: .userInitiated) {
            let rendered = try process(cgImage: cgImage, scale: scale)
            guard let data = rendered.pngData() else { throw HeadshotError.invalidImage }
            return data
        }.value

        guard let output = UIImage(data: pngData) else { throw HeadshotError.invalidImage }
        return output
    }

    private static func process(cgImage: CGImage, scale: CGFloat) throws -> UIImage {
        let portrait = cropToPortrait(cgImage)
        let ciContext = CIContext(options: [.useSoftwareRenderer: false])
        var ciImage = CIImage(cgImage: portrait)

        let backdrop = studioPaper(in: ciImage.extent)
        if let cutout = segmentedSubject(ciImage, cgImage: portrait) {
            ciImage = cutout.composited(over: backdrop)
        }

        ciImage = grade(ciImage).cropped(to: ciImage.extent.integral)

        guard let output = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            throw HeadshotError.invalidImage
        }
        return UIImage(cgImage: output, scale: scale, orientation: .up)
    }

    private static func cropToPortrait(_ cgImage: CGImage) -> CGImage {
        let bounds = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
        let crop: CGRect
        if let face = largestFaceRect(in: cgImage) {
            crop = headshotFrame(around: face, in: bounds)
        } else {
            crop = aspectFitCrop(bounds, aspect: 4 / 5)
        }
        return cgImage.cropping(to: crop.integral) ?? cgImage
    }

    /// Vision boxes are normalized with origin at lower-left; CGImage is top-left.
    private static func largestFaceRect(in cgImage: CGImage) -> CGRect? {
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        try? handler.perform([request])
        guard let face = request.results?.max(by: { $0.boundingBox.area < $1.boundingBox.area }) else {
            return nil
        }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let box = face.boundingBox
        return CGRect(
            x: box.origin.x * width,
            y: (1 - box.origin.y - box.size.height) * height,
            width: box.size.width * width,
            height: box.size.height * height
        )
    }

    private static func headshotFrame(around face: CGRect, in bounds: CGRect) -> CGRect {
        let padX = face.width * 0.55
        let padTop = face.height * 0.6
        let padBottom = face.height * 1.2
        let expanded = CGRect(
            x: face.minX - padX,
            y: face.minY - padTop,
            width: face.width + padX * 2,
            height: face.height + padTop + padBottom
        )
        return clamp(aspectFitCrop(expanded, aspect: 4 / 5, focusY: 0.38), to: bounds)
    }

    private static func aspectFitCrop(
        _ rect: CGRect,
        aspect: CGFloat,
        focusY: CGFloat = 0.5
    ) -> CGRect {
        var crop = rect
        let current = crop.width / max(crop.height, 1)
        if current > aspect {
            let newHeight = crop.width / aspect
            crop.origin.y -= (newHeight - crop.height) * focusY
            crop.size.height = newHeight
        } else {
            let newWidth = crop.height * aspect
            crop.origin.x -= (newWidth - crop.width) / 2
            crop.size.width = newWidth
        }
        return crop
    }

    private static func clamp(_ rect: CGRect, to bounds: CGRect) -> CGRect {
        var crop = rect
        if crop.width > bounds.width {
            let scale = bounds.width / crop.width
            crop.size.width = bounds.width
            crop.size.height *= scale
        }
        if crop.height > bounds.height {
            let scale = bounds.height / crop.height
            crop.size.height = bounds.height
            crop.size.width *= scale
        }
        crop.origin.x = min(max(crop.origin.x, bounds.minX), bounds.maxX - crop.width)
        crop.origin.y = min(max(crop.origin.y, bounds.minY), bounds.maxY - crop.height)
        return crop
    }

    private static func segmentedSubject(_ image: CIImage, cgImage: CGImage) -> CIImage? {
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return nil
        }
        guard let buffer = request.results?.first?.pixelBuffer else { return nil }

        var mask = CIImage(cvPixelBuffer: buffer)
        let scaleX = image.extent.width / max(mask.extent.width, 1)
        let scaleY = image.extent.height / max(mask.extent.height, 1)
        mask = mask.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let blurred = mask.clampedToExtent()
            .applyingGaussianBlur(sigma: 7)
            .cropped(to: image.extent)

        let blend = CIFilter.blendWithMask()
        blend.inputImage = image
        blend.backgroundImage = CIImage(color: .clear).cropped(to: image.extent)
        blend.maskImage = blurred
        return blend.outputImage
    }

    private static func studioPaper(in extent: CGRect) -> CIImage {
        let gradient = CIFilter.linearGradient()
        gradient.point0 = CGPoint(x: extent.midX, y: extent.maxY)
        gradient.point1 = CGPoint(x: extent.midX, y: extent.minY)
        gradient.color0 = CIColor(red: 0.78, green: 0.79, blue: 0.81)
        gradient.color1 = CIColor(red: 0.42, green: 0.44, blue: 0.47)
        return (gradient.outputImage ?? CIImage(color: CIColor(red: 0.62, green: 0.63, blue: 0.65)))
            .cropped(to: extent)
    }

    private static func grade(_ image: CIImage) -> CIImage {
        let controls = CIFilter.colorControls()
        controls.inputImage = image
        controls.contrast = 1.06
        controls.saturation = 0.96
        controls.brightness = 0.015

        let shadows = CIFilter.highlightShadowAdjust()
        shadows.inputImage = controls.outputImage
        shadows.shadowAmount = 0.18
        shadows.highlightAmount = 0.92

        let temp = CIFilter.temperatureAndTint()
        temp.inputImage = shadows.outputImage
        temp.neutral = CIVector(x: 6500, y: 0)
        temp.targetNeutral = CIVector(x: 6200, y: 2)

        let sharpened = CIFilter.unsharpMask()
        sharpened.inputImage = temp.outputImage
        sharpened.radius = 1.4
        sharpened.intensity = 0.28

        return sharpened.outputImage ?? image
    }
}

private extension CGRect {
    var area: CGFloat { width * height }
}
