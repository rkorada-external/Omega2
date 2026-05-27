-------------------------------
--mapping of  ESIJ1000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ1000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ1000')
	delete BEST..TI17FNC where CHAIN_CT='ESIJ1000'
	delete BEST..TI17CHN  where CHAIN_CT='ESIJ1000'

	insert into BEST..TI17CHN values ('ESIJ1000',  '')

	----------IDF_CT:   ESIJ1000 ------------------

		insert into BEST..TI17FNC values ('ESIJ1000',' ','ESIJ1000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESIJ1000',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ1000',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESIJ1000','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESIJ1000','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESIJ1000','@variante')
go

