# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Razorpay
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** { *; }
-optimizationpasses 5
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# QR / ZXing
-keep class com.journeyapps.** { *; }
-keep class com.google.zxing.** { *; }

# Lottie (V2 — keeping for future)
-dontwarn com.airbnb.lottie.**
-keep class com.airbnb.lottie.** { *; }

# General
-keepattributes SourceFile,LineNumberTable
-dontwarn okhttp3.**
-dontwarn okio.**