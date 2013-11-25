#!/bin/bash
# Globale Variablen #
BaseDir=/media/5a24e136-09b9-48e1-95db-b44d5db3e28a
DownloadDir=${BaseDir}/Medien/Downloads
MediaDir=${BaseDir}/Medien
logline=$(date +'%d.%m.%Y')" "$(date +'%H:%M:%S')" FileBot"
LogFile=/root/.pyload/Logs/log.txt
tmpFolder=$MediaDir/tmp
DATE=$(date +%d.%m.%Y\ %H:%M:%S)

echo  "$logline ##########################" | tee -a $LogFile

echo  "$logline Dateihandling after FILEBOT is done" | tee -a $LogFile
echo  "$logline File has moved to $1" | tee -a $LogFile
cd /
echo "$logline New CreationDate" | tee -a $LogFile
touch -c "$1"
echo "$logline CHMOD 777" | tee -a $LogFile
chmod 777 "$1"
#echo "$logline Convert DTS Tracks to AC3" | tee -a $LogFile
#/mkvdts2ac3/mkvdts2ac3.sh -w "$tmpFolder" -n "$1"
