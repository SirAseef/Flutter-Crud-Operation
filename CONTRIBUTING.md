# Contributing

Thanks for your interest in improving **Flutter CRUD Operation**! Contributions of all sizes are welcome — bug fixes, features, docs, and tests.

## Getting started

1. Fork the repository and clone your fork.
2. Install the latest **stable** Flutter SDK (`flutter --version`).
3. Configure your **own** Firebase project (see the README’s *Getting started*), or copy the templates for analysis-only work:
   ```bash
   cp lib/firebase_options.dart.example lib/firebase_options.dart
   ```
4. `flutter pub get`

## Workflow

1. Create a branch from `main`: `git checkout -b feat/short-description` (or `fix/…`, `docs/…`).
2. Keep changes focused; one logical change per pull request.
3. Before pushing, make sure these pass locally — CI runs the same checks:
   ```bash
   dart format lib test
   flutter analyze
   flutter test
   ```
4. Use clear, conventional commit messages, e.g. `feat: add price sorting`, `fix: handle empty SKU`.
5. Open a pull request and fill in the template.

## Code style

- Follow the lints in `analysis_options.yaml` (based on `flutter_lints`).
- State lives in GetX controllers (`lib/controllers`); Firebase access lives only in `lib/services`; widgets stay in `lib/views`.
- Add or update tests in `test/` for behaviour changes.

## Never commit secrets

`lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` and `firebase.json` are git-ignored on purpose. Only the `.example` templates belong in the repo. See [SECURITY.md](SECURITY.md).

## Code of conduct

Be respectful and constructive. Harassment or discrimination of any kind is not tolerated.
