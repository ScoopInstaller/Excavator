$assets = (Invoke-RestMethod -Uri "https://api.github.com/repos/github/hub/releases/latest").assets
if(!$assets) {
    Write-Error "Not assets for latest hub release found!"
    exit 1
}

$asset = $assets | Where-Object { $_.name -match 'hub-linux-amd64-[\d.]+.tgz' } | Select-Object -First 1
if(!$asset) {
    Write-Error "No hub asset for linux-amd64 found"
    exit 1
}
Write-Host "Downloading hub to: $PSScriptRoot$($asset.name)"
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "$PSScriptRoot/hub-linux-amd64.tgz"
