#! /usr/bin/python3
##########     export LC_ALL='en_US.utf8'
import time
import xmltodict
import xml.etree.ElementTree as ET
from pprint import pprint
import json,os,re,sys
import locale
from pathlib import Path
import glob

os.environ["PYTHONIOENCODING"] = "utf-8"
myLocale=locale.setlocale(category=locale.LC_ALL, locale="en_GB.UTF-8")

def execQuery(SRV,query):
	print ("\n...... ", query)
	#cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Ubatch -S'+SRV.upper()+'_TPO2 -c to /tmp/ -Jiso_1 -P"omega2--" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log' +  ' 2>&1' 
	#print (cmd) 
	cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Udom_gen_ro -S'+SRV.upper()+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log'  
	print (cmd)
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

def parseVtom(xmlFile):
	txt=(open(xmlFile, "r",encoding='iso-8859-15').read())
	doc=xmltodict.parse(txt)
	#return (json.dumps(doc))
	return (json.loads(json.dumps(doc)))
	#return (doc)

def paramJob(job):
	#print("\t\t", job["@name"],job['Script'].replace("#$DCMD/","").replace(".cmd",""))
	Parameters=""
	if "Parameters" in job :
		parmaters=job["Parameters"]["Parameter"]
		if isinstance(parmaters,list) :
			for p in parmaters :
				#print("\t\t\t", p)
				Parameters += " " + p
		else :
			#print("\t\t\t", parmaters)
			Parameters += " " + parmaters
	return Parameters
#pprint(res)

#for domain in res:
#	print (domain)
#	for r in res["Domain"]["Resources"]:
#		print ("\t",r)
		
#pprint (res["Domain"]["Environments"])

 
#for app in res["Domain"]["Environments"] ["Environment"] ["Applications"]["Application"][1] :
#	pprint (app ) 

def writeBCP(fp,env,job,appName,comment,IDF_CT,VNORME,VTYPEAOC):
	chain=job['Script'].replace("#$DCMD/","").replace(".cmd","") 
	if not chain.endswith("0") : return 
	if chain.startswith("ESL") : VNORME="I4I"
	if VNORME != "" and IDF_CT == "" : IDF_CT=chain
	#print (job['Script'])
	#print(chain)
	if "@comment" in job: comment =job["@comment"] 
	#print('IDF_CT 1:',IDF_CT)
	if job["@name"].startswith("EOMA"):
		params=paramJob(job).replace("$(echo $VNORME)",VNORME).replace('$(echo $TOM_JOB | cut -d"_" -f2)',chain)
		if len (params.strip().split(" "))  > 1 : IDF_CT =params.strip().split(" ")[1].strip()
		#print('IDF_CT 2 :',IDF_CT ,";", params,";",job["@name"],";",chain,";",VNORME			)
		fp.write("""{env}~{appname}~{title}~{chain}~{params}~{IDF_CT}~{VNORME}~{VTYPEAOC}~{comment}\n""".format(
			env=env,
			appname=appName, 
			title=job["@name"],
			chain=chain, 
			params=params.strip().replace("=",chain+".env"),
			IDF_CT=IDF_CT,
			VNORME=VNORME ,
			VTYPEAOC=VTYPEAOC,
			comment=comment))
			
def parseXmlVtom(fp,env,xmlFile) : 
	print("-----------------------------------\n",xmlFile)
	res=parseVtom(xmlFile)
	for i in range(len(res["Domain"]["Environments"] ["Environment"] ["Applications"]["Application"])):
		Application = res["Domain"]["Environments"] ["Environment"] ["Applications"]["Application"][i]
		appName=Application["@name"]
		v={}
		VNORME=""
		VTYPEAOC=""
		comment=""
		IDF_CT=""
		#{'Variable': {'@name': 'VNORME', '@value': 'I17G'}}
		#<Parameter><![CDATA[$(echo $VNORME)_ESFD2220___$(echo $VTYPEAOC)]]></Parameter>
		if 'Variables' in Application : 
			Variables=Application['Variables' ] 	
			#print(Application["@name"],Variables)
			if isinstance(Variables,dict) :
				if isinstance(Variables['Variable'],list) :
					for v in Variables['Variable']:
						if v['@name'] == 'VNORME' :   VNORME = v['@value']
						if v['@name'] == 'VTYPEAOC' : VTYPEAOC = v['@value']
				else:
					if Variables['Variable']['@name'] == 'VNORME' :   VNORME = Variables['Variable']['@value']
					if Variables['Variable']['@name'] == 'VTYPEAOC' : VTYPEAOC = Variables['Variable']['@value']
			#print(Application["@name"],VNORME, VTYPEAOC)
			
		if "Jobs" in Application and appName.startswith("EOMA") :
			jobs=Application["Jobs"]
			if isinstance(jobs,dict) :
				comment=""
				if isinstance(jobs['Job'],list) :
					l=len(jobs['Job'])
					for j in range(l):
						job=jobs['Job'][j]
						writeBCP(fp,env,job,appName,comment,IDF_CT,VNORME,VTYPEAOC)
				else:
					if "@name" in jobs['Job'] :
						job=jobs['Job']
						writeBCP(fp,env,job,appName,comment,IDF_CT,VNORME,VTYPEAOC)
	
