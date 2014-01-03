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

## String Manipulation für den EmailVersand
mailtitle_ext=${1##*/}
mailtitle=${mailtitle_ext%.*}

## nur dateien mit der Endung "mkv" als email versenden
if [[ $1 =~ .*mkv.* ]]
then

  echo  "$logline ##########################" | tee -a $LogFile
  echo  "$logline Dateihandling nachdem FILEBOT fertig ist" | tee -a $LogFile
  echo  "$logline Datei wurde nach $1 verschoben" | tee -a $LogFile
  cd /

  echo "$logline Entferne andersprachige Tonspur" | tee -a $LogFile
  python /root/mkv_ger.py "${1%/*.mkv}"

  echo "$logline DTS Tracks zu AC3 wandeln" | tee -a $LogFile
  /mkvdts2ac3/mkvdts2ac3.sh -w "$tmpFolder" -n "$1"

  echo "$logline Neues Erstelldatum" | tee -a $LogFile
  touch -c "$1"

  echo "$logline CHMOD 777" | tee -a $LogFile
  chmod 777 "$1"

  echo "$logline E-Mail senden" | tee -a $LogFile
  echo -e "pyLoad hat einen Film heruntergeladen und wurde durch Filebot nach \n\n\t ~${1##*/Medien} \n\n verschoben \n\n\n Sincerly \n your lovely NAS" | mailx -s "INFO: $mailtitle runtergeladen" hannes.mueller87@gmail.com;

else
  echo "$logline $mailtitle_ext ist keine MKV" | tee -a $LogFile
fi
