#!/bin/bash

# Globale Variablen #
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
MovieFormat="movieFormat=Movies/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}"
Ignore="ignore=\b(?i:doku)\b"
Execute="exec=sh $ExtScript \"{file}\""
Extras="clean=y artwork=y subtitles=de"


#code
echo -e "##############################" | tee -a $LogFile
echo -e "$DATE \tINFO:\tpyLoad UNRAR_FINISHED" | tee -a $LogFile

# Bin ich die einzige Instanz dieses Scriptes?
if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
        echo  -e "$DATE \tWarnung:\tDas Script wird schon ausgeführt als PID `pidof -x $(basename $0) -o %PPID`" | tee -a $LogFile
        exit
fi

# Läuft Filebot irgendwo schonmal?
if ps ax | grep -v grep | grep -v $0 | grep $SERVICE > /dev/null
then
	echo -e "$DATE \tWarnung:\t$SERVICE laeuft schon - lass es sein!" | tee -a $LogFile
else
	sleep 5
        echo -e "$DATE \tINFO:\t$SERVICE laeuft nicht" | tee -a $LogFile
		
	# Nur ausführen wenn keine RAR-Dateien da sind - das entpacken soll pyLoad selbst machen(passwörter)?
	cd "$DownloadFolder"
	count=`ls -1 *.rar 2>/dev/null | wc -l`
	if [ $count != 0 ]
	then
		echo -e "$DATE \tWarnung:\tHier sind noch Archive... abbruch!" | tee -a $LogFile
	else
		echo -e "$DATE \tINFO:\tkeine rar-Dateien in $1 zu finden - es kann los gehen!" | tee -a $LogFile
		# Funktionen #
		sortiere(){
		filebot -script fn:amc "$DownloadFolder" --output "$MediaDir" --conflict override -non-strict --action move --def "$MovieFormat" "$Ignore" "$Execute" $Extras
		}
		cleaning(){
		filebot -script fn:cleaner "$DownloadFolder" --def root=y "$Ignore" "exts=jpg|nfo|rar|etc" "terms=sample|trailer|etc"
		}
		xbmc_clean(){
		curl -s -d '{"jsonrpc":"2.0","method":"VideoLibrary.Clean","id":1}' -H 'content-type: application/json;' http://192.168.0.107:8585/jsonrpc?VideoLibrary.Clean
		}
		xbmc_scan(){
		curl -s -d '{"jsonrpc":"2.0","method":"VideoLibrary.Scan","id":1}' -H 'content-type: application/json;' http://192.168.0.107:8585/jsonrpc?VideoLibrary.Scan
		}
		
		# Ausfuehren #
		echo -e "$DATE \tINFO:\tFilebot ausfuehren" | tee -a $LogFile
		sortiere
		echo -e "$DATE \tINFO:\tFilebot aufraeumen" | tee -a $LogFile
		cleaning | tee -a $LogFile
		echo -e "$DATE \tINFO:\tNAS_XBMC - Library aufraeumen" | tee -a $LogFile
		#xbmc_clean | tee -a $LogFile
		echo -e "\n$DATE \tINFO:\tNAS_XBMC - Library scannen" | tee -a $LogFile
		#xbmc_scan | tee -a $LogFile
		exit
	fi
fi

