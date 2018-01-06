# ALIAS
Set-Alias e "code"
Set-Alias p "$env:ProgramFiles\VideoLAN\VLC\vlc.exe"
@('ls', 'rm', 'mv', 'cp', 'cat', 'man', 'pwd', 'wget', 'curl', 'mkdir') | ForEach-Object { Remove-Item alias:$_ 2> $null }

# ENV
$TOOLS = "${env:SystemDrive}\_TOOLS"
$DEV = "${env:SystemDrive}\_DEV"

# Import-Module "$TOOLS\vcpkg\scripts\posh-vcpkg"
$env:SCOOP = "$TOOLS\scoop"
$env:GOPATH = "$DEV\code\go"
$env:GOBIN = "$DEV\code\go\bin"
$env:ChocolateyInstall = "$TOOLS\choco"
$env:PATH += ";`
    $TOOLS\scoop\apps\xming\current;`
    $TOOLS\mingw64\bin;`
    ${env:GOBIN};${env:ProgramFiles}\dotnet;`
    ${env:ProgramFiles}\VCG\MeshLab\;`
    ${env:UserProfile}\AppData\Local\Conan\conan;`
    $TOOLS\vcpkg;`
"

# DOCKER
function x11 { xming -ac -multiwindow -clipboard }
function whale { if ($args) { x11; docker run -v "$((Get-Location).path):/app" -e DISPLAY=$(display) -it $args } }
function display { (Get-NetAdapter "vEthernet (DockerNAT)" | Get-NetIPAddress -AddressFamily "IPv4").IPAddress + ":0" 2> $null }

# GIT
function gst { git status -sb }
function glg { git log --graph --oneline --decorate }
function qgp { if ($args) { git add -A; git commit -m "$args"; git push } }
function qgfp { git init; git add -A; git commit -m "first commit"; git remote add origin $args[0]; git push -u origin master}
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
function dv { Set-Location "$DEV" }
function pwdc { Write-Host $(Get-Location) -ForegroundColor DarkGray }
function b ([Int]$jumps) { for ( $i = 0; $i -lt $jumps; $i++) { Set-Location .. } }

# SYS
function me { net user ${env:UserName} }
function off { shutdown /hybrid /s /t $($args[0] * 60) }
function bitLock { sudo manage-bde.exe -lock $args[0] }
function bitUnlock { sudo manage-bde.exe -unlock $args[0] -pw }
function bg { Start-Process powershell -NoNewWindow "-Command $args" }
function ke { Stop-Process (Get-Process explorer).id }
function eposh { e "${env:UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" }
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
function su {
    powershell -new_console:a ${args}
}
function sudo {
    try {
        [Console]::TreatControlCAsInput = $true
        $USR = ${env:USERNAME}
        $GRP = (net localgroup)[4] -replace "^."
        powershell -new_console:an "net localgroup $GRP $USR /Add"
        while ($true) { Read-Host | Out-Null; break }
        powershell -new_console:a ${args}
        while ($true) { Read-Host | Out-Null; break }
    } finally { powershell -new_console:an "net localgroup $GRP $USR /Del" }
}

