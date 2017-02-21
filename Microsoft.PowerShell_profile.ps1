
### --------------------------------- LOAD -------------------------------- ###

# Avoid "Microsoft Copyright spam"!
Clear-Host

# Git info.
Import-Module posh-git

# Hack consoleZ "open in the same directory"

$currentPath = "$env:USERPROFILE\currentPath.txt"
$previousPath = "$env:USERPROFILE\previousPath.txt"

if( Test-Path $currentPath ) {
    Get-Content $currentPath | Set-Location
}

# Hack for use GUI linux apps via Docker.
# Requires Xming or similar. ( xming -ac -multiwindow -clipboard )
$NetInfo = [System.Net.Dns]::GetHostAddresses("$env:computername")
$HostIP = $NetInfo[4].IPAddressToString
$DISPLAY = $HostIP+":0"

### -------------------------------- PROMPT ------------------------------- ###

function prompt {

    # Hack consoleZ "open in the same directory"
    Get-Content $currentPath | Out-File $previousPath
    (Get-Location).Path | Out-File $currentPath

    # Title Vars...
    $usu = $env:username
    $dom = $env:userdomain
    # Write title...
    $host.UI.RawUI.WindowTitle = "[$usu] @ $dom"

    # Prompt Vars...
    $cd = (Get-Location).Path
    $time = (Get-Date).ToLongTimeString()
    if(Get-GitStatus) { $sep = "`n " } else { $sep = " " }
    # Write prompt...
    Write-Host ""
    Write-Host "$(Write-VcsStatus)" -NoNewline
    Write-Host "$sep" -NoNewline
    Write-Host "[" -ForegroundColor Gray -NoNewline
    Write-Host "$time" -ForegroundColor Magenta -NoNewline
    Write-Host "]" -ForegroundColor Gray -NoNewline
    Write-Host " @ " -ForegroundColor Gray -NoNewline
    Write-Host "[" -ForegroundColor Gray -NoNewline
    Write-Host "$cd" -ForegroundColor Blue -NoNewline
    Write-Host "]" -ForegroundColor Gray
    Write-Host " >" -ForegroundColor White -NoNewline
    "` "
}

### ------------------------------ FUNCTIONS ------------------------------ ###

# QuickGitPush: the args are the string to commit.
function qgp {
    git add -A
    git commit -m "$args"
    git push
}

# Alias to git status resume and branch indicator.
function gst { git status -sb }

# Hack powershell 'ls' with git bash binaries.
function l { ls.exe -AFGh --color --group-directories-first }
function ll { ls.exe -AFGhl --color --group-directories-first }
function lt { ls.exe -AFGhlR --color --group-directories-first }

# bd: goto previous directory.
function bd {
    if( Test-Path $previousPath ) {
        Get-Content $previousPath | Set-Location
    }
}

# Open explorer windows on current directory.
function oo { explorer (Get-Location).Path }

# Quick access to home directory.
function ho { Set-Location $env:userprofile }

### ------------------------------- CHOCO --------------------------------- ###

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if ( Test-Path $ChocolateyProfile ) {
  Import-Module "$ChocolateyProfile"
}
