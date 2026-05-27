-------------------------------
--mapping of  ESEJ0210

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEJ0210')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEJ0210')
	delete BEST..TI17FNC where CHAIN_CT='ESEJ0210'
	delete BEST..TI17CHN  where CHAIN_CT='ESEJ0210'

	insert into BEST..TI17CHN values ('ESEJ0210',  '')

	----------IDF_CT:   ESEJ0210 ------------------

		insert into BEST..TI17FNC values ('ESEJ0210',' ','ESEJ0210',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESEJ0210','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'ESEJ0210','')
go

