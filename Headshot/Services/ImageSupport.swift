import CoreTransferable
import Photos
import UniformTypeIdentifiers
import UIKit

struct ImportedImage: Transferable {
    let image: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw HeadshotError.invalidImage
            }
            return ImportedImage(image: image)
        } exporting: { imported in
            imported.image.jpegData(compressionQuality: 0.92) ?? Data()
        }
    }
}

extension UIImage {
    func normalizedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func downscaled(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scaleFactor = maxDimension / longest
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

enum PhotoSaver {
    static func save(_ image: UIImage) async throws {
        let status: PHAuthorizationStatus
        let current = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if current == .notDetermined {
            status = await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { value in
                    continuation.resume(returning: value)
                }
            }
        } else {
            status = current
        }
        guard status == .authorized || status == .limited else {
            throw HeadshotError.saveDenied
        }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } catch {
            throw HeadshotError.saveFailed
        }
    }
}
