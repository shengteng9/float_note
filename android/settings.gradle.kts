pluginManagement {
    val flutterSdkPath = file("local.properties").readText().let {
        Regex("flutter\\.sdk=(.+)").find(it)?.groupValues?.get(1)
            ?: throw GradleException("flutter.sdk not found in local.properties")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // 优先使用国内镜像
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    resolutionStrategy {
        eachPlugin {
            when (requested.id.id) {
                "com.android.application" ->
                    // 使用与 Gradle 8.6 兼容的 Android Gradle 插件版本
                    useModule("com.android.tools.build:gradle:8.4.0") // 或 8.2.2
                "dev.flutter.flutter-gradle-plugin" ->
                    useModule("dev.flutter:flutter-gradle-plugin:3.0.0")
                "org.jetbrains.kotlin.android" ->
                    // 确保 Kotlin 版本与 Android Gradle 插件兼容
                    useModule("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.4.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

include(":app")