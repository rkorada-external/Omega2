-------------------------------
--mapping of  ESRD0010

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESRD0010')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESRD0010')
	delete BEST..TI17FNC where CHAIN_CT='ESRD0010'
	delete BEST..TI17CHN  where CHAIN_CT='ESRD0010'

	insert into BEST..TI17CHN values ('ESRD0010',  '')
go

