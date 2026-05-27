-------------------------------
--mapping of  ESID1530

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1530')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1530')
	delete BEST..TI17FNC where CHAIN_CT='ESID1530'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1530'

	insert into BEST..TI17CHN values ('ESID1530',  '')

	----------IDF_CT:   ESID1530 ------------------

		insert into BEST..TI17FNC values ('ESID1530',' ','ESID1530',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FLIFTHR','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIFTHR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_CPLIFDRI','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFDRI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_CPLIFEST','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFEST_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_CPLIFESTQ','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFESTQ_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_SUBTRSBASE','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRSBASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID2030_IARVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FLIFMOD','${DFILP}/${ENV_PREFIX}_ESID1530_FLIFMOD_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FLIFPEN','${DFILP}/${ENV_PREFIX}_ESID1530_FLIFPEN_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FLIFMOD2','${DFILP}/${ENV_PREFIX}_ESID1530_FLIFMOD2_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID1530','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID1530','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID1530','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID1530','@variante')
go

