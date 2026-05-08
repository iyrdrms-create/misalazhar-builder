Add-Type -AssemblyName System.Drawing
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$sourceFile = "d:\SOFTWARE\addon\logo.png"

if (!(Test-Path $sourceFile)) {
    Write-Host "File logo.png tidak ditemukan!"
    exit
}

$image = [System.Drawing.Image]::FromFile($sourceFile)

$sizes = @( @(32,32), @(48,48), @(96,96), @(128,128), @(220,140) )

foreach ($s in $sizes) {
    $w = $s[0]
    $h = $s[1]
    
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    
    # Kualitas resolusi tinggi (High Quality)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    # Isi dengan background putih murni
    $g.Clear([System.Drawing.Color]::White)
    
    # Gambar/Resize logo ke tengah-tengah
    $g.DrawImage($image, 0, 0, $w, $h)
    
    $path = "d:\SOFTWARE\addon\logo_$($w)x$($h).png"
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $g.Dispose()
    $bmp.Dispose()
}

$image.Dispose()
Write-Host "Berhasil!"
