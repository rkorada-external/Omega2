#! /usr/bin/python3

#import extractPermFilesFromlog
import os,fnmatch,glob
import re
import sys,collections
import os.path

from pprint import pprint
from collections import OrderedDict


def execQuery(SRV,query):
	#print ("\n...... ", query)
	cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Ubatch -S'+SRV.upper()+'_TPO2 -c to /tmp/ -Jiso_1 -P"omega2--" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log' +  ' 2>&1' 
	#cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Udom_gen_ro -S'+SRV.upper()+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log'  
	#print (cmd) 
	#fout.write( cmd +"\n")
	return  os.system(cmd) 
	
	#print ( command +' >' +fName + ' 2>&1' )
	return a


def getResultSet(SRV,query):
	#fout.write( "query: " + query+"\n")
	b=execQuery(SRV,query)
	file = open('/tmp/query.out.1', 'r')
	b = file.readlines()
	tab=[]
	for line in b:
		tab.append( line.strip().split("~"))
	file.close()
	#fout.write( tab +" \n")
	return tab

def create_table():
	fSql=open("tmpChains.sql","w")
	fSql.write("USE BTRAV                                                   \n")
	fSql.write("go                                                         \n")
	fSql.write("                                                           \n")
	fSql.write("IF OBJECT_ID('dbo.TCHAIN_JOB') IS NOT NULL                   \n")
	fSql.write("BEGIN                                                      \n")
	fSql.write("    DROP TABLE dbo.TCHAIN_JOB                                \n")
	fSql.write("    IF OBJECT_ID('dbo.TCHAIN_JOB') IS NOT NULL               \n")
	fSql.write("        PRINT '<<< FAILED DROPPING TABLE dbo.TCHAIN_JOB >>>' \n")
	fSql.write("    ELSE                                                   \n")
	fSql.write("        PRINT '<<< DROPPED TABLE dbo.TCHAIN_JOB >>>'         \n")
	fSql.write("END                                                        \n")
	fSql.write("go                                                         \n")
	fSql.write("create table TCHAIN_JOB                                      \n")
	fSql.write("(                                                          \n")
	fSql.write("    ENV_CT                            varchar(10) null,                         \n")
	fSql.write("    CHAIN_CT                            varchar(10) null,                         \n")
	fSql.write("    JOB_CT                            	varchar(50) null                         \n")
	fSql.write(")                                                          \n")
	fSql.write("go\n")
	cmd="isql -Ubatch -SDEV_TPO2 -Pomega2-- -eerr -i tmpChains.sql" 
	os.system(cmd )
	fSql.close()



def AnalyseJobLine ( chain,line):
	elmnts = re.split(r'\s+|\t+', line)
	JOB=args= folder=""

	for elmnt in elmnts:
		#print elmnt
		if elmnt == '2>&1':break
		if folder != "" :  args +=  elmnt + " "
		if re.search('.cmd',elmnt):
			matchFolderJob = re.match( r'\$\{(.*)\}/(.*).cmd', elmnt)
			if matchFolderJob :
				folder=matchFolderJob.group(1)
				JOB=matchFolderJob.group(2)


	if JOB != "":
				#print "\t" , JOB ,args
				print (chain+";"+JOB)
				


def getJobsOfChain(src_chain,fSql,env):
	chain = os.path.basename(src_chain)
	#print src_chain
	f= open(src_chain, "r", encoding='cp1252') 
	a = f.readlines()
	findCHAININT=0
	findJOBINIT=0
	for line in a:
		#print line
		line=re.sub('PARALLEL_JOB\s*"', '', line)
		if line.strip().startswith("CHAININIT"):
			findCHAININT=1
			#print(src_chain)
		if line.strip().startswith("JOBINIT"):findJOBINIT=1
		if  (not line.find(".cmd"))  :
			continue
		#if findCHAININT == 1 and  (re.search(r'\.cmd.*2>&1 | ${TEE}',line)) :
		if findCHAININT == 1 and  (line.strip().startswith("${DCMD}/") or line.strip().startswith("${DUTI}/") ) :
			#print( line)
			matchFolderJob = re.match( r'.*/(.*).cmd', line)
			#print matchFolderJob
			if matchFolderJob :
				#folder=matchFolderJob.group(1)
				JOB=matchFolderJob.group(1)
				if JOB != "":
					#print "\t" , JOB ,args
					#print( chain.replace('.cmd','')+";"+JOB)
					chain=chain.replace('.cmd','')
					fSql.write("insert into BTRAV..TCHAIN_JOB VALUES('{env}','{chain}','{job}')  \n".format(env=env, chain=chain,job=JOB))
				
			#AnalyseJobLine(chain.replace('.cmd',''),line.strip())
	fSql.write("go\n")
	f.close()

