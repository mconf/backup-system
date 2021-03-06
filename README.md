# Backup system

This set of scripts is used to implement the backup policies used by mconf's infrastructure.

The idea is to use [btsync](http://labs.bittorrent.com/experiments/sync.html) to backup encrypted files using read-only secrets to avoid that a backup server propagates improper deletions.

All scripts here are designed for Ubuntu 10.04.


## Usage

Log in the server you want to backup and follow the steps below.


#### Create a `backups` user

Create the user and add permission to run `sudo`:

```bash
sudo useradd -d /home/backups -m backups -s /bin/bash
sudo passwd backups # set a password!
sudo adduser backups sudo
```

In order to access folders with different permissions, this user should be able to execute sudo from scripts, without password prompt. To enable this, you must edit permissions with the following command:

```bash
sudo visudo
```

And then add the line (replace backups for the name of the user that you previously created):

```bash
backups ALL=(ALL) NOPASSWD: ALL
```

Logout and login again with the new user.

#### Install `btsync`

*Warning*: btsync requires the same version across all servers syncing the same folder. Keep that in mind.

First of all, you have to clone this repository with the following command:

```bash
git clone https://github.com/mconf/backup-system.git
```

To install the backup tool you just have to run the following command:

```bash
./backup-system/scripts/install_backupsystem.sh # don't use sudo!
```

This will install `btsync` and setup a default encrypted folder under the path specified by the variable `BACKUP_PATH`. By default this folder is `/home/<user>/.backup`.
You can change it by altering the `BACKUP_PATH` variable before running the script, but this is not recommended.

Then, the script will return a secret that you should **take note** to add to another instance of `btsync` that will actually backup the data.
It is important to note that this secret is read-only to prevent improper deletion in any backup server.

This script is not idempotent. It will override the previous secret and you will have to reconfigure any remote backup server previously configured.

Updates for btsync can be made running the `update_btsync` script.


#### Running scripts to backup data

The scripts will create backup packages, encrypt them and copy everything to the folders shared with `btsync`.

The backup jobs currently available for use are:

* `webapp.sh`: to backup a web app, including a folder and a MySQL database.
* `db.sh`: to backup a database only, dumping it to an SQL file.
* `folders.sh`: to backup one folder.

First copy the script you want to a different file to edit it and give it permissions:

```bash
cp ./backup-system/scripts/jobs/webapp.sh ./backup-system/my_jobs/webapp_APP_NAME.sh
chmod 770 ./backup-system/my_jobs/webapp_APP_NAME.sh
```

Open it and set/replace these variables:

```bash
BACKUP_ID="app_name"                                      # a name that will be used to identify the files from this backup
DB_PASS="password"                                        # database password
DB_USER="username"                                        # database username
DB_NAME="app_table"                                       # database table name
APP_FILES="/var/www/app"                                  # folder with the files that will be backed up
SECRET="MY_ENCRYPTION_SECRET"                             # a password used to encrypt the files (make it as big as possible. 20+ )
BASE_SCRIPTS_PATH="./backup-system/scripts/base"          # path of the scripts used by other scripts
BACKUP_FOLDER="/home/BACKUP_USER/.backup/encrypted"       # path that you save the data, replace for you created login or change it completely
```

Script are folder independent, but all folder must be explicitly defined on each script.

Run it once to test it:

```bash
./backup-system/my_jobs/webapp_APP_NAME.sh
```

#### Add it to your backup server

Go to the server that will store your backups and add the new folder/secret to it.


#### Schedule your backups

We use crontab to make our backups. Here we present the basic commands to schedule a backup job to repeat at a given time.

To list cron jobs registered: `crontab -l`

To edit the table enterof jobs: `crontab -e`

Add, for example, one of the following commands:

```
# every day at 1:30 AM
30 1 * * * /bin/bash -l -c '/home/backups/backup-system/my_jobs/webapp_APP_NAME.sh'

# every Saturday at 1:00 AM
0 1 * * 6 /bin/bash -l -c '/home/backups/backup-system/my_jobs/webapp_APP_NAME.sh'
```

For further information, there are [many](http://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) tutorials across the internet.


#### Uninstall backup system

In order to undo this installation, you must first stop btsync process with the following command:

```bash
sudo killall btsync
```

Remove from the system initialization:

```bash
sudo update-rc.d -f btsync-daemon remove
```

Then you delete the following files:

```bash
sudo rm /etc/init.d/btsync-daemon
sudo rm /usr/local/bin/btsync
```

The following folders to be deleted may vary according to the user name created previously. You should replace *backups* for the name that you used. Notice that you will be deleting the backuped data and loose all configurations.

```bash
sudo rm -r /home/backups/.btsync
sudo rm -r /home/backups/.backup
```
Lastly, you should delete all cron jobs that you eventually added. You can access these through the following command:

```
crontab -e
```

## Future works

* Implement a better daemon system with start, stop and restart methods.
* Auto add secret to a specified backup server.

## Other

If you ever need to start your btsync deamon again, use:

```bash
sudo service btsync-daemon start
```

## Known issues

* You have to use the same version of btsync in all servers, and the installation script will always
install the latest version available.
* If using two scripts to backup files in the same server, use completely different IDs. IDs such as `redmine` and `redmine-something`
will not work as expected. The rotate script will consider that they are the same and files that shouldn't be removed
will be removed.
* The script `mkcuper_folders.sh` will only work with a single folder. This happens because we can't export an array
of strings (of paths) from one bash script to another.

To stop it just kill the process.
