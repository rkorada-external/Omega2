-------------------------------
--mapping of  ESPD9990

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD9990')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD9990')
	delete BEST..TI17FNC where CHAIN_CT='ESPD9990'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD9990'

	insert into BEST..TI17CHN values ('ESPD9990',  'IFRS4 Post omega IFRS')

	----------IDF_CT:   ESPD9990 ------------------

		insert into BEST..TI17FNC values ('ESPD9990',' ','ESPD9990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'ESPD9990','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'ESPD9990','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'ESPD9990','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESPD9990','')
go

