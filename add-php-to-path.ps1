# Script to add PHP to PATH environment variable
# Run this script as Administrator for permanent changes, or run normally for current session only

$phpPath = "C:\Users\amohn\Developer\php-8.5.1-nts-Win32-vs17-x64"

# Check if php.exe exists
if (Test-Path "$phpPath\php.exe") {
    Write-Host "✓ Found php.exe at: $phpPath\php.exe" -ForegroundColor Green
} else {
    Write-Host "✗ php.exe not found in: $phpPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "You need to download the Windows binaries from:" -ForegroundColor Yellow
    Write-Host "https://windows.php.net/download/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Look for: php-8.5.1-nts-Win32-vs17-x64.zip (Non-Thread Safe version)" -ForegroundColor Yellow
    Write-Host "Extract it so that php.exe is in: $phpPath" -ForegroundColor Yellow
    exit 1
}

# Add to PATH for current session
$env:PATH += ";$phpPath"
Write-Host "✓ Added to PATH for current session" -ForegroundColor Green

# Test PHP
Write-Host ""
Write-Host "Testing PHP installation..." -ForegroundColor Cyan
php -v

Write-Host ""
Write-Host "Note: This PATH change is only for the current PowerShell session." -ForegroundColor Yellow
Write-Host "To make it permanent, you need to:" -ForegroundColor Yellow
Write-Host "1. Run PowerShell as Administrator" -ForegroundColor Yellow
Write-Host "2. Run: [Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';$phpPath', 'User')" -ForegroundColor Cyan
