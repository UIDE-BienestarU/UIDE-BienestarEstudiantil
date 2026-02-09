import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")

    // ✅ Google Services (Firebase/FCM)
    id("com.google.gms.google-services")

    // Flutter (debe ir después de Android/Kotlin)
    id("dev.flutter.flutter-gradle-plugin")
}

// 🔐 Carga de key.properties (si existe)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "ec.miempresa.miapp.uidebienestar"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // (Recomendado: evita problemas con varias libs modernas)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "ec.miempresa.miapp.uidebienestar"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Firma RELEASE desde key.properties
    signingConfigs {
        // Solo crear release si existe key.properties
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storePassword = keystoreProperties["storePassword"] as String

                // key.properties trae storeFile=upload-keystore.jks (solo el nombre)
                storeFile = file(keystoreProperties["storeFile"] as String)
            }
        }
    }

    buildTypes {
        release {
            // ✅ IMPORTANTE: ya no usar debug
            // Si no existe key.properties, evita romper el build.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // Opcional: (puedes activarlo después)
            // isMinifyEnabled = true
            // isShrinkResources = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }
}

dependencies {
    // Requerido si habilitas desugaring arriba
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
