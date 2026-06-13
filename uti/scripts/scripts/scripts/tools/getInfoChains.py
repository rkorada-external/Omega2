#! /usr/bin/python3
import os,fnmatch,time,datetime,csv,pickle,glob
import re
import sys,collections, gzip
from pprint import pprint



dialect = csv.excel
dialect.delimiter = ";"
dialect.lineterminator = "\n"
SRV="DEV" 
def execQuery(query):
	#print "\n...... ", query
	cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Ubatch -S'+SRV+'_TPO2 -c to /tmp/ -Jiso_1 -P"omega2--" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log' +  ' 2>&1' 
	#print cmd 
	#cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Udom_gen_ro -S'+SRV+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log'  
	#fout.write( cmd +"\n")
	return  os.system(cmd ) 
	

def getResultSet(query):
	#fout.write( "query: " + query+"\n")
	b=execQuery(query)
	file = open('/tmp/query.out.1', 'r')
	b = file.readlines()
	tab=[]
	for line in b:
		tab.append( line.strip().split("~"))
	file.close()
	#fout.write( tab +" \n")
	return tab


def getparamMatched(line,param,value):
	#print("line,param,value:",line,param,value)
	if value == '' :
		#nchainGrp= re.match( r'#----> "+param+" \.*: (.*)', line)
		nchainGrp= re.match( r'#----> '+param+' \.*: (.*)', line)
		if nchainGrp:
			value=nchainGrp.group(1)
			if value == "" : value=" "
	return value

def addStringValue(value,sep=","):
	if value =="": return "NULL"+sep
	return "'" + value + "'"+sep



