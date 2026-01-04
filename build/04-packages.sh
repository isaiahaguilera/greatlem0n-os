#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Packages Install Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

###############################################################################
# Install Packages
###############################################################################
echo "::group:: Install Packages"

# Install packages using dnf5
# Example: dnf5 install -y tmux

FEDORA_PACKAGES=(
    zsh
    fish
    tmux
    keychain
    git
)

dnf5 install -y "${FEDORA_PACKAGES[@]}"

# Example using COPR with isolated pattern:
# copr_install_isolated "ublue-os/staging" package-name

echo "::endgroup::"

###############################################################################
# Remove Packages
###############################################################################
echo "::group:: Remove Packages"

# Remove packages that come with the base image
# Example: dnf5 remove -y firefox

EXCLUDED_PACKAGES=(
    firefox
    firefox-langpacks
)

# Remove excluded packages if they are installed
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    readarray -t INSTALLED_EXCLUDED < <(rpm -qa --queryformat='%{NAME}\n' "${EXCLUDED_PACKAGES[@]}" 2>/dev/null || true)
    if [[ "${#INSTALLED_EXCLUDED[@]}" -gt 0 ]]; then
        dnf5 -y remove "${INSTALLED_EXCLUDED[@]}"
    else
        echo "No excluded packages found to remove."
    fi
fi

echo "::endgroup::"
echo "Packages Install Script complete!"
