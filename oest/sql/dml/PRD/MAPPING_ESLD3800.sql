-------------------------------
--mapping of  ESLD3800

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3800')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3800')
	delete BEST..TI17FNC where CHAIN_CT='ESLD3800'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD3800'

	insert into BEST..TI17CHN values ('ESLD3800',  '')

	----------IDF_CT:   ESLD3800 ------------------

		insert into BEST..TI17FNC values ('ESLD3800',' ','ESLD3800',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FCLIENT','${DFILP}/${ENV_PREFIX}_ESID7000_FCLIENT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID7000_FCPLACC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID7000_FCTRGRO.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FSUBTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FSUBTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FSOBBLOB','${DFILP}/${ENV_PREFIX}_ESID7000_FSOBBLOB.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESID7000_FSSDACTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FPLACEMT2','${DFILP}/${ENV_PREFIX}_ESID7000_FPLACEMT2.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLSGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTRLO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLSGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTAALO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLSGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTARLO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLREJGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLREJGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLREJGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_OIADVPERICASE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_OIRDVPERICASE.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FTECLEDALO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDA_I4I_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FTECLEDRLO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDR_I4I_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FTECLEDALO_MTH','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDA_MTH_I4I_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FTECLEDALO_MVT','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDA_MVT_I4I_LOC.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('Y',  'ESLD3800','')
go

