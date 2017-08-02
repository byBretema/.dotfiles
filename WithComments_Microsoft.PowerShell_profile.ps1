# Made with <3 by @cambalamas

### CONFIG::IMPORTS
Import-Module posh-git
# Import-Module posh-with
Import-Module posh-docker
# Import-Module psdockerhub

### CONFIG::VARS
$env:GOPATH = "C:\devbox\go"
$env:SCOOP = "C:\tools\scoop"
$env:GOBIN = "C:\devbox\go\bin"
$env:ChocolateyInstall = "C:\tools\choco"
# Manage last directory.
$CURRPATH = "$env:USERPROFILE\CURRPATH.txt"
$PREVPATH = "$env:USERPROFILE\PREVPATH.txt"
# Path
$env:PATH += ";${env:ProgramFiles(x86)}\Xming;${env:SystemDrive}\mingw64\mingw64\bin;${env:SystemDrive}\devbox\go\bin"
# Hack for use GUI linux apps via Docker.   Require X11 => $(xming -ac -multiwindow -clipboard)
function display () {
    return (Get-NetAdapter "vEthernet (DockerNAT)" | Get-NetIPAddress -AddressFamily "IPv4").IPAddress + ":0" 2> $null
}

### CONFIG::ALIASES
Set-Alias e "code"
Set-Alias p "$env:ProgramFiles\VideoLAN\VLC\vlc.exe"
@('rm', 'mv', 'cp', 'cat', 'man', 'pwd', 'wget', 'echo', 'curl') | ForEach-Object { Remove-Item alias:$_ 2> $null }

### CONFIG::PROMPT
function prompt() {
    # Last status
    if ($?) { Write-Host "$([Char]9829)` " -ForegroundColor Green -NoNewline }
    else    { Write-Host "$([Char]9829)` " -ForegroundColor Red -NoNewline }
    # Current path
    Write-Host "$(Split-Path $(Get-Location) -Leaf)" -ForegroundColor Cyan -NoNewline
    # Git stuff
    if (Get-GitStatus) {
        Write-Host ":" -ForegroundColor White -NoNewline
        Write-Host "$((Get-GitStatus).Branch)" -ForegroundColor Magenta -NoNewline
        if ((Get-GitStatus).HasWorking) { Write-Host "*" -ForegroundColor DarkGray -NoNewline }
        if ((Get-GitStatus).AheadBy) { Write-Host ".A$((Get-GitStatus).AheadBy)" -ForegroundColor Green -NoNewline }
        if ((Get-GitStatus).BehindBy) { Write-Host ".B$((Get-GitStatus).BehindBy)" -ForegroundColor Red -NoNewline }
    }
    Write-Host " >" -ForegroundColor White -NoNewline
    "` "
    curPathUpdate
}

### FUNCTIONS::GIT
# Alias to git status resume and branch indicator.
function gst { git status -sb }
function glg { git log --graph --oneline --decorate }
# QuickGitPush: the args are the string to commit.
function qgp { git add -A; git commit -m "$args"; git push }
# Create a branch locally and push to repo.
function gitb { git checkout -b "$args"; git push origin "$args" }
# ZSH GitIt poor imitation. Works bad for ssh.
function gitit { Start-Process "$(git remote -v | gawk '{print $2}' | head -1)" }
# Get repo info via github rest API.
function gitinfo ($who, $which) {
    $rest = Invoke-RestMethod -Uri "https://api.github.com/repos/$who/$which"
    $webpage = ($rest.homepage, "<None>")[-not $rest.homepage]
    Write-Host "Forks: "         -NoNewline; $rest.forks
    Write-Host "Stars: "         -NoNewline; $rest.stargazers_count
    Write-Host "Watchers: "      -NoNewline; $rest.watchers_count
    Write-Host "Private: "       -NoNewline; $rest.private
    Write-Host "Main lang: "     -NoNewline; $rest.language
    Write-Host "Lines of code: " -NoNewline; $rest.size
    Write-Host "Web page: "      -NoNewline; $webpage
}

