#!/usr/bin/env bash

set -eoux pipefail

###############################################################################
# Install Visual Studio Code from the Official Microsoft Repository
###############################################################################
# This script follows @ublue-os/bluefin conventions:
# - Use dnf5 exclusively (never dnf or yum)
# - Always use -y for non-interactive installs
# - Remove third-party repo files after install (repos don't work at runtime)
###############################################################################

echo "Installing Visual Studio Code..."

# Add Microsoft VS Code RPM repository
cat > /etc/yum.repos.d/vscode.repo << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Install VS Code
dnf5 install -y code

# Clean up repo file (required - repos don't work at runtime in bootc images)
rm -f /etc/yum.repos.d/vscode.repo

echo "Visual Studio Code installed successfully"
