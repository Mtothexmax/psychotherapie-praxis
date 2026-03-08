param(
    [string]$Source = "foto.jpg"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcePath = Join-Path $root $Source

if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Source image not found: $sourcePath"
}

Add-Type -AssemblyName System.Drawing

function Get-JpegCodec {
    return [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
        Where-Object { $_.MimeType -eq "image/jpeg" } |
        Select-Object -First 1
}

function Save-Jpeg {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Bitmap]$Bitmap,
        [Parameter(Mandatory = $true)][string]$OutPath,
        [Parameter(Mandatory = $true)][long]$Quality
    )

    $codec = Get-JpegCodec
    if (-not $codec) {
        throw "JPEG encoder not available on this system."
    }

    $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality,
        $Quality
    )

    try {
        $Bitmap.Save($OutPath, $codec, $encParams)
    }
    finally {
        $encParams.Dispose()
    }
}

function New-CoverResize {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Image]$Image,
        [Parameter(Mandatory = $true)][int]$TargetWidth,
        [Parameter(Mandatory = $true)][int]$TargetHeight
    )

    $targetRatio = $TargetWidth / [double]$TargetHeight
    $sourceRatio = $Image.Width / [double]$Image.Height

    if ($sourceRatio -gt $targetRatio) {
        $cropHeight = $Image.Height
        $cropWidth = [int][Math]::Round($cropHeight * $targetRatio)
        $cropX = [int][Math]::Floor(($Image.Width - $cropWidth) / 2)
        $cropY = 0
    }
    else {
        $cropWidth = $Image.Width
        $cropHeight = [int][Math]::Round($cropWidth / $targetRatio)
        $cropX = 0
        $cropY = [int][Math]::Floor(($Image.Height - $cropHeight) / 2)
    }

    $dest = New-Object System.Drawing.Bitmap($TargetWidth, $TargetHeight)
    $dest.SetResolution($Image.HorizontalResolution, $Image.VerticalResolution)

    $graphics = [System.Drawing.Graphics]::FromImage($dest)
    try {
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

        $srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropWidth, $cropHeight)
        $dstRect = New-Object System.Drawing.Rectangle(0, 0, $TargetWidth, $TargetHeight)
        $graphics.DrawImage($Image, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    }
    finally {
        $graphics.Dispose()
    }

    return $dest
}

$legacyTargets = @(
    "docs/foto-600x400.jpg",
    "docs/foto-1200x800.jpg",
    "docs/foto-1800x1200.jpg"
)

foreach ($legacy in $legacyTargets) {
    $legacyPath = Join-Path $root $legacy
    if (Test-Path -LiteralPath $legacyPath) {
        Remove-Item -LiteralPath $legacyPath -Force
        Write-Host "Removed legacy file $legacyPath"
    }
}

$targets = @(
    @{ Width = 400; Height = 600; Path = (Join-Path $root "docs/foto-400x600.jpg") },
    @{ Width = 800; Height = 1200; Path = (Join-Path $root "docs/foto-800x1200.jpg") },
    @{ Width = 1200; Height = 1800; Path = (Join-Path $root "docs/foto-1200x1800.jpg") }
)

$img = [System.Drawing.Image]::FromFile($sourcePath)
try {
    foreach ($t in $targets) {
        $bmp = New-CoverResize -Image $img -TargetWidth $t.Width -TargetHeight $t.Height
        try {
            Save-Jpeg -Bitmap $bmp -OutPath $t.Path -Quality 90
            Write-Host "Wrote $($t.Path) [$($t.Width)x$($t.Height)] @ quality 90"
        }
        finally {
            $bmp.Dispose()
        }
    }
}
finally {
    $img.Dispose()
}
