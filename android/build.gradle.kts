// android/build.gradle.kts

// No buildscript/classpath needed because plugins are declared in settings.gradle.kts

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Keep Flutter's shared build directory mapping (optional)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    layout.buildDirectory.set(newBuildDir.dir(name))
    // Keep original intent of evaluating :app first
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
