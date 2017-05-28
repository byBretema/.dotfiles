
#
# Made with <3 by cambalamas.
#


### ------------------------------- ON LOAD ------------------------------- ###

# Ignore dups !
Set-PSReadLineOption -HistoryNoDuplicates:$True

# Modules
Import-Module posh-docker
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"


### --------------------------------- VARS -------------------------------- ###

# Path
$env:PATH += ";${env:ProgramFiles(x86)}\Xming"

# Vars
$GOPATH = "D:\devbox\go"
$env:GOPATH = "D:\devbox\go"
$PLAYER = "$env:ProgramFiles\VideoLAN\VLC\vlc.exe"
$EDITOR = "$env:ProgramFiles\Sublime Text 3\subl.exe"

# Hack for use GUI linux apps via Docker.
# Requires Xming or similar. ( xming -ac -multiwindow -clipboard )
$DISPLAY = $((Get-NetAdapter "vEthernet (DockerNAT)" |
    Get-NetIPAddress).IPAddress)+":0" 2>$null

# Open in the same directory
$currentPath = "$env:USERPROFILE\currentPath.txt"
$previousPath = "$env:USERPROFILE\previousPath.txt"
Get-Content $currentPath | Set-Location 2>$null


### -------------------------------- PROMPT ------------------------------- ###

[ScriptBlock]$PrePrompt = {
    # Open in the same directory hack
    curPathUpdate
    # Print ls output
    Write-Host ""
    $ls = (dir).name -join ", "
    Write-Host "{ " -ForegroundColor Yellow -NoNewline
    Write-Host "$($ls)" -ForegroundColor DarkYellow -NoNewline
    Write-Host " }" -ForegroundColor Yellow #-NoNewline
}

[ScriptBlock]$CmderPrompt = {
    $time = (Get-Date).ToLongTimeString()
    Write-Host "$time" -ForegroundColor Red -NoNewline
    Write-Host " in " -ForegroundColor White -NoNewline
    Write-Host "$(Get-Location)" -ForegroundColor Blue -NoNewline
}

[ScriptBlock]$PostPrompt = {
    Write-Host "$(Write-VcsStatus)" -NoNewline
}


### ---------------------------- POSH ALIAS ------------------------------- ###

$rmAlias = @('ls','rm','mv','cp','cat','pwd','man','wget','echo','curl')
$rmAlias | ForEach-Object {
    if(Get-Alias -name $_ 2>$null) {
        Remove-Item alias:$_
    }
}

# Sublime quick access.
Set-Alias e $EDITOR

# VLC quick access.
Set-Alias p $PLAYER


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

# Create a branch locally and push to repo.
function gitbranch {
    git checkout -b "$args"
    git push origin "$args"
}

# Get repo info via github rest API.
function gitinfo ($who, $which) {
    $repoinfo = irm -Uri "https://api.github.com/repos/$who/$which"
    $webpage = ($repoinfo.homepage, "<None>")[-not $repoinfo.homepage]

    Write-Host "Forks: "         -NoNewline; $repoinfo.forks
    Write-Host "Stars: "         -NoNewline; $repoinfo.stargazers_count
    Write-Host "Watchers: "      -NoNewline; $repoinfo.watchers_count
    Write-Host "Private: "       -NoNewline; $repoinfo.private
    Write-Host "Main lang: "     -NoNewline; $repoinfo.language
    Write-Host "Lines of code: " -NoNewline; $repoinfo.size
    Write-Host "Web page: "      -NoNewline; $webpage
}

### ------------------------------ FUNCTIONS ------------------------------ ###

# X11 via xming.
function x11 { xming -ac -multiwindow -clipboard }

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

# Open all path files on vim.
function vf ()
{
    $filepaths = $input | Get-Item | % { $_.fullname }
    vim $filepaths
}

# Jump back N times.
function b ([Int]$jumps) {
    for ( $i=0; $i -lt $jumps; $i++) {
        Set-Location ..
    }
}

# Go to previous directory.
function bd {
    if ( Test-Path $previousPath ) {
        Get-Content $previousPath | Set-Location
    }
}

# Shutdown timer.
function poff {
    if( -not $args ) {
        shutdown -a -fw
    } else {
        shutdown -s -t $($args[0]*60)
    }
}

# Hack powershell 'ls' with git bash binaries.
function ls { (dir $args).name -join ", "}
function l  { ls.exe -AFGh --color $args}
function ll { ls.exe -AFGhl --color $args}
function lt { ls.exe -AFGhlt --color $args}

# Info about ip and from ping.
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

# Update last active dir path.
function curPathUpdate {
    if( -not ( $(Get-Content $currentPath) -eq $((Get-Location).path) )) {
        Get-Content $currentPath | Out-File $previousPath
    }
    (Get-Location).Path | Out-File $currentPath
}
