-------------------------------
--mapping of  ESID2020

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2020')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2020')
	delete BEST..TI17FNC where CHAIN_CT='ESID2020'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2020'

	insert into BEST..TI17CHN values ('ESID2020',  '')

	----------IDF_CT:   ESID2020 ------------------

		insert into BEST..TI17FNC values ('ESID2020',' ','ESID2020',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2020',  'EST_DLRLIFEI','${DFILP}/${ENV_PREFIX}_ESID2030_DLRLIFEI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID2020','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID2020','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID2020','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID2020','@variante')
go

