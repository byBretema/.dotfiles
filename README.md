# .dotfiles

> dotfiles for Linux (CachyOS + Zsh) and Windows (Pure PowerShell 7 + Strong Linux vibes)

- Donwload/Clone repo onto `$home/.dotfiles`  (*remove `.git` folder*)
- Read `install` script carefully and adapt it to your needs

*Then just run it:*

#### Linux

```bash
./linux/install.sh -u -i -l
```

#### Windows
> Actually outdated

```powershell
# Allows unsigned scripts on current terminal
Set-ExecutionPolicy Bypass -Scope Process
./windows/install.ps1
```

#### References

- https://ricoberger.de/cheat-sheets/yazi/

#### ToDo

- [ ] Try to update the windows scripts.
- [ ] https://github.com/shapeshed/dotfiles/blob/main/local/bin/toggle-theme

#### HELPERS

-  *SSH KeyGen*

    ```bash
    ssh-keygen -t ed25519
    paru -S --needed --noconfirm xclip
    cat .ssh/id_ed25519.pub | xclip -selection c
    ```
