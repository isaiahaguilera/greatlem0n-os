#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Container Image Signature Verification Policy
###############################################################################
# This script configures /etc/containers/policy.json to require signature
# verification for the ghcr.io/isaiahaguilera/greatlem0n-os repository using sigstore signatures.
#
# What this does:
# - Enforces signature verification for ghcr.io/isaiahaguilera/greatlem0n-os
# - Uses the public key at /etc/pki/containers/greatlem0n-os.pub
# - Ensures only properly signed images in the repository can be pulled/upgraded
#
# Security benefits:
# - Prevents man-in-the-middle attacks on repository image updates
# - Guarantees image authenticity (signed by the correct private key)
# - Consistent signature enforcement across the repository
###############################################################################

echo "::group:: Configure Container Signature Policy"

# Define paths
POLICY_FILE="/etc/containers/policy.json"
PUBLIC_KEY_PATH="/etc/pki/containers/greatlem0n-os.pub"
IMAGE_REFERENCE="ghcr.io/isaiahaguilera/greatlem0n-os"

# Create temporary file for atomic update
# This ensures the policy file isn't corrupted if the script fails mid-write
TMP_POLICY="$(mktemp)"

# Build the JQ filter to add signature verification for the repository
# This modifies the policy to require:
# - type: sigstoreSigned (verify using sigstore/cosign signatures)
# - keyPath: Public key used to verify the signature
# - signedIdentity: matchRepository (signature must match the repository)
jq --arg image "$IMAGE_REFERENCE" \
   --arg keypath "$PUBLIC_KEY_PATH" \
   '.transports.docker[$image] = [{
     "type": "sigstoreSigned",
     "keyPath": $keypath,
     "signedIdentity": {"type": "matchRepository"}
   }]' \
   "$POLICY_FILE" > "$TMP_POLICY"

# Atomically replace the policy file
# Using mv ensures the file is updated atomically (no partial writes)
mv "$TMP_POLICY" "$POLICY_FILE"
chown root:root "$POLICY_FILE"
chmod 0644 "$POLICY_FILE"

echo "Container signature policy configured successfully"
echo "Repository images will require valid signatures using: $PUBLIC_KEY_PATH"

echo "::endgroup::"
echo "Container Signature Policy configuration complete!"
