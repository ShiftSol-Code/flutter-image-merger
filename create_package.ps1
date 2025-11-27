# PowerShell console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
# $OutputEncoding = [System.Text.Encoding]::UTF8

# Release build and deployment package creation script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Image Merger - Windows Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Release build
Write-Host "[1/6] Building release version..." -ForegroundColor Green
flutter build windows --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Build completed!" -ForegroundColor Green
Write-Host ""

# 2. Stop running processes
Write-Host "[2/6] Checking for running app..." -ForegroundColor Green
$processName = "image_merger"
$runningProcess = Get-Process -Name $processName -ErrorAction SilentlyContinue
if ($runningProcess) {
    Write-Host "Stopping running $processName process..." -ForegroundColor Yellow
    Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# 3. Create deployment folder
Write-Host "[3/6] Preparing deployment folder..." -ForegroundColor Green
$deployDir = "ImageMerger_Windows"
if (Test-Path $deployDir) {
    Remove-Item $deployDir -Recurse -Force
}
New-Item -ItemType Directory -Path $deployDir | Out-Null

# 4. Copy files
Write-Host "[4/6] Copying files..." -ForegroundColor Green
$sourceDir = "build\windows\x64\runner\Release"

# File copy retry logic
$maxRetries = 3
$retryCount = 0
$copySuccess = $false

while (-not $copySuccess -and $retryCount -lt $maxRetries) {
    try {
        Copy-Item "$sourceDir\*" -Destination $deployDir -Recurse -Force
        $copySuccess = $true
    }
    catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-Host "Retrying file copy... ($retryCount/$maxRetries)" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
        else {
            Write-Host "File copy failed!" -ForegroundColor Red
            exit 1
        }
    }
}

# 5. Create README
Write-Host "[5/6] Creating README file..." -ForegroundColor Green
$readmeContent = @"
# Image Merger - Vertical Image Combiner

A simple tool to merge multiple images vertically.

## How to Run
1. Double-click **image_merger.exe** to launch

## Features
* Multiple image selection and vertical merging
* Drag and drop for easy upload
* Mouse wheel zoom in/out
* Mouse drag to pan image
* Save to custom location
* Remembers save path

## Usage

### Method 1: Button Upload
1. Click "Upload Images" button
2. Select multiple images (Ctrl + Click)
3. Images automatically merge vertically

### Method 2: Drag and Drop
1. Select image files in File Explorer
2. Drag to app window (blue border appears)
3. Drop to automatically merge

### Image Controls
- **Zoom**: Mouse wheel
- **Pan**: Click and drag

### Save
1. Click "Save" button
2. Choose folder and filename
3. Save (same folder used as default next time)

## System Requirements
- Windows 10 or later (64-bit)
- About 50MB disk space

## Troubleshooting

### "VCRUNTIME140.dll not found" error
Install Visual C++ Redistributable:
https://aka.ms/vs/17/release/vc_redist.x64.exe

### App won't start
- Add to Windows Defender exceptions
- Try running as administrator

### Drag and drop not working
Run app and File Explorer at same privilege level.

## Version
Version: 1.0.0
Built with: Flutter

## License
MIT License

---
Contact developer if you encounter issues.
"@

[System.IO.File]::WriteAllText((Join-Path $PWD "$deployDir\README.txt"), $readmeContent, [System.Text.Encoding]::UTF8)

# 6. Create ZIP
Write-Host "[6/6] Creating ZIP package..." -ForegroundColor Green
$zipFile = "ImageMerger_Windows.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

# ZIP compression retry logic
$zipSuccess = $false
$retryCount = 0

while (-not $zipSuccess -and $retryCount -lt $maxRetries) {
    try {
        Compress-Archive -Path $deployDir -DestinationPath $zipFile -Force
        $zipSuccess = $true
    }
    catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-Host "Retrying ZIP creation... ($retryCount/$maxRetries)" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
        else {
            Write-Host "ZIP creation failed! Please compress the folder manually." -ForegroundColor Red
            Write-Host "Deployment folder: $deployDir\" -ForegroundColor Yellow
            exit 1
        }
    }
}

# Completion message
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment package created successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package file: $zipFile" -ForegroundColor Yellow

if (Test-Path $zipFile) {
    $zipSize = [math]::Round((Get-Item $zipFile).Length / 1MB, 2)
    Write-Host "Package size: $zipSize MB" -ForegroundColor Yellow
}

Write-Host "Deployment folder: $deployDir\" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Send $zipFile to users" -ForegroundColor White
Write-Host "2. Users extract and run image_merger.exe" -ForegroundColor White
Write-Host "3. Works without Flutter installation!" -ForegroundColor White
Write-Host ""
