-------------------------------
--mapping of  STPD0020

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STPD0020')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STPD0020')
	delete BEST..TI17FNC where CHAIN_CT='STPD0020'
	delete BEST..TI17CHN  where CHAIN_CT='STPD0020'

	insert into BEST..TI17CHN values ('STPD0020',  '')

	----------IDF_CT:   STPD0020 ------------------

		insert into BEST..TI17FNC values ('STPD0020',' ','STPD0020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'STPD0020','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'STPD0020','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'STPD0020','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'STPD0020','')
go

