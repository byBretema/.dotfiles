# Made with ??? by cambalamas.

### --------------------------------- VARS -------------------------------- ###

# A unix friendly var to select your favorite editor.
$EDITOR = "C:\Program Files\Sublime Text 3\subl.exe"
$env:EDITOR = $EDITOR

# Hack for use GUI linux apps via Docker.
# Requires Xming or similar. ( xming -ac -multiwindow -clipboard )
$NetInfo = [System.Net.Dns]::GetHostAddresses("$env:computername")
$HostIP = $NetInfo[4].IPAddressToString
$DISPLAY = $HostIP+":0"
$env:DISPLAY = $DISPLAY

### --------------------------------- LOAD -------------------------------- ###

# Avoid "Microsoft Copyright spam"!
Clear-Host

# Git info.
Import-Module posh-git

# Hack consoleZ "open in the same directory"
$currentPath = "$env:USERPROFILE\currentPath.txt"
$previousPath = "$env:USERPROFILE\previousPath.txt"
if ( Test-Path $currentPath ) {
    Get-Content $currentPath | Set-Location
}

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
    if ( Get-GitStatus ) { $sep = "`n " } else { $sep = " " }
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

### ---------------------------- POSH ALIAS ------------------------------- ###

if ( -Not $(Get-Alias -name e 2>$null) ) { New-Alias e $EDITOR }

Remove-Item alias:ls
Remove-Item alias:rm
Remove-Item alias:mv
Remove-Item alias:cp
Remove-Item alias:cat
Remove-Item alias:man
Remove-Item alias:wget
Remove-Item alias:echo
Remove-Item alias:curl

### ------------------------------ FUNCTIONS ------------------------------ ###

# QuickGitPush: the args are the string to commit.
function qgp {
    git add -A
    git commit -m "$args"
    git push
}

# Alias to git status resume and branch indicator.
function gst { git status -sb }

# ZSH GitIt poor imitation. Works bad for ssh.
function gitit {
    $chrome = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
    Start-Process $chrome "$(git remote -v | gawk '{print $2}' | head -1)"
}

# Hack powershell 'ls' with git bash binaries.
function ls { ls.exe --color $args}
function l { ls.exe -AFGh --color $args}
function ll { ls.exe -AFGhl --color $args}
function lt { ls.exe -AFGhlR --color $args}

# bd: goto previous directory.
function bd {
    if ( Test-Path $previousPath ) {
        Get-Content $previousPath | Set-Location
    }
}

function netinfo {
    Write-Host ""
    Write-Host "IP privada:           $HostIP"
    Write-Host "IP publica:           $(curl.exe -s icanhazip.com)"
    Write-Host "---------------------------------------------------------------"
    Write-Host "IP time:         $((ping 8.8.8.8)[11])"
    Write-Host "DNS local time:  $((ping www.google.es)[11])"
    Write-Host "DNS foreign time:$((ping www.google.com)[11])"
}

# choco search install and update with -fyr flags by default.
function chof { choco info $args }
function chos { choco search $args }
function chou { choco upgrade -fyr all }
function chol { choco list --local-only }
function choi { choco install -fyr $args }

# scoop search install and update easier aliases.
function scoops { scoop search $args }
function scoopi { scoop install -a 64bit $args }
function scoopu { scoop update * ; scoop update * -q }

# system update.
function sysup { chou ; scoopu }

# Open explorer windows on current directory.
function oo { explorer (Get-Location).Path }

# Quick access to home directory.
function ho { Set-Location $env:userprofile }

# Avoid System32\find.exe use 'seek' to use scoop unix-like sane find.
function seek {
    "$env:userprofile\scoop\shims\find.exe $args 2>/null" | Invoke-Expression
}

# Quick edit to config files.
$h_vimrc     = "$env:userprofile\.vimrc"
$h_gitingore = "$env:userprofile\.gitignore"
$h_gitconfig = "$env:userprofile\.gitconfig"
$h_consoleZ  = "$ConsoleZSettingsDir\console.xml"
$h_profile   = "$env:userprofile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
function qe {
    switch ($args[0]) {
        "vim"  { subl $h_vimrc }
        "posh" { subl $h_profile}
        "z"    { subl $h_consoleZ }
        "git"  { subl $h_gitconfig ; subl $h_gitingore }
        default { }
    }
}

### ------------------------------- CHOCO --------------------------------- ###

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if ( Test-Path $ChocolateyProfile ) {
  Import-Module "$ChocolateyProfile"
}
