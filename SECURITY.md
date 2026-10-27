# Security Policy

## Supported versions

Only the latest commit on `main` receives security fixes.

## Reporting a vulnerability

Please **do not open a public issue** for security problems. Instead, email **aseefahmed@aptechnorth.edu.pk** with:

- a description of the issue and its impact,
- steps to reproduce (or a proof of concept),
- any suggested fix.

You can expect an acknowledgement within a few working days. Please allow reasonable time for a fix before public disclosure.

## Firebase configuration & keys

- Firebase client config (`lib/firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, `firebase.json`) is **git-ignored**. Generate your own with `flutterfire configure`; only `.example` templates are committed.
- Firebase client API keys identify a project; they are **not** a substitute for access control. Protect your data with restrictive **Firestore** and **Storage Security Rules** and, ideally, **Firebase Authentication** and **App Check**.
- Never use open test-mode rules (`allow read, write: if true;`) in production.
- If you accidentally commit a key, rotate/restrict it in Google Cloud Console immediately — removing it from Git history alone is not enough.