def getLogsInfos(sqlFile,env,site,dirs):
	logsInfo={}
	chainsList=getResultSet("select CHAIN from BTRAV..TCHK_VTOM where env = '{env}' ".format(env=env))
	for flog in dirs:
		CHAIN_CT=flog.split("_")[2]
		if [CHAIN_CT] not in chainsList: continue 
		#print( flog, CHAIN_CT)
		f= open(flog, 'r', encoding='cp1252')
		a = f.readlines()
		CHAIN_CT=''
		STATUS_CT=''
		stepErr=''
		START_D=''
		END_D=''
		GONOGO=''
		VNORME=''
		EST_PLAN=''
		VERSION_9001=''
		ICLODAT=''
		IDF_CT=''
		TYPEINV=''
		NORME_CF=''
		PLAN_CT=''
		CRE_D=''
		for line in a:
			nchainGrp= re.match( r'# Chain name    :  ._(.*)  Date :  (.*)', line)
			if nchainGrp:
				CHAIN_CT=nchainGrp.group(1)
				#dt=datetime.datetime.strptime(nchainGrp.group(2), frmt)
				START_D = nchainGrp.group(2)
			nchainGrp= re.match( '#   ERROR: Step (.*) has failed with return Code', line)
			if nchainGrp:
				stepErr=nchainGrp.group(1)
			nchainGrp= re.match( r'# '+CHAIN_CT+'.*: (.*)', line)
			if nchainGrp:
				GONOGO=nchainGrp.group(1)
			nchainGrp= re.match( r'# End of Chain :  ._' + CHAIN_CT+'\s*(.*)\s*Date:\s*(.*)', line)
			if nchainGrp:
				STATUS_CT=nchainGrp.group(1)
				END_D=nchainGrp.group(2)
			nchainGrp= re.match( r'#---> PARM_CRE_D                     = (.*)', line)
			if nchainGrp:
				CRE_D=nchainGrp.group(1)
			nchainGrp= re.match( r'#---->Planified with ................: /scor/scordata/ubas/perm/T_ES.J0000_(.*).dat', line)
			if nchainGrp:
				PLAN_CT=nchainGrp.group(1)
			nchainGrp= re.match( r'#----> EST_PLAN .......................: /scor/scordata/ubas/perm/T_ESCJ0000_(P.*).dat', line)
			if nchainGrp:
				EST_PLAN=nchainGrp.group(1)
			
			if CRE_D == "" :
				nchainGrp= re.match( r'#----> CRE_D...........................: (.*)', line)
				if nchainGrp:
					CRE_D=nchainGrp.group(1)
			if CHAIN_CT ==  "ESDJ7010" and IDF_CT == "":
				mtch=re.match("# Begin of job : ._ESDJ7010_ESID0061(.)",line.strip())
				#print line.strip()
				if mtch :
					IDF_CT=CHAIN_CT+"_"+mtch.group(1).strip()
			if CHAIN_CT ==  "ESID2030" and IDF_CT == "":
				mtch=re.match("# Begin of job : ._ESID2030_ESID3024(.)",line.strip())
				if mtch :
					IDF_CT=CHAIN_CT+"_"+mtch.group(1).strip()
			if CHAIN_CT ==  "ESID2040" and IDF_CT == "":
				mtch=re.match("#---> EST_CMPCALC_PA                 = /scor/scordata/ub.*/.*/._ESID2040_CMPCALC_PA(.)",line.strip())
				if mtch :
					IDF_CT=CHAIN_CT+"_"+mtch.group(1).strip()
			if CHAIN_CT ==  "ESID2070" and IDF_CT == "":
				mtch=re.match("# Begin of job : ._ESID2070_ESID3021_(.)",line.strip())
				if mtch :
					IDF_CT=CHAIN_CT+"_"+mtch.group(1).strip()

				
				
			VNORME			=getparamMatched(line,"VNORME",			VNORME		).strip()
			EST_PLAN		=getparamMatched(line,"EST_PLAN",		EST_PLAN	).strip()	
			VERSION_9001	=getparamMatched(line,"VERSION_9001",	VERSION_9001).strip()		
			ICLODAT			=getparamMatched(line,"ICLODAT",		ICLODAT		).strip()
			IDF_CT			=getparamMatched(line,"IDF_CT",			IDF_CT		).strip()
			TYPEINV			=getparamMatched(line,"TYPEINV",		TYPEINV		).strip()
			NORME_CF		=getparamMatched(line,"NORME_CF	",		NORME_CF	).strip()	
		if VERSION_9001 !="ESCS9001":
			PLAN_CT=""
			EST_PLAN=""
		if IDF_CT.strip() =="":
			IDF_CT=CHAIN_CT
		if IDF_CT.startswith("I4_"):
			IDF_CT=CHAIN_CT+"_"+IDF_CT
		if NORME_CF=="" : 
			NORME_CF=VNORME
		if CRE_D != '' :
			#print( flog , CRE_D)
			buf="delete BTRAV..TCHK_LOG_CHAIN where env='{env}' and  site = '{site}' and CRE_D = '{CRE_D}' and IDF_CT = '{IDF_CT}' \n".format(env=env,site=site,CRE_D=CRE_D,IDF_CT=IDF_CT)
			buf +="insert into BTRAV..TCHK_LOG_CHAIN values( "  \
			+ 									 addStringValue(env      ) \
			+ 									 addStringValue(site        ) \
			+ 									 addStringValue(CHAIN_CT    ) \
			+ 									 addStringValue(IDF_CT      ) \
			+ 									 addStringValue(CRE_D       ) \
			+ 									 addStringValue(STATUS_CT   ) \
			+ 									 addStringValue(START_D     ) \
			+ 									 addStringValue(END_D       ) \
			+ 									 addStringValue(GONOGO      ) \
			+ 									 addStringValue(VNORME      ) \
			+ 									 addStringValue(EST_PLAN    ) \
			+ 									 addStringValue(VERSION_9001) \
			+ 									 addStringValue(ICLODAT     ) \
			+ 									 addStringValue(TYPEINV     ) \
			+ 									 addStringValue(NORME_CF     ) \
			+ 									 addStringValue(PLAN_CT     ) \
			+ 									 addStringValue(flog    ,")")
			sqlFile.write(buf+"\n")
			sqlFile.write("go \n")

