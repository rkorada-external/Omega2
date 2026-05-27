-------------------------------
--mapping of  ESID0070

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0070')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0070')
	delete BEST..TI17FNC where CHAIN_CT='ESID0070'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0070'

	insert into BEST..TI17CHN values ('ESID0070',  '')

	----------IDF_CT:   ESID0070 ------------------

		insert into BEST..TI17FNC values ('ESID0070',' ','ESID0070',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID0070',  'EST_MVTPNA0','${DFILP}/${ENV_PREFIX}_ESID0070_MVTPNA0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID0070',  'EST_FTPNA17','${DFILP}/${ENV_PREFIX}_ESID0070_FT_FAC_PNA17_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID0070','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID0070','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID0070','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID0070','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID0070','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID0070','@variante')
go

