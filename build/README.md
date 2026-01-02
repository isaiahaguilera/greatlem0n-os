# Build Scripts

This directory contains build scripts that run during image creation. Scripts are executed in numerical order.

## How It Works

Scripts are named with a number prefix (e.g., `10-build.sh`, `20-onepassword.sh`) and run in ascending order during the container build process.

## Included Scripts

- **`10-build.sh`** - Main build script for base system modifications, package installation, and service configuration

## Example Scripts

- **`20-onepassword.sh.example`** - Example showing how to install software from third-party RPM repositories (Google Chrome, 1Password)

To use an example script:
1. Remove the `.example` extension
2. Make it executable: `chmod +x build/20-yourscript.sh`
3. Enable the auto-runner (see "Execution Order" section below) or add to 10-build.sh

## Creating Your Own Scripts

Create numbered scripts for different purposes:

```bash
# 10-build.sh - Base system (already exists)
# 20-drivers.sh - Hardware drivers  
# 30-development.sh - Development tools
# 40-gaming.sh - Gaming software
# 50-cleanup.sh - Final cleanup tasks
```

### Script Template

```bash
#!/usr/bin/env bash
set -oue pipefail

echo "Running custom setup..."
# Your commands here
```

### Best Practices

- **Use descriptive names**: `20-nvidia-drivers.sh` is better than `20-stuff.sh`
- **One purpose per script**: Easier to debug and maintain
- **Clean up after yourself**: Remove temporary files and disable temporary repos
- **Test incrementally**: Add one script at a time and test builds
- **Comment your code**: Future you will thank present you

### Disabling Scripts

To temporarily disable a script without deleting it:
- Rename it with `.disabled` extension: `20-script.sh.disabled`
- Or remove execute permission: `chmod -x build/20-script.sh`

## Execution Order

**By default**, the Containerfile only runs:

```dockerfile
RUN /ctx/build/10-build.sh
```

### Option 1: Keep Everything in 10-build.sh (Current Default)
The simplest approach - add all your customizations to `10-build.sh`.

### Option 2: Use the Auto-Runner Script (Recommended for Multiple Scripts)
To automatically run all numbered scripts in order:

1. **Update Containerfile** line 55 from:
   ```dockerfile
   /ctx/build/10-build.sh
   ```
   to:
   ```dockerfile
   /ctx/build/00-run-all.sh
   ```

2. **Rename example scripts** you want to use:
   ```bash
   mv build/20-onepassword.sh.example build/20-onepassword.sh
   ```

The runner will automatically execute all `[0-9][0-9]-*.sh` scripts in numerical order.

### Option 3: Manually Add Scripts to Containerfile
Add explicit RUN commands for each script:

```dockerfile
RUN --mount=... /ctx/build/10-build.sh
RUN --mount=... /ctx/build/20-onepassword.sh
RUN --mount=... /ctx/build/30-cosmic.sh
```

## Notes

- Scripts run as root during build
- Build context is available at `/ctx`
- Use dnf5 for package management (not dnf or yum)
- Always use `-y` flag for non-interactive installs
