#!/bin/bash
#
# backup.sh
#
# Backs up /home/ec2-user/data, /etc, /boot, and /usr into a single
# compressed .tgz archive under /mnt/backup, named using the hostname
# and the current date-hour-minute. Intended to be run every 5 minutes
# via cron.

# Check if we are root privilege or not.
# ---------------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: You must run this script as root." >&2
    exit 1
fi

# Which files/folders are we going to back up.
# Please make sure /home/ec2-user/data exists.
# ---------------------------------------------------------------------
sources=(/home/ec2-user/data /etc /boot /usr)

for src in "${sources[@]}"; do
    if [ ! -e "$src" ]; then
        echo "Error: $src does not exist. Aborting backup." >&2
        exit 1
    fi
done

# Where do we backup to. Please create this folder before executing this script.
# ---------------------------------------------------------------------
dest="/mnt/backup"

if [ ! -d "$dest" ]; then
    echo "Error: destination folder $dest does not exist. Aborting backup." >&2
    exit 1
fi

# Create archive filename based on hostname and time (date-hour-minute).
# ---------------------------------------------------------------------
hostname=$(hostname -s)
day=$(date +%Y%m%d-%H%M)
archive_file="${hostname}-${day}.tgz"

# Print start status message.
# ---------------------------------------------------------------------
echo "Backing up ${sources[*]} to $dest/$archive_file"
date
echo

# Backup the files using tar.
# ---------------------------------------------------------------------
tar czf "$dest/$archive_file" "${sources[@]}"

# Print end status message.
# ---------------------------------------------------------------------
echo
echo "Backup finished:"
date

# Long listing of files in $dest to check file sizes.
# ---------------------------------------------------------------------
ls -lh "$dest"


# To set this script for executing in every 5 minutes, we'll create cronjob
# ---------------------------------------------------------------------
# To set this script for executing every 5 minutes, add the following
# line with `crontab -e` (running as root, since root privileges are
# required to read /etc, /boot and /usr):
#
# */5 * * * * /bin/bash /path/to/backup.sh >> /var/log/backup.log 2>&1
# ---------------------------------------------------------------------
