# ALIAS
Set-Alias e "code"
Set-Alias p "$env:ProgramFiles\VideoLAN\VLC\vlc.exe"
@('ls', 'rm', 'mv', 'cp', 'cat', 'man', 'pwd', 'wget', 'curl', 'mkdir') | ForEach-Object { Remove-Item alias:$_ 2> $null }

# ENV
$env:SCOOP = "C:\tools\scoop"
$env:GOPATH = "C:\devbox\code\go"
$env:GOBIN = "C:\devbox\code\go\bin"
$env:ChocolateyInstall = "C:\tools\choco"
$CURRPATH = "${env:USERPROFILE}\CURRPATH.txt"
$PREVPATH = "${env:USERPROFILE}\PREVPATH.txt"
$env:PATH += ";${env:ProgramFiles(x86)}\Xming;${env:SystemDrive}\tools\mingw64\bin;${env:GOBIN}"

# DOCKER
function x11 { xming -ac -multiwindow -clipboard }
function whale { if ($args) { x11; docker run -it -v "$((Get-Location).path):/app" -e DISPLAY=$(display) $args } }
function display { (Get-NetAdapter "vEthernet (DockerNAT)" | Get-NetIPAddress -AddressFamily "IPv4").IPAddress + ":0" 2> $null }

# GIT
function gst { git status -sb }
function glg { git log --graph --oneline --decorate }
function qgp { if ($args) { git add -A; git commit -m "$args"; git push } }
function gitit { Start-Process "$(git remote -v | gawk '{print $2}' | head -1)" }
function gitb { if ($args[0]) { git checkout -b "$args[0]"; git push origin "$args[0]" } }
function loc { if ($args[0]) { (Get-ChildItem * -recurse -include *.$($args[0]) | Get-Content | Measure-Object -Line).Lines } }
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

# MOVE
function k  { Clear-Host; l}
function l  { ls.exe -AhpX $args }
function ll { ls.exe -AhlpX --color $args }
function oo { explorer (Get-Location).Path }
function ho { Set-Location $env:userprofile }
function pwdc { Write-Host $(Get-Location) -ForegroundColor DarkGray }
function b ([Int]$jumps) { for ( $i = 0; $i -lt $jumps; $i++) { Set-Location .. } }
function bd { if ( Test-Path $PREVPATH ) { Get-Content $PREVPATH | Set-Location } }
function Update-SavedPath {
    if ( -not ( $(Get-Content $CURRPATH) -eq $((Get-Location).path) )) { Get-Content $CURRPATH | Out-File $PREVPATH }
    (Get-Location).Path | Out-File $CURRPATH
}

# SYS
function offTimer { shutdown /hybrid /s /t $($args[0] * 60) }
function bitLock { manage-bde.exe -lock $args[0] }
function bitUnlock { manage-bde.exe -unlock $args[0] -pw }
function bg { Start-Process powershell -NoNewWindow "-Command $args" }
function ke { Stop-Process (Get-Process explorer).id }
function eposh { e "${env:USERPROFILE}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" }
function iconFind ([String]$icon) { for ($i = 0; $i -le 65535; $i++) { if ( [char]$i -eq $icon ) { Write-Host $i } } }

# GO
function g { go run $(Get-ChildItem *.go).Name $args }
function goget { if ($args[0]) { go get -v -u $args[0] } }
function gowin { $env:GOOS = "windows"; $env:GOARCH = "amd64"; go build }
function gomac { $env:GOOS = "darwin";  $env:GOARCH = "amd64"; go build }
function gonix { $env:GOOS = "linux";   $env:GOARCH = "amd64"; go build }
function godroid { $env:GOOS = "android"; $env:GOARCH = "arm";   go build }

# NET
function netinfo {
    Write-Host "IP publica:          $(curl.exe -s icanhazip.com)"
    Write-Host "IP privada (Eth):    $((Get-NetAdapter "Ethernet" | Get-NetIPAddress).IPAddress[1])"
    Write-Host "IP privada (Wifi):   $((Get-NetAdapter "Wi-Fi" | Get-NetIPAddress).IPAddress[1])"
    Write-Host "IP time:         $((ping 8.8.8.8)[11])"
    Write-Host "DNS local time:  $((ping www.google.es)[11])"
    Write-Host "DNS foreign time:$((ping www.google.com)[11])"
}
function goo {
    Start-Process "https://www.google.com/search?q=$($args -join '+')"
}

# OFFICE
function office() {
    Start-Job -ScriptBlock {
        $path, $args = $args
        $prg, $files = $args
        switch ($prg) {
            e { $cmd = "EXCEL" }
            w { $cmd = "WINWORD" }
            p { $cmd = "POWERPNT" }
            default { exit }
        }
        try {
            Start-Service 'ClickToRunSvc'
            Set-Location $path
            Start-Process $cmd -ArgumentList " $files"
            Wait-Process $cmd
        } finally { runas /user:$((net user)[4] -replace "[ ].*$") /savedcred "powershell -Command Stop-Service ClickToRunSvc" }
    } -ArgumentList $((Get-Location).path), $args | Out-Null
}

# SUDO
$GRP = (net localgroup)[4] -replace "^."
$ADM = (net localgroup $GRP)[6]
$USR = ${env:USERNAME}
function su { runas /user:$ADM /savedcred "$args" }
function sudo {
    try {
        [Console]::TreatControlCAsInput = $true
        $cmd = "$( if ($args) {"-Command $args"} )"
        su "net localgroup $GRP $USR /Add" | Out-Null
        Start-Process powershell -ArgumentList "-new_console:a $cmd"
        while($true){ Read-Host | Out-Null; break }
    } finally { su "net localgroup $GRP $USR /Del" | Out-Null }
}

# PROMPT
function prompt {
    $Host.UI.RawUI.ForegroundColor = ("Red", "Green")[${?}]
    # $Host.UI.Write(" " + [Char]11166)
    $Host.UI.Write(" " + [Char]9679)

    $Host.UI.RawUI.ForegroundColor = "Cyan"
    $Host.UI.Write(" " + $(Split-Path $PWD -leaf))

    if ($gst = (Get-GitStatus)) {
        $Host.UI.RawUI.ForegroundColor = "Blue"
        $Host.UI.Write(" git(")
        $Host.UI.RawUI.ForegroundColor = "Red"
        $Host.UI.Write($gst.Branch)
        $Host.UI.RawUI.ForegroundColor = "Blue"
        $Host.UI.Write(")")

        $Host.UI.RawUI.ForegroundColor = "Magenta"
        if ($gst.AheadBy) {
            $Host.UI.Write(" " + [Char]8593)
        } elseif ($gst.BehindBy) {
            $Host.UI.Write(" " + [Char]8595)
        } else {
            if ($gst.HasWorking) {
                $Host.UI.Write(" " + [Char]10008)
            } else {
                $Host.UI.Write(" " + [Char]10004)
            }
        }
    } else {
        $Host.UI.RawUI.ForegroundColor = "Magenta"
        $Host.UI.Write(" " + [Char]10247)
    }

    $Host.UI.RawUI.ForegroundColor = "White"
    Update-SavedPath
    return "` ` "
}
