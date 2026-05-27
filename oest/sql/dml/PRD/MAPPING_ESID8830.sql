-------------------------------
--mapping of  ESID8830

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8830')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8830')
	delete BEST..TI17FNC where CHAIN_CT='ESID8830'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8830'

	insert into BEST..TI17CHN values ('ESID8830',  '')

	----------IDF_CT:   ESID8830 ------------------

		insert into BEST..TI17FNC values ('ESID8830',' ','ESID8830',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_DLTOTGTRC','${DFILP}/${ENV_PREFIX}_ESID7000_DLTOTGTRC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_DLTOTGTAAC','${DFILP}/${ENV_PREFIX}_ESID7000_DLTOTGTAAC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_DLTOTGTARC','${DFILP}/${ENV_PREFIX}_ESID7000_DLTOTGTARC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID8830','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID8830','@variante')
go

