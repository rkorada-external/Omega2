-------------------------------
--mapping of  ESPD3860

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD3860')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD3860')
	delete BEST..TI17FNC where CHAIN_CT='ESPD3860'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3860'

	insert into BEST..TI17CHN values ('ESPD3860',  'IFRS4 Post omega IFRS')

	----------IDF_CT:   ESPD3860 ------------------

		insert into BEST..TI17FNC values ('ESPD3860',' ','ESPD3860',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'ESPD3860','')

	----------IDF_CT:   I4I_ESPD3860 ------------------

		insert into BEST..TI17FNC values ('I4I_ESPD3860','IFRS4 Post omega','ESPD3860',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESPD3860',  'EPO_FTECLEDA_MVT_PREV','${DFILP}/${ENV_PREFIX}_ESFD3930_FTECLEDA_DELTA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD3860',  'ESF_SAP_RETURN_CHECKS','${DFILI}/${ENV_PREFIX}_ESPD3860_${IDF_CT}_SAP_RETURN_CHECKS.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD3860',  'EPO_FTECLEDA_CUR','${DFILP}/${ENV_PREFIX}_ESPD3860_FTECLEDA_CUR_I4I_POS_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD3860',  'EPO_FTECLEDASO_MVT','${DFILP}/${ENV_PREFIX}_ESPD3860_FTECLEDA_MVT_I4I_POS_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD3860',  'EPO_FTECLEDASO_MVT_POSTING','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_MVT_I4I_POSTING_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'I4I_ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'I4I_ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'I4I_ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I4I_ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'I4I_ESPD3860','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'I4I_ESPD3860','')
go

