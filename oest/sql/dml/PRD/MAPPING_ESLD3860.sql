-------------------------------
--mapping of  ESLD3860

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3860')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3860')
	delete BEST..TI17FNC where CHAIN_CT='ESLD3860'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD3860'
 
	insert into BEST..TI17CHN values ('ESLD3860',  '')

	----------IDF_CT:   ESLD3860 ------------------

		insert into BEST..TI17FNC values ('ESLD3860',' ','ESLD3860',0)
					

		----------  Perms---------------------
			insert into BEST..TI17PERMFIL values ('ESLD3860',  'ESL_FTECLEDALO_MVT_PREV','${DFILP}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('Y',  'ESLD3860','')
go

