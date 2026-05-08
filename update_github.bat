@echo off
setlocal
cd /d "%~dp0"

:: Konfigurasi URL Repository
set REPO_URL=https://github.com/iyrdrms-create/misalazhar-builder.git

:: Inisialisasi jika belum
if not exist ".git" (
    echo [INFO] Inisialisasi Git...
    git init
    git remote add origin %REPO_URL%
    git branch -M main
)

:: Reset paksa agar mengikuti .gitignore yang baru
echo [INFO] Membersihkan daftar file lama...
git reset --mixed HEAD > nul 2>&1
git rm -r --cached . > nul 2>&1

echo [INFO] Menambahkan file (Sesuai .gitignore)...
git add .

:: Input pesan commit dari user
set /p commit_msg="Masukkan pesan perubahan (commit message): "
if "%commit_msg%"=="" set commit_msg="Update rutin via script bat"

echo [INFO] Melakukan commit...
git commit -m "%commit_msg%"

echo [INFO] Mengirim ke GitHub (Push)...
git push -u origin main -f

echo.
echo ==========================================
echo [INFO] Jika muncul error 403, pastikan Anda sudah 
echo menghapus login GitHub lama di Credential Manager Windows.
echo ==========================================
pause
