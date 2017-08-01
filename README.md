<p align="center">
	<img src="logo.png" height="250" width="250">
	<br>
</p>

<br>

## 1. Emulator: [λ Cmder](http://cmder.net/)

- Use _**Download full**_ option to get it with _git-for-windows_.

- Extract `cmder\` folder and copy it to `C:\`

- Open a poweshell tab.

- Link settings:
  - **GUI:**
    ```powershell
    $g_path = ".\ConEmu.xml"
    $h_path = "$env:ConEmuDir\ConEmu.xml"
    if ( Test-Path $h_path )  { Remove-Item $h_path }
    New-Item -Path $h_path -ItemType SymbolicLink -Value  $g_path
    ```
  - **Powershell:**
    ```powershell
    $g_path = ".\user-profile.ps1"
    $h_path = "$env:CMDER_ROOT\config\user-profile.ps1"
    if ( Test-Path $h_path )  { Remove-Item $h_path }
    New-Item -Path $h_path -ItemType SymbolicLink -Value  $g_path
    ```

- Change computer name:

  ```powershell
  Rename-Computer <ComputerName>
  ```


<br>

## 2. Modules, scoop and chocolatey.

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
```

### Install chocolatey.

```powershell
Invoke-WebRequest https://chocolatey.org/install.ps1 `
	-UseBasicParsing | Invoke-Expression
```

Now you can use: `choco search <PartialAppName>` to search an application.

And later use: `choco install -fyr <FullAppName>` to install the application.

### Install scoop.
```powershell
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
```
```powershell
scoop bucket add extras
```

Now you can use: `scoop search <PartialAppName>` to search an application.

And later use: `scoop install <FullAppName>` to install the application.

<br>

### 3. Link other configs.
```powershell
# Link .vimrc
$g_path = ".\.vimrc"
$h_path = "$env:userprofile\.vimrc"
if ( Test-Path $h_path )     { Remove-Item $h_path }
New-Item -Path $h_path -ItemType SymbolicLink -Value $g_path

# Link .gitignore
$g_path = "..\.gitignore"
$h_path = "$env:userprofile\.gitignore"
if ( Test-Path $h_path )     { Remove-Item $h_path }
New-Item -Path $h_path -ItemType SymbolicLink -Value $g_path

# Link .gitconfig
$g_path = "..\.gitconfig"
$h_path = "$env:userprofile\.gitconfig"
if ( Test-Path $h_path )     { Remove-Item $h_path }
New-Item -Path $h_path -ItemType SymbolicLink -Value $g_path
```

### Plugin manager for vim!

```powershell
$vimAutoload = "$env:USERPROFILE\vimfiles\autoload"
Remove-Item -r $vimAutoload 2>$null
New-Item -ItemType Directory $vimAutoload

Invoke-WebRequest`
    -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"`
    -Outfile "$vimAutoload\plug.vim"
```
<br>

### 4. Pretty tips.


#### SSD good practices.
	fsutil behavior set disabledeletenotify NTFS 0
	fsutil behavior set disabledeletenotify ReFS 0

> I ignore how to do the next via powershell so I have written the GUI process.

- Disable `Index` on `Computer > SSD Properties > General`.
- Disable `Optimizer` on `Computer > SSD Properties > Tools`.
- Disable `Protection` on `Adv System > System Protection`.
- Disable `VirtualMem` on `Adv System > Performance > Adv options`.
- Disable `EnablePrefetcher` on `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters`.

#### File Explorer stuff. (via GUI)

> Into a explorer window.

- Switch to `This computer` the `View > Options > Open explorer` select.
- Uncheck `Recently` and `Frequently` on `View > Options > Privacity` at dialog bottom.

