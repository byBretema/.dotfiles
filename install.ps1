#Requires -RunAsAdministrator

### Helpers
###############################################################################

$script_root = $PSScriptRoot

if ($PSVersionTable.PSVersion.Major -lt 7) {
    $ProgressPreference = "SilentlyContinue"
}

function path_to_unix([string]$path) {
    return "$path".Replace("\", "/")
}

function unzip($path) {
    $folder = "${path}_unzip"
    Write-Host ">> Unzip : $folder"
    Remove-Item -Recurse $folder -Force 2>$null
    $null = Start-Process -FilePath "${env:ProgramFiles}\7-Zip\7zG.exe" -ArgumentList "x `"$path`" -o`"$folder`" -aou" -PassThru -Wait
    Start-Process $folder
}

function download_to_temp([string]$url, [string]$name = "") {
    if ($name.Length -lt 1) {
        $name = $url.Split("/")[-1]
    }
    Write-Host ">> Downloading : $name"
    $tmp_file = "${env:TEMP}\$name"
    Invoke-WebRequest -UserAgent "Wget" -URI $url -OutFile $tmp_file;
    return $tmp_file
}

function install_winget([string]$package, [string]$name = "") {
    if ($name.Length -gt 0) {
        $name = " : $name"
    }
    Write-Host ">> Installing/Updating : $package$name"
    winget install --disable-interactivity --accept-package-agreements --accept-source-agreements -e --id "$package" 1>$null
}

function install_module([string]$pkg) {
    Write-Host ">> Installing : $pkg"
    $null = Install-Module $pkg -Confirm:$False -Force -AllowClobber
}

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

function modify_reg_prop([string]$Path, [string]$Name, $Value, [string]$Type = "DWord") {
    if (-not (Test-Path $Path)) {
        $null = New-Item -Path $Path -Force
    }
    $null = Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value -Force
}

function lns([string]$from, [string]$to) {
    $to = path_to_unix $to
    Write-Host ">> Linking : $from to $to"
    $null = New-Item -Path "$to" -ItemType SymbolicLink -Value "$from" -Force
}

# $global:custom_path = [Environment]::GetEnvironmentVariable('Path', "User")
# function add_to_env_path ([string] $folder_path) {
#     if ("$global:custom_path".Contains($folder_path)) {
#         return
#     }
#     Write-Host ">> Adding to PATH : $folder_path"
#     $env:PATH += ";$folder_path"
#     $global:custom_path += ";$folder_path"
#     [Environment]::SetEnvironmentVariable('Path', $global:custom_path, "User")
# }

function print_title([string]$title, [string]$subtitle = "") {
    Write-Host "`n============================================================"
    Write-Host ":: $title :: $subtitle"
    Write-Host "============================================================"
}

Write-Host "`n>>> SCRIPT BEGINING <<<`n"


### WINGET Packages
###############################################################################

print_title "Winget"

if ($PSVersionTable.PSVersion.Major -lt 7) {
    install_winget "Microsoft.PowerShell"               # Pwsh : Powershell 7
    sudo config --enable normal
    & pwsh.exe "$script_root\install.ps1"
    exit 0
}

# OS Tweaks
#---------------------
install_winget "Nilesoft.Shell"                         # NShell : Custom right-click menu
install_winget "Ditto.Ditto"                            # Ditto : Clipboard History
install_winget "QL-Win.QuickLook"                       # QuickLook : macos-like Preview
install_winget "voidtools.Everything"                   # Everything : The best file searcher
install_winget "voidtools.Everything.Cli"               #  ↪ Use 'es <query>' to use Everything Search from Terminal
install_winget "Flow-Launcher.Flow-Launcher"            # Laucher : Spotlight/Alfred like
install_winget "Microsoft.PowerToys"                    # PowerToys : FancyZones, Color Picker, OCR, ...
install_winget "9P8LTPGCBZXD" "WinToys"                 # WinToys : Settings Dashboard

# OS Utils
#---------------------
install_winget "Bitwarden.Bitwarden"                    # BitWarden
install_winget "7zip.7zip"                              # 7Zip
install_winget "ShareX.ShareX"                          # Better screenshots

# 7zip : Double-Click Simply Extract
$null = New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
$null = New-Item -path "HKCR:/Applications/7zG.exe/shell/open/command" -value "`"${env:ProgramFiles}\7-Zip\7zG.exe`" x `"%1`" -o* -aou" -Force

# Media
#---------------------
install_winget "Rufus.Rufus"                            # To burn ISOs onto USBs
install_winget "CodecGuide.K-LiteCodecPack.Full"        # KLite video code pack
install_winget "9NBLGGH42THS" "3D Previewer"            # 3D Previewer
install_winget "BlenderFoundation.Blender"              # Blender
install_winget "HandBrake.HandBrake"                    # HandBrake : Video Coder
install_winget "OBSProject.OBSStudio"                   # OBS Studio

# Communications
#---------------------
install_winget "XPFCS9QJBKTHVZ" "Spark Mail"            # Spark Mail
install_winget "Microsoft.Teams"                        # MS Teams
install_winget "TeamViewer.TeamViewer"                  # TeamViewer
install_winget "9NKSQGP7F2NH" "Whatsapp"                # Whatsapp
install_winget "SlackTechnologies.Slack"                # Slack

# Information
#---------------------
install_winget "SumatraPDF.SumatraPDF"                  # Sumatra : PDF Reader
install_winget "Brave.Brave"                            # Brave : A better Chrome
install_winget "Notion.Notion"                          # Notion
install_winget "Obsidian.Obsidian"                      # Obsidian

# Dev
#---------------------
install_winget "Microsoft.VisualStudioCode"             # VS Code

install_winget "Git.Git"                                # Git
install_winget "bmatzelle.Gow"                          # Linux Aliases
install_winget "gsass1.NTop"                            # htop for Windows
install_winget "junegunn.fzf"                           # htop for Windows
install_winget "sharkdp.bat"                            # like 'cat' but better
install_winget "eza-community.eza"                      # ls 2.0

install_winget "Starship.Starship"                      # Terminal prompt

install_winget "Python.Python.3.13"                     # Python 3.x
install_winget "ShiningLight.OpenSSL.Dev"               # OpenSSL

install_winget "Kitware.CMake"                          # CMake
install_winget "KhronosGroup.VulkanSDK"                 # Vulkan
install_winget "Microsoft.VisualStudio.2022.Community"  # Visual Studio (MSVC)

# Personal
#---------------------
install_winget "Valve.Steam"                            # Steam
install_winget "LocalSend.LocalSend"                    # AirDrop wannabe
install_winget "9PKTQ5699M62" "iCloud"                  # iCloud
##install_winget "RazerInc.RazerInstaller"          # Razer Lights


### MANUALLY : DOWNLOAD + INSTALL
###############################################################################

print_title "Direct Downloads"

unzip (download_to_temp "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip")
unzip (download_to_temp "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip")
unzip (download_to_temp "https://rubjo.github.io/victor-mono/VictorMonoAll.zip")

## OpenSSH
# if ($(Get-Service -Name ssh-agent).Name -lt 1) {
#     $openssh_msi = download_to_temp "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.2.2.0p1-Beta/OpenSSH-Win64-v9.2.2.0.msi"
#     Write-Host ">> Installing : OpenSSH"
#     Start-Process msiexec.exe -Wait -ArgumentList "/i $openssh_msi /passive"
# }


### POWERSHELL MODULES
###############################################################################

print_title "Pwsh Modules"

Import-Module PowerShellGet  1>$null 2>$null
install_module z
install_module posh-git


### REGISTRY
###############################################################################

print_title "Registry"

# Show hidden files
Write-Host ">> Activating: Show hidden files and folders"
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Windows/CurrentVersion/Explorer/Advanced" "Hidden" 1

# Show all extensions
Write-Host ">> Activating: Show all files extensions"
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Windows/CurrentVersion/Explorer/Advanced" "HideFileExt" 0

# Hide search box or icon from taskbar
Write-Host ">> Hiding: Search icon"
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Windows/CurrentVersion/Search" "SearchboxTaskbarMode" 0

# Hide virtual-desktops from taskbar
Write-Host ">> Hiding: Virtual-Desktops icon"
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Windows/CurrentVersion/Explorer/Advanced" "ShowTaskViewButton" 0

# Hide widgets from taskbar
Write-Host ">> Hiding: Widgets icon"
modify_reg_prop "HKLM:/SOFTWARE/Microsoft/PolicyManager/default/NewsAndInterests/AllowNewsAndInterests" "value" 0
modify_reg_prop "HKLM:/SOFTWARE/Policñies/Microsoft/Dsh" "AllowNewsAndInterests" 0

# Hide taskbar on non-primary screens
Write-Host ">> Hiding: Taskbar on non-primary screens"
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Windows/CurrentVersion/Explorer/Advanced" "MMTaskbarEnabled" 0

# Hide duplicate removable drives from navigation pane of File Explorer
Write-Host ">> Hiding: Duplicate drives"
Remove-Item "HKLM:/SOFTWARE/Microsoft/Windows/CurrentVersion/Explorer/Desktop/NameSpace/DelegateFolders/{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}" 1>$null 2>$null

# No telemetry
Write-Host ">> Disabling: Telemetry"
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Windows/CurrentVersion/AdvertisingInfo" "Enabled" 0
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Windows/CurrentVersion/Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" 0
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Speech_OneCore/Settings/OnlineSpeechPrivacy" "HasAccepted" 0
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Input/TIPC" "Enabled" 0
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/InputPersonalization" "RestrictImplicitInkCollection" 1
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/InputPersonalization" "RestrictImplicitTextCollection" 1
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/InputPersonalization/TrainedDataStore" "HarvestContacts" 0
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Personalization/Settings" "AcceptedPrivacyPolicy" 0
modify_reg_prop "HKLM:/SOFTWARE/Microsoft/Windows/CurrentVersion/Policies/DataCollection" "AllowTelemetry" 0
modify_reg_prop "HKCU:/SOFTWARE/Microsoft/Windows/CurrentVersion/Explorer/Advanced" "Start_TrackProgs" 0

# Enable 'end task' on taskbar
Write-Host ">> Enabling: 'End Task' form TaskBar"
modify_reg_prop "HKCU:/Software/Microsoft/Windows/CurrentVersion/Explorer/Advanced/TaskbarDeveloperSettings" "TaskbarEndTask" 1

# Only on laptops
if ($null -ne (Get-CimInstance -Class win32_battery)) {
    # Enable 'Hibernate After'
    Write-Host ">> Enable hibernate after"
    $power_settings_path = "HKLM:/SYSTEM/CurrentControlSet/Control/Power/PowerSettings"
    $key_a = "238C9FA8-0AAD-41ED-83F4-97BE242C8F20"
    $key_b = "9d7815a6-7ee4-497e-8888-515a05f02364"
    $hibernate_path = "$power_settings_path/$key_a/$key_b"
    modify_reg_prop $hibernate_path "Attributes" 2
}


### DEFENDER EXCLUSIONS
###############################################################################

print_title "Windows Defender Exclusions"

# Folders
Write-Host ">> Adding: Folders"
$folders_to_not_scan = @(
    "${home}\dev",
    "${env:SystemDrive}\Qt"
)

$folders_to_not_scan | ForEach-Object { Add-MpPreference -ExclusionPath $_ }

# Processes
Write-Host ">> Adding: Processes"
$process_to_not_scan = @(
    # Qt
    "qtcreator_processlauncher.exe",
    "qtcreator.exe",
    "clangd.exe",
    "clangd.exe",
    # Shells
    "pwsh.exe",
    "powershell.exe",
    "WindowsTerminal.exe",
    "git-bash.exe",
    "bash.exe"
    # VS
    "Code.exe",
    "vshost-clr2.exe",
    "VSInitializer.exe",
    "VSIXInstaller.exe",
    "VSLaunchBrowser.exe",
    "vsn.exe",
    "VsRegEdit.exe",
    "VSWebHandler.exe",
    "VSWebLauncher.exe",
    "XDesProc.exe",
    "Blend.exe",
    "DDConfigCA.exe",
    "devenv.exe",
    "FeedbackCollector.exe",
    "Microsoft.VisualStudio.Web.Host.exe",
    "mspdbsrv.exe",
    "MSTest.exe",
    "PerfWatson2.exe",
    "Publicize.exe",
    "QTAgent.exe",
    "QTAgent_35.exe",
    "QTAgent_40.exe",
    "QTAgent32.exe",
    "QTAgent32_35.exe",
    "QTAgent32_40.exe",
    "QTDCAgent.exe",
    "QTDCAgent32.exe",
    "StorePID.exe",
    "T4VSHostProcess.exe",
    "TailoredDeploy.exe",
    "TCM.exe",
    "TextTransform.exe",
    "TfsLabConfig.exe",
    "UserControlTestContainer.exe",
    "vb7to8.exe",
    "VcxprojReader.exe",
    "VsDebugWERHelper.exe",
    "VSFinalizer.exe",
    "VsGa.exe",
    "VSHiveStub.exe",
    "vshost.exe",
    "vshost32.exe",
    "vshost32-clr2.exe",
    "msbuild.exe",
    # VCS
    "git.exe"
)

$process_to_not_scan | ForEach-Object { Add-MpPreference -ExclusionProcess $_ }


### CAPABILITIES
###############################################################################

print_title "Capabilities"

# Enable OCR for all available languages
install_capabilites "Language.OCR" "en-GB,en-US,es-ES,fr-FR"


### LINKs
###############################################################################

print_title "Symbolic Links"

# Git Config
lns "$script_root\.gitconfig" "${home}\.gitconfig"
lns "$script_root\.gitignore" "${home}\.gitignore"

# Powershell Profile on Powershell 7.x
$documents = ([Environment]::GetFolderPath("MyDocuments"))
lns "$script_root\profile.ps1" "$documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# VSCode Config + Extensions
$vscode_config_path = path_to_unix "${env:APPDATA}\Code\User"
lns "$script_root\vscode\settings.json"    "${vscode_config_path}\settings.json"
lns "$script_root\vscode\keybindings.json" "${vscode_config_path}\keybindings.json"

# Windows Terminal Config
$local_appdata_pkgs = path_to_unix "${env:LOCALAPPDATA}\Packages"
$terminal_partial_path = "*Microsoft.WindowsTerminal*"
$terminals = (Get-ChildItem $local_appdata_pkgs -Name $terminal_partial_path)
foreach ($terminal in $terminals) {
    $terminal = path_to_unix "$local_appdata_pkgs\$terminal"
    $settings_path = "$terminal\LocalState\settings.json"
    lns "$script_root\terminal\settings.json" $settings_path
}
