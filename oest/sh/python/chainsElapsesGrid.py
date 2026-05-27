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



server=sys.argv[1]
site=sys.argv[2]
dbclo=sys.argv[3]

query="""declare   @day_min int ,
            @hour_min int,
            @date_min datetime,
            @date_max datetime
		select @date_min=min( convert(datetime,START_D) ) ,@date_max=max( convert(datetime,END_D) ),@day_min=datepart(DD,min( convert(datetime,START_D)) ) ,@hour_min =datepart(HH,min( convert(datetime,START_D) ) )
		from  BTRAV..TLOG_INFO_CHAIN  where server = '{0}' and site='{1}' and cre_d='{2}' 
		select 
			CHAIN_CT, 
			IDF_CT,
			START_D, 
			END_D,
			datediff(SS,convert(datetime,START_D), convert(datetime,END_D) ) 'delta sec', 
			datepart(DD,START_D) - @day_min day, 
			24*(datepart(DD,START_D) - @day_min) +datepart(HH,START_D) -@hour_min heure, 
			datepart(MI,START_D)  minute,
			datepart(MI,START_D)/1 +1 '# mn',
			datediff(SS,convert(datetime,START_D) ,convert(datetime,END_D) )/60/1 +1 '#delta min'
		from  BTRAV..TLOG_INFO_CHAIN  where server = '{0}' and site='{1}' and cre_d='{2}' 
		order by START_D
""".format(server,site,dbclo)
elapses=getResultSet(query)
#pprint(elapses)
buf={}
for row in elapses:
	chain=row[0]
	idf_ct=row[1]
	day=int(row[5])
	heure=int(row[6])
	minute=int(row[8])
	if row[9] != "":
		delta=int(row[9])
		for i in range(500):	buf[i]=""
		for i in range(heure*60+minute,heure*60+minute+delta):	buf[i]="X"
		bufs=""
		for i in range(500):	bufs +=buf[i]+";"
		print chain+";"+idf_ct+";"+str(delta)+";"+";"+bufs
	else:
		print chain+";"+idf_ct
	
	


#pprint(buf)
	