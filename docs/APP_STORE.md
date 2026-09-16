# App Store submission checklist

Headshot is an iPhone-only SwiftUI app with **no Push**, **no Sign in with Apple**, **no IAP yet**, and **no backend**. Replace the placeholders below, then archive from Xcode. Date of this checklist: 16 September 2026.

## 1. Accounts and identifiers (human)

- [ ] Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99 USD / year). Organization enrollment needs a D-U-N-S number and can take days.
- [ ] In [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list):
  - [ ] Register an **App ID**. Replace the placeholder bundle ID `com.yourcompany.headshot` with a reverse-DNS id you own (`com.yourdomain.headshot`).
  - [ ] Capabilities: **none required**. Do not add Push Notifications, Associated Domains, or Sign in with Apple unless a later version needs them.
- [ ] In Xcode → target **Headshot** → *Signing & Capabilities*:
  - [ ] Team = your Personal Team (device debug) or paid team (TestFlight / App Store).
  - [ ] Automatically manage signing = on.
  - [ ] Bundle Identifier = the App ID you registered.
- [ ] Create the app record in [App Store Connect](https://appstoreconnect.apple.com) (same bundle ID, iOS, category **Photo & Video**).

`DEVELOPMENT_TEAM` is intentionally unset in the project. Xcode fills it when you pick a team. Do not commit a team ID unless this repo is private to that org.

## 2. What is already set in the project

| Setting | Value | Where |
| --- | --- | --- |
| Display name | Headshot | `INFOPLIST_KEY_CFBundleDisplayName` + `Info.plist` |
| Bundle ID placeholder | `com.yourcompany.headshot` | target build settings |
| Marketing version | `1.0.0` | `MARKETING_VERSION` |
| Build | `1` | `CURRENT_PROJECT_VERSION` |
| Deployment target | iOS 17.0 | project + target |
| Devices | iPhone only | `TARGETED_DEVICE_FAMILY = 1` |
| Orientations | Portrait | Info.plist + build settings |
| Category | Photography | `LSApplicationCategoryType` |
| Mac Catalyst / iPad | Off | build settings |
| Push | None | no entitlement |
| Encryption export | HTTPS only, non-exempt = NO | `ITSAppUsesNonExemptEncryption` |
| App icon | 1024×1024 `AppIcon.appiconset` | drop a final PNG over `AppIcon.png` (no alpha, no rounded mask) |
| Launch screen | `LaunchBackground` + `LaunchMark` | replace mark with final logo |
| Camera / Photos strings | Present | `Headshot/Info.plist` |
| Privacy manifest | Photos for app functionality, no tracking | `PrivacyInfo.xcprivacy` |
| Secrets | Empty `openAIAPIKey`; runtime key in Keychain via Settings | `AppConfig.swift`, Settings gear |

Bump **build** (`CURRENT_PROJECT_VERSION`) on every TestFlight upload. Bump **version** (`MARKETING_VERSION`) for a store release.

Debug vs Release: standard Xcode configs (`-Onone` / whole-module `-O`). No secrets differ between configs. Keep `AppConfig.openAIAPIKey = ""` in anything you archive.

## 3. TestFlight

- [ ] Product → Archive (Any iOS Device, Release).
- [ ] Distribute App → App Store Connect → Upload.
- [ ] Wait for processing; add internal testers (no review) then external (Beta App Review).
- [ ] Export compliance question: **No** — the app only uses HTTPS (`ITSAppUsesNonExemptEncryption = false` already answers this in the binary).
- [ ] Content rights: you own the UI; user photos stay on device unless they paste an OpenAI key.

Do not ship a shared vendor API key in the binary. Testers who want cloud studio paste their own key in **Settings**. A later paid product should proxy the model through your server so the key never ships.

## 4. Privacy nutrition labels (App Store Connect)

Fill **App Privacy** to match the manifest:

| Data | Collected? | Linked to identity? | Used for tracking? | Purpose |
| --- | --- | --- | --- | --- |
| Photos or Videos | Yes (the portrait they pick or take) | No | No | App Functionality |
| Other | No | — | — | — |

Third-party: if the user pastes an OpenAI key, the portrait is uploaded to OpenAI (`api.openai.com`) to produce the edit. State that in the privacy policy. The on-device studio never leaves the phone.

Required usage strings (already in `Info.plist`):

- Camera — take a portrait for the studio headshot
- Photo Library (read) — choose a portrait
- Photo Library (add) — save the result

You do **not** need microphone, location, tracking, or ATT.

## 5. Screenshots and listing copy

iPhone-only, so one size class is enough.

- Required: **6.9" iPhone** portrait, 1–10 shots. Accepted sizes: **1320×2868**, **1290×2796**, or **1260×2736** px ([Apple spec](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)).
- Recommended capture device: iPhone 16/17 Pro Max simulator at 1320×2868.
- Optional: 6.5" set; Apple will scale 6.9" down if omitted.
- iPad screenshots: not required (`TARGETED_DEVICE_FAMILY = 1`).
- App preview video: optional, 15–30 s.

Suggested shot list: empty studio → library pick → generating overlay → before/after slider → save.

Subtitle (30 characters) example: `Studio portraits, still you.`

Description should say identity is preserved (lighting, background, attire only).

Support URL and Privacy Policy URL are required. Host a one-pager before submit.

## 6. Review notes template (paste into App Store Connect)

```
Headshot turns a user photo into a professional business headshot.

HOW TO TEST
1. Launch the app. No account, no login.
2. Tap Library and pick any portrait (Simulator has no camera).
3. Tap Create headshot. The default path is on-device (Vision + Core Image) and needs no network or API key.
4. Drag the before/after handle, then Share or Save.

OPTIONAL CLOUD PATH
Settings (gear) → paste an OpenAI API key to use gpt-image-1 image edits.
We are NOT shipping a vendor key. Reviewers do not need the cloud path.

PERMISSIONS
Camera and Photos are used only for the portrait the user chooses and to save the result.

EXPORT COMPLIANCE
Uses HTTPS only. ITSAppUsesNonExemptEncryption is false.
```

## 7. Human setup that this repo cannot do

1. Pick a real bundle ID and Apple Team.
2. Replace `AppIcon.png` (1024×1024, square, no transparency) and `LaunchMark.png`.
3. Privacy policy + support URL.
4. Screenshots from a Retina iPhone or simulator.
5. Age rating (suggest 4+; no unrestricted web, no user-generated social).
6. If you later add **paid credits**: App Store In-App Purchase (consumable or subscription), StoreKit 2, and a privacy/ToS update. That is not in this build.
7. If you later add a **shared** model key: a tiny HTTPS backend. Do not embed the key.

## 8. Review risk notes

- AI image edit of a person’s photo: keep the identity-lock copy in the UI and listing so review understands it is not an “entertainment morph” deepfake toy.
- No user accounts → no Sign in with Apple requirement.
- No third-party ads → no tracking / ATT.
- Swift-only, Apple frameworks + optional OpenAI HTTPS. Nothing that typically blocks review.
