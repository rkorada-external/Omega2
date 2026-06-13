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
node 		 = config.get('properties', 'node').replace('"','')
prefix_tmp 	 = config.get('properties', 'prefix_tmp').replace('"','')


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

fName= prefix_tmp  + username + '.txt'
labelList="Delivery components:\n"	
listToDelivredComponents={}
listDelivredComponents={}
header="component;Delivery revision;SPIRA;Label;Deploy;delivery date;Spot number;Repo;SPOC revision;Histo component;user;dev revision;dev date;deploy date"
nbCompenentsDelivered=0
nbCompenentsToDelivered=0
rec=[]
for  i in range(cols.NB_COLS):
	rec.append("")

	
def SVN(command):
	if ECHO == "on" :
		print "\n...... " , command
	return  os.system(command +' >' +fName + ' 2>&1') 
	#print command +' >' +fName + ' 2>&1' 
	

import time
dt=time.strftime('%Y-%m-%d-%H:%M:%S')

tmpList=prefix_tmp + "tmp.lst" 
os.system("svn ls -R " + delivery_root + " | grep -v '/$' > " + tmpList) 

fReport = open("reportDelivery2_"+dt+".csv", 'w')
fReport.write(header+"\n")


def analyseLog(component,lines):
	buf=""
	rec[cols.COMPONENT]=component
	for line in lines:
		if	line.startswith("--------------------------"):
			if rec[cols.SVN_REV] != "" :
				buf=""
				if rec[cols.DELIVERY_DT] >= '2020-07-01 00:0:0 ':
					for  i in range(cols.NB_COLS):
						buf +=rec[i]+";" 
						fReport.write(rec[i]+";")		
					fReport.write("\n")
				rec[cols.SPIRA]=""
				rec[cols.LABEL]=""
				rec[cols.SVN_REV]=""
				rec[cols.DELIVERY_DT]=""
				rec[cols.USER]=""
		else:
			read=re.search( r'r([0-9]*)\s*\|\s*([a-z,A-Z,0-9]*)\s*\|\s*(.*)\s*\+', line)
			if read :
				rec[cols.SVN_REV]=read.group(1)
				rec[cols.DELIVERY_DT]=read.group(3)
				rec[cols.USER]=read.group(2)
			else:
				read=re.search( r'.*([0-9]{5}).*',line)
				if read :
					rec[cols.SPIRA]=read.group(1)
				rec[cols.LABEL] +=" " + line.strip()
		#print rec
#cmd="svn ls -R "   + delivery_root + " | grep -v /$"
#ret=SVN(cmd)
if 0==0 :
	f = open(tmpList, 'r')
	a = f.readlines()
	f.close()
	for line in a:
		url = delivery_root+  line.strip()
		#print url
		command='svn log  ' +  url  
		ret=SVN(command)
		if ret == 0 :
			file = open(fName, 'r')
			a = file.readlines()
			if  len(a) > 1 :
				component= url.split(node)[1]
				analyseLog(component,a)		
fReport.close()
					
