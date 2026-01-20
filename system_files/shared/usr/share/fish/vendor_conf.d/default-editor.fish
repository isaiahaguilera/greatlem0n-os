###############################################################################
# Set vim as the default editor for CLI tools
# Covers: git, crontab, visudo, sudo -e, and anything else that respects $EDITOR
###############################################################################
set -gx EDITOR vim
set -gx VISUAL vim
set -gx SUDO_EDITOR vim
