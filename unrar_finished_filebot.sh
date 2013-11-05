#!/bin/bash

# Global Variables #

BaseDir=/media/5a24e136-09b9-48e1-95db-b44d5db3e28a 	# MAINFolder
MediaDir=${BaseDir}/Medien 				# where the files are moved to (~Mediadir/TV Shows/SeriesName/Season x/SeriesName - SxEx - Title_en ; ~Mediadir/Movies/movie (year))
LogFile=$BaseDir/Scripts/filebot.log 			# LogFile
DATE=$(date +%d.%m.%Y\ %H:%M:%S) 			# for a better overview in the logfile
ExtScript=/root/filebot.sh 				# to make further execution to the moved file



#Pyload
# "/$1" is given by pyLoad after a package is extracted succesfully (/Downloads/packagefolder)
# so just edit MediaDir and BaseDir
DownloadFolder=$MediaDir/$1 				# The given packagefolder from pyLoad to only process the finished files



#FileBot-defs
#MovieFormat is set to rename the files with german titles

MovieFormat="movieFormat=Movies/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}/{net.sourceforge.filebot.WebServices.TMDb.getMovieInfo(movie, Locale.GERMAN).name} {'('+y+')'}"
Ignore="ignore=\b(?i:do(k|c)u)\b"
Execute="exec=sh $ExtScript \"{file}\""
Extras="clean=y artwork=y subtitles=de"



#code

echo -e "##############################" | tee -a $LogFile
echo -e "$DATE \tINFO:\tpyLoad UNRAR_FINISHED" | tee -a $LogFile



# Am i the only instance - if not cancel
# to prevent that 2 instances are gonna "fight" each other

if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
        echo  -e "$DATE \tWarning:\tThis script already runs with PID `pidof -x $(basename $0) -o %PPID`" | tee -a $LogFile
        exit
fi


	# Functions #
	sortiere(){
	filebot -script fn:amc "$DownloadFolder" --output "$MediaDir" --conflict override -non-strict --action move --def "$MovieFormat" "$Ignore" "$Execute" $Extras
	}
	cleaning(){
	filebot -script fn:cleaner "$DownloadFolder" --def root=y "$Ignore" "exts=jpg|nfo|rar|etc" "terms=sample|trailer|etc"
	}
	
	# Execute the functions#
	echo -e "$DATE \tINFO:\tFilebot ausfuehren" | tee -a $LogFile
	sortiere | tee -a $LogFile
	echo -e "$DATE \tINFO:\tFilebot aufraeumen" | tee -a $LogFile
	cleaning | tee -a $LogFile
	exit


