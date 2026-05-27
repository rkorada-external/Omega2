-------------------------------
--mapping of  STPD1280

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STPD1280')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STPD1280')
	delete BEST..TI17FNC where CHAIN_CT='STPD1280'
	delete BEST..TI17CHN  where CHAIN_CT='STPD1280'

	insert into BEST..TI17CHN values ('STPD1280',  '')

	----------IDF_CT:   STPD1280 ------------------

		insert into BEST..TI17FNC values ('STPD1280',' ','STPD1280',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('STPD1280',  'EPO_LIFSTAREP_BRIDG','${DFILP}/${ENV_PREFIX}_STPD1500_LIFSTAREP_BRIDG_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'STPD1280','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'STPD1280','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'STPD1280','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'STPD1280','')
go

