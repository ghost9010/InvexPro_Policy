@echo off
setlocal EnableDelayedExpansion

title Deploy InvexPro Privacy Policy to GitHub

echo ========================================================
echo   InvexPro Privacy Policy - GitHub Deployment Script
echo ========================================================
echo.

cd /d "%~dp0"

:: 1. Check Git Installation
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Git is not installed or not in system PATH.
    pause
    exit /b 1
)

:: 2. Target Repository
set "GH_USER="
where gh >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%u in ('gh api user -q .login 2^>nul') do (
        set "GH_USER=%%u"
    )
)

if "%GH_USER%"=="" (
    set "GH_USER=ghost9010"
)

set "REPO_URL=https://github.com/!GH_USER!/InvexPro_Policy.git"
echo [INFO] Active Account: !GH_USER!
echo [INFO] Target Repository: !REPO_URL!
echo.

:: 3. Configure Git Author Identity if missing
set "GIT_NAME="
set "GIT_EMAIL="
for /f "tokens=*" %%n in ('git config user.name 2^>nul') do set "GIT_NAME=%%n"
for /f "tokens=*" %%e in ('git config user.email 2^>nul') do set "GIT_EMAIL=%%e"

if "%GIT_NAME%"=="" (
    git config user.name "!GH_USER!"
)
if "%GIT_EMAIL%"=="" (
    git config user.email "!GH_USER!@users.noreply.github.com"
)

:: 4. Check/Auto-Create GitHub Repository if missing
where gh >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    gh repo view !GH_USER!/InvexPro_Policy >nul 2>&1
    if !ERRORLEVEL! NEQ 0 (
        echo [INFO] Creating repository '!GH_USER!/InvexPro_Policy' on GitHub...
        gh repo create !GH_USER!/InvexPro_Policy --public --confirm >nul 2>&1
    )
)

:: 5. Initialize Git in InvexProPrivacy folder
echo [1/4] Configuring local Git repository...
if exist ".git" (
    git remote set-url origin !REPO_URL! 2>nul || git remote add origin !REPO_URL!
) else (
    git init
    git remote add origin !REPO_URL!
)

git branch -M main

:: 6. Stage & Commit
echo [2/4] Staging Privacy Policy files...
git add -A

echo [3/4] Creating commit...
git commit -m "Update InvexPro Privacy Policy - %DATE% %TIME%" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] No new changes detected. Proceeding to push.
) else (
    echo [OK] Commit created.
)

:: 7. Push to GitHub
echo [4/4] Pushing Privacy Policy to GitHub (!REPO_URL!)...
git push -u origin main --force
if %ERRORLEVEL% NEQ 0 goto PUSH_ERROR

echo.
echo ========================================================
echo  SUCCESS: Privacy Policy site deployed to GitHub!
echo  Repository URL : !REPO_URL!
echo  GitHub Pages   : https://!GH_USER!.github.io/InvexPro_Policy/
echo ========================================================
echo.
pause
exit /b 0

:PUSH_ERROR
echo.
echo ========================================================
echo  [ERROR] Push failed.
echo  Please ensure you are authenticated in Git or GitHub CLI.
echo ========================================================
echo.
pause
exit /b 1
