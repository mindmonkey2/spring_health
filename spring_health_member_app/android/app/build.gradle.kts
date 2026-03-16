plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace   = "com.springhealthtech.spring_health_member"
    compileSdk  = 36
    ndkVersion  = flutter.ndkVersion

    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
            }
        }
    }

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
        applicationId   = "com.springhealth.member"

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
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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
