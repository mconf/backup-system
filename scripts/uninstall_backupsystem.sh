# replace only if default was changed
BTSYNC_CONFIG_PATH=/home/$USER/.btsync
BTSYNC_BIN_PATH=/usr/local/bin

# remove created files and folder
rm -r $BTSYNC_CONFIG_PATH
rm $BTSYNC_BIN_PATH/btsync
rm /etc/init.d/btsync-daemon

