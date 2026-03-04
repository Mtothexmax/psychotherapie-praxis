Write-Host "Rebuilding Tailwind CSS..." -ForegroundColor Cyan

if (-not (Test-Path "node_modules")) {
    Write-Host "node_modules not found. Installing dependencies..." -ForegroundColor Yellow
    npm install
}

npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSuccessfully rebuilt docs/style.css" -ForegroundColor Green
} else {
    Write-Host "`nError rebuilding CSS" -ForegroundColor Red
}