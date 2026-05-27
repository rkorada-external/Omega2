-------------------------------
--mapping of  ESID8800

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8800')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8800')
	delete BEST..TI17FNC where CHAIN_CT='ESID8800'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8800'

	insert into BEST..TI17CHN values ('ESID8800',  '')

	----------IDF_CT:   ESID8800 ------------------

		insert into BEST..TI17FNC values ('ESID8800',' ','ESID8800',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8800',  'EST_FTECLEDR',    '$DFILP/${ENV_PREFIX}_ESID8700_FTECLEDR_${NORME_CF}_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8800',  'EST_FTECLEDA',    '$DFILP/${ENV_PREFIX}_ESID8700_FTECLEDA_${NORME_CF}_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','O','')


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID8800','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID8800','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID8800','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID8800','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID8800','@variante')
go

