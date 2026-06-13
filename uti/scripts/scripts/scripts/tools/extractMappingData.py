#! /usr/bin/python3
 
import os, sys,datetime
import uuid
import fnmatch
import re,collections,sys
import datetime
from pprint import pprint 

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

def execQuery(query):
	#print ("\n...... " , query)
	cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Udom_gen_ro -S'+SRV.upper()+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log'  
	#print (cmd)
	return  os.system(cmd ) 
	


def getResultSet(query):
	b=execQuery(query)
	file = open('/tmp/query.out.1', 'r', encoding='cp1252')
	b = file.readlines()
	tab=[]
	for line in b:
		tab.append( line.strip().split("~"))
	file.close()
	return tab

def getChains(chain):
	return getResultSet("""select  * from BEST..TI17CHN 
	where  CHAIN_CT like '{chain}'
	and CHAIN_CT not in ( '*','ESGETDT0') """.format(chain=chain))

def getReqs():
	return getResultSet("select  * from BEST..TI17REQ  ")

def getFctsOfChain(chain):
	return getResultSet("select  IDF_CT  from BEST..TI17FNC   where   CHAIN_CT='{chain}'".format(chain=chain))

def getFcts():
	return getResultSet("select  * from  BEST..TI17FNC f ")

def getReqsOfFct(fct):
	return getResultSet("select  * from BEST..TI17REQFNC where IDF_CT = '{fct}'".format(fct=fct))

def getPermsOfFct(fct):
	return getResultSet("select  * from BEST..TI17PERMFIL  where IDF_CT = '{fct}'  order by IO ".format(fct=fct))



dicoChainsFctPerms={}
dicoChainsFctReqs={}
dicoChains={}
dicoReqs={}
dicoFcts={}
chains= {}
reqs={}
fcts={}

	
#pprint (chains)

def Init():
	global 	dicoChainsFctPerms, dicoChainsFctReqs ,dicoChains,dicoReqs,dicoFcts,chains

	chains= getChains("%")
	reqs=getReqs()
	fcts=getFcts()



	for chain in chains:
		dicoChains[chain[0]] =chain 
		dicoFctsPerms={}
		dicoFctsReqs={}
		fcts0= getFctsOfChain(chain[0])
		#print("fcts0:",fcts0)
		if len( fcts0) > 0  :
			for fct in fcts0:
				reqs0= getReqsOfFct(fct[0])
				dicoFctsReqs[fct[0]]=reqs0
				perms= getPermsOfFct(fct[0])
				dicoFctsPerms[fct[0]]=perms
				#print("reqs0:",reqs0)
		#else:
		#	reqs0= getReqsOfFct(chain)
		#	dicoFctsReqs[chain[0]]=reqs0
		#	perms= getPermsOfFct(chain[0])
		#	dicoFctsPerms[chain[0]]=perms
		#if chain[0] == 'ESPD2050' :  
		#	reqs0= getReqsOfFct(chain)
		#	dicoFctsReqs[chain[0]]=reqs0
		#	perms= getPermsOfFct(chain[0])
		#	dicoFctsPerms[chain[0]]=perms

		
		dicoChainsFctPerms[chain[0]]=dicoFctsPerms
		dicoChainsFctReqs[chain[0]]=dicoFctsReqs
		#print("dicoChainsFctReqs:")
		#pprint(dicoChainsFctReqs)
		#print("dicoFctsReqs:")
		#pprint(dicoFctsReqs)
		
	for req in reqs:
		dicoReqs[req[0]]=req
	for fct in fcts:
		dicoFcts[fct[0]]=fct
		



#print dicoChainsFctPerms['ESPD3640']
def updateChain (chain)	:
	
	print (""                                    )
	print ("-------------------------------"     )
	print ("--	Init ", chain                    )
	print ("-------------------------------"     )
	print ("")
	
	#print("insert into BEST..TI17CHN" + ENV + " ('%s','%s')"%(dicoChains[chain][0],dicoChains[chain][1]))
	print ( "	delete BEST..TI17PERMFIL" + ENV + " where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='{chain}')".format(chain=chain))
	print ( "	delete BEST..TI17REQFNC" + ENV + " where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='{chain}')".format(chain=chain))
	print ( "	delete BEST..TI17FNC" + ENV + " where CHAIN_CT='{chain}'".format(chain=chain))
	print ( "	delete BEST..TI17CHN" + ENV + "  where CHAIN_CT='{chain}'".format(chain=chain))

	
	print ( "\n	insert into BEST..TI17CHN" + ENV + " values ('{chain}',  '{label}')".format(chain=chain,label=dicoChains[chain][1]) )

	for fct in dicoChainsFctPerms[chain]:
		#if fct in ["POSE","POCE","POSI","POCI"] : 
		#	newFct = chain + "_" + fct
		#else:
		#	newFct = fct
	
		print ("\n		--IDF_CT:  " , fct  , "\n")
		print ( "	insert into BEST..TI17FNC" + ENV + """ values ('{IDF_CT}','{IDF_LL}','{CHAIN_CT}',{SEVERITY_CT})
					""".format(IDF_CT=dicoFcts[fct][0],IDF_LL=dicoFcts[fct][1],CHAIN_CT=dicoFcts[fct][2],SEVERITY_CT=dicoFcts[fct][3]))
		
		print ("\n	----------  Perms---------------------\n")
		for perm in dicoChainsFctPerms[chain][fct]:
				print ( "		insert into BEST..TI17PERMFIL" + ENV + " values ('%s',  '%s','%s','%s','%s')" % (fct,perm[1],perm[2],perm[3],perm[4]))
		print ("\n	----------   Reqs of IDF_CT   ---------------------\n")
		#pprint(dicoChainsFctReqs[chain][fct])
		for req in dicoChainsFctReqs[chain][fct]:
				print ( "		insert into BEST..TI17REQFNC" + ENV + " values ('{fct}',  '{chain}','{label}')".format(fct=req[0],chain=req[1], label=req[2]))

	print ("\ngo\n" )
	



#for chain in dicoTI17REQJOB:
#	updateChain (chain)

if __name__ == '__main__':

	print ("")
	print ("USE BEST\ngo")
	print ("go\n")


	print (""                                  )
	print ("-------------------------------"   )
	print ("-- Clean tables"                   )
	print ("-------------------------------"   )
	print ("")

	print ( "	delete BEST..TI17PERMFIL" + ENV )
	print ( "	delete BEST..TI17REQFNC" + ENV  )
	print ( "	delete BEST..TI17CHN" + ENV  )
	print ( "	delete BEST..TI17FNC" + ENV  )
	print ( "	delete BEST..TI17REQ" + ENV  )

	print (""                                   )
	print ("-------------------------------"    )
	print ("--	load BEST..TI17REQ "            )
	print ("-------------------------------"    )
	print ("")



	Init()
	for req in dicoReqs:
			print ( """	insert into BEST..TI17REQ{ENV} values ('{reqcod_ct}', '{label}','{SAPOSTING_CT}','{REC_CF}')
			 """.format( ENV=ENV,
						 reqcod_ct=dicoReqs[req][0],
						 label=dicoReqs[req][1].encode('ascii',errors='ignore').decode('ascii').strip(),
						 SAPOSTING_CT=dicoReqs[req][2],
						 REC_CF=dicoReqs[req][3]).strip())

	for chain in chains:
		updateChain (chain[0])

	print ("go\n")




#updateChain ( "ESPD3640" )


