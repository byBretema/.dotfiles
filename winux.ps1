### MANUAL THINGS
# Disable: Protection.               On:  Adv System  > System Protection.
# Disable: Optimizer.                On:  Computer    > SSD Properties     > Tools.
# Disable: Index.                    On:  Computer    > SSD Properties     > General.
# Disable: VirtualMem.               On:  Adv System  > Performance        > Adv options.
# Switch to: This computer.          The: View        > Options            > Open explorer select.
# Uncheck: Recently and Frequently.  On:  View        > Options            > Privacity at dialog bottom.

### POLICY (Allow non-signed scripts)
Set-ExecutionPolicy Bypass

### POSH GALLERY
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
$cmdlets = @("posh-git", "psdockerhub", "posh-docker", "posh-with")
$cmdlets | ForEach-Object { Install-Module -Name $_ }

### CHOCOLATEY    # NotSSD = @("uplay", "battle.net", "goggalaxy", "steam")
$env:ChocolateyInstall="C:\tools\choco"
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
choco feature enable -n allowGlobalConfirmation
$chocoApps = @("rufus", "nvidia-display-driver", "vnc-viewer", "unity", "cmdermini", "anydesk", "pushbullet", "obs-studio", "docker", "mingw", "tixati", "7zip", "bulk-crap-uninstaller", "caffeine", "clipgrab", "discord", "ditto", "slack", "google-cast-chrome", "lightshot", "skype", "vlc", "WhatsApp", "GoogleChrome", "VisualStudioCode")
$chocoApps | ForEach-Object { choco install $_ }

### VSCODE
$vsExts = @("alexdima.copy-relative-path", "anseki.vscode-color", "austin.code-gnu-global", "bbenoist.Doxygen", "christian-kohler.path-intellisense", "cssho.vscode-svgviewer", "DavidAnson.vscode-markdownlint", "deerawan.vscode-dash", "donjayamanne.githistory", "donjayamanne.python", "DotJoshJohnson.xml", "EditorConfig.EditorConfig", "felixfbecker.php-intellisense", "idleberg.hopscotch", "idleberg.icon-fonts", "jakob101.RelativePath", "joaoacdias.golang-tdd", "lukasz-wronski.ftp-sync", "lukehoban.Go", "mohsen1.prettify-json", "ms-vscode.cpptools", "ms-vscode.csharp", "ms-vscode.PowerShell", "PeterJausovec.vscode-docker", "rubbersheep.gi", "Rubymaniac.vscode-paste-and-indent", "sandy081.todotasks", "saviorisdead.RustyCode", "sensourceinc.vscode-sql-beautify", "Shan.code-settings-sync", "tinkertrain.theme-panda", "Unity.unity-debug", "wmaurer.vscode-jumpy", "xyz.plsql-language")
$vsExts | ForEach-Object { code --install-extension $_ }

### SCOOP
$env:SCOOP="C:\tools\scoop"
Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
scoop install git
scoop bucket add extras
$scoopApps = @("openssh", "zeal", "go", "mono", "rust", "nodejs", "elixir", "python", "autohotkey", "dd", "say", "adb", "vim", "curl", "sudo", "whois", "xming", "cowsay", "shasum", "figlet", "mediainfo", "redis", "nginx", "ngrok", "sqlite", "mongodb", "mercurial", "postgresql", "gow")
$scoopApps | ForEach-Object { scoop install $_ }

### LINK CONFIG FILES
New-Item -Path "${env:UserProfile}\.gitignore" -ItemType SymbolicLink -Value ".\.gitignore" -Force
New-Item -Path "${env:UserProfile}\.gitconfig" -ItemType SymbolicLink -Value ".\.gitconfig" -Force
New-Item -Path "${env:SystemDrive}\tools\cmdermini\vendor\conemu-maximus5\ConEmu.xml" -ItemType SymbolicLink -Value ".\ConEmu.xml" -Force
New-Item -Path "${env:UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -ItemType SymbolicLink -Value ".\Microsoft.PowerShell_profile.ps1" -Force

### REGEDIT, SERVICES and TASKS
$badSv = @("SysMain", "DiagTrack", "WerSvc", "RetailDemo", "DPS", "PcaSvc", "WdiServiceHost", "dmwappushservice", "wercplsupport", "MapsBroker", "WinRM", "AdobeUpdateService")
$badSv | ForEach-Object { Set-Service -StartupType Disabled -Name $_ 2>$null }
# Add access to HKCR.
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
# 7-zip double-click simply extract.
New-Item -path "hkcr:\Applications\7zG.exe\shell\open\command" -value "`"C:\Program Files\7-Zip\7zG.exe`" x `"%1`" -o* -aou" -Force
New-Item -path "hkcr:\Applications\7zG.exe\shell\open\command" -value "`"C:\Program Files\7-Zip\7zG.exe`" x `"%1`" -o* -aou" -Force
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
disableTasks "office"
disableTasks "adobe"
disableTasks "onedrive"
disableTasks "microsoft"
disableTasks "consolidator"
disableTasks "kernelceiptask"
disableTasks "usbceip"
disableTasks "silentcleanup"
disableTasks "bright"
disableTasks "dmclient"
disableTasks "queuereporting"
disableTasks "scheduleddefrag"
