# Master-Cal — Triage

## Status: 🟡 Suspicious (not as broken as initially feared)

## Problems found

### 1. On-disk build artifacts (NOT tracked in git)
`ios/Pods/`, `ios/build/`, `build/` exist on disk but are correctly gitignored — `git ls-files build/` returns 0 tracked files. **No git surgery needed**, just clean working tree.

### 2. Legacy code coexisting
`legacy-react-native/` directory contains old RN implementation alongside the current Flutter app. This isn't broken per se, but increases cognitive load and dependency surface.

## Fix

```bash
cd /Users/spatchava/agl/Master-Cal

# 1. Clean disk artifacts (no git changes)
flutter clean
rm -rf ios/Pods ios/build build/ .dart_tool

# 2. Reinstall
flutter pub get
cd ios && pod install --repo-update && cd ..

# 3. Smoke build
flutter build ios --debug --no-codesign
flutter build apk --debug

# 4. Decide what to do with legacy-react-native/
# Option A: archive it (move to a separate branch)
git checkout -b archive/legacy-rn
git rm -r legacy-react-native
git commit -m "chore: archive legacy RN implementation"
git checkout master  # legacy-rn still exists on archive branch
# Option B: delete it
rm -rf legacy-react-native
```

## Templates applied
- 14 new files
- 4 `.tmpl.new`

## Next steps
1. Clean + smoke build
2. Decide on `legacy-react-native/`
3. Run `bash tool/coverage.sh` and bring coverage to ≥90/85
4. Replace placeholders in template files
