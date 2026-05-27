# Control Center Module

A Quickshell control center inspired by the hyprzepyx widget panel.

## Files

```
control-center/
├── ControlCenter.qml         # Main panel
├── BarButton.qml             # Optional bar toggle button
├── Colors.qml                # Color palette (singleton)
├── qmldir                    # Registers Colors as singleton
└── widgets/
    ├── ToggleButton.qml      # Pill button (WiFi / Notif mode / Recording)
    ├── SliderRow.qml         # Volume / Mic / Brightness
    ├── SoundOutput.qml       # Expandable device picker
    ├── UserCard.qml          # Profile + uptime + settings + power
    └── NotificationsList.qml # Notifications panel
```

## Installation

1. Drop the whole `control-center/` folder into your dotfiles:
   ```bash
   cp -r control-center ~/dotfiles/quickshell/.config/quickshell/
   ```

2. Wire it into your `shell.qml`:
   ```qml
   import Quickshell
   import "bar" as Bar
   import "app-launcher" as Launcher
   import "notifications" as Notif
   import "theme-switcher" as TS
   import "control-center" as CC

   ShellRoot {
       TS.ThemeSwitcher { id: ts }
       Bar.Bar { theme: ts.theme }
       Launcher.AppLauncher { theme: ts.theme }
       Notif.NotificationPopup { theme: ts.theme }
       CC.ControlCenter { id: controlCenter }
   }
   ```

3. Add a Hyprland keybind to `~/.config/hypr/hyprland.conf`:
   ```
   bind = SUPER, N, exec, qs ipc call controlCenter toggle
   ```

4. Reload everything:
   ```bash
   hyprctl reload
   pkill quickshell && quickshell &
   ```

5. Press `SUPER + N`. The panel should appear at the top-right of your active screen.

## Adding a bar button (optional)

If you want a click-to-open button in your existing bar (instead of just the keybind), edit `bar/Bar.qml` and add the BarButton somewhere in the bar's row layout:

```qml
import "../control-center" as CC

// ... inside your bar's RowLayout:
CC.BarButton { }
```

## Required system packages

```bash
sudo pacman -S \
  wireplumber \      # provides wpctl (volume)
  brightnessctl \    # brightness
  networkmanager \   # nmcli (wifi name)
  pavucontrol \      # sound settings GUI
  wlogout            # power menu (or change powerProcess command)
```

Optional — `bc` for the brightness math (usually preinstalled).

## What works out of the box

- ✅ Volume slider — actually changes system volume via wpctl
- ✅ Mic slider — same, for the default input
- ✅ Brightness slider — uses brightnessctl
- ✅ Uptime — auto-updates every 30s
- ✅ Username — pulled from $USER on startup
- ✅ Avatar — reads `~/.face.jpg` if you set one (`cp photo.jpg ~/.face.jpg`)
- ✅ Power button — opens wlogout
- ✅ Settings gear — opens systemsettings (change in ControlCenter.qml if you don't use KDE)
- ✅ Sound Settings link — opens pavucontrol
- ✅ WiFi name — shows current active connection (read-only for now)
- ✅ Notification mode — visual cycle through Noisy / Quiet / DND (visual only)
- ✅ Recording indicator — toggle visual state

## What's stubbed (extend as you grow)

- ❌ WiFi toggle / network picker — currently opens `nm-connection-editor`. If you want an in-panel network picker, you'd build a network list widget that calls `nmcli` to list/connect.
- ❌ Notification mode actually doing something — wire to `makoctl mode` or similar if you use mako.
- ❌ Recording control — wire to start/stop a `wf-recorder` process.
- ❌ Sound output device list — currently shows current device only. Extend with a `Process` that runs `wpctl status` and parses sinks.
- ❌ Notifications list — empty state only. To populate, import `Quickshell.Services.Notifications` and bind to `NotificationServer`. Stub is marked in `NotificationsList.qml`.

## Customization

**Colors:** edit `Colors.qml`. All widgets reference the singleton, so changes propagate everywhere.

**Width:** edit `implicitWidth: 360` in `ControlCenter.qml`.

**Position:** edit the `anchors` and `margins` blocks in `ControlCenter.qml`. To put it on the left, swap `right: true` for `left: true` and adjust the right margin.

**Bar offset:** if your bar is, say, 40px tall, set `margins.top: 44` (bar height + 4px gap).

**Fonts:** the QML references `"Hack Nerd Font"` throughout. Search-and-replace to swap.

**Icons:** every icon is a Nerd Font glyph. To find more, install `nerd-fonts-cheat-sheet` or browse https://www.nerdfonts.com/cheat-sheet — copy the glyph character directly into the QML.

## Suggested commits

```bash
cd ~/dotfiles
git add quickshell/.config/quickshell/control-center
git commit -m "Add control center module: panel + widgets"

# After wiring into shell.qml:
git add quickshell/.config/quickshell/shell.qml
git commit -m "Wire control center into shell"

# After adding keybind:
git add hypr/.config/hypr/hyprland.conf
git commit -m "Hyprland: bind SUPER+N to control center toggle"
```

## Troubleshooting

**Panel doesn't appear:**
- Check that IPC is registered: `qs ipc show` should list `controlCenter`
- Run `quickshell` in a foreground terminal and watch for QML errors
- Make sure the `qmldir` file is present in the `control-center/` folder

**Volume slider moves but volume doesn't change:**
- Verify `wpctl` works: `wpctl get-volume @DEFAULT_AUDIO_SINK@`
- If you use PulseAudio (not PipeWire), swap `wpctl` for `pactl` calls

**Brightness slider doesn't work:**
- Need `brightnessctl` installed
- May need to add yourself to the `video` group: `sudo usermod -aG video $USER`, then log out/in
- Check: `brightnessctl get`

**No avatar shows:**
- Place a JPEG at `~/.face.jpg`
- The fallback shows the first letter of your username on a colored circle

**Panel cuts off at the bottom on a small screen:**
- Reduce `Layout.fillHeight` on `NotificationsList` or set a max height on the panel
