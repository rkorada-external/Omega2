#! /usr/bin/python2.7
import os, sys, re, gzip, pickle,fnmatch,csv ,subprocess,glob
from pprint import pprint

DSAVE = os.environ.get('DSAVE')
DCSV = os.environ.get('DCSV')
DPKL = os.environ.get('DPKL')
SERVER = os.environ.get('SERVER')
SITE = os.environ.get('SITE')


dialect = csv.excel
dialect.delimiter = ";"
dialect.lineterminator = "\n"


#FILENAME = sys.argv[1]
#DATE = sys.argv[2]
##PLAN = sys.argv[3]
#CRE_D = sys.argv[3]
#
#pklFileName = "{DPKL}/PLANS_{SERVER}_{SITE}_{CRE_D}.pkl".format(DPKL=DPKL, SERVER=SERVER, SITE=SITE, CRE_D=CRE_D)

listCOND=[\
    ('STAD1500','COND3'), \
    ('STAD7500','COND1'), \
    ('ESID0060','COND4'), \
    ('STAD1550','COND1'), \
    ('DWPD0010','COND2'), \
    ('DWPD0010','COND1'), \
    ('ESFD2000','COND1'), \
    ('ESID0060','COND3'), \
    ('ESID1520','COND1'), \
    ('ESID1550','COND1'), \
    ('ESID1800','COND1'), \
    ('ESID2000','COND1'), \
    ('ESID2010','COND1'), \
    ('ESID2060','COND1'), \
    ('ESID2500','COND1'), \
    ('ESID2500','COND2'), \
    ('ESID2560','COND1'), \
    ('ESID2800','COND1'), \
    ('ESID3800','COND1'), \
    ('ESID3800','COND2'), \
    ('ESID3800','COND3'), \
    ('ESID7000','COND2'), \
    ('ESID7000','COND3'), \
    ('ESID8000','COND2'), \
    ('ESLD8830','COND1'), \
    ('ESPD2000','COND1'), \
    ('ESPD2000','COND3'), \
    ('ESPD2500','COND1'), \
    ('ESPD2500','COND2'), \
    ('ESPD2550','COND2'), \
    ('ESPD2550','COND3'), \
    ('ESPD3700','COND1'), \
    ('ESPD3850','COND1'), \
    ('ESPD3860','COND1'), \
    ('ESPD8830','COND1'), \
    ('ESID0060','COND1'), \
    ('ESID0080','COND1'), \
    ('ESID0080','COND3'), \
    ('ESID0560','COND1'), \
    ('ESID3900','COND2'), \
    ('ESID7000','COND1'), \
    ('ESID7050','COND1'), \
    ('ESID7050','COND2'), \
    ('ESID8000','COND1'), \
    ('ESID8060','COND1'), \
    ('ESPD2900','COND2'), \
    ('ESPD3800','COND1'), \
    ('ESPD3800','COND2'), \
    ('ESPD3800','COND3'), \
    ('ESPD3800','COND5'), \
    ('ESPD3800','COND4'), \
    ('ESPD3900','COND2'), \
    ('ESPD8830','COND2'), \
    ('STAD1500','COND1'), \
    ('STAD1500','COND2')  \
    ]       

def pickleDump(fileName, data):
    with open(fileName, 'wb') as f:
        pickle.dump(data, f, pickle.HIGHEST_PROTOCOL) 

def pickleLoad(fileName):
    with open(fileName, 'rb') as f:
        return pickle.load(f)

def pickleAppend(fileName, data):
    fullData = {}

    if os.path.exists(fileName):
        fullData = pickleLoad(fileName)
    
    fullData.update(data)
    pickleDump(fileName, fullData)

def getPlanESCJ0000(fileName,plan,cre_d):
	plansESCJ0000 = {}
	for line in gzip.open(fileName,'rb').readlines():        
		mtch = re.match('export (.*)_(.*)_(.*)="(.*)"', line.strip())
		if mtch:
			CHAIN_CT = mtch.group(2)
			TYPE = mtch.group(3)
			VALUE = mtch.group(4)
			key = "_".join([ plan, cre_d, CHAIN_CT, TYPE])
			if  (CHAIN_CT,TYPE) in listCOND or (TYPE == "GONOGO" and VALUE.replace('"','') == "Y") :
				plansESCJ0000[key] = {}
				plansESCJ0000[key]["CRE_D"] = cre_d
				plansESCJ0000[key]["CHAIN_CT"] = CHAIN_CT
				plansESCJ0000[key]["IDF_CT"] = CHAIN_CT
				plansESCJ0000[key]["TYPE"] = TYPE
				plansESCJ0000[key]["VALUE"] = VALUE.replace('"','')
				plansESCJ0000[key]["PLAN"] = plan

	return plansESCJ0000

