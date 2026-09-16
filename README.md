# Headshot

An iPhone app that turns a snapshot of you into a professional business headshot.

It keeps **you** — same face, same structure, same identity — and only adjusts the studio parts: background, lighting, grooming, and attire.

Open `Headshot.xcodeproj` in Xcode. There is no API key in the project. The full camera → result flow runs immediately through an on-device studio.

## What you get

One screen. Take a photo or pick one, tap **Create headshot**, then compare with a before/after slider. Save to Photos or share.

| Mode | When | What it does |
| --- | --- | --- |
| **On-device studio** | `openAIAPIKey` is empty (default) | Face-aware crop, person cutout onto studio paper, restrained color grade. Never changes facial geometry. Works in Simulator with no network. |
| **OpenAI studio** | You paste a key | Sends the portrait to `gpt-image-1` image edits with `input_fidelity=high` and an identity-lock prompt. |

The toolbar pill tells you which path is active.

## Open and run

You need a Mac with **Xcode 15.4 or later** (iOS 17 SDK).

1. Open `Headshot.xcodeproj`.
2. Select the **Headshot** scheme and an iPhone simulator (or a connected iPhone).
3. Signing: pick your **Team** under the Headshot target → *Signing & Capabilities*. The bundle ID placeholder is `com.yourcompany.headshot` — change it to a reverse-DNS id you own before TestFlight.
4. Press **Run**.

### Simulator

The camera is not available. Use **Library** and pick any portrait (or a screenshot of a person). Create headshot uses the on-device studio. You should see a loading overlay, then a draggable before/after result.

### Device

**Camera** opens the front camera. iOS will ask for camera access the first time. **Save** asks for permission to add photos.

Usage strings live in `Headshot/Info.plist`:

- Camera — take a portrait for the studio headshot
- Photo library add — save the finished image
- Photo library — choose an existing portrait

## Paste an API key (optional)

**App Store / TestFlight:** leave `AppConfig.openAIAPIKey` empty. In the app, open **Settings** (gear) and paste a key. It is stored in the Keychain on that device only.

**Local debug:** you can still paste a key in `Headshot/App/AppConfig.swift`. Do not commit it. A compile-time key overrides Settings.

```swift
static let openAIAPIKey = ""
```

The app calls `POST /v1/images/edits` with:

- `model`: `gpt-image-1`
- `input_fidelity`: `high` (follow the input face closely)
- `size`: `1024x1536`
- `quality`: `high`
- Prompt: identity lock — no facial-structure or identity change; only background, attire, lighting, grooming

Your OpenAI account must be able to use `gpt-image-1`. If the API returns an error, the app shows it on the portrait card and leaves the original photo in place.

To keep using the mock after a key is pasted, set `forceMockStudio = true` in the same file.

**Do not commit a real key.** The placeholder is empty on purpose.

## Identity rules

The cloud prompt in `AppConfig.transformationPrompt` requires the model to keep the same person, bone structure, age, skin tone, and distinctive marks, and forbids reshaping the face. Combined with `input_fidelity=high`, that is the product rule: recognizable person, studio treatment only.

The on-device path never generates a new face. It crops, composites, and grades the pixels you already have.

## Privacy

- **No key:** the photo stays on the device.
- **With key:** the photo is uploaded to OpenAI to produce the edit. Do not use this path for photos you cannot send to a third party.

App Store privacy nutrition labels and export-compliance answers (HTTPS only, `ITSAppUsesNonExemptEncryption = false`) are in [docs/APP_STORE.md](docs/APP_STORE.md). Cost and pricing math is in [docs/COSTS_AND_PRICING.md](docs/COSTS_AND_PRICING.md).

## Project layout

```
Headshot.xcodeproj          Xcode project + shared scheme
Headshot/
  HeadshotApp.swift         App entry
  Info.plist                Camera / Photos usage strings
  App/AppConfig.swift       API key placeholder + identity prompt
  App/APIKeyStore.swift     Keychain storage for the runtime key
  Studio/                   Single-screen UI, settings, view model
  Studio/                   Single-screen UI + view model
  Capture/                  Camera picker + share sheet
  Services/                 OpenAI client, mock studio, image helpers
  Assets.xcassets           App icon + accent color
```

iPhone, portrait, iOS 17+. No extra packages.

## If something fails

| Symptom | What to do |
| --- | --- |
| Signing error | Choose your team; unique bundle ID if needed |
| Camera button alerts | Expected in Simulator — use Library |
| “OpenAI rejected the API key” | Check the value in `AppConfig.swift` |
| Billing / quota error | Check the OpenAI plan, or clear the key to use on-device |
| Save fails | Enable Photos access, or use Share |

This project was authored so it opens as a normal Xcode app on a Mac. There is no iOS simulator in the environment that produced it; run it locally to build and sign.
