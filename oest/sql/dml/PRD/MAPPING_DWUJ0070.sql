-------------------------------
--mapping of  DWUJ0070

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='DWUJ0070')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='DWUJ0070')
	delete BEST..TI17FNC where CHAIN_CT='DWUJ0070'
	delete BEST..TI17CHN  where CHAIN_CT='DWUJ0070'

	insert into BEST..TI17CHN values ('DWUJ0070',  '')

	----------IDF_CT:   DWUJ0070 ------------------

		insert into BEST..TI17FNC values ('DWUJ0070',' ','DWUJ0070',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'DWUJ0070','')
go

