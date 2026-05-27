-------------------------------
--mapping of  ESDJ5020

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESDJ5020')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESDJ5020')
	delete BEST..TI17FNC where CHAIN_CT='ESDJ5020'
	delete BEST..TI17CHN  where CHAIN_CT='ESDJ5020'

	insert into BEST..TI17CHN values ('ESDJ5020',  '')

	----------IDF_CT:   ESDJ5020 ------------------

		insert into BEST..TI17FNC values ('ESDJ5020',' ','ESDJ5020',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FESB','${DFILP}/${ENV_PREFIX}_ESDJ0110_FESB_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_SUBTRS','${DFILP}/${ENV_PREFIX}_ESDJ1010_SUBTRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FACCPAR0','${DFILP}/${ENV_PREFIX}_ESDJ1010_FACCPAR0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FAVERATE','${DFILP}/${ENV_PREFIX}_ESDJ0110_FAVERATE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_SUBTRSASSO','${DFILP}/${ENV_PREFIX}_ESDJ1010_SUBTRSASSO_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FSUBTRSBASE','${DFILP}/${ENV_PREFIX}_ESDJ0110_FSUBTRSBASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FIDLIFEST_MVT','${DFILP}/${ENV_PREFIX}_ESDJ0110_FIDLIFEST_MVT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_IARVPERICASE4','${DFILP}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE4_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'STA_LIFSTAREP_PLAN','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FIDLIFEST_CALL','${DFILP}/${ENV_PREFIX}_ESDJ0110_FIDLIFEST_CALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ5020',  'SAVED_LIFSTAREP_PLAN','${DFILP}/${ENV_PREFIX}_ESDJ5020_LIFSTAREP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESDJ5020','')
go

