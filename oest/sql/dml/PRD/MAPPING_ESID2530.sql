-------------------------------
--mapping of  ESID2530

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2530')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2530')
	delete BEST..TI17FNC where CHAIN_CT='ESID2530'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2530'

	insert into BEST..TI17CHN values ('ESID2530',  '')

	----------IDF_CT:   ESID2530 ------------------

		insert into BEST..TI17FNC values ('ESID2530',' ','ESID2530',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCESANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FCESANT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FPLCANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FPLCANT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_TOTGTR','${DFILP}/${ENV_PREFIX}_ESID2560_TOTGTR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_TOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_TOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_TOTGTAR','${DFILP}/${ENV_PREFIX}_ESID2560_TOTGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FACCTRAA','${DFILP}/${ENV_PREFIX}_ESID0560_FACCTRAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FACCTRAI','${DFILP}/${ENV_PREFIX}_ESID0560_FACCTRAI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCMUSPLI','${DFILP}/${ENV_PREFIX}_ESID0560_FCMUSPLI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FOUTTRAA','${DFILP}/${ENV_PREFIX}_ESID0560_FOUTTRAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCMUSPLIT','${DFILP}/${ENV_PREFIX}_ESID0560_FCMUSPLIT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FRAPP','${DFILP}/${ENV_PREFIX}_ESID2530_FRAPP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID2530','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID2530','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID2530','@variante')
go

