<p align="center"> <img src="logo.png" height="450" width="450"> </p>

## Via POWERSHELL

> The bottom text is a brief orientation on how I have set up my environment, feel free to follow the "guide" or just read and hack the files that are of interest to you :)

### Computer name...
	Rename-Computer <computerName>

### Ensure Get-ExecutionPolicy is not restricted!
	Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

### Trust on PSGallery repository.
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

### A PowerShell environment for Git!
	PowerShellGet\Install-Module -Force posh-git -Scope CurrentUser

### Plugin manager for vim!
	$vimAutoload = "$env:USERPROFILE\vimfiles\autoload"

	Remove-Item -r $vimAutoload 2>$null
	New-Item -ItemType Directory $vimAutoload

	Invoke-WebRequest`
	    -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"`
	    -Outfile "$vimAutoload\plug.vim"

### Chocolatey.

#### 1. Install chocolatey.
	Invoke-WebRequest https://chocolatey.org/install.ps1 `
		-UseBasicParsing | Invoke-Expression

#### 2. Install apps via chocolatey.

> I've got my apps listed on " .\apps\choco.txt ", write yours.

> The `Where-Object { $_ -ne "" }` let you separate the list with blank lines.

	$(Get-Content .\apps\choco.txt) | Where-Object { $_ -ne "" } |
	    ForEach-Object {
	        choco install -fyr --allow-empty-checksums $_ 2>$null
	    }
### Scoop

#### 1. Install scoop.
	iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

#### 2. Add extra packages from scoop-extra repo.
	scoop bucket add extras

#### 3. Install tools via scoop.

> I've got my apps listed on " .\apps\choco.txt ", write yours.

> The `Where-Object { $_ -ne "" }` let you separate the list with blank lines.

	$(Get-Content .\apps\scoop.txt) | Where-Object { $_ -ne "" } |
	    ForEach-Object {
	        scoop install -a 64bit $_ 2>$null
	    }

### Link configs.

#### 1. Paths from this repo.
	$g_consoleZ = ".\console.xml"
	$g_profile = ".\Microsoft.PowerShell_profile.ps1"
	$g_vimrc = "..\.vimrc"
	$g_gitignore = "..\.gitignore"
	$g_gitconfig = "..\.gitconfig"

#### 2. Paths on your machine (verify before...)
	$h_consoleZ = "$env:ConsoleZSettingsDir\console.xml"
	$h_profile = "$env:userprofile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
	$h_vimrc = "$env:userprofile\.vimrc"
	$h_gitingore = "$env:userprofile\.gitignore"
	$h_gitconfig = "$env:userprofile\.gitconfig"

#### 3. Remove previous config (if you want...)
	if ( Test-Path $h_consoleZ )  { Remove-Item $h_consoleZ }
	if ( Test-Path $h_profile )   { Remove-Item $h_profile }
	if ( Test-Path $h_vimrc )     { Remove-Item $h_vimrc }
	if ( Test-Path $h_gitingore ) { Remove-Item $h_gitingore }
	if ( Test-Path $h_gitconfig ) { Remove-Item $h_gitconfig }

#### 4. Finally link the config files.
	New-Item -Path $h_consoleZ -ItemType SymbolicLink -Value  $g_consoleZ
	New-Item -Path $h_profile -ItemType SymbolicLink -Value $g_profile
	New-Item -Path $h_vimrc -ItemType SymbolicLink -Value $g_vimrc
	New-Item -Path $h_gitingore -ItemType SymbolicLink -Value $g_gitignore
	New-Item -Path $h_gitconfig -ItemType SymbolicLink -Value $g_gitconfig

### Sublime settings.

#### 1. Clone my sublime_env repo.
	git clone https://github.com/cambalamas/sublime_env

#### 2. Paths from the repo.
	$g_sublU = ".\sublime_env\Packages\User"
	$g_sublD = ".\sublime_env\Packages\Default"

#### 3. Paths on your machine (verify before...)
	$h_sublU = "$env:userprofile\AppData\Roaming\Sublime Text 3\Packages\User"
	$h_sublD = "$env:userprofile\AppData\Roaming\Sublime Text 3\Packages\Default"

#### 4. Check to remove before link the config files.
	foreach ( $file in (ls $g_sublU).name ) {
	    if ( Test-Path "$h_sublU\$file" ) { Remove-Item -r $h_sublU\$file }
	    New-Item -Path $h_sublU\$file -ItemType SymbolicLink -Value $g_sublU\$file
	}

	foreach ( $file in (ls $g_sublD).name ) {
	    if ( Test-Path "$h_sublD\$file" ) { Remove-Item -r $h_sublD\$file }
	    New-Item -Path $h_sublD\$file -ItemType SymbolicLink -Value $g_sublD\$file
	}

### File Explorer stuff. (via GUI)

> Into a explorer window.

- Switch to `This computer` the `View > Options > Open explorer` select.
- Uncheck `Recently` and `Frequently` on `View > Options > Privacity` at dialog bottom.

### SSD good practices.
	fsutil behavior set disabledeletenotify NTFS 0
	fsutil behavior set disabledeletenotify ReFS 0

> I ignore how to do the next via powershell so I have written the GUI process.

- Disable `Index` on `Computer > SSD Properties > General`.
- Disable `Optimizer` on `Computer > SSD Properties > Tools`.
- Disable `Protection` on `Adv System > System Protection`.
- Disable `VirtualMem` on `Adv System > Performance > Adv options`.
- Disable `EnablePrefetcher` on `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters`.

### Windows services !!!

***[ BE CAREFUL, DO NOT RUN IF YOU DO NOT KNOW THE EFFECTS OF THESE LINES. ]***

> I've got my services filtered on " .\services "

> With a `whiteList.txt`, those services that always will run.

> And a `blackList.txt`, those services that prefer disabled.

> Rewrite those files adapting to your needs.

	# Manual startup (all the files to manual to be able to filter them).
	(Get-Service).Name |
	    ForEach-Object {
	        Set-Service -StartupType Manual -Name $_ 2>$null
	    }

	# Disable startup.
	$(Get-Content .\services\blackList.txt) | Where-Object { $_ -ne "" } |
	    ForEach-Object {
	        Set-Service -StartupType Disabled -Name $_ 2>$null
	    }

	# Automatic startup.
	$(Get-Content .\services\whiteList.txt) | Where-Object { $_ -ne "" } |
	    ForEach-Object {
	        Set-Service -StartupType Automatic -Name $_ 2>$null
	    }
