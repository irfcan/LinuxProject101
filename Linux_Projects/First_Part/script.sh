#!/bin/bash
#
# script.sh
# Finds EC2 instance IDs terminated by user "Paul" (case-insensitive)
# by parsing the CloudTrail event history CSV file, and writes the
# results to result.txt.

CSV_FILE="event_history.csv"
RESULT_FILE="result.txt"

# Make sure the input file exists before we do anything else.
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: $CSV_FILE not found in current directory."
    exit 1
fi

# Empty/create the result file so re-running the script doesn't append
# duplicate results.
> "$RESULT_FILE"

# Steps:
#   1. grep -i "paul"          		-> keep only lines mentioning Paul (any case)
#   2. grep "TerminateInstances" 	-> keep only termination events
#   3. grep -oE "i-[0-9a-f]{8,17}" 	-> pull out every instance id in the line
#   4. sort -u                 		-> de-duplicate the ids
grep -i "paul" "$CSV_FILE" | grep "TerminateInstances" | \
    grep -oE "i-[0-9a-f]{8,17}" | sort -u > "$RESULT_FILE"

echo "Done. Instance IDs terminated by Paul saved to $RESULT_FILE:"
cat "$RESULT_FILE"


# HOCANIN ÇÖZÜMÜ: grep -i paul event_history.csv | grep -i terminate | grep -oE i-.{17} | sort -u > results.txt
