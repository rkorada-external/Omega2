-------------------------------
--mapping of  ESPD2900

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD2900')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD2900')
	delete BEST..TI17FNC where CHAIN_CT='ESPD2900'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD2900'

	insert into BEST..TI17CHN values ('ESPD2900',  '')

	----------IDF_CT:   EBS_ESPD2900 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD2900','Annual EBS opening','ESPD2900',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------


	----------IDF_CT:   I4I_ESPD2900 ------------------

		insert into BEST..TI17FNC values ('I4I_ESPD2900','Annual I4I opening','ESPD2900',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'ESF_FCTRI17PRD_NEW','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESID0560_FPLATXCUM_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLSGTRSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLREGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLRGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLSGTAASO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLSGTARSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLREGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLREMAJGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLREMAJGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTAR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLREJGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLREJGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTAA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2900',  'EPO_DLREJGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTAR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I4I_ESPD2900','')
go

