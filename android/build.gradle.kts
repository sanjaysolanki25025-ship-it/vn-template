allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://artifact.bytedance.com/repository/pangle/") }
        maven { url = uri("https://android-sdk.is.com/") }
    }

    val nextGenDef = "VVNFX05FWFRfR0VOX1NESz10cnVl"
    if (project.hasProperty("dart-defines")) {
        val current = project.property("dart-defines")?.toString() ?: ""
        if (!current.contains("USE_NEXT_GEN_SDK") && !current.contains(nextGenDef)) {
            val updated = if (current.isEmpty()) nextGenDef else "$current,$nextGenDef"
            project.extensions.extraProperties.set("dart-defines", updated)
        }
    } else {
        project.extensions.extraProperties.set("dart-defines", nextGenDef)
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
