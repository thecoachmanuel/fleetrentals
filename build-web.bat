@echo off
echo ===================================================
echo   Building CarLink Flutter Web for Vercel Release
echo ===================================================
flutter build web --release --no-tree-shake-icons
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================================
    echo   Build successful! Output is ready in build\web
    echo   To deploy to Vercel via CLI, run:
    echo     vercel --prod
    echo ===================================================
) else (
    echo Build failed with error code %ERRORLEVEL%.
)