LOG=""
PARM_CRE_D=""
Function=""
IDF_CT=""
chain=""
GONOGO=""
stepLogs=[]



def parseProgStep(root,stepLog):
	global stepsLogs
	stepLog0=root+"/temporaire/"+stepLog
	if not os.path.isfile(stepLog0) : return {"IN":[],"OUT":[]}
	f= open(stepLog0, "r", encoding='cp1252') 
	a = f.readlines()
	I=[]
	O=[]
	for line in a :
		tab= line.strip().split(";")
		if len(tab) == 3 :
			if "toDebug" in tab[2]:
				type=tab[2].split("=")[0].split("_")[1]+ " "
				if type != "PRM" :
					I.append(type+ " "  + tab[2].split("=")[1].strip())
	f.close()
	return {"IN":sorted(I, key=str.lower),"OUT":O}




def parseSortStep(root,stepLog):
	global stepsLogs
	stepLog0=root+"/temporaire/"+stepLog
	if not os.path.isfile(stepLog0) : return {"IN":[],"OUT":[]}
	f= open(stepLog0, "r", encoding='cp1252') 
	a = f.readlines()
	I=[]
	O=[]
	for line in a :
		if line.startswith("/INFILE "):
			I.append(line.split(" ")[1])
		if line.startswith("/OUTFILE ") :
			O.append(line.split(" ")[1])
	f.close()
	return {"IN":I,"OUT":O}


