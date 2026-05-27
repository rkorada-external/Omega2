-------------------------------
--mapping of  ESID1550

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1550')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1550')
	delete BEST..TI17FNC where CHAIN_CT='ESID1550'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1550'

	insert into BEST..TI17CHN values ('ESID1550',  '')

	----------IDF_CT:   ESID1550 ------------------

		insert into BEST..TI17FNC values ('ESID1550',' ','ESID1550',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FACCSUP','${DFILP}/${ENV_PREFIX}_ESID0560_FACCSUP_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_RETPNAGTR','${DFILP}/${ENV_PREFIX}_ESID0060_RETPNAGTR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_DLRNPGTR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_DLRNPGTAA','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_DLRNPGTAR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID1550','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID1550','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID1550','@variante')
go

