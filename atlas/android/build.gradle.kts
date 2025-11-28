buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }

    dependencies {
        // Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.6.0")

        // Kotlin plugin – must match AGP requirements
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.24")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

// Flutter automatically handles build dirs.
// Do NOT override buildDirectory in Flutter projects.

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