def getPlanESFJ0000(fileName,plan,cre_d):
    plansESFJ0000 = {}

    for line in gzip.open(fileName,'rb').readlines():        
        mtch = re.match( r'export EST_(.*)=(.*)', line.strip())  
        if mtch:
            VALUE = mtch.group(2)
            grp = mtch.group(1).split("_", 1)
            CHAIN_CT = grp[0]
            IDF_CT = grp[-1].rsplit("_", 1)[0]
            TYPE = grp[-1].rsplit("_", 1)[-1]

            key = "_".join([plan, cre_d, CHAIN_CT, IDF_CT, TYPE])
            plansESFJ0000[key] = {}
            plansESFJ0000[key]['CRE_D'] = cre_d
            plansESFJ0000[key]['CHAIN_CT'] = CHAIN_CT
            plansESFJ0000[key]['IDF_CT'] = IDF_CT
            plansESFJ0000[key]['TYPE'] = TYPE
            plansESFJ0000[key]['VALUE'] = VALUE.replace('"','')
            plansESFJ0000[key]['PLAN'] = plan
    
    return plansESFJ0000




def getFiles(root):
	SRC_DIRECTORY_SAVE=root
	dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_SAVE),"svg_*_ESCJ0000_PARM0.dat.gz")
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
	dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_SAVE),"svg_*_ESFJ0000_PARM.dat.gz")
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
			dirs=fnmatch.filter(os.listdir(SRC_DIRECTORY_SAVE),"svg_*"+date+"*_ESFJ0000_PLAN.dat.gz")
			for planFile in dirs : 
				plan=planFile.split("_")[4].split(".")[0]
				files[cre_d][plan]=planFile
			
	return files


def csvDump(fileName, data):
    fieldnames = ['CRE_D', 'CHAIN_CT', 'IDF_CT', 'TYPE', 'VALUE', 'PLAN']

    with open(fileName, mode='w') as f:
        csvFile = csv.DictWriter(f, fieldnames=fieldnames, dialect=dialect)
        csvFile.writerow(dict((fn,fn) for fn in csvFile.fieldnames))

        for key, value in data.items():
            csvFile.writerow(value)

def csvToSql(csvFileName, sqlFileName,cre_d,server,site):
    with open(sqlFileName, mode='wt') as sqlFile:
        with open(csvFileName, mode='r') as csvFile:
            csvRead = csv.DictReader(csvFile, dialect=dialect)
            sqlFile.write("USE BTRAV\n")
            sqlFile.write("go \n")
            sqlFile.write('delete BTRAV..TPLANS where SERVER="{SERVER}" and SITE_CT="{SITE}" and CRE_D="{CRE_D}"\n'.format(CRE_D=cre_d, SERVER=server, SITE=site))

            for row in csvRead:
                sqlFile.write('insert into BTRAV..TPLANS values("{0}", "{1}", "{CRE_D}", "{CHAIN_CT}", "{IDF_CT}", "{TYPE}", "{VALUE}", "{PLAN}")\n'.format(server, site, **row))
            sqlFile.write("go \n")





def insertPlan(server,site,dest):
	root="/scordata_"+server+"/ub"+site+"/save/"
	files=getFiles(root)
	for cre_d in files:
		plans={}
		if "PLAN"  in files[cre_d]: plans.update(getPlanESFJ0000(root+files[cre_d]["PLAN"],"PLAN",cre_d))
		if "PLAN0" in files[cre_d]: plans.update(getPlanESCJ0000(root+files[cre_d]["PLAN0"],"PLAN0",cre_d))
		if "PLAN1" in files[cre_d]: plans.update(getPlanESCJ0000(root+files[cre_d]["PLAN1"],"PLAN1",cre_d))
		if "PLAN2" in files[cre_d]: plans.update(getPlanESCJ0000(root+files[cre_d]["PLAN2"],"PLAN2",cre_d))
		if "PLAN3" in files[cre_d]: plans.update(getPlanESCJ0000(root+files[cre_d]["PLAN3"],"PLAN3",cre_d))
		if "PLAN4" in files[cre_d]: plans.update(getPlanESCJ0000(root+files[cre_d]["PLAN4"],"PLAN4",cre_d))
		csvFileName = "{DCSV}/PLANS_{SERVER}_{SITE}_{CRE_D}.csv".format(DCSV=dest+"/csv", SERVER=server, SITE=site, CRE_D=cre_d)
		sqlFileName = "{DSQL}/PLANS_{SERVER}_{SITE}_{CRE_D}.sql".format(DSQL=dest+"/sql", SERVER=server, SITE=site, CRE_D=cre_d)
		#pprint(plans)
		#print sqlFileName
		csvDump(csvFileName, plans)
		csvToSql(csvFileName, sqlFileName,cre_d,server,site)
		cmd="isql -Ubatch -SDEV_TPO2 -Pomega2-- -eerr -i{0} -o{1}/err.log ".format(sqlFileName,dest)
		os.system(cmd) 

#dest= "data/analyse"
dest= sys.argv[1]
sitesList=["as", "am", "eu"]
serversList=["dcvin2obbatch"] 
serversList=["aenitko2batch","aenuato2batch","aenprdo2batch"]#,"aeninto2batch","dcvin2obbatch"]
serversList=["aeninto2batch","dcvin2obbatch"]
#serversList=["aenitko2batch"]
sitesList=["as", "am", "eu"]
for server in serversList:
	for site in ["as", "am", "eu"]:
		insertPlan(server,site,dest)