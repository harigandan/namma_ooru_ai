# ==============================================================================
# Namma Ooru AI — Custom Domain Deployment Script (Windows / PowerShell)
# ==============================================================================

param (
    [string]$DomainName,
    [string]$AdminEmail
)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  நம்ம ஊர் AI • Namma Ooru AI Domain Publishing" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

if (-not $DomainName) {
    $DomainName = Read-Host "Enter your custom domain name (e.g., nammaooru.ai or portal.yourcity.gov.in)"
}

if (-not $AdminEmail) {
    $AdminEmail = Read-Host "Enter your admin email for Let's Encrypt SSL notifications"
}

Write-Host "`n>> Updating nginx.conf with domain: $DomainName..." -ForegroundColor Yellow
$nginxContent = Get-Content -Path "nginx.conf" -Raw
$nginxContent = $nginxContent -replace 'YOUR_DOMAIN', $DomainName
Set-Content -Path "nginx.conf" -Value $nginxContent

Write-Host "`n>> Compiling Flutter Web Production Bundle..." -ForegroundColor Yellow
$env:PATH = "C:\Program Files\Git\cmd;F:\flutter\bin;$env:PATH"
flutter build web --release --no-wasm-dry-run --dart-define=API_BASE_URL=/api/v1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter web build failed. Please check errors above." -ForegroundColor Red
    exit 1
}

Write-Host "`n>> Ready for production deployment!" -ForegroundColor Green
Write-Host "Next steps on your remote Linux server (Ubuntu 22.04 / 24.04):" -ForegroundColor Cyan
Write-Host "1. Point your domain's DNS A-record to your server's Public IP."
Write-Host "2. Copy the project folder to your VPS: scp -r . user@your-server-ip:/var/www/namma_ooru"
Write-Host "3. Run: bash deploy_domain.sh $DomainName $AdminEmail"
Write-Host "4. Visit https://$DomainName to access Namma Ooru AI live!" -ForegroundColor Green
