#! /usr/bin/python2.7
import os, sys, csv, pickle
from pprint import pprint

DSAVE = os.environ.get('DSAVE')
DCSV = os.environ.get('DCSV')
DSQL = os.environ.get('DSQL')
SERVER = os.environ.get('SERVER')
SITE = os.environ.get('SITE')

FILENAME = sys.argv[1]
DATE = sys.argv[2]
INSERT = sys.argv[3]

dialect = csv.excel
dialect.delimiter = ";"
dialect.lineterminator = "\n"

csvFileName = "{DCSV}/PLANS_{SERVER}_{SITE}_{CRE_D}.csv".format(DCSV=DCSV, SERVER=SERVER, SITE=SITE, CRE_D=DATE)
sqlFileName = "{DSQL}/PLANS_{SERVER}_{SITE}_{CRE_D}.sql".format(DSQL=DSQL, SERVER=SERVER, SITE=SITE, CRE_D=DATE)

def pickleLoad(fileName):
    with open(fileName, 'rb') as f:
        return pickle.load(f)

def csvDump(fileName, data):
    fieldnames = ['CRE_D', 'CHAIN_CT', 'IDF_CT', 'TYPE', 'VALUE', 'PLAN']

    with open(fileName, mode='w') as f:
        csvFile = csv.DictWriter(f, fieldnames=fieldnames, dialect=dialect)
        csvFile.writerow(dict((fn,fn) for fn in csvFile.fieldnames))

        for key, value in data.items():
            csvFile.writerow(value)

def csvToSql(csvFileName, sqlFileName):
    with open(sqlFileName, mode='wt') as sqlFile:
        with open(csvFileName, mode='r') as csvFile:
            csvRead = csv.DictReader(csvFile, dialect=dialect)
            sqlFile.write("USE BTRAV\n")
            sqlFile.write("go \n")
            sqlFile.write('delete TPLANS where SERVER="{SERVER}" and SITE_CT="{SITE}" and CRE_D="{CRE_D}"\n'.format(CRE_D=DATE, SERVER=SERVER, SITE=SITE))

            for row in csvRead:
                sqlFile.write('insert into TPLANS values("{0}", "{1}", "{CRE_D}", "{CHAIN_CT}", "{IDF_CT}", "{TYPE}", "{VALUE}", "{PLAN}")\n'.format(SERVER, SITE, **row))
            sqlFile.write("go \n")

pickleData = pickleLoad(FILENAME)
csvDump(csvFileName, pickleData)

csvToSql(csvFileName, sqlFileName)

if INSERT == "yes":
    cmd="isql -Ubatch -SDEV_TPO2 -Pomega2-- -eerr -i{0} > sql.txt".format(sqlFileName)
    os.system(cmd) 