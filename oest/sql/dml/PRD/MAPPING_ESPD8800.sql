-------------------------------
--mapping of  ESPD8800

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8800')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8800')
	delete BEST..TI17FNC where CHAIN_CT='ESPD8800'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8800'

	insert into BEST..TI17CHN values ('ESPD8800',  '')

	----------IDF_CT:   EBS_ESPD8800 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD8800',' ','ESPD8800',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD8800',  'EPO_FTECLEDRSIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDR_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8800',  'EPO_FTECLEDASO_EBS','${DFILP}/${ENV_PREFIX}_ES${PARM_FTECLED}D8700_FTECLEDA_I4I_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8800',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3970_EBS_MVT_MRG_STD_FTECLEDA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8800',  'EPO_FTECLEDRSO','`if [ "${TYPEINV}" = "INV" ];then echo ${DFILP}/${ENV_PREFIX}_ESID8700_PC___FTECLEDR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat;else echo ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDR_I4I_${PARM_ICLODAT_D}.dat;fi;`','I','')

		----------   Reqs    ---------------------


	----------IDF_CT:   I4I_ESPD8800 ------------------

		insert into BEST..TI17FNC values ('I4I_ESPD8800',' ','ESPD8800',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESPD8800',  'EPO_FTECLEDRSO',    '$DFILP/${ENV_PREFIX}_ESPD8700_FTECLEDR_I4I_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD8800',  'EPO_FTECLEDASO',    '$DFILP/${ENV_PREFIX}_ESPD8700_FTECLEDA_${NORME_CF}_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','O','')



		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'I4I_ESPD8800','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I4I_ESPD8800','')
go

