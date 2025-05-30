plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sales_nsm"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Membuat kompatibilitas dengan Java 17
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // Enable desugaring untuk Java 8
    defaultConfig {
        applicationId = "com.example.sales_nsm"
        minSdk = 21
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // Jika perlu untuk aplikasi besar
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Enable desugaring library (untuk Java 8+ fitur)
    dexOptions {
        javaMaxHeapSize = "4g"
    }
}

flutter {
    source = "../.."
}