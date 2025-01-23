
# Arch Linux Notes

### Avoid app autostart

- https://bbs.archlinux.org/viewtopic.php?pid=2169885#p2169885


```shell
rm ~/.config/autostart/electron.desktop              # get rid of the actual autostart
touch ~/.config/autostart/electron.desktop           # cretate a file to block the space
sudo chattr +i ~/.config/autostart/electron.desktop  # avoid any app to modify the file
```
