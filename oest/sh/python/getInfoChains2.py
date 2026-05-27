#! /usr/bin/env python
import os,fnmatch,time,datetime,csv,pickle,glob
import re
import sys,collections, pprint,gzip

dialect = csv.excel
dialect.delimiter = ";"
dialect.lineterminator = "\n"

SRV="DEV"

def execQuery(query):
	print "\n...... ", query
	cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Ubatch -S'+SRV+'_TPO2 -c to /tmp/ -Jiso_1 -P"omega2--" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log' +  ' 2>&1' 
	print cmd 
	#cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Udom_gen_ro -S'+SRV+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log'  
	#fout.write( cmd +"\n")
	return  os.system(cmd) 
	
	print command +' >' +fName + ' 2>&1' 
	return a


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

def getLogsInfos(sqlFile,server,site,rootLog,datefilter,dateFilterLimit,mask="*"):
	#dirs=fnmatch.filter(os.listdir(rootLog),"*"+mask+"*.log")
	dirs = glob.glob(rootLog+"/"+ "*"+mask+"*.log")
	#dirs.sort(key=os.path.getmtime)
	
	logsInfo={}
	for flog in dirs:
		CHAIN_CT=flog.split("_")[2]
		try:
			dateFile = int(flog.split("_")[-2][0:8])
		except:
			continue

		if datefilter <= dateFile and dateFilterLimit >= dateFile:
			# print datefilter, dateFile, dateFilterLimit

			if [CHAIN_CT] not in chainsList: continue 
			# print flog, CHAIN_CT
			f= open(flog, 'r')
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
				VNORME			=getparamMatched(line,"VNORME",			VNORME		)
				EST_PLAN		=getparamMatched(line,"EST_PLAN",		EST_PLAN	)	
				VERSION_9001	=getparamMatched(line,"VERSION_9001",	VERSION_9001)		
				ICLODAT			=getparamMatched(line,"ICLODAT",		ICLODAT		)
				IDF_CT			=getparamMatched(line,"IDF_CT",			IDF_CT		)
				TYPEINV			=getparamMatched(line,"TYPEINV",		TYPEINV		)
				NORME_CF		=getparamMatched(line,"NORME_CF	",		NORME_CF	)	
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
				#print flog , CRE_D
				buf="delete BTRAV..TLOG_INFO_CHAIN where server='{0}' and  SITE = '{1}' and CRE_D = '{2}' and IDF_CT = '{3}' \n".format(server,site,CRE_D,IDF_CT)
				buf +="insert into BTRAV..TLOG_INFO_CHAIN values( "  \
				+ 									 addStringValue(server      ) \
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

chainsList=getResultSet("SELECT  distinct job  FROM BTRAV..ITK_VTOM_CLOS")
# print chainsList
sqlFileName="getInfoChains"
sqlFile=open(sqlFileName+".sql", mode='wt') 
# serversList=["dcvin2obbatch"] 
serversList=["aeninto2batch","aenitko2batch","aenuato2batch","aenprdo2batch"]#,"dcvin2obbatch"]
sitesList=["as", "am", "eu"]

dateFilter = int(sys.argv[1])
dateFilterLimit = 99999999
if len(sys.argv) > 2:
	dateFilterLimit = int(sys.argv[2])
	
for server in serversList:
	for site in sitesList:
		rootLog="/scordata_"+server+"/ub"+site+"/log/"
		print server,site, dateFilter, dateFilterLimit
		getLogsInfos(sqlFile,server,site,rootLog,dateFilter, dateFilterLimit)#,"T_ESID2000_AEnItkO2Batc") 
		
# cmd="isql -Ubatch -SDEV_TPO2 -Pomega2-- -Jiso_1 -eerr -i{0}.sql -o{0}.log ".format(sqlFileName)
# sqlFile.close() 
# print cmd
# os.system(cmd ) 
