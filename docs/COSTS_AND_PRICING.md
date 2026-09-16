# Costs and pricing

Estimates so you can pick a retail price per headshot or a subscription. **As of 16 September 2026.** Recheck the cited pages before you lock IAP tiers — model vendors change rates.

No backend, no CDN, no Push, no analytics SDK in this build. Results live in the user’s Photos app. The only variable COGS is the **optional** cloud image API.

## Assumptions

| ID | Assumption | Value used | Why |
| --- | --- | --- | --- |
| A1 | Home market | United States | USD IAP tiers; Apple fee listed in USD |
| A2 | Apple program | Individual or small org, **Small Business Program** (≤ $1M prior-year proceeds) | 15% commission instead of 30% |
| A3 | Default cloud model in the app today | OpenAI `gpt-image-1`, `quality=high`, `size=1024x1536`, `input_fidelity=high` | Matches `AppConfig.swift` + `OpenAIHeadshotService` |
| A4 | Input photo after client downscale | JPEG, longest side 1536 px | `downscaled(maxDimension: 1536)` |
| A5 | Failure / retry waste | **15%** extra API calls per *successful* result | Timeouts, safety rejects, user “try again” |
| A6 | Text prompt size | ~400 tokens | Identity-lock prompt in `AppConfig` |
| A7 | Hosting / storage / push | **$0** | On-device save + optional direct HTTPS to the model vendor |
| A8 | IAP tax | Ignored (net of VAT/GST; Apple remits in many stores) | Keep COGS comparable; real net depends on storefront |
| A9 | FX / rounding | USD list prices at standard Apple tiers ($0.99, $1.99, $2.99, $4.99, $9.99, …) | |
| A10 | Year | 2026, 12 equal months | Apple $99 fee amortized monthly as $8.25 |

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

**Working unit cost (this app, high / 1024×1536):**

| Step | USD |
| --- | --- |
| Output image (official table) | 0.250 |
| Input image + prompt (estimate) | 0.005 |
| **Call subtotal** | **0.255** |
| × 1.15 waste (A5) | **0.293** |
| **Use** | **$0.29–$0.30 per successful headshot** |

Official image-model token sheet also lists newer **gpt-image-2** at $4 / $15 per 1M image input/output tokens ([Pricing](https://developers.openai.com/api/docs/pricing)). If output token counts stay near gpt-image-1’s ~6,240 high 1024×1536 tokens, that is about **$0.094** output + ~$0.002 input ≈ **$0.11** after 15% waste. Treat that as the **migration target**, not the number in `AppConfig` today. Confirm `input_fidelity` (identity lock) on gpt-image-2 before switching.

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
| OpenAI gpt-image-1 high 1024×1536 | **Ships in app today** | **$0.29** | Best (prompt + `input_fidelity=high`) | Yes |
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

## Worked volume (OpenAI gpt-image-1 high — A3+A5)

COGS = **$0.293** ≈ **$0.29** per successful headshot. Overhead = $99/yr Apple fee.

| Successful shots / month | API COGS / mo | API + Apple fee / mo | API COGS / year |
| ---: | ---: | ---: | ---: |
| 1,000 | $293 | $301 | $3,516 |
| 10,000 | $2,930 | $2,938 | $35,160 |
| 100,000 | $29,300 | $29,308 | $351,600 |

Same volumes on **Gemini Flash Image** (~$0.046): **$46 / $460 / $4,600** per month.

Same volumes on **gpt-image-2 estimate** (~$0.11): **$110 / $1,100 / $11,000** per month.

Rate limits: gpt-image-1 Tier 1 is **5 images/min**. 10k/month is easy; 100k/month (~2,300/day) needs a higher OpenAI usage tier ([model page IPM table](https://developers.openai.com/api/docs/models/gpt-image-1)).

---

## Retail bands (after Apple 15% + COGS)

`Net = list × 0.85`. `Profit = net − (COGS × shots in the SKU)`. COGS = $0.29 (gpt-image-1 high).

### One-shot (1 successful headshot)

| List (USD) | Apple 15% | You net | COGS | Profit | Margin on list |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1.99 | 0.30 | 1.69 | 0.29 | **1.40** | 70% |
| **2.99** | 0.45 | 2.54 | 0.29 | **2.25** | **75%** |
| 4.99 | 0.75 | 4.24 | 0.29 | **3.95** | 79% |

Impulse SKU: **$2.99**. $1.99 still works but looks cheap and trains a low anchor.

### Credit packs (consumable IAP)

| Pack | List | Net @15% | COGS | Profit | $ / extra shot vs $2.99 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 5 shots | 9.99 | 8.49 | 1.45 | **7.04** | $2.00 |
| **10 shots** | **14.99** | 12.74 | 2.90 | **9.84** | **$1.50** |
| 25 shots | 29.99 | 25.49 | 7.25 | **18.24** | $1.20 |

If you want a simpler grid: **10 for $9.99** → net $8.49 − $2.90 = **$5.59** profit (56% of list). Fine, slightly less premium.

### Subscription (auto-renewable)

Caps matter. Unlimited generative headshots at $0.29 COGS will lose money.

| Plan | Included / mo | List | Net @15% | COGS if fully used | Profit if fully used |
| --- | ---: | ---: | ---: | ---: | ---: |
| Light | 5 | 4.99 | 4.24 | 1.45 | **2.79** |
| **Standard** | **15** | **9.99** | 8.49 | 4.35 | **4.14** |
| Heavy (gpt-image-1) | 40 | 14.99 | 12.74 | 11.60 | **1.14** — too thin |
| Heavy on Gemini | 40 | 14.99 | 12.74 | 1.84 | **10.90** |

Year-2 Apple commission stays 15% for subscriptions even if you leave SBP.

**If COGS stays ~$0.29, do not sell unlimited.** Soft-cap the plan and sell top-up packs.

### 30% commission (no SBP) — $2.99 one-shot

Net $2.09 − $0.29 = **$1.80** (still healthy). Packs remain positive. Subscriptions with 40 gpt-image-1 shots at $14.99 go **negative** ($10.49 − $11.60).

---

## Suggested starting menu

1. **Free:** on-device studio (current default). Acquisition, no COGS.
2. **$2.99** — 1 cloud headshot (consumable).
3. **$14.99** — 10 cloud headshots.
4. Optional later: **$9.99 / month** — 15 cloud headshots, then $2.99 top-ups.

At 1,000 paid one-shots/month of $2.99 with 15% Apple + $0.29 COGS: revenue $2,990, Apple $449, COGS $290, **≈ $2,250 contribution** before the $8.25/mo developer fee.

Switching the default cloud model to Gemini (~$0.05) or a verified gpt-image-2 (~$0.11) roughly **doubles or triples** generative margin and is the main lever — not hosting.

---

## What would change these numbers

- Leaving Small Business Program (30% / EU 26%).
- Shipping a **shared** vendor key (you pay COGS; need abuse caps).
- Allowing retries without charging a credit (waste factor > 15%).
- Storing full-res PNG on your S3 at 100k+/mo.
- Using Photoroom instead of generative attire (lower COGS, weaker “LinkedIn blazer” story).

Re-run this sheet when you change `AppConfig.imageModel`, quality, or size.
