-------------------------------
--mapping of  ESID9990

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID9990')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID9990')
	delete BEST..TI17FNC where CHAIN_CT='ESID9990'
	delete BEST..TI17CHN  where CHAIN_CT='ESID9990'

	insert into BEST..TI17CHN values ('ESID9990',  '')

	----------IDF_CT:   ESID9990 ------------------

		insert into BEST..TI17FNC values ('ESID9990','I4I Booking','ESID9990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID9990','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID9990','')
go