def extractVtomXml():
	fp = open(os.environ.get('DFILT')+"/vtom.dat","w", encoding='utf-8')
	parseXmlVtom(fp,"DEV","/scor/OmegaDomain/exportVTOM/DEV_GOM_DEVBATCH_R.xml")
	parseXmlVtom(fp,"IN2","/scor/OmegaDomain/exportVTOM/IN2_GOM_BATCH_N.xml")
	parseXmlVtom(fp,"INT","/scor/OmegaDomain/exportVTOM/INT_GOM_BATCH_N.xml")
	parseXmlVtom(fp,"PRD","/scor/OmegaDomain/exportVTOM/PRD_GOM_BATCH_N.xml")
	parseXmlVtom(fp,"MAI","/scor/OmegaDomain/exportVTOM/MAI_GOM_MAIBATCH_N.xml")
	parseXmlVtom(fp,"UA2","/scor/OmegaDomain/exportVTOM/UA2_GOM_UA2BATCH_N.xml")
	parseXmlVtom(fp,"CNV","/scor/OmegaDomain/exportVTOM/CNV_GOM_CNVBATCH_N.xml")
	parseXmlVtom(fp,"UAT","/scor/OmegaDomain/exportVTOM/UAT_GOM_BATCH_N.xml")
	parseXmlVtom(fp,"ITK","/scor/OmegaDomain/exportVTOM/ITK_GOM_BATCH_N.xml")
	fp.close()
	
def chainsJobstoDico(env0,file):
	lines=open(file, "r").readlines()
	#pprint(lines)
	chains={}
	for line in lines:
		env=line.strip().split(";")[0]
		chain=line.strip().split(";")[0]
		job=line.strip().split(";")[1]
		if env != env0 : continue
		if job == "ESCD9001" or job == "ESFD9001" : continue
		if chain not in chains : chains[chain]=[job]
		else:
			if job not in chains[chain]: chains[chain] += [job]
	#pprint (chains)
	return chains

def checkPermInChain(env,jobs,PERMFIL_CT):
	#print("env;",env)
	if env.lower() == "dev":
		root="/scor/scoromega/runnable/cmd/"
	else:
		root="/scoromega_runnable_aen"+env.lower()+"o2batch/cmd/"
		
	#print("root:",root)
	#print (jobs)
	r="\$\{*"+PERMFIL_CT+"\}*[\s\"\`]*"
	for job in jobs:
		
		#print(PERMFIL_CT,root+chain+".cmd",job+".cmd")
		lines=open(root+job+".cmd",  "r", encoding='latin-1').readlines()
		for i in range(len(lines)):
			lines[i]=lines[i].split('#')[0].strip()
			
		for line in lines:
			if re.search(r, line): 
				#print( line)
				l=line.split('#')[0].strip()
				if not l.startswith("LIBEL=") and l != "" and not  l.startswith("ECHO_LOG"):
					finds=job+";"+PERMFIL_CT+";"+line.strip()
					return True
	return False

