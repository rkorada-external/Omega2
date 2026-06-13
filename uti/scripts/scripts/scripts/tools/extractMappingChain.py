#! /usr/bin/env python
 
import os, sys,datetime
import uuid
import fnmatch
import re,collections,sys
import datetime
import ConfigParser
import pprint

#delivryEnv= os.environ.get('DELIVERY_ENV', '')
#
#pathname = os.path.dirname(sys.argv[0])
#config = ConfigParser.RawConfigParser()
#print pathname +  "/" + 'deliver'+delivryEnv +'.properties' 
#config.read(pathname +  "/" + 'deliver'+delivryEnv +'.properties')
#
#
#root_delivery              = config.get('properties', 'root_delivery').replace('"','')
#listComponentsFile    = config.get('properties', 'listComponentsFile').replace('"','')
#branches                     = config.get('properties', 'branches').replace('"','')
#branches2                     = config.get('properties', 'branches2').replace('"','')
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

fName= '/tmp/deliver_'  + username + '.txt'
labelList="Delivery components:\n"	
listToDelivredComponents={}
listDelivredComponents={}
header="component;Delivery revision;SPIRA;Label;Deploy;delivery date;Spot number;Repo;SPOC revision;Histo component;user;dev revision;dev date;deploy date"
nbCompenentsDelivered=0
nbCompenentsToDelivered=0
ENV=""
SRV=sys.argv[1]
if SRV == "ITK" : SRV="CN2"

#print "len(sys.argv) :" , len(sys.argv)
TI17PERMFIL="TI17PERMFIL"
if len(sys.argv) == 4 :
	TI17PERMFIL="TI17TRAPERMFIL"

 
