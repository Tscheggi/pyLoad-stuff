pyLoad_filebot
==============

pyLoad automation with the awesome Program FileBot by rednoah


These are scripts to have a automated sorting for Movies and Series you download with pyLoad

- edit the Global Variables to suite your environment and Copy the file to ~/pyload/scripts/unrar_finished; ~/pyload/scripts/package_finished
- than activate the "external scripts" plugin in pyLoad 
- disable deep extraction
- restart pyLoad
- see the magic happen

FileBot.sh
==============
Some additional stuff happening to the moved File

mkv_ger.py
==============
Filebot.sh uses this script to remove all non-ger Audiotracks
http://forum.videohelp.com/threads/343271-BULK-remove-non-English-tracks-from-MKV-container?p=2201831&viewfull=1#post2201831


[Hook] HD-Area.org Fetcher Plugin
==============

Es checkt nach einem (selbst definierbarem) Interval HD-Area.org ab (Cinedubs, Filme, top-rls)
Dabei kann man ein minimum an IMDB Rating angeben und die Qualität festlegen was dann schlussendlich dem pyLoad hinzugefügt werden soll.


die Datei ist einzufügen in:
~/.pyload/userplugins/hooks/
pyload neustarten und Plugin aktivieren

viel spass damit.
