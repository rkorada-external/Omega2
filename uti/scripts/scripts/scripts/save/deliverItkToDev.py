#! /usr/bin/env python
 
import os, sys,datetime
import uuid
import fnmatch
import re,collections,sys
import datetime
import ConfigParser

delivryEnv= os.environ.get('DELIVERY_ENV', '')

pathname = os.path.dirname(sys.argv[0])
config = ConfigParser.RawConfigParser()
print pathname +  "/deliverItkToDev.properties"
config.read(pathname +  "/deliverItkToDev.properties")


root_delivery              = config.get('properties', 'root_delivery').replace('"','')
url_itk=config.get('properties', 'url_itk').replace('"','')
csvFile=config.get('properties', 'csvFile').replace('"','')


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


fName= '/tmp/deliver_'  + username + '.txt'
header="component;Delivery revision;SPIRA;Label;Deploy;delivery date;Spot number;Repo;SPOC revision;Histo component;user;dev revision;dev date;deploy date"



def displayLogSvn():
	os.system('cat ' + fName)
	
def SVN(command):
	print "\n...... " , command
	return  os.system(command +' >' +fName + ' 2>&1') 
	#print command +' >' +fName + ' 2>&1' 



ret=SVN( 'svn up ' + csvFile )
displayLogSvn()

SVN('svn  info '	+ url_itk)
displayLogSvn()

textfile = open(fName, 'r')
filetext = textfile.read()
textfile.close()
result = re.search(r"Revision: (.*)", filetext)
revision_itk=result.group(1)	


if len(sys.argv) > 1 :
	revision_itk = sys.argv[1]
	ret=SVN('svn export -r '+ sys.argv[1] + '  ' +  url_itk + ' ' + csvFile)
	displayLogSvn()
else:
	ret=SVN('svn  export  ' +  url_itk + ' ' + csvFile)
	displayLogSvn()



inF = open(csvFile, 'r')
a = inF.readlines()
inF.close()
outF = open(csvFile, 'w')
isHedaer=True
outF.write(header+"\n")
for line in a:
	if isHedaer : isHedaer =False
	else:
		if len (line.split(";")) > 1 :
			rec=line.split(";")
			rec[cols.DEPLOY_STATUS] ="Y"
			rec[cols.SVN_REV]=rec[cols.DEV_REV]
			#rec[cols.DELIVERY_DT]=(datetime.date.today()).strftime('%Y/%m/%d %H:%M')
			dt=(datetime.datetime.today()).strftime('%Y/%m/%d %H:%M')
			for  i in range(cols.NB_COLS):
				outF.write(rec[i]+";")		
			outF.write("\n")	
outF.close()
SVN('svn commit ' + csvFile + ' -m"' + dt + ': update with  ITK revision ' + revision_itk + ' "')
displayLogSvn()

	
