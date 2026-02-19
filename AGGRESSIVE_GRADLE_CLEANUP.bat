@echo off
echo ========================================
echo AGGRESSIVE GRADLE CLEANUP
echo ========================================
echo.

echo Step 1: Stopping all Gradle daemons...
cd android
call gradlew --stop
cd ..
echo Done.
echo.

echo Step 2: Deleting build directories...
if exist build rmdir /s /q build
if exist android\build rmdir /s /q android\build
if exist android\.gradle rmdir /s /q android\.gradle
if exist android\app\build rmdir /s /q android\app\build
echo Done.
echo.

echo Step 3: Clearing Gradle cache...
if exist "%USERPROFILE%\.gradle\caches" rmdir /s /q "%USERPROFILE%\.gradle\caches"
echo Done.
echo.

echo Step 4: Running Flutter clean...
call flutter clean
echo Done.
echo.

echo Step 5: Getting fresh dependencies...
call flutter pub get
echo Done.
echo.

echo ========================================
echo CLEANUP COMPLETE!
echo ========================================
echo.
echo Now try: flutter run
echo Or: flutter build apk --debug
echo.
pause
