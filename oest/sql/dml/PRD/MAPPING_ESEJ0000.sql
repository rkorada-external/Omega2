-------------------------------
--mapping of  ESEJ0000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEJ0000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEJ0000')
	delete BEST..TI17FNC where CHAIN_CT='ESEJ0000'
	delete BEST..TI17CHN  where CHAIN_CT='ESEJ0000'

	insert into BEST..TI17CHN values ('ESEJ0000',  '')

	----------IDF_CT:   ESEJ0000 ------------------

		insert into BEST..TI17FNC values ('ESEJ0000',' ','ESEJ0000',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESEJ0000','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESEJ0000','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'ESEJ0000','')
go

