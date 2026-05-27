-------------------------------
--mapping of  ESLJ8990

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLJ8990')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLJ8990')
	delete BEST..TI17FNC where CHAIN_CT='ESLJ8990'
	delete BEST..TI17CHN  where CHAIN_CT='ESLJ8990'

	insert into BEST..TI17CHN values ('ESLJ8990',  '')

	----------IDF_CT:   ESLJ8990 ------------------

		insert into BEST..TI17FNC values ('ESLJ8990',' ','ESLJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('Y',  'ESLJ8990','')
go

