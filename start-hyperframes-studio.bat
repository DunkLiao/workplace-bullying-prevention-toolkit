@echo off
setlocal

set "PROJECT_DIR=%~dp0video\workplace-bullying-videos"
set "PORT=3002"

if not exist "%PROJECT_DIR%\package.json" (
  echo HyperFrames project was not found:
  echo %PROJECT_DIR%
  echo.
  pause
  exit /b 1
)

start "HyperFrames Studio" cmd /k "cd /d ""%PROJECT_DIR%"" && echo Starting HyperFrames Studio... && echo Project: %PROJECT_DIR% && echo Requested URL: http://127.0.0.1:%PORT% && echo. && echo Keep this window open while editing. Close it to stop Studio. && echo. && npx --yes hyperframes@0.7.22 preview --port %PORT% --open"
