-------------------------------
--mapping of  ESEJ0230

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEJ0230')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEJ0230')
	delete BEST..TI17FNC where CHAIN_CT='ESEJ0230'
	delete BEST..TI17CHN  where CHAIN_CT='ESEJ0230'

	insert into BEST..TI17CHN values ('ESEJ0230',  '')

	----------IDF_CT:   ESEJ0230 ------------------

		insert into BEST..TI17FNC values ('ESEJ0230',' ','ESEJ0230',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESEJ0230','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'ESEJ0230','')
go

