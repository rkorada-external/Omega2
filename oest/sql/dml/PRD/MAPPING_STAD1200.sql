-------------------------------
--mapping of  STAD1200

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1200')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1200')
	delete BEST..TI17FNC where CHAIN_CT='STAD1200'
	delete BEST..TI17CHN  where CHAIN_CT='STAD1200'

	insert into BEST..TI17CHN values ('STAD1200',  '')

	----------IDF_CT:   STAD1200 ------------------

		insert into BEST..TI17FNC values ('STAD1200',' ','STAD1200',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'STAD1200','')
go

