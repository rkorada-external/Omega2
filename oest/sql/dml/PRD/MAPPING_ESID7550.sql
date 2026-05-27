-------------------------------
--mapping of  ESID7550

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID7550')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID7550')
	delete BEST..TI17FNC where CHAIN_CT='ESID7550'
	delete BEST..TI17CHN  where CHAIN_CT='ESID7550'

	insert into BEST..TI17CHN values ('ESID7550',  '')

	----------IDF_CT:   ESID7550 ------------------

		insert into BEST..TI17FNC values ('ESID7550',' ','ESID7550',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID7550',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID7550','@variante')
go

