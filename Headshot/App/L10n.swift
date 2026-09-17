import Foundation

/// All user-facing copy. English is the defaultValue; translations live in Localizable.xcstrings.
enum L10n {
    static var appName: String { String(localized: "studio.title", defaultValue: "ProHeadshot AI") }

    static var tagline: String {
        String(
            localized: "studio.tagline",
            defaultValue: "Studio photos for jobs, visas, and LinkedIn"
        )
    }

    static var startOver: String { String(localized: "studio.startOver", defaultValue: "Start over") }
    static var settings: String { String(localized: "studio.settings", defaultValue: "Settings") }
    static var camera: String { String(localized: "studio.camera", defaultValue: "Camera") }
    static var library: String { String(localized: "studio.library", defaultValue: "Photos") }
    static var create: String { String(localized: "studio.create", defaultValue: "Create headshot") }
    static var share: String { String(localized: "studio.share", defaultValue: "Share") }
    static var save: String { String(localized: "studio.save", defaultValue: "Save") }
    static var retry: String { String(localized: "studio.retry", defaultValue: "Try again") }
    static var ok: String { String(localized: "studio.ok", defaultValue: "OK") }
    static var done: String { String(localized: "settings.done", defaultValue: "Done") }

    static var modeCloud: String { String(localized: "studio.mode.cloud", defaultValue: "Cloud studio") }
    static var modeDevice: String { String(localized: "studio.mode.device", defaultValue: "On this iPhone") }
    static var modeCloudA11y: String { String(localized: "studio.mode.cloud.a11y", defaultValue: "Using cloud studio") }
    static var modeDeviceA11y: String { String(localized: "studio.mode.device.a11y", defaultValue: "Using studio on this iPhone") }

    static var emptyTitle: String {
        String(localized: "studio.empty.title", defaultValue: "Add a photo")
    }
    static var emptyBody: String {
        String(
            localized: "studio.empty.body",
            defaultValue: "Lighting and background change. Your face stays yours."
        )
    }

    static var useJobs: String { String(localized: "studio.use.jobs", defaultValue: "Jobs") }
    static var useVisas: String { String(localized: "studio.use.visas", defaultValue: "Visas") }
    static var useLinkedIn: String { String(localized: "studio.use.linkedin", defaultValue: "LinkedIn") }

    static var trustNoUpload: String {
        String(localized: "studio.trust.noUpload", defaultValue: "No photo is uploaded")
    }
    static var trustIdentity: String {
        String(localized: "studio.trust.identity", defaultValue: "You still look like you")
    }

    static var captionEmpty: String {
        String(
            localized: "studio.caption.empty",
            defaultValue: "On this iPhone by default. Lighting, background, and clothes only."
        )
    }
    static var captionReady: String {
        String(
            localized: "studio.caption.ready",
            defaultValue: "Face the camera in good light. A simple snapshot is enough."
        )
    }
    static var captionGeneratingCloud: String {
        String(
            localized: "studio.caption.generating.cloud",
            defaultValue: "Sending a small photo. Slow internet is OK — you can retry if it fails."
        )
    }
    static var captionGeneratingDevice: String {
        String(
            localized: "studio.caption.generating.device",
            defaultValue: "Working on this iPhone: crop, background, and light. No photo is uploaded."
        )
    }
    static var captionResult: String {
        String(
            localized: "studio.caption.result",
            defaultValue: "Slide to compare. Save or share when it looks right."
        )
    }
    static var captionFailed: String {
        String(
            localized: "studio.caption.failed",
            defaultValue: "Your original photo is unchanged. Try again, or pick another."
        )
    }

    static var cameraUnavailableTitle: String {
        String(localized: "studio.cameraUnavailable.title", defaultValue: "Camera isn’t available")
    }
    static var cameraUnavailableChoose: String {
        String(localized: "studio.cameraUnavailable.choose", defaultValue: "Choose a photo")
    }
    static var cameraUnavailableMessage: String {
        String(
            localized: "studio.cameraUnavailable.message",
            defaultValue: "This device has no camera. Choose a photo from your library instead."
        )
    }

    static var photoA11y: String { String(localized: "studio.photo.a11y", defaultValue: "Selected portrait") }
    static var compareA11y: String {
        String(localized: "studio.compare.a11y", defaultValue: "Before and after comparison")
    }
    static var before: String { String(localized: "studio.before", defaultValue: "Your photo") }
    static var after: String { String(localized: "studio.after", defaultValue: "Studio") }

