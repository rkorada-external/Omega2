-------------------------------
--mapping of  ESPD3850

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD3850')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD3850')
	delete BEST..TI17FNC where CHAIN_CT='ESPD3850'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3850'

	insert into BEST..TI17CHN values ('ESPD3850',  '')

	----------IDF_CT:   I4I_ESPD3850 ------------------

		insert into BEST..TI17FNC values ('I4I_ESPD3850','IFRS4 Post omega IFRS','ESPD3850',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESPD3850',  'EPO_FTECLEDACO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_I4I_POC_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD3850',  'EPO_FTECLEDASIICO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_I4I_POC_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD3850',  'EPO_FTECLEDRCO','${DFILP}/${ENV_PREFIX}_ES${PARM_FTECLED}D3800_FTECLEDR_I4I_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD3850',  'EPO_FTECLEDRSIICO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDR_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD3850',  'EPO_FTECLEDASO_MVT','${DFILP}/${ENV_PREFIX}_ESFD3930_FTECLEDA_DELTA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'I4I_ESPD3850','')
go

