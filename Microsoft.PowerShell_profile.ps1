Set-Alias e "code"
Set-Alias p "$env:ProgramFiles\VideoLAN\VLC\vlc.exe"
@('rm', 'mv', 'cp', 'cat', 'man', 'pwd', 'wget', 'echo', 'curl') | ForEach-Object { Remove-Item alias:$_ 2> $null }

$env:GOPATH = "C:\devbox\code\go"
$env:SCOOP = "C:\tools\scoop"
$env:GOBIN = "C:\devbox\code\go\bin"
$env:ChocolateyInstall = "C:\tools\choco"
$CURRPATH = "$env:USERPROFILE\CURRPATH.txt"
$PREVPATH = "$env:USERPROFILE\PREVPATH.txt"
$env:PATH += ";${env:ProgramFiles(x86)}\Xming;${env:SystemDrive}\tools\mingw64\bin;${env:SystemDrive}\devbox\go\bin"
function display{ (Get-NetAdapter "vEthernet (DockerNAT)" | Get-NetIPAddress -AddressFamily "IPv4").IPAddress + ":0" 2> $null }

function gst { git status -sb }
function glg { git log --graph --oneline --decorate }
function qgp { git add -A; git commit -m "$args"; git push }
function gitb { git checkout -b "$args"; git push origin "$args" }
function gitit { Start-Process "$(git remote -v | gawk '{print $2}' | head -1)" }
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

function k { Clear-Host; l}
function gepa { (Get-Location).path | Set-Clipboard }
function gopa { Get-Clipboard | Set-Location }
function oo { explorer (Get-Location).Path }
function ho { Set-Location $env:userprofile }
function l { pwdc; ls.exe -AFGh --color $args }
function ll { pwdc; ls.exe -AFGhl --color $args }
function pwdc { Write-Host $(Get-Location) -ForegroundColor DarkGray }
function b ([Int]$jumps) { for ( $i = 0; $i -lt $jumps; $i++) { Set-Location .. } }
function bd { if ( Test-Path $PREVPATH ) { Get-Content $PREVPATH | Set-Location } }
function curPathUpdate {
    if ( -not ( $(Get-Content $CURRPATH) -eq $((Get-Location).path) )) { Get-Content $CURRPATH | Out-File $PREVPATH }
    (Get-Location).Path | Out-File $CURRPATH
}

function x11 { xming -ac -multiwindow -clipboard }
function whale { x11; docker run -it -v "$((Get-Location).path):/app" -e DISPLAY=$(display) $args }
function iconFind ([String]$icon) { for ($i = 0; $i -le 65535; $i++) { if ( [char]$i -eq $icon ) { Write-Host $i } } }
function netinfo {
    Write-Host "IP publica:          $(curl.exe -s icanhazip.com)"
    Write-Host "IP privada (Eth):    $((Get-NetAdapter "Ethernet" | Get-NetIPAddress).IPAddress[1])"
    Write-Host "IP privada (Wifi):   $((Get-NetAdapter "Wi-Fi" | Get-NetIPAddress).IPAddress[1])"
    Write-Host "IP time:         $((ping 8.8.8.8)[11])"
    Write-Host "DNS local time:  $((ping www.google.es)[11])"
    Write-Host "DNS foreign time:$((ping www.google.com)[11])"
}

function offCancel { shutdown /a }
function bg { Start-Process -NoNewWindow $args }
function bitLock { manage-bde.exe -lock $args[0] }
function ke { Stop-Process (Get-Process explorer).id }
function offTimer { shutdown /hybrid /t $($args[0] * 60) }
function bitUnlock { manage-bde.exe -unlock $args[0] -pw }
function eposh { e "${env:userprofile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" }

function g { go run $(Get-ChildItem *.go).Name $args }
function goget { go get -v -u $args }
function gowin { $env:GOOS = "windows"; $env:GOARCH = "amd64"; go build }
function gomac { $env:GOOS = "darwin";  $env:GOARCH = "amd64"; go build }
function gonix { $env:GOOS = "linux";   $env:GOARCH = "amd64"; go build }
function goand { $env:GOOS = "android"; $env:GOARCH = "arm";   go build }

function sudo {
    $group = (net localgroup)[4] -replace "^."
    $adm   = (net localgroup $group)[6]
    $user  = ${env:USERNAME}
    runas /user:$adm "net localgroup $group $user /Add"
    Start-Process  powershell.exe -ArgumentList "-NoExit", "-Command", "$args" -Verb RunAs
    runas /user:$adm /savedcred "net localgroup $group $user /Del" > $null
}

function prompt() {
    if ($?) { $color = "Green" } else { $color = "Red" }
    Write-Host "$([Char]9829)` " -ForegroundColor $color -NoNewline
    Write-Host "$(Split-Path $(Get-Location) -Leaf)" -ForegroundColor Cyan -NoNewline
    if (Get-GitStatus) {
        Write-Host ":" -ForegroundColor White -NoNewline
        Write-Host "$((Get-GitStatus).Branch)" -ForegroundColor Magenta -NoNewline
        if ((Get-GitStatus).HasWorking) { Write-Host "*" -ForegroundColor DarkGray -NoNewline }
        if ((Get-GitStatus).AheadBy) { Write-Host ".A$((Get-GitStatus).AheadBy)" -ForegroundColor Green -NoNewline }
        if ((Get-GitStatus).BehindBy) { Write-Host ".B$((Get-GitStatus).BehindBy)" -ForegroundColor Red -NoNewline }
    }
    Write-Host " >" -ForegroundColor White -NoNewline; "` "
    curPathUpdate
}
