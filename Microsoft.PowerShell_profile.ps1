
### -----------------------LOAD---------------------- ###

# Avoid "Microsoft Copyright spam"!
Clear-Host

# Git info.
Import-Module posh-git

# Hack consoleZ "open in the same directory"
if(Test-Path "C:\lastpath.txt") {
    Get-Content "C:\lastpath.txt" | Set-Location
}

### ----------------------PROMPT--------------------- ###

function prompt {

    # Hack consoleZ "open in the same directory"
    (Get-Location).Path | Out-File "C:\lastpath.txt"

    # Title Vars...
    $usu = $env:username
    $dom = $env:userdomain
    # Write title...
    $host.UI.RawUI.WindowTitle = "[$usu] @ $dom"

    # Prompt Vars...
    $cd = (Get-Location).Path
    $time = (Get-Date).ToLongTimeString()
    if(Get-GitStatus) { $sep = "`n " } else { $sep = " " }
    # Write prompt...
    Write-Host ""
    Write-Host "$(Write-VcsStatus)" -NoNewline
    Write-Host "$sep" -NoNewline
    Write-Host "[" -ForegroundColor Gray -NoNewline
    Write-Host "$time" -ForegroundColor Magenta -NoNewline
    Write-Host "]" -ForegroundColor Gray -NoNewline
    Write-Host " @ " -ForegroundColor Gray -NoNewline
    Write-Host "[" -ForegroundColor Gray -NoNewline
    Write-Host "$cd" -ForegroundColor Blue -NoNewline
    Write-Host "]" -ForegroundColor Gray
    Write-Host " >" -ForegroundColor White -NoNewline
    "` "
}

### -------------------FUNCTIONS--------------------- ###

# QuickGitPush: the args are the string to commit.
function qgp {
    git add -A
    git commit -m "$args"
    git push
}

# Alias to git status resume and branch indicator.
function gst { git status -sb }

# Hack powershell 'ls' with git bash binaries.
function l { ls.exe -AFGh --color --group-directories-first }
function ll { ls.exe -AFGhl --color --group-directories-first }
function lt { ls.exe -AFGhlR --color --group-directories-first }

# Open explorer windows on current directory.
function oo { explorer (Get-Location).Path }

# Quick access to home directory.
function ho { Set-Location $env:userprofile }
