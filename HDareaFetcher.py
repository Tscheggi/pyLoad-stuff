# -*- coding: utf-8 -*-
from module.plugins.Hook import Hook
import urllib2 
from BeautifulSoup import BeautifulSoup 
import re 

class HDareaFetcher(Hook):
    __name__ = "HDareaFetcher"
    __version__ = "0.6"
    __description__ = "Checks HD-AREA.org for new Movies. "
    __config__ = [("activated", "bool", "Activated", "False"),
                  ("interval", "int", "Check interval in minutes", "60"),
                  ("queue", "bool", "move Movies directly to Queue", "False"),
                  ("quality", "str", "720p or 1080p", "720p"),
                  ("rating","float","min. IMDB rating","6.1"),
                  ("hoster", "str", "Preferred Hoster (seperated by ;)","uploaded;cloudzer")]
    __author_name__ = ("Gutz-Pilz")
    __author_mail__ = ("")

    def setup(self):
        self.interval = self.getConfig("interval") * 60 
    def periodical(self):
        for site in ('Cinedubs', 'top-rls', 'movies', 'Old_Stuff', 'msd'):
            address = ('http://hd-area.org/index.php?s=' + site)
            page = urllib2.urlopen(address).read()
            soup = BeautifulSoup(page)
            movieTit = []
            movieLink = []
            movieRating = []

            try:
                for title in soup.findAll("div", {"class" : "topbox"}):
                    for title2 in title.findAll("div", {"class" : "boxlinks"}):
                         for title3 in title2.findAll("div", {"class" : "title"}):
                            movieTit.append(title3.getText())
                    for imdb in title.findAll("div", {"class" : "boxrechts"}):
                        if 'IMDb' in imdb.getText():
                            for aref in imdb.findAll('a'):
                                movieRating.append(imdb.getText())
                        if not 'IMDb' in imdb.getText():
                            movieRating.append('IMDb 0.1/10')
            except:
                pass

            for download in soup.findAll("div", {"class":"download"}):
                for descr in download.findAll("div", {"class":"beschreibung"}):
                    links = descr.findAll("span", {"style":"display:inline;"})
                    for link in links:
                            url = link.a["href"]
                            hoster = link.text
                            for prefhoster in self.getConfig("hoster").split(";"):
                                if prefhoster.lower() in hoster.lower():
                                    movieLink.append(url)
                                    break
                            else:
                                continue
                            break

            f = open("hdarea.txt", "a")            
            if (len(movieLink) > 0) :
                for i in range(len(movieTit)):                 
                    link = movieLink[i]
                    #cleaning the title from unnecessary stuff
                    title = movieTit[i]
                    title = title.lower()
                    title = title.replace('.german','')
                    title = title.replace('.bluray','')
                    title = re.sub(".(h|x)264(-|.)\S+", "", title)
                    title = re.sub(".complete-\S+", "", title)
                    title = re.sub(".remux-\S+", "", title)
                    title = re.sub(".web\S+", "", title)
                    title = re.sub(".nfo(-\S+|)", "", title)
                    title = title.replace('.dual','')
                    title = title.replace('.avc','')
                    title = title.replace('.dl','')
                    title = title.replace('.ac3ld','')
                    title = title.replace('.ac3d','')
                    title = title.replace('.ac3','')
                    title = title.replace('.dtshd','')
                    title = title.replace('.dtsd','')
                    title = title.replace('.dts','')
                    title = title.replace('.dd5.1','')
                    title = title.replace('.dtsd','')
                    title = title.replace('.5.1','')
                    title = title.replace('.hddvd','')
                    title = title.replace('.md','')
                    title = title.replace('.bluray','')
                    title = title.replace('.multi','')
                    title = title.replace('.disc1+2','')
                    title = title.replace('.extended','')
                    title = title.replace('.dubbed','')
                    title = title.replace('.ml','')
                    title = title.replace('.flac','')
                    title = title.replace('.read',' ')
                    title = title.replace('.unrated','')
                    title = title.replace('.directors','')
                    title = title.replace('.cut','')
                    s = open("hdarea.txt").read()    
                    if title in s:
                        self.core.log.debug("HDArea: Already been added:\t\t" +title[0:30])
                    else:
                        rating_txt = movieRating[i]
                        rating_float = rating_txt[5:8]
                        rating = rating_float.replace(',','.')    
                        rating = rating.replace('-/','0.')
                        list = [self.getConfig("quality")]
                        list2 = ['S0','s0','season','Season','DOKU','doku','Doku','s1','s2','s3','s4','s5']
                        if any(word in title for word in list) and rating > self.getConfig("rating"):
                            if any (word in title for word in list2):
                                self.core.log.debug("HDArea: REJECTED! not a Movie:\t\t" +title)
                            else: 
                                f.write(title+"\n")                      
                                f.write(link+"\n\n")
                                self.core.api.addPackage(title.encode("utf-8")+" IMDb: "+rating, link.split('"'), 1 if self.getConfig("queue") else 0)               
                                self.core.log.info("HDArea: !!! ACCEPTED !!!:\t\t" +title+"... with rating:\t"+rating)
                        else:
                            if rating < self.getConfig("rating"):
                                self.core.log.debug("HDArea: IMDb-Rating ("+rating+") to low:\t\t" +title)
                            if not any(word in title for word in list):
                                self.core.log.debug("HDArea: Quality ("+self.getConfig("quality")+") mismatch:\t\t" +title)
            f.close()
