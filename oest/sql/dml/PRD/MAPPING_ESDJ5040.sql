-------------------------------
--mapping of  ESDJ5040

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESDJ5040')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESDJ5040')
	delete BEST..TI17FNC where CHAIN_CT='ESDJ5040'
	delete BEST..TI17CHN  where CHAIN_CT='ESDJ5040'

	insert into BEST..TI17CHN values ('ESDJ5040',  '')

	----------IDF_CT:   ESDJ5040 ------------------

		insert into BEST..TI17FNC values ('ESDJ5040',' ','ESDJ5040',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESDJ5040','')
go

