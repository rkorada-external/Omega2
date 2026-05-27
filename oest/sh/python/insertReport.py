#! /usr/bin/env python

import os,fnmatch,time,datetime,csv,pickle
import re
import sys,collections
from pprint import pprint


 
def execQuery(query):
	print "\n...... ", query
	cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Udom_gen_ro -S'+SRV+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log' +  ' 2>&1' 
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
	
def nb_ligne( IN ):
	return sum(1 for line in open (IN))     #sumforinopen#    # count

def ConvertPklToSql(pklFile,sqlFile,server,dbclo):
	with open(pklFile, 'rb') as f:
		logsInfo=pickle.load(f)
	fSql=open(sqlFile,"w")
	fSql.write("USE BEST                                                   \n")
	fSql.write("go                                                         \n")
	fSql.write("                                                           \n")
	fSql.write("IF OBJECT_ID('dbo.TCLOS_REPORT') IS NOT NULL                   \n")
	fSql.write("BEGIN                                                      \n")
	fSql.write("    DROP TABLE dbo.TCLOS_REPORT                                \n")
	fSql.write("    IF OBJECT_ID('dbo.TCLOS_REPORT') IS NOT NULL               \n")
	fSql.write("        PRINT '<<< FAILED DROPPING TABLE dbo.TCLOS_REPORT >>>' \n")
	fSql.write("    ELSE                                                   \n")
	fSql.write("        PRINT '<<< DROPPED TABLE dbo.TCLOS_REPORT >>>'         \n")
	fSql.write("END                                                        \n")
	fSql.write("go                                                         \n")
	fSql.write("create table TCLOS_REPORT                                      \n")
	fSql.write("(                                                          \n")
	fSql.write("    SITE_CT                             varchar(10) null,                         \n")
	fSql.write("    DBCLOD_D                            varchar(10) null,                         \n")
	fSql.write("    CHAIN_CT                            varchar(10) null,                         \n")
	fSql.write("    PERMFIL_CT                          varchar(30) null,                         \n")
	fSql.write("    IOFind                              varchar(30) null,                         \n")
	fSql.write("    PATHPATTRN_LL                       varchar(512) null,                         \n")
	fSql.write("    IO                                  varchar(5) null,                         \n")
	fSql.write("    pathI                               varchar(512) null,                         \n")
	fSql.write("    sizeInLogI                          int null,                         \n")
	fSql.write("    dtInLogI                            varchar(30) null,                         \n")
	fSql.write("    sizeI                               int null,                         \n")
	fSql.write("    createDateI                         varchar(30) null,                         \n")
	fSql.write("    pathO                               varchar(512) null,                         \n")
	fSql.write("    size                                int null,                         \n")
	fSql.write("    InLogO                              varchar(30) null,                         \n")
	fSql.write("    dtInLogO                            varchar(30) null,                         \n")
	fSql.write("    sizeO	                             int null,                         \n")
	fSql.write("    createDateO                         varchar(30) null,                         \n")
	fSql.write("    IDF_CT                              varchar(30) null,                         \n")
	fSql.write("    NORME_CF                            varchar(30) null,                         \n")
	fSql.write("    TYPEINV                             varchar(30) null,                         \n")
	fSql.write("    VERSION_9001                        varchar(30) null,                         \n")
	fSql.write("    param_Context_id                    varchar(30) null,                         \n")
	fSql.write("    REQCOD_CT                           varchar(30) null,                         \n")
	fSql.write("    CLOTYP_CT                           varchar(30) null,                         \n")
	fSql.write("    OldPlan                             varchar(30) null,                         \n")
	fSql.write("    CHAIN_CT_OldPlan                    varchar(30) null                         \n")
	fSql.write(")                                                          \n")
	fSql.write("go                                                         \n")

	for idf_ct in logsInfo:
		print idf_ct, logsInfo[idf_ct]



#	fChainJobsCsv.write("CHAIN_CT,ordre,JOB_CT,JOB_CMD\n")
#
#	chainJobs=collections.OrderedDict()
#
#	for chain in dirs:
#		i=0
#		NCHAIN=chain.split(".")[0]
#		for line in open(SRC_DIRECTORY_DCMD+"/"+chain).readlines():
#			line_s=line.strip().replace("'","\"")
#			if re.match(".*\$\{DCMD\}",line.strip()) and not line_s.startswith("#"):
#				matchJob = re.match( r'(.*)/(.*).cmd', line_s)
#				if matchJob :
#					folder=matchJob.group(1)
#					job=matchJob.group(2)
#					i +=1
#					if NCHAIN not in chainJobs: chainJobs[NCHAIN]=[]
#					chainJobs[NCHAIN].append(job)
#					#print NCHAIN, str(i),job,folder, line_s
#					fChainJobsCsv.write( "{};{};{};{})\n".format(NCHAIN, str(i),job, line_s))
#					fChainJobsSql.write( "insert into BEST..TCLOS_REPORT values('{}',{},'{}','{}')\n".format(NCHAIN, str(i),job, line_s))
#	fChainJobsSql.write("go                                                         \n")
#	fChainJobsSql.close()
#	fChainJobsCsv.close()
#	return chainJobs


#writer = csv.DictWriter(csvFile, fieldnames=header, dialect=dialect)
#writer.writerow(dict((fn,fn) for fn in writer.fieldnames))
	
#csv_reader = csv.reader(csvFile, delimiter=';')
def addStringValue(value,sep=","):
	if value =="": return "NULL"+sep
	return "'" + value + "'"+sep

def csvToSql(csvFileName,sqlFileName,server,dbclo,site) :
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

server=sys.argv[1]
dbclo=sys.argv[2]
site=sys.argv[3]

DPKL = os.environ.get('DPKL')
DCSV = os.environ.get('DCSV')


csvFileName=DCSV+"/closingStatus_"+ dbclo +"_"+ server +"_"+ site+".csv"
sqlFileName=DPKL+ "/closingStatus_"+ dbclo +"_"+ server +"_"+ site+".sql"

print  "csvFileName:", csvFileName
csvToSql(csvFileName,sqlFileName,server,dbclo,site)
cmd="isql -Ubatch -SDEV_TPO2 -Pomega2-- -eerr -i" + sqlFileName
os.system(cmd ) 



#csvToSql("data/analyse/closingStatus20210405_20210406_dcvprdobbatch_as.csv","data/analyse/closingStatus20210405_20210406_dcvprdobbatch_as.sql","dcvprdobbatch","20210405")


