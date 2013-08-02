#!/bin/bash

# User should replace this variable for the apropriate data
BACKUP_ID="app_name"
FOLDER_PATHS="FOLDER_PATH_1"
SECRET="MY_ENCRYPTION_SECRET"

# default paths
BASE_SCRIPTS_PATH="/home/backups/backup-system/scripts/base"
BACKUP_FOLDER="/home/backups/.backup/encrypted"
WORK_FOLDER="/tmp/$BACKUP_ID/`date +%F-%Hh%M`"

# starting back up
echo "BACKUP $BACKUP_ID"
mkdir -p $BACKUP_FOLDER

# change to work folder
mkdir -p $WORK_FOLDER
cd $WORK_FOLDER

# Copying files to temp folder
export FOLDER_PATHS
export DEST_PATH=$WORK_FOLDER
$BASE_SCRIPTS_PATH/copy_folders.sh

# Encrypt and move to backup folder
export ENCRYPT_SOURCE_PATH=$WORK_FOLDER
export ENCRYPT_DEST_PATH=$BACKUP_FOLDER
export ENCRYPT_SECRET=$SECRET
export ENCRYPT_ID=$BACKUP_ID
$BASE_SCRIPTS_PATH/encrypt.sh

# Rotating
export ROTATE_FOLDER=$BACKUP_FOLDER
export ROTATE_MAX=2
export ROTATE_FILTER="${BACKUP_ID}-*.tar.gz.aes"
$BASE_SCRIPTS_PATH/rotate.sh

# Cleaning up tmp files
sudo rm -r -f $WORK_FOLDER
