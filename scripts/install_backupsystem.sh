# WARNING
# this script is not designed to run more than once.
# to rerun it, you should first delete all files and folders created here

BTSYNC_CONFIG_PATH=/home/$USER/.btsync
BTSYNC_BIN_PATH=/usr/local/bin

# DO NOT change this in order to maintain standardization
BACKUP_PATH=/home/$USER/.backup

# create folders
mkdir -p $BACKUP_PATH/encrypted # this one is shared
mkdir -p $BTSYNC_CONFIG_PATH


# download and install btsync
mkdir -p /tmp/btsyncinstall
cd /tmp/btsyncinstall
# version compatible with machines on xen
curl btsync.s3-website-us-east-1.amazonaws.com/btsync_x64.tar.gz -o btsync.tar.gz
# other versions
# curl http://btsync.s3-website-us-east-1.amazonaws.com/btsync_glibc23_i386.tar.gz -o btsync.tar.gz
# curl http://btsync.s3-website-us-east-1.amazonaws.com/btsync_i386.tar.gz -o btsync.tar.gz
tar -xf btsync.tar.gz
sudo mv btsync $BTSYNC_BIN_PATH/btsync

# prepare sync variables
ENCRYPTED_FOLDER_SECRET=$(btsync --generate-secret)
ENCRYPTED_FOLDER_SECRET_RO=$(btsync --get-ro-secret $ENCRYPTED_FOLDER_SECRET)
echo "{ 
  \"device_name\": \""$HOSTNAME:$USER"\",
  \"listening_port\" : 0,
  \"storage_path\" : \""$BTSYNC_CONFIG_PATH/"\",
  \"check_for_updates\" : true, 
  \"use_upnp\" : true,
  \"download_limit\" : 0,                       
  \"upload_limit\" : 0, 
  \"shared_folders\" :
  [
    {
      \"secret\" : \""$ENCRYPTED_FOLDER_SECRET"\",
      \"dir\" : \""$BACKUP_PATH/encrypted"\",
      \"use_relay_server\" : true,
      \"use_tracker\" : true, 
      \"use_dht\" : false,
      \"search_lan\" : true,
      \"use_sync_trash\" : true,
      \"known_hosts\" :
      [
        \""192.168.0.1:44444"\"
      ]
    }
  ]
}" > sync.conf
mv ./sync.conf $BTSYNC_CONFIG_PATH/sync.conf

# btsync deamon
echo "
#!/bin/sh
btsync --config /home/$USER/.btsync/sync.conf
" > btsync-daemon

# moving daemon to your daemontools services path
chmod +x btsync-daemon
sudo mv ./btsync-daemon /etc/init.d/
sudo update-rc.d btsync-daemon defaults 

# start btsync service
service btsync-daemon

echo ""
echo "WARNING: take note of this secret!"
echo "Backup Secret: $ENCRYPTED_FOLDER_SECRET_RO"