def parseChainLog(root,log,dbclo=""):
	global 	PARM_CRE_D,	GONOGO_VAR,GONOGO_VAR2,	Function,IDF_CT,chain,GONOGO,stepLogs
	stepLogs=[]
	chain= os.path.basename(log).split("_")[1]
	f= open(log, "r", encoding='cp1252') 
	a = f.readlines()
	PARM_CRE_D=""
	GONOGO_VAR=""
	GONOGO_VAR2=""
	GONOGO=""
	Function=""
	IDF_CT=""
	stepLog=""
	BEGIN_STEP="xxxx"
	startFiles={}
	endFiles={}
	outFiles={}
	for line in a:
		if line.startswith("#---> PARM_CRE_D"):
			PARM_CRE_D=line.split("=")[1].strip()
			if dbclo != PARM_CRE_D and dbclo != "": 
				return ({},{})
			#else:
				#print("------- ",chain,end=" ")
		if line.strip().startswith("# PRGLOG:") and dbclo == PARM_CRE_D:
			stepLog=line.strip().split(":")[1]
			#parseStepLog(root,stepLog)
		if line.startswith("# Function:"): 
			Function = line.split(":")[1].strip()
			#print( "\t",Function)
				#----> IDF_CT
		if line.startswith("#----> IDF_CT"):  IDF_CT =  line.split(":")[1].strip()

		if line.startswith("# GONOGO_VAR:"):  GONOGO_VAR =  line.split("=")[1].strip()
		if line.startswith("# GONOGO_VAR2:"): 
			GONOGO_VAR2 = line.split("=")[1].strip()
			GONOGO="NO GO"
			if GONOGO_VAR == "Y" or GONOGO_VAR2 == "Y" :
				GONOGO="GO"
			#print(log,"GONOGO=",GONOGO,"IDF_CT=",IDF_CT)
			#print("chain=",chain,"GONOGO=",GONOGO,"GONOGO_VAR=",GONOGO_VAR,"GONOGO_VAR2=",GONOGO_VAR2)

		m = re.match( r'#---> (.*) = /scor/scordata/ub../perm/(.*)', line.strip())
		if m :
			perm=m.group(1)
			path=m.group(2).split(" ")[0]
			startFiles[perm] ={"path":path}
			startFiles[perm]["PERMFIL_CT"]=perm.strip()
			if len ( m.group(2).split(" ") ) > 1 :
				startFiles[perm]["size"]= m.group(2).split(" ")[1]
				startFiles[perm]["time"]= m.group(2).split(" ")[2]
		m = re.match( r'#CHAINEND---> (.*) = /scor/scordata/ub../perm/(.*)',line.strip())
		if m :
			perm=m.group(1)
			path=m.group(2).split(" ")[0]
			endFiles[perm] ={"PERMFIL_CT":perm.strip(),"path":path,"size":"","time":"","IO":"I"}
			if len ( m.group(2).split(" ") ) > 1 :
				endFiles[perm]["size"]= m.group(2).split(" ")[1]
				endFiles[perm]["time"]= m.group(2).split(" ")[2]
				if "time" in startFiles[perm] :
					if  endFiles[perm]["time"] !=  "":
						if startFiles[perm]["time"] != endFiles[perm]["time"]:
							outFiles[perm] = endFiles[perm]
							endFiles[perm]["IO"]="O"
				if "time" in startFiles[perm] and endFiles[perm]["time"] ==  "" :
					outFiles[perm] = endFiles[perm]
					endFiles[perm]["IO"]="O"
				if "time" not in startFiles[perm] and endFiles[perm]["time"] !=  "" :
					outFiles[perm] = endFiles[perm]
					endFiles[perm]["IO"]="O"
			

	#outFiles={}
	#for file in startFiles :
	#	if file not in endFiles: continue 
	#	endFiles[file]["IO"]="I"
	#	endFiles[perm]["PERMFIL_CT"]=startFiles[perm]["PERMFIL_CT"]
	#	if "time" in startFiles[file] :
	#		if  endFiles[file]["time"] !=  "":
	#			if startFiles[file]["time"] != endFiles[file]["time"]:
	#				outFiles[file] = endFiles[file]
	#				endFiles[file]["IO"]="O"
	#	if "time" in startFiles[file] and endFiles[file]["time"] ==  "" :
	#		outFiles[file] = endFiles[file]
	#		endFiles[file]["IO"]="O"
	#	if "time" not in startFiles[file] and endFiles[file]["time"] !=  "" :
	#		outFiles[file] = endFiles[file]
	#		endFiles[file]["IO"]="O"
	#		
	#new_list = sorted(endFiles.keys(), key=lambda x:x[4])
	##pprint(endFiles)
	#for file in new_list :
	#	if file in endFiles: endFile=endFiles[file]
	#	else : endFile=""
	#	#print(startFiles[file],endFile)
	#	#print(endFiles[file]["IO"], file,endFiles[file]["path"],endFiles[file]["size"],endFiles[file]["time"])
			
	f.close()
	
	return (chain,startFiles,endFiles)