    static var statusReading: String { String(localized: "status.reading", defaultValue: "Reading the portrait…") }
    static var statusIdentity: String { String(localized: "status.identity", defaultValue: "Keeping your face yours…") }
    static var statusLight: String { String(localized: "status.light", defaultValue: "Setting studio light…") }
    static var statusBackground: String { String(localized: "status.background", defaultValue: "Cleaning the background…") }
    static var statusFinishing: String { String(localized: "status.finishing", defaultValue: "Finishing the headshot…") }

    static var statusMessages: [String] {
        [statusReading, statusIdentity, statusLight, statusBackground, statusFinishing]
    }

    static var toastSaved: String { String(localized: "toast.saved", defaultValue: "Saved to Photos") }
    static var loadFailed: String {
        String(localized: "error.loadFailed", defaultValue: "That photo couldn’t be opened. Try another one.")
    }

    static var generatingA11y: String {
        String(localized: "studio.generating.a11y", defaultValue: "Creating headshot")
    }

    enum Settings {
        static var title: String { String(localized: "settings.title", defaultValue: "Settings") }
        static var keyHeader: String { String(localized: "settings.key.header", defaultValue: "Cloud studio key") }
        static var saveKey: String { String(localized: "settings.key.save", defaultValue: "Save key") }
        static var removeKey: String { String(localized: "settings.key.remove", defaultValue: "Remove key") }
        static var placeholder: String { String(localized: "settings.key.placeholder", defaultValue: "Paste key") }
        static var footerRuntime: String {
            String(
                localized: "settings.footer.runtime",
                defaultValue: "Optional. Without a key, photos stay on this iPhone. With a key, the portrait is sent to OpenAI to make the studio photo. The key is stored only on this device."
            )
        }
        static var footerCompileTime: String {
            String(
                localized: "settings.footer.compileTime",
                defaultValue: "A key is already set in the app build, so it takes priority. For store builds, leave that empty and paste a key here instead."
            )
        }
        static var thisBuild: String { String(localized: "settings.build", defaultValue: "This version") }
        static var bundle: String { String(localized: "settings.bundle", defaultValue: "Bundle ID") }
        static var version: String { String(localized: "settings.version", defaultValue: "Version") }
        static var studio: String { String(localized: "settings.studio", defaultValue: "Studio") }
        static var studioCloud: String { String(localized: "settings.studio.cloud", defaultValue: "Cloud") }
        static var studioDevice: String { String(localized: "settings.studio.device", defaultValue: "This iPhone") }
    }

    enum Error {
        static var missingKey: String {
            String(
                localized: "error.missingKey",
                defaultValue: "No cloud key is set. Add one in Settings, or keep using the studio on this iPhone."
            )
        }
        static var invalidImage: String {
            String(localized: "error.invalidImage", defaultValue: "That photo couldn’t be prepared. Try a different one.")
        }
        static var unauthorized: String {
            String(localized: "error.unauthorized", defaultValue: "The cloud key was rejected. Check it in Settings.")
        }
        static var quota: String {
            String(
                localized: "error.quota",
                defaultValue: "The cloud studio is out of credit. Try again later, or use the studio on this iPhone."
            )
        }
        static var saveDenied: String {
            String(localized: "error.saveDenied", defaultValue: "Photos access is off. Turn it on in Settings, or use Share.")
        }
        static var saveFailed: String {
            String(localized: "error.saveFailed", defaultValue: "Couldn’t save to Photos. Try Share instead.")
        }
        static var transport: String {
            String(
                localized: "error.transport",
                defaultValue: "Couldn’t reach the studio. Check your connection and try again."
            )
        }
        static var badURL: String {
            String(localized: "error.badURL", defaultValue: "The studio address in the app is not valid.")
        }
        static func httpStatus(_ code: Int) -> String {
            let format = String(
                localized: "error.httpStatus",
                defaultValue: "The studio returned an error (%d). Try again in a moment."
            )
            return String(format: format, code)
        }
        static var emptyResponse: String {
            String(localized: "error.emptyResponse", defaultValue: "The studio sent back an empty photo. Try again.")
        }
        static var unusableImage: String {
            String(localized: "error.unusableImage", defaultValue: "The studio didn’t return a usable photo. Try another.")
        }
        static var genericAPI: String {
            String(localized: "error.genericAPI", defaultValue: "The studio returned an error. Try again.")
        }
    }
}
