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
config.read(pathname + delivryEnv + "/" + 'deliver_gui.properties')


root_delivery              = config.get('properties', 'root_delivery').replace('"','')
listComponentsFile    = config.get('properties', 'listComponentsFile').replace('"','')
branches                     = config.get('properties', 'branches').replace('"','')
listCtrComponentsFile= config.get('properties', 'listCtrComponentsFile').replace('"','')

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
labelList="Delivery components:\n"	
listToDelivredComponents={}
listDelivredComponents={}
header="component;Delivery revision;SPIRA;Label;Deploy;delivery date;Spot number;OTS Revision;SPOC revision;Error Type;user;dev revision;dev date;deploy date"
nbCompenentsDelivered=0
nbCompenentsToDelivered=0
def  InitEmptyRec():
	rec=[]
	for  i in range(cols.NB_COLS):
		rec.append("")
	return rec 

	
def SVN(command):
	print "\n...... " , command
	return  os.system(command +' >' +fName + ' 2>&1') 
	#print command +' >' +fName + ' 2>&1' 
	
def getSvnLogSVN():
	file = open(fName, 'r')
	a = file.readlines()
	file.close()
	return a
def displayLogSvn():
	os.system('cat ' + fName)

def IsListDeliveryLocked():
	SVN("svn info " + listComponentsFile) 
	text = open(fName,mode='r').read()
	result = re.search('Lock Owner: (.*)',text,re.MULTILINE)
	print text
	user=""
	if  result :	user=result.group(1)
	print "user:",  user
	if user != username and user != "":
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		print  "#"
		print  "#         ERROR: list of components " + listCtrComponentsFile + " is locked, please retry later"
		print  "#"
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		sys.exit(1)

def IsManySpiraOfComponentExist(comp0,spira0):
	SVN("svn info " + comp0) 
	f = open(fName, 'r')
	url=""
	read =re.search(r'^URL: (.*)', f.read(), re.MULTILINE)
	if read :
		url = read.group(1)
	else:
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		print  "#"
		print  "#         ERROR: the component  " + comp0 + " is not in SVN workspace"
		print  "#"
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		return -1
		#sys.exit(1)
	comp1=url.replace( branches,"")
	#print "comp1=",  comp1	
	
	ret = False
	f = open(listCtrComponentsFile, 'r')
	a = f.readlines()
	spiraList=[]
	val =""
	for line in a:
		cmt=""
		if len (line.split(";")) > 1 :
			comp=line.split(";")[0]
			spira =line.split(";")[1].strip()
			if len (line.split(";")) > 2 :
				cmt = line.split(";")[2].strip()
			if  comp == comp1  :
				spiraList.append([spira,cmt])
				if spira == spira0 :
					val= spira
					ret = True
	ret =True		
	''''
	if val == ""    :
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		print  "#"
		print  "#         ERROR: the "+ comp0+" component does not exist for the spira " + spira0
		print  "#"
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	'''		
	if len (spiraList ) >  1  and val != "" :
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		print  "#"
		print  "#         Important: the "+ comp0+" component impacts other spira:"
		for sp in  spiraList:
			print  "#         		" + sp[0] , sp[1]
		print  "#"
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		
	
	return ret
	
	
def setEnvironnement(cmp):
	global root_delivery, listComponentsFile
	SVN("svn info " + cmp) 
	contents = open(fName,mode='r').readlines()

	f=open(fName,'r') 
	read =re.search(r'^URL: (.*)', f.read(), re.MULTILINE)
	f.close()
	ret = - 1
	if read  :
		url = read.group(1)
		print url , branches
		if url.startswith(branches) : 
			ret = 0

	if ret == -1 :
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		print  "#"
		print  "#         ERROR: " + cmp+"  component not found  in SVN " 
		print  "#"
		print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	return ret 
	
	
def deliverComponent(cmp, spira, revision_dev = '0' ):
	global nbCompenentsDelivered
	global nbCompenentsToDelivered
	print "\n=======================--- deliver " , cmp , spira, revision_dev , " ---============================#\n"

	nbCompenentsToDelivered  +=1
	if setEnvironnement(cmp) == -1 : return -1
	
	if not IsManySpiraOfComponentExist(cmp,spira) : return -1
	
	ret = SVN('svn info ' + cmp) 
	f = open(fName, 'r')
	if ret == 0 :
		read =re.search(r'^URL: (.*)', f.read(), re.MULTILINE)
		f.close()
		if read  :
			url = read.group(1)
			#print "url:" , url
			if revision_dev == '0' :
				command='svn log  ' +  url + ' --limit 1 '
			else:
				command='svn log  -r ' +  revision_dev +  ' ' 
				command += url 
			ret=SVN(command)
			if ret == 0 :
				file = open(fName, 'r')
				a = file.readlines()
				if  len(a) > 1 :  
					read=re.search( r'r([0-9]*)\s*\|\s*([a-z,A-Z,0-9]*)\s*\|\s*(.*)\s*\+', a[1].strip())
					if read :
						revision_delivery=read.group(1) 
						user=read.group(2) 
						dt=read.group(3)
						label=label1="SPIRA: "+spira+ " " +  a[3].strip()
						i=4
						while not a[i].startswith("--------------------------"):
							label +="\n" + a[i].strip()
							i +=1
						component= url.split("global/")[1]
						print "  component:", component
						print "  revision delivery:", revision_delivery
						print "  user:",user
						print "  label:",label
						print "  date:",dt
						revision_delivery=read.group(1)
						displayLogSvn()
						rec=InitEmptyRec()
						rec[cols.COMPONENT]=component
						rec[cols.LABEL]=label1
						rec[cols.SPIRA]=spira
						rec[cols.DEPLOY_STATUS]="Y"
						rec[cols.SVN_REV]=revision_delivery
						today = datetime.date.today() 
						rec[cols.DELIVERY_DT]=today.strftime('%Y/%m/%d %H:%M')
						rec[cols.USER]=user
						rec[cols.DEV_REV]=""
						rec[cols.DEV_DT]=dt
						listToDelivredComponents[component] = rec
				else :
					print  " revision not found"
		else: 
			displayLogSvn()
	if ret != 0 : displayLogSvn()
	
	return ret
	

				
