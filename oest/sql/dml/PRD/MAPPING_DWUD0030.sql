-------------------------------
--mapping of  DWUD0030

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='DWUD0030')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='DWUD0030')
	delete BEST..TI17FNC where CHAIN_CT='DWUD0030'
	delete BEST..TI17CHN  where CHAIN_CT='DWUD0030'

	insert into BEST..TI17CHN values ('DWUD0030',  '')
go

