-------------------------------
--mapping of  ESPD1520

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD1520')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD1520')
	delete BEST..TI17FNC where CHAIN_CT='ESPD1520'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD1520'

	insert into BEST..TI17CHN values ('ESPD1520',  '')

	----------IDF_CT:   ESPD1520 ------------------

		insert into BEST..TI17FNC values ('ESPD1520',' ','ESPD1520',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_EPOSOCI','${DFILP}/${ENV_PREFIX}_ESPD0060_EPSOC_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID2030_IARVPERICASE0_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_ECRSOCAPC','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCAPC_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_ECRSOCRPC','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCRPC_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_ECRSOCACBP','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCACBP_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_ECRSOCRCBP','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCRCBP_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'ESPD1520','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'ESPD1520','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESPD1520','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'ESPD1520','')
go

