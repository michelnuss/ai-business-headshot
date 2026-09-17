# App Store submission checklist

Headshot is an iPhone-only SwiftUI app for **emerging markets** (Africa, South America, and similar): professional photos for jobs, visas, and profiles — not a US/EU vanity filter. **No Push**, **no Sign in with Apple**, **no IAP in this build**, **no backend**. Replace placeholders, then archive. Date: 16 September 2026.

Localizations shipped: English, Spanish, Portuguese, French (system language). Set App Store Connect primary and additional languages to match. Prefer availability in African and Latin American storefronts; use Apple regional price tiers (see [docs/COSTS_AND_PRICING.md](COSTS_AND_PRICING.md)).

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
| Display name | ProHeadshot | `INFOPLIST_KEY_CFBundleDisplayName` + `Info.plist` |
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
| App icon | 1024×1024 `AppIcon.appiconset` | `Headshot/Assets.xcassets/AppIcon.appiconset/AppIcon.png` (storefront export: `Marketing/AppIcon-1024.png`; no alpha, no rounded mask) |
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

Subtitle (30 characters) example: `Jobs, visas, real photos.`

Description should say identity is preserved (lighting, background, clothes only) and name the use cases: applications, visas, professional profiles. Do not sell it as a beauty or entertainment filter.

Availability: enable storefronts in Africa and Latin America. Use Apple’s regional pricing so $0.99–$2.99 packs map to local currency. Screenshot text should match the localization (ES, PT, FR, EN) — don’t ship English-only marketing in BR/MX/SN.

Support URL and Privacy Policy URL are required. Host a one-pager before submit.

## 6. Review notes template (paste into App Store Connect)

```
Headshot makes a formal studio photo from a phone snapshot for job applications, visas, and professional profiles. It keeps the same person — lighting, background, and clothes only.

HOW TO TEST
1. Launch. No account.
2. Tap Photos and pick any portrait (Simulator has no camera).
3. Tap Create headshot. Default path is on this iPhone (Vision + Core Image). No network, no key.
4. Slide to compare, then Share or Save. If a step fails, Try again is visible — nothing is hidden.

OPTIONAL CLOUD
Settings (gear) → paste an OpenAI key. Reviewers do not need this. We do not ship a vendor key. Uploads are small JPEGs.

PERMISSIONS
Camera and Photos: only the portrait the user chooses, and save/share.

EXPORT COMPLIANCE
HTTPS only. ITSAppUsesNonExemptEncryption is false.

POSITIONING
Built for slower networks and older iPhones (iOS 17 / iPhone XS class and newer). Localizations: EN, ES, PT, FR.
```

## 7. Human setup that this repo cannot do

1. Pick a real bundle ID and Apple Team.
2. Privacy policy + support URL.
3. Screenshots from a Retina iPhone or simulator.
4. Age rating (suggest 4+; no unrestricted web, no user-generated social).
5. If you later add **paid credits**: App Store In-App Purchase (consumable or subscription), StoreKit 2, and a privacy/ToS update. That is not in this build.
6. If you later add a **shared** model key: a tiny HTTPS backend. Do not embed the key.

## 8. Review risk notes

- AI image edit of a person’s photo: keep the identity-lock copy in the UI and listing so review understands it is not an “entertainment morph” deepfake toy.
- No user accounts → no Sign in with Apple requirement.
- No third-party ads → no tracking / ATT.
- Swift-only, Apple frameworks + optional OpenAI HTTPS. Nothing that typically blocks review.
