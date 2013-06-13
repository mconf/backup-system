# Backup Systems

This set of scripts is used to implement the backup policies used by mconf's infrastructure.

The ideia is to use [btsync](http://labs.bittorrent.com/experiments/sync.html) to backup encrypted files using read-only secrets to avoid that a backup server propagates improper deletions.

All scripts here are designed for Ubuntu 10.04+.

## Usage

In order to deploy the backup system, you should clone this repository and make a copy of each desired backup job and replace the indicated variables. For example:

` cp ./backup-system/scripts/install_backupsystem.sh ./backup-system/scripts/MY_BACKUP_JOB.sh`

replacing the variables:

`
BACKUP_ID="MY_BACKUP"
DB_PASS="MY_PASSWORD"
DB_USER="MY_USER"
DB_NAME="MY_TABLE"
APP_FILES="MY_BACKEDUP_FOLDER"
SECRET="MY_ENCRYPTION_SECRET"
`

It is important to keep every script on the same folder, as some scripts call others.

### Install btsync

To install the backup tool you just have to run the fallowing command:

` ./backup-system/scripts/install_backupsystem.sh `

This will install btsync and setup a default encrypted folder under the path specified by the variable BACKUP_PATH. You can change this folder by altering this variable before running the script.
Then, the script will return a secret that you should TAKE NOTE to add to another instance of btsync that will act as a backup server.
It is important to note that this secret is read-only to prevent improper deletion in any backup server.

This script is not idempotent. 

Updates can be made running the update_btsync script. 

### Schedule Backups

We use crontab to make our backups. Here we present the basic commands to schedule a backup job to repeat at a given time.

To list cron jobs:

` crontab -l `

To add a job, enter the command:

` crontab -e `

and add, for exemple, the fallowing line:

` 0 1 * * * /path/to/script.sh `

This will make script.sh to be called every day at 01:00.


For further information, there are [many](http://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) tutorials across the internet.

## Future Works

* Implement a better daemon system with start, stop and restart methods.
* Auto add secret to a specified backup server.