def deliverComponents(componentsList):				
	f= open(componentsList, 'r')
	a = f.readlines()
	for line in a:	
		component=line.strip().split(";")[0]
		spira=line.strip().split(";")[1]
		if len(line.strip().split(";")) > 2 :
			revision=line.strip().split(";")[2]
		else :
			revision ='0'
		deliverComponent ( component,spira,revision )
	f.close()
	return 


def getLastListComponents():
	global header 
	ret=SVN( 'svn up ' + listComponentsFile)
	f = open(listComponentsFile, 'r')
	a = f.readlines()
	firstLine=False
	lastListComponents={}
	for line in a:	
		if not firstLine:
			#header=line
			firstLine = True
		else:
			component=line.strip().split(';')[0]
			lastListComponents[component]=line.strip().split(';')
			#print line
	f.close()
	return  lastListComponents

def mergeDelivredComponentsToLastList(listComponents):
	print "\n info: merge Delivred Components To LastList  --------------------- \n"
	global labelList
	global listToDelivredComponents
	global listDelivredComponents
	global nbCompenentsDelivered
	
	for component in listToDelivredComponents :
		if component in listComponents :
			if  listComponents[component] [cols.SVN_REV]  !=  listToDelivredComponents[component] [cols.SVN_REV			]:
				nbCompenentsDelivered +=1
				listComponents[component] [cols.SPIRA 				]=listToDelivredComponents[component] [cols.SPIRA 				]
				listComponents[component] [cols.LABEL 				]=listToDelivredComponents[component] [cols.LABEL 				]
				listComponents[component] [cols.DEPLOY_STATUS]=listToDelivredComponents[component] [cols.DEPLOY_STATUS]
				listComponents[component] [cols.SVN_REV			]=listToDelivredComponents[component] [cols.SVN_REV			]
				listComponents[component] [cols.DELIVERY_DT	]=listToDelivredComponents[component] [cols.DELIVERY_DT		]
				listComponents[component] [cols.USER				]=listToDelivredComponents[component] [cols.USER					]
				listComponents[component] [cols.DEV_REV			]=listToDelivredComponents[component] [cols.DEV_REV			]
				listComponents[component] [cols.DEV_DT			]=listToDelivredComponents[component] [cols.DEV_DT			]
				listDelivredComponents[component]=listToDelivredComponents[component] 
				labelList +="	- " + component + "\n"
		else:
			nbCompenentsDelivered +=1
			listComponents[component] =listToDelivredComponents[component] 
			listDelivredComponents[component]=listToDelivredComponents[component] 
			labelList +="	- " + component + "\n"
	return listComponents
			
def commitListOfComponents(listComponents):
	#print "\n info: commit List Of Components  --------------------- \n"
	global labelList, header
	global  nbCompenentsDelivered
	global listDelivredComponents
	if  len (listDelivredComponents) > 0 :
		ret=SVN( 'svn up ' + listComponentsFile )
		f = open(listComponentsFile, 'w')
		a = f.write(header)
		f.write("\n")
		#print  header.strip()
		for component in sorted(listComponents.iterkeys()):	
			#print listComponents
			#print nb_cols
			buf=""
			for  i in range(cols.NB_COLS):
				buf +=listComponents[component][i]+";" 
				f.write(listComponents[component][i]+";")		
			f.write("\n")
			#print buf
		#print "\n"
		f.close()
		ret=SVN( 'svn commit ' + listComponentsFile + ' -m "' + labelList + '"')

#setEnvironnement(sys.argv[1])
#quit()
	
try:
	#IsListDeliveryLocked()
	SVN("svn lock " + listComponentsFile) 
	
	print "\n########################################\n # delivery of user :" + username + "\n#  date:"  + now.isoformat() +   "\n########################################\n  "
	ret = 0 
	if len(sys.argv) > 3 :
		ret = deliverComponent ( sys.argv[1],sys.argv[2] ,sys.argv[3])    
	else:
		if os.path.splitext(sys.argv[1])[1] == '.lst':
			deliverComponents(sys.argv[1])
		else :
			print  sys.argv
			if len(sys.argv) <= 2:
				print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
				print  "#"
				print  "#         ERROR: Spira number  is mandatory ; cmd mus be like :" 
				print  "#            deliver.sh spiraNumber [revisonOfComponent] "
				print  "#"
				print  "#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
				ret = - 1 
			else:
				ret = deliverComponent ( sys.argv[1],sys.argv[2])
			
	if ret == 0 :
		lastListComponents=getLastListComponents()	
		#print  "getLastListComponents:", lastListComponents
		#print  "listToDelivredComponents:", listToDelivredComponents
		listComponents=mergeDelivredComponentsToLastList(lastListComponents)
		#print  "out mergeDelivredComponentsToLastList:" ,listComponents
		#print  "lastListComponents :", lastListComponents
		commitListOfComponents(listComponents)
		displayLogSvn()
	
finally:
	SVN("svn unlock " + listComponentsFile) 
	print  "\n Info: return: " + str(ret ) 
	print  "\n Info: " + str(nbCompenentsToDelivered)  + " component(s)  to delivered "
	print  "\n Info: " + str(nbCompenentsDelivered)  + " component(s) delivered "
		
