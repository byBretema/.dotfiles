
### --------------------------- IMPORTANT STUFF --------------------------- ###

# Ensure Get-ExecutionPolicy is not restricted!
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# A PowerShell environment for Git!
PowerShellGet\Install-Module posh-git -Scope CurrentUser

# Plugin manager for vim!

New-Item -ItemType Directory $env:USERPROFILE\.vim\autoload\

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -Outfile "$env:USERPROFILE\.vim\autoload\plug.vim"


### ------------------------------ CHOCOLATEY ----------------------------- ###
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

$choco_apps = @( "7zip", "putty", "docker", "filezilla", "sublimetext3", "youtube-dl", "mediainfo-cli", "imagemagick.tool", "cpu-z", "pdftk", "vlc", "mpv", "mediainfo", "adobe-creative-cloud", "slack", "skype", "discord", "whatsapp", "telegram", "goggalaxy", "steam", "dolphin", "googlechrome", "xmind" )

$choco | ForEach-Object { choco install -y $_ }
choco install -y --allow-empty-checksums battle.net


### -------------------------------- SCOOP -------------------------------- ###
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

# add extra packages from scoop-extra repo.
scoop bucket add extras

$scoop_tools = @( "tar", "nmap", "lynx", "nssm", "nuget", "wifi-manager", "ag", "ln", "sed", "say", "time", "sudo", "gawk", "grep", "less", "touch", "wget", "which", "cowsay", "openssh", "diffutils", "findutils", "coreutils", "vim", "adb", "make", "ctags", "whois", "ffmpeg", "shasum", "doxygen", "busybox", "winmerge", "mercurial", "heroku-cli", "gitextensions", "go", "rust", "mono", "python", "devd", "ngrok", "caddy", "nginx", "redis", "sqlite", "mongodb", "postgresql" )

$scoop_tools | ForEach-Object { scoop install -a 64bit $_}


### -------------------------- LINK CONFIG FILES -------------------------- ###

# Link consoleZ profile...
$g_consoleZ = ".\console.xml"
$h_consoleZ = "C:\consoleZ\console.xml"
Remove-Item $h_consoleZ
New-Item -Path $h_consoleZ -ItemType SymbolicLink -Value  $g_consoleZ

# Link powershell profile...
$g_profile = ".\Microsoft.PowerShell_profile.ps1"
$h_profile = "$env:userprofile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Remove-Item $h_profile
New-Item -Path $h_profile -ItemType SymbolicLink -Value $g_profile

# Link git default ignore list...
$g_gitignore = ".\.gitignore"
$h_gitingore = "$env:userprofile\.gitignore"
Remove-Item $h_gitingore
New-Item -Path $h_gitingore -ItemType SymbolicLink -Value $g_gitignore

# Link git config...
$g_gitconfig = ".\.gitconfig"
$h_gitconfig = "$env:userprofile\.gitconfig"
Remove-Item $h_gitconfig
New-Item -Path $h_gitconfig -ItemType SymbolicLink -Value $g_gitconfig

# Link vim config...
$g_vimrc = ".\.vimrc"
$h_vimrc = "$env:userprofile\.vimrc"
Remove-Item $h_vimrc
New-Item -Path $h_vimrc -ItemType SymbolicLink -Value $g_vimrc
