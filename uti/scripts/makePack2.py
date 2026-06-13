#! /usr/bin/env python
 
import os, sys,datetime
import uuid
import fnmatch
import re,collections,sys,glob
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


def getLastListComponents(listComponentsFile):
	global header 
	#ret=SVN( 'svn up ' + listComponentsFile)
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


def getComponetsUAT ( ):
	SVN("svn up /scor/scoromega/delivery/3G_DELIVERY/OM2.DELIVERY/CSV_delivred")
	compUatDico={}	
	csvs = glob.glob('/scor/scoromega/delivery/3G_DELIVERY/OM2.DELIVERY/CSV_delivred/*.csv')
	#csvs.sort(key=os.path.getmtime)
	csvs.sort()
	for csv in csvs :
		if '-NO.csv' not in csv: 
			print " fusion : " , csv
			listComponents= getLastListComponents(csv)
			#print listComponents
			for comp in listComponents:
				if  listComponents[comp][cols.COMPONENT] != "component" :
					compUatDico[comp] = listComponents[comp]
	#print "\nUAT merge: "
	#for key in compUatDico :
	#	print compUatDico[key]

	return compUatDico
		

def getComponentsITK():
	f = open("tmp2.dat", 'r')
	a = f.readlines()
	compItkDico={}	
	for line in a:
		row=line.strip().split(';')
		if  row[cols.COMPONENT] != "component" :
			if row[cols.COMPONENT] in compItkDico :
				if row[cols.REV_CSV] > compItkDico[row[cols.COMPONENT]][cols.REV_CSV]:
					compItkDico[row[cols.COMPONENT] ]=row
			else:
				compItkDico[row[cols.COMPONENT] ]=row
	return compItkDico 

def getComponentsSpiras():
	spirasList=[]
	f = open(sys.argv[1], 'r')
	a = f.readlines()
	for line in a:
		spirasList.append(line.strip().split(';')[0])
	f.close()
	f = open("tmp2.dat", 'r')
	a = f.readlines()
	compSpirasDico={}	
	for line in a:
		row=line.strip().split(';')
		if  row[cols.COMPONENT] != "component" :
			key=(row[cols.COMPONENT],row[cols.SPIRA])
			if row[cols.SPIRA] in spirasList:
				if key in compSpirasDico :
					if row[cols.REV_CSV] > compSpirasDico[key][cols.REV_CSV]:
						compSpirasDico[key]=row
				else:
					compSpirasDico[key]=row
	f.close()
	return compSpirasDico
	
def makePack():
	compUatDico = getComponetsUAT()  #  merge des csv UAT
	compItkDico = getComponentsITK()  #  liste des dernires revision des composant itk livres
	compSpirasDico= getComponentsSpiras()  # liste des couples [composant,spira] demandees
	compSpirasDicoAdd={}
	for compSpira in compSpirasDico:  # couple (comp,Spira) a livrer
		comp = 	compSpira[0]
		spira=	compSpira[1]
		moreRecentRev=""
		forSpira=""
		inUat="Non"
		
		# control par rapoort aux composantx de de la liste ITK
		if comp in compItkDico:    # si le comosant exist dans la liste Itk
			spiraItk = compItkDico[comp][cols.SPIRA]    # on recupere sa spira
			if spiraItk != compSpirasDico[compSpira][cols.SPIRA]: # on teste si les spiras itk et spira demande sont differents 
				if (comp,spiraItk) in compSpirasDico : #si la spira itk est aussi demandee
					if compSpirasDico[compSpira][cols.SVN_REV] <compSpirasDico[(comp,spiraItk)] : # si la revision de la spira demandee est < alors on  renseigne les nouvelle colonnes
						moreRecentRev="OUI"
						forSpira=spiraItk
				else: 
					if (comp,spiraUat) in compSpirasDicoAdd :
						if compSpirasDico[compSpira][cols.SVN_REV] <compSpirasDicoAdd[(comp,spiraItk)] :
							moreRecentRev="OUI"
							forSpira=spiraItk
						else: #si la spira itk n'est pas demandee et n'a pas ete rajoutee on la rajoute a la liste 
							compSpirasDicoAdd[(comp,spiraItk)] = compItkDico[comp]+[moreRecentRev,forSpira,inUat]

		# control par rapoort aux composantx de de la liste ITK			
		if comp in compUatDico: # si le comosant exist dans la liste Itk
			spiraUat = compUatDico[comp][cols.SPIRA] 
			if spiraUat != compSpirasDico[compSpira][cols.SPIRA]: # si spira UAT est differt de Spira demandee
				if (comp,spiraUat) in compSpirasDico : # si la spira UAt est aussi demandee
					if compSpirasDico[compSpira][cols.SVN_REV] <compSpirasDico[(comp,spiraItk)] : #si sar rivision est > , on m.a.j 
						moreRecentRev="OUI"
						forSpira=spiraItk
					else: # si la spira UAt n'a pas ete demandee
						if (comp,spiraUat) in compSpirasDicoAdd : # si la spira UAt n'a pas ete demandee mais rajoute 
							if compSpirasDico[compSpira][cols.SVN_REV] <compSpirasDicoAdd[(comp,spiraItk)] :
								moreRecentRev="OUI"
								forSpira=spiraItk
								inUat=Oui
							else: #si la spira UAT n'est pas demandee et n'a pas ete rajoutee on la rajoute a la liste 
								compSpirasDicoAdd[(comp,spiraItk)] = compItkDico[comp]+[moreRecentRev,forSpira,inUat]


		f = open("tmp3.dat", 'w')
		f.write(header+"moreRecentRev;moreRecentRev;inUat\n")							
		for  cmpSpira in compSpirasDico:
			for  field in compSpirasDico[cmpSpira]:
				f.write(field+";")		
			f.write("\n")

		for  cmpSpira in compSpirasDicoAdd:
			for  field in compSpirasDicoAdd[cmpSpira]:
				f.write(field+";")		
			f.write("\n")


makePack()	
#fusionUATCsv()

