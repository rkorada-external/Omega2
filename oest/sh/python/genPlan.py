#! /usr/bin/env python
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
	cmd='${BCPPDIR}/bcpmulti BIDON out "query.out" -Udom_gen_ro -S'+SRV+'_TPO2 -c to /tmp/ -Jiso_1 -P"scorRO" -t"~" -r"\n" -d0 -M0 -Q "'+ query + '"   >>  log' +  ' 2>&1' 
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

dbclo_max=sys.argv[1]

SRV="INT" 
query="""
	Select  REQCOD_CT, NORME_CF,convert(varchar, max(DBCLO_D),112)
	FROM  BEST..TI17REQJOBPLAN 
	where site_cf ='FRA1'
	and dbclo_d between '20210430' and '{0}' 
	group by REQCOD_CT, NORME_CF
	order by 3
""".format(dbclo_max)

dbclos=getResultSet(query)
SRV="DEV" 
for row in dbclos:
	reqcod=row[0]
	norme=row[1]
	dbclo=row[2]
	with  open("PLAN_{0}.sql".format(reqcod), "w") as sqlFile:
		#print "---------------------------------\n-- REQCOD_CT = {0}\n[1} \n---------------------------------\n".format(reqcod,query)
		query="""
			select  distinct CHAIN_CT 
			from  BTRAV..TLOG_INFO_CHAIN  
			where server = 'aeninto2batch' 
			and site='eu' 
			and cre_d='{0}'
			and VNORME = '{1}'
			and GONOGO='GO'
			order by CHAIN_CT 
		""".format(dbclo,reqcod[0:3])

		chains=getResultSet(query)
		print "---------------------------------\nSql File:PLAN_{0}.sql \nREQCOD_CT={0} \n#rows={1} \nquery:{2}".format(reqcod,len(chains),query)
		sqlFile.write( "---------------------------------\n-- Plan of REQCOD_CT = {0} \n---------------------------------\n".format(reqcod))
		sqlFile.write("USE BEST\n")
		sqlFile.write("go \n\n")
		sqlFile.write("Delete BEST..TI17REQCHN  where REQCOD_CT = '{0}'\n".format(reqcod))
		for chain in chains:
			sqlFile.write(  "	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='{0}' )  insert into BEST..TI17CHN values('{0}','') \n".format(chain[0]))
			sqlFile.write(  "	if not exists (select 1 from BEST..TI17FNC where IDF_CT='{0}' )  insert into BEST..TI17FNC values('{0}','') \n".format(chain[0]))
			sqlFile.write(  "	INSERT INTO BEST..TI17REQCHN  VALUES( '{0}','{1}','{1}','' ) \n\n".format(reqcod,chain[0])  )
		sqlFile.write( "go\n")

