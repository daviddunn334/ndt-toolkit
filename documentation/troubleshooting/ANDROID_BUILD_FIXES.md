# Android Build Fixes

Common Android build issues and their solutions for the NDT Toolkit app.

## 🎯 Overview

This guide covers common Android build problems and proven solutions. Most issues relate to Java version compatibility, Gradle configuration, or dependency conflicts.

---

## ⚠️ Java Version Issues

### Issue: Unsupported Class File Major Version

**Error Message:**
```
Unsupported class file major version 68
```
or
```
Android Gradle plugin requires Java 17 to run. You are currently using Java 24.
```

**Root Cause:** Java 24 is too new and unstable for Android development. Flutter/Android requires Java 17 LTS.

**Solution:**

1. **Install Java 17 LTS**
   - Download: [Oracle JDK 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
   - Install to: `C:\Program Files\Java\jdk-17`

2. **Set JAVA_HOME Environment Variable**
   ```powershell
   # PowerShell (as Administrator)
   [System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Java\jdk-17', [System.EnvironmentVariableTarget]::Machine)
   ```

3. **Configure Gradle to Force Java 17**
   
   Edit `android/gradle.properties`, add:
   ```properties
   org.gradle.java.home=C:\\Program Files\\Java\\jdk-17
   ```

4. **Verify Configuration**
   ```bash
   cd android
   .\gradlew -version
   ```
   
   Should show:
   ```
   Launcher JVM: 17.0.12
   Daemon JVM: 'C:\Program Files\Java\jdk-17' (from org.gradle.java.home)
   ```

5. **Clean and Rebuild**
   ```bash
   .\gradlew clean
   .\gradlew --stop
   cd ..
   flutter clean
   flutter pub get
   flutter run
   ```

**Why This Works:** The `org.gradle.java.home` property forces Gradle to use a specific Java version regardless of system PATH or JAVA_HOME.

---

## 🔧 Gradle Build Failures

### Issue: Gradle Daemon Connection Failed

**Error Message:**
```
Could not connect to the Gradle daemon.
```

**Solution:**

1. **Stop All Gradle Daemons**
   ```bash
   cd android
   .\gradlew --stop
   ```

2. **Clear Gradle Caches**
   ```bash
   Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches
   ```

3. **Rebuild**
   ```bash
   cd ..
   flutter clean
   flutter pub get
   flutter run
   ```

### Issue: Gradle Build Times Out

**Error Message:**
```
Gradle build daemon disappeared unexpectedly
```

**Solution:**

Edit `android/gradle.properties`, add or increase:
```properties
org.gradle.daemon=true
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
org.gradle.parallel=true
org.gradle.caching=true
```

---

## 📦 Dependency Conflicts

### Issue: Duplicate Class Found

**Error Message:**
```
Duplicate class [classname] found in modules
```

**Solution:**

1. **Check for Conflicting Dependencies**
   ```bash
   cd android
   .\gradlew app:dependencies
   ```

2. **Exclude Duplicates in** `android/app/build.gradle`:
   ```gradle
   dependencies {
       implementation('some.library') {
           exclude group: 'duplicate.group', module: 'duplicate-module'
       }
   }
   ```

3. **Force Specific Version**
   ```gradle
   configurations.all {
       resolutionStrategy {
           force 'com.google.android.gms:play-services-basement:18.1.0'
       }
   }
   ```

### Issue: Version Conflict

**Error Message:**
```
Conflict with dependency 'com.google.android.gms:...'
```

**Solution:**

Update versions in `android/app/build.gradle` to match:
```gradle
implementation platform('com.google.firebase:firebase-bom:32.7.0')
implementation 'com.google.firebase:firebase-analytics'
implementation 'com.google.firebase:firebase-auth'
// All Firebase dependencies will use BOM version
```

---

## 🧹 Nuclear Option: Complete Clean

When all else fails, perform a complete clean:

### Windows PowerShell

```powershell
# Stop all Gradle processes
cd android
.\gradlew --stop
cd ..

# Delete all build artifacts
flutter clean
Remove-Item -Recurse -Force android\.gradle -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\app\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue

# Clear Gradle caches
Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches -ErrorAction SilentlyContinue

# Rebuild everything
flutter pub get
flutter pub upgrade
cd android
.\gradlew clean
cd ..
flutter run
```

---

## 🔐 Signing Issues

### Issue: Key Store Not Found

**Error Message:**
```
KeyStore file not found
```

**Solution:**

1. **Check** `android/key.properties` exists and paths are correct
2. **Verify key store file exists** at specified location
3. **Use absolute paths** in `key.properties`

Example `android/key.properties`:
```properties
storePassword=your-password
keyPassword=your-password
keyAlias=ndt-toolkit
storeFile=C:/Users/youruser/keys/ndt-toolkit-key.jks
```

---

## 📱 Multidex Issues

### Issue: Cannot Fit Requested Classes

**Error Message:**
```
Cannot fit requested classes in a single dex file
```

**Solution:**

Enable multidex in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Must be 21 or higher
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

---

## 🏗️ Build Tool Version Issues

### Issue: AGP/Gradle Version Mismatch

**Error Message:**
```
This version of Android Gradle plugin requires Gradle X.X
```

**Solution:**

Use this stable version combination:

**`android/build.gradle`:**
```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    dependencies {
        classpath 'com.android.tools.build:gradle:8.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

**`android/gradle/wrapper/gradle-wrapper.properties`:**
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.10-all.zip
```

---

## ⚡ Performance Issues

### Issue: Build Takes Too Long

**Solutions:**

1. **Enable Gradle Caching**
   
   Add to `android/gradle.properties`:
   ```properties
   org.gradle.caching=true
   org.gradle.parallel=true
   ```

2. **Increase Gradle Heap Size**
   ```properties
   org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m
   ```

3. **Use Local Maven Cache**
   ```properties
   android.enableJetifier=true
   android.useAndroidX=true
   ```

---

## 🆘 Android Studio Issues

### Issue: IDE Not Recognizing Gradle Project

**Solution:**

1. **File → Invalidate Caches / Restart**
2. **File → Sync Project with Gradle Files**
3. **Set Gradle JDK**:
   - **File → Settings → Build → Gradle**
   - Set **Gradle JDK** to Java 17
   - Click **Apply**

### Issue: "SDK Location Not Found"

**Solution:**

Create `android/local.properties`:
```properties
sdk.dir=C\:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk
```

Replace path with your actual Android SDK location.

---

## 📝 Common Warnings (Safe to Ignore)

### file_picker Platform Warnings

```
Warning: The plugin `file_picker` requires the following:
- file_picker_linux
- file_picker_macos
- file_picker_windows
```

**These warnings are safe to ignore** - they're from the package supporting multiple platforms.

### Deprecated API Warnings

```
warning: [deprecation] SomeClass in package is deprecated
```

**Usually safe to ignore** unless causing build failures. These come from dependencies and will be fixed in future versions.

---

## 🔍 Diagnostic Commands

### Check Java Version
```bash
java -version
javac -version
```

### Check Gradle Version
```bash
cd android
.\gradlew -version
```

### List Gradle Tasks
```bash
.\gradlew tasks
```

### View Dependencies
```bash
.\gradlew app:dependencies
```

### Flutter Doctor
```bash
flutter doctor -v
```

### Clear Flutter Cache
```bash
flutter clean
flutter pub cache repair
```

---

## 📚 Related Documentation

- [Build Configuration Guide](../guides/BUILD_CONFIGURATION.md)
- [Common Issues](./COMMON_ISSUES.md)
- [Firebase Setup](../setup/FIREBASE_SETUP.md)

---

## 🆘 Still Having Issues?

1. Check Flutter version: `flutter --version`
2. Update Flutter: `flutter upgrade`
3. Check Flutter doctor: `flutter doctor -v`
4. Review full error logs
5. Search Flutter GitHub issues
6. Check Stack Overflow

---

**Last Updated:** February 19, 2026
