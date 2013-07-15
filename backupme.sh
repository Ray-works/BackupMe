#!/bin/bash
# Backup Me
# www.Ray-works.de

# MySQL Konfiguration
MYSQL_USER=
MYSQL_PASS=

# Backup-Verzeichnis definieren
DESTINATION="/backup";

# Zu sichernde Verzeichnisse
SOURCE="/etc /var/log /var/www /var/vmail /mysqldump";

# Ausnahmen
EXCLUDE="/var/www/testfolder";

# Archive Name
DATE=`date +"%Y-%m-%d"`;
ARCHIVE="Backup-$DATE.tgz"

# Anzahl der maximalen Backups
MAX=5;

# Backup-Verzeichnis anlegen 
if [ ! -d "$DESTINATION" ]; then
  mkdir $DESTINATION
fi

if [ ! -d "/mysqldump" ]; then
  mkdir /mysqldump
fi

while [ `ls $DESTINATION -1 | wc -l` -gt $(($MAX-1)) ]; do
    OLDEST=`ls $DESTINATION | head -1`
    echo "Entferne altes Backup: $OLDEST";
    rm -rf $DESTINATION/$OLDEST
done

# Sicherung der Datenbanken
cd /mysqldump
for x in $(mysql -u$MYSQL_USER -p$MYSQL_PASS -Bse 'show databases'); do
mysqldump -u$MYSQL_USER -p$MYSQL_PASS --single-transaction $x > ${x}-$DATE.sql
done

cd ../

# Archivieren
tar zcfP $DESTINATION/$ARCHIVE $SOURCE --exclude=$EXCLUDE

# Datenbank Backups löschen, da sie schon im Archiv sind
rm -rf /mysqldump
