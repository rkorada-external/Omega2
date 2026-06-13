#! /usr/bin/env python
 
import os, sys,datetime
import uuid
import fnmatch
import re,collections,sys
import datetime
import ConfigParser

 


pathname = os.path.dirname(sys.argv[0])
config = ConfigParser.RawConfigParser()

config.read(pathname+ "/"+ sys.argv[0].replace(".py",".properties"))

delivery_root= config.get('properties', 'delivery_root').replace('"','')
ECHO         = config.get('properties', 'ECHO').replace('"','')
status       = config.get('properties', 'status').replace('"','')



class cols(object):
	COMPONENT=0
	SVN_REV=1
	SPIRA=2
	LABEL=3
	DEPLOY_STATUS=4
	DELIVERY_DT=5
	SPOT_NBR=6
	OTS_REV=7
	SPOC_REV=8
	ERRROR=9
	USER=10
	DEV_REV=11
	DEV_DT=12
	DEPLOY_DATE=13
	NB_COLS=14

now = datetime.datetime.now()

uuid.uuid4()
import getpass
username = getpass.getuser()

fName= '/tmp/TraceDELIVERY_'  + username + '.txt'
labelList="Delivery components:\n"	
listToDelivredComponents={}
listDelivredComponents={}
header="component;Delivery revision;SPIRA;Label;Deploy;delivery date;Spot number;Repo;SPOC revision;Histo component;user;dev revision;dev date;deploy date"
nbCompenentsDelivered=0
nbCompenentsToDelivered=0
def  InitEmptyRec():
	rec=[]
	for  i in range(cols.NB_COLS):
		rec.append("")
	return rec 

	
def SVN(command):
	if ECHO == "on" :
		print "\n...... " , command
	return  os.system(command +' >' +fName + ' 2>&1') 
	#print command +' >' +fName + ' 2>&1' 
	

import time
dt=time.strftime('%Y-%m-%d-%H:%M:%S')

fReport = open("reportDelivery_"+dt+".csv", 'w')
fReport.write(header+"\n")
#cmd="svn ls -R "   + delivery_root + " | grep -v /$"
#ret=SVN(cmd)
if 0==0 :
	f = open("deliveryCmps.lst", 'r')
	a = f.readlines()
	f.close()
	for line in a:
		url = delivery_root+  line.strip()
		#print url
		command='svn log  ' +  url + ' --limit 1 '
		ret=SVN(command)
		if ret == 0 :
			file = open(fName, 'r')
			a = file.readlines()
			if  len(a) > 1 :
				read=re.search( r'r([0-9]*)\s*\|\s*([a-z,A-Z,0-9]*)\s*\|\s*(.*)\s*\+', a[1].strip())
				if read :
					revision_dev=read.group(1)
					user=read.group(2)
					dt=read.group(3)
					#label=label1="SPIRA: "+spira+ " " +  a[3].strip()
					label =a[3].strip()
					spira=""
					read=re.search( r'.*([0-9]{5}).*',label)
					if read :
						spira=read.group(1)
					i=4
					while not a[i].startswith("--------------------------"):
						label +="\n" + a[i].strip()
						i +=1
					component= url.split("3I_DELIVERY/")[1]
					#print "  component:", component
					#print "  revision dev:", revision_dev
					#print "  user:",user
					#print "  label:",label
					#print "  date:",dt
					#print "  Spira:", spira
					rec=InitEmptyRec()
					rec[cols.COMPONENT]=component
					rec[cols.LABEL]=label
					rec[cols.SPIRA]=spira
					rec[cols.DEPLOY_STATUS]=status
					rec[cols.SVN_REV]="" #revision_delivery
					today = datetime.datetime.today() 
					rec[cols.DELIVERY_DT]=today.strftime('%Y/%m/%d %H:%M')
					rec[cols.USER]=user
					rec[cols.DEV_REV]=revision_dev
					rec[cols.DEV_DT]=dt
					buf=""
					for  i in range(cols.NB_COLS):
						buf +=rec[i]+";" 
						fReport.write(rec[i]+";")		
					fReport.write("\n")
					#print rec
		
fReport.close()
					
