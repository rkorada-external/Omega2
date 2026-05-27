-------------------------------
--mapping of  ESID8530

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8530')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8530')
	delete BEST..TI17FNC where CHAIN_CT='ESID8530'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8530'

	insert into BEST..TI17CHN values ('ESID8530',  '')

	----------IDF_CT:   ESID8530 ------------------

		insert into BEST..TI17FNC values ('ESID8530',' ','ESID8530',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8530',  'EST_FRAPP','${DFILP}/${ENV_PREFIX}_ESID2530_FRAPP_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8530',  'EST_FRETCOMP','${DFILP}/${ENV_PREFIX}_ESID8530_FRETCOMP.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID8530','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID8530','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID8530','@variante')
go

