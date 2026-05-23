# CalcMaster — Monetization & Growth Plan

> Source-of-truth strategy doc. Implementation status as of writing: **NOT yet wired into the app.** This document captures the plan and the concrete Flutter integration path for each pillar.

---

## 1. Affiliate Partnerships

- Integrate affiliate links across shopping, nutrition, and wellness-related sections.
- Earn commission from product purchases, meal delivery orders, and wellness subscriptions.
- Support multiple affiliate partners and referral programs.
- Implement click and conversion tracking through a centralized analytics service.

## 2. In-App Advertising

- Add banner, native, and interstitial ad placements throughout the app experience.
- Configure ad attribution and analytics for campaign performance.
- Ensure ads blend naturally into the UI with minimal disruption to users.

## 3. Premium Subscription Model

- Offer multiple subscription tiers:
  - Monthly subscription
  - Annual subscription with discounted pricing
  - One-time lifetime access option
- Premium features may include:
  - Ad-free experience
  - Advanced insights and analytics
  - Expanded feature access
  - Priority customer support

## 4. User Re-Engagement

- Use push notifications to improve retention and increase recurring engagement.
- Send reminders, recommendations, and personalized updates.
- Drive users back into the app ecosystem to increase activity and conversions.

## 5. Data & Insights Strategy

- Explore anonymized and aggregated trend reporting in the future.
- Maintain strong privacy protections and avoid sharing personally identifiable information.
- Potential opportunities for partnerships with research and industry organizations.

## Revenue Growth Targets

| Active Users | Estimated Monthly Revenue |
|---:|---:|
| 1K | ~$600 |
| 10K | ~$6K |
| 100K | ~$60K |
| 1M | ~$600K |

---

## Launch Readiness Checklist

Before launch:

- [ ] Replace placeholder API keys and affiliate IDs
- [ ] Configure advertising accounts and production ad units
- [ ] Set up subscription products in app store platforms (App Store Connect, Google Play Console)
- [ ] Configure push notification provider credentials (APNs key + FCM service account)
- [ ] Validate analytics and tracking integrations (event spec frozen)
- [ ] Complete final testing for monetization flows and user experience
- [ ] Privacy policy + EULA published and linked from in-app Settings
- [ ] App Tracking Transparency (ATT) prompt + Android UMP consent flow validated

---

## Implementation map (Flutter)

For each pillar, the concrete code package, what I can build vs what requires account setup, and rough effort.

### 1. Affiliate links + click tracking

| Item | Approach | Status |
|---|---|---|
| Centralized affiliate link manager | New `lib/lib_affiliates.dart` returning `{ partner, url, ref }` keyed on category and region | Code: ~1h |
| Click tracking | Wrap every affiliate tap in an `AnalyticsService.logClick(partner, slot, region)` call before launching `url_launcher` | Code: ~30m |
| Where to embed | Convert→Cooking results → "Buy on Amazon", Tools→BMI → "Get a smart scale", Finance→Compound → "Open a high-yield savings account" | Code: ~2h per slot |
| **Blocker** | Real affiliate IDs (Amazon Associates, Skimlinks, Impact, etc.) — business signup, no code needed | External |

### 2. In-app ads

| Item | Approach |
|---|---|
| SDK | `google_mobile_ads` (AdMob) — official, smallest binary, supports iOS + Android |
| Banner | Anchored 50dp banner above the bottom nav, hidden when premium |
| Interstitial | After every Nth use of a tool (e.g. 5th conversion in a session) |
| Native | Sponsored card injected at index 4 of the Convert grid |
| Test ad units | AdMob ships sandbox unit IDs for development |
| **Blocker** | AdMob account + production unit IDs + iOS App Store + Play Console listings | External |

Code effort: ~6 hours for all 3 placements + premium gating.

### 3. Premium subscription

