# Build Configuration Guide

Complete guide for configuring and building the NDT Toolkit app for all platforms.

## 🎯 Overview

NDT Toolkit is built with Flutter and targets three platforms:
- **Web** - Primary deployment platform (Firebase Hosting)
- **Android** - Mobile app (Google Play Store ready)
- **iOS** - Mobile app (App Store ready)

---

## 🔧 Environment Setup

### Prerequisites

- **Flutter SDK:** 3.24.3 or later
- **Dart SDK:** Included with Flutter
- **Node.js:** 18.x or later (for Firebase Functions)
- **Firebase CLI:** `npm install -g firebase-tools`
- **Git:** For version control

### Platform-Specific Requirements

#### For Android Development
- **Java:** JDK 17 LTS (Required)
  - Download: [Oracle JDK 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
  - Installation path: `C:\Program Files\Java\jdk-17`
- **Android Studio:** Latest stable version
- **Android SDK:** API Level 33 or higher

#### For iOS Development (macOS only)
- **Xcode:** Latest stable version
- **CocoaPods:** `sudo gem install cocoapods`
- **Apple Developer Account:** For deployment

---

## ⚙️ Java Configuration (Android)

### Why Java 17?

**Java 17 LTS** is the recommended version for Flutter/Android development. Newer versions (like Java 24) may have compatibility issues with Android Gradle Plugin.

### Setting Up Java 17

1. **Install Java 17 LTS**
   - Download from Oracle or Adoptium
   - Install to: `C:\Program Files\Java\jdk-17`

2. **Set JAVA_HOME Environment Variable**

   ```powershell
   # Windows PowerShell (as Administrator)
   [System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Java\jdk-17', [System.EnvironmentVariableTarget]::Machine)
   ```

3. **Configure Gradle to Use Java 17**

   Edit `android/gradle.properties`:
   
   ```properties
   org.gradle.java.home=C:\\Program Files\\Java\\jdk-17
   ```

4. **Verify Configuration**

   ```bash
   cd android
   ./gradlew -version
   ```

   Should show:
   ```
   Launcher JVM: 17.0.12
   Daemon JVM: 'C:\Program Files\Java\jdk-17'
   ```

---

## 🏗️ Build Tool Versions

### Stable Version Combination (Battle-Tested)

In `android/build.gradle`:

```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    
    dependencies {
        classpath 'com.android.tools.build:gradle:8.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.1'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
    }
}
```

In `android/gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.10-all.zip
```

### Version Compatibility Matrix

| Component | Version | Notes |
|-----------|---------|-------|
| Gradle | 8.10 | Stable with AGP 8.3.0 |
| Android Gradle Plugin | 8.3.0 | Latest stable |
| Kotlin | 1.9.10 | Compatible with Flutter |
| Google Services | 4.4.1 | Firebase integration |
| Crashlytics Gradle | 2.9.9 | Latest stable |
| Java | 17 LTS | Required for Gradle 8.x |

---

## 🚀 Building the App

### Web Build

```bash
# Development build
flutter build web

# Production build (optimized)
flutter build web --release

# Build with specific base href (for subdirectory hosting)
flutter build web --release --base-href /app/

# Output location
# build/web/
```

### Android Build

#### Debug APK
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

#### Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Build

```bash
# Build for device
flutter build ios --release

# Build for simulator
flutter build ios --debug --simulator

# Create IPA for distribution
flutter build ipa --release
# Output: build/ios/ipa/*.ipa
```

---

## 🧹 Clean Build

If you encounter build issues, perform a clean build:

```bash
# Clean Flutter build cache
flutter clean

# Clean Android build cache (Windows)
cd android
.\gradlew clean
cd ..

# Clean all caches (nuclear option)
flutter clean
Remove-Item -Recurse -Force android\.gradle
Remove-Item -Recurse -Force android\build
Remove-Item -Recurse -Force android\app\build
Remove-Item -Recurse -Force build

# Rebuild
flutter pub get
flutter build web --release
```

---

## 🔧 Configuration Files

### Version Management

Update version in `pubspec.yaml`:

```yaml
version: 1.0.0+1
#        │ │ │  └─ Build number (increment every build)
#        │ │ └──── Patch version (bug fixes)
#        │ └────── Minor version (new features)
#        └──────── Major version (breaking changes)
```

**Important:** Always increment version before deployment!

### Firebase Configuration

#### Web Configuration

`web/index.html` contains Firebase config:

```javascript
const firebaseConfig = {
  apiKey: "...",
  authDomain: "...",
  projectId: "ndt-toolkit",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "...",
  measurementId: "..."
};
```

#### Android Configuration

Located at: `android/app/google-services.json`

#### iOS Configuration

Located at: `ios/Runner/GoogleService-Info.plist`

---

## 📦 Dependencies

### Managing Dependencies

```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Outdated dependencies check
flutter pub outdated

# Analyze dependency tree
flutter pub deps
```

### Key Dependencies

See `pubspec.yaml` for complete list. Major dependencies include:

- **firebase_core** - Firebase SDK
- **firebase_auth** - Authentication
- **cloud_firestore** - Database
- **firebase_storage** - File storage
- **firebase_analytics** - Analytics
- **syncfusion_flutter_pdf** - PDF generation
- **excel** - Excel file handling
- **image_picker** - Photo capture/selection

---

## 🧪 Testing Builds

### Run Locally

```bash
# Web (Chrome)
flutter run -d chrome

# Android device
flutter run -d [device-id]

# iOS simulator
flutter run -d iPhone

# List available devices
flutter devices
```

### Test Web Build Locally

```bash
# Build for web
flutter build web --release

# Serve locally (Python)
cd build/web
python -m http.server 8000
# Visit: http://localhost:8000

# Or use npm package
npx http-server build/web -p 8000
```

---

## 🚨 Common Build Issues & Fixes

### Java Version Issues

**Symptom:** `Unsupported class file major version 68`

**Fix:** Install Java 17 and configure `gradle.properties` as shown above.

### Gradle Build Fails

**Symptom:** Various Gradle errors

**Fix:**
```bash
cd android
.\gradlew clean
.\gradlew --stop
cd ..
flutter clean
flutter pub get
```

### iOS Build Fails

**Symptom:** CocoaPods errors

**Fix:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### Web Build Warnings

**Symptom:** `file_picker` platform warnings

**Note:** Safe to ignore - these are from the package supporting multiple platforms.

---

## 📱 App Signing (Production)

### Android Signing

1. **Generate Key Store**

```bash
keytool -genkey -v -keystore ndt-toolkit-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ndt-toolkit
```

2. **Configure Signing**

Create `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=ndt-toolkit
storeFile=<path-to-keystore>
```

3. **Update** `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### iOS Signing

Configured in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → Signing & Capabilities
3. Select your development team
4. Configure provisioning profiles

---

## 🔒 Security Notes

### Sensitive Files

**Never commit these files:**
- `android/key.properties`
- `android/app/google-services.json` (contains API keys)
- `ios/Runner/GoogleService-Info.plist`
- `*.jks` (keystore files)
- `.env` files

These files should be:
- Added to `.gitignore`
- Stored securely (password manager, secure storage)
- Backed up separately

---

## 📚 Related Documentation

- [Deployment Guide](../DEPLOYMENT.md) - Deploy to production
- [GitHub Actions](../setup/GITHUB_ACTIONS.md) - Automated builds
- [Domain Setup](../setup/DOMAIN_SETUP.md) - Configure hosting

---

## 🆘 Getting Help

### Build Issues

1. Check Flutter doctor: `flutter doctor -v`
2. Clean and rebuild (see Clean Build section)
3. Review error logs carefully
4. Check Flutter GitHub issues
5. Consult troubleshooting section

### Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Android Build Guide](https://docs.flutter.dev/deployment/android)
- [iOS Build Guide](https://docs.flutter.dev/deployment/ios)

---

**Last Updated:** February 19, 2026
