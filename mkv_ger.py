#!/usr/bin/python

import os
import re
import sys
import StringIO
import subprocess

# change this for other languages (3 character code)
LANG = "ger"

# set this to the path for mkvmerge
MKVMERGE = "mkvmerge"

AUDIO_RE    = re.compile(r"Spur ID (\d+): audio \([A-Z0-9_/]+\) [number:\d+ uid:\d+ codec_id:[A-Z0-9_/]+ codec_private_length:\d+ language:([a-z]{3})")
SUBTITLE_RE = re.compile(r"Spur ID (\d+): subtitles \([A-Z0-9_/]+\) [number:\d+ uid:\d+ codec_id:[A-Z0-9_/]+ codec_private_length:\d+ language:([a-z]{3})(?: track_name:\w*)? default_track:[01]{1} forced_track:([01]{1})")

if len(sys.argv) < 2:
    print "Please supply an input directory"
    sys.exit()

in_dir = sys.argv[1]

for root, dirs, files in os.walk(in_dir):
    for f in files:

        # filter out non mkv files
        if not f.endswith(".mkv"):
            continue

        # path to file
        path = os.path.join(root, f)

        # build command line
        cmd = [MKVMERGE, "--identify-verbose", path]

        # get mkv info
        mkvmerge = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = mkvmerge.communicate()
        if mkvmerge.returncode != 0:
            print >> sys.stderr, "mkvmerge failed to identify", path
            continue

        # find audio and subtitle tracks
        audio = []
        subtitle = []
        for line in StringIO.StringIO(stdout):
            m = AUDIO_RE.match(line)
            if m:
                audio.append(m.groups())
            else:
                m = SUBTITLE_RE.match(line)
                if m:
                    subtitle.append(m.groups())

        # filter out files that don't need processing
        if len(audio) < 2 and len(subtitle) < 2:
            print >> sys.stderr, "nothing to do for", path
            continue

        # filter out tracks that don't match the language	
        audio_lang = filter(lambda a: a[1]==LANG, audio)
        subtitle_lang = filter(lambda a: a[1]==LANG, subtitle)

        # filter out files that don't need processing
        if len(audio_lang) == 0 and len(subtitle_lang) == 0:
            print >> sys.stderr, "no tracks with that language in", path
            continue

        # build command line
        cmd = [MKVMERGE, "-o", path + ".temp"]
        if len(audio_lang):
            cmd += ["--audio-tracks", ",".join([str(a[0]) for a in audio_lang])]
            for i in range(len(audio_lang)):
                cmd += ["--default-track", ":".join([audio_lang[i][0], "0" if i else "1"])]
        if len(subtitle_lang):
            cmd += ["--subtitle-tracks", ",".join([str(s[0]) for s in subtitle_lang])]
            for i in range(len(subtitle_lang)):
                cmd += ["--default-track", ":".join([subtitle_lang[i][0], "0"])]
        cmd += [path]

        # process file
        print >> sys.stderr, "Processing", path, "...",
        mkvmerge = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = mkvmerge.communicate()
        if mkvmerge.returncode != 0:
            print >> sys.stderr, "Failed"
            continue
        
        print >> sys.stderr, "Succeeded"

        # overwrite file
        os.remove(path)
        os.rename(path + ".temp", path)
