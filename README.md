# StudyFlow — Free Offline Study Planner

StudyFlow is an Android-first Flutter app for students who want to organize assignments, schedule study blocks, and practice with flashcards.

## Features

- Home dashboard with due-soon assignments, completion progress, upcoming study blocks, and quick actions.
- Assignment management: create, edit, delete, mark complete, set subject, due date, and priority.
- Study schedule: add study blocks with subject, topic, date/time, and duration, then start a timer from a block.
- Flashcard decks: create decks, add cards, flip cards, and navigate through cards.
- Local persistence via `shared_preferences`; no login or internet connection required.
- Light/dark theme toggle.
- Responsive Material 3 UI using scrollable layouts, adaptive wrapping, safe areas, and flexible rows to reduce overflow risk.
- Assignments, study blocks, and flashcard decks start empty and are created by the user.

## Run in VS Code (Windows)

1. Install Flutter SDK and Android SDK. Install the Flutter and Dart extensions in VS Code.
2. Extract this ZIP and open the `StudyFlow` folder in VS Code.
3. Open Terminal → New Terminal and run:

   ```bash
   flutter doctor
   flutter pub get
   flutter devices
   flutter test
   flutter run
   ```

4. Select your Android emulator (for example `emulator-5554`).

If Flutter says the Android platform is missing or unsupported, run `flutter create .` from the project root, then run `flutter pub get` and `flutter run`. This regenerates platform scaffolding while preserving Dart source files.

## Build a release APK

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Expected APK location: `build/app/outputs/flutter-apk/app-release.apk`.

## Privacy and storage

Assignments, study blocks, flashcards, and theme preference are stored locally on this device. No backend, analytics, ad SDK, or login is included. Clearing app storage or uninstalling may delete your data, so keep your own backups.

## Notes

This is a study organization tool, not a school learning management system. It does not sync across devices or send push notifications.