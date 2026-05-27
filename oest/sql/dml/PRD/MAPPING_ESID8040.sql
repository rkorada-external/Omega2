-------------------------------
--mapping of  ESID8040

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8040')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8040')
	delete BEST..TI17FNC where CHAIN_CT='ESID8040'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8040'

	insert into BEST..TI17CHN values ('ESID8040',  '')

	----------IDF_CT:   ESID8040 ------------------

		insert into BEST..TI17FNC values ('ESID8040',' ','ESID8040',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_SUBTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_CMPCALC','${DFILP}/${ENV_PREFIX}_ESID2040_CMPCALC_PC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_TGAPTHR','${DFILP}/${ENV_PREFIX}_ESID8040_TGAPTHR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_FLIFEST0','${DFILP}/${ENV_PREFIX}_ESID8040_FLIFEST0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID8040','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID8040','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID8040','@variante')
go

