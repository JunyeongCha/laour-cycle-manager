// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    // Google 서비스 Gradle 플러그인을 추가합니다.
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vokdo.laour" // 이전에 수정한 우리 앱의 고유 ID
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
        applicationId = "com.vokdo.laour" // 이전에 수정한 우리 앱의 고유 ID
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
    // 이 부분이 가장 중요합니다.
    // Firebase BoM(Bill of Materials)을 가져옵니다.
    // BoM을 사용하면 여러 Firebase 라이브러리 버전을 알아서 맞춰줍니다.
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))

    // 사용할 Firebase 제품에 대한 종속성을 추가합니다.
    // BoM을 사용할 때는 버전을 명시하지 않습니다.
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-messaging")
}