# FIX UPDATES
function fixUpdates {
    # Set-ExecutionPolicy Bypass
    $manSvc = @("wuauserv", "AdobeUpdateService", "AJRouter", "ALG", "AppIDSvc", "AppMgmt", "AppReadiness", "AppVClient", "AppXSvc", "AxInstSV", "BITS", "Browser", "CertPropSvc", "ClickToRunSvc", "ClipSVC", "COMSysApp", "cphs", "cplspcon", "CscService", "debugregsvc", "defragsvc", "*DeveloperToolsS*", "DeviceInstall", "*DevicesFlowUser*", "DevQueryBroker", "*diagnosticshub*", "DiagTrack", "digiSPTIService64", "DmEnrollmentSvc", "dmwappushservice", "DoSvc", "dot3svc", "DPS", "DsmSvc", "DsSvc", "EapHost", "EFS", "embeddedmode", "EntAppSvc", "Fax", "fdPHost", "FDResPub", "fhsvc", "*FlexNetLicensi*", "FrameServer", "*GalaxyClientSer*", "*GalaxyCommunica*", "gupdate", "gupdatem", "HomeGroupListener", "HomeGroupProvider", "icssvc", "IKEEXT", "iPodService", "IpxlatCfgSvc", "irmon", "KtmRm", "LicenseManager", "lltdsvc", "LxssManager", "MapsBroker", "*MessagingServic*", "MSDTC", "MSiSCSI", "msiserver", "*NaturalAuthenti*", "NcaSvc", "NcdAutoSetup", "Netlogon", "Netman", "NetSetupSvc", "NetTcpPortSharing", "ose64", "p2pimsvc", "p2psvc", "PcaSvc", "PeerDistSvc", "PerfHost", "pla", "PNRPAutoReg", "PNRPsvc", "PrintNotify", "QWAVE", "RasAuto", "RasMan", "RemoteAccess", "RemoteRegistry", "RetailDemo", "RmSvc", "RpcLocator", "SCardSvr", "ScDeviceEnum", "SCPolicySvc", "SDRSVC", "SEMgrSvc", "Sense", "SensorDataService", "SensorService", "SensrSvc", "SessionEnv", "SharedAccess", "shpamsvc", "SkypeUpdate", "smphost", "SmsRouter", "SNMPTRAP", "spectrum", "sppsvc", "SshBroker", "SshProxy", "SstpSvc", "*SteamClientSe*", "svsvc", "swprv", "SysMain", "TabletInputService", "TapiSrv", "Te.Service", "TermService", "*TieringEngineSe*", "TrustedInstaller", "tzautoupdate", "UevAgentService", "UI0Detect", "UmRdpService", "upnphost", "UsoSvc", "vds", "vmicguestinterface", "vmicheartbeat", "vmickvpexchange", "vmicrdv", "vmicshutdown", "vmictimesync", "vmicvmsession", "vmicvss", "VSS", "*VSStandardColle*", "W32Time", "WalletService", "wbengine", "WbioSrvc", "wcncsvc", "WdiServiceHost", "WdiSystemHost", "WebClient", "Wecsvc", "WEPHOSTSVC", "wercplsupport", "WerSvc", "WFDSConMgrSvc", "WiaRpc", "WinRM", "wisvc", "wlidsvc", "wlpasvc", "wmiApSrv", "WPDBusEnum", "WSearch", "WwanSvc", "xbgm", "XblAuthManager", "XblGameSave", "XboxGipSvc", "XboxNetApiSvc")
    $manSvc | ForEach-Object { Set-Service -StartupType Manual -Name $_ 2>$null }
    $disSvc = @("AppVClient", "diagnosticshub.standardcollector.service", "DiagTrack", "dmwappushservice", "DoSvc", "DPS", "MapsBroker", "NetTcpPortSharing", "PcaSvc", "RemoteAccess", "RemoteRegistry", "RetailDemo", "SCardSvr", "SensorService", "SensrSvc", "shpamsvc", "SysMain", "UevAgentService", "WdiServiceHost", "wercplsupport", "WerSvc", "WinRM", "WSearch")
    $disSvc | ForEach-Object { Set-Service -StartupType Disabled -Name $_ 2>$null }
    # Cortana -> SearchUI.
    New-Item -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force
    New-ItemProperty -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -name "AllowCortana" -PropertyType DWORD -value 0 -Force
    # Telemetry off.
    Set-Service DiagTrack -StartupType Disabled
    Set-Service dmwappushservice -StartupType Disabled
    New-ItemProperty -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -name "AllowTelemetry " -PropertyType DWORD -value 0 -Force
    # SSD
    fsutil behavior set disabledeletenotify NTFS 0
    fsutil behavior set disabledeletenotify ReFS 0
    New-ItemProperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -name "EnablePrefetcher" -PropertyType DWORD -value 0 -Force
    New-ItemProperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -name "EnableSuperfetch" -PropertyType DWORD -value 0 -Force
    # Tasks
    function disableTasks ([String]$name) {
        $taskArr = (Get-ScheduledTask -TaskName "*${name}*")
        $taskArr | ForEach-Object { Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath }
    }
    $disTaks = @("office", "adobe", "onedrive", "microsoft", "consolidator", "kernelceiptask", "usbceip", "silentcleanup", "bright", "dmclient", "queuereporting", "scheduleddefrag")
    $disTaks | ForEach-Object { Set-Service -StartupType Manual -Name $_ 2>$null }
}

# PROMPT
function prompt {
    $laststatus = ("Red", "Green")[${?}]
    # $Host.UI.Write(" " + [Char]9679)

    if ($gst = (Get-GitStatus)) {
        # Git branch.
        if (-not $gst.Branch -eq "master") {
            $Host.UI.RawUI.ForegroundColor = "Blue"
            $Host.UI.Write(" git(")
            $Host.UI.RawUI.ForegroundColor = "Red"
            $Host.UI.Write($gst.Branch)
            $Host.UI.RawUI.ForegroundColor = "Blue"
            $Host.UI.Write(") ")
        }
        # Git status.
        $Host.UI.RawUI.ForegroundColor = "Magenta"
        if ($gst.AheadBy) {
            $Host.UI.Write([Char]8593) # Arrow up.
        } elseif ($gst.BehindBy) {
            $Host.UI.Write([Char]8595) # Arrow down.
        } else {
            if ($gst.HasWorking) {
                $Host.UI.Write([Char]10008) # X.
            } else {
                $Host.UI.Write([Char]10004) # V.
            }
        }
    } else {
        # No VCS.
        $Host.UI.RawUI.ForegroundColor = "Magenta"
        $Host.UI.Write([Char]10247) # Three points separator.
    }
    # Current folder.
    $Host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.Write(" " + $(Split-Path $PWD -leaf))
    # Separator and last command return status code indicator.
    $Host.UI.RawUI.ForegroundColor = $laststatus
    $Host.UI.Write(" " + [Char]11166)
    # All plain text on "DarkCyan"
    $Host.UI.RawUI.ForegroundColor = "DarkCyan"
    # Feed popd cmdlet.
    # if (-not $env:PREVPATH -eq $PWD.path) {
    #     if (-not $env:OLDPWD -eq $PWD.path) {
    #         Push-Location
    #         $env:OLDPWD = $PWD
    #     }
    # }
    # $env:PREVPATH = $PWD.Path
    # Avoid "PS>" text.
    return "` ` "
}

# LANGS

## GO
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

## C++
function cc {
    if ($args) { $files = $args } else { $files = ( $(Get-ChildItem *.cc), $(Get-ChildItem *.cpp) ) }
    $out = [io.path]::GetFileNameWithoutExtension($files[0])
    Write-Host "C++ compiling... $out.exe`n================================="
    g++ -I. -std='c++17' -fopenmp -O6 $files -o $out
    if (Test-Path ".\$out.exe") { & ".\$out.exe"; Remove-Item "$out.exe" }
}
function cc_include {
    Set-Location "$TOOLS\vcpkg\installed\x86-windows\include\"
}

## MATLAB
function matl {
    matlab -nodesktop -nodisplay -nosplash -n -r $([io.path]::GetFileNameWithoutExtension($args[0]))
}

# END
# Clear-Host
Set-PSReadLineOption -HistoryNoDuplicates:$True
