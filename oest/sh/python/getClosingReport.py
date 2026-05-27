#! /usr/bin/env python
import os,fnmatch,time,datetime,csv,pickle,glob
import re
import sys,collections, gzip
from pprint import pprint
#! /usr/bin/env python



dest = sys.argv[1]
dateMin="00000000"
dateMax="99999999"
if len (sys.argv)  > 2 :
	dateMin=sys.argv[2]
if len (sys.argv)  > 3 :
	dateMax=sys.argv[3]

DCSV = dest+"/getPlanGZ2"
DPKL = dest+"/pkl"

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
	return  os.system(cmd ) 
	
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

def getIdFctChain(srv):
	global SRV
	SRV=srv
	return getResultSet("""
							select distinct IDF_CT,CHAIN_CT into #IdfctChn from BEST..TI17REQCHN     where idf_ct not  like '%PO[CS][EI]%' 
							select p.IDF_CT,PERMFIL_CT, isnull(CHAIN_CT,substring(p.IDF_CT,1,8)) CHAIN_CT  from BEST..TI17PERMFIL  p
							left outer join  #IdfctChn  c on p.IDF_CT = c.IDF_CT 
							--where  p.IDF_CT not like '%ESPT%'
							--and p.IDF_CT ='STPD1500'
						""")
							                            
	
def nb_ligne( IN ):
	return sum(1 for line in open (IN))     #sumforinopen#    # count





def getChainJobs(server):
	SRC_DIRECTORY_DCMD="/scoromega_runnable_"+server+"/cmd"
	dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_DCMD),"*0.cmd")
	fChainJobsSql=open("data/analyse/chainJobs.sql","w")
	fChainJobsCsv=open("data/analyse/chainJobs.csv","w")
	fChainJobsSql.write("USE BEST                                                   \n")
	fChainJobsSql.write("go                                                         \n")
	fChainJobsSql.write("                                                           \n")
	fChainJobsSql.write("IF OBJECT_ID('dbo.TCHNJOBS') IS NOT NULL                   \n")
	fChainJobsSql.write("BEGIN                                                      \n")
	fChainJobsSql.write("    DROP TABLE dbo.TCHNJOBS                                \n")
	fChainJobsSql.write("    IF OBJECT_ID('dbo.TCHNJOBS') IS NOT NULL               \n")
	fChainJobsSql.write("        PRINT '<<< FAILED DROPPING TABLE dbo.TCHNJOBS >>>' \n")
	fChainJobsSql.write("    ELSE                                                   \n")
	fChainJobsSql.write("        PRINT '<<< DROPPED TABLE dbo.TCHNJOBS >>>'         \n")
	fChainJobsSql.write("END                                                        \n")
	fChainJobsSql.write("go                                                         \n")
	fChainJobsSql.write("create table TCHNJOBS                                      \n")
	fChainJobsSql.write("(                                                          \n")
	fChainJobsSql.write("    CHAIN_CT     varchar(30) null,                         \n")
	fChainJobsSql.write("    ordre               smallint,                          \n")
	fChainJobsSql.write("    JOB_CT              varchar(30) null,                  \n")
	fChainJobsSql.write("    JOB_CMD      varchar(1024) null                        \n")
	fChainJobsSql.write(")                                                          \n")
	fChainJobsSql.write("go                                                         \n")



	fChainJobsCsv.write("CHAIN_CT,ordre,JOB_CT,JOB_CMD\n")

	chainJobs=collections.OrderedDict()

	for chain in dirs:
		i=0
		NCHAIN=chain.split(".")[0]
		for line in open(SRC_DIRECTORY_DCMD+"/"+chain).readlines():
			line_s=line.strip().replace("'","\"")
			if re.match(".*\$\{DCMD\}",line.strip()) and not line_s.startswith("#"):
				matchJob = re.match( r'(.*)/(.*).cmd', line_s)
				if matchJob :
					folder=matchJob.group(1)
					job=matchJob.group(2)
					i +=1
					if NCHAIN not in chainJobs: chainJobs[NCHAIN]=[]
					chainJobs[NCHAIN].append(job)
					#print NCHAIN, str(i),job,folder, line_s
					fChainJobsCsv.write( "{0};{1};{2};{3})\n".format(NCHAIN, str(i),job, line_s))
					fChainJobsSql.write( "insert into BEST..TCHNJOBS values('{0}',{1},'{2}','{3}')\n".format(NCHAIN, str(i),job, line_s))
	fChainJobsSql.write("go                                                         \n")
	fChainJobsSql.close()
	fChainJobsCsv.close()
	return chainJobs

