import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningPropertiesFile = rootProject.file("key.properties")
val releaseSigningProperties = Properties()
if (releaseSigningPropertiesFile.isFile) {
    releaseSigningPropertiesFile.inputStream().use(releaseSigningProperties::load)
}

val requiredSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val missingSigningKeys =
    requiredSigningKeys.filter { releaseSigningProperties.getProperty(it).isNullOrBlank() }
val hasReleaseSigning = releaseSigningPropertiesFile.isFile && missingSigningKeys.isEmpty()

if (releaseSigningPropertiesFile.isFile && missingSigningKeys.isNotEmpty()) {
    throw GradleException(
        "android/key.properties is incomplete. Missing: ${missingSigningKeys.joinToString()}",
    )
}

android {
    namespace = "com.hyu.properotyTycoon"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    androidResources {
        // Godot project packs may contain hidden import metadata.
        ignoreAssetsPattern =
            "!.svn:!.git:!.gitignore:!.ds_store:!*.scc:<dir>_*:!CVS:!thumbs.db:!picasa.ini:!*~"
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hyu.properotyTycoon"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = rootProject.file(releaseSigningProperties.getProperty("storeFile"))
                storePassword = releaseSigningProperties.getProperty("storePassword")
                keyAlias = releaseSigningProperties.getProperty("keyAlias")
                keyPassword = releaseSigningProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Never publish with the debug key. Without key.properties Gradle
            // deliberately produces an unsigned local artifact.
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("org.godotengine:godot:4.7.1.stable")
    implementation("androidx.fragment:fragment-ktx:1.8.9")
    testImplementation("junit:junit:4.13.2")
}

if (!hasReleaseSigning) {
    tasks.matching { it.name == "assembleRelease" || it.name == "bundleRelease" }.configureEach {
        doFirst {
            logger.warn(
                "Release signing is not configured; this artifact is unsigned and cannot be " +
                    "distributed. Copy android/key.properties.example to android/key.properties " +
                    "and provide an upload key for distributable builds.",
            )
        }
    }
}
