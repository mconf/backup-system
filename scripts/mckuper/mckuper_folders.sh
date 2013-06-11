#!/bin/bash

# User should replace this variable for the apropriate data
APP_FILES=("FOLDER_PATH_1" "FOLDER_PATH_2")
BACKUP_ID="ID"
SECRET="YOUR_SECRET_PASSPHRASE"

# default paths
WORK_FOLDER="/tmp/backup/`date +%F-%Hh%M`"
BACKUP_FOLDER="/home/$USER/.backup/encrypted"
SCRIPTS_PATH=$PWD

#starting back up
echo "BACKUP $BACKUP_ID"
mkdir -p $BACKUP_FOLDER

# change to work folder
mkdir -p $WORK_FOLDER
cd $WORK_FOLDER

# Copying files to temp folder
for FOLDER in ${APP_FILES[*]}
do
	DEST_PATH=./folders/$FOLDER
	mkdir -p $DEST_PATH
	cp -R $FOLDER/* $DEST_PATH
done

# Encrypt and move to backup folder
export ENCRYPT_SOURCE_PATH=$WORK_FOLDER
export ENCRYPT_DEST_PATH=$BACKUP_FOLDER
export ENCRYPT_SECRET=$SECRET
export ENCRYPT_ID=$BACKUP_ID
$SCRIPTS_PATH/mckuper_encrypt.sh

# Cleaning up tmp files
rm -r -f $WORK_FOLDER

# Rotating
export ROTATE_FOLDER=$BACKUP_FOLDER
export ROTATE_MAX=2
export ROTATE_FILTER=*.tar.gz.aes
$SCRIPTS_PATH/mckuper_rotate.sh
