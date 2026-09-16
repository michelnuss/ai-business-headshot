# Costs and pricing

Estimates so you can pick a retail price per headshot or a pack. **As of 16 September 2026.** Primary customer is **Africa, South America, and similar markets** — not US/EU-first pricing. Recheck cited pages before locking IAP.

No backend, no CDN, no Push, no analytics SDK in this build. Results live in Photos. The only variable COGS is the optional cloud image API.

Apple shows IAP in **local currency**. The USD tier ($0.99, $1.99, $2.99…) is the equalized list price; storefronts convert (e.g. BRL, ZAR, NGN, KES, COP, MXN). Some countries share the US store; still price for purchasing power, not Silicon Valley ARPU.

## Assumptions

| ID | Assumption | Value used | Why |
| --- | --- | --- | --- |
| A1 | Home market | Emerging markets (Africa, Latin America, similar). USD tiers for Apple equalization | Local currency is Apple’s conversion of the USD price point |
| A2 | Apple program | **Small Business Program** (≤ $1M prior-year proceeds) | 15% commission |
| A3 | Default cloud path **in the app today** | OpenAI `gpt-image-1`, **`quality=medium`**, `1024x1536`, `input_fidelity=high`, JPEG in/out | Matches `AppConfig` — medium is what $0.99 packs can bear |
| A4 | Upload after client compress | JPEG, longest side **1024 px**, quality **0.72** | Slow/metered networks; older iPhones |
| A5 | Failure / retry waste | **15%** extra API calls per successful result | Timeouts on poor networks, user retry |
| A6 | Text prompt | ~400 tokens | Identity-lock + job/visa framing |
| A7 | Hosting / storage / push | **$0** | On-device save |
| A8 | IAP tax | Ignored (VAT/GST often remitted by Apple) | |
| A9 | List prices | Apple tiers **$0.99 / $1.99 / $2.99** as the default menu | High-income $4.99+ is optional, not the plan |
| A10 | Year | 2026 | $99 Apple fee → $8.25/mo |

