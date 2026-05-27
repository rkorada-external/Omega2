-------------------------------
--mapping of  ESID8050

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8050')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8050')
	delete BEST..TI17FNC where CHAIN_CT='ESID8050'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8050'

	insert into BEST..TI17CHN values ('ESID8050',  '')

	----------IDF_CT:   ESID8050 ------------------

		insert into BEST..TI17FNC values ('ESID8050',' ','ESID8050',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_NPSAIS','${DFILP}/${ENV_PREFIX}_ESID2000_NPSAIS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_IBNR_EBS','${DFILP}/${ENV_PREFIX}_ESID2000_IBNR_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_PNARETRO','${DFILP}/${ENV_PREFIX}_ESID0060_PNARETRO_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_IBNR_IFRS','${DFILP}/${ENV_PREFIX}_ESID2000_IBNR_IFRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_FUTURE_EBS','${DFILP}/${ENV_PREFIX}_ESID2000_FUTURE_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_BLANCHIMENT_RPCC','${DFILP}/${ENV_PREFIX}_ESID2000_BLANCHIMENT_RPCC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID8050','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID8050','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID8050','@variante')
go

