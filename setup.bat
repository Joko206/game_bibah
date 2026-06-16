@echo off
echo Mengunduh Aftman v0.3.0 (Manajer Tool Roblox)...
powershell -Command "$url = 'https://github.com/LPGhatguy/aftman/releases/download/v0.3.0/aftman-0.3.0-windows-x86_64.zip'; $zipPath = \"$env:TEMP\aftman.zip\"; $extractPath = \"$env:TEMP\aftman_temp\"; Invoke-WebRequest -Uri $url -OutFile $zipPath; Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force; & \"$extractPath\aftman.exe\" self-install"

echo.
echo Menginstal Rojo dan tool lainnya sesuai aftman.toml...
set PATH=%USERPROFILE%\.aftman\bin;%PATH%
aftman install

echo.
echo Setup Selesai! Silakan tutup jendela ini dan buka ulang VS Code / PowerShell Anda.
pause
