# Contributing to CalcMaster

## Branching
- `main` — protected; releases tagged from here
- `feat/<short-name>`, `fix/<short-name>`, `docs/<short-name>`, `chore/<short-name>`
- One topic per PR; rebase before merge

## Commits
- [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `perf:`, `ci:`
- Imperative mood, ≤72 chars subject, body wraps at 100

## Pull request flow
1. Open against `main`
2. CI must be green:
   - lint
   - unit + component
   - coverage gate (≥90% line / ≥85% branch)
   - build (debug)
3. At least one CODEOWNER approval
4. Squash-merge with conventional commit subject

## Code style
- Lint config in repo root is the source of truth
- Run `flutter analyze` and `flutter format` before pushing
- Pre-commit hook recommended (Husky / pre-commit)

## Tests required
- Every new behavior gets a unit/component test
- Every bug fix gets a regression test
- New screens/flows get at least one integration test
- New top-level user journeys get an E2E test

## Definition of done
- [ ] Tests written
- [ ] Coverage gate passes
- [ ] Docs updated (`docs/SPEC.md` and/or `docs/DESIGN.md` if behavior or shape changed)
- [ ] CHANGELOG entry added
- [ ] PR description includes screenshots/screencasts for UI changes
- [ ] No `console.log` / `print()` / `NSLog` left in source

## Reporting bugs / requesting features
Open an issue with the appropriate template. Include reproduction steps, expected vs actual, and environment.

## Security
Do **not** open a public issue for vulnerabilities. Email the owner listed in `CODEOWNERS`.
