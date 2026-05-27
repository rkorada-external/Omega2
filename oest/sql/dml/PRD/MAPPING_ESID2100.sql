-------------------------------
--mapping of  ESID2100

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2100')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2100')
	delete BEST..TI17FNC where CHAIN_CT='ESID2100'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2100'

	insert into BEST..TI17CHN values ('ESID2100',  '')

	----------IDF_CT:   ESID2100 ------------------

		insert into BEST..TI17FNC values ('ESID2100',' ','ESID2100',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FSNEMHIST','${DFILP}/${ENV_PREFIX}_ESID0560_FSNEMHIST_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FLOARATSNEM','${DFILP}/${ENV_PREFIX}_ESID2000_FLOARATSNEM_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DSUMGTAASNEM','${DFILP}/${ENV_PREFIX}_ESID2000_DSUMGTAASNEM_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_PERICASESNEM','${DFILP}/${ENV_PREFIX}_ESID2000_PERICASESNEM_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLGTRSNEM','${DFILP}/${ENV_PREFIX}_ESID2100_DLGTRSNEM_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLGTAASNEM','${DFILP}/${ENV_PREFIX}_ESID2100_DLGTAASNEM_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLGTARSNEM','${DFILP}/${ENV_PREFIX}_ESID2100_DLGTARSNEM_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLFTSNEMHIST','${DFILP}/${ENV_PREFIX}_ESID2100_DLFTSNEMHIST_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID2100','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID2100','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID2100','@variante')
go

