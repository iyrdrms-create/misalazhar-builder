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
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    
    # Latar putih polos agar sejuk dipandang
    $g.Clear([System.Drawing.Color]::White)
    
    $srcW = $src.Width
    $srcH = $src.Height
    
    # Skala 90% bingkai agar ada margin/bingkai putih estetik di sekelilingnya
    $ratio = [math]::Min( (1280 * 0.9) / $srcW, (800 * 0.9) / $srcH )
    
    $newW = [int]($srcW * $ratio)
    $newH = [int]($srcH * $ratio)
    
    $posX = [int]((1280 - $newW) / 2)
    $posY = [int]((800 - $newH) / 2)
    
    $g.DrawImage($src, $posX, $posY, $newW, $newH)
    
    $outPath = $file.DirectoryName + "\hd_" + $file.Name
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $g.Dispose()
    $bmp.Dispose()
    $src.Dispose()
}

Write-Host "Berhasil memanen semua screenshot!"
