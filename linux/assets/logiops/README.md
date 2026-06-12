# logiops-rs config

## Requirements

- `logiops-rs` package — provides `logiops` daemon
- `ydotool` package — fallback for key injection if uinput

## Why direct keypress (not ydotool)?

`logiops-rs` injects key events via `uinput`. On some Wayland compositors this may
not work (synthetic input is sometimes filtered). If the gestures don't reach the
compositor, the simplest fallback is calling `ydotool` through an external trigger
(e.g. a udev rule or a wrapper that monitors the device).

## Config breakdown

### smartshift

```toml
[devices.smartshift]
on = false
```

Disables Logitech's automatic ratchet/free-spin toggle. The wheel stays in whatever
physical position you set it to (clicky or free-spin).

### gestures

Bound to the **gesture button** (`cid = 0x00c4` — the recessed button below the main
scroll wheel on the MX Master 3).

| Action | Effect |
|--------|--------|
| Hold + move ↑ | Super + k (Cosmic: workspace up) |
| Hold + move ↓ | Super + j (Cosmic: workspace down) |
| Hold + move ← | Volume down |
| Hold + move → | Volume up |

Keys used in TOML:
- `KEY_LEFTMETA` = Super
- `KEY_K` / `KEY_J` = workspace navigation
- `KEY_VOLUMEDOWN` / `KEY_VOLUMEUP` = volume

### hiresscroll

```toml
[devices.hiresscroll]
hires = true
invert = false
```

Enables high-resolution scrolling.
