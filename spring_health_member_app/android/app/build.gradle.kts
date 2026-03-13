plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace   = "com.springhealthtech.spring_health_member"
    compileSdk  = 36
    ndkVersion  = flutter.ndkVersion

    compileOptions {
        sourceCompatibility             = JavaVersion.VERSION_17
        targetCompatibility             = JavaVersion.VERSION_17
        // Required for flutter_local_notifications date/time APIs
        isCoreLibraryDesugaringEnabled  = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId   = "com.springhealthtech.spring_health_member"

        // ✅ FIX: health package (Health Connect) requires minSdk 26
        // Android 8.0 Oreo — covers 97%+ of active Android devices (2026)
        minSdk          = 26

        targetSdk       = 36
        versionCode     = flutter.versionCode
        versionName     = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Replace with your own keystore before Play Store submission
            signingConfig = signingConfigs.getByName("debug")

            // Optional: enable R8 shrinking for smaller APK
            isMinifyEnabled   = false
            isShrinkResources = false
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM — manages all Firebase library versions together
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-analytics")

    // MultiDex — required when method count exceeds 65k (Firebase + Health)
    implementation("androidx.multidex:multidex:2.0.1")

    // Core library desugaring — needed for flutter_local_notifications
    // and any Java 8+ date/time APIs on older Android versions
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