#for chain in chainJobs: print chain, chainJobs[chain]


def getLogsInfos(rootLog,rootPerm,site,cre_d,mask="*"):
	#dirs=fnmatch.filter(os.listdir(rootLog),"*"+mask+"*.log")
	dirs = glob.glob(rootLog+ "/"+"*"+mask+"*.log") 
	dirs.sort(key=os.path.getmtime)

	logsInfo={}
	print '		getLogsInfos({0},{1},{2},{3},{4})'.format(rootLog,rootPerm,site,cre_d,mask )
	for log in dirs:
		chain=os.path.basename(log).split("_")[1]
		if [chain] not in chainsList: continue 
		isLog=False
		perms={}
		IDF_CT=""
		NORME_CF=""
		VNORME=""
		TYPEINV=""
		param_Context_id=""
		VERSION_9001=""
		#chain=log[2:10] 
		GONOGO=""
		lines=open(log).readlines()
		for line in lines:
			if re.match(".*#---> PARM_CRE_D                     = "+cre_d+".*",line.strip()): 
				isLog=True
				break
				#print  "PARM_CRE_D",log,cre_d
			if re.match("#----> CRE_D...........................: "+cre_d+".*",line.strip()): 
				isLog=True
				break

		if isLog:
			#print log, chain,cre_d
			for line in lines:
				#print line
				matchPerm=re.match("#---> (.*)= /scor/scordata/ub"+site+"/(.*dat)( *[0-9]*)(.*)",line.strip())
				#matchPerm=re.match("#---> (.*)= /scor/scordata/ub"+site+"/(.*)",line.strip())
				if matchPerm  :
					PERMFIL_CT=matchPerm.group(1).strip()
					if PERMFIL_CT not  in perms:
						perms[PERMFIL_CT]={}
						perms[PERMFIL_CT]["pathI"]=matchPerm.group(2)
						perms[PERMFIL_CT]["sizeInLogI"]=matchPerm.group(3)
						perms[PERMFIL_CT]["dtInLogI"]=matchPerm.group(4)
						perms[PERMFIL_CT]["sizeI"]=""
						perms[PERMFIL_CT]["dtI"]=""
						if os.path.isfile(rootPerm+perms[PERMFIL_CT]["pathI"]): 
							perms[PERMFIL_CT]["sizeI"] = str(os.path.getsize(rootPerm+perms[PERMFIL_CT]["pathI"]))
							perms[PERMFIL_CT]["dtI"]   =time.ctime(os.path.getctime(rootPerm+perms[PERMFIL_CT]["pathI"]))
						perms[PERMFIL_CT]["pathO"]		=""
						perms[PERMFIL_CT]["sizeInLogO"]	=""
						perms[PERMFIL_CT]["dtInLogO"]	=""
						perms[PERMFIL_CT]["sizeO"]		=""
						perms[PERMFIL_CT]["dtO"]		=""
						#pprint(perms)
				matchPerm=re.match("#CHAINEND---> (.*)= /scor/scordata/ub"+site+"/(.*dat)( *[0-9]*)(.*)",line.strip())
				#matchPerm=re.match("#---> (.*)= /scor/scordata/ub"+site+"/(.*)",line.strip())
				if matchPerm :
					PERMFIL_CT=matchPerm.group(1).strip()
					if PERMFIL_CT not in perms: 
						perms[PERMFIL_CT]={}
						perms[PERMFIL_CT]["pathI"]		=""
						perms[PERMFIL_CT]["sizeInLogI"]	=""
						perms[PERMFIL_CT]["dtInLogI"]	=""
						perms[PERMFIL_CT]["sizeI"]		=""
						perms[PERMFIL_CT]["dtI"]		=""
					perms[PERMFIL_CT]["pathO"]		=matchPerm.group(2)
					perms[PERMFIL_CT]["sizeInLogO"]	=matchPerm.group(3)
					perms[PERMFIL_CT]["dtInLogO"]	=matchPerm.group(4)
					perms[PERMFIL_CT]["sizeO"]		=""
					perms[PERMFIL_CT]["dtO"]		=""
					if os.path.isfile(rootPerm+perms[PERMFIL_CT]["pathO"]): 
						perms[PERMFIL_CT]["sizeO"]  = str(os.path.getsize(rootPerm+perms[PERMFIL_CT]["pathO"]))
						perms[PERMFIL_CT]["dtO"]    =time.ctime(os.path.getctime(rootPerm+perms[PERMFIL_CT]["pathO"]))
					#pprint(perms)
				mtch=re.match("#----> IDF_CT .........................: (.*)",line.strip())
				if mtch :
						IDF_CT=mtch.group(1).strip()
				mtch=re.match("#----> NORME_CF .......................: (.*)",line.strip())
				if mtch :
						NORME_CF=mtch.group(1)
				mtch=re.match("#----> TYPEINV ........................: (.*)",line.strip())
				if mtch :
						TYPEINV=mtch.group(1)
				mtch=re.match("#----> VNORME .........................: (.*)",line.strip())
				if mtch :
						VNORME=mtch.group(1)
				mtch=re.match("#----> param_Context_id ...............: (.*)",line.strip())
				if mtch :
						param_Context_id=mtch.group(1)
				mtch=re.match("#----> VERSION_9001 ...................: (.*)",line.strip())
				if mtch :
						VERSION_9001=mtch.group(1)
				mtch=re.match("# "+chain+".*: (.*)",line.strip())
				if mtch :
						GONOGO=mtch.group(1).strip()
				if chain ==  "ESDJ7010" and IDF_CT == "":
					mtch=re.match("# Begin of job : ._ESDJ7010_ESID0061(.)",line.strip())
					if mtch :
						IDF_CT=chain+"_"+mtch.group(1).strip()
				if chain ==  "ESID2030" and IDF_CT == "":
					mtch=re.match("# Begin of job : ._ESID2030_ESID3024(.)",line.strip())
					if mtch :
						IDF_CT=chain+"_"+mtch.group(1).strip()
				if chain ==  "ESID2040" and IDF_CT == "":
					mtch=re.match("#---> EST_CMPCALC_PA                 = /scor/scordata/ubas/.*/._ESID2040_CMPCALC_PA(.)_2",line.strip())
					if mtch :
						IDF_CT=chain+"_"+mtch.group(1).strip()
				if chain ==  "ESID2070" and IDF_CT == "":
					mtch=re.match("# Begin of job : ._ESID2070_ESID3021_(.)",line.strip())
					if mtch :
						IDF_CT=chain+"_"+mtch.group(1).strip()
						
