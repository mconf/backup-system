# this script replaces the binaries for btsync with the latest version

BTSYNC_BIN_PATH=/usr/local/bin

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

