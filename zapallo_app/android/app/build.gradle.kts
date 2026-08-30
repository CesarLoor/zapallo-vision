plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.espe.zapalloai.zapallo_app"
    compileSdk = 36  // Android 16 (API 36) para Samsung S25+
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).\
        applicationId = "com.espe.zapalloai.zapallo_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 21)  // tensorflow-lite requires API 21+
        targetSdk = 36  // Android 16 (API 36) para Samsung S25+
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Solo ARM 64-bit: reduce el APK ~50% y acelera el build
        // Samsung S25+, Pixel 6+ y emuladores arm64 son todos 64-bit
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// Resolve namespace conflict between tensorflow-lite and tensorflow-lite-api
// Both libraries declare namespace "org.tensorflow.lite" which is forbidden
// by AGP 8+. We exclude the api artifact since tensorflow-lite already includes it.
configurations.all {
    resolutionStrategy {
        exclude(group = "org.tensorflow", module = "tensorflow-lite-api")
    }
}

flutter {
    source = "../.."
}