#CHAINEND---> EST_IGTAA00                    = /scor/scordata/ubam/perm/T_ESIJ7000_IGTAA00_POS_20210630.dat 2291147377 2021-04-05 11:59:52						
		if isLog and GONOGO == "GO":
			if NORME_CF=="" : NORME_CF=VNORME
			if IDF_CT=="" : IDF_CT =chain
			if VERSION_9001 == "ESFD9001 EBS" : IDF_CT=chain +"_" +param_Context_id
			if VERSION_9001 == "ESFD9001 IFRS4" : IDF_CT =chain + "_" + IDF_CT # chain P&C multi-insance  ( split Life/P&C ) 
			if IDF_CT =="Q" or IDF_CT =="Y" : IDF_CT =chain # chaine Life
			logsInfo[IDF_CT]={}
			logsInfo[IDF_CT]["log"]=os.path.basename(log)
			logsInfo[IDF_CT]["IDF_CT"]=IDF_CT
			logsInfo[IDF_CT]["NORME_CF"]=NORME_CF
			logsInfo[IDF_CT]["TYPEINV"]=TYPEINV
			logsInfo[IDF_CT]["perms"]=perms
			logsInfo[IDF_CT]["CHAIN_CT"]=chain
			logsInfo[IDF_CT]["param_Context_id"]=param_Context_id
			logsInfo[IDF_CT]["VERSION_9001"]=VERSION_9001
			
	return logsInfo		
						


