import Foundation
import PhotosUI
import SwiftUI
import UIKit

@MainActor
@Observable
final class StudioViewModel {
    var phase: StudioPhase = .empty
    var pickerItem: PhotosPickerItem?
    var showCamera = false
    var showLibrary = false
    var showShare = false
    var showSettings = false
    var cameraUnavailable = false
    var isSaving = false
    var toast: String?
    var studioEpoch = 0

    var usesCloudAI: Bool {
        _ = studioEpoch
        return AppConfig.usesCloudAI
    }

    var modeLabel: String {
        usesCloudAI ? "OpenAI studio" : "On-device studio"
    }

    var canCreate: Bool {
        if case .ready = phase { return true }
        return false
    }

    var canStartOver: Bool {
        if case .empty = phase { return false }
        return true
    }

    func handlePickedItem(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            guard let imported = try await item.loadTransferable(type: ImportedImage.self) else {
                failLoad("That file couldn’t be opened as a photo. Try another one.")
                pickerItem = nil
                return
            }
            accept(imported.image)
            pickerItem = nil
        } catch {
            failLoad("Couldn’t load that photo. Try another one.")
            pickerItem = nil
        }
    }

    func acceptCameraImage(_ image: UIImage) {
        accept(image.normalizedOrientation())
    }

    func requestCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            cameraUnavailable = true
            return
        }
        showCamera = true
    }

    func createHeadshot() {
        guard case .ready(let image) = phase else { return }
        generateTask?.cancel()
        statusTask?.cancel()

        phase = .generating(source: image, status: Self.statusMessages[0])
        statusTask = Task { await rotateStatus(for: image) }

        generateTask = Task {
            do {
                let service = HeadshotServiceFactory.make()
                let headshot = try await service.generateHeadshot(from: image)
                guard !Task.isCancelled else { return }
                statusTask?.cancel()
                phase = .result(original: image, headshot: headshot)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                statusTask?.cancel()
                let message = (error as? HeadshotError)?.errorDescription
                    ?? error.localizedDescription
                phase = .failed(source: image, message: message)
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    func retry() {
        if case .failed(let image, _) = phase {
            phase = .ready(image)
            createHeadshot()
        }
    }

    func startOver() {
        generateTask?.cancel()
        statusTask?.cancel()
        pickerItem = nil
        toast = nil
        phase = .empty
    }

    func saveToPhotos() async {
        guard let image = phase.resultImage else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            try await PhotoSaver.save(image)
            presentToast("Saved to Photos")
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            let message = (error as? HeadshotError)?.errorDescription
                ?? "Couldn’t save to Photos."
            presentToast(message)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    func shareItems() -> [Any] {
        guard let image = phase.resultImage else { return [] }
        return [image]
    }

    func refreshStudioMode() {
        studioEpoch += 1
    }

    private var generateTask: Task<Void, Never>?
    private var statusTask: Task<Void, Never>?
    private var toastTask: Task<Void, Never>?

    private static let statusMessages = [
        "Reading the portrait…",
        "Locking facial identity…",
        "Setting studio light…",
        "Cleaning the background…",
        "Finishing the headshot…"
    ]

    private func accept(_ image: UIImage) {
        generateTask?.cancel()
        statusTask?.cancel()
        let prepared = image.downscaled(maxDimension: 2048)
        phase = .ready(prepared)
    }

    private func failLoad(_ message: String) {
        switch phase {
        case .empty:
            presentToast(message)
        case .ready(let image), .generating(let image, _), .failed(let image, _):
            phase = .failed(source: image, message: message)
        case .result(let original, _):
            phase = .failed(source: original, message: message)
        }
    }

    private func rotateStatus(for image: UIImage) async {
        var index = 0
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(2.2))
            guard !Task.isCancelled else { return }
            index = (index + 1) % Self.statusMessages.count
            if case .generating = phase {
                phase = .generating(source: image, status: Self.statusMessages[index])
            }
        }
    }

    private func presentToast(_ message: String) {
        toastTask?.cancel()
        toast = message
        toastTask = Task {
            try? await Task.sleep(for: .seconds(2.4))
            guard !Task.isCancelled else { return }
            if toast == message {
                toast = nil
            }
        }
    }
}
