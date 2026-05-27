-------------------------------
--mapping of  ESID3020

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3020')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3020')
	delete BEST..TI17FNC where CHAIN_CT='ESID3020'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3020'

	insert into BEST..TI17CHN values ('ESID3020',  '')

	----------IDF_CT:   ESID3020 ------------------

		insert into BEST..TI17FNC values ('ESID3020',' ','ESID3020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID3020','')
go

