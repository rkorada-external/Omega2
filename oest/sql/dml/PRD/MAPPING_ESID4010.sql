-------------------------------
--mapping of  ESID4010

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID4010')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID4010')
	delete BEST..TI17FNC where CHAIN_CT='ESID4010'
	delete BEST..TI17CHN  where CHAIN_CT='ESID4010'

	insert into BEST..TI17CHN values ('ESID4010',  '')
go

