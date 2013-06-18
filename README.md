# Backup system

This set of scripts is used to implement the backup policies used by mconf's infrastructure.

The ideia is to use [btsync](http://labs.bittorrent.com/experiments/sync.html) to backup encrypted files using read-only secrets to avoid that a backup server propagates improper deletions.

All scripts here are designed for Ubuntu 10.04+.

## Usage

Log in the server you want to backup and follow the steps below.

#### Create a `backups` user

Create the user and add permission to run `sudo`:

```bash
sudo useradd -d /home/backups -m backups -s /bin/bash
sudo passwd backups # set a password!
sudo adduser backups sudo
```

Logout and login again with the new user.

#### Clone this repository

```
git clone https://github.com/mconf/backup-system.git
```

#### Install `btsync`

To install the backup tool you just have to run the following command:

` ./backup-system/scripts/install_backupsystem.sh `

This will install `btsync` and setup a default encrypted folder under the path specified by the variable `BACKUP_PATH`. By default this folder is `/home/<user>/.backup`.
You can change it by altering the `BACKUP_PATH` variable before running the script, but it is not recommended.

Then, the script will return a secret that you should **take note** to add to another instance of `btsync` that will backup the data.
It is important to note that this secret is read-only to prevent improper deletion in any backup server.

This script is not idempotent.

Updates can be made running the `update_btsync` script.


#### Run the scripts that will backup the data

The scripts will created backup packages, encrypt them and copy everything to the folders shared with `btsync`.

The scripts currently available for use are:

* `mckuper_webapp.sh`: to backup a web app, including a folder and a database.
* `mckuper_folders.sh`: to backup one or more folders.

First copy the script you want to a different file to edit it and give it permissions:

```bash
cp ./backup-system/scripts/mckuper/mckuper_webapp.sh ./backup-system/scripts/mckuper/mckuper_webapp_APP_NAME.sh
chmod a+x ./backup-system/scripts/mckuper/mckuper_webapp_APP_NAME.sh
```

Open it and set/replace these variables:

```bash
BACKUP_ID="app_name"             # a name that will be used to identify the files from this backup
DB_PASS="password"               # database password
DB_USER="username"               # database username
DB_NAME="app_table"              # database table name
APP_FILES="/var/www/app"         # folder with the files that will be backed up
SECRET="MY_ENCRYPTION_SECRET"    # a password used to encrypt the files (make it as big as possible)
```

It is important to keep the scripts on their original folders, as some scripts call others.

Run it once to test it:

```bash
cd ./backup-system/scripts/mckuper/
./mckuper_webapp_APP_NAME.sh
```


#### Schedule your backups

We use crontab to make our backups. Here we present the basic commands to schedule a backup job to repeat at a given time.

To list cron jobs registered: `crontab -l`

To edit the table enterof jobs: `crontab -e`

Add, for example, the following line:

```
30 1 * * * cd ./backup-system/scripts/mckuper/; ./mckuper_webapp_APP_NAME.sh
```

This will make `mckuper_webapp_APP_NAME.sh` be called every day at 01:30.

For further information, there are [many](http://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) tutorials across the internet.

## Future works

* Implement a better daemon system with start, stop and restart methods.
* Auto add secret to a specified backup server.
