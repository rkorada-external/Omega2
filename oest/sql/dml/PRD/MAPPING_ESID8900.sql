-------------------------------
--mapping of  ESID8900

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8900')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8900')
	delete BEST..TI17FNC where CHAIN_CT='ESID8900'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8900'

	insert into BEST..TI17CHN values ('ESID8900',  '')

	----------IDF_CT:   ESID8900 ------------------

		insert into BEST..TI17FNC values ('ESID8900',' ','ESID8900',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8900',  'EST_FCTRSTAT','${DFILP}/${ENV_PREFIX}_ESID3900_FCTRSTAT_I4I_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8900',  'EST_FSEGSTAT','${DFILP}/${ENV_PREFIX}_ESID3900_FSEGSTAT_I4I_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID8900','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID8900','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID8900','@variante')
go

