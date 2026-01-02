# Claude Code Instructions for greatlem0n-os

This repository builds a custom bootc operating system image based on Universal Blue/Bluefin.

## Primary Instructions

**See [AGENTS.md](AGENTS.md) for comprehensive development guidelines.**

The AGENTS.md file contains detailed instructions for:
- Repository structure and file organization
- Where to add packages (build-time vs runtime)
- Conventional commit requirements
- Validation workflows
- Common patterns and examples

## Critical Quick Reference

### Pre-Commit Checklist
1. **Conventional Commits** - ALL commits MUST follow format: `<type>: <description>`
2. **Shellcheck** - Run on all modified `.sh` files
3. **YAML validation** - Validate modified YAML files
4. **Justfile syntax** - Verify with `just --list`
5. **Confirm with user** - Always confirm before committing

### Key Rules
- **ALWAYS** use `dnf5` exclusively (never `dnf`, `yum`, `rpm-ostree`)
- **ALWAYS** disable COPRs after use (use `copr_install_isolated` function)
- **NEVER** commit `cosign.key` to repository
- **NEVER** use `dnf5` in ujust files - only Brewfile/Flatpak shortcuts
- **ALWAYS** update "What's Different" section in README.md when modifying packages/configs

### Trust But Verify Workflow
When user reports changes made outside Claude Code:
1. User briefly describes what they changed
2. **Verify** by reading the actual files to confirm changes
3. Update README sections based on verified findings:
   - **"What's Different"**: For OS packages, apps, or system config changes
   - **"Template Features"**: For build infrastructure or workflow changes
4. Update the "Last updated" date (for "What's Different" only)
5. Report back what was found and documented

### Package Locations
- **Build-time** (baked into image): `build/10-build.sh` - use `dnf5 install -y`
- **Runtime CLI tools**: `custom/brew/*.Brewfile` - Homebrew packages
- **Runtime GUI apps**: `custom/flatpaks/*.preinstall` - Flatpak applications
- **User commands**: `custom/ujust/*.just` - shortcuts (NO dnf5)

### Image Name
Current image: `greatlem0n-os`

Update in these files when renaming:
- `Containerfile` (line 9)
- `Justfile` (line 1)
- `README.md` (line 1)
- `artifacthub-repo.yml` (line 5)
- `custom/ujust/README.md` (~line 175)
- `.github/workflows/clean.yml` (line 23)

## Commit Attribution

Include in commit message footer:
```
Assisted-by: Claude Sonnet 4.5 via Claude Code
```

## Project Vision & Long-term Goal

### Modular Bluefin Migration (Experimental)

**Current State**: Using monolithic `ghcr.io/ublue-os/bluefin:stable` base image

**Long-term Goal**: Migrate to modular architecture using Fedora 43 bootc base + Bluefin OCI components

#### Why Modular?

Bluefin refactored (Dec 2025) to decouple the OS into reusable OCI containers:
- `ghcr.io/projectbluefin/common:latest` - Core Bluefin personality (ujust, GNOME config, systemd units)
- `ghcr.io/ublue-os/brew:latest` - Homebrew implementation
- `ghcr.io/projectbluefin/branding:latest` - Visual assets
- `ghcr.io/ublue-os/artwork:latest` - Shared art assets

This enables treating the OS like cloud infrastructure: base image + layered components, all swappable via `rpm-ostree rebase`.

#### Target Architecture

Instead of monolithic:
```dockerfile
FROM ghcr.io/ublue-os/bluefin:stable
```

Build modular:
```dockerfile
FROM ghcr.io/projectbluefin/common:latest AS common
FROM ghcr.io/ublue-os/brew:latest AS brew
FROM quay.io/fedora/fedora-bootc:43
COPY --from=common /ctx /
COPY --from=brew /ctx /
# Custom build scripts and files
```

#### Philosophy

- **OS as Infrastructure Code**: Dockerfiles are the new package managers
- **Composable Components**: Mix and match OCI layers
- **Zero Reinstalls**: `rpm-ostree rebase` to switch entire OS
- **90+ Day Rollback**: Image history in registry

#### Implementation Approach

**This is NOT a rush migration.** Changes will be made incrementally when user requests them.

- Repo is experimental/educational, not production
- VM testing required before any hardware deployment
- Reference: bluefin-lts commit 83d5b68 for modular pattern
- Hardware: AMD Ryzen 7 5700U, 32GB RAM, currently running bluefin:stable Fedora 43

#### Key Resources

- [Bluefin 2025 Blog](https://docs.projectbluefin.io/blog/bluefin-2025/) - Architecture context
- [bluefin-lts](https://github.com/ublue-os/bluefin-lts/) - Reference implementation
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp) - Community support

## Full Documentation

For complete instructions, troubleshooting, examples, and patterns:
**→ [AGENTS.md](AGENTS.md)**
