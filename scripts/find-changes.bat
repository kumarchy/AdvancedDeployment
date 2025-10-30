@echo off
setlocal enabledelayedexpansion

echo ========================================
echo 🔍 Detecting changed metadata files...
echo ========================================

REM Define paths
set ROOT_DIR=%~dp0..
set DELTA_DIR=%ROOT_DIR%\delta
set FORCEAPP_DIR=%ROOT_DIR%\force-app\main\default

REM Cleanup old delta folder
if exist "%DELTA_DIR%" (
    echo Removing old delta folder...
    rmdir /s /q "%DELTA_DIR%"
)
mkdir "%DELTA_DIR%\src"

REM Detect changed files
cd /d "%ROOT_DIR%"
git diff --name-only HEAD~1 HEAD > "%DELTA_DIR%\changed_files.txt"

echo Changed files:
type "%DELTA_DIR%\changed_files.txt"
echo.

REM Initialize flags for package.xml
set HAS_CLASSES=0
set HAS_TRIGGERS=0
set HAS_LWC=0

for /f "usebackq delims=" %%f in ("%DELTA_DIR%\changed_files.txt") do (
    set FILE=%%f
    REM Convert forward slashes to backslashes for Windows
    set "FILE=!FILE:/=\!"
    
    if "!FILE!"=="" (
        REM skip empty lines
    ) else (
        if exist "!FILE!" (
            echo Processing: !FILE!

            REM --- Apex Classes ---
            echo !FILE! | findstr /C:"force-app\main\default\classes" >nul
            if !errorlevel! equ 0 (
                echo [APEX CLASS] Copying !FILE! ...
                mkdir "%DELTA_DIR%\src\classes" >nul 2>&1
                copy "!FILE!" "%DELTA_DIR%\src\classes\" >nul
                set HAS_CLASSES=1
            )

            REM --- Apex Triggers ---
            echo !FILE! | findstr /C:"force-app\main\default\triggers" >nul
            if !errorlevel! equ 0 (
                echo [APEX TRIGGER] Copying !FILE! ...
                mkdir "%DELTA_DIR%\src\triggers" >nul 2>&1
                copy "!FILE!" "%DELTA_DIR%\src\triggers\" >nul
                set HAS_TRIGGERS=1
            )

            REM --- Lightning Web Components ---
            echo !FILE! | findstr /C:"force-app\main\default\lwc" >nul
            if !errorlevel! equ 0 (
                echo [LWC] Copying !FILE! ...
                REM Extract component name from path
                for %%a in ("!FILE!") do (
                    set "FULLPATH=%%~dpa"
                    set "FILENAME=%%~nxa"
                )
                
                REM Get the component folder name (parent of the file)
                for %%b in ("!FULLPATH:~0,-1!") do (
                    set "COMPONENT_NAME=%%~nxb"
                    mkdir "%DELTA_DIR%\src\lwc\!COMPONENT_NAME!" >nul 2>&1
                    copy "!FILE!" "%DELTA_DIR%\src\lwc\!COMPONENT_NAME!\" >nul
                )
                set HAS_LWC=1
            )

            REM --- Aura Components ---
            echo !FILE! | findstr /C:"force-app\main\default\aura" >nul
            if !errorlevel! equ 0 (
                echo [AURA] Copying !FILE! ...
                for %%a in ("!FILE!") do (
                    set "FULLPATH=%%~dpa"
                    set "FILENAME=%%~nxa"
                )
                for %%b in ("!FULLPATH:~0,-1!") do (
                    set "COMPONENT_NAME=%%~nxb"
                    mkdir "%DELTA_DIR%\src\aura\!COMPONENT_NAME!" >nul 2>&1
                    copy "!FILE!" "%DELTA_DIR%\src\aura\!COMPONENT_NAME!\" >nul
                )
            )

            REM --- Objects ---
            echo !FILE! | findstr /C:"force-app\main\default\objects" >nul
            if !errorlevel! equ 0 (
                echo [OBJECT] Copying !FILE! ...
                for %%a in ("!FILE!") do (
                    set "FULLPATH=%%~dpa"
                    set "FILENAME=%%~nxa"
                )
                for %%b in ("!FULLPATH:~0,-1!") do (
                    set "OBJECT_NAME=%%~nxb"
                    mkdir "%DELTA_DIR%\src\objects\!OBJECT_NAME!" >nul 2>&1
                    copy "!FILE!" "%DELTA_DIR%\src\objects\!OBJECT_NAME!\" >nul
                )
            )

            REM --- Flows ---
            echo !FILE! | findstr /C:"force-app\main\default\flows" >nul
            if !errorlevel! equ 0 (
                echo [FLOW] Copying !FILE! ...
                mkdir "%DELTA_DIR%\src\flows" >nul 2>&1
                copy "!FILE!" "%DELTA_DIR%\src\flows\" >nul
            )

        ) else (
            echo WARNING: File not found - !FILE!
        )
    )
)

REM --- Generate Dynamic package.xml based on what was found ---
echo.
echo Generating package.xml...

(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Package xmlns="http://soap.sforce.com/2006/04/metadata"^>

if !HAS_CLASSES! equ 1 (
    echo     ^<types^>
    echo         ^<members^>*^</members^>
    echo         ^<name^>ApexClass^</name^>
    echo     ^</types^>
)

if !HAS_TRIGGERS! equ 1 (
    echo     ^<types^>
    echo         ^<members^>*^</members^>
    echo         ^<name^>ApexTrigger^</name^>
    echo     ^</types^>
)

if !HAS_LWC! equ 1 (
    echo     ^<types^>
    echo         ^<members^>*^</members^>
    echo         ^<name^>LightningComponentBundle^</name^>
    echo     ^</types^>
)

echo     ^<version^>60.0^</version^>
echo ^</Package^>
) > "%DELTA_DIR%\package.xml"

echo.
echo ========================================
echo ✅ Delta folder created successfully!
echo Location: %DELTA_DIR%
echo ========================================
echo.
echo Summary:
if !HAS_CLASSES! equ 1 echo - Apex Classes: Found
if !HAS_TRIGGERS! equ 1 echo - Apex Triggers: Found
if !HAS_LWC! equ 1 echo - Lightning Web Components: Found
echo ========================================
endlocal