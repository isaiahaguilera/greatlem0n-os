# Build Scripts

This directory contains build scripts that run during image creation. Scripts are executed in explicit order via `build.sh`.

## How It Works

The `build.sh` script explicitly declares which scripts to run and in what order. This provides clarity, control, and supports conditional logic.

## Current Scripts

- **`build.sh`** - Main runner that executes scripts in explicit order (Bluefin pattern)
- **`02-system-config.sh`** - System configuration: copy files, enable services
- **`04-packages.sh`** - Package installation and removal
- **`11-vscode.sh`** - Install Visual Studio Code from the official Microsoft repository
- **`copr-helpers.sh`** - Helper functions for COPR repositories (sourced, not executed)

## Example Scripts

Example scripts are located in `build/examples/`:

- **`20-onepassword.sh.example`** - Install software from third-party RPM repositories (Google Chrome, 1Password)
- **`30-cosmic-desktop.sh.example`** - Replace GNOME with COSMIC desktop

To use an example script:
1. Copy from `examples/` to `build/`
2. Remove the `.example` extension
3. Make it executable: `chmod +x build/20-yourscript.sh`
4. Add it to `build.sh` in the appropriate location

## Adding New Scripts

**Follow the explicit pattern** - add your script to `build.sh`:

1. **Create your script** with numbered prefix:
   ```bash
   # build/25-my-feature.sh
   #!/usr/bin/bash
   set -eoux pipefail

   echo "Installing my feature..."
   dnf5 install -y my-package
   ```

2. **Make it executable**:
   ```bash
   chmod +x build/25-my-feature.sh
   ```

3. **Add to `build.sh`**:
   ```bash
   # In build.sh, add:
   /ctx/build/25-my-feature.sh
   ```

## Script Numbering Convention

Scripts use numbered prefixes to indicate execution order:

- **00-09**: Reserved for orchestration (build.sh)
- **10-19**: Core build operations (packages, system files)
- **20-29**: Additional software (editors, tools)
- **30-39**: Desktop customization (themes, extensions)
- **40-49**: Hardware-specific (drivers, firmware)
- **50-59**: Cleanup and validation
- **90-99**: Reserved for future use

## Alternative: Auto-Discovery Runner

For simpler use cases, `00-run-all.sh` provides auto-discovery - it finds and runs all `[0-9][0-9]-*.sh` scripts automatically.

To use it instead of `build.sh`:
1. Update `Containerfile` to call `/ctx/build/00-run-all.sh`
2. Name scripts with numbered prefixes
3. They'll run automatically in order

**Explicit (`build.sh`) is recommended** for clarity and conditional logic.

## Best Practices

- **Use descriptive names**: `20-nvidia-drivers.sh` is better than `20-stuff.sh`
- **One purpose per script**: Easier to debug and maintain
- **Clean up after yourself**: Remove temporary files and disable temporary repos
- **Test incrementally**: Add one script at a time and test builds
- **Comment your code**: Future you will thank present you
- **Use dnf5 exclusively**: Never use `dnf`, `yum`, or `rpm-ostree`
- **Always use `-y` flag**: For non-interactive installs
- **Disable COPRs after use**: Use `copr_install_isolated` function

## Execution in Containerfile

The Containerfile runs:

```dockerfile
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/build.sh
```

## Notes

- Scripts run as root during build
- Build context is available at `/ctx`
- Use dnf5 for package management
- See `copr-helpers.sh` for COPR installation patterns
- Check `examples/` directory for working patterns before creating new ones
