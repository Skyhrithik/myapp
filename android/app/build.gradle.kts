plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter plugin must come after the Android/Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services (for Firebase etc.)
    id("com.google.gms.google-services")
}

android {
    namespace = "in.fps.shop"

    compileSdk = flutter.compileSdkVersion
    // If you pinned NDK earlier, you can keep it; it’s optional:
    // ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "in.fps.shop"
        // flutter.minSdkVersion can be <21 depending on your Flutter version.
        // Make sure we’re at least 21 for flutter_local_notifications:
        minSdk = maxOf(21, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // If you use multidex elsewhere, uncomment:
        // multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // ✅ This fixes your error
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // Use your real signing config for release builds later
            signingConfig = signingConfigs.getByName("debug")
            // If you turned on shrinkResources earlier, keep it paired with minify:
            // isMinifyEnabled = true
            // isShrinkResources = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            // Make sure shrinkResources isn’t on without minify (it will crash the build)
            // isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Required for core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // If you explicitly add other Android deps here, keep them.
    // Usually Flutter plugins bring their own dependencies, so nothing else is required here.
}
