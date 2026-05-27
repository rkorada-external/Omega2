#! /usr/bin/env python

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

#for e in listCOND:
#	print e
	
with  open("/scordata_aenitko2batch/ubas/perm/T_ESFJ0000_TI17PERMFIL.dat", "r") as f:
	for line in f.readlines()
		print line 