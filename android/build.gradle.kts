allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Some third-party plugins (e.g. blue_thermal_printer, isar_flutter_libs)
// predate AGP's mandatory `namespace` requirement (AGP 7+) and only declare
// their package via the manifest. Patch them in place at configuration time
// rather than forking each plugin. Registered before evaluationDependsOn
// below so the afterEvaluate hook attaches before any subproject evaluates.
subprojects {
    afterEvaluate {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            ?: return@afterEvaluate
        if (android.namespace != null) return@afterEvaluate

        val manifestFile = android.sourceSets.getByName("main").manifest.srcFile
        if (!manifestFile.exists()) return@afterEvaluate

        val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestFile.readText())
        if (packageMatch != null) {
            android.namespace = packageMatch.groupValues[1]
        }
    }
}

// isar_flutter_libs (and potentially other legacy plugins) hardcode an old
// compileSdkVersion (e.g. 30) in their own build.gradle. That's too low to
// resolve framework resources such as android:attr/lStar (added in API 31),
// which breaks release builds at the resource-verification step even though
// debug builds (which skip that step) succeed. Raise any subproject's
// compileSdk to match the app's so resource linking succeeds everywhere.
subprojects {
    afterEvaluate {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            ?: return@afterEvaluate
        val minCompileSdk = 36
        if ((android.compileSdkVersion?.removePrefix("android-")?.toIntOrNull() ?: 0) < minCompileSdk) {
            android.compileSdkVersion("android-$minCompileSdk")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
