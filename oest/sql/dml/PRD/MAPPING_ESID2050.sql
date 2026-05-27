-------------------------------
--mapping of  ESID2050

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2050')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2050')
	delete BEST..TI17FNC where CHAIN_CT='ESID2050'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2050'

	insert into BEST..TI17CHN values ('ESID2050',  '')

	----------IDF_CT:   ESID2050 ------------------

		insert into BEST..TI17FNC values ('ESID2050',' ','ESID2050',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2050',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID2050','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID2050','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID2050','@variante')
go

