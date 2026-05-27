#! /usr/bin/python2.7
import os, sys, re, gzip, pickle
from pprint import pprint

DSAVE = os.environ.get('DSAVE')
DCSV = os.environ.get('DCSV')
DPKL = os.environ.get('DPKL')
SERVER = os.environ.get('SERVER')
SITE = os.environ.get('SITE')

FILENAME = sys.argv[1]
DATE = sys.argv[2]
PLAN = sys.argv[3]
CRE_D = sys.argv[4]

pklFileName = "{DPKL}/PLANS_{SERVER}_{SITE}_{CRE_D}.pkl".format(DPKL=DPKL, SERVER=SERVER, SITE=SITE, CRE_D=CRE_D)

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

def getPlanESCJ0000(fileName):
    plansESCJ0000 = {}

    for line in gzip.open(fileName,'rb').readlines():        
        mtch = re.match('export (.*)_(.*)_(.*)="(.*)"', line.strip())
        if mtch:
            CHAIN_CT = mtch.group(2)
            TYPE = mtch.group(3)
            VALUE = mtch.group(4)
            key = "_".join([DATE, PLAN, CRE_D, CHAIN_CT, TYPE])

            for l in listCOND:
                if (l[0] == CHAIN_CT and l[1] == TYPE) or (TYPE == "GONOGO"):
                    plansESCJ0000[key] = {}
                    plansESCJ0000[key]["CRE_D"] = CRE_D
                    plansESCJ0000[key]["CHAIN_CT"] = CHAIN_CT
                    plansESCJ0000[key]["IDF_CT"] = ""
                    plansESCJ0000[key]["TYPE"] = TYPE
                    plansESCJ0000[key]["VALUE"] = VALUE
                    plansESCJ0000[key]["PLAN"] = PLAN
            
    return plansESCJ0000

def getPlanESFJ0000(fileName):
    plansESFJ0000 = {}

    for line in gzip.open(fileName,'rb').readlines():        
        mtch = re.match( r'export EST_(.*)=(.*)', line.strip())  
        if mtch:
            VALUE = mtch.group(2)
            grp = mtch.group(1).split("_", 1)
            CHAIN_CT = grp[0]
            IDF_CT = grp[-1].rsplit("_", 1)[0]
            TYPE = grp[-1].rsplit("_", 1)[-1]

            key = "_".join([DATE, PLAN, CRE_D, CHAIN_CT, IDF_CT, TYPE])
            plansESFJ0000[key] = {}
            plansESFJ0000[key]['CRE_D'] = CRE_D
            plansESFJ0000[key]['CHAIN_CT'] = CHAIN_CT
            plansESFJ0000[key]['IDF_CT'] = IDF_CT
            plansESFJ0000[key]['TYPE'] = TYPE
            plansESFJ0000[key]['VALUE'] = VALUE
            plansESFJ0000[key]['PLAN'] = PLAN
    
    return plansESFJ0000


if PLAN in ["PLAN0", "PLAN1", "PLAN2", "PLAN3", "PLAN4"]:
    pickleAppend(pklFileName, getPlanESCJ0000(FILENAME))

if PLAN in ["PLAN"]:
    pickleAppend(pklFileName, getPlanESFJ0000(FILENAME))

