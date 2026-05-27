-------------------------------
--mapping of  ESID3700

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3700')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3700')
	delete BEST..TI17FNC where CHAIN_CT='ESID3700'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3700'

	insert into BEST..TI17CHN values ('ESID3700',  '')
go

