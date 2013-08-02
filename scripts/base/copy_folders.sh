#!/bin/bash

# required variables: FOLDER_PATHS DEST_PATH

for FOLDER in ${FOLDER_PATHS[*]}
do
	FOLDER_DEST_PATH=$DEST_PATH/$FOLDER
	mkdir -p $FOLDER_DEST_PATH
	sudo cp -R $FOLDER/* $FOLDER_DEST_PATH
done