
param (
    [Parameter(Mandatory = $false)] [switch] $i, # Install
    [Parameter(Mandatory = $false)] [switch] $u, # Update
    [Parameter(Mandatory = $false)] [switch] $o  # Overwrite
)

$exts_file = "$home\.dotfiles\vscode\extensions.txt"
$exts_prev = (Get-Content $exts_file)
$exts_curr = (code --list-extensions)

# Install
#----------------------------
if ($i) {
    $command = "code"
    foreach ($ext in $exts_clean) {
        $command += " --install-extension `"$ext`" --force"
    }
    Invoke-Expression $command
}

# Update
#----------------------------
if ($o) {
    $exts_clean = $exts_curr
}
else {
    $exts_clean = $exts_prev + $exts_curr | Sort-Object -Unique
}
if ($o -or $u) {
    $exts_clean | Out-File -FilePath $exts_file -Encoding utf8
}
