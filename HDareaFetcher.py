# -*- coding: utf-8 -*-
from module.plugins.Hook import Hook
import urllib2 
from BeautifulSoup import BeautifulSoup 
import re 

class HDareaFetcher(Hook):
    __name__ = "HDareaFetcher"
    __version__ = "0.1"
    __description__ = "Checks HD-AREA.org for new Movies. "
    __config__ = [("activated", "bool", "Activated", "False"),
                  ("interval", "int", "Check interval in minutes", "60"),
                  ("queue", "bool", "move Movies directly to Queue", "False"),
                  ("quality", "str", "720p or 1080p", "720p"),
                  ("rating","float","min. IMDB rating","6.1")]
    __author_name__ = ("Gutz-Pilz")
    __author_mail__ = ("")

    def setup(self):
        self.interval = self.getConfig("interval") * 60 
    def periodical(self):
        for site in ('Cinedubs', 'top-rls', 'movies'):
            address = ('http://hd-area.org/index.php?s=' + site)
            page = urllib2.urlopen(address).read()
            soup = BeautifulSoup(page)
            movieTit = []
            movieLink = []
            movieRating = []

            for title in soup.findAll("div", {"class" : "title"}):
                movieTit.append(title.getText())

            for span in soup.findAll('span', attrs={"style":"display:inline;"},recursive=True):
                for a in span.findAll('a'):
                    if 'ploaded' in a.getText():
                        movieLink.append(a['href'])
                    if not 'ploaded' in a.getText():
                        if 'loudzer' in a.getText():
                            movieLink.append(a['href'])

            for imdb in soup.findAll("div", {"class" : "boxrechts"}):
                for aref in imdb.findAll('a'):
                    movieRating.append(imdb.getText())

            f = open("hdarea.txt", "a")            
            if (len(movieLink) > 0) :
                for i in range(len(movieTit)):                 
                    link = movieLink[i]
                    title = movieTit[i]
                    s = open("hdarea.txt").read()    
                    if title in s:
                        self.core.log.info("HDArea: Already been added " +title[0:20])
                    else:
                        rating_txt = movieRating[i]
                        rating_float = rating_txt[5:8]
                        rating = rating_float.replace(',','.')    
                        rating = rating.replace('-/','0.')
                        list = [self.getConfig("quality")]
                        list2 = ['S0','s0','season','Season','DOKU','doku','Doku']
                        if any(word in title for word in list) and rating > self.getConfig("rating"):
                            if any (word in title for word in list2):
                                self.core.log.info("HDArea: rejected, because Series " +title[0:20])
                            else: 
                                f.write(title+"\n")                      
                                f.write(link+"\n\n")
                                self.core.api.addPackage(title.encode("utf-8"), link.split('"'), 1 if self.getConfig("queue") else 0)               
                                self.core.log.info("HDArea: New Movie found " +title[0:20]+"... with rating ("+rating+")")
                        else:
                            if rating < self.getConfig("rating"):
                                self.core.log.info("HDArea: IMDB-Rating ("+rating+") to low: " +title[0:20])
                            if not any(word in title for word in list):
                                self.core.log.info("HDArea: Quality ("+self.getConfig("quality")+") mismatch: " +title[0:20])
            f.close()
