@echo off

rem WIP!!!

md $env:USERPROFILE\.vim\autoload\
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" -Outfile "$env:USERPROFILE\.vim\autoload\plug.vim"