def getPermsOfLog(log):
	if not os.path.exists(log) : return{}
	stepLogs=[]
	#chain= os.path.basename(log).split("_")[1]
	f= open(log, "r", encoding='cp1252') 
	a = f.readlines()
	startFiles={}
	endFiles={}
	outFiles={}
	perms={}
	for line in a:
		m = re.match( r'#---> (.*) = /scor/scordata/ub../perm/(.*)', line.strip())
		if m :
			perm=m.group(1)
			path=m.group(2).split(" ")[0]
			startFiles[perm] ={"path":path}
			startFiles[perm]["PERMFIL_CT"]=perm.strip()
			if len ( m.group(2).split(" ") ) > 1 :
				startFiles[perm]["size"]= m.group(2).split(" ")[1]
				startFiles[perm]["time"]= m.group(2).split(" ")[2]
			else:
				startFiles[perm]["size"]= ""
				startFiles[perm]["time"]= ""
			
		m = re.match( r'#CHAINEND---> (.*) = /scor/scordata/ub../perm/(.*)',line.strip())
		if m :
			perm=m.group(1)
			path=m.group(2).split(" ")[0]
			endFiles[perm] ={"PERMFIL_CT":perm.strip(),"path":path,"size":"","time":"","IO":"I"}
			if len ( m.group(2).split(" ") ) > 1 :
				endFiles[perm]["size"]= m.group(2).split(" ")[1]
				endFiles[perm]["time"]= m.group(2).split(" ")[2]
				if "time" in startFiles[perm] :
					if  endFiles[perm]["time"] !=  "":
						if startFiles[perm]["time"] != endFiles[perm]["time"]:
							outFiles[perm] = endFiles[perm]
							endFiles[perm]["IO"]="O"
				if "time" in startFiles[perm] and endFiles[perm]["time"] ==  "" :
					outFiles[perm] = endFiles[perm]
					endFiles[perm]["IO"]="O"
				if "time" not in startFiles[perm] and endFiles[perm]["time"] !=  "" :
					outFiles[perm] = endFiles[perm]
					endFiles[perm]["IO"]="O"
			else:
				endFiles[perm]["size"]= ""
				endFiles[perm]["time"]= ""
				
			

			
	f.close()
	for perm in startFiles:
		if perm in endFiles:
			perms[perm]=startFiles[perm]
			perms[perm]["path"]=startFiles[perm]["path"]
			perms[perm]["size_e"]= endFiles[perm]["size"]
			perms[perm]["time_e"]= endFiles[perm]["time"]
	return (perms)






def getLogs(env,site,dbclo,patt=""):
	global LOG ,GONOGO
	root="/scor/scord::ata/ub{site}".format(site=site)
	if env != 'dev':
		root="/scordata_aen{env}o2batch/ub{site}".format(env=env,site=site)
	masq="{root}/log/*{patt}*.log".format(root=root,patt=patt)
	print( masq) 
	logs = glob.glob(masq)
	for log in logs:
		res=parseChainLog(root,log,dbclo)

def getOutputPerms(env,site,dbclo,patt=""):
	global LOG ,GONOGO
	root="/scor/scord::ata/ub{site}".format(site=site)
	if env != 'dev':
		root="/scordata_aen{env}o2batch/ub{site}".format(env=env,site=site)
	masq="{root}/log/*{patt}*.log".format(root=root,patt=patt)
	print( masq) 
	logs = glob.glob(masq)
	perms=[]
	for log in logs:
		res=parseChainLog(root,log,dbclo)
		chain=res[0]
		start=res[1]
		end=res[2]
		for perm in end:
			date_in=date_out=""
			if 'time' in start[perm]: date_in = start[perm]["time"]
			if 'time' in end[perm]: date_out = end[perm]["time"]
			if end[perm]["IO"] ==  "O" :
				#print (chain, start[perm]["PERMFIL_CT"],end[perm]["PERMFIL_CT"])
				if [start[perm]["PERMFIL_CT"],start[perm]["path"],chain] not in perms : perms.append([start[perm]["PERMFIL_CT"],start[perm]["path"],chain]) 
	return perms
	
	
