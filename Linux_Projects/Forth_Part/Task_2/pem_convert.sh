#!/bin/bash
#
# pem_convert.sh
#
# certificate.pem holds a PEM certificate as a single line, using the
# literal two-character sequence "\n" instead of real newlines. This
# script turns it back into a standard multi-line PEM file, new.pem,
# suitable for use elsewhere in the Ansible playbook.
#
# Usage: ./pem_convert.sh

SRC_FILE="certificate.pem"
DEST_FILE="new.pem"

if [ ! -f "$SRC_FILE" ]; then
    echo "Error: $SRC_FILE not found in current directory." >&2
    exit 1
fi

# 1. sed 's/\\n/\n/g'  -> turn every literal backslash-n into a real newline
# 2. sed fixes         -> normalize the BEGIN header spacing
sed 's/\\n/\n/g' "$SRC_FILE" | \
    sed 's/-----BEGINCERTIFICATE-----/-----BEGIN CERTIFICATE-----/' > "$DEST_FILE"

echo "Converted $SRC_FILE into multi-line format: $DEST_FILE"
echo "---"
cat "$DEST_FILE"