### FUNCTIONS::LAZY-DEV
# Execute on bg
function bg { Start-Process -NoNewWindow $args }
# Clean and list
function k { Clear-Host; l}
# X11 via xming.
function x11 { xming -ac -multiwindow -clipboard }
# Open explorer windows on current directory.
function oo { explorer (Get-Location).Path }
# Restart explorer file manager.
function ke { Stop-Process (Get-Process explorer).id }
# Quick access to home directory.
function ho { Set-Location $env:userprofile }
# Jump back N times.
function b ([Int]$jumps) { for ( $i = 0; $i -lt $jumps; $i++) { Set-Location .. } }
# Go to previous directory.
function bd { if ( Test-Path $PREVPATH ) { Get-Content $PREVPATH | Set-Location } }
# Shutdown timer.
function offTimer { shutdown /hybrid /t $($args[0] * 60) }
# Cancel shutdown timer.
function offCancel { shutdown /a }
# Bitlocker lock.
function bitLock () { manage-bde.exe -lock $args[0] }
# Bitlocker unlock.
function bitUnlock () { manage-bde.exe -unlock $args[0] -pw }
# Find icon
function iconFind ([String]$icon) { for ($i = 0; $i -le 65535; $i++) { if ( [char]$i -eq $icon ) { Write-Host $i } } }
# Hack powershell 'ls' with git bash binaries.
function l { pwdc; ls.exe -AFGh --color $args }
function ll { pwdc; ls.exe -AFGhl --color $args }
function pwdc { Write-Host $(Get-Location) -ForegroundColor DarkGray }
# Open a gui app via Docker.
function whale {
    xming -ac -multiwindow -clipboard
    docker run -it -v "$((Get-Location).path):/app" -e DISPLAY=$DISPLAY $args
}
# Quick edit to config files.
function qe {
    switch ($args[0]) {
        "vim" { e "${env:userprofile}\.vimrc" }
        "git" { e "${env:userprofile}\.gitconfig"; e "${env:userprofile}\.gitignore" }
        "posh" { e "${env:userprofile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"}
        default {}
    }
}
# Info about ip and from ping.
function netinfo {
    Write-Host "IP publica:          $(curl.exe -s icanhazip.com)"
    Write-Host "IP privada (Eth):    $((Get-NetAdapter "Ethernet" | Get-NetIPAddress).IPAddress[1])"
    Write-Host "IP privada (Wifi):   $((Get-NetAdapter "Wi-Fi" | Get-NetIPAddress).IPAddress[1])"
    Write-Host "IP time:         $((ping 8.8.8.8)[11])"
    Write-Host "DNS local time:  $((ping www.google.es)[11])"
    Write-Host "DNS foreign time:$((ping www.google.com)[11])"
}

### FUNCTIONS::EXTRA
# Update last active dir path.
function curPathUpdate {
    if ( -not ( $(Get-Content $CURRPATH) -eq $((Get-Location).path) )) {
        # if I move to other path...
        Get-Content $CURRPATH | Out-File $PREVPATH
    }
    (Get-Location).Path | Out-File $CURRPATH
}
# An aproximation to SUDO powers.
$group = (net localgroup)[4] -replace "^."
$adm = (net localgroup $group)[6]
$user = $env:USERNAME
function sudo {
    runas /user:$adm "net localgroup $group $user /Add"
    start-process POWERSHELL.EXE -verb runAs
    runas /user:$adm /savedcred "net localgroup $group $user /Del" > $null
}
function sudoOn { runas /user:$adm "net localgroup $group $user /Add" }
function sudoOff { runas /user:$adm "net localgroup $group $user /Del" }

### FUNCTIONS::GOLANG
# Easy to run a multifile project.
function g { go run $(Get-ChildItem *.go).Name $args }
# Tipicall go get flags.
function goget { go get -v -u $args }
# Easy cross compilation (Go1.5 or greater)
function gowin { $env:GOOS = "windows"; $env:GOARCH = "amd64"; go build }
function gomac { $env:GOOS = "darwin"; $env:GOARCH = "amd64"; go build }
function gonix { $env:GOOS = "linux"; $env:GOARCH = "amd64"; go build }
function goand { $env:GOOS = "android"; $env:GOARCH = "arm"; go build }

### CONFIG::STUFF
# Avoid ugly msgs (Comment or Delete if fail, to see stderr output)
Clear-Host
# No store duplicate entries on the history
Set-PSReadLineOption -HistoryNoDuplicates:$True
