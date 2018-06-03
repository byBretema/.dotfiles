
# Write with <3 by Dac. (@cambalamas)

# ENV
$DEVPATH = "${env:SystemDrive}\Dac\_devel"
$env:GOPATH = "$DEVPATH\go"
$env:GOBIN = "$DEVPATH\go\bin"
$env:PATH += ";`
    ${env:GOBIN};`
    $TOOLS\mingw64\bin;`
    $TOOLS\scoop\apps\xming\current;`
    ${env:ProgramFiles}\VCG\MeshLab\;`
"

# MOVE
function dev { Set-Location "$DEVPATH" }
function k { Clear-Host; Get-ChildItem $args}
function ho { Set-Location $env:userprofile }
function md { New-Item -ItemType Directory $args[0]; Set-Location $args[0]}
function b ([Int]$jumps) { for ( $i = 0; $i -lt $jumps; $i++) { Set-Location .. } }
function oo { if ($args) {explorer $args[0] } else { explorer (Get-Location).Path } }

# SYS
function noff { shutdown /a }
function me { net user ${env:UserName} }
function devices { sudo mmc devmgmt.msc }
function ke { Stop-Process (Get-Process explorer).id }
function bitLock { sudo manage-bde.exe -lock $args[0] }
function off { shutdown /hybrid /s /t $($args[0] * 60) }
function bitUnlock { sudo manage-bde.exe -unlock $args[0] -pw }
function bg { Start-Process powershell -NoNewWindow "-Command $args" }
function eposh { code "${env:UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" }
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

# NET
function goo { Start-Process "https://www.google.com/search?q=$($args -join '+')" }
function netinfo {
    Write-Host "Public IP:           $(curl.exe -s icanhazip.com)"
    Write-Host "Private IP (Eth):    $((Get-NetAdapter "Ethernet" | Get-NetIPAddress).IPAddress[1])"
    Write-Host "Private IP (Wifi):   $((Get-NetAdapter "Wi-Fi" | Get-NetIPAddress).IPAddress[1])"
    Write-Host "IP time:         $((ping 8.8.8.8)[11])"
    Write-Host "DNS local time:  $((ping www.google.es)[11])"
    Write-Host "DNS foreign time:$((ping www.google.com)[11])"
}


# ========================================================================== #


# DOCKER
function x11 { xming -ac -multiwindow -clipboard }
function whale { if ($args) { x11; docker run -v "$((Get-Location).path):/app" -e DISPLAY=$(display) -it $args } }
function display { (Get-NetAdapter "vEthernet (DockerNAT)" | Get-NetIPAddress -AddressFamily "IPv4").IPAddress + ":0" 2> $null }

# GIT
function gst { git status -sb }
function glg { git log --graph --oneline --decorate }
function qgp { if ($args) { git add -A; git commit -m "$args"; git push } }
function gitit { Start-Process "$(git remote -v | gawk '{print $2}' | head -1)" }
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

function cc {
    $out = (Get-Item $PWD).Name
    $files = $(Get-ChildItem *.c, *.cc, *.cpp)
    g++ -I. -std='c++17' -fopenmp -O6 -Wall $files $args -o $out
    if (Test-Path ".\$out.exe") { & ".\$out.exe"; Remove-Item ".\$out.exe"}
}


# ========================================================================== #


# PROMPT
function prompt {
    $lastStatus = ("!", "")[${?}]
    Write-Prompt "`n"

    if ($gst = (Get-GitStatus)) {
        $gitStr += " git($($gst.Branch)"
        $gitStr += ("", ", A:$($gst.AheadBy)")[$gst.AheadBy]
        $gitStr += ("", ", B:$($gst.BehindBy)")[$gst.BehindBy]
        $gitStr += (", V) ", ", X) ")[$gst.HasWorking]
        Write-Prompt $gitStr -ForegroundColor Black -BackgroundColor White
        Write-Prompt "` "
    }
    $dataStr = " ${pwd} "
    $dataStr += "${lastStatus}> "
    Write-Prompt $dataStr -ForegroundColor Black -BackgroundColor White
    return "` "
}

# ========================================================================== #


# FIX UPDATES
function fixWindowsUpdate {
    #* Tasks
    $tasks = @("usbceip", "microsoft", "consolidator", "silentcleanup", "dmclient", "scheduleddefrag")
    $tasks | ForEach-Object {
        $taskArr = (Get-ScheduledTask -TaskName "*$_*")
        $taskArr | ForEach-Object { Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath }
    }

    #* Telemetry
    Set-Service DiagTrack -StartupType Disabled
    Set-Service dmwappushservice -StartupType Disabled
    New-ItemProperty -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -name "AllowTelemetry " -PropertyType DWORD -value 0 -Force
}


# ========================================================================== #

# Clear-Host
Set-PSReadLineOption -HistoryNoDuplicates:$True
