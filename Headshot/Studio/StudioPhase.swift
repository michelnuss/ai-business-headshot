import UIKit

enum StudioPhase {
    case empty
    case ready(UIImage)
    case generating(source: UIImage, status: String)
    case result(original: UIImage, headshot: UIImage)
    case failed(source: UIImage, message: String)

    var sourceImage: UIImage? {
        switch self {
        case .empty:
            return nil
        case .ready(let image),
             .generating(let image, _),
             .failed(let image, _):
            return image
        case .result(let original, _):
            return original
        }
    }

    var resultImage: UIImage? {
        if case .result(_, let headshot) = self {
            return headshot
        }
        return nil
    }

    var isGenerating: Bool {
        if case .generating = self { return true }
        return false
    }
}
