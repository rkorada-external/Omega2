-------------------------------
--mapping of  ESARCH00

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESARCH00')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESARCH00')
	delete BEST..TI17FNC where CHAIN_CT='ESARCH00'
	delete BEST..TI17CHN  where CHAIN_CT='ESARCH00'

	insert into BEST..TI17CHN values ('ESARCH00',  'Archive permanet files')
go

