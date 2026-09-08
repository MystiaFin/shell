# Quickshell Configuration

My personal Quickshell desktop shell for the Niri compositor.

## Preview

https://github.com/user-attachments/assets/62e414de-d074-45df-8447-c3d34149c136

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
- kitty remote control for live terminal recoloring; kitty must listen on
  `unix:@quickshell-kitty` and permit remote control
- `pkill` for switching running foot instances to the generated light or dark
  palette
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
- `${XDG_DATA_HOME:-$HOME/.local/share}/themes/QuickshellDynamicLight/` with
  `index.theme`, `gtk-3.0/gtk.css`, and `gtk-4.0/gtk.css`
- `${XDG_DATA_HOME:-$HOME/.local/share}/themes/QuickshellDynamicDark/` with the
  same GTK files
- `${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0/gtk.css`, linked to the active
  variant for libadwaita clients such as the GNOME portal file picker
- `${XDG_CONFIG_HOME:-$HOME/.config}/vesktop/settings/quickCss.css`, with a
  managed Quickshell block that Vencord reloads live
- `${XDG_CACHE_HOME:-$HOME/.cache}/quickshell-theme/spotify.css`, served only
  on `127.0.0.1:17384` for the Spicetify theme extension
- `${XDG_CONFIG_HOME:-$HOME/.config}/btop/themes/quickshell.theme`
- `${XDG_CONFIG_HOME:-$HOME/.config}/cava/themes/quickshell`

The terminal files are overwritten atomically. The shell then asks kitty at
`unix:@quickshell-kitty` to reload the generated kitty palette and signals
running foot instances to select the generated light or dark palette.

The GTK directories are created with `mkdir -p`. Every export rewrites both
wallpaper-derived variants. Quickshell selects light or dark mode from the
wallpaper palette's average luminance, activates the corresponding GTK theme,
and synchronizes the desktop color-scheme preference. The GNOME portal backend
is restarted after the GTK4 user stylesheet changes because libadwaita does not
load custom GTK theme names. Generated files and the wallpaper selection are
intentionally ignored by Git.

Vesktop keeps user-written Quick CSS outside the `quickshell-theme` marker
block. Spotify's Nix-built files remain immutable; a Home Manager user service
serves the generated CSS and the bundled Spicetify extension refreshes it while
Spotify is running.
