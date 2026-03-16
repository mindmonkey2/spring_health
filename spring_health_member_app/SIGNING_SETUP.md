# Spring Health — Release Signing Setup

## Generate Keystore (run once, keep the file safe forever)
keytool -genkey -v \
-keystore spring_health_member_app/android/spring-health-release.keystore \
-alias spring-health \
-keyalg RSA \
-keysize 2048 \
-validity 10000

## Create key.properties (never commit this file)
Copy key.properties.template → key.properties
Fill in your actual passwords.

## Build Release APK
```text
cd spring_health_member_app
flutter build apk --release \
--dart-define=RAZORPAY_KEY=rzp_live_YOUR_KEY
```

## Build App Bundle (preferred for Play Store)
```text
cd spring_health_member_app
flutter build appbundle --release \
--dart-define=RAZORPAY_KEY=rzp_live_YOUR_KEY
```

Output: build/app/outputs/bundle/release/app-release.aab