def genPermIO(server,dbServer):
	fctPerms=getIdFctChain(dbServer)	
	chainJobs=getChainJobs(server)
	fChainPermIO=open(DCSV+"chainPermIO.csv","w")
	chainPerms={}
	for fctPerm in fctPerms:
		chain=fctPerm[2]
		PERMFIL_CT=fctPerm[1]
		if chain in chainJobs:
			for job in chainJobs[chain]:
				#print job, PERMFIL_CT
				isFind=False
				file="/scoromega_runnable_"+server+"/cmd/"+job+".cmd"
				if not os.path.exists(file): continue
				for line in open(file).readlines():
					if re.match(".*\${"+PERMFIL_CT+"}.*",line.strip().split("#")[0]) or re.match(".*\$"+PERMFIL_CT+"\s.*",line.strip().split("#")[0]):
						if re.match(".*_I[1-9]*=.*",line.strip().split("#")[0]) : 
							fChainPermIO.write("{0};{1};{2};{3}\n".format( chain,PERMFIL_CT,"I",line.strip()))
							chainPerms[(chain,PERMFIL_CT)]=("I",line.strip())
							isFind=True
							break
						else :
							if re.match(".*_O[1-9]*=.*",line.strip().split("#")[0]) : 
								fChainPermIO.write("{0};{1};{2};{3}\n".format( chain,PERMFIL_CT,"O",line.strip()))
								chainPerms[(chain,PERMFIL_CT)]=("O",line.strip())
								isFind=True
								break
							else : 
								if re.match(".*/INFILE\s.*",line.strip().split("#")[0]) : 
									fChainPermIO.write("{0};{1};{2};{3}\n".format( chain,PERMFIL_CT,"I",line.strip()))
									chainPerms[(chain,PERMFIL_CT)]=("I",line.strip())
									isFind=True
									break
								else : 
									if re.match(".*/OUTFILE\s.*",line.strip().split("#")[0]) : 
										fChainPermIO.write("{0};{1};{2};{3}\n".format( chain,PERMFIL_CT,"O",line.strip()))
										chainPerms[(chain,PERMFIL_CT)]=("O",line.strip())
										isFind=True
										break
									else:
										if re.match(".*cp .*\${"+PERMFIL_CT+"}$",line.split("#")[0].replace('"',"").strip()) or re.match(".*cp .*\$$"+PERMFIL_CT,line.split("#")[0].replace('"',"").strip())  : 
											fChainPermIO.write("{0};{1};{2};{3}\n".format( chain,PERMFIL_CT,"O",line.strip()))
											chainPerms[(chain,PERMFIL_CT)]=("O",line.strip())
											isFind=True
											break
										else:
											if re.match(".*cp .*\${"+PERMFIL_CT+"}\s+",line.split("#")[0].replace('"',"").strip()) or re.match(".*cp .*\$\s+"+PERMFIL_CT,line.split("#")[0].replace('"',"").strip())  : 
												fChainPermIO.write("{0};{1};{2};{3}\n".format( chain,PERMFIL_CT,"I",line.strip()))
												chainPerms[(chain,PERMFIL_CT)]=("I",line.strip())
												isFind=True
												break
				if isFind : break 
			if not isFind : fChainPermIO.write("{0};{1};{2};{3}\n".format( chain,PERMFIL_CT,"?",""))
	fChainPermIO.close()
	return chainPerms


#for chain in logsInfo:
#	print "\n",chain,logsInfo[chain]["log"],logsInfo[chain]["IDF_CT"],logsInfo[chain]["NORME_CF"],logsInfo[chain]["TYPEINV"]
#	for perm in logsInfo[chain]["perms"]:
#		print "\t", perm, logsInfo[chain]["perms"][perm][0], logsInfo[chain]["perms"][perm][1]
#print getChainJobs("aenitko2batch")
#genPermIo("aenitko2batch")

def getFiles(root,mask="*"):
	SRC_DIRECTORY_SAVE=root
	dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_SAVE),"svg_*"+mask+"*_ESCJ0000_PARM0.dat.gz")
	files={}
	for file in dirs:
		i=0
		cre_d=""
		for line in gzip.open(SRC_DIRECTORY_SAVE+"/"+file,"rb").readlines():
			matchCRE_D= re.match( r'CRE_D   (.*)', line.strip()) 
			if matchCRE_D :
				cre_d=matchCRE_D.group(1)
		if cre_d != "" :
			date=file.split("_")[1]
			if cre_d not in files : files[cre_d]={"date":date}
			dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_SAVE),"svg_*"+date+"*_ESCJ0000_PLAN*.dat.gz")
			for planFile in dirs : 
				plan=planFile.split("_")[4].split(".")[0]
				files[cre_d][plan]=planFile
	dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_SAVE),"svg_*"+mask+"*_ESCJ0000_PARM0.dat.gz")
	for file in dirs:
		i=0
		cre_d=""
		for line in gzip.open(SRC_DIRECTORY_SAVE+"/"+file,"rb").readlines():
			matchCRE_D= re.match( r'.*~PARM_CRE_D~(.*)', line.strip()) 
			if matchCRE_D :
				cre_d=matchCRE_D.group(1)
				break
		if cre_d != "" :
			date=file.split("_")[1]
			if cre_d not in files : files[cre_d]={"date":date}
			dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_SAVE),"svg_*"+date+"*_ESFJ0000_PLAN_IFRS17.dat.gz")
			for planFile in dirs : 
				files[cre_d]["PLAN"]=planFile
			dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_SAVE),"svg_*"+date+"*ESFJ0000_TI17PERMFIL.dat.gz")
			for permFile in dirs : 
				files[cre_d]["TI17PERMFIL"]=permFile
			
	return files

