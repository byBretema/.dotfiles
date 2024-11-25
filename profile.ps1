
# Written with <3 by Daniel (@byBretema)

###############################################################################
### PREREQUISITes
###############################################################################

# winget install --id Starship.Starship -e


###############################################################################
### GLOBAL STUFF
###############################################################################

function path_to_unix([string]$path) {
	return "$path".Replace("\", "/")
}

$dev_dir = path_to_unix "${env:UserProfile}/dev";


###############################################################################
### PATHs
###############################################################################

# Scoop
Get-ChildItem "${env:userprofile}/scoop/apps/" -ErrorAction SilentlyContinue |
ForEach-Object { "$_/current" } | ForEach-Object { $p = $_; $env:PATH += ";$p;$p/bin" }

# VcPkg
$env:VCPKG_ROOT = "${env:SystemDrive}/vcpkg";

# Path
$env:PATH += ";${env:VCPKG_ROOT}"
$env:PATH += ";${env:userprofile}/scoop/shims"
$env:PATH += ";${env:ProgramFiles}/starship/bin"
$env:PATH += ";${dev_dir}/_bin/"
$env:PATH += ";${dev_dir}/_bin/Odin"
$env:PATH = path_to_unix ${env:PATH}

# Python
$env:PYTHONPATH = path_to_unix ${env:PYTHONPATH}

# PS Modules
$env:psmodulepath += ";$env:userprofile/scoop/modules"
$env:psmodulepath = path_to_unix ${env:psmodulepath}


###############################################################################
### ALIASes
###############################################################################

# Discard aliases (https://github.com/bmatzelle/gow)
@("md", "cls", "awk", "basename", "bash", "bc", "bison", "bunzip2", "bzip2", "bzip2recover", "cat", "chgrp", "chmod",
	"chown", "chroot", "cksum", "clear", "cp", "csplit", "curl", "cut", "dc", "dd", "df", "diff", "diff3", "dirname",
	"dos2unix", "du", "egrep", "env", "expand", "expr", "factor", "fgrep", "flex", "fmt", "fold", "gawk", "gfind",
	"gow", "grep", "gsar", "gsort", "gzip", "head", "hostid", "hostname", "id", "indent", "install", "join", "jwhois",
	"less", "lesskey", "ln", "ls", "m4", "make", "md5sum", "mkdir", "mkfifo", "mknod", "mv", "nano", "ncftp", "nl",
	"od", "pageant", "paste", "patch", "pathchk", "plink", "pr", "printenv", "printf", "pscp", "psftp", "putty",
	"puttygen", "pwd", "rm", "rmdir", "scp", "sdiff", "sed", "seq", "sftp", "sha1sum", "shar", "sleep", "split", "ssh",
	"su", "sum", "sync", "tac", "tail", "tar", "tee", "test", "touch", "tr", "uname", "unexpand", "uniq", "unix2dos",
	"unlink", "unrar", "unshar", "uudecode", "uuencode", "vim", "wc", "wget", "whereis", "which", "whoami", "xargs",
	"yes", "zip") | ForEach-Object { if (Test-Path alias:$_) { Remove-Item -Force alias:$_ } }

# List dir
function ls { eza -a  --icons always --git -s type $args }
function l { eza -a  --icons always --git -s type $args }
function ll { eza -la --icons always --git -s type $args }
function tree { eza -Ta --icons always --git -s type $args }

# Location management
Set-Alias pul Push-Location
Set-Alias pol Pop-Location
function treeup ([int]$jumps) {
	for ( $i = 0; $i -lt $jumps; $i++) { Set-Location .. }
}

# Folders creation
function md {
	New-Item -ItemType Directory $args[0]; Set-Location $args[0]
}

# Choco always as admin
function choco { "sudo `"${env:ChocolateyInstall}/bin/choco.exe`" $args" | Invoke-Expression }

# Clear and list
function k { Clear-Host; ll }

# Start process
Set-Alias o Start-Process

# Open current dir on explorer
function oo {
	Param ( [Parameter(Mandatory = $false)] [string]$path = "." )
	explorer $path
}

# Soft/Symbolic link
function lns ([string]$from, [string]$to) {
	$null = New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force
}

# Windows whoami
function me { net user ${env:UserName} }

# Run last command as admin
# function aaa { sudo -plz }

# Open devices manager
function devices { mmc devmgmt.msc }

# Kill explorer
function ke { Stop-Process (Get-Process explorer).id }

# Shutdown and cancell
function off { shutdown /hybrid /s /t $($args[0] * 60) }
function noff { shutdown /a }

# Bitlock
function bitlock { sudo manage-bde.exe -lock $args[0] }
function bitunlock { sudo manage-bde.exe -unlock $args[0] -pw }


###############################################################################
### UTILs
###############################################################################

# Download to temp file
function download_to_temp ([string]$url, [string]$filename, [string]$ext) {
	$tmp_file = path_to_unix "${env:TEMP}/${filename}.${ext}";
	if ($PSVersionTable.PSVersion.Major -lt 7) {
		$ProgressPreference = "SilentlyContinue"
	}
	Invoke-WebRequest -URI $url -OutFile $tmp_file;
	return $tmp_file
}

# Install a program from URL
function install_exe_from_url ([string]$url, [string]$filename) {
	& "$(download_to_temp $url $filename "exe")"
}

# Open git repo on the browser
function gitit {
	if (-not (Test-Path "./.git")) {
		Write-Output "fatal: not a git repository (or any of the parent directories): .git";
		return;
	}

	$http = ((((git remote -v)[0] -Split " ")[0] -Split "`t")[1])
	$ssh = ($http -Split "@")[1].Replace(":", "/")

	$ErrorActionPreference = "SilentlyContinue";
	try {
		Start-Process "https://$http"
	}
	catch {
		Start-Process "https://$ssh"
	}
}

# Search on Google
function s {
	if ($args) {
		Start-Process "https://www.google.com/search?q=$($args -join '+')"
	}
}

# Translatation CLI
function tr ([string]$to, [string]$text) {
	try {
		$Uri = “https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($to)&dt=t&q=$text”
		$Response = Invoke-RestMethod -Uri $Uri -Method Get
		$Translation = $Response[0].SyncRoot | ForEach-Object { $_[0] }
		Write-Output $Translation
	}
 catch {
		"[ERR] - Check values of | `$to = $to | `$text = $text"
	}
}

# Kill processes that match the name
function killp {
	Get-Process "*$args*" -ErrorAction Ignore | ForEach-Object { Write-Output "$($_.Id)    $($_.ProcessName)" };
	$toKill = Read-Host "PID to kill"
	Stop-Process $toKill
}

# Network info
function net_info {
	$pub = $(curl.exe -s icanhazip.com)
	$privW = $((Get-NetAdapter "Wi-Fi" | Get-NetIPAddress).IPAddress[1])
	Write-Host "IP (U/R):                 $pub / $privW"
	Write-Host "(8.8.8.8) time:       $((ping 8.8.8.8)[10])"
	Write-Host "(www.google.es) time: $((ping www.google.es)[10])"
	Write-Host "(www.google.com) time:$((ping www.google.com)[10])"
}

# Is ip alive?
function is_ip_alive {
	Param
	(
		[Parameter(Mandatory = $true)] [string]$ip,
		[Parameter(Mandatory = $false)] [Int32]$timeout_ms = 40
	)
	$(ping $ip -n 1 -w $timeout_ms -f -4 | Out-Null)
	return ("", $ip)[$LASTEXITCODE -eq 0]
}

# Interactive winget
function iwinget ([string]$inName) {
	$lines = winget search $inName

	# Gather indices
	$nameIdx = 0
	$nameLen = -1
	$idIdx = -1
	$idLen = -1
	$verIdx = -1
	$verLen = -1
	$firstContentRow = -1

	for ($lIdx = 0; $lIdx -lt $lines.Length; $lIdx++) {
		$l = $lines[$lIdx]

		if (-not $l.StartsWith("Name")) {
			continue
		}

		$firstContentRow = $lIdx + 2;

		for ($c = 0; $c -lt $l.Length - 1; $c++) {

			$s = "$($l[$c])$($l[$($c+1)])"

			if ($s -eq "Id") {
				$idIdx = $c
				$nameLen = $idIdx - $nameIdx
			}

			elseif ($s -eq "Ve") {
				$verIdx = $c
				$idLen = $verIdx - $idIdx
			}

			elseif (($s -eq "Ma") -or ($s -eq "So")) {
				$verLen = $c - $verIdx
			}
		}

		break
	}

	# Validate indices
	$idxs = @($nameLen, $idIdx, $idLen, $verIdx, $verLen)
	$idxsOk = $true;
	foreach ($idx in $idxs) {
		$idxsOk = $idxsOk -and $($idx -gt -1)
	}

	# Extract info
	$it0 = $firstContentRow
	$it = $firstContentRow

	$packages = New-Object System.Collections.Generic.List[System.Object]

	if (-not ( ($it -gt -1) -and ($it -lt $lines.Length) -and $idxsOk )) {
		Write-Output "No package found matching input criteria: '$inName'"
		return
	}

	for (; $it -lt $lines.Length; $it++) {

		$n = $($it - $it0)
		$nStr = "$n"
		if ($n -lt 10) { $nStr = "  " + $nStr }
		if (($n -gt 9) -and $n -lt 100) { $nStr = " " + $nStr }

		$pkgName = $lines[$it].Substring($nameIdx, $nameLen)
		$pkgId = $lines[$it].Substring($idIdx, $idLen)
		$pkgVer = $lines[$it].Substring($verIdx, $verLen)
		Write-Output "$nStr)  ID: $pkgId | Ver: $pkgVer | Name: $pkgName"

		$packages.Add($pkgId.Trim());
	}

	$toInstall = Read-Host ">> Enter index of package to install"
	try {
		$toInstallIdx = [int]$toInstall
	}
	catch {
		Write-Output "Bad index '$toInstall'."
		return;
	}

	$p = $packages[$toInstallIdx];
	Write-Output "!! Trying to install: '$p'"
	winget install -e --id $p --accept-package-agreements --accept-source-agreements --disable-interactivity --silent
}


###############################################################################
### AUTOCOMPLETes
###############################################################################

# z
Register-ArgumentCompleter -CommandName z -ScriptBlock {
	param($commandName, $parameterName, $wordToComplete)
	Search-NavigationHistory $commandName -List | ForEach-Object { $_.Path } | ForEach-Object {
		New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_,
		$_,
		"ParameterValue",
		$_
	}
}

# winget
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)
	[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
	$Local:word = $wordToComplete.Replace('"', '""')
	$Local:ast = $commandAst.ToString().Replace('"', '""')
	winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}


###############################################################################
### MODULES
###############################################################################

Import-Module z
Import-Module posh-git
Import-Module scoop-completion
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"


###############################################################################
### PWSH SETTINGS
###############################################################################

$env:POWERSHELL_TELEMETRY_OPTOUT = 1             # Avoid telemetry
Set-PSReadLineOption -HistoryNoDuplicates:$True  # Avoid duplicates


###############################################################################
### PROMPT
###############################################################################

$env:STARSHIP_CONFIG = path_to_unix "$home/.config/bretema/starship.toml";

if (-not (Test-Path $env:STARSHIP_CONFIG)) {
	$req = Invoke-WebRequest https://gist.githubusercontent.com/byBretema/e87e1d98a2b6d1aaf244c910a0d3d464/raw/;
	$req.Content > $home/.config/bretema_starship.toml
	New-Item -ItemType File -Path $env:STARSHIP_CONFIG
}

Invoke-Expression (&starship init powershell)
