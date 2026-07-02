#!/bin/bash
#
# user_password.sh
#
# This script creates a new user on the local system.
# It accepts the username and a comment (real name) as parameters,
# generates a random password for the account, and forces the user
# to change that password on first login.
#
# Usage: ./user_password.sh <username> <comment>

# Make sure the script is being executed with superuser privileges.
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: You must run this script as root (use sudo)." >&2
    exit 1
fi

# id -u → çalıştıran kullanıcının UID'sini verir. root'un UID'si her zaman 0'dır.
# $(...) → komut ikamesi (command substitution), yani id -u komutunun çıktısını bir değişken gibi kullanır.
# -ne 0 → "not equal" yani UID 0'a eşit değilse (root değilse).
# >&2 → hata mesajını standart çıktı yerine standart hata (stderr) akışına yönlendirir; bu, hata mesajlarının doğru kanaldan gitmesi için genel bir kuraldır.
# exit 1 → script'i "başarısız" anlamına gelen 1 kodu ile sonlandırır. useradd, chpasswd gibi komutlar root yetkisi ister, o yüzden en başta kontrol ediliyor.


# Get the username (login).
if [ -z "$1" ]; then
    read -rp "Enter the username to create: " USER_NAME
else
    USER_NAME="$1"
fi

# Get the real name (contents for the description field / comment).
if [ -z "$2" ]; then
    read -rp "Enter the comment (e.g. full name) for this account: " COMMENT
else
    shift
    COMMENT="$*"
fi

# Get the password. Generate a random 12-character password automatically
# so the admin doesn't have to invent one manually for every new hire.
PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c 12)

# Create the account.
useradd -c "$COMMENT" -m "$USER_NAME"

# Check to see if the useradd command succeeded.
# We don't want to tell the user that an account was created when it hasn't been.
if [ $? -ne 0 ]; then
    echo "Error: Could not create user account $USER_NAME." >&2
    exit 1
fi

# Set the password.
echo "$USER_NAME:$PASSWORD" | chpasswd

# Check to see if the passwd command succeeded.
if [ $? -ne 0 ]; then
    echo "Error: Could not set password for $USER_NAME." >&2
    exit 1
fi

# Force password change on first login.
passwd -e "$USER_NAME"

# Display the username, password, and the host where the user was created.
echo "-----------------------------------------------"
echo "User account created successfully!"
echo "Host      : $(hostname)"
echo "Username  : $USER_NAME"
echo "Password  : $PASSWORD"
echo "Note: user must change this password at first login."
echo "-----------------------------------------------"