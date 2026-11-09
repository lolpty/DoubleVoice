[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ServerDirectory,
    [string]$PublicHost = '',
    [ValidateRange(1,65535)][int]$PublicPort = 24454,
    [ValidateRange(0,65535)][int]$BindPort = 0
)
$ErrorActionPreference = 'Stop'
$serverPath = (Resolve-Path -LiteralPath $ServerDirectory).Path
if (-not (Test-Path -LiteralPath (Join-Path $serverPath 'server.properties'))) {
    throw 'Choose a server directory containing server.properties. Stop the server before configuration.'
}
$PublicHost = $PublicHost.Trim()
if ($PublicHost -match ':') {
    $parsedAddress = $null
    if (-not [System.Net.IPAddress]::TryParse($PublicHost.Trim('[',']'), [ref]$parsedAddress)) {
        throw 'PublicHost must be an IP or DNS name without a port or URL scheme.'
    }
    $PublicHost = $parsedAddress.ToString()
} elseif ($PublicHost -notmatch '^[a-zA-Z0-9.-]*$') { throw 'PublicHost must be an IP or DNS name, or empty for automatic detection.' }
$listenPort = if ($BindPort -eq 0) { $PublicPort } else { $BindPort }
$advertisedPort = if ($listenPort -eq $PublicPort) { 0 } else { $PublicPort }
$path = Join-Path $serverPath 'plugins/DoubleVoice/config.yml'
$content = ''
if (Test-Path -LiteralPath $path) { $content = [System.IO.File]::ReadAllText($path) }
if ([string]::IsNullOrWhiteSpace($content)) {
    $template = Join-Path $PSScriptRoot '../src/main/resources/config.yml'
    if (-not (Test-Path -LiteralPath $template)) { $template = Join-Path $PSScriptRoot '../config/config.yml' }
    $content = [System.IO.File]::ReadAllText([System.IO.Path]::GetFullPath($template))
}
function Set-Section([string]$Content, [string]$Section, [hashtable]$Values) {
    $lines = New-Object 'System.Collections.Generic.List[string]'
    foreach ($line in ($Content -split '\r?\n')) { $lines.Add($line) }
    $start = -1; $end = $lines.Count
    for ($i=0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match ('^' + [regex]::Escape($Section) + ':\s*(?:#.*)?$')) { $start = $i; continue }
        if ($start -ge 0 -and $lines[$i] -match '^[a-zA-Z][^:]*:') { $end = $i; break }
    }
    if ($start -lt 0) { $lines.Add("${Section}:"); $start = $lines.Count - 1; $end = $lines.Count }
    foreach ($key in $Values.Keys) {
        $found = $false
        for ($i=$start+1; $i -lt $end; $i++) {
            if ($lines[$i] -match ('^  ' + [regex]::Escape($key) + ':')) {
                if ($null -eq $Values[$key]) { $lines.RemoveAt($i); $i--; $end-- }
                else { $lines[$i] = "  ${key}: $($Values[$key])" }
                $found = $true
            }
        }
        if (-not $found -and $null -ne $Values[$key]) { $lines.Insert($end, "  ${key}: $($Values[$key])"); $end++ }
    }
    return $lines -join "`n"
}
$preferred = 'simple'
if ($content -match '(?m)^  preferred:\s*["'']?(simple|plasmo)') { $preferred = $Matches[1] }
elseif ($content -match '(?m)^  preferred-client:\s*["'']?(simple|plasmo)') { $preferred = $Matches[1] }
$simpleSupport = 'true'; $plasmoSupport = 'true'
if ($content -match '(?m)^  simple:\s*(true|false)') { $simpleSupport = $Matches[1] }
if ($content -match '(?m)^  plasmo:\s*(true|false)') { $plasmoSupport = $Matches[1] }
$content = $content -replace '(?m)^# Настрой исходные плагины по README\.md до запуска\.', '# Самостоятельный DoubleVoice: один JAR, один UDP-порт.'
$content = $content -replace '(?m)^  # Чужие приватные активации[^\r\n]*(?:\r?\n|$)', ''
$content = Set-Section $content 'network' @{
    port = "$listenPort"; 'public-host' = "'$PublicHost'"; 'public-port' = "$advertisedPort"
    'simple-port' = $null; 'plasmo-port' = $null; 'max-sessions' = $null; 'max-sessions-per-ip' = $null; 'idle-seconds' = $null
}
$content = Set-Section $content 'clients' @{ simple = $simpleSupport; plasmo = $plasmoSupport; preferred = $preferred }
$content = Set-Section $content 'voice' @{ 'preferred-client' = $null; 'plasmo-activations' = $null }
[System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($path)) | Out-Null
if (Test-Path -LiteralPath $path) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
    Copy-Item -LiteralPath $path -Destination "$path.doublevoice-$stamp.bak"
}
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($path, $content.TrimEnd() + "`n", $utf8)
Write-Host "Configured standalone DoubleVoice: UDP bind=$listenPort, public=$PublicPort, host='$PublicHost' (empty=automatic)."
Write-Host 'Only plugins/DoubleVoice/config.yml was changed. Remove old server voicechat/PlasmoVoice JARs before starting.'
