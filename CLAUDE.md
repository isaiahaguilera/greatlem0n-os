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
3. Update README "What's Different" section based on verified findings
4. Update the "Last updated" date
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

## Full Documentation

For complete instructions, troubleshooting, examples, and patterns:
**→ [AGENTS.md](AGENTS.md)**