def checkAllPermInChain(env,chain0=""):
	file_path = os.path.dirname(os.path.realpath(__file__))
	chains=chainsJobstoDico(env,os.getenv("DFILT")+"/chainsJobs.dat")
	#pprint(chains)
	if chain0 =="" :
		print("\n----------------------------------- files not used in {env} environment ----------------------------- ".format(env=env))
		for chain in chains:
			perms=getResultSet(env,"""
							select PERMFIL_CT from BEST..TI17PERMFIL where IDF_CT in (
							select IDF_CT from BEST..TI17FNC where CHAIN_CT = '{chain}')
				""".format(chain=chain))
			#print( perms)
			ret=False
			notPerm="???"
			for perm in perms:
				ret=checkPermInChain(env.lower(),chains[chain]+[chain],perm[0]) 
				#print("retour checkPemInChain:",chain,perm[0], ret)
				if ret : 
					break
				notPerm=perm[0]
				if not ret : print (chain,";",chains[chain]+[chain],";",notPerm)
	else:
		
		perms=getResultSet(env,"""
					select * from BEST..TI17PERMFIL where IDF_CT in (
					select IDF_CT from BEST..TI17FNC where CHAIN_CT = '{chain}')
		""".format(chain=chain0))
		
		jobs=getResultSet("DEV","""
					select JOB from BTRAV..TCHK_CHAINS_JOBS 
					where CHAIN = '{chain}' 
					and env='{env}' 
					order by 1
		""".format(chain=chain0,env=env))

		
		#print( perms)
		ret=False
		notPerm="???"
		print ("\n------------------------ Chain[jobs]: ------------------------------------")
		print(chain0)
		print(jobs)
		
		print ("\n------------------------ TI17PERMFIL: ------------------------------------")
		for perm in perms:
			print (perm)

		print ("\n------------------------ Ecart : ------------------------------------")
		for perm in perms:
			ret=checkPermInChain(env.lower(),chains[chain0]+[chain0],perm[1]) 
			#print("retour checkPemInChain:",chain,perm[0], ret)
			if ret : 
				break
			notPerm=perm[1]
			if not ret : print (notPerm)
		
		print ("\n---------------------------------------------------------------------\n")
		
def parseVtom(xmlFile,site):
	if site=="eu" : oma= "EOMA"
	if site=="as" : oma= "AOMA"
	if site=="am" : oma= "UOMA"
	
	txt=(open(xmlFile, "r",encoding='iso-8859-15').read())
	doc=xmltodict.parse(txt)
	dico =json.loads(json.dumps(doc))
	apps={}
	for app in dico["Domain"]["Environments"]["Environment"]["Applications"]["Application"]:
		v=app["@name"].split("_")
		if v[0]==oma and  re.match(r'^CLOS|^INC|^MIC', v[1]) : #v[1].startswith( "CLOS") :  
			app_name= v[1]+"_"+v[2]
			apps[app_name]={}
			apps[app_name]["VTYPEAOC"]=""
			apps[app_name]["VNORME"]=""
			apps[app_name]["jobs"]=[]
			if "Variables" in app :
				for var in app["Variables"]:
					tab_var=app["Variables"][var]
					if(type(tab_var) == dict): 	tab_var= [tab_var]
					for elt in tab_var :
						apps[app_name][elt["@name"]]=elt["@value"]
			tab_job=app["Jobs"]["Job"]
			if(type(tab_job) == dict): 	tab_job= [tab_job]
			for job in tab_job:
				v=job["@name"].split("_")
				job_name= v[1]+"_"+v[2]
				idf_ct = ""
				if 'Parameters' in job and type(job['Parameters']['Parameter']) == list and len(job['Parameters']['Parameter']) > 1    :
					idf_ct=job['Parameters']['Parameter'][1]
					idf_ct=idf_ct.replace("$(echo $VNORME)",apps[app_name]["VNORME"])
					idf_ct=idf_ct.replace("$(echo $VTYPEAOC)",apps[app_name]["VTYPEAOC"])
					idf_ct=idf_ct.replace('$(echo $TOM_JOB | cut -d"_" -f2)',v[1])	
				apps[app_name]["jobs"].append({ 'name': job_name,"chain":v[1],"IDF_CT":idf_ct})
				#print("-----------------------------")
				# pprint(job)
				#apps[app_name][job_name]["Parameters"]=job["Parameters"]["Parameter"]
				
	#pprint (apps)
	chains=[]
	for app in apps:
		for	job in apps[app]["jobs"]:
			#for chain in apps[app][job]:
			job["app"]=app
			job["VNORME"]=apps[app]["VNORME"]
			job["VTYPEAOC"]=apps[app]["VTYPEAOC"]
			
			if ( job["name"][:2] in ["ES","EX","ST"] and job["chain"][-1:] == "0"):
				chains.append(job)
				

	#pprint(apps["INCEPI17G_D2"])
	return (chains)
