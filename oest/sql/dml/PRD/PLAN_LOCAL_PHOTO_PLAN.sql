 -- Local
 
 if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT ='Y'  ) 
	insert into BEST..TI17REQ values ('Y','local IFRS4')

 if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESLD3860'  ) 
	insert into BEST..TI17CHN values ('ESLD3860','')

 if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESLJ8990'  ) 
	insert into BEST..TI17CHN values ('ESLJ8990','')


 if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESLD3860'  ) 	insert into BEST..TI17FNC values ('ESLD3860','','ESLD3860',0)

 if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESLJ8990'  ) 
	insert into BEST..TI17FNC values ('ESLJ8990','','ESLJ8990',0)


 delete BEST..TI17REQFNC where REQCOD_CT = 'Y'
 
 insert into BEST..TI17REQFNC values ('Y', 'ESLJ0090','')
 insert into BEST..TI17REQFNC values ('Y', 'ESLD8700','')
 insert into BEST..TI17REQFNC values ('Y', 'ESLD8100','')
 insert into BEST..TI17REQFNC values ('Y', 'ESLD3850','')
 insert into BEST..TI17REQFNC values ('Y', 'ESLD3800','')
 insert into BEST..TI17REQFNC values ('Y', 'ESLD2900','')
 insert into BEST..TI17REQFNC values ('Y', 'ESLD1900','')
 insert into BEST..TI17REQFNC values ('Y', 'ESLD1800','')
 insert into BEST..TI17REQFNC values ('Y', 'ESLD3860','')
 insert into BEST..TI17REQFNC values ('Y', 'ESLJ8990','')
 




-- Photo plan

if not exists ( select 1 from BEST..TI17REQ where REQCOD_CT ='A'  ) 
	insert into BEST..TI17REQ values ('A','Life plan')
	
-- Ajout des chaines IFRS4
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='DWUJ0070'  ) 	insert into BEST..TI17CHN values ('DWUJ0070','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESCJ0000'  ) 	insert into BEST..TI17CHN values ('ESCJ0000','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESCJ0060'  ) 	insert into BEST..TI17CHN values ('ESCJ0060','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESCJ8990'  ) 	insert into BEST..TI17CHN values ('ESCJ8990','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESDJ0110'  ) 	insert into BEST..TI17CHN values ('ESDJ0110','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESDJ1010'  ) 	insert into BEST..TI17CHN values ('ESDJ1010','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESDJ5020'  ) 	insert into BEST..TI17CHN values ('ESDJ5020','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESDJ5040'  ) 	insert into BEST..TI17CHN values ('ESDJ5040','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESDJ7000'  ) 	insert into BEST..TI17CHN values ('ESDJ7000','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESDJ7010'  ) 	insert into BEST..TI17CHN values ('ESDJ7010','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESDJ8040'  ) 	insert into BEST..TI17CHN values ('ESDJ8040','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESEJ0000'  ) 	insert into BEST..TI17CHN values ('ESEJ0000','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESEJ1000'  ) 	insert into BEST..TI17CHN values ('ESEJ1000','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESIJ2000'  ) 	insert into BEST..TI17CHN values ('ESIJ2000','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESED0300'  ) 	insert into BEST..TI17CHN values ('ESED0300','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESEH1100'  ) 	insert into BEST..TI17CHN values ('ESEH1100','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESEH1110'  ) 	insert into BEST..TI17CHN values ('ESEH1110','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESEH1200'  ) 	insert into BEST..TI17CHN values ('ESEH1200','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID1000'  ) 	insert into BEST..TI17CHN values ('ESID1000','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID1010'  ) 	insert into BEST..TI17CHN values ('ESID1010','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID1500'  ) 	insert into BEST..TI17CHN values ('ESID1500','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID1900'  ) 	insert into BEST..TI17CHN values ('ESID1900','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID2030'  ) 	insert into BEST..TI17CHN values ('ESID2030','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID2070'  ) 	insert into BEST..TI17CHN values ('ESID2070','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID3020'  ) 	insert into BEST..TI17CHN values ('ESID3020','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESIJ0010'  ) 	insert into BEST..TI17CHN values ('ESIJ0010','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESIJ0090'  ) 	insert into BEST..TI17CHN values ('ESIJ0090','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESIJ7000'  ) 	insert into BEST..TI17CHN values ('ESIJ7000','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID0060'  ) 	insert into BEST..TI17CHN values ('ESID0060','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID0070'  ) 	insert into BEST..TI17CHN values ('ESID0070','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID0080'  ) 	insert into BEST..TI17CHN values ('ESID0080','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID0110'  ) 	insert into BEST..TI17CHN values ('ESID0110','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID0120'  ) 	insert into BEST..TI17CHN values ('ESID0120','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID0130'  ) 	insert into BEST..TI17CHN values ('ESID0130','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID8030'  ) 	insert into BEST..TI17CHN values ('ESID8030','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='DWUD0130'  ) 	insert into BEST..TI17CHN values ('DWUD0130','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='DWUD9130'  ) 	insert into BEST..TI17CHN values ('DWUD9130','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID0560'  ) 	insert into BEST..TI17CHN values ('ESID0560','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID1520'  ) 	insert into BEST..TI17CHN values ('ESID1520','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID1530'  ) 	insert into BEST..TI17CHN values ('ESID1530','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID2020'  ) 	insert into BEST..TI17CHN values ('ESID2020','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID2040'  ) 	insert into BEST..TI17CHN values ('ESID2040','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID2080'  ) 	insert into BEST..TI17CHN values ('ESID2080','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='ESID4000'  ) 	insert into BEST..TI17CHN values ('ESID4000','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='STAD1200'  ) 	insert into BEST..TI17CHN values ('STAD1200','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='STAD1280'  ) 	insert into BEST..TI17CHN values ('STAD1280','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='STAD1500'  ) 	insert into BEST..TI17CHN values ('STAD1500','')
if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT ='STAD1550'  ) 	insert into BEST..TI17CHN values ('STAD1550','')

