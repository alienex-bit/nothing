# Project: "Nothing" - Technical Environment Specs

## 1. Core Framework & Language
* **Framework:** Flutter SDK (Current Stable Channel)
* **Language:** Dart 3.x
* **Game Engine:** Flame Engine (v1.18+)
* **Physics Integration:** Forge2D (Flame bridge)

## 2. Development Environment
* **OS:** Windows 10/11
* **IDE:** VS Code or Android Studio
* **Build Tool:** Flutter CLI
* **Scripting Automation:** PowerShell 7.x

## 3. Project Dependencies (`pubspec.yaml`)
* `flame`: Core engine
* `flame_forge2d`: Physics engine
* `shared_preferences`: Local state/save data

## 4. Android Build Configuration
* **Minimum SDK:** API Level 26 (Android 8.0)
* **Target SDK:** API Level 34 (Android 14)
* **Keystore:** Dedicated signing key required for Play Store release
* **Architecture:** arm64-v8a, armeabi-v7a (for broad compatibility)

## 5. Build & Execution Workflow
* **Dependency Management:** `flutter pub get`
* **Compilation:** `flutter build appbundle --release`
* **Environment Management:** PowerShell scripts in `/scripts` directory
