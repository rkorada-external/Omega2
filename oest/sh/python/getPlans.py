#! /usr/bin/python2.7
import os, sys, subprocess, csv, re, gzip, pickle, time, fnmatch
from pprint import pprint

DSAVE = os.environ.get('DSAVE')
DPKL = os.environ.get('DPKL')
SERVER = os.environ.get('SERVER')
SITE = os.environ.get('SITE')

def pickleDump(fileName, data):
    with open(fileName, 'wb') as f:
        pickle.dump(data, f, pickle.HIGHEST_PROTOCOL) 

def getPlansESCJ0000(date):
    dirs=fnmatch.filter(os.listdir(DSAVE),"svg_{0}*ESCJ0000_PLAN[0-4].dat.gz".format(date))
    plansESCJ0000 = {}

    for plan in dirs:
        f = re.match('.*ESCJ0000_(.*).dat.gz', plan).group(1)
        fileName = DSAVE + "/" + plan
     
        for line in gzip.open(fileName,'rb').readlines():        
            mtch = re.match('export (.*)_(.*)_GONOGO="Y"', line.strip())
            if mtch:
                CHAIN_CT = mtch.group(2)
                plansESCJ0000[CHAIN_CT] = f

    return plansESCJ0000

def getPlansESFJ0000(date):
    dirs=fnmatch.filter(os.listdir(DSAVE),"svg_{0}*ESFJ0000_PLAN_IFRS17.dat.gz".format(date))
    planESFJ0000={}

    for plan in dirs:
        fileName = DSAVE + "/" + plan
        for line in gzip.open(fileName,'rb').readlines():
            IDF_CT = line.strip().split("~")[3]
            planESFJ0000[IDF_CT]={}
            planESFJ0000[IDF_CT]["REQCOD_CT"]=line.strip().split("~")[0]
            planESFJ0000[IDF_CT]["CLOTYP_CT"]=line.strip().split("~")[1]
            planESFJ0000[IDF_CT]["CHAIN_CT"]=line.strip().split("~")[2]
            planESFJ0000[IDF_CT]["NORME_CF"]=line.strip().split("~")[4]

    return planESFJ0000


def getPermESFJ0000(date):
	dirs=fnmatch.filter(os.listdir(DSAVE),"svg_{0}*_ESFJ0000_TI17PERMFIL.dat.gz".format(date))
	perms={}
	for perm in dirs:
		fileName = DSAVE + "/" + perm
		for line in gzip.open(fileName,'rb').readlines():
			IDF_CT=line.strip().split("~")[0]
			PERMFIL_CT=line.strip().split("~")[1]
			PATHPATTRN_LL=line.strip().split("~")[2]
			IO=line.strip().split("~")[3]
			perms[(IDF_CT,PERMFIL_CT)]=(PATHPATTRN_LL,IO)
	return perms

date = sys.argv[1]
plan = sys.argv[2]

pklFileName = "{0}/{1}_{2}_{3}_{4}.pkl".format(DPKL, plan, SERVER, SITE, date)

if plan == "PLANS":
    PlansESCJ0000 = getPlansESCJ0000(date)
    pickleDump(pklFileName, PlansESCJ0000)
if plan == "PLAN_IFRS17":
    PlansESFJ0000 = getPlansESFJ0000(date)
    pickleDump(pklFileName, PlansESFJ0000)
if plan == "TI17PERMFIL":
    PermsESFJ0000 = getPermESFJ0000(date)
    pickleDump(pklFileName, PermsESFJ0000)	
