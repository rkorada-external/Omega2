---------------------------------
-- Plan of REQCOD_CT = I4IMINV 
---------------------------------
USE BEST
go 

Delete BEST..TI17REQCHN  where REQCOD_CT = 'I4IMINV'
	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESCJ0060' )  insert into BEST..TI17CHN values('ESCJ0060','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESCJ0060' )  insert into BEST..TI17FNC values('ESCJ0060','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESCJ0060','ESCJ0060','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESCJ8990' )  insert into BEST..TI17CHN values('ESCJ8990','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESCJ8990' )  insert into BEST..TI17FNC values('ESCJ8990','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESCJ8990','ESCJ8990','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ0110' )  insert into BEST..TI17CHN values('ESDJ0110','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ0110' )  insert into BEST..TI17FNC values('ESDJ0110','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESDJ0110','ESDJ0110','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ1010' )  insert into BEST..TI17CHN values('ESDJ1010','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ1010' )  insert into BEST..TI17FNC values('ESDJ1010','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESDJ1010','ESDJ1010','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ5020' )  insert into BEST..TI17CHN values('ESDJ5020','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ5020' )  insert into BEST..TI17FNC values('ESDJ5020','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESDJ5020','ESDJ5020','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ7000' )  insert into BEST..TI17CHN values('ESDJ7000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ7000' )  insert into BEST..TI17FNC values('ESDJ7000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESDJ7000','ESDJ7000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ7010' )  insert into BEST..TI17CHN values('ESDJ7010','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ7010' )  insert into BEST..TI17FNC values('ESDJ7010','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESDJ7010','ESDJ7010','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESDJ8040' )  insert into BEST..TI17CHN values('ESDJ8040','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESDJ8040' )  insert into BEST..TI17FNC values('ESDJ8040','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESDJ8040','ESDJ8040','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESEH1100' )  insert into BEST..TI17CHN values('ESEH1100','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESEH1100' )  insert into BEST..TI17FNC values('ESEH1100','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESEH1100','ESEH1100','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESEH1110' )  insert into BEST..TI17CHN values('ESEH1110','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESEH1110' )  insert into BEST..TI17FNC values('ESEH1110','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESEH1110','ESEH1110','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESEH1200' )  insert into BEST..TI17CHN values('ESEH1200','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESEH1200' )  insert into BEST..TI17FNC values('ESEH1200','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESEH1200','ESEH1200','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESEJ1000' )  insert into BEST..TI17CHN values('ESEJ1000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESEJ1000' )  insert into BEST..TI17FNC values('ESEJ1000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESEJ1000','ESEJ1000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID0060' )  insert into BEST..TI17CHN values('ESID0060','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID0060' )  insert into BEST..TI17FNC values('ESID0060','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID0060','ESID0060','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID0070' )  insert into BEST..TI17CHN values('ESID0070','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID0070' )  insert into BEST..TI17FNC values('ESID0070','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID0070','ESID0070','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID0080' )  insert into BEST..TI17CHN values('ESID0080','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID0080' )  insert into BEST..TI17FNC values('ESID0080','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID0080','ESID0080','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID0110' )  insert into BEST..TI17CHN values('ESID0110','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID0110' )  insert into BEST..TI17FNC values('ESID0110','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID0110','ESID0110','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID0120' )  insert into BEST..TI17CHN values('ESID0120','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID0120' )  insert into BEST..TI17FNC values('ESID0120','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID0120','ESID0120','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID0130' )  insert into BEST..TI17CHN values('ESID0130','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID0130' )  insert into BEST..TI17FNC values('ESID0130','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID0130','ESID0130','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID0560' )  insert into BEST..TI17CHN values('ESID0560','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID0560' )  insert into BEST..TI17FNC values('ESID0560','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID0560','ESID0560','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID1000' )  insert into BEST..TI17CHN values('ESID1000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID1000' )  insert into BEST..TI17FNC values('ESID1000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID1000','ESID1000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID1010' )  insert into BEST..TI17CHN values('ESID1010','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID1010' )  insert into BEST..TI17FNC values('ESID1010','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID1010','ESID1010','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID1500' )  insert into BEST..TI17CHN values('ESID1500','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID1500' )  insert into BEST..TI17FNC values('ESID1500','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID1500','ESID1500','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID1520' )  insert into BEST..TI17CHN values('ESID1520','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID1520' )  insert into BEST..TI17FNC values('ESID1520','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID1520','ESID1520','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID1530' )  insert into BEST..TI17CHN values('ESID1530','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID1530' )  insert into BEST..TI17FNC values('ESID1530','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID1530','ESID1530','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID1550' )  insert into BEST..TI17CHN values('ESID1550','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID1550' )  insert into BEST..TI17FNC values('ESID1550','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID1550','ESID1550','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID1800' )  insert into BEST..TI17CHN values('ESID1800','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID1800' )  insert into BEST..TI17FNC values('ESID1800','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID1800','ESID1800','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID1900' )  insert into BEST..TI17CHN values('ESID1900','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID1900' )  insert into BEST..TI17FNC values('ESID1900','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID1900','ESID1900','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2000' )  insert into BEST..TI17CHN values('ESID2000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2000' )  insert into BEST..TI17FNC values('ESID2000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2000','ESID2000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2020' )  insert into BEST..TI17CHN values('ESID2020','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2020' )  insert into BEST..TI17FNC values('ESID2020','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2020','ESID2020','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2030' )  insert into BEST..TI17CHN values('ESID2030','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2030' )  insert into BEST..TI17FNC values('ESID2030','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2030','ESID2030','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2040' )  insert into BEST..TI17CHN values('ESID2040','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2040' )  insert into BEST..TI17FNC values('ESID2040','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2040','ESID2040','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2050' )  insert into BEST..TI17CHN values('ESID2050','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2050' )  insert into BEST..TI17FNC values('ESID2050','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2050','ESID2050','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2060' )  insert into BEST..TI17CHN values('ESID2060','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2060' )  insert into BEST..TI17FNC values('ESID2060','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2060','ESID2060','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2070' )  insert into BEST..TI17CHN values('ESID2070','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2070' )  insert into BEST..TI17FNC values('ESID2070','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2070','ESID2070','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2080' )  insert into BEST..TI17CHN values('ESID2080','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2080' )  insert into BEST..TI17FNC values('ESID2080','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2080','ESID2080','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2090' )  insert into BEST..TI17CHN values('ESID2090','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2090' )  insert into BEST..TI17FNC values('ESID2090','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2090','ESID2090','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2100' )  insert into BEST..TI17CHN values('ESID2100','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2100' )  insert into BEST..TI17FNC values('ESID2100','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2100','ESID2100','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2500' )  insert into BEST..TI17CHN values('ESID2500','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2500' )  insert into BEST..TI17FNC values('ESID2500','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2500','ESID2500','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2530' )  insert into BEST..TI17CHN values('ESID2530','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2530' )  insert into BEST..TI17FNC values('ESID2530','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2530','ESID2530','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2550' )  insert into BEST..TI17CHN values('ESID2550','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2550' )  insert into BEST..TI17FNC values('ESID2550','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2550','ESID2550','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2560' )  insert into BEST..TI17CHN values('ESID2560','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2560' )  insert into BEST..TI17FNC values('ESID2560','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2560','ESID2560','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2590' )  insert into BEST..TI17CHN values('ESID2590','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2590' )  insert into BEST..TI17FNC values('ESID2590','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2590','ESID2590','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID2800' )  insert into BEST..TI17CHN values('ESID2800','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID2800' )  insert into BEST..TI17FNC values('ESID2800','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID2800','ESID2800','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID3800' )  insert into BEST..TI17CHN values('ESID3800','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID3800' )  insert into BEST..TI17FNC values('ESID3800','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID3800','ESID3800','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID3810' )  insert into BEST..TI17CHN values('ESID3810','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID3810' )  insert into BEST..TI17FNC values('ESID3810','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID3810','ESID3810','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID3850' )  insert into BEST..TI17CHN values('ESID3850','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID3850' )  insert into BEST..TI17FNC values('ESID3850','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID3850','ESID3850','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID3900' )  insert into BEST..TI17CHN values('ESID3900','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID3900' )  insert into BEST..TI17FNC values('ESID3900','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID3900','ESID3900','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8030' )  insert into BEST..TI17CHN values('ESID8030','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8030' )  insert into BEST..TI17FNC values('ESID8030','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8030','ESID8030','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8040' )  insert into BEST..TI17CHN values('ESID8040','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8040' )  insert into BEST..TI17FNC values('ESID8040','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8040','ESID8040','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8050' )  insert into BEST..TI17CHN values('ESID8050','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8050' )  insert into BEST..TI17FNC values('ESID8050','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8050','ESID8050','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8100' )  insert into BEST..TI17CHN values('ESID8100','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8100' )  insert into BEST..TI17FNC values('ESID8100','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8100','ESID8100','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8120' )  insert into BEST..TI17CHN values('ESID8120','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8120' )  insert into BEST..TI17FNC values('ESID8120','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8120','ESID8120','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8530' )  insert into BEST..TI17CHN values('ESID8530','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8530' )  insert into BEST..TI17FNC values('ESID8530','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8530','ESID8530','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8700' )  insert into BEST..TI17CHN values('ESID8700','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8700' )  insert into BEST..TI17FNC values('ESID8700','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8700','ESID8700','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8710' )  insert into BEST..TI17CHN values('ESID8710','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8710' )  insert into BEST..TI17FNC values('ESID8710','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8710','ESID8710','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8800' )  insert into BEST..TI17CHN values('ESID8800','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8800' )  insert into BEST..TI17FNC values('ESID8800','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8800','ESID8800','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESID8900' )  insert into BEST..TI17CHN values('ESID8900','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESID8900' )  insert into BEST..TI17FNC values('ESID8900','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESID8900','ESID8900','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESIJ0010' )  insert into BEST..TI17CHN values('ESIJ0010','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESIJ0010' )  insert into BEST..TI17FNC values('ESIJ0010','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESIJ0010','ESIJ0010','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESIJ0090' )  insert into BEST..TI17CHN values('ESIJ0090','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESIJ0090' )  insert into BEST..TI17FNC values('ESIJ0090','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESIJ0090','ESIJ0090','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESIJ1000' )  insert into BEST..TI17CHN values('ESIJ1000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESIJ1000' )  insert into BEST..TI17FNC values('ESIJ1000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESIJ1000','ESIJ1000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='ESIJ7000' )  insert into BEST..TI17CHN values('ESIJ7000','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='ESIJ7000' )  insert into BEST..TI17FNC values('ESIJ7000','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','ESIJ7000','ESIJ7000','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='STAD1500' )  insert into BEST..TI17CHN values('STAD1500','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='STAD1500' )  insert into BEST..TI17FNC values('STAD1500','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','STAD1500','STAD1500','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='STAD1530' )  insert into BEST..TI17CHN values('STAD1530','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='STAD1530' )  insert into BEST..TI17FNC values('STAD1530','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','STAD1530','STAD1530','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='STAD1540' )  insert into BEST..TI17CHN values('STAD1540','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='STAD1540' )  insert into BEST..TI17FNC values('STAD1540','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','STAD1540','STAD1540','' ) 

	if not exists (select 1 from BEST..TI17CHN where CHAIN_CT='STAD1550' )  insert into BEST..TI17CHN values('STAD1550','') 
	if not exists (select 1 from BEST..TI17FNC where IDF_CT='STAD1550' )  insert into BEST..TI17FNC values('STAD1550','') 
	INSERT INTO BEST..TI17REQCHN  VALUES( 'I4IMINV','STAD1550','STAD1550','' ) 

go
