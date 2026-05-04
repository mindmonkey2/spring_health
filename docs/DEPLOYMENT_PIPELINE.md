# Spring Health — Deployment Pipeline

This document covers the complete CI/CD pipeline for both Flutter apps in this monorepo: `spring_health_member_app` and `spring_health_studio`.

---

## Overview

| Phase | What it does | Status | Trigger |
|-------|-------------|--------|---------|
| 1 — Quality Gate | Analyze + unit tests | ✅ Live | Every PR and push to `main` |
| 2 — Web Previews | Firebase Hosting preview channels | ✅ Live | Every PR and push to `main` |
| 3 — Android Distribution | Signed APK → Firebase App Distribution | ✅ Live | Every push to `main` |
| 4 — Google Play Store | Production Android release | 🔜 Planned | Manual / tag-based |
| 5 — iOS TestFlight | iPhone beta testing | 🔜 Planned | Every push to `main` |

---

## Firebase Projects

| Project ID | Used by | URL |
|-----------|---------|-----|
| `springhealth-d00aa` | Member app (Android + Web) | `springhealth-d00aa.web.app` |
| `springhealth-d00aa` | Studio app (Web, secondary site) | `springhealth-studio.web.app` |

---

## Phase 1 — Quality Gate (CI)

**Workflow file:** `.github/workflows/ci.yml`

Runs on every pull request and every push to `main`. Both jobs run in parallel.

### Member App job
```
flutter pub get
flutter analyze          # Zero issues required
flutter test test/models test/services
```

`benchmark_test.dart` is intentionally excluded — it contains a timing assertion (`batchedTime < nPlus1Time`) that produces false failures on fast CI runners.

### Studio App job
```
flutter pub get
flutter analyze          # Zero issues required
flutter test             # All 4 tests are deterministic
```

### Pub cache
Packages are cached keyed on `pubspec.lock` so `flutter pub get` is a cache hit on unchanged dependencies.

### Concurrency
Stale runs on the same branch are cancelled automatically when a new commit arrives — keeps the queue clean on fast-moving PRs.

---

## Phase 2 — Web Preview Channels

**Workflow file:** `.github/workflows/preview.yml`

Builds both apps for web and deploys to Firebase Hosting.

### On a pull request
- Member app → unique preview URL, e.g. `member-app--pr42-abc123--springhealth-d00aa.web.app`
- Studio app → unique preview URL, e.g. `springhealth-studio--pr42-abc123.web.app`
- GitHub Action posts both URLs as a comment on the PR automatically

### On merge to `main`
- Member app → `https://springhealth-d00aa.web.app` (live)
- Studio app → `https://springhealth-studio.web.app` (live)

### Firebase setup (already done)
- Default hosting site: `springhealth-d00aa` (member app)
- Secondary hosting site: `springhealth-studio` (studio app)
- Service account: `github-actions-deploy@springhealth-d00aa.iam.gserviceaccount.com`
- Roles: `roles/firebasehosting.admin`

### GitHub secret required
| Secret | Value |
|--------|-------|
| `FIREBASE_SERVICE_ACCOUNT_SPRINGHEALTH` | Service account JSON key (stored) |

---

## Phase 3 — Android APK Distribution

**Workflow file:** `.github/workflows/distribute.yml`

Runs on every push to `main`. Builds a signed release APK for the member app and uploads it to Firebase App Distribution. Testers receive an email with a direct install link.

### Build steps
1. Decode `ANDROID_KEYSTORE_BASE64` secret → write `spring-health-release.jks`
2. Write `android/key.properties` from signing secrets
3. `flutter build apk --release`
4. Upload to Firebase App Distribution via `wzieba/Firebase-Distribution-Github-Action@v1`
5. Delete keystore and `key.properties` (cleanup always runs even on failure)

### Tester group
| Group | Members |
|-------|---------|
| `testers` | `chiluka.sridher@gmail.com` |

To add more testers: Firebase Console → `springhealth-d00aa` → App Distribution → Groups → testers → Add testers.

### Android signing
The keystore is generated with:
- **Alias:** `spring-health-key`
- **Validity:** 10,000 days
- **Algorithm:** RSA 2048

The keystore is stored exclusively as a GitHub secret (`ANDROID_KEYSTORE_BASE64`). It is never written to disk in CI except during the build step, and is deleted immediately after.

