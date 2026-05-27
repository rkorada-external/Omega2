-------------------------------
--mapping of  ESID3860

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3860')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3860')
	delete BEST..TI17FNC where CHAIN_CT='ESID3860'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3860'

	insert into BEST..TI17CHN values ('ESID3860',  '')

	----------IDF_CT:   ESID3860 ------------------

		insert into BEST..TI17FNC values ('ESID3860','I4I Booking','ESID3860',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID3860','')

	----------IDF_CT:   I4I_ESID3860 ------------------

		insert into BEST..TI17FNC values ('I4I_ESID3860','I4I Closing or Booking','ESID3860',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESID3860',  'EST_FTECLEDA_MVT_PREV','${DFILP}/${ENV_PREFIX}_ESFD3930_FTECLEDA_DELTA_I4I_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESID3860',  'ESF_SAP_RETURN_CHECKS','${DFILI}/${ENV_PREFIX}_ESID3860_${IDF_CT}_SAP_RETURN_CHECKS.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESID3860',  'EST_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESID3860_FTECLEDA_MVT_I4I_INV_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESID3860',  'EST_FTECLEDA_MVT_POSTING','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MVT_I4I_POSTING_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'I4I_ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'I4I_ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'I4I_ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'I4I_ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'I4I_ESID3860','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'I4I_ESID3860','')
go

