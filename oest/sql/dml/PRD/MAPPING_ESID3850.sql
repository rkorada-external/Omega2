-------------------------------
--mapping of  ESID3850

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3850')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3850')
	delete BEST..TI17FNC where CHAIN_CT='ESID3850'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3850'

	insert into BEST..TI17CHN values ('ESID3850',  '')

	----------IDF_CT:   ESID3850 ------------------

		insert into BEST..TI17FNC values ('ESID3850',' ','ESID3850',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID3850',  'EST_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESFD3930_FTECLEDA_DELTA_I4I_INV_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESID3850','')
go

