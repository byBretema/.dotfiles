# Ensure Get-ExecutionPolicy is not restricted!
Set-ExecutionPolicy RemoteSigned -s cu

# A PowerShell environment for Git!
PowerShellGet\Install-Module posh-git -Scope CurrentUser

md $env:USERPROFILE\.vim\autoload\
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -Outfile "$env:USERPROFILE\.vim\autoload\plug.vim"

# A command-line installer for Windows!
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
scoop bucket add extras
scoop install 7zip
scoop install adb
scoop install ag
scoop install apache
scoop install busybox
scoop install caddy
scoop install chromedriver
scoop install cmake
scoop install concfg
scoop install coreutils
scoop install cowsay
scoop install csvtosql
scoop install ctags
scoop install curl
scoop install devd
scoop install diffutils
scoop install dig
scoop install doxygen
scoop install erlang
scoop install ffmpeg
scoop install findutils
scoop install forge
scoop install gawk
scoop install gcc
scoop install go
scoop install grep
scoop install haskell
scoop install hub
scoop install hugo
scoop install iconv
scoop install imagemagick
scoop install kvm
scoop install latex
scoop install less
scoop install ln
scoop install lua
scoop install lynx
scoop install make
scoop install mariadb
scoop install maven
scoop install mediainfo
scoop install mercurial
scoop install mongodb
scoop install mono
scoop install msys
scoop install mysql
scoop install nginx
scoop install nmap
scoop install nodejs
scoop install nssm
scoop install nuget
scoop install openjdk
scoop install openssh
scoop install openssl
scoop install optipng
scoop install packer
scoop install pdftk
scoop install php
scoop install postgresql
scoop install python
scoop install r
scoop install redis
scoop install ruby
scoop install rust
scoop install say
scoop install scala
scoop install sed
scoop install shasum
scoop install sqlite
scoop install sudo
scoop install tar
scoop install telnet
scoop install time
scoop install touch
scoop install vim
scoop install webp
scoop install wget
scoop install which
scoop install youtube-dl
scoop install cpu-z
scoop install filezilla
scoop install gifcam
scoop install gitextensions
scoop install gvim
scoop install handle
scoop install heroku-cli
scoop install jkrypto
scoop install mplayer
scoop install ngrok
scoop install pandoc
scoop install putty
scoop install slack
scoop install sublime-text
scoop install telegram
scoop install thunderbird
scoop install vlc
scoop install whois
scoop install wifi-manager
scoop install winmerge
scoop install write


# Link powershell profile.
mklink $env:userprofile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 .\Microsoft.PowerShell_profile.ps1

# Link consoleZ profile.
mklink  C:\consoleZ\console.xml .\console.xml


# Link git config and default ignore list.
mklink $env:userprofile\.gitignore .\.gitignore
mklink $env:userprofile\.gitconfig .\.gitconfig

# Link vim config.
mklink $env:userprofile\.vimrc .\.vimrc
