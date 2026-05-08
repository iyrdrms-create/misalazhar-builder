Add-Type -AssemblyName System.Drawing
$sizes = @( @(32,32), @(48,48), @(96,96), @(128,128), @(220,140) )
foreach ($s in $sizes) {
    $w = $s[0]
    $h = $s[1]
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::RoyalBlue)
    
    # Optional text for fun
    $font = New-Object System.Drawing.Font("Arial", 8)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString("AFB", $font, $brush, 0, 0)

    $path = "d:\SOFTWARE\addon\icon_${w}x${h}.png"
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}
