#! /usr/bin/env python
 
import os, sys,datetime
import uuid
import fnmatch
import re,collections,sys
import datetime
import ConfigParser

delivryEnv= os.environ.get('SCRUT_ENV', '')

pathname = os.path.dirname(sys.argv[0])
config = ConfigParser.RawConfigParser()
print pathname +  "/AutoDeployDEV.properties" 
config.read(pathname +  "/AutoDeployDEV.properties")

root_delivery         = config.get('properties', 'root_delivery').replace('"','')
root_dev           	  = config.get('properties', 'root_dev').replace('"','')
listComponentsFile    = config.get('properties', 'listComponentsFile').replace('"','')
branches              = config.get('properties', 'branches').replace('"','')
branches2             = config.get('properties', 'branches2').replace('"','')

status="Y"
ECHO="on"
if config.has_option('properties','status'):
	status= config.get('properties', 'status').replace('"','')
	print "status:", status

#listCtrComponentsFile= config.get('properties', 'listCtrComponentsFile').replace('"','')

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

fName= '/tmp/scrut_'  + username + '.txt'
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
	#comp1=compl.replace( branches2,"")
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

	displayLogSvn()
	f=open(fName,'r') 
	read =re.search(r'^URL: (.*)', f.read(), re.MULTILINE)
	f.close()
	ret = - 1
	if read  :
		url = read.group(1)
		print url , branches
		if url.startswith(branches) or url.startswith(branches2)  : 
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

