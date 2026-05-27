-------------------------------
--mapping of  ESID2800

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2800')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2800')
	delete BEST..TI17FNC where CHAIN_CT='ESID2800'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2800'

	insert into BEST..TI17CHN values ('ESID2800',  '')

	----------IDF_CT:   ESID2800 ------------------

		insert into BEST..TI17FNC values ('ESID2800',' ','ESID2800',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_TOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_TOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_TOTGTAR','${DFILP}/${ENV_PREFIX}_ESID2560_TOTGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_DLREJGTAA','${DFILP}/${ENV_PREFIX}_ESID2900_DLREJGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_DLREJGTAR','${DFILP}/${ENV_PREFIX}_ESID2900_DLREJGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID2800','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID2800','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID2800','@variante')
go

