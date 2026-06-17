# greatlem0n-os

[![Build Stable Image](https://github.com/isaiahaguilera/greatlem0n-os/actions/workflows/build.yml/badge.svg)](https://github.com/isaiahaguilera/greatlem0n-os/actions/workflows/build.yml)

A custom bootc operating system image based on [Universal Blue](https://universal-blue.org/) and [Bluefin](https://projectbluefin.io). Built from the [finpilot template](https://github.com/ublue-os/finpilot) with system configuration management and remote desktop optimizations.

## What Makes this Image Different?

This image is based on [Bluefin](https://projectbluefin.io) and includes these customizations:

### System Configuration
- **Remote Desktop Optimizations**: PolicyKit rules to mirror local behavior to RDP sessions for wheel users
  - NetworkManager, Flatpak, GNOME settings, Bluetooth, power operations work seamlessly over RDP
  - No password prompts for actions that don't require them locally
- **Hardware Access for Remote Sessions**: Udev rules granting wheel users direct hardware access over RDP/SSH
  - WiFi/Bluetooth toggles, USB devices, video capture, block devices, GPIO, DRM/GPU access
  - Eliminates "permission denied" errors for remote admin users
- **SSH Brute Force Protection**: fail2ban with escalating bans (1h → 1 day → 1 week → 1 month)
  - Monitors sshd via systemd journal, bans via firewalld rich rules
  - Automatic ban escalation for repeat offenders
- **Container Signature Policy**: Require sigstore signatures for `ghcr.io/isaiahaguilera/greatlem0n-os` pulls using the repo public key
- **Sigstore Registry Attachments**: Enable cosign signature discovery for `ghcr.io/isaiahaguilera/greatlem0n-os`
- **Fastfetch Branding**: Custom logo directory with shuffle enabled, labeled key layout + percent palette, plus `/usr/bin` wrapper + shell/fish aliases (GNOME accent "bling" now opt-in)
- **Tailscale Exit Node**: IP forwarding enabled (`net.ipv4.ip_forward`, `net.ipv6.conf.all.forwarding`) so this device can optionally serve as a Tailscale exit node — toggle via `ujust tailscale-exit-node`

### Added Packages (Build-time)
- Core system packages and services (see `build/02-system-config.sh` and `build/04-packages.sh`)
- Visual Studio Code from the official Microsoft repository for development work
- Ghostty terminal from the `scottames/ghostty` COPR

### Added Applications (Runtime)
- **CLI Tools (Homebrew)**: Brewfiles for development tools, fonts, and utilities (see `custom/brew/`). Includes shell enhancements (eza, starship, fzf, zoxide), development tools (shellcheck, cosign), and package management (bbrew).
- **VS Code Extensions (Homebrew)**: Managed via `custom/brew/vscode.Brewfile` with a ujust installer. Includes themes (Catppuccin), AI assistants (Claude Code, GitHub Copilot), and utilities (color-highlight).
- **GUI Apps (Flatpak)**: Flatpak preinstall configuration (see `custom/flatpaks/`). Includes productivity apps (Foliate ebook reader) and GNOME utilities.

### Configuration Files
- `system_files/shared/etc/fail2ban/jail.local`
- `system_files/shared/etc/polkit-1/rules.d/90-remote-desktop-permissions.rules`
- `system_files/shared/etc/udev/rules.d/90-wheel-hardware-access.rules`
- `system_files/shared/etc/containers/registries.d/greatlem0n-os.yaml`
- `system_files/shared/etc/greatlem0n-os/fastfetch.json`
- `system_files/shared/usr/share/greatlem0n-os/fastfetch.jsonc`
- `system_files/shared/usr/bin/greatlem0n-fastfetch`
- `system_files/shared/usr/bin/greatlem0n-bling-fastfetch`
- `system_files/shared/etc/profile.d/ublue-fastfetch.sh`
- `system_files/shared/usr/share/fish/vendor_conf.d/ublue-fastfetch.fish`
- `system_files/shared/usr/share/greatlem0n-os/lemon-logos/symbols_custom/TwoThumbsUpLemon.ansi`
- `system_files/shared/etc/pki/containers/greatlem0n-os.pub`
- `system_files/shared/etc/sysctl.d/99-tailscale.conf`

*Last updated: 2026-06-17*

## Quick Start

### Deploy the Image

Switch to this image:
```bash
sudo bootc switch ghcr.io/isaiahaguilera/greatlem0n-os:stable
sudo systemctl reboot
```

### Customize for Your Needs

This image is built from the [finpilot template](https://github.com/ublue-os/finpilot). For detailed customization instructions, see:

- **[AGENTS.md](AGENTS.md)** - Comprehensive development guide with examples and patterns
- **[finpilot template README](https://github.com/ublue-os/finpilot#readme)** - Template features, image signing, rechunker, SBOM, and more

Quick customization overview:
- **Build-time packages**: Edit `build/04-packages.sh` (see [build/README.md](build/README.md))
- **System configs**: Add files to `system_files/shared/` (see [system_files/README.md](system_files/README.md))
- **Runtime CLI tools**: Edit Brewfiles in `custom/brew/` (see [custom/brew/README.md](custom/brew/README.md))
- **GUI apps**: Edit Flatpak preinstall in `custom/flatpaks/` (see [custom/flatpaks/README.md](custom/flatpaks/README.md))
- **User commands**: Add ujust recipes in `custom/ujust/` (see [custom/ujust/README.md](custom/ujust/README.md))

### Local Testing

Test your changes before pushing:

```bash
just build              # Build container image
just build-qcow2        # Build VM disk image
just run-vm-qcow2       # Test in browser-based VM
```

## Build System

- Automated builds via GitHub Actions on every push to main (`:stable` tag)
- Self-hosted Renovate updates base images and dependencies every 6 hours
- Automatic cleanup of old images (90+ days)
- Validation workflows for code quality (shellcheck, Brewfile, Flatpak ID verification)
- Image signing with cosign (enabled)
- SBOM generation and rechunker (disabled by default, see [finpilot template](https://github.com/ublue-os/finpilot#readme))

## Resources

### Documentation
- [AGENTS.md](AGENTS.md) - Complete development guide for this image
- [Universal Blue Documentation](https://universal-blue.org/)
- [bootc Documentation](https://containers.github.io/bootc/)
- [Bluefin Documentation](https://docs.projectbluefin.io/)
- [finpilot Template](https://github.com/ublue-os/finpilot)

### Community
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc Discussion](https://github.com/bootc-dev/bootc/discussions)

### Video
- [Video Tutorial by TesterTech](https://www.youtube.com/watch?v=IxBl11Zmq5wE)
