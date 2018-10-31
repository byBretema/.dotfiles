
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
"

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
function ll { (Get-ChildItem -Force $args).Name}
function hrm { Remove-Item -Force -Recurse}
function noff { shutdown /a }
function me { net user ${env:UserName} }
function devices { sudo mmc devmgmt.msc }
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
		$name = $_;
		gci -r $_.FullName | measure-object -property length -sum |
			select `
		@{ Name = "Name"; Expression = {$name} },
		@{ Name = "Sum (MB)"; Expression = {"{0:N3}" -f ($_.sum / 1MB) } },
		@{ Name = "Sum(Bytes)"; Expression = {$_.sum} }
	} | sort "Sum(Bytes)" -desc
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
function gitit { chrome.exe --disable-logging "$($(git remote -v).Split()[1])" }
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
function gostart ([String]$vcs, [String]$projectName) {
	if ($vcs -eq "lab") {
		$vcsFolder = "gitlab.com"
	} elseif ($vcs -eq "hub") {
		$vcsfolder = "github.com"
	}
	$projectFolder = "$env:GOPATH/src/$vcsFolder/$projectName"
	if (-not (Test-Path $projectFolder)) {
		New-Item -ItemType Directory $projectFolder
	}
	Set-Location $projectFolder
	code $projectFolder
}

function cc {
	$out = (Get-Item $PWD).Name
	$files = $(Get-ChildItem *.c, *.cc, *.cpp)
	g++ -I. -std='c++17' -fopenmp -O6 -Wall $files $args -o $out
	if (Test-Path ".\$out.exe") { & ".\$out.exe"; Remove-Item ".\$out.exe"}
}


# ========================================================================== #


# PROMPT
function _Prompt {
	$lastStatus = (":`(", ":)")[${?}]
	Write-Prompt "`n"
	Write-Prompt " ${pwd} " -ForegroundColor White
	if ($gst = (Get-GitStatus)) {
		$gitStr += "($($gst.Branch)) "
		$work = ($gst.AheadBy -or $gst.BehindBy -or $gst.HasWorking)
		Write-Prompt $gitStr -ForegroundColor ("Green", "Red")[$work]
	}
	Write-Prompt "$lastStatus" -ForegroundColor White
	return "` ` "
}

function Prompt {
	# $lastStatus = ("‼", "♥")[${?}]
	$lastStatus = ("<", ">")[${?}]
	# Pwd, where am I? 1/2
	$pwdPath = $PWD.Path -split "\\"
	Write-Prompt "[$($pwdpath[0][0])] " -ForegroundColor DarkGray
	# Git, is there a repository?
	if ($gst = (Get-GitStatus)) {
		$gitStr += "($($gst.Branch)) "
		$work = ($gst.AheadBy -or $gst.BehindBy -or $gst.HasWorking)
		Write-Prompt $gitStr -ForegroundColor ("Green", "Red")[$work]
	}
	# Pwd, where am I? 2/2
	Write-Prompt "$($pwdpath[-1]) " -ForegroundColor White
	# Prev command works?
	Write-Prompt "$lastStatus " -ForegroundColor White
	return "` "
}

# ========================================================================== #


# FIX UPDATES
function fixWindowsUpdate {
	#* Tasks
	@("usbceip", "microsoft", "consolidator", "silentcleanup",
		"dmclient", "scheduleddefrag", "office", "adobe") | ForEach-Object {
		$(Get-ScheduledTask -TaskName "*$_*") | ForEach-Object {
			Disable-ScheduledTask $_
		}
	}

	#* Telemetry
	Set-Service DiagTrack -StartupType Disabled
	Set-Service PcaSvc -StartupType Disabled
	Set-Service "Micro Star SCM" -StartupType Disabled
	# Set-Service "Killer Network Service" -StartupType Disabled
	Set-Service dmwappushservice -StartupType Disabled
	New-ItemProperty -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -name "AllowTelemetry " -PropertyType DWORD -value 0 -Force
}


# ========================================================================== #

# Avoid duplicates
Set-PSReadLineOption -HistoryNoDuplicates:$True

# Do not use UserProfile as main folder
if ($PWD.Path -eq ${env:UserProfile}) { Set-Location "$env:SystemDrive\DAC" }
