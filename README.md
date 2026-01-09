# greatlem0n-os

[![Build Stable Image](https://github.com/isaiahaguilera/greatlem0n-os/actions/workflows/build.yml/badge.svg)](https://github.com/isaiahaguilera/greatlem0n-os/actions/workflows/build.yml)

A custom bootc operating system image based on [Universal Blue](https://universal-blue.org/) and [Bluefin](https://projectbluefin.io). Built from the finpilot template with system configuration management and remote desktop optimizations.

## What Makes this Image Different?

This image is based on [Bluefin](https://projectbluefin.io) and includes these customizations:

### System Configuration
- **Remote Desktop Optimizations**: PolicyKit rules to mirror local behavior to RDP sessions for wheel users
  - NetworkManager, Flatpak, GNOME settings, Bluetooth, power operations work seamlessly over RDP
  - No password prompts for actions that don't require them locally
- **Hardware Access for Remote Sessions**: Udev rules granting wheel users direct hardware access over RDP/SSH
  - WiFi/Bluetooth toggles, USB devices, video capture, block devices, GPIO, DRM/GPU access
  - Eliminates "permission denied" errors for remote admin users
- **Container Signature Policy**: Require sigstore signatures for `ghcr.io/isaiahaguilera/greatlem0n-os` pulls using the repo public key
- **Sigstore Registry Attachments**: Enable cosign signature discovery for `ghcr.io/isaiahaguilera/greatlem0n-os`
- **Fastfetch Branding**: Custom logo directory with shuffle enabled, labeled key layout + percent palette, plus `/usr/bin` wrapper + shell/fish aliases (GNOME accent “bling” now opt-in)

### Added Packages (Build-time)
- Core system packages and services (see `build/02-system-config.sh` and `build/04-packages.sh`)
- Visual Studio Code from the official Microsoft repository for development work
- Ghostty terminal from the `scottames/ghostty` COPR

### Added Applications (Runtime)
- **CLI Tools (Homebrew)**: Brewfiles for development tools, fonts, and utilities (see `custom/brew/`). Includes fzf, shellcheck, and bbrew.
- **VS Code Extensions (Homebrew)**: Managed via `custom/brew/vscode.Brewfile` with a ujust installer.
- **GUI Apps (Flatpak)**: Flatpak preinstall configuration (see `custom/flatpaks/`)

### Configuration Files
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

*Last updated: 2026-01-08*

## Build Features

Custom enhancements added to this image:

- **System Files Management**: Universal Blue pattern for polkit/udev rules (see `system_files/`)
- **Explicit Build Script Runner**: `build.sh` declares scripts in explicit order for clarity and control (Bluefin pattern)
- **Modular Architecture Support**: `Containerfile.experimental` for testing modular OCI composition
- **Manual Disk Image Builder**: GitHub Actions workflow for on-demand ISO and QCOW2 builds
- **AI Assistant Integration**: Comprehensive AGENTS.md and CLAUDE.md for development guidance

## What's Included

### Build System
- Automated builds via GitHub Actions on every push to main
- Self-hosted Renovate updates base images and dependencies every 6 hours
- Automatic cleanup of old images (90+ days)
- Single-branch workflow: All commits to `main` build `:stable` images
- Validation workflows for code quality:
  - Brewfile, Justfile, ShellCheck, Renovate config, Flatpak ID verification
- Production features:
  - Container signing with cosign
  - SBOM generation (disabled by default)
  - Layer rechunking (disabled by default)

### Homebrew Integration
- Pre-configured Brewfiles for easy package installation and customization
- Includes curated collections: development tools, fonts, CLI utilities. Go nuts.
- Users install packages at runtime with `brew bundle`, aliased to premade `ujust commands`
- See [custom/brew/README.md](custom/brew/README.md) for details

### Flatpak Support
- Ship your favorite flatpaks
- Automatically installed on first boot after user setup
- See [custom/flatpaks/README.md](custom/flatpaks/README.md) for details

### Rechunker
- Optimizes container image layer distribution for better download resumability
- Based on [hhd-dev/rechunk](https://github.com/hhd-dev/rechunk) v1.2.4
- Disabled by default for faster initial builds
- Enable in `.github/workflows/build.yml` by uncommenting the rechunker steps (see comments in file)
- Recommended for production deployments after initial testing

### ujust Commands
- User-friendly command shortcuts via `ujust`
- Pre-configured examples for app installation and system maintenance for you to customize
- See [custom/ujust/README.md](custom/ujust/README.md) for details

### Build Scripts
- Explicit script runner (`build.sh`) for clarity and control
- Organized scripts: system config (02), packages (04), applications (11+)
- Example scripts in `build/examples/` for third-party repositories and desktop replacement
- Helper functions for safe COPR usage
- See [build/README.md](build/README.md) for details

## Quick Start

### Customize the Image

Add build-time packages in `build/04-packages.sh`:
```bash
dnf5 install -y package-name
```

Add system configuration files in `system_files/shared/`:
```
system_files/shared/etc/
├── polkit-1/rules.d/     # PolicyKit rules
└── udev/rules.d/         # Device permissions
```

Customize runtime apps:
- Add Brewfiles in `custom/brew/` ([guide](custom/brew/README.md))
- Add Flatpaks in `custom/flatpaks/` ([guide](custom/flatpaks/README.md))
- Add ujust commands in `custom/ujust/` ([guide](custom/ujust/README.md))

### Development Workflow

1. Make changes to the repository
2. Test locally (see "Local Testing" below)
3. Commit with conventional commit format (e.g., `feat: add new package`)
4. Push to `main` - GitHub Actions builds `:stable` image automatically

### Deploy the Image

Switch to this image:
```bash
sudo bootc switch ghcr.io/isaiahaguilera/greatlem0n-os:stable
sudo systemctl reboot
```

## Optional: Enable Image Signing

Image signing is disabled by default to let you start building immediately. However, signing is strongly recommended for production use.

### Why Sign Images?

- Verify image authenticity and integrity
- Prevent tampering and supply chain attacks
- Required for some enterprise/security-focused deployments
- Industry best practice for production images

### Setup Instructions

1. Generate signing keys:
```bash
cosign generate-key-pair
```

This creates two files:
- `cosign.key` (private key) - Keep this secret
- `cosign.pub` (public key) - Commit this to your repository

2. Add the private key to GitHub Secrets:
   - Copy the entire contents of `cosign.key`
   - Go to your repository on GitHub
   - Navigate to Settings → Secrets and variables → Actions ([GitHub docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository))
   - Click "New repository secret"
   - Name: `SIGNING_SECRET`
   - Value: Paste the entire contents of `cosign.key`
   - Click "Add secret"

3. Replace the contents of `cosign.pub` with your public key:
   - Open `cosign.pub` in your repository
   - Replace the placeholder with your actual public key
   - Commit and push the change

4. Enable signing in the workflow:
   - Edit `.github/workflows/build.yml`
   - Find the "OPTIONAL: Image Signing with Cosign" section.
   - Uncomment the steps to install Cosign and sign the image (remove the `#` from the beginning of each line in that section).
   - Commit and push the change

5. Your next build will produce signed images!

Important: Never commit `cosign.key` to the repository. It's already in `.gitignore`.

## Additional Features

Optional features available for enhanced security and reliability:

### Rechunker (Disabled)

Optimizes image layer distribution for better download resumability.

To enable:
1. Edit `.github/workflows/build.yml`
2. Uncomment the "Run Rechunker" step (around line 121)
3. Uncomment the "Load in podman and tag" step
4. Comment out the "Tag for registry" step

### SBOM Attestation (Disabled)

Generates Software Bill of Materials for supply chain transparency.

Requires image signing to be enabled first. To enable:
1. Complete image signing setup above
2. Edit `.github/workflows/build.yml`
3. Uncomment the "Add SBOM Attestation" step (around line 232)

### Image Verification

Once signing is enabled, verify images with:
```bash
cosign verify --key cosign.pub ghcr.io/isaiahaguilera/greatlem0n-os:stable
```

## Detailed Guides

- [Homebrew/Brewfiles](custom/brew/README.md) - Runtime package management
- [Flatpak Preinstall](custom/flatpaks/README.md) - GUI application setup
- [ujust Commands](custom/ujust/README.md) - User convenience commands
- [Build Scripts](build/README.md) - Build-time customization

## Local Testing

Test your changes before pushing:

```bash
just build              # Build container image
just build-qcow2        # Build VM disk image
just run-vm-qcow2       # Test in browser-based VM
```

## Community

- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc Discussion](https://github.com/bootc-dev/bootc/discussions)

## Learn More

- [Universal Blue Documentation](https://universal-blue.org/)
- [bootc Documentation](https://containers.github.io/bootc/)
- [Video Tutorial by TesterTech](https://www.youtube.com/watch?v=IxBl11Zmq5wE)

## Security

Security features available:
- Image signing with cosign (enabled)
- SBOM generation (disabled - see "Additional Features")
- Automated security updates via Renovate (enabled)
- Build provenance tracking via GitHub Actions
