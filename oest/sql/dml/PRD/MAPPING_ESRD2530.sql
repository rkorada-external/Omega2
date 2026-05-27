-------------------------------
--mapping of  ESRD2530

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESRD2530')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESRD2530')
	delete BEST..TI17FNC where CHAIN_CT='ESRD2530'
	delete BEST..TI17CHN  where CHAIN_CT='ESRD2530'

	insert into BEST..TI17CHN values ('ESRD2530',  '')
go

