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
config.read(pathname + delivryEnv + "/" + 'deliver.properties')

'''
root_delivery              = config.get('properties', 'root_delivery').replace('"','')
listComponentsFile    = config.get('properties', 'listComponentsFile').replace('"','')
branches                     = config.get('properties', 'branches').replace('"','')
listCtrComponentsFile= config.get('properties', 'listCtrComponentsFile').replace('"','')
'''
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
	REV_CSV=14
	NB_COLS=15

	
	
now = datetime.datetime.now()

uuid.uuid4()
import getpass
username = getpass.getuser()

fName= '/tmp/deliver_'  + username + '.txt'
labelList="Delivery components:\n"	
listToDelivredComponents={}
listDelivredComponents={}
header="component;Delivery revision;SPIRA;Label;Deploy;delivery date;Spot number;OTS Revision;SPOC revision;Error Type;user;dev revision;dev date;deploy date;csv revision"
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
	global nb_component_not_commited 
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
		nb_component_not_commited += 1
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
		nb_component_not_commited += 1
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
	global root_delivery, listComponentsFile,nb_component_not_commited 
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
		nb_component_not_commited += 1
	return ret 
	
nb_component_commited=0	
nb_component_not_commited=0	
	
				
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


spirasList=[]
f = open(sys.argv[1], 'r')
a = f.readlines()
for line in a:
	spirasList.append(line.strip().split(';')[0])
f.close()



compDico={}	
f = open("tmp2.dat", 'r')
a = f.readlines()
for line in a:
	row=line.strip().split(';')
	if  row[cols.COMPONENT] != "component" :
		key=row[cols.COMPONENT]+row[cols.SVN_REV]+row[cols.SPIRA]
		if row[cols.SPIRA] in spirasList:
			if key in compDico :
				if row[cols.REV_CSV] > compDico[key][cols.REV_CSV]:
					compDico[key]=row
			else:
				compDico[key]=row

f = open("tmp3.dat", 'w')
f.write(header+"\n")
for cmp in 	compDico:
	for  i in range(cols.NB_COLS):
		f.write(compDico[cmp][i]+";")		
	f.write("\n")
f.close()

