
# Write with <3 by Dac. (@cambalamas)

# ENV
$PERSONALPATH = "${env:SystemDrive}\DAC"
$DEVPATH = "$PERSONALPATH\DEV"
$env:GOPATH = "$DEVPATH\go"
$env:GOBIN = "$DEVPATH\go\bin"
$env:PATH += ";`
	${env:GOBIN};`
	${env:ProgramFiles}\VCG\MeshLab\;`
	${env:ProgramFiles}\Unity\Hub\Editor\;`
	${env:userprofile}\scoop\apps\xming\current;`
	${env:ProgramFiles(x86)}\Google\Chrome` Dev\Application;`
	${env:ProgramFiles}\OpenSSL-Win64\bin;`
	${env:userprofile}\AppData\Local\.meteor;`
	${env:userprofile}\scoop\apps\python\current\Scripts;`
	$PERSONALPATH\.bin;`
"

# Remove aliases of 'gow' (https://github.com/bmatzelle/gow)
@("awk", "basename", "bash", "bc", "bison", "bunzip2", "bzip2", "bzip2recover", "cat", "chgrp", "chmod", "chown", "chroot", "cksum", "clear", "cp", "csplit", "curl", "cut", "dc", "dd", "df", "diff", "diff3", "dirname", "dos2unix", "du", "egrep", "env", "expand", "expr", "factor", "fgrep", "flex", "fmt", "fold", "gawk", "gfind", "gow", "grep", "gsar", "gsort", "gzip", "head", "hostid", "hostname", "id", "indent", "install", "join", "jwhois", "less", "lesskey", "ln", "ls", "m4", "make", "md5sum", "mkdir", "mkfifo", "mknod", "mv", "nano", "ncftp", "nl", "od", "pageant", "paste", "patch", "pathchk", "plink", "pr", "printenv", "printf", "pscp", "psftp", "putty", "puttygen", "pwd", "rm", "rmdir", "scp", "sdiff", "sed", "seq", "sftp", "sha1sum", "shar", "sleep", "split", "ssh", "su", "sum", "sync", "tac", "tail", "tar", "tee", "test", "touch", "tr", "uname", "unexpand", "uniq", "unix2dos", "unlink", "unrar", "unshar", "uudecode", "uuencode", "vim", "wc", "wget", "whereis", "which", "whoami", "xargs", "yes", "zip") | ForEach-Object { if (Test-Path alias:$_) { Remove-Item -Force alias:$_ } }

# MOVE
function dev { Set-Location "$DEVPATH" }
function k { Clear-Host; Get-ChildItem $args}
function ho { Set-Location $env:userprofile }
remove-item alias:md
function md { New-Item -ItemType Directory $args[0]; Set-Location $args[0]}
function b ([int]$jumps) { for ( $i = 0; $i -lt $jumps; $i++) { Set-Location .. } }
function oo { if ($args) {explorer $args[0] } else { explorer (Get-Location).Path } }
function lns([string]$to, [string]$from) {New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force}


