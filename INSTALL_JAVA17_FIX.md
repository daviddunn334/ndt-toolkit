# ✅ Install Java 17 and Fix Environment

## The Real Problem
- Your system has **Java 24** (too new, causing compatibility issues)
- **JAVA_HOME is NOT set** (Gradle can't find the correct Java)
- Even AGP 8.7.3 has issues with Java 24 in practice
- **Java 17 LTS** is the most stable version for Flutter/Android

---

## 🔧 Step-by-Step Fix

### Step 1: Download Java 17 (LTS)
1. Go to: https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html
2. Download: **Windows x64 Installer** (jdk-17_windows-x64_bin.exe)
3. Run the installer
4. **Remember the installation path** (usually `C:\Program Files\Java\jdk-17`)

---

### Step 2: Set JAVA_HOME Environment Variable

#### Option A: Using Windows Settings (Recommended)
1. Press `Windows Key` and search for **"Environment Variables"**
2. Click **"Edit the system environment variables"**
3. Click **"Environment Variables..."** button at bottom
4. Under **"System variables"** (bottom section):
   - Click **"New..."**
   - Variable name: `JAVA_HOME`
   - Variable value: `C:\Program Files\Java\jdk-17` (or your actual Java 17 path)
   - Click **OK**
5. Find **"Path"** in System variables
   - Click **Edit**
   - Click **New**
   - Add: `%JAVA_HOME%\bin`
   - Click **OK** on all dialogs
6. **Restart VS Code, Android Studio, and PowerShell**

#### Option B: Using PowerShell (Temporary - for testing only)
```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
```
**Note**: This only works for the current PowerShell session!

---

### Step 3: Verify Java 17 is Active
Open a **NEW** PowerShell window and run:
```powershell
java -version
```
Should show: `java version "17.x.x"`

```powershell
echo $env:JAVA_HOME
```
Should show: `C:\Program Files\Java\jdk-17`

---

### Step 4: Tell Gradle to Use Java 17
Create or edit `android/gradle.properties` to add:
```properties
org.gradle.java.home=C:\\Program Files\\Java\\jdk-17
```
**Note**: Use double backslashes `\\` in the path!

---

### Step 5: Clean Everything
```powershell
.\AGGRESSIVE_GRADLE_CLEANUP.bat
```

---

### Step 6: Test Build
```powershell
flutter run
```

---

## ✅ What Should Happen

When you run `cd android; .\gradlew -version`, you should see:
```
Launcher JVM:  17.x.x (Oracle Corporation ...)
Daemon JVM:    C:\Program Files\Java\jdk-17 (no JDK specified, using current Java home)
```

---

## 🎯 Why Java 17?

| Java Version | Status | Flutter/Android Support |
|--------------|--------|------------------------|
| Java 11      | LTS    | ✅ Widely supported    |
| Java 17      | LTS    | ✅ **BEST CHOICE**     |
| Java 21      | LTS    | ⚠️ Some issues         |
| Java 24      | Latest | ❌ Too new, unstable   |

**Java 17 is:**
- Long Term Support (LTS) - supported until 2029
- Most tested with Flutter and Android
- Recommended by Google for Android development
- Stable and mature

---

## 🔍 Troubleshooting

### If `java -version` still shows Java 24:
1. Make sure you restarted PowerShell/VS Code/Android Studio
2. Check `echo $env:JAVA_HOME` shows Java 17 path
3. Check `echo $env:PATH` includes `%JAVA_HOME%\bin`
4. If multiple Java versions installed, Java 17 path must be BEFORE Java 24 in PATH

### If Gradle still uses Java 24:
1. Make sure `android/gradle.properties` has the `org.gradle.java.home` line
2. Run `cd android; .\gradlew --stop` to kill all Gradle daemons
3. Delete `C:\Users\david\.gradle\caches` folder
4. Try again

### If build still fails:
1. Check Android Studio is also using Java 17:
   - Open Android Studio
   - File → Settings → Build, Execution, Deployment → Build Tools → Gradle
   - Set "Gradle JDK" to Java 17
2. Restart Android Studio

---

## 📝 Summary

1. ✅ Install Java 17
2. ✅ Set JAVA_HOME to Java 17
3. ✅ Add to PATH
4. ✅ Update `android/gradle.properties`
5. ✅ Restart everything
6. ✅ Clean caches
7. ✅ Test build

This should permanently fix your Android build issues!