def execQuery(query):
	#print "\n...... " , query
	return  os.system('${BCPPDIR}/bcpmulti BIDON out "query.out" -Udom_gen_ro -S'+SRV+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >  log' +  ' 2>&1' ) 
	
	print command +' >' +fName + ' 2>&1' 
	return a


def getResultSet(query):
	b=execQuery(query)
	file = open('/tmp/query.out.1', 'r')
	b = file.readlines()
	tab=[]
	for line in b:
		tab.append( line.strip().split("~"))
	file.close()
	return tab

def getChains(chain):
	return getResultSet("select  * from BEST..TI17CHN where  CHAIN_CT like '%" + chain +  "' and CHAIN_CT not in ( '*','ESGETDT0') ")

def getReqs():
	return getResultSet("select  * from BEST..TI17REQ  ")

def getFctsOfChain(chain):
	return getResultSet("select  distinct f.* from BEST..TI17REQCHN r, BEST..TI17FNC f  where f.IDF_CT = r.IDF_CT and CHAIN_CT = '" + chain +  "' ")

def getReqsOfFct(fct,chain):
	return getResultSet("select  distinct * from BEST..TI17REQCHN where IDF_CT = '" + fct +  "' and CHAIN_CT = '" + chain[0] +  "' ")

def getTI17REQJOB():
	return getResultSet("select  * from BEST..TI17REQJOB  ")

def getTI17REQJOBPLAN():
	return getResultSet("select  * from BEST..TI17REQJOBPLAN  ")

def getFcts():
	return getResultSet("select  * from BEST..TI17FNC  ")

def getReqOfFcts(fct):
	return getResultSet("select distinct  REQCOD_CT from BEST..TI17REQCHN where  IDF_CT = '"+fct+"'")

def getPermsOfFct(fct):
	return getResultSet("select  * from BEST..TI17PERMFIL  where IDF_CT = '" + fct + "' order by IO ")

def getFctsPC():
	return getResultSet("select * from BEST..TI17FNC where IDF_CT like '%I4_PC___%'")

def getPermsPC():
	return getResultSet("select * from BEST..TI17PERMFIL where idf_ct in (select IDF_CT from BEST..TI17FNC where IDF_CT like '%I4_PC___%' ) order by 1,2,4")




dicoComponentRev={}
	


def  InitEmptyRec():
        rec=[]
        for  i in range(cols.NB_COLS):
                rec.append("")
        return rec




def deliverCmp(cmp ) :
	global nb_component_commited
	ret = SVN('svn info ' + cmp)
	f = open(fName, 'r')
	if ret == 0 :
		read =re.search(r'^URL: (.*)', f.read(), re.MULTILINE)
		f.close()
		if read  :
				url = read.group(1)
				#print "url:" , url
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
							component= url.split("global/")[1]
							print "  component:", component
							print "  revision dev:", revision_dev
							print "  user:",user
							print "  label:",label
							print "  date:",dt
							print "  Spira:", spira
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
							listToDelivredComponents[component] = rec
							nb_component_commited += 1
                 #ret=SVN( 'svn up ' + root_delivery + component)
	return ret

#for cmp  in dicoComponentRev:
#	SVN ("svn -u " + cmp) 
#	getCmp(cmp ) 		


def deliverComponents(componentsList):				
	f= open(componentsList, 'r')
	a = f.readlines()
	for line in a:
		if not line.strip().startswith("#")  and line.strip() != "": 	
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
			for  i in range(len(listComponents[component])):
				buf +=listComponents[component][i]+";" 
				f.write(listComponents[component][i]+";")		
			f.write("\n")
			#print buf
		#print "\n"
		f.close()
		ret=SVN( 'svn commit ' + listComponentsFile + ' -m "' + labelList + '"')
		ret=SVN( 'svn st ' + listComponentsFile )
		displayLogSvn()

#setEnvironnement(sys.argv[1])
#quit()

def deliverCmps():
	ret=0
	SVN ("svn status -u /scor/scoromega/delivery/3I_DEV/*") 
	f= open(fName, "r")
	a = f.readlines()
	for line in a :
		#print "line:",line
		tab=line.split(" ")
		#print "tab:", tab
		#if len(tab) > 14 and  tab[8] == "*"  and tab[11] != ""  and os.path.isfile(tab[14].strip()) :
		cmp=line[21:].strip()
		#print cmp, os.path.isfile(cmp)
		if len(tab) > 14 and  tab[8] == "*"  and  not os.path.isdir(cmp) :
			#print "list:" ,tab[14]
			dicoComponentRev[cmp]= tab[11]
		
	#print dicoComponentRev
	for cmp  in dicoComponentRev:
		#SVN ("svn -u " + cmp) 
		dir=os.path.dirname(cmp)
		bn=os.path.basename(cmp)
		SVN("svn info " + dir) 
		f = open(fName, 'r')
		url=""
		read =re.search(r'^URL: (.*)', f.read(), re.MULTILINE)
		if read :
			url = read.group(1)
			SVN("svn up " + url + "/" + bn + " " + dir )
			ret = deliverCmp(cmp ) 	
			if ret != 0 : break ;
	return ret	
	
listComponentsAfterRevision={}
def getCmpAfterRevision(root, revision ):
	SVN("svn   status -u -v " + root ) 
	f= open(fName, "r")
	a = f.readlines()
	for line in a :
		#print "line:",line
		tab=line.split()
		if ( tab[1] >= revision and tab[0] != "Status") :
			listComponentsAfterRevision[tab[3]]= tab
	return listComponentsAfterRevision


	
def createCsvFile(root,revision,status,csvFile):
	global ECHO
	cmpsList=getCmpAfterRevision(root_dev,revision )
	ECHO="off"
	print "-------------------------"
	
	for cmp  in cmpsList:
		command='svn log  ' +  cmp + ' --limit 1 '
		ret=SVN(command)
		if ret == 0 :
			file = open(fName, 'r')
			a = file.readlines()
			if  len(a) > 1 :
				read=re.search( r'r([0-9]*)\s*\|\s*([a-z,A-Z,0-9]*)\s*\|\s*(.*)\s*\+', a[1].strip())
				if read :
					revision_dev=read.group(1)
				#	user=read.group(2)
				#	dt=read.group(3)
				#	#label=label1="SPIRA: "+spira+ " " +  a[3].strip()
				#	label =a[3].strip()
				#	spira=""
				#	if (len(label.split(" ") )> 0 ) : spira=label.split(" ")[0]
				#	i=4
				#	while not a[i].startswith("--------------------------"):
				#		label +="\n" + a[i].strip()
				#		i +=1
				#	component= url.split("global/")[1]
				read=re.search( r'[^0-9]+([0-9]{5,6})[^0-9]+', a[3].strip())
				spira=read.group(1)
		print cmpsList[cmp][3]+";"+spira+";"+revision_dev
	ECHO="on"
try:
	lastListComponents=getLastListComponents()
	ret = deliverCmps()
	#print "ret:" , str(ret )
	if ret == 0 :
		#print lastListComponents
		#print listToDelivredComponents
		listComponents=mergeDelivredComponentsToLastList(lastListComponents)
		#print listComponents
		commitListOfComponents(listComponents)
		displayLogSvn()
	#getCmpAfterRevision("/scor/scoromega/delivery/3I_DEV",revision )
	
finally:
	#print  "\n Info: return: " + str(ret ) 
	print  "\n Info: " + str(nbCompenentsToDelivered)  + " component(s)  to delivered "
	print  "\n Info: " + str(nbCompenentsDelivered)  + " component(s) delivered "
	print  "\n Info: " + str(nb_component_commited)  + " component(s) committed "
	print  "\n Info: " + str(nb_component_not_commited)  + " component(s) not committed "
	#createCsvFile("/scor/scoromega/delivery/3I_DEV","456200","Y","toto")
	