If you are **not** in the Small Business Program, replace 15% with **30%** in every margin table (or 26% IAP in the EU under the 2026 EU terms — see Apple’s [EU apps page](https://developer.apple.com/support/apps-in-the-eu)).

---

## Fixed / platform costs

| Cost | Amount | Cadence | Source |
| --- | --- | --- | --- |
| Apple Developer Program | **$99 USD** | Per membership year | [developer.apple.com/programs](https://developer.apple.com/programs/) |
| App Store commission (standard) | **30%** of digital goods | Per paid app / IAP | [Membership details](https://developer.apple.com/programs/whats-included/) |
| App Store Small Business Program | **15%** while under the $1M proceeds cap | Per paid app / IAP | [Small Business Program](https://developer.apple.com/app-store/small-business-program/) |
| Subscriptions after year 1 | **15%** (even outside SBP) | Auto-renewable IAP | Same membership page, note 2 |
| EU IAP (Apple-processed, from 1 Oct 2026 terms) | **26%** standard / **15%** SBP | EU digital goods | [Apps in the EU](https://developer.apple.com/support/apps-in-the-eu) |
| TestFlight | $0 | Included with membership | |
| Push Notifications | $0 | Not used | |
| Sign in with Apple | $0 | Not used | |

**Per successful headshot, Apple’s $99/year is noise** once you have any volume: $99 / 12,000 shots = **$0.008**. Ignore it in unit COGS; budget it as overhead.

---

## AI transformation COGS (per API call)

### 1) OpenAI — current shipping choice

Official **gpt-image-1** published per-image table and token rates: [GPT Image 1 model page](https://developers.openai.com/api/docs/models/gpt-image-1).

| Quality | 1024×1024 | 1024×1536 (this app) |
| --- | --- | --- |
| Low | $0.011 | $0.016 |
| Medium | $0.042 | $0.063 |
| High | $0.167 | **$0.25** |

Edits also bill **input** tokens (text $5 / 1M, image $10 / 1M). A 1536-class selfie is on the order of **~$0.003–$0.006** extra (community tile math + ~400 text tokens). Negligible next to high-quality output.

**Working unit cost (this app, medium / 1024×1536):**

| Step | USD |
| --- | --- |
| Output image (official table) | 0.063 |
| Input image + prompt (1024-class JPEG) | 0.004 |
| **Call subtotal** | **0.067** |
| × 1.15 waste (A5) | **0.077** |
| **Use** | **~$0.08 per successful cloud headshot** |

High quality ($0.25 + waste ≈ **$0.29**) is **not** the shipping default. It cannot fund $0.99–$2.99 packs. Keep high as a later “HD” SKU only if you raise the price.

Official image-model token sheet also lists **gpt-image-2** at $4 / $15 per 1M image in/out ([Pricing](https://developers.openai.com/api/docs/pricing)) — a possible cheaper migrate after identity testing.

### 2) Google Gemini 2.5 Flash Image

Google’s launch post prices output at **$30 / 1M tokens**, **1,290 tokens/image** → **$0.039 / image**. Input image tokens are ~$0.0004. [Introducing Gemini 2.5 Flash Image](https://developers.googleblog.com/en/introducing-gemini-2-5-flash-image/).

| | USD |
| --- | --- |
| Call | ~0.040 |
| After 15% waste | **~$0.046** |

Identity fidelity is good for “edit this photo” but weaker than OpenAI’s explicit `input_fidelity=high`. Cheapest serious alternative.

### 3) Photoroom Image Editing API

Plus plan: **$0.10 per successful call** (background, relight, beautify in one request). Basic background-only: **$0.02**. Plans prepaid (e.g. **$20 / 1,000** Basic images). Sandbox: 1,000 watermarked Plus calls/month. [Photoroom API pricing](https://www.photoroom.com/api/pricing), [Plus pricing docs](https://docs.photoroom.com/image-editing-api-plus-plan/pricing).

After 15% waste: **~$0.115** for a Plus “studio” call. Strong at background/lighting; **will not change attire** the way a generative edit can.

### 4) Replicate FLUX.2 (optional fourth)

FLUX.2 [pro]: **$0.015 + $0.015 per input and output megapixel**. A 1024×1536 (~1.57 MP) edit ≈ $0.015 + 2 × 1.57 × $0.015 ≈ **$0.062** / call. [FLUX.2 on Replicate](https://replicate.com/blog/run-flux-2-on-replicate). Schnell is **$0.003** but is a poor identity lock for paid headshots.

After 15% waste: **~$0.071** (pro).

### Comparison (successful headshot, 15% waste)

| Provider | Role | Est. USD / success | Identity lock | Attire change |
| --- | --- | --- | --- | --- |
| OpenAI gpt-image-1 **medium** 1024×1536 | **Ships in app today** | **$0.08** | Best (prompt + `input_fidelity=high`) | Yes |
| OpenAI gpt-image-1 high 1024×1536 | Optional HD, not default | **$0.29** | Best | Yes |
| OpenAI gpt-image-2 (token estimate) | Migrate after testing | ~$0.11 | TBD | Yes |
| Gemini 2.5 Flash Image | Cheapest generative | **$0.046** | Good | Yes |
| Photoroom Plus | Studio ops, not wardrobe | **$0.12** | Excellent (no new face) | No |
| FLUX.2 pro on Replicate | Mid generative | **$0.071** | Fair | Yes |
| On-device Vision/Core Image | Default without a key | **$0** | Perfect (same pixels) | No |

---

## Hosting, storage, extras

| Item | This app | If you add it later | Typical cost |
| --- | --- | --- | --- |
| Backend | None | Cloudflare Worker / Fly.io proxy so the vendor key never ships | Often **$0–5/mo** until tens of thousands of requests; then still cents |
| Result storage / CDN | None (Photos app) | S3 + CloudFront, ~0.5–2 MB PNG | ~$0.023/GB-month store + ~$0.09/GB egress — **ignore at <100k shots** |
| Push | None | APNs is free; you still need a server | $0 APNs + hosting |
| Crash reporting | None | Sentry Developer: **5,000 errors/mo free** | [Sentry help](https://www.sentry.help/en/articles/13964960-can-i-have-a-live-app-in-the-app-store-using-sentry-on-the-free-developer-plan) |
| Analytics | None | TelemetryDeck new accounts: **50,000 signals/mo free** (from 1 Jul 2026) | [TelemetryDeck pricing update](https://telemetrydeck.com/blog/pricing-update-2026/) |

**Recommendation:** stay at $0 platform COGS until you sell a **shared** AI quota. Then add a $5/mo worker and keep photos off your disk.

---

## Worked volume (OpenAI gpt-image-1 **medium** — A3+A5)

COGS = **~$0.08** per successful cloud headshot. Apple fee $99/yr.

| Successful shots / month | API COGS / mo | API + Apple fee / mo | API COGS / year |
| ---: | ---: | ---: | ---: |
| 1,000 | $77 | $85 | $924 |
| 10,000 | $770 | $778 | $9,240 |
| 100,000 | $7,700 | $7,708 | $92,400 |

Same volumes on **Gemini Flash Image** (~$0.046): **$46 / $460 / $4,600** per month. Strong fallback if you need even cheaper packs.

High-quality OpenAI at the same volumes: **$293 / $2,930 / $29,300** — too heavy for this market.

Rate limits: gpt-image-1 Tier 1 is **5 images/min**. 10k/month is easy; 100k/month needs a higher usage tier ([model page](https://developers.openai.com/api/docs/models/gpt-image-1)).

---

## Retail bands — emerging markets first

`Net = list × 0.85` (Small Business). `Profit = net − (COGS × shots)`. **COGS = $0.08** (medium, shipping default).

Apple maps these USD tiers to local currency automatically. You can lower a storefront further in App Store Connect (e.g. a cheaper Brazil or Nigeria equivalent) without changing the US equalized tier.

### Default menu ($0.99–$2.99)

| SKU | List (USD equalized) | Apple 15% | You net | COGS | Profit | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 cloud photo | **0.99** | 0.15 | 0.84 | 0.08 | **0.76** | Impulse; still positive at 30% Apple ($0.61 profit) |
| **5 photos** | **1.99** | 0.30 | 1.69 | 0.40 | **1.29** | Best everyday pack |
| **10 photos** | **2.99** | 0.45 | 2.54 | 0.80 | **1.74** | Family / repeat applications |

Do **not** sell 10 shots at $2.99 on **high** quality ($2.54 − $2.90 = **loss**). Medium (or Gemini) is the constraint that makes this menu work.

Free on-this-iPhone studio stays free forever — acquisition, zero COGS, works offline.

### If a storefront can bear more

| SKU | List | Net @15% | COGS | Profit |
| --- | ---: | ---: | ---: | ---: |
| 1 photo | 1.99 | 1.69 | 0.08 | 1.61 |
| 10 photos | 4.99 | 4.24 | 0.80 | 3.44 |

Use this only after you see conversion in that country — not as the global default.

### Subscription (optional, capped)

Unlimited cloud at any COGS is dangerous on poor networks (retries). Prefer packs.

| Plan | Included / mo | List | Net @15% | COGS if used up | Profit |
| --- | ---: | ---: | ---: | ---: | ---: |
| Light | 5 | 1.99 | 1.69 | 0.40 | **1.29** |
| Standard | 12 | 2.99 | 2.54 | 0.96 | **1.58** |

Year-2 Apple subscription commission stays 15%.

### 30% commission (no Small Business Program)

$0.99 one-shot: net $0.69 − $0.08 = **$0.61**.  
$2.99 / 10: net $2.09 − $0.80 = **$1.29**. Still viable with medium quality. High quality 10-for-$2.99 is not.

---

## Suggested starting menu

1. **Free:** studio on this iPhone (crop, light, background). Always available, including offline.
2. **$0.99** — 1 cloud photo (job/visa this week).
3. **$1.99** — 5 cloud photos.
4. **$2.99** — 10 cloud photos.

At 1,000 paid $0.99 shots/month: revenue $990, Apple $149, COGS $80, **≈ $761 contribution** before the $8.25/mo developer fee.

Gemini at ~$0.05 COGS is the next lever if you need $0.99 packs in very price-sensitive storefronts and can accept a slightly weaker identity lock.

---

## What would change these numbers

- Defaulting back to **high** quality (breaks $0.99–$2.99 packs).
- Leaving Small Business Program (30% / EU 26%).
- Shipping a **shared** vendor key (you pay COGS; need hard caps).
- Not charging a credit on retry (waste > 15% on slow networks).
- US-only $9.99+ SKUs as the only option (wrong market).

Re-run this sheet when you change `AppConfig.imageModel`, `imageQuality`, or size.
