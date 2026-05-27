-------------------------------
--mapping of  STAD1550

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1550')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1550')
	delete BEST..TI17FNC where CHAIN_CT='STAD1550'
	delete BEST..TI17CHN  where CHAIN_CT='STAD1550'

	insert into BEST..TI17CHN values ('STAD1550',  '')

	----------IDF_CT:   STAD1550 ------------------

		insert into BEST..TI17FNC values ('STAD1550',' ','STAD1550',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('STAD1550',  'STA_LIFSTAREP','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP_INV.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1550',  'STA_LIFINVDIF','${DFILP}/${ENV_PREFIX}_STAD1530_LIFINVDIF${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1550',  'STA_LIFSTADIF','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTADIF${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1550',  'EST_FLIFPLN2','${DFILP}/${ENV_PREFIX}_ESID1520_EST_FLIFPLN2_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'STAD1550','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'STAD1550','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'STAD1550','@variante')
			insert into BEST..TI17REQFNC values ('A',  'STAD1550','')
go