# SYS
# remove-item alias:rm
function l { ls -ALph $args}
function ll { ls -ALphog $args}
function hrm { Remove-Item -Force -Recurse}
function noff { shutdown /a }
function me { net user ${env:UserName} }
function devices { mmc devmgmt.msc }
function ke { Stop-Process (Get-Process explorer).id }
function bitLock { sudo manage-bde.exe -lock $args[0] }
function off { shutdown /hybrid /s /t $($args[0] * 60) }
function bitUnlock { sudo manage-bde.exe -unlock $args[0] -pw }
function bg { Start-Process powershell -NoNewWindow "-Command $args" }
function eposh { code $profile }
function ehyper { code "${env:UserProfile}\.hyper.js" }
function iconFind ([String]$icon) { for ($i = 0; $i -le 65535; $i++) { if ( [char]$i -eq $icon ) { Write-Host $i } } }
function top {
	Clear-Host
	$saveY = [console]::CursorTop
	$saveX = [console]::CursorLeft
	while ($true) {
		Get-Process | Sort-Object -Descending CPU | Select-Object -First 30
		Start-Sleep -Seconds 2
		[console]::setcursorposition($saveX, $saveY + 3)
	}
}
function du {
	Get-ChildItem $pwd | ForEach-Object {
		$name = $_
		Get-ChildItem -r $_.FullName | measure-object -property length -sum |
			Select-Object `
		@{ Name = "Name"; Expression = {$name} },
		@{ Name = "Sum (MB)"; Expression = {"{0:N3}" -f ($_.sum / 1MB) } },
		@{ Name = "Sum(Bytes)"; Expression = {$_.sum} }
	} | Sort-Object "Sum(Bytes)" -desc
}
function sudop {
	sudo powershell
}

# NET
function s { Start-Process "https://www.google.com/search?q=$($args -join '+')" }
function netinfo {
	$pub = $(curl.exe -s icanhazip.com)
	$privW = $((Get-NetAdapter "Wi-Fi" | Get-NetIPAddress).IPAddress[1])
	Write-Host "IP (U/R):                 $pub / $privW"
	Write-Host "(8.8.8.8) time:       $((ping 8.8.8.8)[11])"
	Write-Host "(www.google.es) time: $((ping www.google.es)[11])"
	Write-Host "(www.google.com) time:$((ping www.google.com)[11])"
}


# ========================================================================== #


# DOCKER
function x11 { xming -ac -multiwindow -clipboard }
function whale { if ($args) { x11; docker run -v "$((Get-Location).path):/app" -e DISPLAY=$(display) -it $args } }
function display { (Get-NetAdapter "vEthernet (DockerNAT)" | Get-NetIPAddress -AddressFamily "IPv4").IPAddress + ":0" 2> $null }

# GIT
function gpl { git pull }
function gft { git fetch }
function gst { git status -sb }
function glg { git log --graph --oneline --decorate }
function qgp { if ($args) { git add -A; git commit -m "$args"; git push } }
function gitit { Start-Process "$($(git remote -v).Split()[1])" }
function gitb { if ($args[0]) { git checkout -b "$args[0]"; git push origin "$args[0]" } }
function qgfp { git init; git add -A; git commit -m "first commit"; git remote add origin $args[0]; git push -u origin master}
function loc { if ($args[0]) { (Get-ChildItem * -recurse -include *.$($args[0]) | Get-Content | Measure-Object -Line).Lines } }

# GO
$env:GOOS = "windows"
$env:GOARCH = "amd64"
function gor { go run $(Get-ChildItem *.go).Name $args }
function goget { if ($args[0]) { go get -v -u $args[0] } }
function gowin { gobuild("windows") }
function gomac { gobuild("darwin") }
function gonix { gobuild("linux") }
function godroid { gobuild("android") }
function gobuild ([String]$os) {
	if ($os -eq "android") { $arch = "arm" } else { $arch = "amd64" }
	$env:GOOS = $os
	$env:GOARCH = $arch
	Write-Host "Compiling project for `"${env:GOOS}`" on `"${env:GOARCH}`"..."
	go build
}
function gostart_old ([String]$vcs, [String]$projectName) {
	if ($vcs -eq "lab") {
		$vcsFolder = "gitlab.com"
	}
	elseif ($vcs -eq "hub") {
		$vcsfolder = "github.com"
	}
	$projectFolder = "$env:GOPATH/src/$vcsFolder/$projectName"
	if (-not (Test-Path $projectFolder)) {
		New-Item -ItemType Directory $projectFolder
	}
	Set-Location $projectFolder
	code $projectFolder
}

# C++
function cc {
	$out = (Get-Item $PWD).Name
	$files = $(Get-ChildItem *.c, *.cc, *.cpp)
	g++ -I. -std='c++17' -fopenmp -O6 -Wall $files $args -o $out
	if (Test-Path ".\$out.exe") { & ".\$out.exe"; Remove-Item ".\$out.exe"}
}

# CARBON-NOW-SH : 'npm i -g carbon-now-cli'.
# '-i' to setup your preset
# '-o' to open img on photos
# '--clear' remove all imgs from the folder
# '--path' open the path of imgs
function Carbon {
	$path = "${env:LOCALAPPDATA}\CarbonNow\"
	$file = "$path\carbon.data"
	$imgName = $(Get-Date).Ticks
	$imgPath = "$path$imgName.png"
	# Clear
	if(($args[0] -eq "--clear") -or ($args[1] -eq "--clear")) {
		Remove-Item "$path/*.png"
		return
	}
	# Open path
	if(($args[0] -eq "--path") -or ($args[1] -eq "--path")) {
		Invoke-Item $path
		return
	}
	# System files
	if (-not(Test-Path $path)) { mkdir $path > $null }
	Set-Content $file $(Get-Clipboard) > $null
	# API call
	if($args[0] -eq "-i") { carbon-now.cmd $file -i -l $path -t $imgName -h}
	else { carbon-now.cmd $file -l $path -t $imgName -h }
	# Copy image to clipboard
	[Reflection.Assembly]::LoadWithPartialName('System.Drawing') > $null
	[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') > $null
	if (Test-Path($imgPath)) {
		$rawImg = [System.Drawing.Image]::Fromfile("$(Get-Item($imgPath))");
		[System.Windows.Forms.Clipboard]::SetImage($rawImg);
	} else { Write-Output "[NOT FOUND] --> $imgPath" }
	# Maybe you wanna open the img to see it
	if(($args[0] -eq "-o") -or ($args[1] -eq "-o")) {
		Start-Process $imgPath
	}
}

function LiveNgrok {
	$name = "LiveNgrok"
	$job = (Get-Job LiveNgrok -ErrorAction SilentlyContinue)
	$mayCreateJob = -not($job) -or ($job.Count -lt 1  -and  $job.State -eq "Running")
	if($mayCreateJob){ Start-Job -name $name { & "ngrok" http 5500 } > $null }
	& ngrok2telegram.exe
}

function CancelAllJobs {
	Stop-Job *
	Remove-Job *
}

# ========================================================================== #


# PROMPT
$env:promptOrientation = "h";
$env:promptNewLine = $false;
# function togglePromptOrientation(){
# 	$env:promptOrientation = ("v","h")[$env:promptOrientation -eq "h"];
# }
# function togglePrompNewLine(){
# 	$env:promptNewLine = (-not ${env:promptNewLine})
# }

function Prompt {

	$last = ${?}
	$lastColor = ("Red", "Yellow")[$last] # F / T
	$lastStr = ([char]8252, [char]9829)[$last] # F:‼ / T:♥
	function __SEPARATOR__ { Write-Prompt " | " -ForegroundColor DarkGray }
	# Pwd, where am I?
	$currFolder = ($PWD.Path -split '\\')[-1]
	$lineInit = ("","`n ")[$env:promptNewLine -eq $true]
	Write-Prompt "$lineInit$currFolder" -ForegroundColor White
	__SEPARATOR__
	# TimeStamp
	Write-Prompt $(Get-Date -Format T) -ForegroundColor Cyan
	# Git, is there a repository?
	if ($gst = (Get-GitStatus)) {
		$work = ($gst.AheadBy -or $gst.BehindBy -or $gst.HasWorking)
		__SEPARATOR__
		Write-Prompt $gst.Branch -ForegroundColor ("Green", "Magenta")[$work]
	}
	# Prev command works?
	if($env:promptOrientation -eq "v"){
		Write-Prompt "`n$lastStr" -ForegroundColor $lastColor
	} else {
		__SEPARATOR__
		Write-Prompt "$lastStr" -ForegroundColor $lastColor
	}
	Write-Prompt " $([char]9658)" -ForegroundColor DarkGray
	return "` "
}

# ========================================================================== #


# FIX UPDATES
function fixWindowsUpdate {
	#* Tasks
	@("usbceip", "microsoft", "consolidator", "silentcleanup",
		"dmclient", "scheduleddefrag", "office", "adobe") | ForEach-Object {
		$(Get-ScheduledTask -TaskName "*$_*") | ForEach-Object {
			Disable-ScheduledTask $_ 2> $null
		}
	}
	#* Services
	@("DiagTrack", "PcaSvc", "Micro Star SCM", "dmwappushservice") | ForEach-Object {
		Set-Service $_ -StartupType Disabled
	}
	#* Not allow telemetry
	New-ItemProperty -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -name "AllowTelemetry " -PropertyType DWORD -value 0 -Force
}


# ========================================================================== #

# Avoid duplicates
Set-PSReadLineOption -HistoryNoDuplicates:$True

# Do not use UserProfile as main folder
if ($PWD.Path -eq ${env:UserProfile}) { Set-Location "$env:SystemDrive\DAC" }
