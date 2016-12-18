#!/bin/bash

do_usage() {
    echo -n
    echo "Usage:"
    echo "backupgpg.sh* *destination folder*"
    exit 1
}
[ 1 -ne $# ] && do_usage

STAMP=$(date "+%Y%m%d")
tar -cf $HOME/gnupg-backup.tar -C $HOME .gnupg

DEST_FILE=gnugp-backup-$STAMP.tar.enc

if [ ! -d $1 ] ; then
    echo "Destination folder $1 not found."
    exit 1
fi

NORMALIZED_DIR=$(readlink -e $1)
backupsecret $HOME/gnupg-backup.tar $NORMALIZED_DIR/$DEST_FILE
