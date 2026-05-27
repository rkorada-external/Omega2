-------------------------------
--mapping of  ESLD3850

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3850')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3850')
	delete BEST..TI17FNC where CHAIN_CT='ESLD3850'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD3850'

	insert into BEST..TI17CHN values ('ESLD3850',  '')

	----------IDF_CT:   ESLD3850 ------------------

		insert into BEST..TI17FNC values ('ESLD3850',' ','ESLD3850',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESLD3850',  'ESL_FTECLEDALO_MVT','${DFILP}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESLD3850','')
go

