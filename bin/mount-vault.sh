#!/bin/bash

LOOP_DEV=$(sudo losetup -j $1)
if [ ! -z "$LOOP_DEV" ] ; then
   echo -e "The vault $1 is already mounted!";
   exit 1;
fi

DEV_LOOP=$(sudo losetup -f)
MOUNT_POINT=/tmp/vault

echo -e "Mounting vault on $DEV_LOOP..."
sudo losetup $DEV_LOOP $1

if [ "$?" = "0" ]; then
    echo -e "Decrypting vault..."
    sudo cryptsetup luksOpen /dev/loop0 vault

    if [ "$?" = "0" ]; then
        echo -e "Mounting vault..."
        mkdir -p $MOUNT_POINT
        sudo mount /dev/mapper/vault $MOUNT_POINT

        if [ "$?" = "0" ]; then
            echo -e "Completed, vault mounted on $MOUNT_POINT"
        else
            echo -e "Error: mount exited with $?"
        fi

    else
        echo -e "Error: cryptsetup exited with $?"
    fi
else
    echo -e "Error: losetup exited with $?"
fi

exit $?
