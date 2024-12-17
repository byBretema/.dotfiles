
param (
    [Parameter(Mandatory = $false)] [switch] $OverwriteWithCurrentExtensions
)

# Gather extensions from file + current
$exts_file = "$home\.dotfiles\vscode\extensions.txt"
$exts_prev = (Get-Content $exts_file)
$exts_curr = (code --list-extensions)

if ($OverwriteWithCurrentExtensions) {
    $exts_clean = $exts_curr
}
else {
    $exts_clean = $exts_prev + $exts_curr | Sort-Object -Unique
}

# Update file
$exts_clean | Out-File -FilePath $exts_file -Encoding utf8

# Constructs the command
$command = "code"
foreach ($ext in $exts_clean) {
    $command += " --install-extension `"$ext`" --force"
}

# Run the command
Invoke-Expression $command
