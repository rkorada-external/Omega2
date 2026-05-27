---------------------------------
-- Plan of REQCOD_CT = I4IQPOS 
---------------------------------
USE BEST
go 

Delete BEST..TI17REQCHN  where REQCOD_CT = 'I4IQPOS'
	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESCJ0060' )  insert into BEST..TI17CHN values('ESCJ0060','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESCJ0060' )  insert into BEST..TI17FNC values('ESCJ0060','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESCJ0060','ESCJ0060','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESCJ8990' )  insert into BEST..TI17CHN values('ESCJ8990','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESCJ8990' )  insert into BEST..TI17FNC values('ESCJ8990','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESCJ8990','ESCJ8990','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ0110' )  insert into BEST..TI17CHN values('ESDJ0110','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ0110' )  insert into BEST..TI17FNC values('ESDJ0110','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESDJ0110','ESDJ0110','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ5020' )  insert into BEST..TI17CHN values('ESDJ5020','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ5020' )  insert into BEST..TI17FNC values('ESDJ5020','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESDJ5020','ESDJ5020','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ7000' )  insert into BEST..TI17CHN values('ESDJ7000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ7000' )  insert into BEST..TI17FNC values('ESDJ7000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESDJ7000','ESDJ7000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ7010' )  insert into BEST..TI17CHN values('ESDJ7010','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ7010' )  insert into BEST..TI17FNC values('ESDJ7010','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESDJ7010','ESDJ7010','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ8040' )  insert into BEST..TI17CHN values('ESDJ8040','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ8040' )  insert into BEST..TI17FNC values('ESDJ8040','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESDJ8040','ESDJ8040','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESEH1100' )  insert into BEST..TI17CHN values('ESEH1100','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESEH1100' )  insert into BEST..TI17FNC values('ESEH1100','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESEH1100','ESEH1100','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESEH1110' )  insert into BEST..TI17CHN values('ESEH1110','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESEH1110' )  insert into BEST..TI17FNC values('ESEH1110','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESEH1110','ESEH1110','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESEH1200' )  insert into BEST..TI17CHN values('ESEH1200','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESEH1200' )  insert into BEST..TI17FNC values('ESEH1200','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESEH1200','ESEH1200','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESEJ1000' )  insert into BEST..TI17CHN values('ESEJ1000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESEJ1000' )  insert into BEST..TI17FNC values('ESEJ1000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESEJ1000','ESEJ1000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID3850' )  insert into BEST..TI17CHN values('ESID3850','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID3850' )  insert into BEST..TI17FNC values('ESID3850','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESID3850','ESID3850','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8710' )  insert into BEST..TI17CHN values('ESID8710','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8710' )  insert into BEST..TI17FNC values('ESID8710','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESID8710','ESID8710','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESIJ0010' )  insert into BEST..TI17CHN values('ESIJ0010','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESIJ0010' )  insert into BEST..TI17FNC values('ESIJ0010','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESIJ0010','ESIJ0010','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESIJ0090' )  insert into BEST..TI17CHN values('ESIJ0090','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESIJ0090' )  insert into BEST..TI17FNC values('ESIJ0090','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESIJ0090','ESIJ0090','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESIJ7000' )  insert into BEST..TI17CHN values('ESIJ7000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESIJ7000' )  insert into BEST..TI17FNC values('ESIJ7000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESIJ7000','ESIJ7000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD0060' )  insert into BEST..TI17CHN values('ESPD0060','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD0060' )  insert into BEST..TI17FNC values('ESPD0060','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD0060','ESPD0060','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD1520' )  insert into BEST..TI17CHN values('ESPD1520','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD1520' )  insert into BEST..TI17FNC values('ESPD1520','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD1520','ESPD1520','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD1800' )  insert into BEST..TI17CHN values('ESPD1800','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD1800' )  insert into BEST..TI17FNC values('ESPD1800','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD1800','ESPD1800','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD2050' )  insert into BEST..TI17CHN values('ESPD2050','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD2050' )  insert into BEST..TI17FNC values('ESPD2050','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD2050','ESPD2050','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD2550' )  insert into BEST..TI17CHN values('ESPD2550','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD2550' )  insert into BEST..TI17FNC values('ESPD2550','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD2550','ESPD2550','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3800' )  insert into BEST..TI17CHN values('ESPD3800','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD3800' )  insert into BEST..TI17FNC values('ESPD3800','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD3800','ESPD3800','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3810' )  insert into BEST..TI17CHN values('ESPD3810','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD3810' )  insert into BEST..TI17FNC values('ESPD3810','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD3810','ESPD3810','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD3900' )  insert into BEST..TI17CHN values('ESPD3900','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD3900' )  insert into BEST..TI17FNC values('ESPD3900','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD3900','ESPD3900','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD4000' )  insert into BEST..TI17CHN values('ESPD4000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD4000' )  insert into BEST..TI17FNC values('ESPD4000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD4000','ESPD4000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD7000' )  insert into BEST..TI17CHN values('ESPD7000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD7000' )  insert into BEST..TI17FNC values('ESPD7000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD7000','ESPD7000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8000' )  insert into BEST..TI17CHN values('ESPD8000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD8000' )  insert into BEST..TI17FNC values('ESPD8000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD8000','ESPD8000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8100' )  insert into BEST..TI17CHN values('ESPD8100','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD8100' )  insert into BEST..TI17FNC values('ESPD8100','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD8100','ESPD8100','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8700' )  insert into BEST..TI17CHN values('ESPD8700','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD8700' )  insert into BEST..TI17FNC values('ESPD8700','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD8700','ESPD8700','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8800' )  insert into BEST..TI17CHN values('ESPD8800','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD8800' )  insert into BEST..TI17FNC values('ESPD8800','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD8800','ESPD8800','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPD8900' )  insert into BEST..TI17CHN values('ESPD8900','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPD8900' )  insert into BEST..TI17FNC values('ESPD8900','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPD8900','ESPD8900','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPJ0090' )  insert into BEST..TI17CHN values('ESPJ0090','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPJ0090' )  insert into BEST..TI17FNC values('ESPJ0090','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPJ0090','ESPJ0090','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESPJ8990' )  insert into BEST..TI17CHN values('ESPJ8990','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESPJ8990' )  insert into BEST..TI17FNC values('ESPJ8990','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','ESPJ8990','ESPJ8990','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='STPD1200' )  insert into BEST..TI17CHN values('STPD1200','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='STPD1200' )  insert into BEST..TI17FNC values('STPD1200','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','STPD1200','STPD1200','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='STPD1280' )  insert into BEST..TI17CHN values('STPD1280','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='STPD1280' )  insert into BEST..TI17FNC values('STPD1280','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','STPD1280','STPD1280','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='STPD1500' )  insert into BEST..TI17CHN values('STPD1500','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='STPD1500' )  insert into BEST..TI17FNC values('STPD1500','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IQPOS','STPD1500','STPD1500','' ) 

go
