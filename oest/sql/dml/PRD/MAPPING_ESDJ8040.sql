-------------------------------
--mapping of  ESDJ8040

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESDJ8040')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESDJ8040')
	delete BEST..TI17FNC where CHAIN_CT='ESDJ8040'
	delete BEST..TI17CHN  where CHAIN_CT='ESDJ8040'

	insert into BEST..TI17CHN values ('ESDJ8040',  '')

	----------IDF_CT:   ESDJ8040 ------------------

		insert into BEST..TI17FNC values ('ESDJ8040',' ','ESDJ8040',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_TCALL','${DFILP}/${ENV_PREFIX}_ESDJ0110_TCALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SUBTRS','${DFILP}/${ENV_PREFIX}_ESDJ1010_SUBTRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_TGAPTHR','${DFILP}/${ENV_PREFIX}_ESDJ0110_TGAPTHR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SRGTC','${DFILP}/${ENV_PREFIX}_ESDJ7010_SRGTC${IT}_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_FACCPAR0','${DFILP}/${ENV_PREFIX}_ESDJ1010_FACCPAR0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SUBTRSASSO','${DFILP}/${ENV_PREFIX}_ESDJ1010_SUBTRSASSO_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_CPLIFDRI','${DFILP}/${ENV_PREFIX}_ESDJ7010_CPLIFDRI${IT}_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_VLIFEST195','${DFILP}/${ENV_PREFIX}_ESDJ7010_VLIFEST195${IT}_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_IARVPERICASE4','${DFILP}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE4_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SUBTRSESBPROP','${DFILP}/${ENV_PREFIX}_ESDJ1010_SUBTRSESBPROP_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SIGNANO','${DFILP}/${ENV_PREFIX}_ESDJ8040_SIGNANO${IT}_${TYPEINV}_${ICLODAT2}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SRGTE','${DFILP}/${ENV_PREFIX}_ESDJ8040_SRGTE${IT}_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_CMPCALC','${DFILP}/${ENV_PREFIX}_ESDJ8040_CMPCALC_PC${IT}_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_CMPCALC_PC','${DFILP}/${ENV_PREFIX}_ESDJ8040_CMPCALC_PC${IT}_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESDJ8040','')
go

