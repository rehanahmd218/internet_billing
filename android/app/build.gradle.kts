import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

//--- ADD THIS BLOCK--
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
//--- END ADDITION---

android {
    namespace = "com.example.internet_billing"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.wifi.easynetbilling"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
    create("release") {
        storeFile = file(
            keystoreProperties["storeFile"]?.toString()
                ?: throw GradleException("storeFile missing in key.properties")
        )
        storePassword =
            keystoreProperties["storePassword"]?.toString()
                ?: throw GradleException("storePassword missing")
        keyAlias =
            keystoreProperties["keyAlias"]?.toString()
                ?: throw GradleException("keyAlias missing")
        keyPassword =
            keystoreProperties["keyPassword"]?.toString()
                ?: throw GradleException("keyPassword missing")
    }
}

//--- END ADDITION--
buildTypes {
release {
//--- REPLACE "debug" WITH "release"--
signingConfig = signingConfigs.getByName("release")
}
}
}

flutter {
    source = "../.."
}
