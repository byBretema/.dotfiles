
function path_to_unix([string]$path) {
    return "$path".Replace("\", "/")
}

######################################################
### WINGET Packages
######################################################

function install_winget($package) {
    winget install --disable-interactivity --accept-package-agreements --accept-source-agreements -e --id "$package"
}

install_winget "Microsoft.PowerShell"             # Pwsh : Powershell 7

# OS Utils
#---------------------
install_winget "Ditto.Ditto"                      # Ditto      : Clipboard History
install_winget "Win.QuickLook"                    # QuickLook  : macos-like Preview
install_winget "voidtools.Everything"             # Everything : The best file searcher
install_winget "voidtools.Everything.Cli"         # Everything : The best file searcher
install_winget "Flow-Launcher.Flow-Launcher"      # Laucher    : Spotlight/Alfred like
install_winget "Microsoft.PowerToys"              # PowerToys
install_winget "7zip.7zip"                        # 7Zip

# 7zip : Double-Click Simply Extract
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
New-Item -path "hkcr:\Applications\7zG.exe\shell\open\command" -value "`"${env:ProgramFiles}/7-Zip/7zG.exe`" x `"%1`" -o* -aou" -Force

# Media
#---------------------
install_winget "Rufus.Rufus"                      # To burn ISOs onto USBs
install_winget "CodecGuide.K-LiteCodecPack.Full"  # KLite
install_winget "9NBLGGH42THS"                     # 3D Previewer
install_winget "BlenderFoundation.Blender"        # Blender
install_winget "HandBrake.HandBrake"              # HandBrake : Video Coder
install_winget "OBSProject.OBSStudio"             # OBS Studio

# Communications
#---------------------
install_winget "XPFCS9QJBKTHVZ"                   # Spark Email
install_winget "Microsoft.Teams"                  # MS Teams
install_winget "TeamViewer.TeamViewer"            # TeamViewer

# Information
#---------------------
install_winget "SumatraPDF.SumatraPDF"            # Sumatra : PDF Reader
install_winget "Zen-Team.Zen-Browser.Optimized"   # Zen Browser
install_winget "Notion.Notion"                    # Notion
install_winget "Obsidian.Obsidian"                # Obsidian

# Dev
#---------------------
install_winget "Git.Git"                          # Git
install_winget "bmatzelle.Gow"                    # Linux Aliases
install_winget "KhronosGroup.VulkanSDK"           # Vulkan
install_winget "Microsoft.VisualStudioCode"       # VS Code
install_winget "Starship.Starship"                # Terminal prompt
install_winget "gsass1.NTop"                      # htop for Windows

# Personal
#---------------------
install_winget "Apple.iCloud"                     # iCloud
install_winget "Valve.Steam"                      # Steam
install_winget "RazerInc.RazerInstaller"          # Razer Lights


######################################################
### MANUALLY : DOWNLOAD + INSTALL
######################################################

# Download to temp file
function temp_download ([string]$url, [string]$filename, [string]$ext) {
    $tmp_file = path_to_unix "${env:TEMP}/${filename}.${ext}";
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        $ProgressPreference = "SilentlyContinue"
    }
    Invoke-WebRequest -URI $url -OutFile $tmp_file;
    return $tmp_file
}

$f = temp_download "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" "FiraCode" "zip"
unzip -o $f
explorer.exe "$f".Trim(".zip")

$f = temp_download "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip" "FiraCodeNF" "zip"
unzip -o $f
explorer.exe "$f".Trim(".zip")

$f = temp_download "https://download.clipgrab.org/clipgrab-3.9.11-dotinstaller.exe" "ClipGrab" "exe"
& "$f"


######################################################
### POWERSHELL MODULES
######################################################

Install-Module z -AllowClobber
Install-Module posh-git -AllowClobber


######################################################
### REGISTRY
######################################################

function add_reg_dword ($path, $key, $val) {
    sudo REG ADD $path /v $key /t REG_DWORD /d $val /f
}

$IsLaptop = ($null -ne (Get-CimInstance -Class win32_battery))
$PowerSettingsPath = "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings"

# Disable telemetry
Set-Service DiagTrack -StartupType Disabled
add_reg_dword "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0

# Only on laptops
if ($IsLaptop) {
    # Enable 'Hybernate After'
    $hibernate_key = "${PowerSettingsPath}\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\9d7815a6-7ee4-497e-8888-515a05f02364"
    add_reg_dword $hibernate_key "Attributes" 2
}


######################################################
### CAPABILITIES
######################################################

function install_capabilites($name) {
    $caps = Get-WindowsCapability -Online | Where-Object { $_.Name -Like "*$name*" }
    foreach ($cap in $caps) {
        $cap | Add-WindowsCapability -Online
    }
}

# Enable OCR for all available languages
install_capabilites "Language.OCR"


######################################################
### LINKs
######################################################

function lns ([string]$from, [string]$to) {
    $null = New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force
}

# $documents = ([Environment]::GetFolderPath("MyDocuments"))
# lns "./profile.ps1" "$documents/PowerShell/Microsoft.PowerShell_profile.ps1"

lns "./profile.ps1" $PROFILE
lns "./.gitconfig" "${home}/.gitconfig"

$vscode_config_path = path_to_unix "${env:APPDATA}\Code\User"
lns "./vscode/settings.json"    "${vscode_config_path}\settings.json"
lns "./vscode/keybindings.json" "${vscode_config_path}\keybindings.json"


lns "${home}/.tigrc" ".tigrc"