-- Ajout des IDF_CT IFRS4
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='DWUJ0070'  ) 	insert into BEST..TI17FNC values ('DWUJ0070','','DWUJ0070',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESCJ0000'  ) 	insert into BEST..TI17FNC values ('ESCJ0000','','ESCJ0000',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESCJ0060'  ) 	insert into BEST..TI17FNC values ('ESCJ0060','','ESCJ0060',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESCJ8990'  ) 	insert into BEST..TI17FNC values ('ESCJ8990','','ESCJ8990',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESDJ0110'  ) 	insert into BEST..TI17FNC values ('ESDJ0110','','ESDJ0110',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESDJ1010'  ) 	insert into BEST..TI17FNC values ('ESDJ1010','','ESDJ1010',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESDJ5020'  ) 	insert into BEST..TI17FNC values ('ESDJ5020','','ESDJ5020',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESDJ5040'  ) 	insert into BEST..TI17FNC values ('ESDJ5040','','ESDJ5040',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESDJ7000'  ) 	insert into BEST..TI17FNC values ('ESDJ7000','','ESDJ7000',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESDJ7010'  ) 	insert into BEST..TI17FNC values ('ESDJ7010','','ESDJ7010',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESDJ8040'  ) 	insert into BEST..TI17FNC values ('ESDJ8040','','ESDJ8040',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESEJ0000'  ) 	insert into BEST..TI17FNC values ('ESEJ0000','','ESEJ0000',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESEJ1000'  ) 	insert into BEST..TI17FNC values ('ESEJ1000','','ESEJ1000',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESIJ2000'  ) 	insert into BEST..TI17FNC values ('ESIJ2000','','ESIJ2000',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESED0300'  ) 	insert into BEST..TI17FNC values ('ESED0300','','ESED0300',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESEH1100'  ) 	insert into BEST..TI17FNC values ('ESEH1100','','ESEH1100',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESEH1110'  ) 	insert into BEST..TI17FNC values ('ESEH1110','','ESEH1110',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESEH1200'  ) 	insert into BEST..TI17FNC values ('ESEH1200','','ESEH1200',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID1000'  ) 	insert into BEST..TI17FNC values ('ESID1000','','ESID1000',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID1010'  ) 	insert into BEST..TI17FNC values ('ESID1010','','ESID1010',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID1500'  ) 	insert into BEST..TI17FNC values ('ESID1500','','ESID1500',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID1900'  ) 	insert into BEST..TI17FNC values ('ESID1900','','ESID1900',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID2030'  ) 	insert into BEST..TI17FNC values ('ESID2030','','ESID2030',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID2070'  ) 	insert into BEST..TI17FNC values ('ESID2070','','ESID2070',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID3020'  ) 	insert into BEST..TI17FNC values ('ESID3020','','ESID3020',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESIJ0010'  ) 	insert into BEST..TI17FNC values ('ESIJ0010','','ESIJ0010',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESIJ0090'  ) 	insert into BEST..TI17FNC values ('ESIJ0090','','ESIJ0090',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESIJ7000'  ) 	insert into BEST..TI17FNC values ('ESIJ7000','','ESIJ7000',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID0060'  ) 	insert into BEST..TI17FNC values ('ESID0060','','ESID0060',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID0070'  ) 	insert into BEST..TI17FNC values ('ESID0070','','ESID0070',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID0080'  ) 	insert into BEST..TI17FNC values ('ESID0080','','ESID0080',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID0110'  ) 	insert into BEST..TI17FNC values ('ESID0110','','ESID0110',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID0120'  ) 	insert into BEST..TI17FNC values ('ESID0120','','ESID0120',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID0130'  ) 	insert into BEST..TI17FNC values ('ESID0130','','ESID0130',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID8030'  ) 	insert into BEST..TI17FNC values ('ESID8030','','ESID8030',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='DWUD0130'  ) 	insert into BEST..TI17FNC values ('DWUD0130','','DWUD0130',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='DWUD9130'  ) 	insert into BEST..TI17FNC values ('DWUD9130','','DWUD9130',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID0560'  ) 	insert into BEST..TI17FNC values ('ESID0560','','ESID0560',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID1520'  ) 	insert into BEST..TI17FNC values ('ESID1520','','ESID1520',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID1530'  ) 	insert into BEST..TI17FNC values ('ESID1530','','ESID1530',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID2020'  ) 	insert into BEST..TI17FNC values ('ESID2020','','ESID2020',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID2040'  ) 	insert into BEST..TI17FNC values ('ESID2040','','ESID2040',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID2080'  ) 	insert into BEST..TI17FNC values ('ESID2080','','ESID2080',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='ESID4000'  ) 	insert into BEST..TI17FNC values ('ESID4000','','ESID4000',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='STAD1200'  ) 	insert into BEST..TI17FNC values ('STAD1200','','STAD1200',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='STAD1280'  ) 	insert into BEST..TI17FNC values ('STAD1280','','STAD1280',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='STAD1500'  ) 	insert into BEST..TI17FNC values ('STAD1500','','STAD1500',0)
if not exists ( select 1 from BEST..TI17FNC where IDF_CT ='STAD1550'  ) 	insert into BEST..TI17FNC values ('STAD1550','','STAD1550',0)

