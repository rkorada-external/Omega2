-------------------------------
--mapping of  ESIJ2000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ2000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ2000')
	delete BEST..TI17FNC where CHAIN_CT='ESIJ2000'
	delete BEST..TI17CHN  where CHAIN_CT='ESIJ2000'

	insert into BEST..TI17CHN values ('ESIJ2000',  '')

	----------IDF_CT:   ESIJ2000 ------------------

		insert into BEST..TI17FNC values ('ESIJ2000',' ','ESIJ2000',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESIJ2000','')
go

