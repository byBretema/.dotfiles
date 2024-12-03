#Requires -RunAsAdministrator

######################################################
### Helprs
######################################################

$script_root = $PSScriptRoot.Replace("\", "/")
$prog_files = ${env:ProgramFiles}.Replace("\", "/")

if ($PSVersionTable.PSVersion.Major -lt 7) {
    $ProgressPreference = "SilentlyContinue"
}

function path_to_unix([string]$path) {
    return "$path".Replace("\", "/")
}

function unzip($path) {
    $folder = ("$path".Replace("\", "/")) + "_unzip"
    Write-Host ">> Unzip : $folder"
    Remove-Item -Recurse $folder -Force 2>$null
    $null = Start-Process -FilePath "$prog_files/7-Zip/7zG.exe" -ArgumentList "x `"$path`" -o`"$folder`" -aou" -PassThru -Wait
    Start-Process $folder
}

Write-Host "`nSCRIPT BEGINING!`n========================================="

######################################################
### WINGET Packages
######################################################

Write-Host "`n[winget]"

function install_winget([string]$package, [string]$name = "") {
    if ($name.Length -gt 0) {
        $name = " : $name"
    }
    Write-Host ">> Installing/Updating : $package$name"
    winget install --disable-interactivity --accept-package-agreements --accept-source-agreements -e --id "$package" 1>$null
}

if ($PSVersionTable.PSVersion.Major -lt 7) {
    install_winget "Microsoft.PowerShell" # Pwsh : Powershell 7
    sudo config --enable normal
    & pwsh.exe "$script_root/install.ps1"
    exit 0
}

# OS Utils
#---------------------
install_winget "Ditto.Ditto"                      # Ditto      : Clipboard History
install_winget "QL-Win.QuickLook"                 # QuickLook  : macos-like Preview
install_winget "voidtools.Everything"             # Everything : The best file searcher
install_winget "voidtools.Everything.Cli"         # Everything : The best file searcher
install_winget "Flow-Launcher.Flow-Launcher"      # Laucher    : Spotlight/Alfred like
##install_winget "Microsoft.PowerToys"              # PowerToys
install_winget "7zip.7zip"                        # 7Zip

# 7zip : Double-Click Simply Extract
$null = New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
$null = New-Item -path "hkcr:\Applications\7zG.exe\shell\open\command" -value "`"$prog_files/7-Zip/7zG.exe`" x `"%1`" -o* -aou" -Force

# Media
#---------------------
install_winget "Rufus.Rufus"                      # To burn ISOs onto USBs
install_winget "CodecGuide.K-LiteCodecPack.Full"  # KLite
install_winget "9NBLGGH42THS" "3D Previewer"      # 3D Previewer
install_winget "BlenderFoundation.Blender"        # Blender
install_winget "HandBrake.HandBrake"              # HandBrake : Video Coder
install_winget "OBSProject.OBSStudio"             # OBS Studio

# Communications
#---------------------
install_winget "XPFCS9QJBKTHVZ" "Spark Mail"      # Spark Mail
install_winget "Microsoft.Teams"                  # MS Teams
install_winget "TeamViewer.TeamViewer"            # TeamViewer

# Information
#---------------------
install_winget "SumatraPDF.SumatraPDF"            # Sumatra : PDF Reader
install_winget "Brave.Brave"                      # Brave : A better Chrome
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
install_winget "eza-community.eza"                # ls 2.0
install_winget "Python.Python.3.13"               # Python 3.x
install_winget "Microsoft.VisualStudio.2022.Community"  # Visual Studio (MSVC)

# Personal
#---------------------
install_winget "Valve.Steam"                      # Steam
install_winget "LocalSend.LocalSend"              # AirDrop wannabe
##install_winget "Apple.iCloud"                     # iCloud
##install_winget "RazerInc.RazerInstaller"          # Razer Lights


######################################################
### MANUALLY : DOWNLOAD + INSTALL
######################################################

Write-Host "`n[direct-download]"

# Download to temp file
function download_to_temp([string]$url) {
    $name = $url.Split("/")[-1]
    Write-Host ">> Downloading : $name"
    $tmp_file = path_to_unix "${env:TEMP}/$name";
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        $ProgressPreference = "SilentlyContinue"
    }
    Invoke-WebRequest -URI $url -OutFile $tmp_file;
    return $tmp_file
}

#unzip (download_to_temp "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip")
#unzip (download_to_temp "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip")
#unzip (download_to_temp "https://rubjo.github.io/victor-mono/VictorMonoAll.zip")

## OpenSSH
if (-not (Test-Path "$prog_files/OpenSSL-Win64")) {
    $openssh_msi = download_to_temp "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.2.2.0p1-Beta/OpenSSH-Win64-v9.2.2.0.msi"
    Write-Host ">> Installing : OpenSSH"
    Start-Process msiexec.exe -Wait -ArgumentList "/i $openssh_msi /passive"
}


######################################################
### POWERSHELL MODULES
######################################################

# Write-Host "`n[pwsh-modules]"

# function install_module([string]$pkg) {
#     Write-Host ">> Installing : $pkg"
#     $null = Install-Module $pkg -Confirm:$False -Force -AllowClobber
# }

# Import-Module PowerShellGet  2>$null
# install_module z
# install_module posh-git


######################################################
### REGISTRY
######################################################

Write-Host "`n[registry]"

function add_reg_dword ([string]$path, [string]$key, $val) {
    $null = (REG ADD $path /v $key /t REG_DWORD /d $val /f)
}


# Disable telemetry
Write-Host ">> Disable telemetry"
Set-Service DiagTrack -StartupType Disabled
add_reg_dword "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0

# Only on laptops
$IsLaptop = ($null -ne (Get-CimInstance -Class win32_battery))
if ($IsLaptop) {
    # Enable 'Hibernate After'
    Write-Host ">> Enable hibernate after"
    $power_settings_path = "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings"
    $key_a = "238C9FA8-0AAD-41ED-83F4-97BE242C8F20"
    $key_b = "9d7815a6-7ee4-497e-8888-515a05f02364"
    $hibernate_path = "$power_settings_path\$key_a\$key_b"
    add_reg_dword $hibernate_path "Attributes" 2
}


######################################################
### CAPABILITIES
######################################################

Write-Host "`n[capabilities]"

function install_capabilites([string]$name, [string]$filters_by_comma = "") {
    $filters = $filters_by_comma.Split(",")
    $has_filter = $filters.Length -gt 0
    $caps = Get-WindowsCapability -Online | Where-Object { $_.Name -Like "*$name*" }
    foreach ($cap in $caps) {
        # Check filter
        if ($has_filter) {
            $valid = $false
            foreach ($filter in $filters) {
                $valid = $valid -or $cap.Name.Contains($filter)
            }
            if (-not $valid) {
                continue
            }
        }
        # Install
        Write-Host ">> Installing : $($cap.Name)"
        $null = $cap | Add-WindowsCapability -Online
    }
}

# Enable OCR for all available languages
install_capabilites "Language.OCR" "en-GB,en-US,es-ES,fr-FR"


######################################################
### LINKs
######################################################

Write-Host "`n[sym-links]"

function lns([string]$from, [string]$to) {
    $to = path_to_unix $to
    Write-Host ">> Linking : $from to $to"
    $null = New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force
}

# Git Config
lns "$script_root/.gitconfig" "${home}/.gitconfig"

# Powershell Profile on Powershell 7.x
$documents = ([Environment]::GetFolderPath("MyDocuments"))
lns "$script_root/profile.ps1" "$documents/PowerShell/Microsoft.PowerShell_profile.ps1"

# VSCode Config + Extensions
$vscode_config_path = path_to_unix "${env:APPDATA}\Code\User"
lns "$script_root/vscode/settings.json"    "${vscode_config_path}/settings.json"
lns "$script_root/vscode/keybindings.json" "${vscode_config_path}/keybindings.json"

# Windows Terminal Config
$local_appdata_pkgs = path_to_unix "${env:LOCALAPPDATA}\Packages"
$terminal_partial_path = "*Microsoft.WindowsTerminal*"
$terminals = (Get-ChildItem $local_appdata_pkgs -Name $terminal_partial_path)
foreach ($terminal in $terminals) {
    $terminal = path_to_unix "$local_appdata_pkgs\$terminal"
    $settings_path = "$terminal/LocalState/settings.json"
    lns "$script_root/terminal/settings.json" $settings_path
}