delete BEST..TI17REQFNC where REQCOD_CT = 'A'

insert into BEST..TI17REQFNC values ('A', 'DWUJ0070','')
insert into BEST..TI17REQFNC values ('A', 'ESCJ0000','')
insert into BEST..TI17REQFNC values ('A', 'ESCJ0060','')
insert into BEST..TI17REQFNC values ('A', 'ESCJ8990','')
insert into BEST..TI17REQFNC values ('A', 'ESDJ0110','')
insert into BEST..TI17REQFNC values ('A', 'ESDJ1010','')
insert into BEST..TI17REQFNC values ('A', 'ESDJ5020','')
insert into BEST..TI17REQFNC values ('A', 'ESDJ5040','')
insert into BEST..TI17REQFNC values ('A', 'ESDJ7000','')
insert into BEST..TI17REQFNC values ('A', 'ESDJ7010','')
insert into BEST..TI17REQFNC values ('A', 'ESDJ8040','')
insert into BEST..TI17REQFNC values ('A', 'ESEJ0000','')
insert into BEST..TI17REQFNC values ('A', 'ESEJ1000','')
insert into BEST..TI17REQFNC values ('A', 'ESIJ2000','')
insert into BEST..TI17REQFNC values ('A', 'ESED0300','')
insert into BEST..TI17REQFNC values ('A', 'ESEH1100','')
insert into BEST..TI17REQFNC values ('A', 'ESEH1110','')
insert into BEST..TI17REQFNC values ('A', 'ESEH1200','')
insert into BEST..TI17REQFNC values ('A', 'ESID1000','')
insert into BEST..TI17REQFNC values ('A', 'ESID1010','')
insert into BEST..TI17REQFNC values ('A', 'ESID1500','')
insert into BEST..TI17REQFNC values ('A', 'ESID1900','')
insert into BEST..TI17REQFNC values ('A', 'ESID2030','')
insert into BEST..TI17REQFNC values ('A', 'ESID2070','')
insert into BEST..TI17REQFNC values ('A', 'ESID3020','')
insert into BEST..TI17REQFNC values ('A', 'ESIJ0010','')
insert into BEST..TI17REQFNC values ('A', 'ESIJ0090','')
insert into BEST..TI17REQFNC values ('A', 'ESIJ7000','')
insert into BEST..TI17REQFNC values ('A', 'ESID0060','')
insert into BEST..TI17REQFNC values ('A', 'ESID0070','')
insert into BEST..TI17REQFNC values ('A', 'ESID0080','')
insert into BEST..TI17REQFNC values ('A', 'ESID0110','')
insert into BEST..TI17REQFNC values ('A', 'ESID0120','')
insert into BEST..TI17REQFNC values ('A', 'ESID0130','')
insert into BEST..TI17REQFNC values ('A', 'ESID8030','')
insert into BEST..TI17REQFNC values ('A', 'DWUD0130','')
insert into BEST..TI17REQFNC values ('A', 'DWUD9130','')
insert into BEST..TI17REQFNC values ('A', 'ESID0560','')
insert into BEST..TI17REQFNC values ('A', 'ESID1520','')
insert into BEST..TI17REQFNC values ('A', 'ESID1530','')
insert into BEST..TI17REQFNC values ('A', 'ESID2020','')
insert into BEST..TI17REQFNC values ('A', 'ESID2040','')
insert into BEST..TI17REQFNC values ('A', 'ESID2080','')
insert into BEST..TI17REQFNC values ('A', 'ESID4000','')
insert into BEST..TI17REQFNC values ('A', 'STAD1200','')
insert into BEST..TI17REQFNC values ('A', 'STAD1280','')
insert into BEST..TI17REQFNC values ('A', 'STAD1500','')
insert into BEST..TI17REQFNC values ('A', 'STAD1550','')


