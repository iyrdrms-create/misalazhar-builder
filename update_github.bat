@echo off
setlocal
cd /d "%~dp0"

:: Konfigurasi URL Repository
set REPO_URL=https://github.com/iyrdrms-create/misalazhar-builder.git

:: Cek apakah folder .git sudah ada
if not exist ".git" (
    echo [INFO] Inisialisasi Git...
    git init
    git remote add origin %REPO_URL%
    git branch -M main
)

:: Cek apakah remote sudah benar
git remote set-url origin %REPO_URL%

echo [INFO] Menyegarkan daftar file (refresh index)...
git rm -r --cached . > nul 2>&1

echo [INFO] Menambahkan file...
git add .

:: Input pesan commit dari user
set /p commit_msg="Masukkan pesan perubahan (commit message): "
if "%commit_msg%"=="" set commit_msg="Update rutin via script bat"

echo [INFO] Melakukan commit...
git commit -m "%commit_msg%"

echo [INFO] Mengirim ke GitHub (Push)...
git push -u origin main

echo.
echo ==========================================
echo [BERHASIL] Selesai! Tekan apa saja untuk keluar.
echo ==========================================
pause > nul
