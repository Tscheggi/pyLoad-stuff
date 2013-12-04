#!/bin/bash

# Global Variables #
DATE=$(date +%d.%m.%Y\ %H:%M:%S)
BaseDir=/media/5a24e136-09b9-48e1-95db-b44d5db3e28a
DownloadDir=${BaseDir}/Medien/Downloads
MediaDir=${BaseDir}/Medien
logline=$(date +'%d.%m.%Y')" "$(date +'%H:%M:%S')" FileBot"
LogFile=/root/.pyload/Logs/log.txt                   
ExtScript=/root/filebot.sh

# Pyload
DownloadFolder=$MediaDir/$1
SERVICE=unrar
SERVICE2=filebot

# FileBot-defs
MovieFormat="movieFormat=Movies/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}"
Ignore="ignore=\b(?i:doku)\b"
Execute="exec=sh $ExtScript \"{file}\""
Extras="clean=y artwork=n subtitles=de"

echo -e "$logline ##########################" | tee -a $LogFile
echo -e "$logline ............unrar_finished" | tee -a $LogFile

# check if there is a unrar process running
x=1
while (ps ax | grep -v grep | grep -v $0 | grep $SERVICE > /dev/null && [ $x -le 2 ])
do
        echo -e "$logline $SERVICE still running ...WAITING..." | tee -a $LogFile
        sleep 15
        x=$(( $x + 1 ))
done

# check if filebot is running
y=1
while (ps ax | grep -v grep | grep -v $0 | grep $SERVICE2 > /dev/null  && [ $y -le 3 ])
        do
                echo -e "$logline $SERVICE2 already running ..wait 60 secs" | tee -a $LogFile
                sleep 60
                y=$(( $y + 1 ))
        done

# final check before running
if  (ps ax | grep -v grep | grep -v $0 | grep $SERVICE > /dev/null ||  ps ax | grep -v grep | grep -v $0 | grep $SERVICE2)
        
        then
                echo -e "$logline $SERVICE or $SERVICE2 still running - ABORT" | tee -a $LogFile
                exit

        else
        # Functions #
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

        # Execute the functions#
        echo -e "$logline sorting Files with Filebot" | tee -a $LogFile
        sortiere
        echo -e "$logline cleaning Clutter with Filebot" | tee -a $LogFile
        cleaning
        #echo -e "$logline XBMC clean" | tee -a $LogFile
        #xbmc_clean
        #echo -e "$logline XBMC scan" | tee -a $LogFile
        #xbmc_scan
fi
