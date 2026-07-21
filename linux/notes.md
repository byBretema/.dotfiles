
# Linux Notes
> I use Arch btw!

## CHEATSHEET

### Avoiding app autostart

https://bbs.archlinux.org/viewtopic.php?pid=2169885#p2169885


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

## GPU SELECTION

Settings to place on `/etc/environment`

"Disable" Nvidia, prefer iGPU:  *(TODO: Check if works the same for integrated AMD/Intel)*
```
__NV_PRIME_RENDER_OFFLOAD=0

__GLX_VENDOR_LIBRARY_NAME="mesa"
__EGL_VENDOR_LIBRARY_FILENAMES="/usr/share/glvnd/egl_vendor.d/50_mesa.json"

__VK_LAYER_NV_optimus="non_NVIDIA_only"
VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/radeon_icd.x86_64.json"
VK_DRIVER_FILES="/usr/share/vulkan/icd.d/radeon_icd.x86_64.json"
```

"Enable" Nvidia, prefer dGPU:  *(TODO: Check the same for dedicated AMD)*
```
__NV_PRIME_RENDER_OFFLOAD=1

__GLX_VENDOR_LIBRARY_NAME="nvidia"
__EGL_VENDOR_LIBRARY_FILENAMES="/usr/share/glvnd/egl_vendor.d/10_nvidia.json"

__VK_LAYER_NV_optimus="NVIDIA_only"
VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/nvidia_icd.json"
VK_DRIVER_FILES="/usr/share/vulkadfn/icd.d/nvidia_icd.json"

## DRM-COLORTEMP — Screen Temperature

A workaround for color temperature control on COSMIC DE (until native gamma lands). Uses direct DRM manipulation via TTY switching.

### Usage

| Action | Keys |
|--------|------|
| Auto (time-based) | `Ctrl+Alt+F3` then back to your TTY |
| Force warm (night) | `Ctrl+Alt+F4` then back |
| Force cool (day) | `Ctrl+Alt+F5` then back |

After switching to the monitor TTY, immediately switch back — the daemon applies gamma when COSMIC releases the DRM lock.

### Config

`/etc/default/drm-colortemp.conf` (symlinked from `linux/assets/drm-colortemp/drm-colortemp.conf`)

| Key | Default | Description |
|-----|---------|-------------|
| `DAY_TEMP` | 6500 | Daytime temperature (K) |
| `NIGHT_TEMP` | 3500 | Nighttime temperature (K) |
| `SUNSET_HOUR` | 20 | When to switch to night |
| `SUNRISE_HOUR` | 8 | When to switch to day |


## MX MASTER 3 — Solaar Setup

After installing/running `install.sh -l`:

1. **Log out and back in** — Solaar autostarts via XDG desktop file
2. **Open Solaar GUI** — find your MX Master 3, click the padlock icon to unlock diversion mode
3. **Set "Mouse Gesture Button" → "Mouse Gestures"** — enables directional gesture events
4. Verify rules.yaml is linked: `~/.config/solaar/rules.yaml`

Solaar's `KeyPress` actions work on Wayland via uinput. The gesture rules live in `~/.config/solaar/rules.yaml` (symlinked to `linux/assets/solaar/rules.yaml`).

## COSMIC — Get window app_id

Lists all running windows and their `app_id` (useful for tiling exception rules). The target app must be running to show up.

```shell
uv tool run cosmic-ext-window-helper state
```

## SSH_AUTH_SOCK not set

If you see `SSH_AUTH_SOCK not set` briefly on session start (e.g., in TTY), the fix is to enable `gcr-ssh-agent`:

```shell
systemctl --user enable --now gcr-ssh-agent.socket
systemctl --user enable --now gcr-ssh-agent.service
```

After enabling, the SSH socket appears at `$XDG_RUNTIME_DIR/keyring/ssh` and `SSH_AUTH_SOCK` is set automatically.

To verify:
```shell
echo $SSH_AUTH_SOCK
# Should output: /run/user/$UID/keyring/ssh
```

## SKIP-WORKTREE (local git changes)

Ignore local diffs on a tracked file (won't show in `git st`, won't be committed):
```shell
git update-index --skip-worktree <file>
```

To revert: `git update-index --no-skip-worktree <file>`

List all skipped files: `git ls-files -v | grep ^S`

## LOGIN KEYRING NOT UNLOCKED (cosmic-greeter)

After switching from GDM to `cosmic-greeter`, apps (Slack, etc.) prompt for the login keyring password because `pam_gnome_keyring.so` is not in greetd's PAM stack.

### Fix

Add `pam_gnome_keyring.so` to `/etc/pam.d/greetd`:

```shell
sudo cp /etc/pam.d/greetd /etc/pam.d/greetd.bak

echo '#%PAM-1.0

auth       required     pam_securetty.so
auth       requisite    pam_nologin.so
auth       include      system-local-login
auth       optional     pam_gnome_keyring.so
account    include      system-local-login
session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start' | sudo tee /etc/pam.d/greetd
```

Then log out and back in (or reboot) for the PAM config to take effect.

### Verify module installed

```shell
ls /usr/lib/security/pam_gnome_keyring.so
```

```
