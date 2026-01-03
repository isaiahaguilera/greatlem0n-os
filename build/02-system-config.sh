#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# System Configuration Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

###############################################################################
# Copy System Files
###############################################################################
echo "::group:: Copy System Files"

# Copy system files structure to root (polkit, udev, etc.)
if [ -d /ctx/system_files/shared ]; then
    cp -r /ctx/system_files/shared/* /
fi

echo "::endgroup::"

###############################################################################
# Copy Custom Files
###############################################################################
echo "::group:: Copy Custom Files"

# Copy Brewfiles to standard location
mkdir -p /usr/share/ublue-os/homebrew/
cp /ctx/custom/brew/*.Brewfile /usr/share/ublue-os/homebrew/

# Consolidate Just Files
mkdir -p /usr/share/ublue-os/just/
find /ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just

# Copy Flatpak preinstall files
mkdir -p /etc/flatpak/preinstall.d/
cp /ctx/custom/flatpaks/*.preinstall /etc/flatpak/preinstall.d/

echo "::endgroup::"

###############################################################################
# System Configuration
###############################################################################
echo "::group:: System Configuration"

# Enable/disable systemd services
systemctl enable podman.socket
# Example: systemctl mask unwanted-service

echo "::endgroup::"

echo "System Configuration Script complete!"
