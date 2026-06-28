ga android/app/build.gradle.ktsplugins { 
    id("com.android.application") 
    id("kotlin-android") 
    id("dev.flutter.flutter-gradle-plugin") 
    id("com.google.gms.google-services")
g commit -m "fix(android): AGP 9.0 limpio"}
gp
android {
    namespace = "com.leloms_app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.leloms_app"
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
