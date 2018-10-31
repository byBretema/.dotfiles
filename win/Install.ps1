
# Write with <3 by Dac. (@cambalamas)

# POSH GALLERY
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
$cmdlets = @("posh-git", "psdockerhub", "posh-docker")
$cmdlets | ForEach-Object { Install-Module -Name $_ }

# SCOOP
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
scoop install git
scoop install gcc go openssh sudo xming cmake make

# CHOCO
Set-ExecutionPolicy Bypass
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
choco feature enable -n allowGlobalConfirmation
choco install 7zip blender ditto meshlab rufus teamviewer telegram tixati whatsapp sumatrapdf steam hyper clipgrab caffeine captura postman #nvidia-display-driver

# 7-zip double-click simply extract
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
New-Item -path "hkcr:\Applications\7zG.exe\shell\open\command" -value "`"C:\Program Files\7-Zip\7zG.exe`" x `"%1`" -o* -aou" -Force

# TELEMETRY OFF
Set-Service DiagTrack -StartupType Disabled
Set-Service dmwappushservice -StartupType Disabled
New-ItemProperty -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -name "AllowTelemetry" -PropertyType DWORD -value 0 -Force

# TASKS OFF
@("usbceip", "microsoft", "consolidator", "silentcleanup", "dmclient", "scheduleddefrag") | ForEach-Object {
	(Get-ScheduledTask -TaskName "*$_*") | ForEach-Object { Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath }
}

# LINK CONFIG FILES
function lns([string]$to, [string]$from) {New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force}

lns $profile ".\Microsoft.PowerShell_profile.ps1"

lns "${env:UserProfile}\.gitignore" "..\git\.gitignore"
lns "${env:UserProfile}\.gitconfig" "..\git\.gitconfig"

lns "${env:APPDATA}\Code\User\settings.json" "..\vscode\settings.json"
lns "${env:APPDATA}\Code\User\keybindings.json" "..\vscode\keybindings.json"