def newest(chain,IDF_CT,pref,env):
	masq=f"/scordata_aen{env}o2batch/ubeu/log/{pref}_{chain}*log"
	list_of_files = glob.glob(masq) 
	newestLog=""
	if (list_of_files ):
		latest_file = max(list_of_files, key=os.path.getmtime)
		tm=os.path.getctime(latest_file) 
		newestLog= latest_file
		#print(f"{latest_file} {IDF_CT} {tm}")
	return newestLog
	# else :
	# 	print(f"not found :{masq}, {IDF_CT}")

def getStartTimeClosing(masq):
	
	list_of_files = glob.glob(masq)
	tm=""
	if (list_of_files ):
		latest_file = max(list_of_files, key=os.path.getmtime)
		tm=os.path.getctime(latest_file) 
		#print(f"{latest_file}  {tm}")
	return tm

def logsList(env,site):
	envU=env.upper()
	pref="T"
	if env == "prd" : pref="P"
	if env == "cnv" : pref="C"
	if env == "dev" : pref="D"

	if env == "ua2" : xmlVtomFile="/scor/OmegaDomain/exportVTOM/UA2_GOM_UA2BATCH_N.xml"
	if env == "dev" : xmlVtomFile="/scor/OmegaDomain/exportVTOM/DEV_GOM_DEVBATCH_R.xml"
	if env == "in2" : xmlVtomFile="/scor/OmegaDomain/exportVTOM/IN2_GOM_BATCH_N.xml"
	if env == "int" : xmlVtomFile="/scor/OmegaDomain/exportVTOM/INT_GOM_BATCH_N.xml"
	if env == "itk" : xmlVtomFile="/scor/OmegaDomain/exportVTOM/ITK_GOM_BATCH_N.xml"
	if env == "prd" : xmlVtomFile="/scor/OmegaDomain/exportVTOM/PRD_GOM_BATCH_N.xml"
	if env == "mai" : xmlVtomFile="/scor/OmegaDomain/exportVTOM/MAI_GOM_MAIBATCH_N.xml"
	if env == "uat" : xmlVtomFile="/scor/OmegaDomain/exportVTOM/UAT_GOM_BATCH_N.xml"
	if env == "cnv" : xmlVtomFile="/scor/OmegaDomain/exportVTOM/CNV_GOM_CNVBATCH_N.xml"

	chains= parseVtom(xmlVtomFile,site)



	dateESCJ000=getStartTimeClosing(masq=f"/scordata_aen{env}o2batch/ub{site}/log/{pref}_ESCJ0000_*log")
	if dateESCJ000 == "" :
		print( "\n Error: ESCJ0000 not run \n")
		return []
	chainsStatus="Waiting"
	ret=[]
	for chain in chains:
		newestLog= newest(chain["chain"],chain["IDF_CT"],pref,env)
		chain["log"]=newestLog
		chain["status"]="Waiting"
		if ( newestLog != ""):
			tm=os.path.getctime(newestLog)
			if (  dateESCJ000 <= tm):
				chain["status"]=chainStatus(newestLog,pref,chain["chain"])
			ret.append(chain)
	return ret 




def chainStatus(log,pref,chain):
	status="Waiting"
	for line in open(log,encoding='iso-8859-15').readlines():
		if re.match(f"# End of Chain :  {pref}_{chain}.* Failed" , line):
			status="Failed"
		else:
			if re.match(f"# End of Chain :  {pref}_{chain}.* Succeeded" , line):
				status="Succeeded"
	return status

			
if __name__ == '__main__':
	# env=chain=""
	# if  len (sys.argv) >= 2 : env = sys.argv[1]
	# if  len (sys.argv) >= 3 : chain = sys.argv[2]
	#
	# parseVtom("/scor/OmegaDomain/exportVTOM/ITK_GOM_BATCH_N.xml")
	#logsList("uat","eu")
	for log in logsList("itk","eu"):
		if log['status'] not in ["Succeeded"] :
			pprint(log)
	#checkFailed('ESFD3920',"I17G_NDC_ALL_INI","T","itk")
	#newest('ESFD3920',"I17G_NDC_ALL_INI","T","itk")
	#print( time.ctime(getStartTimeClosing(masq=f"/scordata_aenuato2batch/ubeu/log/T_ESCJ0000_*log")) )