def getIntermidiareFile():
	query="select * from BTRAV..TCHK_LOG_CHAIN where cre_d > '20220501' and env ='itk' and GONOGO ='GO' and site ='eu'"
	ret=getResultSet("DEV",query)
	perms_o={}
	perms_old={}
	for row in ret:
		log=row[16]
		chain= os.path.basename(log).split("_")[1]
		#print(log)
		perms= getPermsOfLog(log)
		#pprint(perms)
		for perm in perms :
			chain=row[2]
			idf_ct=row[3]
			perm
			time_chain=row[6].replace("/","-").replace(" ","_")
			time_s=perms[perm]["time"]
			time_e=perms[perm]["time_e"] 
			path=perms[perm]["path"]
			if time_s != time_e :
				#print(chain,idf_ct,perm,path,time_chain,time_e,time_s,log)
				if path not in perms_o:
					perms_o[path]=perms[perm]["time_e"]
				else :
					if perms_o[path]  > perms[perm]["time_e"]:
						perms_o[path]=perms[perm]["time_e"]
		for perm in perms :
			path=perms[perm]["path"]
			if path  not in perms_old and  path  not in perms_o:
				perms_old[path] = perms[perm]["time_e"]
				
	pprint(perms_o)

	query="select distinct cre_d from BTRAV..TCHK_LOG_CHAIN where cre_d >= '20220418' and env ='itk' and GONOGO ='GO' and site ='eu'"
	dbclos=getResultSet("DEV",query)
	#pprint(dbclos)
	permsChainsDbclo={}
	for dbclo in dbclos:
		permsChains={}
		query="select flog, CHAIN_CT, IDF_CT , START_D from BTRAV..TCHK_LOG_CHAIN where cre_d = '{dbclo}' and env ='itk' and GONOGO ='GO' and site ='eu'".format(dbclo=dbclo[0])
		logs=getResultSet("DEV",query)
		for log in logs:
			pathLog=log[0]
			chain=log[1]
			idf_ct=log[2]
			start_d=log[3].replace("/","-").replace(" ","_")
			perms= getPermsOfLog(log[0])
			for perm in perms :
				time_s=perms[perm]["time"]
				time_e=perms[perm]["time_e"] 
				path=perms[perm]["path"]
				dic={"chain":chain,"idf_ct":idf_ct,"chainStart":start_d,"inDate":perms[perm]["time"],"outDate":perms[perm]["time_e"]} 
				if path in permsChains :
					permsChains[path].append(dic)
				else:
					permsChains[path]=[dic]
		for path in permsChains:
			permsChains[path]=sorted(permsChains[path],key=lambda k:k["chainStart"])
		permsChainsDbclo[dbclo[0]]=permsChains
	

def getIntermOfClosing(env,site,dbclo):
	#print("DBCLO: ",dbclo)
	permsChains={}
	query="""select flog, CHAIN_CT, IDF_CT , START_D 
			 from BTRAV..TCHK_LOG_CHAIN 
			 where cre_d = '{dbclo}' 
			 and env ='{env}' 
			 and GONOGO ='GO' 
			 and site ='{site}'
	""".format(dbclo=dbclo,env=env,site=site)
	logs=getResultSet("DEV",query)
	for log in logs:
		pathLog=log[0]
		chain=log[1]
		idf_ct=log[2]
		start_d=log[3].replace("/","-").replace(" ","_")
		perms= getPermsOfLog(log[0])
		for perm in perms :
			time_s=perms[perm]["time"]
			time_e=perms[perm]["time_e"] 
			path=perms[perm]["path"]
			dic={"chain":chain,"idf_ct":idf_ct,"chainStart":start_d,"inDate":perms[perm]["time"],"outDate":perms[perm]["time_e"]} 
			if path in permsChains :
				permsChains[path].append(dic)
			else:
				permsChains[path]=[dic]
	for path in permsChains:
		permsChains[path]=sorted(permsChains[path],key=lambda k:k["chainStart"])
	return( permsChains )

def getIntermOfAlClosingEnvSite(env,site):
	query="""select distinct cre_d 
			from BTRAV..TCHK_LOG_CHAIN 
			where  1 = 1
			--cre_d >= '20220418' 
			and GONOGO ='GO' 
			and env ='{env}' 
			and site ='{site}'
			order by START_D
			""".format(env=env,site=site)
	dbclos=getResultSet("DEV",query)
	#pprint(dbclos)
	permsChainsDbclo={}
	for dbclo in dbclos:
		ret=getIntermOfClosing(env,site,dbclo[0])
		permsChainsDbclo[dbclo[0]]=ret
	
	return( permsChainsDbclo)
	
if __name__ == '__main__':
	env=sys.argv[1]
	site=sys.argv[2]
	dbclo=sys.argv[3]
	#masq=sys.argv[4]
	#getLogs("prd","am","20220302","2022030")
	#getLogs(env,site,dbclo,masq)
	#getOutputPerms("uat","eu","","202204")
	#pprint(getIntermOfClosing(env,site,dbclo))
	#pprint(getIntermOfAlClosingEnvSite(env,site))
	paths= getIntermOfClosing(env,site,dbclo)
	pprint(paths)
	#for path in paths :
	#	if paths[path][0]['inDate'] == paths[path][0]['outDate'] :
	#		print( path)
	#		pprint(paths[path][0])
