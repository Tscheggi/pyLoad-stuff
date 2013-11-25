#!/bin/bash

# Globale Variablen #
DATE=$(date +%d.%m.%Y\ %H:%M:%S)
BaseDir=/media/5a24e136-09b9-48e1-95db-b44d5db3e28a
DownloadDir=${BaseDir}/Medien/Downloads
MediaDir=${BaseDir}/Medien
logline=$(date +'%d.%m.%Y')" "$(date +'%H:%M:%S')" FileBot"
LogFile=/root/.pyload/Logs/log.txt                      # LogFile
ExtScript=/root/filebot.sh

#Pyload
DownloadFolder=$MediaDir/$1
SERVICE=filebot

#FileBot-defs
MovieFormat="movieFormat=Movies/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}"
Ignore="ignore=\b(?i:doku)\b"
Execute="exec=sh $ExtScript \"{file}\""
Extras="clean=y artwork=n subtitles=de"

echo -e "$logline ##########################" | tee -a $LogFile
echo -e "$logline ............unrar_finished" | tee -a $LogFile


        # Funktionen #
        sortiere(){
        filebot -script fn:amc "$DownloadFolder" --output "$MediaDir" --conflict override -non-strict --action move --def "$MovieFormat" "$Ignore" "$Execute" $Extras
        }
        cleaning(){
        filebot -script fn:cleaner "$DownloadFolder" --def root=y "$Ignore" "exts=jpg|nfo|rar|etc" "terms=sample|trailer|etc"
        }

                # Ausfuehren #
                # Execute the functions#
                echo -e "$logline sorting Files with Filebot" | tee -a $LogFile
                sortiere
                echo -e "$logline cleaning Clutter with Filebot" | tee -a $LogFile
                cleaning
                exit
