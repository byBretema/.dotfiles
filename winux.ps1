# Ensure Get-ExecutionPolicy is not restricted!
Set-ExecutionPolicy RemoteSigned -s cu

# A PowerShell environment for Git!
PowerShellGet\Install-Module posh-git -Scope CurrentUser

md $env:USERPROFILE\.vim\autoload\
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -Outfile "$env:USERPROFILE\.vim\autoload\plug.vim"

# A command-line installer for Windows!
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
scoop bucket add extras


# end-user stuff
scoop install 7zip
scoop install vlc
scoop install cpu-z
scoop install putty
scoop install slack
scoop install write
scoop install mplayer
scoop install telegram
scoop install mediainfo
scoop install filezilla
scoop install imagemagick
scoop install thunderbird
scoop install sublime-text
scoop install chromedriver

# sys tools
scoop install hub
scoop install nmap
scoop install msys
scoop install lynx
scoop install nuget

# unix tools
scoop install ag
scoop install ln
scoop install sed
scoop install say
scoop install kvm
scoop install time
scoop install sudo
scoop install gawk
scoop install grep
scoop install less
scoop install curl
scoop install touch
scoop install cowsay
scoop install openjdk
scoop install openssh
scoop install openssl
scoop install diffutils
scoop install findutils
scoop install coreutils

# dev tools
scoop install dig
scoop install adb
scoop install make
scoop install ctags
scoop install cmake
scoop install ffmpeg
scoop install doxygen
scoop install busybox
scoop install mercurial

# servers
scoop install devd
scoop install caddy
scoop install nginx
scoop install apache

# langs
scoop install r
scoop install go
scoop install gcc
scoop install lua
scoop install php
scoop install ruby
scoop install rust
scoop install mono
scoop install latex
scoop install python
scoop install nodejs
scoop install erlang
scoop install haskell

# frameworks
scoop install hugo
scoop install maven

# databases
scoop install redis
scoop install mysql
scoop install sqlite
scoop install mongodb
scoop install mariadb
scoop install csvtosql
scoop install postgresql

scoop install tar
scoop install telnet


scoop install forge
scoop install iconv
scoop install nssm
scoop install optipng
scoop install packer
scoop install pdftk
scoop install scala
scoop install shasum
scoop install vim
scoop install webp
scoop install wget
scoop install which
scoop install youtube-dl
scoop install gifcam
scoop install gitextensions
scoop install gvim
scoop install handle
scoop install heroku-cli
scoop install jkrypto
scoop install ngrok
scoop install pandoc
scoop install whois
scoop install winmerge
scoop install wifi-manager


# Link consoleZ profile.
mklink  C:\consoleZ\console.xml .\console.xml

# Link powershell profile.
mklink $env:userprofile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 .\Microsoft.PowerShell_profile.ps1

# Link git config and default ignore list.
mklink $env:userprofile\.gitignore .\.gitignore
mklink $env:userprofile\.gitconfig .\.gitconfig

# Link vim config.
mklink $env:userprofile\.vimrc .\.vimrc
