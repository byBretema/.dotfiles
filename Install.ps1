
# Write with <3 by Dac. (@cambalamas)

# POSH GALLERY
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
$cmdlets = @("posh-git", "psdockerhub", "posh-docker", "posh-with")
$cmdlets | ForEach-Object { Install-Module -Name $_ }

# SCOOP
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
scoop install git
scoop install go openssh sudo xming

# CHOCO
Set-ExecutionPolicy Bypass
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
choco install 7zip blender ditto firefox gimp GoogleChrome meshlab rufus teamviewer telegram texmaker tixati unity vscode whatsapp

# 7-zip double-click simply extract
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
New-Item -path "hkcr:\Applications\7zG.exe\shell\open\command" -value "`"C:\Program Files\7-Zip\7zG.exe`" x `"%1`" -o* -aou" -Force

# TELEMETRY OFF
Set-Service DiagTrack -StartupType Disabled
Set-Service dmwappushservice -StartupType Disabled
New-ItemProperty -path "hklm:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -name "AllowTelemetry " -PropertyType DWORD -value 0 -Force

# TASKS OFF
$tasks = @("usbceip", "microsoft", "consolidator", "silentcleanup", "dmclient", "scheduleddefrag")
$tasks | ForEach-Object {
    $taskArr = (Get-ScheduledTask -TaskName "*$_*")
    $taskArr | ForEach-Object { Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath }
}

# LINK CONFIG FILES
New-Item -Path "${env:UserProfile}\.gitignore" -ItemType SymbolicLink -Value ".\.gitignore" -Force
New-Item -Path "${env:UserProfile}\.gitconfig" -ItemType SymbolicLink -Value ".\.gitconfig" -Force
New-Item -Path "${env:UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -ItemType SymbolicLink -Value ".\Microsoft.PowerShell_profile.ps1" -Force
