# Quickshell Configuration

A personal Quickshell desktop shell for the Niri compositor. It provides a
per-screen status bar, application launcher, control and utility centers,
notifications, wallpaper selection, wallpaper-derived colors, and liquid edge
effects.

The current environment uses Quickshell 0.3.0. See [ARCHITECTURE.md](ARCHITECTURE.md)
for ownership and dependency rules and [scripts/check.sh](scripts/check.sh) for
static validation.

## Dependencies

Required for the intended desktop:

- Quickshell 0.3 with the Wayland, networking, Bluetooth, notifications, and I/O
  modules used by the source
- Niri, including the `NIRI_SOCKET` environment variable for workspace IPC
- Linux `/proc` and `/sys` interfaces for CPU, memory, and battery data
- Poppins for text
- JetBrains Mono Nerd Font for most icons
- Material Design Icons, declared by the shared typography contract
- Symbols Nerd Font for workspace symbols

Optional feature integrations:

- `playerctl` for MPRIS metadata and media controls
- `cava` for the media visualizer
- `wpctl` with WirePlumber for output and microphone volume
- `brightnessctl` for display brightness
- `wlogout` for the power menu
- kitty remote control for live terminal recoloring; kitty must listen on
  `unix:@quickshell-kitty` and permit remote control
- `dconf` for selecting the generated GTK theme

Developer validation requires `git`, `bash`, `cmp`, and Qt's `qsb`. The check
script also uses `qmlformat` and `qmllint` when they are installed.

## Run

```sh
quickshell -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
```

Do not use startup as a validation command: startup performs the theme export
side effects described below.

## Launcher IPC

The launcher exposes the `launcher` IPC target. For the default configuration:

```sh
quickshell ipc call launcher toggle
quickshell ipc call launcher show
quickshell ipc call launcher hide
quickshell ipc call launcher setVisible true
quickshell ipc call launcher getVisible
```

If the configuration was started from another path, select the same instance
with `quickshell ipc -p /path/to/config call launcher toggle`.

## Wallpapers

The picker reads image files from `$XDG_PICTURES_DIR/Wallpapers`. If
`XDG_PICTURES_DIR` is unset, it uses `$HOME/Pictures/Wallpapers`. Quoted values
and literal `$HOME` or `${HOME}` segments in `XDG_PICTURES_DIR` are expanded.
The directory is not created automatically. The picker accepts JPEG, PNG, and
WebP files and defaults to `wallpaper_2.jpg` in that directory.

Applying a wallpaper writes its file URL to
`${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/wallpaper-selection`. That file is
loaded on the next start; an empty or missing file selects the default image.
The wallpaper drives the dynamic shell palette and is revealed on every screen
with the compiled wallpaper shader.

## Generated Themes And Side Effects

At startup and after relevant theme colors change, the shell generates:

- `${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/terminal-colors-kitty.conf`
- `${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/terminal-colors-foot.ini`
- `${XDG_DATA_HOME:-$HOME/.local/share}/themes/QuickshellDynamicOne/` with
  `index.theme`, `gtk-3.0/gtk.css`, and `gtk-4.0/gtk.css`
- `${XDG_DATA_HOME:-$HOME/.local/share}/themes/QuickshellDynamicTwo/` with the
  same GTK files

The terminal files are overwritten atomically. The shell then asks kitty at
`unix:@quickshell-kitty` to reload the generated kitty palette. It does not
invoke foot.

The GTK directories are created with `mkdir -p`. Exports alternate between the
two generated theme names, overwrite their files, and run `dconf write` on
`/org/gnome/desktop/interface/gtk-theme` so GTK observes a theme-name change.
This changes the user's current GTK theme setting. Generated files and the
wallpaper selection are intentionally ignored by Git.
