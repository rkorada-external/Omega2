-------------------------------
--mapping of  ESCJ0000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESCJ0000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESCJ0000')
	delete BEST..TI17FNC where CHAIN_CT='ESCJ0000'
	delete BEST..TI17CHN  where CHAIN_CT='ESCJ0000'

	insert into BEST..TI17CHN values ('ESCJ0000',  '')

	----------IDF_CT:   ESCJ0000 ------------------

		insert into BEST..TI17FNC values ('ESCJ0000',' ','ESCJ0000',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

go

