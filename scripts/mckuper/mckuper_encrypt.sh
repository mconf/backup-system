# Encrypt directly to backup folder
sudo tar -zcf - $ENCRYPT_SOURCE_PATH | openssl aes-256-cbc  -k $ENCRYPT_SECRET -salt -out $ENCRYPT_DEST_PATH/$ENCRYPT_ID-`date +%F-%Hh%M`.tar.gz.aes  

# To Decrypt: 
# openssl aes-256-cbc -k $ENCRYPT_SECRET -d -salt -in $ENCRYPT_DEST_PATH/$ENCRYPT_ID-`date +%F-%Hh%M`.tar.gz.aes | tar -xz -f -

