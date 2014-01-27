#!/bin/bash
# Version 0.1 
# Globale Variablen #
DATE=$(date +%d.%m.%Y\ %H:%M:%S) 
BaseDir=/media/5a24e136-09b9-48e1-95db-b44d5db3e28a
DownloadDir=${BaseDir}/Medien/Downloads
MediaDir=${BaseDir}/Medien
LogFile=/root/.pyload/Logs/log.txt 			# LogFile
ExtScript=filebot.sh

#Pyload
DownloadFolder=$MediaDir/$1
SERVICE=unrar
SERVICE2=filebot

#FileBot-defs
MovieFormat="movieFormat=Movies/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}"
Ignore="ignore=\b(?i:doku)\b"
Execute="exec=cd /root/ && ./$ExtScript \"{file}\""
Extras="clean=y artwork=n"


logit(){
	logline=$(date +'%d.%m.%Y')" "$(date +'%H:%M:%S')" FileBot\t"
	echo -e "$logline " $* | tee -a $LogFile
	return 0
}

logit "##########################"
logit "............unrar_finished"
sleep 10
count=`find "$DownloadFolder" -name "*.rar" -o -name "*.r0*" 2>/dev/null | wc -l`
if [ $count != 0 ]
then
		logit "ABORT! Still some Archives"
		exit
else
		logit "Starting FileBot!"
		logit "$DownloadFolder"
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
		# Execute the functions#
		logit "sorting Files with FileBot"
		sortiere
		logit "cleaning Clutter with FileBot"
		cleaning
		#logit "XBMC clean"
		#xbmc_clean
		#logit "XBMC scan"
		#xbmc_scan
exit
fi
