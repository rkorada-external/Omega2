-------------------------------
--mapping of  ESCJ8990

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESCJ8990')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESCJ8990')
	delete BEST..TI17FNC where CHAIN_CT='ESCJ8990'
	delete BEST..TI17CHN  where CHAIN_CT='ESCJ8990'

	insert into BEST..TI17CHN values ('ESCJ8990',  '')

	----------IDF_CT:   ESCJ8990 ------------------

		insert into BEST..TI17FNC values ('ESCJ8990',' ','ESCJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESCJ8990','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESCJ8990','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESCJ8990','')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESCJ8990','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESCJ8990','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESCJ8990','')
go