-- correction I4IMINVB
	delete BEST..TI17REQFNC where IDF_CT like "%I4I_%LIF%" and REQCOD_CT ="I4IMINVB"
	delete  BEST..TI17REQFNC where IDF_CT like "ESID2030" and REQCOD_CT ="I4IMINVB"
	delete  BEST..TI17REQFNC where IDF_CT like "ESEH1200" and REQCOD_CT ="I4IMINVB"
	delete  BEST..TI17REQFNC where  REQCOD_CT ="I4IMINVB"  and IDF_CT in (  "ESID2560" ,"ESID8700","ESID8710" )

	insert into BEST..TI17REQFNC values ('I4IMINVB', 'ESID8710','')


-- correction I4IQINVB
	delete  BEST..TI17REQFNC where  REQCOD_CT ="I4IQINVB"  and IDF_CT in (  
		"ESEH1100",
		"ESEH1200",
		"I4I_Q_CC_LIF",
		"I4I_Y_CC_LIF",
		"ESID2560",
		"ESID3810",
		"ESCJ8990",
		"ESID0080",
		"ESIJ0010",
		"STAD7500")

	insert into BEST..TI17REQFNC values ('ESCJ8990', 'ESCJ8990','')
	insert into BEST..TI17REQFNC values ('ESID0080', 'ESID0080','')
	insert into BEST..TI17REQFNC values ('ESIJ0010', 'ESIJ0010','')
	insert into BEST..TI17REQFNC values ('STAD7500', 'STAD7500','')
go

