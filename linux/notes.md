
# Linux Notes
> I use Arch btw!

## CHEATSHEET

### Avoiding app autostart

- https://bbs.archlinux.org/viewtopic.php?pid=2169885#p2169885


```shell
disable_autostart() {
    fp="$HOME/.config/autostart/$1.desktop"
    rm $fp              # Get rid of the actual autostart
    touch $fp           # Cretate a file to block the space
    sudo chattr +i $fp  # Avoid any app to modify the file
}

# i.e.
disable_autostart "electron"
```

