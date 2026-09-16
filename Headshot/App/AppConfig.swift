import Foundation

/// Runtime configuration for Headshot.
///
/// Paste an OpenAI API key into `openAIAPIKey` to send portraits to
/// `gpt-image-1` with high input fidelity. Leave it blank (the default) to
/// use the on-device mock studio, which is fully usable in Simulator.
enum AppConfig {
    /// OpenAI API key. **Leave empty** in App Store / TestFlight archives.
    /// Paste a key at runtime in Settings (Keychain) instead of compiling one in.
    static let openAIAPIKey = ""

    /// Optional override for the Images API base URL.
    static let openAIBaseURL = "https://api.openai.com/v1"

    /// Image model used for identity-preserving edits.
    static let imageModel = "gpt-image-1"

    /// Set to `true` to keep using the on-device studio even after a key is pasted.
    static let forceMockStudio = false

    static var usesCloudAI: Bool {
        !forceMockStudio && isAPIKeyPresent
    }

    static var isAPIKeyPresent: Bool {
        !resolvedAPIKey.isEmpty
    }

    /// Compile-time key wins (local debug). Otherwise the Keychain value from Settings.
    static var resolvedAPIKey: String {
        let compiled = openAIAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if !compiled.isEmpty { return compiled }
        return APIKeyStore.load() ?? ""
    }

    /// Identity-preserving edit prompt. Facial geometry is explicitly off-limits.
    static let transformationPrompt = """
    Edit this photograph into a professional business headshot.

    IDENTITY LOCK (mandatory):
    - This is the same person. Keep their exact face, facial structure, bone structure, \
    age, gender presentation, skin tone, eye shape, nose, mouth, jawline, brows, \
    hairline, and every distinctive mark (moles, scars, freckles, glasses).
    - Do NOT change facial geometry. Do NOT slim, widen, or reshape the face. \
    Do NOT swap identity, beautify by morphing, or make them look like someone else.
    - Do NOT alter expression beyond a natural, slight professional ease. \
    Keep the original head pose as much as possible.

    ALLOWED ADJUSTMENTS ONLY:
    - Replace the background with a clean, seamless studio backdrop \
    (neutral gray or soft charcoal paper, gently out of focus).
    - Wardrobe: if clothing is casual, change it to simple professional attire \
    (well-fitted navy or charcoal blazer, or a crisp collared shirt). Keep it understated.
    - Lighting: even, flattering studio light; soft key from slightly above; \
    gentle fill; no harsh shadows; no dramatic color gels.
    - Grooming: tidy flyaway hair, even skin texture, reduce temporary blemishes. \
    Keep real skin texture — no plastic or airbrushed look.
    - Framing: head-and-shoulders portrait, subject centered, eyes roughly on the \
    upper third, looking toward camera. Photorealistic photograph only.

    No text, logos, watermarks, jewelry changes unless already present, \
    or illustration/painting effects.
    """
}
