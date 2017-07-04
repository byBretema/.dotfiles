Clear-Host
Set-PSReadLineOption -HistoryNoDuplicates:$True

### ON LOAD
Import-Module posh-git
Import-Module posh-docker
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

### GLOBAL VARS
$EDITOR = "code"
$env:GOPATH = "D:\devbox\go"
$PLAYER = "$env:ProgramFiles\VideoLAN\VLC\vlc.exe"
$env:PATH += ";${env:ProgramFiles(x86)}\Xming;${env:GOPATH}\bin"
# Hack for use GUI linux apps via Docker.
# Requires Xming or similar. ( xming -ac -multiwindow -clipboard )
$DISPLAY = $((Get-NetAdapter "vEthernet (DockerNAT)" |
    Get-NetIPAddress).IPAddress)+":0" 2>$null
# Open in the last directory
$currentPath = "$env:USERPROFILE\currentPath.txt"
$previousPath = "$env:USERPROFILE\previousPath.txt"
#...Get-Content $currentPath | Set-Location 2>$null

### PROMPT FUNCTION
function prompt() {
    # Last status
    if ($? -and $LASTEXITCODE.Equals(0)) {
        Write-Host "V" -ForegroundColor Green -NoNewline
        Write-Host "` " -ForegroundColor White -NoNewline
    } else {
        Write-Host "X" -ForegroundColor Red -NoNewline
        Write-Host "` " -ForegroundColor White -NoNewline
    }
    # Current path
    Write-Host "$(Split-Path $(Get-Location) -Leaf)" -ForegroundColor Cyan -NoNewline
    # Git stuff
    if (Get-GitStatus) {
        $gs = (Get-GitStatus)
        Write-Host ":" -ForegroundColor White -NoNewline
        Write-Host "$($gs.Branch)" -ForegroundColor Magenta -NoNewline
        if ($gs.HasWorking) {
            Write-Host "*" -ForegroundColor DarkGray -NoNewline
        }
        if ($gs.AheadBy) {
            Write-Host ".A$($gs.AheadBy)" -ForegroundColor Green -NoNewline
        }
        if ($gs.BehindBy) {
            Write-Host ".B$($gs.BehindBy)" -ForegroundColor Red -NoNewline
        }
    }
    # Write-Host " | " -ForegroundColor White -NoNewline
    # Write-Host "$(ls)" -ForegroundColor Blue -NoNewline
    Write-Host " >" -ForegroundColor White -NoNewline
    "` "
}

### POSH ALIAS
Set-Alias e $EDITOR
Set-Alias p $PLAYER
$badAliases = @('ls','rm','mv','cp','cat','man','pwd','wget','echo','curl')
$badAliases | ForEach-Object {
    if(Get-Alias -name $_ 2>$null) {
        Remove-Item alias:$_
    }
}

### GIT FUNCTIONS
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


### LAZY-DEV FUNCTIONS
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
# Open a gui app via Docker.
function dogui () {
    xming -ac -multiwindow -clipboard
    docker run -it -v "$((Get-Location).path):/app" -e DISPLAY=$DISPLAY $args
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
function offTimer {
    if( -not $args ) {
        shutdown -a -fw
    } else {
        shutdown -s -t $($args[0]*60)
    }
}
# Hack powershell 'ls' with git bash binaries.
function pwdColored { $pwdOutput=$(pwd); Write-Host "$pwdOutput" -ForegroundColor DarkGray}
function ls { (Get-ChildItem $args).name -join ", " }
function l  { pwdColored; ls.exe -AFGh --color $args }
function ll { pwdColored; ls.exe -AFGhl --color $args }
function lt { pwdColored; ls.exe -AFGhlt --color $args }
function all { $(ls.exe "*.$args") }
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
function qe {
    switch ($args[0]) {
        "vim"  { e "$env:userprofile\.vimrc" }
        "posh" { e "$env:CMDER_ROOT\config\user-profile.ps1"}
        "git"  { e "$env:userprofile\.gitconfig" ; e "$env:userprofile\.gitignore" }
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

### WEB FUNCTION
function npmServer {
    npm install -g live-server
    live-server
}
