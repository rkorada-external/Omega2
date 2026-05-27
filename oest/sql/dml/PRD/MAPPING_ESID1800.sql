-------------------------------
--mapping of  ESID1800

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1800')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1800')
	delete BEST..TI17FNC where CHAIN_CT='ESID1800'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1800'

	insert into BEST..TI17CHN values ('ESID1800',  '')

	----------IDF_CT:   ESID1800 ------------------

		insert into BEST..TI17FNC values ('ESID1800',' ','ESID1800',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FACCSUP','${DFILP}/${ENV_PREFIX}_ESID0560_FACCSUP_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_DLSGTR','${DFILP}/${ENV_PREFIX}_ESID1800_DLSGTR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_DLSGTAA','${DFILP}/${ENV_PREFIX}_ESID1800_DLSGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_DLSGTAR','${DFILP}/${ENV_PREFIX}_ESID1800_DLSGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID1800','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID1800','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID1800','@variante')
go

