-------------------------------
--mapping of  ESPD7000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD7000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD7000')
	delete BEST..TI17FNC where CHAIN_CT='ESPD7000'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD7000'

	insert into BEST..TI17CHN values ('ESPD7000',  '')

	----------IDF_CT:   ESPD7000 ------------------

		insert into BEST..TI17FNC values ('ESPD7000',' ','ESPD7000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLSGTRSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLREGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLRGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLSGTAASO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLSGTARSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLREGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLREMAJGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLREMAJGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTAR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTRSO','${DFILP}/${ENV_PREFIX}_ESPD7000_CMGTRSO.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTAASO','${DFILP}/${ENV_PREFIX}_ESPD7000_CMGTAASO.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTARSO','${DFILP}/${ENV_PREFIX}_ESPD7000_CMGTARSO.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTR','${DFILP}/${ENV_PREFIX}_ESPD7000_CMGTR_${BOOKING_D}_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CADVPERIESB0','${DFILP}/${ENV_PREFIX}_ESPD0060_CADVPERIESB0_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTAA','${DFILP}/${ENV_PREFIX}_ESPD7000_CMGTAA_${BOOKING_D}_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTAR','${DFILP}/${ENV_PREFIX}_ESPD7000_CMGTAR_${BOOKING_D}_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'ESPD7000','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESPD7000','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'ESPD7000','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'ESPD7000','')
go