def getPlanEPO(server,site):
	SRC_DIRECTORY_PERM=os.environ.get('DPER', '')+"/perm/"
	dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_PERM),"*_ESCJ0000_PLAN_EPO.dat")
	planEPO={}
	for plan in dirs:
		f="PLAN_EPO"
		for line in open(SRC_DIRECTORY_PERM+"/"+plan).readlines():
				mtch=re.match('export EST_(.*)_GONOGO="Y"',line.strip())
				if mtch :
					CHAIN_CT=mtch.group(1)
					planEPO[CHAIN_CT]=f
	#return planEPO
	return {}

def getPlanESFJ0000(fileName):
	planESFJ0000={}
	for line in gzip.open(fileName,"rb").readlines():
		IDF_CT=line.strip().split("~")[3]
		planESFJ0000[IDF_CT]={}
		planESFJ0000[IDF_CT]["REQCOD_CT"]=line.strip().split("~")[0]
		planESFJ0000[IDF_CT]["CLOTYP_CT"]=line.strip().split("~")[1]
		planESFJ0000[IDF_CT]["CHAIN_CT"]=line.strip().split("~")[2]
		planESFJ0000[IDF_CT]["NORME_CF"]=line.strip().split("~")[4]

	return planESFJ0000
	
	
		
def getPlanESCJ0000(fileName,plan):
	plansESCJ0000 = {}
	for line in gzip.open(fileName,'rb').readlines():        
		mtch = re.match('export (.*)_(.*)_(.*)="(.*)"', line.strip())
		if mtch:
			CHAIN_CT = mtch.group(2)
			plansESCJ0000["CHAIN_CT"] = plan
	return plansESCJ0000		
	
def getPermESFJ0000(permFile):
	perms={}
	for line in gzip.open(permFile,"rb").readlines():
		IDF_CT=line.strip().split("~")[0]
		PERMFIL_CT=line.strip().split("~")[1]
		PATHPATTRN_LL=line.strip().split("~")[2]
		IO=line.strip().split("~")[3]
		perms[(IDF_CT,PERMFIL_CT)]=(PATHPATTRN_LL,IO)
	return perms


def getPlanification(rootSave,files,cre_d):
	PlanESFJ0000={}
	if "PLAN" in files[cre_d]: PlanESFJ0000=getPlanESFJ0000(rootSave+files[cre_d]["PLAN"])
	PlansESCJ0000={}
	if "PLAN0" in files[cre_d]: PlansESCJ0000.update(getPlanESCJ0000(rootSave+files[cre_d]["PLAN0"],"PLAN0"))
	if "PLAN1" in files[cre_d]: PlansESCJ0000.update(getPlanESCJ0000(rootSave+files[cre_d]["PLAN1"],"PLAN1"))
	if "PLAN2" in files[cre_d]: PlansESCJ0000.update(getPlanESCJ0000(rootSave+files[cre_d]["PLAN2"],"PLAN2"))
	if "PLAN3" in files[cre_d]: PlansESCJ0000.update(getPlanESCJ0000(rootSave+files[cre_d]["PLAN3"],"PLAN3"))
	if "PLAN4" in files[cre_d]: PlansESCJ0000.update(getPlanESCJ0000(rootSave+files[cre_d]["PLAN4"],"PLAN4"))

	PlanEPO={}#getPlanEPO(server,site)
	allPlan={}
	for IDF_CT in PlanESFJ0000:
		CHAIN_CT=PlanESFJ0000[IDF_CT]["CHAIN_CT"]
		allPlan[IDF_CT]=PlanESFJ0000[IDF_CT]
		if CHAIN_CT in PlansESCJ0000: 
			allPlan[IDF_CT]["OldPlan"]=PlansESCJ0000[CHAIN_CT]
			del PlansESCJ0000[CHAIN_CT]
		else:
			allPlan[IDF_CT]["OldPlan"]=''
		#print allPlan[IDF_CT]
	for CHAIN_CT in PlansESCJ0000:
		IDF_CT=CHAIN_CT
		if IDF_CT in  allPlan :
			allPlan[IDF_CT]["OldPlan"] = PlansESCJ0000[CHAIN_CT]
		else:
			allPlan[IDF_CT]={'REQCOD_CT': '', 'CLOTYP_CT': '', 'OldPlan': PlansESCJ0000[CHAIN_CT], 'NORME_CF': '', 'CHAIN_CT': CHAIN_CT}
	for CHAIN_CT in PlanEPO:
		IDF_CT=CHAIN_CT+"_POSE"
		allPlan[IDF_CT]={'REQCOD_CT': '', 'CLOTYP_CT': '', 'OldPlan': PlanEPO[CHAIN_CT], 'NORME_CF': '', 'CHAIN_CT': CHAIN_CT}
		
	
	if 	"ESID2060" in allPlan : allPlan["ESID2060_I4_PC___"] = allPlan["ESID2060"]
	if 	"ESID2550" in allPlan : allPlan["ESID2550_I4_PC___"] = allPlan["ESID2550"]
	if 	"ESID2560" in allPlan : allPlan["ESID2560_I4_PC___"] = allPlan["ESID2560"]
	if 	"ESID3800" in allPlan : allPlan["ESID3800_I4_PC_C__"] = allPlan["ESID3800"]
	if 	"ESID3800" in allPlan : allPlan["ESID3800_I4_PC_M__"] = allPlan["ESID3800"]
	if 	"ESID8700" in allPlan : allPlan["ESID8700_I4_PC___"] = allPlan["ESID8700"]
	
		#print allPlan[IDF_CT]
			
	return allPlan


	csvFile.close()


