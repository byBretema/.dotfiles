# .dotfiles

> dotfiles for Linux (CachyOS + Fish, Bash/Zsh kept in parity) and Windows (Pure PowerShell 7 + Strong Linux vibes)

- Clone the repo into `~/.dotfiles` (keep `.git`: `--set-git-filters` needs it)
- Read `install` script carefully and adapt it to your needs

*Then just run it:*

#### Linux

```bash
./linux/install.sh --all
```

#### Windows
> Actually outdated

```powershell
# Allows unsigned scripts on current terminal
Set-ExecutionPolicy Bypass -Scope Process
./win/install.ps1
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
    wl-copy < ~/.ssh/id_ed25519.pub
    ```
