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
	echo  "$logline ##########################" | tee -a $LogFile
	echo  "$logline Dateihandling nachdem FILEBOT fertig ist" | tee -a $LogFile
	echo  "$logline Datei wurde nach ~${1%/*.mkv}/* verschoben" | tee -a $LogFile
	DUCMD="$(which \du) -m"
	FileSize1=$($DUCMD "$1" | cut -f1)
	FileSize12=$(echo "$FileSize1" | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1.\2/;ta')
	cd /

	echo "$logline Entferne andersprachige Tonspur" | tee -a $LogFile
	python /root/mkv_ger.py "${1%/*.mkv}"
        FileSize2=$($DUCMD "$1" | cut -f1)
	DIFF1=$(($FileSize1 - $FileSize2))
	DIFF12=$(echo "$DIFF1" | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1.\2/;ta')

	echo "$logline DTS Tracks zu AC3 wandeln" | tee -a $LogFile
	/mkvdts2ac3/mkvdts2ac3.sh -w "$tmpFolder" -n "$1"
	FileSize3=$($DUCMD "$1" | cut -f1)
	DIFF2=$(($FileSize2 - $FileSize3))
	DIFF22=$(echo "$DIFF2" | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1.\2/;ta')

	echo "$logline Neues Erstelldatum" | tee -a $LogFile
	touch -c "$1"

	echo "$logline CHMOD 777" | tee -a $LogFile
	chmod 777 "$1"
	Final=$($DUCMD "$1" | cut -f1)
	Final2=$(echo "$Final" | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1.\2/;ta')

	echo -e "\nOriginal\t = \t$FileSize12 GB"
	echo -e "AudioTrack\t = \t$DIFF12 GB"
	echo -e "DTS2AC3\t\t = \t$DIFF22 GB"
	echo -e "FinalSize\t = \t$Final2 GB\n"
	# schlaue mail ;)

	send_email(){
	if [ $FileSize1 == $FileSize2 -a $FileSize2 == $FileSize3 ]; then
		echo "$logline E-Mail senden (nichts komprimiert)" | tee -a $LogFile
		echo -e "Verschoben nach:\t ~${1##*/Medien}\n\nKeine Platzsparmaßnahmen stattgefunden\nFinale Größe:\t$Final2 MB\n\n\nSincerly\nyour lovely NAS" | mailx -s "INFO: $mailtitle runtergeladen" your@mail.com;
	else
		echo "$logline E-Mail senden (verkleinert)" | tee -a $LogFile
		echo -e "Verschoben nach:\t ~${1##*/Medien}\n\nOriginal:\t$FileSize12 MB\nAudioSpur entfernt:\t$DIFF12 MB\nAudioSpur komprimiert:\t$DIFF22 MB\nFinale Größe:\t$Final2 MB\n\n\nSincerly\nyour lovely NAS" | mailx -s "INFO: $mailtitle runtergeladen" your@mail.com;
	fi
	}

	send_email
else
	echo "$logline $mailtitle_ext ist keine MKV" | tee -a $LogFile
fi
