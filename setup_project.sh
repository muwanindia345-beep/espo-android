#!/data/data/com.termux/files/usr/bin/bash
# setup_project.sh — Kreas la tutan Android/Kotlin/Compose projekton por Espo

set -e

echo "📁 Kreante dosierstrukturon..."
mkdir -p app/src/main/java/com/espo/roboto/ui/theme
mkdir -p app/src/main/java/com/espo/roboto/network
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/mipmap-anydpi-v26
mkdir -p .github/workflows

# ============================================================
# settings.gradle.kts
# ============================================================
cat > settings.gradle.kts << 'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "EspoRoboto"
include(":app")
EOF

# ============================================================
# build.gradle.kts (root)
# ============================================================
cat > build.gradle.kts << 'EOF'
plugins {
    id("com.android.application") version "8.7.2" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
}
EOF

# ============================================================
# gradle.properties
# ============================================================
cat > gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

# ============================================================
# app/build.gradle.kts
# ============================================================
cat > app/build.gradle.kts << 'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.espo.roboto"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.espo.roboto"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")

    // Retejaj vokoj al la Flask-backend
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")

    debugImplementation("androidx.compose.ui:ui-tooling")
}
EOF

# ============================================================
# AndroidManifest.xml
# ============================================================
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="Espo"
        android:allowBackup="true"
        android:theme="@style/Theme.Espo">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.Espo">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# ============================================================
# res/values/styles.xml (baza tema por antaŭ ol Compose ŝargiĝas)
# ============================================================
cat > app/src/main/res/values/styles.xml << 'EOF'
<resources>
    <style name="Theme.Espo" parent="android:Theme.Material.Light.NoActionBar">
        <item name="android:windowBackground">#1E1E2F</item>
        <item name="android:statusBarColor">#1E1E2F</item>
    </style>
</resources>
EOF

# ============================================================
# res/values/strings.xml
# ============================================================
cat > app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">Espo</string>
</resources>
EOF

# ============================================================
# Colors.kt — samaj koloroj kiel la retejo
# ============================================================
cat > app/src/main/java/com/espo/roboto/ui/theme/Colors.kt << 'EOF'
package com.espo.roboto.ui.theme

import androidx.compose.ui.graphics.Color

val FonaKoloro = Color(0xFF1E1E2F)
val BabilejoFono = Color(0xFF2A2A3D)
val UzantaVeziko = Color(0xFF4DD0E1)
val RobotaVeziko = Color(0xFF3D3D55)
val TradukoVeziko = Color(0xFF2F4A52)
val TekstoBlanka = Color(0xFFFFFFFF)
val VizaĝoHelaBlua = Color(0xFF4DD0E1)
val VizaĝoProfundaBlua = Color(0xFF34A1C9)
EOF

echo "✅ Baza strukturo kaj Gradle-dosieroj kreitaj."
echo "▶️  Sekva paŝo: MainActivity.kt kaj la reto-tavolo aldoniĝos en la venonta skripto."
