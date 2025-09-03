$bucketPath = "."
$files = Get-ChildItem -Path $bucketPath -Filter *.json

foreach ($file in $files) {
    Write-Host "🔍 Processing manifest: $($file.Name)"

    # Load JSON
    $json = Get-Content $file.FullName | ConvertFrom-Json

    # Extract URL
    $url = $json.url
    if (-not $url) {
        Write-Warning "❌ No URL found in $($file.Name)!"
        continue
    }

    # Download file temporarily
    $temp = New-TemporaryFile
    Invoke-WebRequest -Uri $url -OutFile $temp.FullName

    # Calculate SHA256
    $hash = (Get-FileHash $temp.FullName -Algorithm SHA256).Hash.ToUpper()

    # Replace hash in JSON
    $json.hash = $hash

    # Write back (formatted)
    $json | ConvertTo-Json -Depth 5 | Set-Content -Path $file.FullName -Encoding UTF8

    Write-Host "✅ Updated hash for $($file.Name): $hash"
}
