#!/bin/bash


create_user() {
    read -p "Enter new username: " username
    adduser $username >/dev/null
    passwd $username >/dev/null
    usermod -aG wheel $username >/dev/null
    
    read -p "Do you allow the user to switch to root without a password using sudo? [y/n]: " grant_nopass
    if [[ "$grant_nopass" == "y" || "$grant_nopass" == "Y" ]]; then
        sed -i "s#^\($username:[^:]*:\)[0-9]\+:[0-9]\+\(.*\)#\10:0\2#" /etc/passwd

        TMPFILE=$(mktemp)
        trap "rm -f $TMPFILE" EXIT
        cp /etc/sudoers $TMPFILE
        
        echo "$username ALL=(ALL) NOPASSWD: ALL" >> $TMPFILE
        visudo -c -f $TMPFILE >/dev/null
        if [ $? -eq 0 ]; then
            cp $TMPFILE /etc/sudoers
            echo "Modified sudoers file."
        else
            echo "Failed to modify the sudoers file"
        fi
    else
        echo "The user needs a password to use sudo to switch to root."
    fi
    echo "$username Create Success."
}

create_user