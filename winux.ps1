# Made with ♥ by cambalamas.

### --------------------------- IMPORTANT STUFF --------------------------- ###

# Ask for computer name, if empty, don't change it.
Write-Host "Sets a new name for the computer (Empty == No changes) :   " -ForegroundColor Cyan -NoNewline
$computerName = Read-Host
if ($computerName.Lenght > 0) {
    Rename-Computer $computerName
}

# Ensure Get-ExecutionPolicy is not restricted!
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# A PowerShell environment for Git!
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
PowerShellGet\Install-Module -Force posh-git -Scope CurrentUser

# Plugin manager for vim!
$vimAutoload = "$env:USERPROFILE\vimfiles\autoload"
if ( Test-Path $vimAutoload ) { Remove-Item -r $vimAutoload }
New-Item -ItemType Directory $vimAutoload
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -Outfile "$vimAutoload\plug.vim"

### ------------------------------ CHOCOLATEY ----------------------------- ###

# Execute installation script.
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

# Define apps array.
$choco_apps = @( "spotify" "rufus", "ditto", "7zip", "docker", "filezilla", "xming", "sublimetext3", "youtube-dl", "mediainfo-cli", "imagemagick.tool", "pdftk", "vlc", "mpv", "mediainfo", "adobe-creative-cloud", "slack", "skype", "discord", "whatsapp", "telegram", "goggalaxy", "steam", "dolphin", "googlechrome", "xmind", "evince" )

# Execute install over the array elements.
$choco_apps | ForEach-Object { choco install -fyr $_ }
choco install -fyr --allow-empty-checksums battle.net

### -------------------------------- SCOOP -------------------------------- ###

# Execute installation script.
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

# add extra packages from scoop-extra repo.
scoop bucket add extras

# Define tools array.
$scoop_tools = @( "figlet" "tar", "nmap", "lynx", "nssm", "nuget", "wifi-manager", "ag", "ln", "sed", "say", "time", "sudo", "gawk", "grep", "less", "touch", "wget", "which", "cowsay", "openssh", "diffutils", "findutils", "coreutils", "vim", "adb", "make", "ctags", "whois", "ffmpeg", "shasum", "doxygen", "busybox", "winmerge", "mercurial", "heroku-cli", "gitextensions", "go", "rust", "mono", "python", "devd", "ngrok", "caddy", "nginx", "redis", "sqlite", "mongodb", "postgresql" )

# Execute install over the array elements.
$scoop_tools | ForEach-Object { scoop install -a 64bit $_ }

### -------------------------- LINK CONFIG FILES -------------------------- ###

# Link consoleZ profile...
$g_consoleZ = ".\console.xml"
$h_consoleZ = "$env:ConsoleZSettingsDir\console.xml"
if ( Test-Path $h_consoleZ ) { Remove-Item $h_consoleZ }
New-Item -Path $h_consoleZ -ItemType SymbolicLink -Value  $g_consoleZ

# Link powershell profile...
$g_profile = ".\Microsoft.PowerShell_profile.ps1"
$h_profile = "$env:userprofile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if ( Test-Path $h_profile ) { Remove-Item $h_profile }
New-Item -Path $h_profile -ItemType SymbolicLink -Value $g_profile

# Link git default ignore list...
$g_gitignore = ".\.gitignore"
$h_gitingore = "$env:userprofile\.gitignore"
if ( Test-Path $h_gitingore ) { Remove-Item $h_gitingore }
New-Item -Path $h_gitingore -ItemType SymbolicLink -Value $g_gitignore

# Link git config...
$g_gitconfig = ".\.gitconfig"
$h_gitconfig = "$env:userprofile\.gitconfig"
if ( Test-Path $h_gitconfig ) { Remove-Item $h_gitconfig }
New-Item -Path $h_gitconfig -ItemType SymbolicLink -Value $g_gitconfig

# Link vim config...
$g_vimrc = ".\.vimrc"
$h_vimrc = "$env:userprofile\.vimrc"
if ( Test-Path $h_vimrc ) { Remove-Item $h_vimrc }
New-Item -Path $h_vimrc -ItemType SymbolicLink -Value $g_vimrc

### -------------------------- LINK SUBLIME ENV --------------------------- ###

# User packages. (Basically config files)
$g_sublU = ".\sublime_env\Packages\User"
$h_sublU = "$env:userprofile\AppData\Roaming\Sublime Text 3\Packages\User"

# Link user packages using SymbolicLink.
foreach ( $file in (ls $g_sublU).name ) {
    if ( Test-Path "$h_sublU\$file" ) { Remove-Item -r $h_sublU\$file }
    New-Item -Path $h_sublU\$file -ItemType SymbolicLink -Value $g_sublU\$file
}

# Defualt packages.
$g_sublD = ".\sublime_env\Packages\Default"
$h_sublD = "$env:userprofile\AppData\Roaming\Sublime Text 3\Packages\Default"

# Link default packages using SymbolicLink.
foreach ( $file in (ls $g_sublD).name ) {
    if ( Test-Path "$h_sublD\$file" ) { Remove-Item -r $h_sublD\$file }
    New-Item -Path $h_sublD\$file -ItemType SymbolicLink -Value $g_sublD\$file
}

### ---------------------------- SET SERVICES ----------------------------- ###

# Array with all services name.
$toManualServices = (Get-Service).Name

# Set them to manual startup.
$toManualServices | ForEach-Object {
    Set-Service -StartupType Manual -Name $_ 2>$null
}

# Array with some crap services.
$toDisableServices = @( "WSearch", "DiagTrack", "diagnosticshub.standardcollector.service", "WerSvc", "WMPNetworkSvc", "RetailDemo", "DPS", "PcaSvc", "WdiServiceHost", "dmwappushservice", "DcpSvc", "wscsvc", "wercplsupport", "MapsBroker", "WinRM" )

# Set them to disable startup.
$toDisableServices | ForEach-Object {
    Set-Service -StartupType Disabled -Name $_ 2>$null
}
