# spring_health_member

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

### Firebase Configuration

For security reasons, Firebase configuration values are not hardcoded in the repository. Instead, they are provided at build time using environment variables via `--dart-define` or `--dart-define-from-file`.

You can create a `firebase_config.json` file (which should be added to your `.gitignore`) with the following structure:

```json
{
  "FIREBASE_API_KEY_ANDROID": "your-android-api-key",
  "FIREBASE_APP_ID_ANDROID": "your-android-app-id",
  "FIREBASE_MESSAGING_SENDER_ID_ANDROID": "your-android-sender-id",
  "FIREBASE_PROJECT_ID_ANDROID": "your-project-id",
  "FIREBASE_STORAGE_BUCKET_ANDROID": "your-storage-bucket",

  "FIREBASE_API_KEY_IOS": "your-ios-api-key",
  "FIREBASE_APP_ID_IOS": "your-ios-app-id",
  "FIREBASE_MESSAGING_SENDER_ID_IOS": "your-ios-sender-id",
  "FIREBASE_PROJECT_ID_IOS": "your-project-id",
  "FIREBASE_STORAGE_BUCKET_IOS": "your-storage-bucket",
  "FIREBASE_IOS_BUNDLE_ID": "your-ios-bundle-id",

  "FIREBASE_API_KEY_WEB": "your-web-api-key",
  "FIREBASE_APP_ID_WEB": "your-web-app-id",
  "FIREBASE_MESSAGING_SENDER_ID_WEB": "your-web-sender-id",
  "FIREBASE_PROJECT_ID_WEB": "your-project-id",
  "FIREBASE_AUTH_DOMAIN_WEB": "your-auth-domain",
  "FIREBASE_STORAGE_BUCKET_WEB": "your-storage-bucket",
  "FIREBASE_MEASUREMENT_ID_WEB": "your-measurement-id"
}
```

Then run or build the app using:

```bash
flutter run --dart-define-from-file=firebase_config.json
```

## Resources

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
