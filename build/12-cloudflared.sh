#!/usr/bin/env bash

set -eoux pipefail

###############################################################################
# Install cloudflared from the Official Cloudflare Repository
###############################################################################
# This script follows @ublue-os/bluefin conventions:
# - Use dnf5 exclusively (never dnf or yum)
# - Always use -y for non-interactive installs
# - Remove third-party repo files after install (repos don't work at runtime)
#
# --setopt=tsflags=noscripts skips the RPM %post scriptlet, which tries to
# create a symlink at /usr/local/bin/cloudflared. In bootc images /usr/local
# is a symlink to /var/usrlocal (mutable runtime state) and does not exist
# at build time. The binary is already installed to /usr/bin/cloudflared by
# the RPM itself, so the symlink is not needed.
#
# NOTE: cloudflared requires runtime configuration before the service can run.
# After deployment, configure the tunnel and enable the service:
#   cloudflared tunnel login
#   cloudflared service install
###############################################################################

echo "Installing cloudflared..."

# Add Cloudflare cloudflared RPM repository
curl -fsSL https://pkg.cloudflare.com/cloudflared.repo -o /etc/yum.repos.d/cloudflared.repo

# Install cloudflared, skipping post-install scriptlet.
# The %post script attempts to symlink into /usr/local/bin which does not
# exist in bootc images at build time - the binary at /usr/bin/cloudflared
# is sufficient.
dnf5 install -y --setopt=tsflags=noscripts cloudflared

# Clean up repo file (required - repos don't work at runtime in bootc images)
rm -f /etc/yum.repos.d/cloudflared.repo

echo "cloudflared installed successfully"
