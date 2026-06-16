@echo off
echo Menginstal Aftman (Manajer Tool Roblox)...
powershell -Command "iex (irm 'https://raw.githubusercontent.com/LPGhatguy/aftman/main/scripts/install.ps1')"

echo.
echo Menginstal Rojo dan tool lainnya sesuai aftman.toml...
aftman install

echo.
echo Setup Selesai! Silakan tutup jendela ini dan buka ulang VS Code / PowerShell Anda.
pause
