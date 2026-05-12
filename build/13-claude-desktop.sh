#!/usr/bin/env bash

set -eoux pipefail

###############################################################################
# Install Claude Desktop from claude-desktop-debian
###############################################################################
# Unofficial community project that repackages Anthropic's Claude Desktop
# for Linux: https://github.com/aaddrick/claude-desktop-debian
#
# Uses the project's official DNF repo. Repo file is removed after install
# (required - repos don't work at runtime in bootc images).
#
# NOTE: If the RPM %post scriptlet attempts to write to /usr/local/bin,
# add --setopt=tsflags=noscripts to the dnf5 install line (same issue as
# cloudflared). Verify by inspecting the installed RPM with:
#   rpm -q --scripts claude-desktop
###############################################################################

echo "Installing Claude Desktop..."

curl -fsSL https://pkg.claude-desktop-debian.dev/rpm/claude-desktop.repo \
    -o /etc/yum.repos.d/claude-desktop.repo

dnf5 install -y claude-desktop

rm -f /etc/yum.repos.d/claude-desktop.repo

echo "Claude Desktop installed successfully"
