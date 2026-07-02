#!/bin/bash
#
# invalid_user.sh
#
# Scans the SSH audit log (auth.log) for "Invalid user" attempts,
# extracts the attempted usernames, counts how many times each one
# was tried, and writes the sorted results to invalid_user.txt.
#
# Usage: ./invalid_user.sh

LOG_FILE="auth.log"
RESULT_FILE="invalid_user.txt"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: $LOG_FILE not found in current directory." >&2
    exit 1
fi

# 1. grep "Invalid user"        -> only the lines announcing a bad username
# 2. awk '{print $8}'           -> field 8 is the username in
#                                   "... sshd[pid]: Invalid user <name> from <ip>"
# 3. sort                       -> group identical usernames together
# 4. uniq -c                    -> count occurrences of each username
# 5. sort -rn                   -> show the most-attempted usernames first
grep "Invalid user" "$LOG_FILE" | awk '{print $8}' | sort | uniq -c | sort -rn > "$RESULT_FILE"

echo "Invalid user attempt counts saved to $RESULT_FILE"
echo "---"
cat "$RESULT_FILE"
