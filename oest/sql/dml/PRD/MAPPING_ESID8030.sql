-------------------------------
--mapping of  ESID8030

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8030')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8030')
	delete BEST..TI17FNC where CHAIN_CT='ESID8030'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8030'

	insert into BEST..TI17CHN values ('ESID8030',  '')

	----------IDF_CT:   ESID8030 ------------------

		insert into BEST..TI17FNC values ('ESID8030',' ','ESID8030',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_FLIFMOD','${DFILP}/${ENV_PREFIX}_ESID1530_FLIFMOD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_FLIFPEN','${DFILP}/${ENV_PREFIX}_ESID1530_FLIFPEN_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_FLIFMOD2','${DFILP}/${ENV_PREFIX}_ESID1530_FLIFMOD2_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_CPLIFDRI','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFDRIY_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_CPLIFDRIQ','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFDRIQ_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_FRATTACHEVOL','${DFILP}/${ENV_PREFIX}_ESID2030_FRATTACHEVOL_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_CPLIFEST_MVT','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFEST_MVTY_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_CPLIFEST_MVTQ','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFEST_MVTQ_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID8030','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID8030','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID8030','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID8030','@variante')
go

