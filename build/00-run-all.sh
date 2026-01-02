#!/usr/bin/env bash
set -eoux pipefail

###############################################################################
# Build Script Runner (OPTIONAL)
###############################################################################
# This script automatically runs all numbered build scripts in order.
#
# To use this runner:
# 1. Update Containerfile line 55 from:
#      /ctx/build/10-build.sh
#    to:
#      /ctx/build/00-run-all.sh
#
# 2. Rename any .example scripts you want to use:
#      mv build/20-onepassword.sh.example build/20-onepassword.sh
#
# The runner will automatically execute all [0-9][0-9]-*.sh scripts in
# numerical order, skipping itself.
###############################################################################

echo "::group:: Running build scripts"

# Avoid iterating over the literal pattern when no scripts match.
shopt -s nullglob

# Find and execute all numbered scripts in order
for script in /ctx/build/[0-9][0-9]-*.sh; do
    # Skip this runner script itself
    [ "$(basename "$script")" = "00-run-all.sh" ] && continue

    # Execute if it exists and is executable
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "================================================"
        echo "Executing: $(basename "$script")"
        echo "================================================"
        "$script"
        echo ""
    else
        echo "Skipping: $(basename "$script") (not executable or doesn't exist)"
    fi
done

echo "::endgroup::"
echo "✓ All build scripts completed successfully!"