### GitHub secrets required
| Secret | Purpose |
|--------|---------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded release keystore |
| `ANDROID_KEY_ALIAS` | Key alias within the keystore |
| `ANDROID_KEY_PASSWORD` | Password for the key |
| `ANDROID_STORE_PASSWORD` | Password for the keystore |
| `FIREBASE_APP_ID_MEMBER_ANDROID` | Firebase app ID for the Android app |

### Firebase setup (already done)
- App Distribution enabled on `springhealth-d00aa`
- `testers` group created
- Service account granted `roles/firebaseappdistro.admin`

---

## Phase 4 — Google Play Store (Planned)

Production Android release. Prerequisites before starting:

- [ ] Google Play Developer account ($25 one-time fee at play.google.com/console)
- [ ] App created in Play Console with package name `com.springhealth.member`
- [ ] Privacy policy URL
- [ ] Store listing assets (screenshots, feature graphic, description)

### Planned workflow
1. Build release AAB (`flutter build appbundle --release`) — Play Store requires AAB not APK
2. Sign with the same keystore used in Phase 3
3. Upload via `r0adkll/upload-google-play` GitHub Action using a Play Store service account JSON
4. Target track: `internal` → `alpha` → `production`

> **Important:** The keystore used to sign the app must never change after the first Play Store submission. The existing keystore stored in `ANDROID_KEYSTORE_BASE64` should be used for Play Store submission too.

---

## Phase 5 — iOS TestFlight (Planned)

Beta distribution to iPhone via Apple TestFlight. Prerequisites before starting:

- [ ] **Apple Developer Program membership** — $99/year at developer.apple.com/programs/enroll (takes 24–48 hours for Apple approval)
- [ ] Bundle ID registered: `com.springhealthtech.springHealthMember`
- [ ] App record created in App Store Connect

### How to enroll
1. Go to `developer.apple.com/programs/enroll`
2. Sign in with your Apple ID
3. Choose **Individual / Sole Proprietor** (or Entity if registering as a business)
4. Pay the $99/year fee
5. Wait for Apple approval email (typically 24–48 hours)

### Planned workflow once enrolled
```
# On every push to main:
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
# Upload IPA to TestFlight via App Store Connect API
```

Uses `apple-actions/upload-testflight-build` or Fastlane `pilot` on a `macos-latest` GitHub Actions runner.

### Secrets that will be needed
| Secret | How to get it |
|--------|--------------|
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect → Users → Keys |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Same page as above |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Download `.p8` file, base64 encode it |
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Keychain → export Distribution cert as `.p12` |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Password set when exporting `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Download from Apple Developer portal |

---

## Service Account Summary

**Service account:** `github-actions-deploy@springhealth-d00aa.iam.gserviceaccount.com`

| Role | Purpose |
|------|---------|
| `roles/firebasehosting.admin` | Deploy to Hosting (Phase 2) |
| `roles/firebaseappdistro.admin` | Upload APKs to App Distribution (Phase 3) |

---

## GitHub Secrets Summary

| Secret | Used by |
|--------|---------|
| `FIREBASE_SERVICE_ACCOUNT_SPRINGHEALTH` | preview.yml, distribute.yml |
| `ANDROID_KEYSTORE_BASE64` | distribute.yml |
| `ANDROID_KEY_ALIAS` | distribute.yml |
| `ANDROID_KEY_PASSWORD` | distribute.yml |
| `ANDROID_STORE_PASSWORD` | distribute.yml |
| `FIREBASE_APP_ID_MEMBER_ANDROID` | distribute.yml |

All secrets are stored in **GitHub → repo Settings → Secrets and variables → Actions**.

---

## Adding a Tester (App Distribution)

To add someone to the Android tester group without touching code:

1. Firebase Console → `springhealth-d00aa` → **App Distribution**
2. Click **Testers & Groups** → `testers`
3. Click **Add testers** → enter email address
4. They receive an invite email with installation instructions

---

## Workflow Dependency Map

```
Pull Request opened / commit pushed
│
├─► ci.yml          (analyze + test — both apps, parallel)
│
├─► preview.yml     (web build + Firebase Hosting preview — both apps)
│
Merge to main
│
├─► ci.yml          (same quality gate)
├─► preview.yml     (deploy to live channels)
└─► distribute.yml  (build signed APK + Firebase App Distribution)
```
