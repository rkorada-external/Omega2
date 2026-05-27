-------------------------------
--mapping of  ESED0300

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESED0300')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESED0300')
	delete BEST..TI17FNC where CHAIN_CT='ESED0300'
	delete BEST..TI17CHN  where CHAIN_CT='ESED0300'

	insert into BEST..TI17CHN values ('ESED0300',  '')

	----------IDF_CT:   ESED0300 ------------------

		insert into BEST..TI17FNC values ('ESED0300',' ','ESED0300',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESED0300','')
go

