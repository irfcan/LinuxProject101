#!/bin/bash
#
# command.sh
#
# Reads the private IP address of the newly-created EC2 instance from
# info.json and substitutes it into terraform.tf, replacing the
# "ec2-private_ip" placeholder on line 40 (kubernetes_api_url). Only
# grep/sed are used — the files are never opened in an editor.
#
# Usage: ./command.sh

JSON_FILE="info.json"
TF_FILE="terraform.tf"

if [ ! -f "$JSON_FILE" ] || [ ! -f "$TF_FILE" ]; then
    echo "Error: $JSON_FILE or $TF_FILE not found in current directory." >&2
    exit 1
fi

# Pull the first "PrivateIpAddress" value out of the JSON file.
# -m1 stops after the first match (the top-level instance IP).
PRIVATE_IP=$(grep -m1 '"PrivateIpAddress"' "$JSON_FILE" | sed -E 's/.*: *"([^"]+)".*/\1/')

if [ -z "$PRIVATE_IP" ]; then
    echo "Error: could not find PrivateIpAddress in $JSON_FILE." >&2
    exit 1
fi

# Replace the ec2-private_ip placeholder in terraform.tf with the real IP.
sed -i "s/ec2-private_ip/$PRIVATE_IP/" "$TF_FILE"

echo "Replaced placeholder with private IP: $PRIVATE_IP"
echo "Updated line in $TF_FILE:"
grep -n "$PRIVATE_IP" "$TF_FILE"