def dumpDataClosing(server,site,cre_d,serverDB,mask="*"):
	print "	----- dump: "+DPKL+"/logsInfo_"+server+"_"+site+"_"+cre_d+".pkl"
	logsInfo=getLogsInfos(server,site,cre_d,mask)
	with open(DPKL + "/logsInfo_"+server+"_"+site+"_"+cre_d+".pkl", 'wb') as f:
		pickle.dump(logsInfo, f, pickle.HIGHEST_PROTOCOL) 

#	print "	----- dump: "+DPKL+"/planification_"+server+"_"+site+"_"+cre_d+".pkl"
#	planification=getPlanification(server,site,cre_d)
#	with open(DPKL + "/planification_"+server+"_"+site+"_"+cre_d+".pkl", 'wb') as f:
#		pickle.dump(planification, f, pickle.HIGHEST_PROTOCOL) 
#
#	print "	----- dump: "DPKL+"/permIO.pkl"
#	permIO=genPermIO(server,serverDB)
#	with open(DPKL + "/permIO_"+server+"_"+site+"_"+cre_d+".pkl", 'wb') as f:
#		pickle.dump(permIO, f, pickle.HIGHEST_PROTOCOL) 
#		
#	listPerms={}
#	with  open("/scordata_aenitko2batch/ubas/perm/T_ESFJ0000_TI17PERMFIL.dat", "r") as f:
#		for line in f.readlines():
#			listPerms[(line.strip().split("~")[0],line.strip().split("~")[1])] = ((line.strip().split("~")[2],line.strip().split("~")[3])  )
#	with open("data/analyse/TI17PERMFIL_"+serverDB+"_"+site+"_"+cre_d+".pkl", 'wb') as f:
#			pickle.dump(listPerms, f, pickle.HIGHEST_PROTOCOL) 

	logsInfo=getLogsInfos(rootLog,rootPerm,site,cre_d,mask) 
	planification=getPlanification(rootSave,files,cre_d)
	PermTI17PERMFIL=getPermESFJ0000(rootSave+files[cre_d]["TI17PERMFIL"])


