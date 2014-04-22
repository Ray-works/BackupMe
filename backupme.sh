#!/bin/bash

# Backup Script
# by Ray-works.de
# Update: 29.10.2013

# Date
DATE=`date +"%Y-%m-%d"`;

echo "--- Backup Started ---";
echo "--- $DATE ---";

# MySQL & FTP Konfiguration
MYSQL_USER=root
MYSQL_PASS=

# Storage Konfiguration
NFSIP=""
NFSVOL=""
MOUNTPOINT="/mnt/storage"

# Mountpoint "storage" anlegen
if [ ! -d $MOUNTPOINT ]; then
    mkdir $MOUNTPOINT
	echo "Status: Mountpoint created.";
fi

# Solange storage nicht gemountet ist, versuche alle 10 Sekunden es zu mounten
until mount | grep "$MOUNTPOINT" &> /dev/null; do
   mount -t nfs $NFSIP:$NFSVOL $MOUNTPOINT &> /dev/null
   sleep 10
done

echo "Status: Storage mounted.";

# Backup-Verzeichnis definieren
DESTINATION="$MOUNTPOINT";

# MySQL Dump Verzeichnis anlegen
if [ ! -d "/mysqldump" ]; then
  mkdir /mysqldump
  echo "Status: MySQL-Dump directory created.";
fi

# Zu sichernde Verzeichnisse
SOURCE="/root /etc /var/log /var/www /var/vmail /var/tools /mysqldump /home/ray";

# Archive Name
ARCHIVE="Backup-$DATE.tgz"

# Anzahl der maximalen Backups
MAX=10;

while [ `ls $DESTINATION -1 | wc -l` -gt $(($MAX-1)) ]; do
    OLDEST=`ls $DESTINATION | head -1`
    echo "Status: Removing old backup -> $OLDEST";
    rm -rf $DESTINATION/$OLDEST
done

# Sicherung der Datenbanken
cd /mysqldump
for x in $(mysql -u$MYSQL_USER -p$MYSQL_PASS -Bse 'show databases'); do
  mysqldump -u$MYSQL_USER -p$MYSQL_PASS --single-transaction $x > ${x}-$DATE.sql
  echo "MySQL-Dump: ${x}-$DATE.sql created.";
done

cd ../

# Archivieren
tar zcfP $DESTINATION/$ARCHIVE $SOURCE

# Backups löschen
rm -rf /mysqldump

umount $MOUNTPOINT
echo "Status: Storage unmounted.";
echo "--- Backup Completed ---";
echo "--- $DATE ---";
