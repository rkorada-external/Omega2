-------------------------------
--mapping of  ESID0080

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0080')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0080')
	delete BEST..TI17FNC where CHAIN_CT='ESID0080'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0080'

	insert into BEST..TI17CHN values ('ESID0080',  '')

	----------IDF_CT:   ESID0080 ------------------

		insert into BEST..TI17FNC values ('ESID0080',' ','ESID0080',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID0080','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID0080','')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID0080','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESID0080','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'ESID0080','')
go

