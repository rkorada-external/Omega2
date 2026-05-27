-------------------------------
--mapping of  ESID8600

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8600')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8600')
	delete BEST..TI17FNC where CHAIN_CT='ESID8600'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8600'

	insert into BEST..TI17CHN values ('ESID8600',  '')

	----------IDF_CT:   ESID8600 ------------------

		insert into BEST..TI17FNC values ('ESID8600',' ','ESID8600',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8600',  'EST_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESID3700_FTECLED_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

go

