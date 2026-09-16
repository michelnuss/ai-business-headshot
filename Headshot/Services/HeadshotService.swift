import Foundation
import UIKit

enum HeadshotError: LocalizedError, Equatable {
    case missingAPIKey
    case invalidImage
    case transport(String)
    case api(String)
    case unauthorized
    case quota
    case saveDenied
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "No API key is set. Paste one in AppConfig.swift, or keep using the on-device studio."
        case .invalidImage:
            return "That photo couldn’t be prepared. Try a different portrait."
        case .transport(let message):
            return message
        case .api(let message):
            return message
        case .unauthorized:
            return "OpenAI rejected the API key. Check the value in AppConfig.swift."
        case .quota:
            return "OpenAI returned a billing or quota error. Check your plan, then try again."
        case .saveDenied:
            return "Photos access is off. Enable it in Settings, or use Share instead."
        case .saveFailed:
            return "Couldn’t save to Photos. Try Share instead."
        }
    }
}

protocol HeadshotGenerating {
    func generateHeadshot(from image: UIImage) async throws -> UIImage
}

enum HeadshotServiceFactory {
    @MainActor
    static func make() -> any HeadshotGenerating {
        if AppConfig.usesCloudAI {
            return OpenAIHeadshotService()
        }
        return MockStudioService()
    }
}

/// On-device path used when no API key is present.
/// Crops to a head-and-shoulders frame, replaces the background, and grades light.
struct MockStudioService: HeadshotGenerating {
    func generateHeadshot(from image: UIImage) async throws -> UIImage {
        let started = Date()
        let result = try await PortraitStudio.render(image)
        let remaining = 0.9 - Date().timeIntervalSince(started)
        if remaining > 0 {
            try await Task.sleep(for: .seconds(remaining))
        }
        return result
    }
}

struct OpenAIHeadshotService: HeadshotGenerating {
    func generateHeadshot(from image: UIImage) async throws -> UIImage {
        let key = AppConfig.resolvedAPIKey
        guard !key.isEmpty else { throw HeadshotError.missingAPIKey }

        guard let jpeg = image
            .normalizedOrientation()
            .downscaled(maxDimension: 1536)
            .jpegData(compressionQuality: 0.86)
        else {
            throw HeadshotError.invalidImage
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        func field(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        field("model", AppConfig.imageModel)
        field("prompt", AppConfig.transformationPrompt)
        field("size", "1024x1536")
        field("quality", "high")
        field("input_fidelity", "high")
        field("output_format", "png")
        field("n", "1")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image[]\"; filename=\"portrait.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(jpeg)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")

        guard let url = URL(string: "\(AppConfig.openAIBaseURL)/images/edits") else {
            throw HeadshotError.transport("The OpenAI URL in AppConfig.swift is not valid.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw HeadshotError.transport("Couldn’t reach OpenAI. Check your connection and try again.")
        }

        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if status == 401 || status == 403 {
            throw HeadshotError.unauthorized
        }

        if let apiError = try? JSONDecoder().decode(OpenAIErrorEnvelope.self, from: data).error {
            throw Self.mapAPIError(apiError.message ?? "OpenAI returned an error.")
        }

        guard (200...299).contains(status) else {
            throw HeadshotError.api("OpenAI returned HTTP \(status). Try again in a moment.")
        }

        let decoded = try JSONDecoder().decode(OpenAIImagesResponse.self, from: data)
        guard let item = decoded.data?.first else {
            throw HeadshotError.api("OpenAI returned an empty image response.")
        }

        if let b64 = item.b64Json, let imageData = Data(base64Encoded: b64), let image = UIImage(data: imageData) {
            return image
        }

        if let urlString = item.url, let remote = URL(string: urlString) {
            let (remoteData, _) = try await URLSession.shared.data(from: remote)
            if let image = UIImage(data: remoteData) {
                return image
            }
        }

        throw HeadshotError.api("OpenAI didn’t return a usable image. Try another photo.")
    }

    private static func mapAPIError(_ message: String) -> HeadshotError {
        let lower = message.lowercased()
        if lower.contains("quota") || lower.contains("billing") || lower.contains("insufficient") {
            return .quota
        }
        if lower.contains("incorrect api key") || lower.contains("invalid api key") {
            return .unauthorized
        }
        return .api(message)
    }
}

private struct OpenAIImagesResponse: Decodable {
    struct Item: Decodable {
        let b64Json: String?
        let url: String?

        enum CodingKeys: String, CodingKey {
            case b64Json = "b64_json"
            case url
        }
    }

    let data: [Item]?
}

private struct OpenAIErrorEnvelope: Decodable {
    struct Item: Decodable {
        let message: String?
        let code: String?
    }

    let error: Item?
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
