#!/bin/bash

# ==============================
# Script: create_users.sh
#
# ==============================

CSV_FILE="users.csv"
LOG_FILE="users_creation.log"

if [[ $EUID -ne 0 ]]; then
	echo"you should be a root"
        exit 1
fi


if [[ ! -f "$CSV_FILE" ]]; then
    echo"file deosn't exist"
    exit 1
fi

echo "starting the process..." | tee -a "$LOG_FILE"
echo "----------------------------------" | tee -a "$LOG_FILE"


while IFS=',' read -r username fullname groupname shell
do
    
    if [[ "$username" == "username" ]]; then
        continue
    fi

    
    if [[ -z "$username" ]]; then
        continue
    fi

   
    if ! getent group "$groupname" > /dev/null 2>&1; then
        groupadd "$groupname"
        echo "group added: $groupname" | tee -a "$LOG_FILE"
    fi

   
    if id "$username" &>/dev/null; then
        echo "user is already exist" | tee -a "$LOG_FILE"
        continue
    fi

    
    useradd -m -c "$fullname" -g "$groupname" -s "$shell" "$username"

    if [[ $? -eq 0 ]]; then
        
        random_pass=$(openssl rand -base64 8)
        echo "$username:$random_pass" | chpasswd

        
        chage -d 0 "$username"

        echo "user created : $username |group: $groupname | Password: $random_pass" | tee -a "$LOG_FILE"
    else
        echo "failed to create user: $username" | tee -a "$LOG_FILE"
    fi

done < "$CSV_FILE"
