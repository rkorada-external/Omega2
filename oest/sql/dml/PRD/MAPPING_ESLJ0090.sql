-------------------------------
--mapping of  ESLJ0090

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLJ0090')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLJ0090')
	delete BEST..TI17FNC where CHAIN_CT='ESLJ0090'
	delete BEST..TI17CHN  where CHAIN_CT='ESLJ0090'

	insert into BEST..TI17CHN values ('ESLJ0090',  '')

	----------IDF_CT:   ESLJ0090 ------------------

		insert into BEST..TI17FNC values ('ESLJ0090',' ','ESLJ0090',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FCES','${DFILP}/${ENV_PREFIX}_ESID7000_FCES.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FPLC','${DFILP}/${ENV_PREFIX}_ESID7000_FPLC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESID7000_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESID7000_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESID7000_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_IADVPERICASE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_EPOSOCLO','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_EPOSOCLO_CUR','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_CUR_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_EPOSOCLO_NEW','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_NEW_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_EPOSOCLO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_CURNEW_LOC.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('Y',  'ESLJ0090','')
go

