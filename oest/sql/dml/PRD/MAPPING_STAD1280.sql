-------------------------------
--mapping of  STAD1280

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1280')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1280')
	delete BEST..TI17FNC where CHAIN_CT='STAD1280'
	delete BEST..TI17CHN  where CHAIN_CT='STAD1280'

	insert into BEST..TI17CHN values ('STAD1280',  '')

	----------IDF_CT:   STAD1280 ------------------

		insert into BEST..TI17FNC values ('STAD1280',' ','STAD1280',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'STAD1280','')
go

