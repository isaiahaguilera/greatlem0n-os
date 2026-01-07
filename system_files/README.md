# System Files

This directory contains system-level configuration files that get copied directly into the OS image during build. It follows the Universal Blue pattern used in Bluefin's modular OCI architecture.

## Structure

```
system_files/
└── shared/
    └── etc/
        ├── polkit-1/
        │   └── rules.d/
        │       └── *.rules          # PolicyKit authorization rules
        └── udev/
            └── rules.d/
                └── *.rules          # Device access rules
```

The `shared/` directory mirrors the root filesystem structure. Files are copied with:
```bash
cp -r /ctx/system_files/shared/* /
```

This means `system_files/shared/etc/polkit-1/rules.d/90-example.rules` becomes `/etc/polkit-1/rules.d/90-example.rules` in the final image.

## Adding System Files

### PolicyKit Rules

PolicyKit rules control authorization for system operations. Place `.rules` files in:
```
system_files/shared/etc/polkit-1/rules.d/
```

Example use cases:
- Remote desktop permissions
- Package manager authorization
- Hardware access control

### Udev Rules

Udev rules control device permissions and hardware access. Place `.rules` files in:
```
system_files/shared/etc/udev/rules.d/
```

Example use cases:
- Wheel group hardware access
- Custom device permissions
- USB device handling

### Other System Files

You can add any system configuration files by mirroring their final path:
- `/usr/share/` configs → `system_files/shared/usr/share/`
- `/etc/` configs → `system_files/shared/etc/`

## Why This Pattern?

This structure aligns with Universal Blue's modular architecture:

1. **Matches Bluefin OCI pattern** - When migrating to modular architecture, OCI containers use `system_files/shared/`
2. **Clear organization** - Mirrors actual filesystem layout
3. **Future-proof** - Ready for modular migration
4. **Explicit** - Easy to see what files go where

## Current System Files

### PolicyKit Rules

**`90-remote-desktop-permissions.rules`** - Remote Desktop (RDP) Authorization

Mirrors local behavior to remote sessions for wheel users. Fixes password prompts that don't appear when physically at the machine:

- **Pre-session**: Flatpak metadata updates, RDP login helpers
- **Active session**: NetworkManager, Flatpak operations, GNOME Control Center, Bluetooth, audio devices, color management, power operations
- **GVFS admin**: Allows `admin:///` in GNOME Files with proper authentication

**Philosophy**: Only mirrors actions that wheel users can do locally without password. Never suppresses prompts that would appear locally.

**Security**: All rules require wheel group membership. Session-based rules require active session. File operations require authentication (AUTH_ADMIN_KEEP).

### Udev Rules

**`90-wheel-hardware-access.rules`** - Hardware Access for Remote Sessions

Grants wheel users direct hardware access when connecting via RDP/SSH. Default `TAG=="uaccess"` only works for local sessions, causing permission denied errors remotely.

**Devices granted access**:
- Radio controls (`/dev/rfkill`) - WiFi/Bluetooth toggles
- Serial devices (`/dev/ttyUSB*`, `/dev/ttyACM*`) - Arduino, ESP32, serial consoles
- Video capture (`/dev/video*`) - Webcams, capture cards
- USB devices (`/dev/bus/usb/*`) - Firmware flashing, diagnostics
- Block devices (`/dev/sda`, `/dev/nvme*`) - Disk management, mounting
- Input devices (`/dev/input/*`) - Controllers, input remapping
- GPIO/embedded (`/dev/gpiochip*`, `/dev/spidev*`, `/dev/i2c-*`) - Raspberry Pi, sensors
- DRM/GPU (`/dev/dri/*`) - Graphics utilities, display config

**Permissions**: `MODE="0664"` (owner: rw, group: rw, others: r)

**Companion file**: Works with `90-remote-desktop-permissions.rules` for complete remote desktop functionality.

### Fastfetch Branding

**`fastfetch.json`** - Custom fastfetch logo configuration
**`fastfetch.jsonc`** - Default fastfetch layout, labels, and colors

Sets a custom logo directory and enables random logo selection:

- Config: `system_files/shared/etc/greatlem0n-os/fastfetch.json`
- Layout: `system_files/shared/usr/share/greatlem0n-os/fastfetch.jsonc`
- Wrapper: `system_files/shared/usr/bin/greatlem0n-fastfetch`
- Bling helper: `system_files/shared/usr/bin/greatlem0n-bling-fastfetch` (enabled via `FASTFETCH_USE_BLING=1`)
- Shell aliases: `system_files/shared/etc/profile.d/ublue-fastfetch.sh`
- Fish aliases: `system_files/shared/usr/share/fish/vendor_conf.d/ublue-fastfetch.fish`
- Logo assets: `system_files/shared/usr/share/greatlem0n-os/lemon-logos/symbols_custom/`
- Example logo: `TwoThumbsUpLemon.ansi`

## Migration Note

The `custom/` directory is still used for Brewfiles, Flatpaks, and ujust commands. Eventually, those may migrate to `system_files/` to fully align with Universal Blue patterns, but for now:

- **System configs** (polkit, udev, etc.) → `system_files/shared/`
- **App configs** (brew, flatpak, ujust) → `custom/`

See [CLAUDE.md](../CLAUDE.md) for the long-term modular migration vision.
