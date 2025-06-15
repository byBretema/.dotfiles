# .dotfiles

> dotfiles for Linux (CachyOS + Zsh) and Windows (Pure PowerShell 7 + Strong Linux vibes)

- Donwload repo onto `$home/.dotfiles`  (*remove `.git` folder*)
- Read `install` script carefully and adapt it to your needs

*Then just run it:*

#### Linux

```bash
    chsh -s /usr/bin/zsh  # Sets ZSH as your default shell  (might need a logout to be applied)
    ./linux/install.sh -u -i -l
```

#### Windows

```powershell
    Set-ExecutionPolicy Bypass -Scope Process  # Allows unsigned scripts on current terminal
    ./windows/install.ps1
```

---

#### ToDo

- [ ] Move to `common` folder, configs of: alacritty, ghostty, tmux
    - [ ] Update the `install` scripts.
- [ ] Try to update the windows scripts.

---

#### Helpers

##### SSH KeyGen
```bash
ssh-keygen -t ed25519
paru -S --needed --noconfirm xclip
cat .ssh/id_ed25519.pub | xclip -selection c
```