| Item | Approach |
|---|---|
| SDK | **RevenueCat** (`purchases_flutter`) — abstracts App Store + Play Store IAP, handles receipts, restore, server-side validation |
| Tiers | `calcmaster_monthly`, `calcmaster_annual`, `calcmaster_lifetime` |
| Paywall UI | New screen `lib/screens/paywall_screen.dart`; entry points: ad close button, "Pro" badge in header, advanced-insights gate |
| Gate logic | `PremiumProvider` (ChangeNotifier) wrapping RevenueCat customer info; `isPro` boolean read by ad widgets and feature gates |
| **Blocker** | RevenueCat account, App Store Connect IAP products, Google Play products, sandbox testers | External |

Code effort: ~8 hours including paywall design, restore flow, and gating.

### 4. Push notifications + re-engagement

| Item | Approach |
|---|---|
| SDK | `firebase_messaging` for FCM (Android + iOS APNs) |
| Triggers | Scheduled daily ("Save this conversion?"), event-based ("New currency rates available"), behavior-based ("You haven't opened CalcMaster in 5 days") |
| Local notifications | `flutter_local_notifications` for in-app reminders that don't need a server |
| **Blocker** | Firebase project + APNs auth key uploaded to FCM + permission UX | Mostly external |

Code effort: ~4 hours for permission flow + 3 notification types.

### 5. Analytics

| Item | Approach |
|---|---|
| SDK | `firebase_analytics` for events, `firebase_crashlytics` for crashes |
| Event spec | `tab_open`, `convert_used`, `calc_used`, `affiliate_click`, `ad_impression`, `paywall_shown`, `purchase_started`, `purchase_completed` |
| Privacy | No PII; respect ATT + UMP consent; offer opt-out toggle in Settings |
| **Blocker** | Firebase project | External |

Code effort: ~3 hours.

---

## Total code effort

| Pillar | Code hours | Blockers |
|---|---:|---|
| Analytics | 3h | Firebase project |
| Ads | 6h | AdMob account |
| Subscriptions | 8h | RevenueCat + IAP products |
| Notifications | 4h | Firebase + APNs key |
| Affiliates | 4h | Affiliate signups |
| Settings + Paywall + Privacy | 4h | Privacy policy text |
| **Total** | **~29h** | |

---

## What I can implement *right now* without external accounts

> **STATUS · DONE.** All scaffolding below is implemented in the repo today.
> All credentials and toggles live in **one file**: `lib/monetization/monetization_config.dart`.
> Search for `// REPLACE:` to find every value to swap before launch, then flip
> the matching master switch (e.g. `adsEnabled = true`) and rebuild.

1. **A `MonetizationConfig`** struct with placeholder IDs + master toggles per pillar so production keys never ship in dev builds.
2. **Premium-gating scaffolding** (`PremiumProvider`, `PremiumGate` widget) — initially returning `false` always, ready to swap RevenueCat in.
3. **Settings screen** with placeholder "Subscribe to Pro", "Restore purchases", "Send feedback", "Privacy policy" rows.
4. **Affiliate link wrapper** that opens a URL via `url_launcher` and logs an analytics event (analytics noop until Firebase wired).
5. **Banner ad placeholder widget** that reserves 50dp at the bottom of every screen, currently empty — drops `AdWidget` in once the AdMob ID exists.
6. **Notification permission prompt UX** that requests permission and persists user choice — no actual sends until FCM is configured.

This gives you a **monetization-ready scaffold** that compiles, ships, and can be flipped on per-pillar by adding just the credentials.

---

## What needs business / account work before any code helps

- App Store Connect listing (paid Apple Developer account: $99/yr)
- Google Play Console listing (one-time $25)
- Firebase project (free)
- AdMob account (free, requires AdSense linkage)
- RevenueCat account (free up to $10K MRR)
- Affiliate program signups (Amazon Associates etc.)
- Privacy policy + Terms of Service (legal review or boilerplate from Iubenda / Termly)
