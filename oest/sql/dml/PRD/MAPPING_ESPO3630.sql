-------------------------------
--mapping of  ESPO3630

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPO3630')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPO3630')
	delete BEST..TI17FNC where CHAIN_CT='ESPO3630'
	delete BEST..TI17CHN  where CHAIN_CT='ESPO3630'

	insert into BEST..TI17CHN values ('ESPO3630',  'UPR cancellation chain ESPD3630')
go

