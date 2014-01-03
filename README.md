pyLoad_filebot
==============
pyLoad automation with the awesome Program FileBot by rednoah
These are scripts to have a automated sorting for Movies and Series you download with pyLoad

- check the scripts and edit it to suite your needs! 
- u dont need to use my scripts - maybe just some inspiration!

 - edit the Global Variables to suite your environment and Copy the file to ~/pyload/scripts/unrar_finished; ~/pyload/scripts/package_finished
 - than activate the "external scripts" plugin in pyLoad 
 - disable deep extraction
 - restart pyLoad
 - see the magic happen
 - difference between the 2 scripts, is, that package_finished also sorts blank downloaded files that are not packed

FileBot.sh
==============
Some additional stuff happening to the moved File
 - remove non-german Tracks (to save space on my NASHD)
 - Convert DTS to AC3 (to save space on my NASHD)
 - modify creation date (to have it stored under "recently added" on XBMC)
 - make it read / writeable for everyone (something i need to do)
 - send email with location of the file and changed filesize (nice to have)


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
