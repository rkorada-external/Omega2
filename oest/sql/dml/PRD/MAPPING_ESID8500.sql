-------------------------------
--mapping of  ESID8500

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8500')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8500')
	delete BEST..TI17FNC where CHAIN_CT='ESID8500'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8500'

	insert into BEST..TI17CHN values ('ESID8500',  '')

	----------IDF_CT:   ESID8500 ------------------

		insert into BEST..TI17FNC values ('ESID8500',' ','ESID8500',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID8500','')
go

