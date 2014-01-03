#!/bin/bash
# Globale Variablen #
BaseDir=/media/5a24e136-09b9-48e1-95db-b44d5db3e28a
DownloadDir=${BaseDir}/Medien/Downloads
MediaDir=${BaseDir}/Medien

## Log
DATE=$(date +%d.%m.%Y\ %H:%M:%S)
logline=$(date +'%d.%m.%Y')" "$(date +'%H:%M:%S')" FileBot"
LogFile=/root/.pyload/Logs/log.txt

## DTS2AC3 um den Datentransfer von OSDrive zu NASDrive zu umgehen (NASHD -> NASHD)
tmpFolder=$MediaDir/tmp

## String Manipulation
mailtitle_ext=${1##*/}
mailtitle=${mailtitle_ext%.*}

## nur dateien mit der Endung "mkv"
if [[ $1 =~ .*mkv.* ]]
then

FileSize1=$(ls -lah "$1" | awk '{ print $5}')
echo  "$logline ##########################" | tee -a $LogFile
echo  "$logline Dateihandling nachdem FILEBOT fertig ist" | tee -a $LogFile
echo  "$logline Datei wurde nach ~${1%/*.mkv}/* verschoben" | tee -a $LogFile
cd /

echo "$logline Entferne andersprachige Tonspur" | tee -a $LogFile
python /root/mkv_ger.py "${1%/*.mkv}"

echo "$logline DTS Tracks zu AC3 wandeln" | tee -a $LogFile
/mkvdts2ac3/mkvdts2ac3.sh -w "$tmpFolder" -n "$1"

echo "$logline Neues Erstelldatum" | tee -a $LogFile
touch -c "$1"

echo "$logline CHMOD 777" | tee -a $LogFile
chmod 777 "$1"

FileSize2=$(ls -lah "$1" | awk '{ print $5}')

echo "$logline E-Mail senden" | tee -a $LogFile
echo -e "Verschoben nach:\t~${1##*/Medien}\n\nDateigröße vorher:\t$FileSize1\nDateigröße danach:\t$FileSize2\n\n\nSincerly\nyour lovely NAS" | mailx -s "INFO: $mailtitle runtergeladen" your@mail.com;
else
echo "$logline $mailtitle_ext ist keine MKV" | tee -a $LogFile
fi
