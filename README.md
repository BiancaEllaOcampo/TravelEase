# TravelEase

A Checklist System for Flight and Multi-type Visa Documents with AI-Assisted Verification for Philippine Travel.

## Summary

TravelEase is a mobile application that helps travelers prepare and verify required flight and visa documents using checklists and AI-assisted verification tools. The app is being developed with Flutter and is currently focused on Android as the primary target platform.

## What we're using

- Framework: Flutter (Dart)
- Primary development & testing platform: Android (we are focusing development, testing, and releases for Android devices)
- Secondary: iOS support exists in the project structure but is not the current focus

Languages present in the repository (high level):
- Dart (Flutter)
- C++ / CMake (native/engine code or libraries)
- Swift (iOS helper code)
- HTML and other assets

## Tech stack

- Flutter (Dart) — cross-platform UI toolkit used to build the mobile app
- Android SDK / Android Studio — primary platform tools
- Native code components (C/C++, CMake) where required for platform integration or performance

## Getting started (development)

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Install Android Studio and set up the Android SDK and an Android emulator, or connect an Android device.
3. Clone the repo:
   ```bash
   git clone https://github.com/BiancaEllaOcampo/TravelEase.git
   cd TravelEase
   ```
4. Get dependencies:
   ```bash
   flutter pub get
   ```
5. Run on an Android device or emulator:
   ```bash
   flutter run
   ```
   If you have multiple devices connected, specify the device:
   ```bash
   flutter run -d <device-id>
   ```