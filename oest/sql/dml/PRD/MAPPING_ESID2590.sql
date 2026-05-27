-------------------------------
--mapping of  ESID2590

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2590')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2590')
	delete BEST..TI17FNC where CHAIN_CT='ESID2590'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2590'

	insert into BEST..TI17CHN values ('ESID2590',  '')

	----------IDF_CT:   ESID2590 ------------------

		insert into BEST..TI17FNC values ('ESID2590',' ','ESID2590',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_FLIBEL1','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL1_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_TOTGTAR','${DFILP}/${ENV_PREFIX}_ESID2560_TOTGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID2590','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID2590','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID2590','@variante')
go

