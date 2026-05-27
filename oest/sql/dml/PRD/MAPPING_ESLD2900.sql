-------------------------------
--mapping of  ESLD2900

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD2900')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD2900')
	delete BEST..TI17FNC where CHAIN_CT='ESLD2900'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD2900'

	insert into BEST..TI17CHN values ('ESLD2900',  '')

	----------IDF_CT:   ESLD2900 ------------------

		insert into BEST..TI17FNC values ('ESLD2900',' ','ESLD2900',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLSGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTRLO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLSGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTAALO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLSGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTARLO_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTRLO_CUR','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO_CUR_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTAALO_CUR','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO_CUR_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTARLO_CUR','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO_CUR_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLOPNGTRLO','${DFILP}/${ENV_PREFIX}_ESLD2900_DLOPNGTRLO_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLOPNGTAALO','${DFILP}/${ENV_PREFIX}_ESLD2900_DLOPNGTAALO_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLOPNGTARLO','${DFILP}/${ENV_PREFIX}_ESLD2900_DLOPNGTARLO_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTRLO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO_CURNEW_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTAALO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO_CURNEW_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTARLO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO_CURNEW_LOC.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('Y',  'ESLD2900','')
go

