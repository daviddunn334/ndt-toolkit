# PowerShell script to generate PWA icons with dark gray background
# Background color: #1f232a

$sourcePath = "assets\logos\logo_appicon.png"
$outputDir = "web\icons"
$backgroundColor = "#1f232a"

Write-Host "Generating PWA icons with background color: $backgroundColor" -ForegroundColor Green

# Ensure output directory exists
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Load System.Drawing assembly
Add-Type -AssemblyName System.Drawing

# Load source image
$sourceImage = [System.Drawing.Image]::FromFile((Resolve-Path $sourcePath).Path)
$sourceWidth = $sourceImage.Width
$sourceHeight = $sourceImage.Height

Write-Host "Source image size: ${sourceWidth}x${sourceHeight}" -ForegroundColor Cyan

# Parse background color
$bgColor = [System.Drawing.ColorTranslator]::FromHtml($backgroundColor)

# Function to create icon with background
function Create-IconWithBackground {
    param(
        [int]$size,
        [string]$filename,
        [bool]$maskable = $false
    )
    
    # Create new bitmap with background
    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Enable high quality rendering
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # Fill background
    $graphics.Clear($bgColor)
    
    # Calculate logo size and position
    if ($maskable) {
        # For maskable icons, use 80% of canvas (safe zone)
        $logoSize = [math]::Floor($size * 0.65)
    } else {
        # For regular icons, use 85% of canvas
        $logoSize = [math]::Floor($size * 0.75)
    }
    
    $x = [math]::Floor(($size - $logoSize) / 2)
    $y = [math]::Floor(($size - $logoSize) / 2)
    
    # Draw the logo
    $destRect = New-Object System.Drawing.Rectangle($x, $y, $logoSize, $logoSize)
    $graphics.DrawImage($sourceImage, $destRect, 0, 0, $sourceWidth, $sourceHeight, [System.Drawing.GraphicsUnit]::Pixel)
    
    # Save the image
    $outputPath = Join-Path $outputDir $filename
    $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Cleanup
    $graphics.Dispose()
    $bitmap.Dispose()
    
    Write-Host "  Created: $filename (${size}x${size})" -ForegroundColor Yellow
}

# Generate all required icon sizes
Write-Host "`nGenerating icons..." -ForegroundColor Green

# Standard icons
Create-IconWithBackground -size 192 -filename "icon-192.png"
Create-IconWithBackground -size 512 -filename "icon-512.png"

# Maskable icons (with safe zone)
Create-IconWithBackground -size 192 -filename "icon-192-maskable.png" -maskable $true
Create-IconWithBackground -size 512 -filename "icon-512-maskable.png" -maskable $true

# Apple touch icon
Create-IconWithBackground -size 180 -filename "apple-touch-icon.png"

# Cleanup
$sourceImage.Dispose()

Write-Host "`nAll PWA icons generated successfully!" -ForegroundColor Green
Write-Host "Output directory: $outputDir" -ForegroundColor Cyan
