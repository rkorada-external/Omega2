-------------------------------
--mapping of  ESID4000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID4000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID4000')
	delete BEST..TI17FNC where CHAIN_CT='ESID4000'
	delete BEST..TI17CHN  where CHAIN_CT='ESID4000'

	insert into BEST..TI17CHN values ('ESID4000',  '')

	----------IDF_CT:   ESID4000 ------------------

		insert into BEST..TI17FNC values ('ESID4000',' ','ESID4000',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID4000','')
go

