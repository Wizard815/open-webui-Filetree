# Export SSL certificate chain from registry.ollama.ai
# Run: powershell -ExecutionPolicy Bypass -File export-cert-chain.ps1

$url = "https://registry.ollama.ai"
$outFile = Join-Path $PSScriptRoot "..\certs\ollama-chain.pem"

Write-Host "Connecting to $url ..."

try {
    $request = [System.Net.HttpWebRequest]::Create($url)
    $request.AllowAutoRedirect = $true
    $request.Timeout = 10000
    [void]$request.GetResponse()
}
catch {
    Write-Host "Connection error (may be OK): $($_.Exception.Message)"
}

$cert = $request.ServicePoint.Certificate
if (-not $cert) {
    Write-Host "ERROR: No certificate received. Check proxy/network."
    exit 1
}

$chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
$chain.Build($cert) | Out-Null

$pem = ""
foreach ($elem in $chain.ChainElements) {
    $c = $elem.Certificate
    $bytes = $c.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
    $b64 = [Convert]::ToBase64String($bytes)
    $pem += "-----BEGIN CERTIFICATE-----`r`n"
    for ($i = 0; $i -lt $b64.Length; $i += 64) {
        $chunk = if ($i + 64 -lt $b64.Length) { $b64.Substring($i, 64) } else { $b64.Substring($i) }
        $pem += $chunk + "`r`n"
    }
    $pem += "-----END CERTIFICATE-----`r`n`r`n"
}

# Ensure certs directory exists
$certsDir = Split-Path $outFile
if (-not (Test-Path $certsDir)) { New-Item -ItemType Directory -Path $certsDir -Force | Out-Null }

$pem | Out-File -FilePath $outFile -Encoding ASCII -NoNewline
(Get-Content $outFile -Raw).TrimEnd() | Set-Content $outFile -Encoding ASCII -NoNewline

Write-Host "Chain exported to: $outFile"
Write-Host "Certificates in chain: $($chain.ChainElements.Count)"
