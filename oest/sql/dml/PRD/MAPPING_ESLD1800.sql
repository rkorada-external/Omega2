-------------------------------
--mapping of  ESLD1800

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD1800')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD1800')
	delete BEST..TI17FNC where CHAIN_CT='ESLD1800'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD1800'

	insert into BEST..TI17CHN values ('ESLD1800',  '')

	----------IDF_CT:   ESLD1800 ------------------

		insert into BEST..TI17FNC values ('ESLD1800',' ','ESLD1800',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FCES','${DFILP}/${ENV_PREFIX}_ESID7000_FCES.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FPLC','${DFILP}/${ENV_PREFIX}_ESID7000_FPLC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESID7000_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESID7000_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESID7000_FPLATXCUM.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_EPOSOCLO','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESID7000_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_IADVPERICASE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_OIRDVPERICASE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_DLSGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTRLO_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_DLSGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTAALO_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_DLSGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTARLO_LOC.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('Y',  'ESLD1800','')
go

