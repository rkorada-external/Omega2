-------------------------------
--mapping of  BTID0090

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='BTID0090')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='BTID0090')
	delete BEST..TI17FNC where CHAIN_CT='BTID0090'
	delete BEST..TI17CHN  where CHAIN_CT='BTID0090'

	insert into BEST..TI17CHN values ('BTID0090',  '')
go

