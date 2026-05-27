-------------------------------
--mapping of  ESIJ0010

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ0010')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ0010')
	delete BEST..TI17FNC where CHAIN_CT='ESIJ0010'
	delete BEST..TI17CHN  where CHAIN_CT='ESIJ0010'

	insert into BEST..TI17CHN values ('ESIJ0010',  '')

	----------IDF_CT:   ESIJ0010 ------------------

		insert into BEST..TI17FNC values ('ESIJ0010',' ','ESIJ0010',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESIJ0010','')
go

