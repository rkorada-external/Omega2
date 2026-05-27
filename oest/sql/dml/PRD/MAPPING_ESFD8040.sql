-------------------------------
--mapping of  ESFD8040

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8040')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8040')
	delete BEST..TI17FNC where CHAIN_CT='ESFD8040'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD8040'

	insert into BEST..TI17CHN values ('ESFD8040',  'granularity product codes')

	----------IDF_CT:   ESFD8040 ------------------

		insert into BEST..TI17FNC values ('ESFD8040','granularity product codes','ESFD8040',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESFD8040',  'ESF_FCTRI17PRD_NEW','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESFD8040',  'ESF_FI17PRODUCT_NEW','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESFD8040','')
go

