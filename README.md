# Flutter CRUD Operation

A Flutter product inventory app that demonstrates complete **Create, Read, Update, and Delete (CRUD)** operations with **GetX**, **Firebase Cloud Firestore**, and **Firebase Storage**. Manage product details and photos, search inventory, and switch between light and dark themes.

> Firebase must be configured and its database and storage rules must allow the requested operation for cloud data to work. Without a working Firebase configuration, the app can still open, but products cannot be loaded or saved.

## Table of contents

- [Features](#features)
- [Built with](#built-with)
- [Getting started](#getting-started)
- [Firebase setup](#firebase-setup)
- [Running and testing](#running-and-testing)
- [Firestore data model](#firestore-data-model)
- [Project structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Security](#security)

## Features

- **Create products:** Enter a product name, description, category, SKU, price, quantity, and availability status.
- **Add product photos:** Pick an image to upload to Firebase Storage, or provide an image URL.
- **Browse products:** See the live product list and total inventory count on the dashboard.
- **View details:** Open a product to see its saved information and image.
- **Update products:** Edit a product and its photo while preserving the original creation date.
- **Delete products:** Confirm before removing a product and its associated uploaded photo.
- **Search inventory:** Search by product name, description, category, or SKU.
- **Responsive layout:** Adaptive dashboard and product cards for phone, tablet, and wider screens.
- **Light and dark themes:** Switch themes from the dashboard.
- **Visible connection state:** See Firebase connection/setup status and relevant loading or error states.

## Built with

| Technology | Purpose |
| --- | --- |
| Flutter and Dart | Cross-platform app and UI |
| GetX | Reactive state management and navigation |
| Firebase Core | Firebase initialization |
| Cloud Firestore | Live product records |
| Firebase Storage | Uploaded product photos |
| `image_picker` | Selecting a product photo |

## Getting started

### Requirements

- Flutter SDK and Dart SDK versions compatible with the constraints in [`pubspec.yaml`](pubspec.yaml).
- A Firebase project with **Cloud Firestore** and **Firebase Storage** enabled for cloud CRUD and image uploads.
- An Android emulator/device, iOS simulator/device, or Chrome.
- Xcode to build or run the iOS app; iOS builds require macOS.

### Install and run

1. Clone the repository and open its folder:

   ```bash
   git clone https://github.com/SirAseef/Flutter-Crud-Operation.git
   cd Flutter-Crud-Operation
   ```

2. Fetch the Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase as described in [Firebase setup](#firebase-setup).

4. Start the app on a connected device or emulator:

   ```bash
   flutter run
   ```

   To select a target explicitly, use (for example):

   ```bash
   flutter devices
   flutter run -d chrome
   ```

5. From the dashboard, tap **Add product** to create a record. Select a photo or enter an image URL, complete the product details, and save. Open a product to view, edit, or delete it.

## Firebase setup

Firebase app configuration is platform-specific and is **not committed** to this repository, because those files contain API keys. The generated files `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `firebase.json` are git-ignored. Placeholder templates are provided instead:

| Template | Real file (git-ignored) |
| --- | --- |
| [`lib/firebase_options.dart.example`](lib/firebase_options.dart.example) | `lib/firebase_options.dart` |
| [`android/app/google-services.json.example`](android/app/google-services.json.example) | `android/app/google-services.json` |
| [`firebase.json.example`](firebase.json.example) | `firebase.json` |

The recommended way is to let FlutterFire generate the real files for your own project (steps below). Alternatively, copy each template to its real filename and fill in the values from your Firebase Console. **The app will not compile until `lib/firebase_options.dart` exists.** Never commit these files; also restrict your API keys in Google Cloud Console (by app package/bundle ID or HTTP referrer, and to the Firebase APIs you use).

1. Create or select a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Cloud Firestore** and create a database.
3. Enable **Firebase Storage** and create a storage bucket.
4. Install and sign in to the Firebase CLI if you have not already:

   ```bash
   npm install -g firebase-tools
   firebase login
   ```

5. Activate FlutterFire CLI and configure the platforms you intend to run:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Select your Firebase project and register the requested Android, iOS, and/or web apps. Keep the Android application ID and iOS bundle ID consistent with the native app configuration. FlutterFire generates platform options; do not copy another project's configuration.

6. Fetch dependencies and run:

   ```bash
   flutter pub get
   flutter run
   ```

The dashboard should show **Connected** after the Firestore products stream succeeds. The app uses the Firestore collection named `items`; it creates product documents when saving new records. Firebase rules must grant the intended access for reads, writes, and image uploads/deletes.

## Running and testing

Run static analysis and widget tests from the project root:

```bash
flutter analyze
flutter test
```

Build a release Android APK:

```bash
flutter build apk --release
```

Build the web app:

```bash
flutter build web
```

For iOS, use a Mac with Xcode and valid Apple signing configuration:

```bash
flutter build ios
```

## Firestore data model

Product documents are stored in the `items` collection:

| Field | Type | Description |
| --- | --- | --- |
| `name` | String | Product name |
| `description` | String | Product description |
| `category` | String | Product category |
| `sku` | String | Stock keeping unit |
| `price` | Number | Product price |
| `quantity` | Integer | Available stock quantity |
| `status` | String | Availability status |
| `imageUrl` | String | Download URL or externally provided image URL |
| `imagePath` | String | Firebase Storage object path; empty for external image URLs |
| `createdAt` | Timestamp | Creation time, set for a new product |
| `updatedAt` | Timestamp | Last save/update time |

Uploaded photos are saved under `items/{productId}/` in Firebase Storage. The app uses the Firestore document ID as the product ID.

## Project structure

```text
lib/
├── controllers/
│   ├── app_controller.dart       # Reactive light/dark theme state
│   └── product_controller.dart   # Product list, search, and CRUD state
├── models/
│   └── product.dart              # Product model and Firestore conversion
├── services/
│   └── product_service.dart      # Firestore and Storage operations
├── views/
│   ├── home_page.dart            # Dashboard and searchable product list
│   ├── product_form_page.dart    # Create/edit product form
│   ├── product_view_page.dart    # Product details
│   └── splash_page.dart          # Startup screen
├── app_theme.dart                # Light and dark themes
├── firebase_options.dart.example # Template; generate firebase_options.dart locally (git-ignored)
└── main.dart                     # Firebase initialization and routes
test/
└── widget_test.dart              # Widget and responsive layout tests
```

## Troubleshooting

- **“Firebase setup required”** — Register the app in your Firebase project and run `flutterfire configure`. Ensure you have enabled Firestore and Storage.
- **Firestore connection or permission error** — Check your internet connection, confirm the Firebase project and app configuration match, and review Firestore security rules.
- **Photo upload or delete error** — Confirm Firebase Storage is enabled and its rules permit the intended operation. Uploaded images require Storage access.
- **Android app does not match Firebase configuration** — Check the Android application ID in `android/app/build.gradle.kts` matches the Android app registered in Firebase, then regenerate the configuration.
- **iOS app does not match Firebase configuration** — Check the iOS bundle ID matches the registered Firebase iOS app and regenerate FlutterFire configuration.
- **Dependencies or generated files are stale** — Run `flutter clean`, then `flutter pub get`, and try again.

## Security

This is a sample app and intentionally does **not** include user authentication. Do not put real or private product data in a publicly accessible database or storage bucket. Before using it with real users:

- Add Firebase Authentication.
- Deploy restrictive Firestore and Storage rules that authorize each user for only the records and files they are allowed to access.
- Do not use open/test rules in production.
- Never commit Firebase config files with real API keys; restrict keys in Google Cloud Console.
- Keep Firebase project configuration matched to a project you own or are authorized to use. Client configuration files are not a replacement for security rules.
