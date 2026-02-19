# Android Build Fix - Commands to Run

## ✅ What Was Updated
- **Kotlin**: 1.8.0 → 1.9.22
- **Android Gradle Plugin**: 7.2.0 → 8.1.4  
- **Google Services**: 4.3.15 → 4.4.0
- **Gradle Wrapper**: Already at 8.10 ✅

---

## 🔧 Step 1: Fix Android SDK Issues

Run these commands in PowerShell (in order):

### 1a. Accept Android Licenses
```powershell
flutter doctor --android-licenses
```
**What to do**: Press `y` and Enter when prompted for each license.

### 1b. Install Missing cmdline-tools
Open Android Studio, then:
1. Go to **Tools → SDK Manager**
2. Click the **SDK Tools** tab
3. Check ☑️ **Android SDK Command-line Tools (latest)**
4. Click **Apply** → **OK**

Or use command line:
```powershell
# Using Android Studio's SDK Manager is recommended
# But if you have sdkmanager in PATH, you can run:
sdkmanager "cmdline-tools;latest"
```

---

## 🧹 Step 2: Clean Everything

Run these commands one by one:

```powershell
# Clean Flutter build
flutter clean

# Clean Gradle cache (this is important!)
cd android
./gradlew clean
cd ..

# Clear Gradle daemon (optional but helpful)
cd android
./gradlew --stop
cd ..
```

---

## 🔨 Step 3: Rebuild the Project

```powershell
# Get Flutter dependencies fresh
flutter pub get

# Build for Android (this will also test if it works)
flutter build apk --debug
```

---

## 🚀 Step 4: Run on Device

If Step 3 succeeds, try running on your device:

```powershell
flutter run
```

---

## ⚠️ If You Still Get Errors

### Error: "Namespace not specified"
If you see this error, run:
```powershell
flutter clean
flutter pub get
cd android
./gradlew --stop
cd ..
flutter run
```

### Error: Java version issues
Make sure you have **Java 11 or higher** installed:
```powershell
java -version
```
Should show version 11 or higher.

### Error: Gradle download issues
If Gradle download fails, try manually:
```powershell
cd android
./gradlew wrapper --gradle-version=8.10
cd ..
```

---

## 📋 Quick Summary

**Run these in order:**
1. `flutter doctor --android-licenses` (accept all)
2. Install cmdline-tools via Android Studio SDK Manager
3. `flutter clean`
4. `cd android && ./gradlew clean && cd ..`
5. `flutter pub get`
6. `flutter build apk --debug`
7. `flutter run`

---

## ✅ Success Indicators

You'll know it worked when:
- ✅ `flutter doctor` shows no errors for Android toolchain
- ✅ `flutter build apk --debug` completes without errors
- ✅ `flutter run` launches the app on your device

---

**Note**: The build files have been updated. DO NOT commit/push yet until you've tested that the build works!
