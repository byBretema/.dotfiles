# Made with ♥ by cambalamas.

### ------------------------------- ON LOAD ------------------------------- ###

# Avoid "Microsoft Copyright spam"!
Clear-Host

# Git info.
Import-Module posh-git

# Chocolatey stuff.
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

### --------------------------------- VARS -------------------------------- ###

$env:PATH += ";${env:ProgramFiles(x86)}\Xming"

# A unix friendly var to select your favorite editor.
$EDITOR = "$env:ProgramFiles\Sublime Text 3\subl.exe"

# Hack for use GUI linux apps via Docker.
# Requires Xming or similar. ( xming -ac -multiwindow -clipboard )
$DISPLAY = $((Get-NetAdapter "vEthernet (DockerNAT)" |
    Get-NetIPAddress).IPAddress)+":0" 2>$null

# Hack consoleZ "open in the same directory"
$currentPath = "$env:USERPROFILE\currentPath.txt"
$previousPath = "$env:USERPROFILE\previousPath.txt"
Get-Content $currentPath | Set-Location 2>$null


### -------------------------------- PROMPT ------------------------------- ###

function prompt {
    # Hack consoleZ "open in the same directory"
    Get-Content $currentPath | Out-File $previousPath
    (Get-Location).Path | Out-File $currentPath

    # Vars...
    $usu = $env:username
    $dom = $env:userdomain
    $cd = (Get-Location).Path
    $time = (Get-Date).ToLongTimeString()

    # Write title...
    $host.UI.RawUI.WindowTitle = "[$usu] @ $dom"

    # Write prompt...
    Write-Host "$(Write-VcsStatus)" -NoNewline
    Write-Host " On " -ForegroundColor White -NoNewline
    Write-Host "$dom" -ForegroundColor DarkBlue -NoNewline
    Write-Host " as " -ForegroundColor White -NoNewline
    Write-Host "$usu" -ForegroundColor DarkYellow -NoNewline
    Write-Host " at " -ForegroundColor White -NoNewline
    Write-Host "$time" -ForegroundColor DarkMagenta -NoNewline
    Write-Host " in " -ForegroundColor White -NoNewline
    Write-Host "$cd" -ForegroundColor DarkCyan -NoNewline
    Write-Host " >" -ForegroundColor White -NoNewline
    "` "
}

### ---------------------------- POSH ALIAS ------------------------------- ###

if ( -Not $(Get-Alias -name e 2>$null) ) {
    New-Alias e $EDITOR
}

$rmAlias = @( 'ls', 'rm', 'mv', 'cp', 'cat', 'man', 'wget', 'echo', 'curl')
$rmAlias | ForEach-Object {
    if(Get-Alias -name $_ 2>$null) {
        Remove-Item alias:$_
    }
}

### -------------------------------- GIT ---------------------------------- ###

# Alias to git status resume and branch indicator.
function gst {
    git status -sb
}

# QuickGitPush: the args are the string to commit.
function qgp {
    git add -A
    git commit -m "$args"
    git push
}

# ZSH GitIt poor imitation. Works bad for ssh.
function gitit {
    $chrome = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
    Start-Process $chrome "$(git remote -v | gawk '{print $2}' | head -1)"
}

### ------------------------------ FUNCTIONS ------------------------------ ###

# Open explorer windows on current directory.
function oo { explorer (Get-Location).Path }

# Restart explorer file manager.
function ke { Stop-Process (Get-Process explorer).id }

# Quick access to home directory.
function ho { Set-Location $env:userprofile }

# Avoid System32\find.exe use 'seek' to use scoop unix-like sane find.
function seek {
    "$env:userprofile\scoop\shims\find.exe $args 2>/null" | Invoke-Expression
}

# jump N above.
function b ([Int]$jumps) {
    for ( $i=0; $i -lt $jumps; $i++) {
        Set-Location ..
    }
}

# go to previous directory.
function bd {
    if ( Test-Path $previousPath ) {
        Get-Content $previousPath | Set-Location
    }
}

# shutdown timer.
function poff {
    if( -not $args ) {
        shutdown -a -fw
    } else {
        shutdown -s -t $($args[0]*60)
    }
}

# Hack powershell 'ls' with git bash binaries.
function ls { ls.exe --color $args}
function l  { ls.exe -AFGh --color $args}
function ll { ls.exe -AFGhl --color $args}
function lt { ls.exe -AFGhlt --color $args}

# info about ip and from ping.
function netinfo {
    Write-Host "IP publica:          $(curl.exe -s icanhazip.com)"
    Write-Host "IP privada (Eth) :   $((Get-NetAdapter "Wi-Fi" |
        Get-NetIPAddress).IPAddress[1])"
    Write-Host "IP privada (Wifi):   $((Get-NetAdapter "Ethernet" |
        Get-NetIPAddress).IPAddress[1])"
    Write-Host "IP time:         $((ping 8.8.8.8)[11])"
    Write-Host "DNS local time:  $((ping www.google.es)[11])"
    Write-Host "DNS foreign time:$((ping www.google.com)[11])"
}

# Quick edit to config files.
$h_vimrc     = "$env:userprofile\.vimrc"
$h_gitingore = "$env:userprofile\.gitignore"
$h_gitconfig = "$env:userprofile\.gitconfig"
$h_profile   = "$env:userprofile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
function qe {
    switch ($args[0]) {
        "vim"  { subl $h_vimrc }
        "posh" { subl $h_profile}
        "git"  { subl $h_gitconfig ; subl $h_gitingore }
        default { }
    }
}
