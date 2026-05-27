-------------------------------
--mapping of  ESFD2000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD2000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD2000')
	delete BEST..TI17FNC where CHAIN_CT='ESFD2000'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD2000'

	insert into BEST..TI17CHN values ('ESFD2000',  '')
go

