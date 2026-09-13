<div align="center">
  <h1>JAQC-shell</h1>
  <p><strong>Just Another Quickshell Config.</strong><br>
  An opinionated Wayland desktop shell built with Quickshell and QML for Niri.</p>

  <p>
    <img alt="Quickshell 0.3" src="https://img.shields.io/badge/QUICKSHELL-0.3-89b4fa?style=flat-square&labelColor=181825">
    <img alt="Niri" src="https://img.shields.io/badge/COMPOSITOR-NIRI-89b4fa?style=flat-square&labelColor=181825">
    <img alt="QML" src="https://img.shields.io/badge/UI-QML-89b4fa?style=flat-square&labelColor=181825">
  </p>
</div>

## Preview

https://github.com/user-attachments/assets/7d3009c8-16a1-4e49-a7e0-bc08de7df022

## Overview

JAQC-shell is my personal Quickshell configuration: a complete desktop shell rather than a collection of disconnected widgets.

### Included

- Status bar with workspaces, system information, clock, media, and connectivity
- Application launcher with a `>` command mode
- Control center and utility panels
- Notification center
- Wallpaper picker with animated transitions
- Wallpaper-derived dynamic color palette
- Desktop overview and floating widgets
- Power menu
- Built-in settings window
- Optional theme integrations for GTK, terminals, tmux, Vesktop, Spotify, btop, and cava

## Installation

Clone the repository as your Quickshell config:

```sh
git clone https://github.com/MystiaFin/shell.git ~/.config/quickshell
```

Then launch it:

```sh
qs
```

> [!NOTE]
> This config is built around Niri. Some components depend directly on Niri IPC and are not expected to work unchanged on other compositors.

## Dependencies

### Required

- **Quickshell 0.3** with the Wayland, networking, Bluetooth, notifications, and I/O modules used by the config
- **Niri** with `NIRI_SOCKET` available
- **Poppins**
- **JetBrains Mono Nerd Font**
- **Symbols Nerd Font**
- **Material Design Icons**
- **ImageMagick 7**
- **curl**

### Optional

These are only needed for their corresponding features:

| Package | Used for |
| --- | --- |
| `cava` | Media visualizer |
| `wpctl` / WirePlumber | Volume and microphone control |
| `brightnessctl` | Display brightness |
| `kitty` remote control | Live kitty palette updates |
| `dconf` | GTK theme switching |
| `tmux` | Generated tmux palette integration |

## Launcher

The launcher handles normal application search and also acts as a small command palette.

Type `>` to switch into command mode. Commands can expose things such as:

- Settings
- Wallpapers
- Tmux sessions
- Other shell actions

The available command entries can be enabled or disabled from **Settings → Launcher**.

<details>
<summary><strong>Launcher IPC</strong></summary>

```sh
qs ipc call launcher toggle
qs ipc call launcher show
qs ipc call launcher hide
qs ipc call launcher setVisible true
qs ipc call launcher getVisible
```

</details>

## Wallpapers & colors

By default the wallpaper picker reads images from:

```text
$XDG_PICTURES_DIR/Wallpapers
```

or, when `XDG_PICTURES_DIR` is not set:

```text
~/Pictures/Wallpapers
```

JPEG, PNG, and WebP files are supported.

The selected wallpaper is persisted in:

```text
~/.config/quickshell/wallpaper-selection
```

The wallpaper can also drive the shell's dynamic palette. Wallpaper transitions, shuffle behavior, palette synchronization, and color preferences are configurable from the settings window.

<details>
<summary><strong>Wallpaper IPC</strong></summary>

```sh
qs ipc call wallpaper toggle
qs ipc call wallpaper show
qs ipc call wallpaper hide
qs ipc call wallpaper setVisible true
qs ipc call wallpaper getVisible
```

</details>

## Settings

The shell includes its own settings window instead of requiring QML edits for normal day-to-day preferences.

Current sections include:

- Appearance
- Colors
- Launcher
- Wallpaper
- Status bar
- Behavior
- Floating widgets
- Animations
- Integrations
- About

Settings are stored in:

```text
~/.config/quickshell/settings.json
```

## Theme integrations

External theme integrations are **opt-in**. Enabling one may generate configuration files or update a running application, so the shell does not enable them automatically.

Supported integrations currently include:

- GTK 3 / GTK 4
- kitty
- foot
- tmux
- Vesktop
- Spotify / Spicetify
- btop
- cava

<details>
<summary><strong>Generated files and side effects</strong></summary>

Depending on which integrations are enabled, JAQC-shell may generate files under your Quickshell config, user theme directory, application config directories, or cache directory.

Examples include:

```text
~/.config/quickshell/terminal-colors-kitty.conf
~/.config/quickshell/terminal-colors-foot.ini
~/.config/quickshell/tmux-colors.conf
~/.config/btop/themes/quickshell.theme
~/.config/cava/themes/quickshell
~/.cache/quickshell-theme/spotify.css
```

GTK integration also generates light and dark wallpaper-derived themes under `~/.local/share/themes/` and updates the active color-scheme preference.

For tmux, add this to `~/.tmux.conf` so new sessions load the generated palette:

```tmux
source-file -q ~/.config/quickshell/tmux-colors.conf
```

</details>

## Weather

The desktop overview reads its location from the ignored local file:

```text
~/.config/quickshell/weather-location.json
```

Example:

```json
{
  "latitude": 0.0,
  "longitude": 0.0,
  "locationName": "City"
}
```

Using approximate city-center coordinates is enough. Weather data is fetched directly from Open-Meteo; no IP geolocation service is used.

## Project structure

```text
components/      shared shell primitives, state, effects, and theme code
services/        settings, wallpaper, and background services
widgets/         launcher, bar, notifications, settings, overview, etc.
integrations/    external theme/application integration logic
shaders/         compiled visual effects and wallpaper transitions
icons/           shell icon assets
shell.qml        root configuration
```

## Notes

This is a personal config that I daily-drive and keep changing. Expect opinions, occasional breakage, and features that exist because I wanted them on my own desktop.

If you use it as a base for your own setup, reading and modifying the QML is very much part of the experience.