def execQuery(query):
	#print "\n...... " , query
	return  os.system('${BCPPDIR}/bcpmulti BIDON out "query.out" -Udom_gen_ro -S'+SRV+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >  log' +  ' 2>&1' ) 
	
	print command +' >' +fName + ' 2>&1' 
	return a


def getResultSet(query):
	#print "query: " , query
	b=execQuery(query)
	file = open('/tmp/query.out.1', 'r')
	b = file.readlines()
	tab=[]
	for line in b:
		tab.append( line.strip().split("~"))
	file.close()
	#print tab 
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
	return getResultSet("select  * from BEST.."+TI17PERMFIL+"  where IDF_CT = '" + fct + "' order by IO ")

def getFctsPC():
	return getResultSet("select * from BEST..TI17FNC where IDF_CT like '%I4_PC___%'")

def getPermsPC():
	return getResultSet("select * from BEST.."+TI17PERMFIL+" where idf_ct in (select IDF_CT from BEST..TI17FNC where IDF_CT like '%I4_PC___%' ) order by 1,2,4")





	
dicoChainsFctPerms={}
dicoChainsFctReqs={}
dicoChains={}
dicoReqs={}
dicoFcts={}
dicoTI17REQJOB={} 
dicoTI17REQJOBPLAN={}
chains= getChains(sys.argv[2])
#print chains 
if len(chains) == 0 :
	chains.append([sys.argv[2],""])
TI17REQJOB=getTI17REQJOB()
TI17REQJOBPLAN=getTI17REQJOBPLAN()

dicoFctPC=getFctsPC()
dicoPermsPC=getPermsPC()

reqs=getReqs()
fcts=getFcts()
#print (chains)

for chain in chains:
	dicoChains[chain[0]] =chain 
	dicoFctsPerms={}
	dicoFctsReqs={}
	fcts0= getFctsOfChain(chain[0])
	#print "fcts0:" ,chain[0], fcts0
	if len( fcts0) > 0  :
		for fct in fcts0:
			reqs0= getReqsOfFct(fct[0],chain)
			dicoFctsReqs[fct[0]]=reqs0
			perms= getPermsOfFct(fct[0])
			dicoFctsPerms[fct[0]]=perms
			#print "perms1: " , perms
	else:
		reqs0= getReqsOfFct(chain[0],chain)
		dicoFctsReqs[chain[0]]=reqs0
		perms= getPermsOfFct(chain[0])
		dicoFctsPerms[chain[0]]=perms
		#print "perms2: " , perms
	if chain[0] == 'ESPD2050' :  
		reqs0= getReqsOfFct(chain[0],chain)
		dicoFctsReqs[chain[0]]=reqs0
		perms= getPermsOfFct(chain[0])
		dicoFctsPerms[chain[0]]=perms
		#print "perms3: " , perms

	dicoChainsFctPerms[chain[0]]=dicoFctsPerms
	dicoChainsFctReqs[chain[0]]=dicoFctsReqs
for req in reqs:
	dicoReqs[req[0]]=req
for fct in fcts:
	dicoFcts[fct[0]]=fct

for req in TI17REQJOB:
	dicoTI17REQJOB[req[0]]=req

for req in TI17REQJOBPLAN:
	dicoTI17REQJOBPLAN[req[0]]=req
#print dicoFcts
#print dicoChainsFctPerms ['ESFD3780']
def updateChain (chain)	:
	
	print ""
	print "-------------------------------" 
	print "--	Init ", chain
	print "-------------------------------"
	print ""
	
	#print("insert into BEST..TI17CHN" + ENV + " ('%s','%s')"%(dicoChains[chain][0],dicoChains[chain][1]))
	
	print ( "	select IDF_CT into #TIDF_CT from BEST..TI17REQCHN where   CHAIN_CT='%s'" % (chain) )
	print ( "	delete BEST.."+TI17PERMFIL+ ENV + " where IDF_CT in  ( select IDF_CT from #TIDF_CT )")
	print ( "	delete BEST..TI17REQCHN" + ENV + " where   IDF_CT in ( select IDF_CT from #TIDF_CT ) and  CHAIN_CT='%s'" % (chain) )
	print ( "	delete BEST..TI17CHN" + ENV + "  where CHAIN_CT='%s'" % (chain) )
	print ( "	delete BEST..TI17FNC" + ENV + " where IDF_CT  in  ( select IDF_CT from #TIDF_CT )"  )
	print ( "	DROP TABLE #TIDF_CT" )
	
	print ( "\n	insert into BEST..TI17CHN" + ENV + " values ('%s',  '%s')" % (chain,dicoChains[chain][1]) )

	for fct in dicoChainsFctPerms[chain]:
		#if fct in ["POSE","POCE","POSI","POCI"] : 
		#	newFct = chain + "_" + fct
		#else:
		#	newFct = fct
		
		newFct = fct
		
		print "\n		-- " , newFct  , fct, "\n"
		if fct in dicoFcts:
			print ( "	insert into BEST..TI17FNC" + ENV + " values ('%s',  '%s')" % (newFct,dicoFcts[fct][1]) )
		
		print "\n	----------  Perms---------------------\n"
		for perm in dicoChainsFctPerms[chain][fct]:
			print ( "		insert into BEST.."+TI17PERMFIL+ ENV + " values ('%s',  '%s','%s','%s','%s')" % (newFct,perm[1],perm[2],perm[3],perm[4]))
		print "\n	----------   Reqs of chain   ---------------------\n"
		if ( len(dicoChainsFctReqs[chain][fct]) == 0 ):
			print ( "		insert into BEST..TI17REQCHN" + ENV + " values ('ALL',  '%s','%s','')"  % (chain,newFct ) )
		else:
			for req in dicoChainsFctReqs[chain][fct]:
				print ( "		insert into BEST..TI17REQCHN" + ENV + " values ('%s',  '%s','%s','%s')" % (req[0],req[1],newFct,req[3]))

	print "\ngo\n" 
	
def updatePC ()	:
	
	print ""
	print "-------------------------------"
	print "--	Init  P&C (SPLIT)"
	print "-------------------------------"
	print ""
	
	#print("insert into BEST..TI17CHN" + ENV + " ('%s','%s')"%(dicoChains[chain][0],dicoChains[chain][1]))
	print ( "	delete BEST.."+TI17PERMFIL+ ENV + " where IDF_CT like '%I4_PC___%'")
	print ( "	delete BEST..TI17FNC" + ENV + " where IDF_CT like '%I4_PC___%'" )

	
	print "\n		-- IDF_CT P&C ------------------\n"
	for fct in dicoFctPC:
		print ( "	insert into BEST..TI17FNC" + ENV + " values ('%s',  '%s')" % (fct[0],fct[1]) )
	 
	print "\n	----------  Perms P&C---------------------\n"
	for perm in dicoPermsPC:
		print ( "		insert into BEST.."+TI17PERMFIL+ ENV + " values ('%s',  '%s','%s','%s','%s')" % (perm[0],perm[1],perm[2],perm[3],perm[4]))
	
	print "\ngo\n" 


for chain in chains :
	updateChain ( chain[0])

#updateChain ( sys.argv[2])
 
