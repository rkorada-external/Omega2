-------------------------------
--mapping of  ESID2090

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2090')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2090')
	delete BEST..TI17FNC where CHAIN_CT='ESID2090'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2090'

	insert into BEST..TI17CHN values ('ESID2090',  '')

	----------IDF_CT:   ESID2090 ------------------

		insert into BEST..TI17FNC values ('ESID2090',' ','ESID2090',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_FLIBEL1','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL1_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_TOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_TOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID2090','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID2090','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID2090','@variante')
go

