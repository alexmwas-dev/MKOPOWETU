import java.util.Properties

plugins {
        id("com.android.application")
            // START: FlutterFire Configuration
                id("com.google.gms.google-services")
                    // END: FlutterFire Configuration
                        id("kotlin-android")
                            id("dev.flutter.flutter-gradle-plugin") // Flutter must be applied last
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
        keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

android {
        namespace = "com.mkopowetu.ke"
            compileSdk = 36 // ✅ Safe target (36 not fully stable yet)

                ndkVersion = flutter.ndkVersion

                    compileOptions {
                                sourceCompatibility = JavaVersion.VERSION_11
                                        targetCompatibility = JavaVersion.VERSION_11
                    }

                        kotlinOptions {
                                    jvmTarget = "11"
                        }

                            signingConfigs {
                                        create("release") {
                                                        if (keyPropertiesFile.exists()) {
                                                                            keyAlias = keyProperties["keyAlias"] as String
                                                                                            keyPassword = keyProperties["keyPassword"] as String
                                                                                                            storeFile = file(keyProperties["storeFile"] as String)
                                                                                                                            storePassword = keyProperties["storePassword"] as String
                                                        }
                                        }
                            }

                                defaultConfig {
                                            applicationId = "com.mkopowetu.ke"
                                                    minSdk = flutter.minSdkVersion // ✅ Android 5+
                                                            targetSdk = 34
                                                                    versionCode = flutter.versionCode
                                                                            versionName = flutter.versionName
                                                                                    multiDexEnabled = true // ✅ Prevent method count issues on older devices
                                }

                                    buildTypes {
                                                release {
                                                                signingConfig = signingConfigs.getByName("release")
                                                                            isShrinkResources = false
                                                                                        isMinifyEnabled = false
                                                                                                    // ✅ Enable these later if you want code shrinking/obfuscation:
                                                                                                                // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
                                                }
                                                        debug {
                                                                        signingConfig = signingConfigs.getByName("release") // Optional: sign debug with release key
                                                        }
                                    }
}

flutter {
        source = "../.."
}
