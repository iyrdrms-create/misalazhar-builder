Add-Type -AssemblyName System.Drawing
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$imgs = Get-ChildItem -Path "d:\SOFTWARE\addon\ss*.png" -Exclude "hd_ss*.png"
if ($imgs.Count -eq 0) {
    Write-Host "Tidak ada file ss yang ditemukan."
    exit
}

foreach ($file in $imgs) {
    if ($file.Name -like "*logo*") { continue }
    
    $src = [System.Drawing.Image]::FromFile($file.FullName)
    $bmp = New-Object System.Drawing.Bitmap 1280, 800
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    
    # Warna abu-abu Google (nyaman di mata) untuk menutupi ruang kosong yang tersisa
    $bg = [System.Drawing.ColorTranslator]::FromHtml("#F1F3F4")
    $g.Clear($bg)
    
    $srcW = $src.Width
    $srcH = $src.Height
    
    # KUNCI BARU: Jangan paksa melebarkan gambar jika gambarnya asli kecil!
    # Kita hanya memperkecilnya jika gambarnya membengkak (melebihi 1280x800).
    $ratio = [math]::Min( (1280 * 0.9) / $srcW, (800 * 0.9) / $srcH )
    
    # Cegah Scaling Naik (Mencegah Blur!)
    if ($ratio -gt 1) { 
        $ratio = 1 
    }
    
    $newW = [int]($srcW * $ratio)
    $newH = [int]($srcH * $ratio)
    
    $posX = [int]((1280 - $newW) / 2)
    $posY = [int]((800 - $newH) / 2)
    
    # Gambar Bayangan Tipis Estetik (Drop Shadow)
    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 0, 0, 0))
    $g.FillRectangle($shadowBrush, ($posX + 5), ($posY + 5), $newW, $newH)
    
    # Gambar aslinya (Super Jernih 1:1)
    $g.DrawImage($src, $posX, $posY, $newW, $newH)
    
    $outPath = $file.DirectoryName + "\hd_" + $file.Name
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $g.Dispose()
    $bmp.Dispose()
    $src.Dispose()
}

Write-Host "Perbaikan Selesai!"
