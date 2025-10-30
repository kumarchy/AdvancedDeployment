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

for /f "usebackq delims=" %%f in ("%DELTA_DIR%\changed_files.txt") do (
    set FILE=%%f
    if "!FILE!"=="" (
        REM skip empty lines
    ) else (
        if exist "!FILE!" (
            echo Copying !FILE! ...

            REM --- Apex Classes ---
            if "!FILE:force-app/main/default/classes=!" neq "!FILE!" (
                mkdir "%DELTA_DIR%\src\classes" >nul 2>&1
                copy "!FILE!" "%DELTA_DIR%\src\classes\" >nul
            )

            REM --- Apex Triggers ---
            if "!FILE:force-app/main/default/triggers=!" neq "!FILE!" (
                mkdir "%DELTA_DIR%\src\triggers" >nul 2>&1
                copy "!FILE!" "%DELTA_DIR%\src\triggers\" >nul
            )

            REM --- Lightning Web Components ---
            if "!FILE:force-app/main/default/lwc=!" neq "!FILE!" (
                for %%a in ("!FILE!") do (
                    set "COMPONENT_PATH=%%~dpa"
                    for %%b in ("!COMPONENT_PATH:~0,-1!") do (
                        xcopy "%%b" "%DELTA_DIR%\src\lwc\%%~nxb" /E /I /Y >nul
                    )
                )
            )
        )
    )
)

REM --- Generate Simple package.xml ---
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Package xmlns="http://soap.sforce.com/2006/04/metadata"^>
echo     ^<types^>
echo         ^<members^>*^</members^>
echo         ^<name^>ApexClass^</name^>
echo     ^</types^>
echo     ^<types^>
echo         ^<members^>*^</members^>
echo         ^<name^>ApexTrigger^</name^>
echo     ^</types^>
echo     ^<types^>
echo         ^<members^>*^</members^>
echo         ^<name^>LightningComponentBundle^</name^>
echo     ^</types^>
echo     ^<version^>60.0^</version^>
echo ^</Package^>
) > "%DELTA_DIR%\package.xml"

echo.
echo ========================================
echo ✅ Delta folder created successfully!
echo Location: %DELTA_DIR%
echo ========================================
endlocal
