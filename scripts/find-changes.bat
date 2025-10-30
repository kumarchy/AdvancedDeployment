@echo off
echo ========================================
echo  🔍 Detecting changed metadata files...
echo ========================================

:: Go to project root
cd /d "%~dp0.."

:: Delete old delta folder if it exists
if exist delta (
    echo Removing old delta folder...
    rmdir /s /q delta
)

:: Create new delta folder
mkdir delta

:: Get changed files between last two commits
git diff --name-only HEAD~1 HEAD > changed_files.txt

echo.
echo Changed files:
type changed_files.txt
echo.

:: Copy only changed Salesforce metadata files to delta folder
for /f "tokens=*" %%A in (changed_files.txt) do (
    if exist "%%A" (
        echo Copying %%A ...
        mkdir "delta\%%~dpA" 2>nul
        xcopy "%%A" "delta\%%A*" /Y /I >nul
    )
)

:: Copy the package.xml for deployment
if exist "package.xml" (
    copy "package.xml" "delta\package.xml" >nul
)

echo.
echo ========================================
echo ✅ Delta folder created successfully!
echo Location: %cd%\delta
echo ========================================
pause
