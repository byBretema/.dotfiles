
###############################################################################
# Pre

# winget install --id Starship.Starship -e
# winget install --id eza-community.eza -e

###############################################################################
# Settings

$env:POWERSHELL_TELEMETRY_OPTOUT = 1             # Avoid telemetry
Set-PSReadLineOption -HistoryNoDuplicates:$True  # Avoid duplicates

if ($PSVersionTable.PSVersion.Major -lt 7) {
    $ProgressPreference = "SilentlyContinue"
}

###############################################################################
# Navigation

function ls   { eza -a  --icons always --git -s type $args }
function l    { eza -a  --icons always --git -s type $args }
function ll   { eza -la --icons always --git -s type $args }
function tree { eza -Ta --icons always --git -s type $args }

Set-Alias o Start-Process
function oo([string]$path = ".") { o $path }

###############################################################################
# Helpers

function _wget([string]$uri, [string]$out) {
    Invoke-WebRequest -UserAgent "Wget" -URI $uri -OutFile $out
}

function rmrf() {
    Remove-Item -Recurse -Force $args 2>$null
}

function download_to_temp([string]$url, [string]$name = "") {
	if ($name.Length -lt 1) { $name = $url.Split("/")[-1] }
	Write-Host "@ Downloading : $name"
	$tmp_file = "${env:TEMP}\$name"
    _wget $url $tmp_file
	return $tmp_file
}

function install_exe_from_url([string]$url, [string]$filename) {
	& "$(download_to_temp $url $filename "exe")"
}

function unzip([string]$path) {
    $folder = "${path}_unzip"
    Write-Host "@ Unzip : $folder"
    rmrf $folder
    $null = Start-Process -FilePath "${env:ProgramFiles}\7-Zip\7zG.exe" -ArgumentList "x `"$path`" -o`"$folder`" -aou" -PassThru -Wait
    Start-Process $folder
}

function lns([string]$from, [string]$to) {
	$from = path_to_windows $from
	$to = path_to_windows $to
	Write-Host "@ Linking : $from to $to"
	$null = New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force
}

function trash([string]$path) {
	$path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("$path")
	$shell = New-Object -comobject "Shell.Application"
	$item = $shell.Namespace(0).ParseName("$Path")
	$item.InvokeVerb("delete")
}

###############################################################################
# Prompt: Starship

$starship_config = "$HOME/.config/starship"
if (-not (Test-Path $starship_config)) {
    mkdir $starship_config
}

$env:STARSHIP_CONFIG = "$starship_config/starship.toml";
if (-not (Test-Path $env:STARSHIP_CONFIG)) {
    $url = "https://raw.githubusercontent.com/byBretema/.dotfiles/refs/heads/main/configs/starship.toml"
    _wget $url $env:STARSHIP_CONFIG
}

Invoke-Expression (&starship init powershell)
