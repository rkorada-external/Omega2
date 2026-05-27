-------------------------------
--mapping of  ESID8060

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8060')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8060')
	delete BEST..TI17FNC where CHAIN_CT='ESID8060'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8060'

	insert into BEST..TI17CHN values ('ESID8060',  '')

	----------IDF_CT:   ESID8060 ------------------

		insert into BEST..TI17FNC values ('ESID8060',' ','ESID8060',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID8060','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID8060','')
go

