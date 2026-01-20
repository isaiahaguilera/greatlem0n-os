# shellcheck shell=bash
###############################################################################
# Set vim as the default editor for CLI tools
# Covers: git, crontab, visudo, sudo -e, and anything else that respects $EDITOR
###############################################################################
export EDITOR="vim"
export VISUAL="vim"
export SUDO_EDITOR="vim"
