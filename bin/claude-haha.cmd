@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%.."

if "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR:~0,-1%"

set "BUN_EXE="
set "SYSTEM32=%SystemRoot%\System32"
if not exist "%SYSTEM32%\where.exe" set "SYSTEM32=C:\Windows\System32"

if defined BUN_INSTALL if exist "%BUN_INSTALL%\bin\bun.exe" set "BUN_EXE=%BUN_INSTALL%\bin\bun.exe"
if not defined BUN_EXE if exist "%USERPROFILE%\.bun\bin\bun.exe" set "BUN_EXE=%USERPROFILE%\.bun\bin\bun.exe"

if not defined BUN_EXE (
    "%SYSTEM32%\where.exe" bun >nul 2>nul
    if !errorlevel! == 0 (
        for /f "delims=" %%i in ('"%SYSTEM32%\where.exe" bun 2^>nul') do (
            set "BUN_EXE=%%~fi"
            goto :bun_found
        )
    )
)

:bun_found
if not defined BUN_EXE (
    echo [claude-haha] Bun is required but was not found in PATH.
    echo [claude-haha] Install Bun for Windows, reopen the terminal, then run this command again.
    exit /b 1
)

if "%CLAUDE_CODE_FORCE_RECOVERY_CLI%"=="1" (
    "%BUN_EXE%" --preload="%ROOT_DIR%\preload.ts" --env-file="%ROOT_DIR%\.env" "%ROOT_DIR%\src\localRecoveryCli.ts" %*
) else (
    "%BUN_EXE%" --preload="%ROOT_DIR%\preload.ts" --env-file="%ROOT_DIR%\.env" "%ROOT_DIR%\src\entrypoints\cli.tsx" %*
)

exit /b %ERRORLEVEL%
