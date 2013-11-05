#!/bin/bash

# Global Variables #
DATE=$(date +%d.%m.%Y\ %H:%M:%S) 
BaseDir=/media/5a24e136-09b9-48e1-95db-b44d5db3e28a
DownloadDir=${BaseDir}/Medien/Downloads
MediaDir=${BaseDir}/Medien
LogFile=$BaseDir/Scripts/filebot.log
ExtScript=/root/filebot.sh #to make further execution to the moved file

#Pyload
DownloadFolder=$MediaDir/$1
SERVICE=filebot

#FileBot-defs
#MovieFormat is set to rename the files with german titles
MovieFormat="movieFormat=Movies/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}"
Ignore="ignore=\b(?i:do(k|c)u)\b"
Execute="exec=sh $ExtScript \"{file}\""
Extras="clean=y artwork=y subtitles=de"


#code
echo -e "##############################" | tee -a $LogFile
echo -e "$DATE \tINFO:\tpyLoad UNRAR_FINISHED" | tee -a $LogFile

# Am i the only instance?
if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
        echo  -e "$DATE \tWarning:\tThis script already runs with PID `pidof -x $(basename $0) -o %PPID`" | tee -a $LogFile
        exit
fi

# Is filebot already running?
if ps ax | grep -v grep | grep -v $0 | grep $SERVICE > /dev/null
then
	echo -e "$DATE \tWarning:\t$SERVICE Already running - Abort!" | tee -a $LogFile
else
	sleep 5
        echo -e "$DATE \tINFO:\t$SERVICE not running" | tee -a $LogFile
		
	# Nur ausführen wenn keine RAR-Dateien da sind - das entpacken soll pyLoad selbst machen(passwörter)?
	cd "$DownloadFolder"
	count=`ls -1 *.rar 2>/dev/null | wc -l`
	if [ $count != 0 ]
	then
		echo -e "$DATE \tWarning:\tThere are Archives... Abort!" | tee -a $LogFile
	else
		echo -e "$DATE \tINFO:\tNo RAR-file found in $1  - START FileBot!" | tee -a $LogFile
		
		# Functions #
		sortiere(){
		filebot -script fn:amc "$DownloadFolder" --output "$MediaDir" --conflict override -non-strict --action move --def "$MovieFormat" "$Ignore" "$Execute" $Extras
		}
		cleaning(){
		filebot -script fn:cleaner "$DownloadFolder" --def root=y "$Ignore" "exts=jpg|nfo|rar|etc" "terms=sample|trailer|etc"
		}
		
		# Execute #
		echo -e "$DATE \tINFO:\tFilebot ausfuehren" | tee -a $LogFile
		sortiere | tee -a $LogFile
		echo -e "$DATE \tINFO:\tFilebot aufraeumen" | tee -a $LogFile
		cleaning | tee -a $LogFile
		exit
	fi
fi

