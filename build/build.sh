#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Build Script Runner
###############################################################################
# This script orchestrates the execution of all build scripts in order.
# HOW TO ADD A NEW SCRIPT:
# ------------------------
# 1. Create your script in the build/ directory with a numbered prefix:
#      build/25-my-custom-script.sh
#
# 2. Make it executable:
#      chmod +x build/25-my-custom-script.sh
#
# 3. Add an entry to the "Execute Build Scripts" section below:
#      /ctx/build/25-my-custom-script.sh
#
# HELPER SCRIPTS:
# ---------------
# Scripts without numbered prefixes (e.g., copr-helpers.sh) are helpers
# meant to be sourced by other scripts, not executed directly.
#
# See: https://github.com/ublue-os/bluefin/blob/main/build_files/shared/build.sh
###############################################################################

echo "Starting build process..."

###############################################################################
# Execute Build Scripts
###############################################################################

# System configuration - copy files, enable services, etc.
/ctx/build/02-system-config.sh

# Package installation and removal
/ctx/build/04-packages.sh

# VSCode/VSCodium installation from Microsoft/VSCodium repos
/ctx/build/11-vscode.sh

###############################################################################
# Conditional Scripts (Examples)
###############################################################################
# You can add conditional logic for scripts that should only run in certain
# circumstances. Uncomment and modify as needed.
#
# Example: Only run on experimental builds
# if [[ "${IMAGE_TAG:-stable}" == "experimental" ]]; then
#     /ctx/build/30-experimental-features.sh
# fi
#
# Example: Only run if a specific package is installed
# if rpm -q some-package &>/dev/null; then
#     /ctx/build/40-configure-some-package.sh
# fi
###############################################################################

###############################################################################
# Build Complete
###############################################################################
echo ""
echo "================================================"
echo "Build process completed successfully!"
echo "================================================"
