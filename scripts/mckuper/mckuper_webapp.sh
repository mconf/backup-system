#!/bin/bash

# User should replace this variable for the apropriate data
BACKUP_ID="ID"
DB_PASS="PASSWORD"
DB_USER="USER"
DB_NAME="TABLE"
APP_FILES="APP_FOLDER_PATH"

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

# dump mysql
MYSQL_DUMP_FILE="./$BACKUP_ID-`date +%F-%Hh%M`.sql"
mysqldump -u $DB_USER --password=$DB_PASS $DB_NAME > $MYSQL_DUMP_FILE

# Copying files to temp folder
mkdir -p ./app
cp -R $APP_FILES/* ./app

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
