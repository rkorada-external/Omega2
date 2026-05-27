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

	

chainsInfo=getResultSet("select *   from  BTRAV..TLOG_INFO_CHAIN i where server in ( 'aeninto2batch' ,'dcvin2obbatch')  and site ='eu' and  GONOGO='GO' order by CRE_D, IDF_CT")

plans={}

for row in chainsInfo:
	server=row[0]
	cre_d=row[4]
	idf_ct=row[3]
	norme=row[9]
	if cre_d not in plans: plans[cre_d]={}
	if idf_ct not in plans[cre_d]: plans[cre_d][idf_ct]={}
	plans[cre_d][idf_ct][server]="GO"

for cre_d in plans:
	for idf_ct in plans[cre_d]:
		in2=""
		int=""
		if 'aeninto2batch' in plans[cre_d][idf_ct] :  int="GO"
		if 'dcvin2obbatch' in plans[cre_d][idf_ct] :  in2="GO"
		print "{0};{1};{2};{3}".format(cre_d,idf_ct,in2, int)

#pprint(plans)

# ['aeninto2batch',
#  'eu',
#  'STAD1550',
#  'STAD1550',
#  '20210510',
#  'Succeeded',
#  '2021/05/11 00:59:59',
#  '2021/05/11 01:03:53',
#  'GO',
#  'I4I',
#  '',
#  'ESCD9001',
#  '20210630',
#  'INV',
#  'I4I',
#  '',