def closingStatus4(logsInfo, planification,PermTI17PERMFIL ,csvFileName) :
	csvFile=open(csvFileName, mode='w') 
	fieldnames = [
			"CHAIN_CT","PERMFIL_CT","IOFind","PATHPATTRN_LL","IO","pathI", "sizeInLogI", "dtInLogI", "sizeI", "createDateI","pathO", "sizeInLogO", "dtInLogO", "sizeO", "createDateO","IDF_CT","NORME_CF","TYPEINV","VERSION_9001","param_Context_id",\
			'REQCOD_CT', 'CLOTYP_CT','OldPlan','CHAIN_CT_OldPlan'\
	]	
							
	dialect = csv.excel
	dialect.delimiter = ";"
	dialect.lineterminator = "\n"
	writer = csv.DictWriter(csvFile, fieldnames=fieldnames, dialect=dialect)
	writer.writerow(dict((fn,fn) for fn in writer.fieldnames))

	#logsInfo=getLogsInfos(server,site,cre_d) 
	#planification=getPlanification(server,site,cre_d)
	#permIO=genPermIO(server,serverDB)
	#PermESFJ0000=getPermESFJ0000(server,site)
	#logsInfo=getLogsInfos("dcvcnvobbatch","as","20210326","ESPD2550")
	
	#root="/scordata_"+server+"/ub"+site+"/save/"
	#with open(DPKL+"/TI17PERMFIL_" +server+"_"+site+"_"+cre_d+".pkl", 'rb') as f:
	#	PermESFJ0000=pickle.load(f)
	#with open(DPKL +"/logsInfo_"     +server+"_"+site+"_"+cre_d+".pkl", 'rb') as f:
	#	logsInfo=pickle.load(f)
	with open(DPKL+"/permIO.pkl", 'rb') as f:
		permIO=pickle.load(f)
	#planification=getPlanification(server,site,cre_d)
	for elmnt in logsInfo:
		IDF_CT=elmnt
		#print elmnt ,"in logsInfo", logsInfo[IDF_CT]["CHAIN_CT"]
		CHAIN_CT=logsInfo[IDF_CT]["CHAIN_CT"]
		if IDF_CT in planification:
			REQCOD_CT=planification[IDF_CT]["REQCOD_CT"]
			CLOTYP_CT=planification[IDF_CT]["CLOTYP_CT"]
			OldPlan=planification[IDF_CT]["OldPlan"]
			CHAIN_CT_OldPlan=planification[IDF_CT]["CHAIN_CT"]
		else:
			REQCOD_CT=""
			CLOTYP_CT=""
			OldPlan=""
			CHAIN_CT_OldPlan=""
		for perm in logsInfo[elmnt]["perms"]:
			#print  "\t", CHAIN_CT, perm
			IO="?"
			IO_PermESFJ0000="?"
			PATHPATTRN_LL_PermESFJ0000="?"
			if (CHAIN_CT,perm) in permIO: IO = permIO[(CHAIN_CT,perm)][0]
			if (IDF_CT,perm) in PermTI17PERMFIL: 
				PATHPATTRN_LL_PermESFJ0000 = PermTI17PERMFIL[(IDF_CT,perm)] [0]	
				IO_PermESFJ0000 = PermTI17PERMFIL[(IDF_CT,perm)] [1]	
			writer.writerow({\
				"CHAIN_CT":CHAIN_CT, \
				"PERMFIL_CT":perm, \
				"IOFind":IO ,\
				"PATHPATTRN_LL":PATHPATTRN_LL_PermESFJ0000, \
				"IO":IO_PermESFJ0000,\
				"pathI":		logsInfo[IDF_CT]["perms"][perm]["pathI"]				,\
				"sizeInLogI":		logsInfo[IDF_CT]["perms"][perm]["sizeInLogI"]			,\
				"dtInLogI":	logsInfo[IDF_CT]["perms"][perm]["dtInLogI"]		,\
				"sizeI"		:	logsInfo[IDF_CT]["perms"][perm]["sizeI"]				,\
				"createDateI":	logsInfo[IDF_CT]["perms"][perm]["dtI"]			,\
				"pathO":		logsInfo[IDF_CT]["perms"][perm]["pathO"]				,\
				"sizeInLogO":		logsInfo[IDF_CT]["perms"][perm]["sizeInLogO"]			,\
				"dtInLogO":	logsInfo[IDF_CT]["perms"][perm]["dtInLogO"]		,\
				"sizeO"		:	logsInfo[IDF_CT]["perms"][perm]["sizeO"]				,\
				"createDateO":	logsInfo[IDF_CT]["perms"][perm]["dtO"]			,\
				"IDF_CT":IDF_CT,\
				"NORME_CF":logsInfo[IDF_CT]["NORME_CF"],\
				"TYPEINV":logsInfo[IDF_CT]["TYPEINV"],\
				"VERSION_9001":logsInfo[IDF_CT]["VERSION_9001"],\
				"param_Context_id":logsInfo[IDF_CT]["param_Context_id"],\
				"REQCOD_CT":REQCOD_CT,\
				"CLOTYP_CT":CLOTYP_CT,\
				"OldPlan":OldPlan,\
				"CHAIN_CT_OldPlan":CHAIN_CT_OldPlan\
			})
			#print elmnt,planification[elmnt] , logsInfo[elmnt]["perms"][perm]
#		for perm in logsInfo[elmnt]["perms"]:
#	for perm in permIO:
#		print perm , permIO[perm]
#
	csvFile.close()
	return csvFileName


def addStringValue(value,sep=","):
	if value =="": return "NULL"+sep
	return "'" + value + "'"+sep
