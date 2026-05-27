-------------------------------
--mapping of  STAD1540

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1540')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1540')
	delete BEST..TI17FNC where CHAIN_CT='STAD1540'
	delete BEST..TI17CHN  where CHAIN_CT='STAD1540'

	insert into BEST..TI17CHN values ('STAD1540',  '')

	----------IDF_CT:   STAD1540 ------------------

		insert into BEST..TI17FNC values ('STAD1540',' ','STAD1540',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('STAD1540',  'EST_SUBTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1540',  'STA_LIFSTAREP','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP_INV.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1540',  'EST_IARVPERICASE4','${DFILP}/${ENV_PREFIX}_ESID2030_IARVPERICASE4_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1540',  'EST_SUBTRSESBPROP','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRSESBPROP_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1540',  'STA_RFAMPRM','${DFILP}/${ENV_PREFIX}_STAD1540_RFAMPRM_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'STAD1540','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'STAD1540','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'STAD1540','@variante')
go

