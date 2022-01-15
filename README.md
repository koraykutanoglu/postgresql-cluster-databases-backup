## Backing Up Databases in PostgreSQL Cluster

It provides a script to backup databases in PostgreSQL cluster structure in this repository.

## Working Steps

1) First, edit the script file.

```
nano script.sh
```

2) You need to set the variables in the script file according to yourself. First, set the IP address of the backup server.

```
sftp_ip=10.10.10.xx
```

3) Enter the name of the user to connect to the backup server

```
sftp_user=root
```

4) Enter the port to make the SFTP connection

```
sftp_port=22
```

5) backups need to be taken in the local directory first. Specify the local directory where backups will be taken.

```
local_backup_directory=/my/backupdir
```

6) Where to back up files on the SFTP server. Attention! The contents of this specified directory should be reserved for backup files only. There should be no directories such as /root /etc. rm -rf is used when deleting historical files.

```
sftp_backup_directory=/root/backup
```

6) Enter the IP number in the last digit of your KeepAlived IP address. For example, if your keepalived IP address is 10.10.10.10, you should enter 10.

```
keepalivedip=xx
```

7) How many days the backups will be maintained on the SFTP server.

```
backup_time=5
```

8) ssh-key must be set for machines to access each other. This is how the backup is sent. ssh-key should be copied from all postgresql servers to SFTP server.

```
ssh-keygen
```

```
ssh-copy-id -f user@hostname
```


## Finally;

After all these settings, install this script file on all your postgresql cluster machines and create a cron for this file on each machine.

For example, let's say I run a cron at 1 o'clock every night. At 1 o'clock all the script files will run and the script file will check the IP address of each machine. The machine with the KeepAlived IP will run the script.

After the backup is received in the local directory and sent to the SFTP server, the backups will be deleted from the local directory.

In addition, historical backups will be kept on the SFTP server for the specified date.

## Script Screenshot

<img width="1661" alt="Ekran Resmi 2022-01-15 14 27 04" src="https://user-images.githubusercontent.com/59109688/149620123-91d1a215-8738-4aa3-8259-fa8c9b25edc5.png">
