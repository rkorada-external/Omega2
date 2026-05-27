-------------------------------
--mapping of  ESPD8050

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8050')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8050')
	delete BEST..TI17FNC where CHAIN_CT='ESPD8050'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8050'

	insert into BEST..TI17CHN values ('ESPD8050',  '')
go

