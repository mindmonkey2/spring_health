# Local Setup Guide: Spring Health Ecosystem

This document provides comprehensive instructions to set up and run the Spring Health Studio (Admin) and Spring Health Member (Client) applications locally.

## 1. Prerequisites

Ensure your development environment meets the following requirements:

### A. Flutter & Dart
- **Flutter SDK:** Stable version 3.29.x is recommended.
  - *Member App Requirement:* `^3.10.4`
  - *Studio App Requirement:* `>=3.2.0 <4.0.0`
- Check your version: `flutter --version`

### B. Java Development Kit (JDK)
- **Required:** Java 17 or higher (essential for Gradle 8.11+).
- Set `JAVA_HOME` to point to your JDK 17 installation.

### C. Node.js (For Cloud Functions)
- **Required:** Node.js v24 (as specified in `functions/package.json`).
- Check your version: `node -v`

### D. Firebase CLI
- Install via npm: `npm install -g firebase-tools`
- Authenticate: `firebase login`

---

## 2. Infrastructure & Toolchain
The project uses a specific build toolchain. **Do not downgrade these versions.**
- **Android Gradle Plugin (AGP):** 8.9.1
- **Gradle:** 8.11.1
- **Kotlin:** 2.1.0
- **Compile SDK / Target SDK:** 36
- **Min SDK:** 26 (Member App — required by Health Connect)

---

## 3. Firebase Backend Configuration

The ecosystem shares a single Firebase project.

1. **Select Firebase Project:**
   In the root directory, link your local environment to your Firebase project:
   ```bash
   firebase use spring-health-studio-f4930
   ```
   > Run this from within each app directory (`spring_health_member_app/` and `spring_health_studio/`) as each has its own `firebase.json`.

2. **Deploy Rules and Indexes:**
   Ensure the database is ready by deploying security rules and Firestore indexes:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage:rules
   ```

3. **Google Services Files:**
   The repository includes template `google-services.json` files for Android. For iOS, you must download `GoogleService-Info.plist` from your Firebase Console and place it in:
   - `spring_health_member_app/ios/Runner/`
   - `spring_health_studio/ios/Runner/`

---

## 4. Running the Applications

The repository is a monorepo. Each app must be initialized independently.

### A. Spring Health Studio (Admin App)
*Used by Owners, Receptionists, and Trainers for management.*

1. **Navigate:** `cd spring_health_studio`
2. **Dependencies:** `flutter pub get`
3. **Run:** `flutter run`
4. **Auth:** Uses Email/Password.

### B. Spring Health Member App (Client App)
*Used by gym members for fitness tracking and AI coaching.*

1. **Navigate:** `cd spring_health_member_app`
2. **Dependencies:** `flutter pub get`
3. **Run:** `flutter run`
   - For payment features, supply the Razorpay key: `flutter run --dart-define=RAZORPAY_KEY=rzp_test_YOUR_KEY`
4. **Auth:** Uses Phone OTP.
5. **Permissions:** Requires Health Connect permissions on Android.
6. **Release builds** (Android): Copy `android/key.properties.template` → `android/key.properties` and fill in your keystore passwords before running `flutter build apk --release`.

---

## 5. Cloud Functions (Optional)

Each app has its own Cloud Functions under `<app-dir>/functions/`. Run these commands from within the app directory you want to work on.

**Member App functions:**
```bash
cd spring_health_member_app/functions
npm install
firebase emulators:start --only functions
```

**Studio App functions:**
```bash
cd spring_health_studio/functions
npm install
firebase emulators:start --only functions
```

> Note: The root-level `functions/` directory is a separate webhook handler and is not part of either Flutter app's Firebase functions.

---

## 6. Troubleshooting

- **AGP/Gradle Mismatch:** Ensure `JAVA_HOME` points to Java 17+. AGP 8.9.x will fail with older Java versions.
- **Dependency Conflicts:** If you encounter issues after updating packages, run `flutter clean` and `flutter pub get` in the respective app directory.
- **Health Connect (Android):** The Member App requires the Health Connect app to be installed and configured on the physical device or emulator.
- **PDF Rendering:** If currency symbols (₹) do not render in the Studio App reports, ensure the device has internet access to fetch `PdfGoogleFonts` (Roboto).

---

## 7. Development Guidelines

When contributing code, adhere to these strict invariants:
- **Linting:** Must pass `flutter analyze` with 0 errors/warnings.
- **Logging:** Use `debugPrint()`, never `print()`.
- **Transactions:** Use Firestore `WriteBatch` or `Transaction` for multi-document updates.
- **State:** Isolate high-frequency updates using `ValueNotifier` to prevent animation flickering.
