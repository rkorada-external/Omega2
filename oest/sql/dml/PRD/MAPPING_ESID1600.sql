-------------------------------
--mapping of  ESID1600

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1600')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1600')
	delete BEST..TI17FNC where CHAIN_CT='ESID1600'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1600'

	insert into BEST..TI17CHN values ('ESID1600',  '')
go

