# vim: set ft=make :
#######################
### custom-system.just
#######################
## Example system configuration commands
## These are simplified examples adapted from Bluefin

# Run a system benchmark (requires stress-ng from Homebrew)
[group('System')]
benchmark:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    if ! type -P "stress-ng" &>/dev/null ; then
        echo "stress-ng is not installed."
        if command -v brew &>/dev/null; then
            if gum confirm "Install stress-ng via Homebrew?" ; then
                brew install stress-ng
                brew link stress-ng
            else
                exit 0
            fi
        else
            echo "Please install stress-ng to run benchmarks."
            exit 1
        fi
    fi
    echo 'Running a 1 minute benchmark...'
    pushd $(mktemp -d) > /dev/null
    stress-ng --matrix 0 -t 1m --times
    popd > /dev/null

# Configure docker and libvirt groups for development
[group('System')]
configure-dev-groups:
    #!/usr/bin/pkexec bash
    CURRENT_USER="{{ `id -un` }}"
    echo "Adding $CURRENT_USER to docker and libvirt groups..."

    # Ensure groups exist in /etc/group
    for group in docker libvirt; do
        if ! grep -q "^$group:" /etc/group; then
            echo "Adding $group to /etc/group"
            grep "^$group:" /usr/lib/group | tee -a /etc/group > /dev/null
        fi
        usermod -aG $group $CURRENT_USER
    done

    echo "Groups configured. Log out and back in for changes to take effect."

# Example toggle command with user choice
[group('System')]
toggle-example-feature:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    echo "This is an example toggle command."
    echo "Current status: [check your status here]"
    OPTION=$(Choose "Enable" "Disable" "Cancel")
    case "$OPTION" in
        "Enable")
            echo "Enabling feature..."
            # Add your enable logic here
            ;;
        "Disable")
            echo "Disabling feature..."
            # Add your disable logic here
            ;;
        "Cancel")
            echo "No changes made."
            ;;
    esac

# Clean up container images and volumes
[group('Maintenance')]
clean-containers:
    #!/usr/bin/bash
    echo "Cleaning up Podman containers, images, and volumes..."
    podman system prune -af
    podman volume prune -f
    echo "Cleanup complete!"

# Update system and reboot if needed
[group('Maintenance')]
update-and-reboot:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    echo "Updating system..."
    sudo bootc upgrade
    if gum confirm "Reboot now to apply updates?"; then
        systemctl reboot
    else
        echo "Reboot later to apply updates."
    fi

# Toggle passwordless sudo (requires password)
[group('System')]
toggle-sudo:
    sudo /usr/bin/toggle-passwordless-sudo

# Configure Tailscale exit node (advertise this device as an exit node)
# Enable also configures firewalld masquerade and UDP GRO forwarding for full functionality
[group('System')]
tailscale-exit-node:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    echo "Tailscale Exit Node"
    echo "Current status: $(tailscale status 2>/dev/null | grep -i 'exit node\|tagged' | head -1 || echo 'run tailscale status to check')"
    echo ""
    OPTION=$(Choose "Enable" "Disable" "Cancel")
    case "$OPTION" in
        "Enable")
            sudo tailscale set --advertise-exit-node
            sudo firewall-cmd --permanent --add-masquerade
            sudo firewall-cmd --reload
            IFACE=$(ip route show default | awk '/default/ {print $5}' | head -1)
            [ -n "$IFACE" ] && sudo ethtool -K "$IFACE" rx-udp-gro-forwarding on
            echo "Exit node enabled. Approve this device at: https://login.tailscale.com/admin/machines"
            ;;
        "Disable")
            sudo tailscale set --advertise-exit-node=false
            sudo firewall-cmd --permanent --remove-masquerade
            sudo firewall-cmd --reload
            echo "Exit node disabled."
            ;;
        "Cancel")
            echo "No changes made."
            ;;
    esac
