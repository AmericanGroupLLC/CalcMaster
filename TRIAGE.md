# CalcMaster — Triage

## Status: ✅ Resolved — repository is Flutter (iOS + Android) only

## What was here

The repo carried five parallel implementations and a server alongside the
shipping Flutter app, which inflated the dependency surface and made it
ambiguous what actually gets released.

## Resolution

Removed with `git rm` (recoverable from history), by explicit decision:

| Removed | What it was |
|---|---|
| `legacy-react-native/` | Original React Native implementation |
| `mobile-rn/` | Second, Expo-based React Native client |
| `extension/` | Browser extension (manifest, popup, content scripts) |
| `desktop/` | Electron wrapper |
| `backend/` | NestJS API server + Dockerfile |
| `web/` | Flutter web platform target |
| `src/`, `tests_suite/` | Stray TypeScript file + TS/Jest suite for the above |
| `package.json`, `package-lock.json`, `pnpm-lock.yaml`, `tsconfig.json`, `jest.config.js` | Node/TS tooling |
| `app.json`, `eas.json` | Expo / EAS build config |
| `docker-compose.yml`, `.env.example` | Backend runtime config |

**Note:** `backend/` was the API the Flutter client calls at runtime
(`ApiClient` → `api.safecodeg.com`: `/ai/chat`, `/users/me`,
`/subscriptions/active`). It was removed on the understanding that it is
deployed and maintained from a different repository. The Flutter app still
depends on that service being reachable — removing the code did not remove the
dependency.

## Kept deliberately

- `fastlane/` + `Gemfile` — iOS/Android deployment lanes.
- `marketing/` + `firebase.json` (`marketing` target) + `.github/workflows/pages.yml` —
  publishes the Privacy Policy / Terms / Support pages. **Both app stores reject
  submissions without a reachable Privacy Policy URL**, so this is load-bearing.
- `kIsWeb` guards in `lib/` — harmless defensive code; stripping them would be a
  wide, risky refactor for no runtime benefit.

## Follow-ups not done here

- Template leftovers remain at the repo root: `.gitignore.tmpl.new`,
  `README.md.tmpl.new`, `analysis_options.yaml.tmpl.new`,
  `pubspec.dev_dependencies.yaml`.
- Release blockers (Android signing key, real iOS AdMob IDs) are tracked in
  [PRODUCTION.md](PRODUCTION.md), not here.