def getLogsInfosSite(env,site,pattern="*"):
	sqlFile=open("getLogsInfosSite.sql", mode='wt') 
	if env.lower() == "dev":
		rootLog="/scor/scordata/ub{site}/log/".format(site=site.lower())
	else:
		rootLog="/scordata_aen{env}o2batch/ub{site}/log/".format(env=env.lower(),site=site.lower())
	#dirs=fnmatch.filter(os.listdir(rootLog),"*"+pattern+"*.log")
	path=rootLog+ "*"+pattern+"*.log"
	print(path)
	dirs = glob.glob(path)
	dirs.sort(key=os.path.getmtime)
	sqlFile=open("getLogsInfosSite.sql", mode='wt') 
	getLogsInfos(sqlFile,env,site,dirs)
	sqlFile.close() 
	cmd="isql -Ubatch -SDEV_TPO2 -Pomega2-- -Jiso_1 -eerr -igetLogsInfosSite.sql -o.log "
	os.system(cmd )
	
def getAllLogsInfos() :
	sqlFile=open("getAllInfoChains.sql", mode='wt') 
	for env in ["dev","uat","int","mai","prd","in2","cnv","itk"]:
		for site in ["eu","as","am"]:
			if env.lower() == "dev":
				rootLog="/scor/scordata/ub{site}/log/".format(site=site.lower())
			else:
				rootLog="/scordata_aen{env}o2batch/ub{site}/log/".format(env=env.lower(),site=site.lower())
			path=rootLog+ "*.log"
			dirs = glob.glob(path)
			dirs.sort(key=os.path.getmtime)
			print(env,site,len(dirs))
			getLogsInfos(sqlFile,env,site,dirs)
	sqlFile.close() 	
	cmd="isql -Ubatch -SDEV_TPO2 -Pomega2-- -Jiso_1 -eerr -igetInfoChains.sql -o.log "
	os.system(cmd )
	
from datetime import datetime
from datetime import timedelta 

def refreshLogsInfos():
	#sqlFile=open("refreshLogsInfos.sql", mode='wt') 
	sqlFile=open("refreshLogsInfos.sql", mode='wt') 
	dates =getResultSet("select CONVERT(VARCHAR(10), convert(datetime,max(START_D)), 112) MAX_DAY, CONVERT(VARCHAR(10),getdate(), 112) TODAY from BTRAV..TCHK_LOG_CHAIN")
	max_date=dates[0][0]
	print ( "Max date:",max_date)
	for env in ["dev","uat","int","mai","prd","in2","cnv","itk"]:
		for site in ["eu","as","am"]:
			server= "aen"+env+"o2batch"
			if env.lower() == "dev":
				rootLog="/scor/scordata/ub{site}/log/".format(site=site.lower())
			else:
				rootLog="/scordata_aen{env}o2batch/ub{site}/log/".format(env=env.lower(),site=site.lower())
			path=rootLog+ "*_AE*O2Batch_*.log"
			print("Path: ",path)
			dirs = glob.glob(path)
			dirs.sort(key=os.path.getmtime)
			new_dirs=[]
			
			for flog in dirs:
				#print (flog)
				dt=flog.lower().replace(server+"_",";").split(";")[1][0:8]	
				if dt >= max_date :
					#print (dt, flog)
					new_dirs.append(flog)
			getLogsInfos(sqlFile,env,site,new_dirs)
	sqlFile.close() 
	cmd="isql -Ubatch -SDEV_TPO2 -Pomega2-- -Jiso_1 -eerr -irefreshLogsInfos.sql -o.log "
	os.system(cmd )



		
if __name__ == '__main__':
	if  len (sys.argv) < 2 :
		getAllLogsInfos() 
	else:
		env=""
		if  len (sys.argv) == 2 and sys.argv[1].lower() == "update": 
			refreshLogsInfos()
		if  len (sys.argv) > 2 : 
			env = sys.argv[1]
			site = sys.argv[2]
			pattern = sys.argv[3]
			getLogsInfosSite(env,site,pattern)
	