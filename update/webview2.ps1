Set-StrictMode -Version Latest
Set-Location "$PSScriptRoot\.."

<#
    - Capture all download links for the latest version of WebView2.
#>

$Content = (Invoke-WebRequest -UseBasicParsing -Uri 'https://developer.microsoft.com/microsoft-edge/webview2').Content
$Runtimes = [regex]::Matches($Content, "https?://[^\s`"']*?(\d+(?:\.\d+)+)[^\s`"']*?\.cab\b")

$Version = (($Runtimes | Sort-Object { [version]$_.Groups[1].Value })[-1]).Groups[1].Value
$Uris = ($Runtimes | Where-Object { $_.Groups[1].Value -contains "$Version" }).Value

<#
    - Filter for the latest version of WebView2.
#>

Write-Host "WebView2 Version: $Version"
if ($Version -eq (Get-Content "bucket\webview2.json" | ConvertFrom-Json)."version") {
    Write-Host "WebView2 manifest & remote versions match, no need to update."
    break
}

<#
    - Filter, display & resolve URIs & paths.
#>

$X64Uri = $Uris | Where-Object { $_ -like "*x64.cab" }
$X86Uri = $Uris | Where-Object { $_ -like "*x86.cab" }
$ARM64Uri = $Uris | Where-Object { $_ -like "*arm64.cab" }

$X64Path = [System.IO.Path]::ChangeExtension((Split-Path -Path $([uri]::new($X64Uri).LocalPath) -Leaf), ".7z")
$X86Path = [System.IO.Path]::ChangeExtension((Split-Path -Path $([uri]::new($X86Uri).LocalPath) -Leaf), ".7z")
$ARM64Path = [System.IO.Path]::ChangeExtension((Split-Path -Path $([uri]::new($ARM64Uri).LocalPath) -Leaf), ".7z")

Write-Host "`nx64:`n`tUri: $X64Uri`n`tFile: $X64Path"
Write-Host "`nx86:`n`tUri: $X86Uri`n`tFile: $X86Path"
Write-Host "`nARM64:`n`tUri: $ARM64Uri`n`tFile: $ARM64Path`n"

<#
    - We can't use Scoop's `CheckVer` hence resolve hashes manually.
#>

curl.exe -#L "$X64Uri" -o "$ENV:TEMP\$X64Path"
$X64Hash = (Get-FileHash -Path "$ENV:TEMP\$X64Path" -Algorithm SHA256).Hash

curl.exe -#L "$X86Uri" -o "$ENV:TEMP\$X86Path"
$X86Hash = (Get-FileHash -Path "$ENV:TEMP\$X86Path" -Algorithm SHA256).Hash

curl.exe -#L "$ARM64Uri" -o "$ENV:TEMP\$ARM64Path"
$ARM64Hash = (Get-FileHash -Path "$ENV:TEMP\$ARM64Path" -Algorithm SHA256).Hash

Write-Host "`nX64:`n`tHash: $X64Hash`n"
Write-Host "`nX86:`n`tHash: $X86Hash`n"
Write-Host "`nARM64:`n`tHash: $ARM64Hash`n"

<#
    - Finally plug everything into a manifest.
#>

$Manifest = @{
    "notes"        = @(
        'To troubleshoot any issues, visit:'
        'https://github.com/Aetopia/scoop-webview2#troubleshooting'
    )
    "version"      = $Version 
    "license"      = "Freeware"
    "homepage"     = "https://developer.microsoft.com/microsoft-edge/webview2"
    "description"  = "Provides a fully portable install of Microsoft Edge WebView2."
    "architecture" = @{
        "64bit" = @{
            "hash" = $X64Hash
            "url"  = "$X64Uri#/$X64Path" 
        }
        "32bit" = @{
            "hash" = $X86Hash
            "url"  = "$X86Uri#/$X86Path"  
        }
        "arm64" = @{
            "hash" = $ARM64Hash
            "url"  = "$ARM64Uri#/$ARM64Path"  
        }
    }
    "installer"    = @{
        "script" = 
        @(
            '$path = "$dir\$([System.IO.Path]::GetFileNameWithoutExtension($fname))"'           
            'Move-Item "$path\*" "$dir" -Force'
            'Remove-Item "$path" -Recurse -Force'
            'reg.exe add "HKCU\SOFTWARE\Microsoft\EdgeUpdate\ClientState\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v "EBWebView" /t "REG_SZ" /d "$dir" /f | Out-Null'
        )
    }
    "pre_install"  = 'if ($Global) { error; break }'
    "uninstaller"  = @{ "script" = 'reg.exe delete "HKCU\SOFTWARE\Microsoft\EdgeUpdate\ClientState\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /f | Out-Null' }
}

Set-Content -Path "bucket\webview2.json" -Value $($Manifest | ConvertTo-Json -Depth 100)

git.exe add "bucket\webview2.json"
git.exe commit -m "$Version"
git push origin main