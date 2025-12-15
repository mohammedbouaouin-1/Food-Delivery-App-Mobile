plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // ← AJOUTÉ
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.food_delivery_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.food_delivery_app"
        minSdk = flutter.minSdkVersion  // ← Changé (Firebase nécessite min 21)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // ← AJOUTÉ
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))  // ← AJOUTÉ
    implementation("com.google.firebase:firebase-analytics")  // ← AJOUTÉ
}
