# Flutter CRUD Operation

A complete product inventory CRUD app built with Flutter, GetX, Cloud Firestore, and Firebase Storage. Add, browse, search, edit, and delete products from a responsive interface, with optional product photos and light/dark themes.

## Features

- Create products with a name, description, category, SKU, price, quantity, availability, and optional image.
- Read live product records from the Firestore `items` collection.
- Update existing product details and replace product photos.
- Delete products after confirmation; uploaded images are managed in Firebase Storage.
- Search products by name or description.
- View product details and inventory information.
- Switch between light and dark themes.
- Use the responsive screens on phone, tablet, and desktop-sized layouts.
- Start the app and browse the UI without Firebase configured; cloud operations require a working Firebase setup.

## Built with

- Flutter and Dart
- GetX for state management and navigation
- Cloud Firestore for product records
- Firebase Storage for product photos
- `image_picker` for selecting images

## Project structure

```text
lib/
  controllers/  GetX controllers for app theme and product state
  models/       Product model and Firestore document conversion
  services/     Firestore and Firebase Storage operations
  views/        Splash, dashboard, product form, and detail screens
  app_theme.dart
  firebase_options.dart
  main.dart
test/
  widget_test.dart
```

## Requirements

- Flutter SDK compatible with the Dart SDK constraint in `pubspec.yaml`
- A configured Firebase project with Cloud Firestore and Firebase Storage enabled
- Android emulator/device, iOS simulator/device, or Chrome for running the app

## Getting started

1. Clone this repository and open the project directory.
2. Install dependencies:

   ```sh
   flutter pub get
   ```

3. Configure Firebase for your own project if needed. The checked-in `lib/firebase_options.dart` and `android/app/google-services.json` are project-specific. In the Firebase Console, enable Cloud Firestore and Firebase Storage. To replace the current project configuration, run:

   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Sign in with Firebase CLI first if required (`firebase login`). Do not copy configuration from a Firebase project you do not own or have permission to use.

4. Run the app:

   ```sh
   flutter run
   ```

   To run on Chrome explicitly:

   ```sh
   flutter run -d chrome
   ```

5. Validate the project:

   ```sh
   flutter analyze
   flutter test
   ```

## Firebase and security

The app stores product documents in the Firestore `items` collection and image files in Firebase Storage. Firestore and Storage must be enabled in the Firebase project. The dashboard indicates when the Firestore stream is connected; Firebase permission or network errors are shown when cloud operations fail.

This sample intentionally has no authentication flow. Before using it with real users or data, add Firebase Authentication and deploy restrictive Firestore and Storage security rules that authorize users to access only permitted records and files. Never use open test rules in a released app. The Firebase client configuration in this repository is not a substitute for security rules and must only point to a project you are authorized to use.
