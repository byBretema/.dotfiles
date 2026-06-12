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

function process_winget_list([string]$list_file) {
    Get-Content $list_file | ForEach-Object {
        $line = $_.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith("#")) {
            return
        }
        install_winget $line
    }
}

function install_font([string]$url, [string]$font_name) {
    $zip = download_to_temp $url "${font_name}.zip"
    $extract_path = "${env:TEMP}\${font_name}_fonts"
    Write-Host ">> Installing font : $font_name"
    Remove-Item -Recurse $extract_path -Force 2>$null
    $null = Start-Process -FilePath "${env:ProgramFiles}\7-Zip\7zG.exe" -ArgumentList "x `"$zip`" -o`"$extract_path`" -aou" -PassThru -Wait
    $font_dest = "$env:SYSTEMROOT\Fonts"
    Get-ChildItem -Path $extract_path -Recurse -Include "*.ttf", "*.otf" | ForEach-Object {
        $dest = Join-Path $font_dest $_.Name
        if (-not (Test-Path $dest)) {
            Copy-Item $_.FullName $font_dest
        }
    }
    Write-Host ">> Font installed : $font_name"
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
    install_winget "Microsoft.PowerShell"
    sudo config --enable normal
    & pwsh.exe "$script_root\install.ps1"
    return
}

process_winget_list "$script_root\winget_install.conf"

# 7zip : Double-Click Simply Extract
$null = New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
$null = New-Item -path "HKCR:/Applications/7zG.exe/shell/open/command" -value "`"${env:ProgramFiles}\7-Zip\7zG.exe`" x `"%1`" -o* -aou" -Force


### FONTS
###############################################################################

print_title "Fonts"

install_font "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/VictorMono.zip" "VictorMono"

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

$configs = "$script_root\..\configs"

# Git Config
lns "$configs\.gitconfig" "${home}\.gitconfig"
lns "$configs\.gitignore" "${home}\.gitignore"

# VSCode Config + Extensions
$vscode_config_path = path_to_unix "${env:APPDATA}\Code\User"
lns "$configs\vscode\settings.json"    "${vscode_config_path}\settings.json"
lns "$configs\vscode\keybindings.json" "${vscode_config_path}\keybindings.json"

# Starship Prompt
$starship_dir = "${home}\.config\starship"
$null = New-Item -ItemType Directory -Path $starship_dir -Force
lns "$configs\starship.toml" "$starship_dir\starship.toml"

# Alacritty (if installed)
$alacritty_dir = "${env:APPDATA}\alacritty"
$null = New-Item -ItemType Directory -Path $alacritty_dir -Force
lns "$configs\alacritty.toml" "$alacritty_dir\alacritty.toml"

# Helix (if installed)
$helix_dir = "${env:APPDATA}\helix"
$null = New-Item -ItemType Directory -Path $helix_dir -Force
lns "$configs\helix\config.toml"     "$helix_dir\config.toml"
lns "$configs\helix\languages.toml"  "$helix_dir\languages.toml"
$helix_themes = "$helix_dir\themes"
$null = New-Item -ItemType Directory -Path $helix_themes -Force
foreach ($theme in (Get-ChildItem "$configs\helix\themes\*.toml")) {
    lns $theme.FullName "$helix_themes\$($theme.Name)"
}

# Flameshot (if installed)
$flameshot_dir = "${home}\.config\flameshot"
$null = New-Item -ItemType Directory -Path $flameshot_dir -Force
lns "$configs\flameshot.ini" "$flameshot_dir\flameshot.ini"

# Yazi (if installed)
$yazi_dir = "${env:APPDATA}\yazi"
$null = New-Item -ItemType Directory -Path $yazi_dir -Force
lns "$configs\yazi\themes\theme.toml" "$yazi_dir\theme.toml"

# Qt Creator Themes (if installed)
$qtc_styles = "${home}\.config\QtProject\qtcreator\styles"
$null = New-Item -ItemType Directory -Path $qtc_styles -Force
foreach ($xml in (Get-ChildItem "$configs\qtcreator\themes\*.xml")) {
    lns $xml.FullName "$qtc_styles\$($xml.Name)"
}

# Clang Format
lns "$configs\.clang-format" "${home}\.clang-format"

# WorkTrunk
$worktrunk_dir = "${home}\.config\worktrunk"
$null = New-Item -ItemType Directory -Path $worktrunk_dir -Force
lns "$configs\worktrunk.toml" "$worktrunk_dir\worktrunk.toml"

# Powershell Profile on Powershell 7.x
$documents = ([Environment]::GetFolderPath("MyDocuments"))
lns "$script_root\profile.ps1" "$documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# Windows Terminal Config
$local_appdata_pkgs = path_to_unix "${env:LOCALAPPDATA}\Packages"
$terminal_partial_path = "*Microsoft.WindowsTerminal*"
$terminals = (Get-ChildItem $local_appdata_pkgs -Name $terminal_partial_path)
foreach ($terminal in $terminals) {
    $terminal = path_to_unix "$local_appdata_pkgs\$terminal"
    $settings_path = "$terminal\LocalState\settings.json"
    lns "$script_root\terminal\settings.json" $settings_path
}
