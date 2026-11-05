@echo off
setlocal EnableExtensions
chcp 65001 >nul

rem ============================================================
rem  Quvvat — Android release APK yig'ish
rem  Ishga tushirish: bu faylni ikki marta bosing.
rem  API manzilini o'zgartirish: build qilishdan oldin
rem    set API_BASE_URL=https://api.quvvat.uz/api
rem  buyrug'ini bering yoki pastdagi qatorni tahrirlang.
rem ============================================================

cd /d "%~dp0.."

rem --- Flutter ---
if exist "%USERPROFILE%\flutter\bin\flutter.bat" (
  set "PATH=%USERPROFILE%\flutter\bin;%PATH%"
)

rem --- JDK 17 (JAVA_HOME berilmagan bo'lsa, jdk-17* papkasini qidiramiz) ---
if not defined JAVA_HOME (
  for /d %%d in ("%USERPROFILE%\jdk-17*") do (
    if exist "%%d\bin\java.exe" set "JAVA_HOME=%%d"
  )
)
if not defined JAVA_HOME if exist "%ProgramFiles%\Java\jdk-17" set "JAVA_HOME=%ProgramFiles%\Java\jdk-17"
if defined JAVA_HOME set "PATH=%JAVA_HOME%\bin;%PATH%"

rem --- Android SDK ---
if not defined ANDROID_HOME if exist "%USERPROFILE%\android-sdk" set "ANDROID_HOME=%USERPROFILE%\android-sdk"
if not defined ANDROID_HOME if exist "%LOCALAPPDATA%\Android\Sdk" set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
if defined ANDROID_HOME set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
if defined ANDROID_HOME set "PATH=%ANDROID_HOME%\platform-tools;%PATH%"

rem --- API manzili ---
if not defined API_BASE_URL set "API_BASE_URL=http://10.144.82.174:8000/api"

where flutter >nul 2>nul
if errorlevel 1 (
  echo.
  echo XATO: Flutter topilmadi.
  echo Flutter'ni o'rnating: https://docs.flutter.dev/get-started/install/windows
  echo yoki FLUTTER papkasini PATH ga qo'shing.
  goto :error
)

echo.
echo   Flutter :
where flutter
echo   JDK     : %JAVA_HOME%
echo   SDK     : %ANDROID_HOME%
echo   API     : %API_BASE_URL%
echo.

call flutter pub get
if errorlevel 1 goto :error

call flutter build apk --release --dart-define=API_BASE_URL=%API_BASE_URL%
if errorlevel 1 goto :error

echo.
echo ============================================================
echo   TAYYOR!
echo   %CD%\build\app\outputs\flutter-apk\app-release.apk
echo ============================================================
echo.
pause
exit /b 0

:error
echo.
echo XATO yuz berdi. Yuqoridagi xabarni tekshiring.
pause
exit /b 1
