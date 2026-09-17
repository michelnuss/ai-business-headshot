# ProHeadshot AI

A professional studio photo from a phone snapshot — for **job applications, visas, and professional profiles**. Built for people in Africa, South America, and similar markets who need a formal photo without a studio or expensive AI apps.

You still look like you. The app only adjusts lighting, background, and clothes. It does not change your face.

Open `Headshot.xcodeproj` on a Mac. No API key is required. The full flow runs on the iPhone.

## Who it is for

- Job and internship applications
- Visas and other official photos
- LinkedIn, company directories, and professional profiles

Not a beauty filter. Copy, pricing, and network use assume slower connections, older iPhones, and low IAP prices — not a US/EU-first product.

Languages in this build: **English, Spanish, Portuguese**, with **French** included for West and Central Africa. The system language picks the strings.

## What you get

One screen. Take a photo or pick one, tap **Create headshot**, compare with a slider, then save or share. Retry is always available if the network drops.

| Mode | When | What it does |
| --- | --- | --- |
| **On this iPhone** | No cloud key (default) | Crop, studio background, lighting. Face pixels stay yours. No upload. |
| **Cloud studio** | Key in Settings | Small JPEG sent to OpenAI `gpt-image-1` with identity lock. Medium quality, ~1024 px upload, JPEG back — cheaper and lighter on slow data. |

## Open and run

Xcode 15.4+ (iOS 17). iPhone XS / XR and newer can run iOS 17.

1. Open `Headshot.xcodeproj`.
2. Scheme **Headshot**, iPhone simulator or device.
3. Signing: pick your Team. Bundle ID placeholder: `com.yourcompany.headshot`.
4. Run. Simulator has no camera — use **Photos**.

Privacy strings (localized) are in `Info.plist` / `InfoPlist.xcstrings`.

## Cloud key (optional)

Leave `AppConfig.openAIAPIKey` empty for store builds. Testers can paste a key in **Settings** (stored in the Keychain on that iPhone). Photos leave the device only with a key. That is explained in Settings — no hidden upload.

Cloud calls use:

- `input_fidelity=high` (keep the same person)
- `quality=medium` (price + download size)
- Upload longest side **1024 px**, JPEG ~0.72
- Timeout **180 s** (slow links)

## Privacy and trust

- No key: the photo never leaves the iPhone.
- With key: OpenAI receives the portrait to produce the studio photo. Said plainly in Settings.
- No accounts, no ads, no tracking, no dark-pattern “free trial” screens.

App Store checklist: [docs/APP_STORE.md](docs/APP_STORE.md).  
Emerging-market price math: [docs/COSTS_AND_PRICING.md](docs/COSTS_AND_PRICING.md).

## Project layout

```
Headshot.xcodeproj
Headshot/
  Localizable.xcstrings     EN / ES / PT / FR UI
  InfoPlist.xcstrings       Camera / Photos permission copy
  App/L10n.swift            Typed string keys
  App/AppConfig.swift       Empty key + identity prompt + upload caps
  Studio/                   Single screen
  Services/                 On-device studio + OpenAI client
docs/
  APP_STORE.md
  COSTS_AND_PRICING.md
Marketing/
  AppIcon-1024.png          App Store 1024×1024 (no alpha)
```

## If something fails

| Symptom | What to do |
| --- | --- |
| Signing error | Choose your team; unique bundle ID |
| Camera alert | Expected in Simulator — use Photos |
| Cloud key rejected | Check Settings |
| Slow or failed cloud call | Wait or tap Try again; on-device studio needs no network |
| Save fails | Enable Photos, or Share |
