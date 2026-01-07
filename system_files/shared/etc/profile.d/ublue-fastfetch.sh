# shellcheck shell=bash
###############################################################################
# Override the upstream alias file in-place so our greatlem0n wrapper is the
# canonical entrypoint without relying on filename ordering.
###############################################################################
unalias neofetch 2>/dev/null
unalias neowofetch 2>/dev/null
unalias fastfetch 2>/dev/null

alias neofetch='greatlem0n-fastfetch'
alias neowofetch='greatlem0n-fastfetch'
alias fastfetch='greatlem0n-fastfetch'
