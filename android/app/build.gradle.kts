plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // nome correto do plugin Kotlin
    id("dev.flutter.flutter-gradle-plugin") // o plugin do Flutter deve vir por último
}

android {
    namespace = "com.example.ihealthy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.ihealthy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        // ✅ Alinhando Java e Kotlin para versão 11
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ✅ Kotlin padrão
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.25")

    // ✅ Necessário por causa do flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
