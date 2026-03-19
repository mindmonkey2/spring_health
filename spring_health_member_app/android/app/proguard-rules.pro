# ============================================================
# Spring Health Member App — ProGuard / R8 Rules
# ============================================================

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Fix R8 Missing Play Core Classes ────────────────────────
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

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

# Mobile Scanner
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Lottie (V2 — keeping for future)
-dontwarn com.airbnb.lottie.**
-keep class com.airbnb.lottie.** { *; }

# OkHttp / Retrofit (used by Firebase internally)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**

# General — preserve source info for crash reports
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Prevent stripping of annotations
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
