-------------------------------
--mapping of  ESPD8900

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8900')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8900')
	delete BEST..TI17FNC where CHAIN_CT='ESPD8900'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8900'

	insert into BEST..TI17CHN values ('ESPD8900',  '')

	----------IDF_CT:   EBS_ESPD8900 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD8900',' ','ESPD8900',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD8900',  'EPO_FCTRSTATSO','${DFILP}/${ENV_PREFIX}_ESPD3900_FCTRSTAT_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8900',  'EPO_FSEGSTATSO','${DFILP}/${ENV_PREFIX}_ESPD3900_FSEGSTAT_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------


	----------IDF_CT:   I4I_ESPD8900 ------------------

		insert into BEST..TI17FNC values ('I4I_ESPD8900',' ','ESPD8900',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESPD8900',  'EPO_FCTRSTATSO','${DFILP}/${ENV_PREFIX}_ESPD3900_FCTRSTAT_I4I_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD8900',  'EPO_FSEGSTATSO','${DFILP}/${ENV_PREFIX}_ESPD3900_FSEGSTAT_I4I_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYPOS',  'I4I_ESPD8900','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I4I_ESPD8900','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'I4I_ESPD8900','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'I4I_ESPD8900','')
go

