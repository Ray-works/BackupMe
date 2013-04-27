#!/bin/bash
#
# Backup Me
# by Eray 'Ray' Sönmez
# www.Ray-works.de

# Allgemeine Angaben
MYSQL_USER=
MYSQL_PASS=
FTP_SERVER=
FTP_USER=
FTP_PASS=

# Festlegung des Datums - Format: 19700101
DATE=`date +"%Y%m%d"`

# Backup-Verzeichnis anlegen 
mkdir /tmp/backup
mkdir /tmp/backup/mysql

# Verzeichnisse die ins Backup integriert werden sollen
cp -r /etc /tmp/backup
cp -r /var/log /tmp/backup
#cp -r /var/www /tmp/backup

cd /tmp/backup/mysql

# Sicherung der Datenbanken
for x in $(mysql -u$MYSQL_USER -p$MYSQL_PASS -Bse 'show databases'); do
mysqldump -u$MYSQL_USER -p$MYSQL_PASS --single-transaction $x > ${x}-$DATE.sql
done

cd ../

# Alle Dateien mit tar.bz2 komprimieren
tar cjfp etc-$DATE.tar.bz2 etc
tar cjfp logs-$DATE.tar.bz2 log
tar cjfp mysql-$DATE.tar.bz2 mysql
#tar cjfp web-$DATE.tar.bz2 www

# Alle komprimierten Dateien per FTP auf den Backup-Server laden
ftp -ni << END_UPLOAD
  open $FTP_SERVER
  user $FTP_USER $FTP_PASS
  bin
  cd html
  mput *.tar.bz2
  quit
END_UPLOAD

# Anschliessend alle auf den Server angelegten Dateien wieder loeschen
rm -rf /tmp/backup
