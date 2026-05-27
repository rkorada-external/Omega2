-------------------------------
--mapping of  ESID8710

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8710')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8710')
	delete BEST..TI17FNC where CHAIN_CT='ESID8710'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8710'

	insert into BEST..TI17CHN values ('ESID8710',  '')

	----------IDF_CT:   ESID8710 ------------------

		insert into BEST..TI17FNC values ('ESID8710',' ','ESID8710',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDA_PC','${DFILP}/${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDR_PC','${DFILP}/${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDA_DIFF','${DFILI}/${ENV_PREFIX}_ESID8710_DIFF_FTECLEDA_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDR_DIFF','${DFILI}/${ENV_PREFIX}_ESID8710_DIFF_FTECLEDR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID8710','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESID8710','')
go

