# Spec — CalcMaster

## 1. Overview
- **Owner:** AmericanGroupLLC
- **Status:** Draft / Approved / Shipping
- **Last updated:** May 26, 2026
- **Audience:** Global users, travelers, students, professionals

## 2. Functional requirements

### 2.1 User stories
1. **As a** Traveler, **I want to** convert currency instantly, **so that** I can understand prices in local currency.
2. (...)

### 2.2 Screens / flows
| ID | Flow | Entry | Exit | Acceptance |
| --- | --- | --- | --- | --- |
| F-01 | Currency conversion | Tap flag -> Select region -> Convert | See converted value | Given/When/Then |
| F-02 | (...) | | | |

### 2.3 Data models
```ts
// Example — replace per app
type User = {
  id: string;        // UUID v4
  email: string;     // RFC 5322
  createdAt: Date;
};
```

### 2.4 Internal API surface
| Endpoint / Method | Purpose | Inputs | Outputs | Errors |
| --- | --- | --- | --- | --- |
| `GET /v1/...` | | | | |

(Note: this is the *internal* contract between client and our own server. External SDK contracts go in `docs/RELEASE.md`.)

### 2.5 Error contracts
| Code | When | User message | Recovery |
| --- | --- | --- | --- |
| `AUTH_EXPIRED` | Session expired | "Please sign in again" | re-auth |
| `NETWORK` | No connectivity | "You're offline" | retry w/ backoff |
| `VALIDATION` | Bad input | field-level inline | re-submit |

## 3. Non-functional requirements

| Aspect | Requirement |
| --- | --- |
| **Availability** | 99.5% rolling 30-day |
| **Latency** | p95 ≤ 400ms server, ≤ 100ms UI input |
| **Cold launch** | ≤ 2.0s on mid-tier device |
| **Accessibility** | WCAG 2.2 AA / iOS VoiceOver / Android TalkBack |
| **Localization** | en, es, zh, hi, fr, ar, de, ja, pt, it, ko, ru |
| **Privacy** | No PII without explicit consent; data deletion flow ≤ 30 days |
| **Offline** | All core calculations work offline with static fallback rates for currency |
| **Battery** | < 2% drain per hour active use |

## 4. Telemetry
- **Events:** screen_view, action_taken, error, conversion
- **Sink:** Firebase Analytics
- **Sampling:** 100% of errors, 10% of action_taken

## 5. Rollout
- **Stages:** internal → 1% → 10% → 50% → 100%
- **Kill switch:** Remote Config
- **Rollback:** see `docs/RELEASE.md`

## 6. Compliance
- GDPR and COPPA compliant. No PII is collected without explicit consent. (GDPR, COPPA, HIPAA, etc. as applicable)

## 7. Out of scope
Direct hardware integration beyond GPS, custom theme engines beyond dark/light modes.
