-------------------------------
--mapping of  ESID2060

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2060')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2060')
	delete BEST..TI17FNC where CHAIN_CT='ESID2060'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2060'

	insert into BEST..TI17CHN values ('ESID2060',  '')

	----------IDF_CT:   ESID2060 ------------------

		insert into BEST..TI17FNC values ('ESID2060',' ','ESID2060',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_MGTAA','${DFILP}/${ENV_PREFIX}_ESIX7000_MGTAA${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_IGTAAF','${DFILP}/${ENV_PREFIX}_ESID0560_IGTAAF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLAGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLSGTAA','${DFILP}/${ENV_PREFIX}_ESID1800_DLSGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_MVTPNAC','${DFILP}/${ENV_PREFIX}_ESID0560_MVTPNAC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLGTAASNEM','${DFILP}/${ENV_PREFIX}_ESID2100_DLGTAASNEM_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLVGTAA','`ls -rt ${DFILP}/${ENV_PREFIX}_ESID2080_DLVGTAA_PC_${PARM_ICLODAT_D}*.dat | tail -1 `','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_TOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_TOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLTOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_DLTOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLTOTITGTAR','${DFILP}/${ENV_PREFIX}_ESID2060_DLTOTITGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID2060','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID2060','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID2060','@variante')

	----------IDF_CT:   ESID2060_I4_PC___ ------------------

		insert into BEST..TI17FNC values ('ESID2060_I4_PC___',' ','ESID2060',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLVGTAA','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_MGTAA','${DFILP}/${ENV_PREFIX}_ESIX7000_MGTAA${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_IGTAAF','${DFILP}/${ENV_PREFIX}_ESID0560_IGTAAF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLAGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLSGTAA','${DFILP}/${ENV_PREFIX}_ESID1800_DLSGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_MVTPNAC','${DFILP}/${ENV_PREFIX}_ESID0560_MVTPNAC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLGTAASNEM','${DFILP}/${ENV_PREFIX}_ESID2100_DLGTAASNEM_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLRGTAA','${DFILP}/${ENV_PREFIX}_ESID2050_I4_PC___DLRGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_TOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_I4_PC___TOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLTOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_I4_PC___DLTOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLTOTITGTAR','${DFILP}/${ENV_PREFIX}_ESID2060_I4_PC___DLTOTITGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

go

