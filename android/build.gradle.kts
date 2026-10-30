group = "app.parkr.alpr.flutter"
version = "0.4.0"

buildscript {
    val kotlinVersion = "2.4.0"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

// app.parkr:alpr is resolved by the app, so its repository goes on every project.
rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://alpr.parkr.app/maven")
            content { includeGroup("app.parkr") }
        }
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "app.parkr.alpr.flutter"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    implementation("app.parkr:alpr:0.4.0")
}