def csvToSql(csvFileName, sqlFileName,dbclo,server,site):
	csvFile=open(csvFileName, mode='r') 
	dialect = csv.excel
	dialect.delimiter = ";"
	dialect.lineterminator = "\n"

	csv_reader = csv.DictReader(csvFile,dialect=dialect)
	line_count = 0
	
	sqlFile=open(sqlFileName, mode='wt') 
	
	
	sqlFile.write("USE BTRAV\n")
	sqlFile.write("go \n")
	sqlFile.write("delete TCLOS_REPORT where server='{0}' and  DBCLO_D = '{1}' and SITE = '{2}'\n".format(server,dbclo,site))
	for row in csv_reader:
		sqlFile.write("insert into TCLOS_REPORT values( " +addStringValue(server) \
		+ 									 addStringValue(dbclo) \
		+ 									 addStringValue(site) \
		+ 									 addStringValue(row["CHAIN_CT"]) \
		+ 									 addStringValue(row["PERMFIL_CT"]) \
		+ 									 addStringValue(row["IOFind"]) \
		+ 									 addStringValue(row["PATHPATTRN_LL"]) \
		+ 									 addStringValue(row["IO"]) \
		+ 									 addStringValue(row["pathI"]) \
		+ 									 addStringValue(row["sizeInLogI"]) \
		+ 									 addStringValue(row["dtInLogI"]) \
		+ 									 addStringValue(row["sizeI"]) \
		+ 									 addStringValue(row["createDateI"]) \
		+ 									 addStringValue(row["pathO"]) \
		+ 									 addStringValue(row["sizeInLogO"]) \
		+ 									 addStringValue(row["dtInLogO"]) \
		+ 									 addStringValue(row["sizeO"]) \
		+ 									 addStringValue(row["createDateO"]) \
		+ 									 addStringValue(row["IDF_CT"]) \
		+ 									 addStringValue(row["NORME_CF"]) \
		+ 									 addStringValue(row["TYPEINV"]) \
		+ 									 addStringValue(row["VERSION_9001"]) \
		+ 									 addStringValue(row["param_Context_id"]) \
		+ 									 addStringValue(row["REQCOD_CT"]) \
		+ 									 addStringValue(row["CLOTYP_CT"]) \
		+ 									 addStringValue(row["OldPlan"]) \
		+ 									 addStringValue(row["CHAIN_CT_OldPlan"],")") +"\n")
		line_count += 1
	sqlFile.write("go \n")


chainsList=getResultSet("SELECT  distinct job  FROM BTRAV..ITK_VTOM_CLOS")
#print chainsList
#dest= sys.argv[1]
sitesList=["eu"]
sitesList=["as"]
serversList=["aenuato2batch"]
serversList=["aenitko2batch","aenuato2batch","aenprdo2batch"]#"aeninto2batch","dcvin2obbatch"]
serversList=["aeninto2batch"]
sitesList=["eu"]
serversList=["aeninto2batch","dcvin2obbatch"]
#serversList=["aenitko2batch"]
sitesList=["as", "am", "eu"]
for server in serversList:
	for site in ["as", "am", "eu"]:
		rootSave="/scordata_"+server+"/ub"+site+"/save/"
		rootLog="/scordata_"+server+"/ub"+site+"/log/"
		rootPerm="/scordata_"+server+"/ub"+site+"/perm/"
		files=getFiles(rootSave)#,"20210503111820")
		#pprint(files)
		for cre_d in files:
			if cre_d < dateMin : continue 
			if cre_d > dateMax : continue 
			mask=files[cre_d]["date"][0:8]
			csvFileName=DCSV+'/closingStatus_{0}_{1}_{2}.csv'.format(str(cre_d),server,site)
			sqlFileName=DCSV+'/closingStatus_{0}_{1}_{2}.sql'.format(str(cre_d),server,site)
			print cre_d, mask , csvFileName
			logsInfo=getLogsInfos(rootLog,rootPerm,site,cre_d)#,"_ESID2000_AEnIntO2Batch_2021050313") 
			planification=getPlanification(rootSave,files,cre_d)
			PermTI17PERMFIL={}
			if "TI17PERMFIL" in files[cre_d]:PermTI17PERMFIL=getPermESFJ0000(rootSave+files[cre_d]["TI17PERMFIL"])
			#permIO=genPermIO(server,serverDB)
			closingStatus4(logsInfo, planification,PermTI17PERMFIL ,csvFileName)
			csvToSql(csvFileName,sqlFileName,cre_d,server,site)
			cmd="isql -Ubatch -SDEV_TPO2 -Pomega2-- -eerr -i{0} -o{1}".format(sqlFileName,dest+"/log")
			#os.system(cmd ) 

#pprint(getLogsInfos("/scordata_aeninto2batch/ubeu/log/","/scordata_aeninto2batch/ubeu/perm/","eu","20210519","STAD1500")) 
#getLogsInfos("/scordata_aeninto2batch/ubeu/log/","/scordata_aeninto2batch/ubeu/perm/","eu","20210519","ESID2000")
