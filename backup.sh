#! /bin/bash

# please fill in the definications

sftp_ip=10.10.10.xx
sftp_user=root
sftp_port=22
local_backup_directory=/my/backupdir
sftp_backup_directory=/root/backup
keepalivedip=xx
backup_time=5
file_password=password
separator=$(printf "%-73s" "-")

echo "${separator// /-}"
echo "Checking Keepalived IP"
keepalived=$(hostname -I | grep -o $keepalivedip)
if [[ "$keepalived" -eq "$keepalivedip" ]]; then
echo "${separator// /-}"
echo "IP checked. Backup is progress"
sleep 2
echo "${separator// /-}"
echo "Checking the date and Date is assigned as a variable"
date=`date +%Y-%m-%d-%H-%M`
sleep 2
echo "${separator// /-}"
echo "Create a directory for date $date"
echo "${separator// /-}"
mkdir -p $local_backup_directory/$date
backupdir=$local_backup_directory/$date
echo "PostgreSQL backup is start"
sleep 2
echo "${separator// /-}"
echo "Backup directory: $backupdir"
sleep 1
start=$(date +%s)
echo "${separator// /-}"
echo "pg_dumpall is start"
sleep 2
sudo -u postgres pg_dumpall --globals-only | gzip > $backupdir/postgres_globals.sql.gz
for db in `sudo -u postgres psql -t -c "select datname from pg_database where not datistemplate" | grep '\S' | awk '{$1=$1};1'`; do
   sudo -u postgres pg_dump $db | gzip | gpg -c --batch --passphrase $file_password > $backupdir/$db.sql.gz.gpg
done
end=$(date +%s) 
echo "${separator// /-}"
echo "Backup is completed"
sleep 2
echo "${separator// /-}"
echo "Backup time: $(($end-$start)) second"
sleep 2
echo "${separator// /-}"
echo "Backup list:"
ls $backupdir
echo "${separator// /-}"
echo "SFTP connection is checking"
echo "${separator// /-}"
ssh -q -p $sftp_port root@$sftp_ip exit
if [[ "$?" -eq "0" ]]; then
echo "older than $backup_time days backup files in SFTP server the deleting"
ssh -o StrictHostKeyChecking=no -p $sftp_port -l $sftp_user $sftp_ip "find $sftp_backup_directory/* -mtime +$backup_time -exec rm -rf {} \;"
echo "${separator// /-}"
echo "Connection is successful, file transfer is starting"
echo "${separator// /-}"
echo "Backup directory is creating in SFTP server"
ssh -o StrictHostKeyChecking=no -l $sftp_user $sftp_ip "mkdir -p $sftp_backup_directory/$date"
echo "${separator// /-}"
echo "Backup files transfer to SFTP server"
scp -P $sftp_port $backupdir/* root@$sftp_ip:$sftp_backup_directory/$date
echo "${separator// /-}"
echo "File transfer is finished"
echo "${separator// /-}"
rm -rf $backupdir
echo "Backup files are deleted"
echo "${separator// /-}"
else
echo "Connection is fail. Backup is stopping."
fi
else
echo "Keepalived IP not available. Backup is stopping."
fi
