-------------------------------
--mapping of  STAD1530

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1530')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD1530')
	delete BEST..TI17FNC where CHAIN_CT='STAD1530'
	delete BEST..TI17CHN  where CHAIN_CT='STAD1530'

	insert into BEST..TI17CHN values ('STAD1530',  '')

	----------IDF_CT:   STAD1530 ------------------

		insert into BEST..TI17FNC values ('STAD1530',' ','STAD1530',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('STAD1530',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1530',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1530',  'STA_LIFSTAREP','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP_INV.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1530',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1530',  'EST_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID2030_IARVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD1530',  'STA_LIFINVDIF','${DFILP}/${ENV_PREFIX}_STAD1530_LIFINVDIF${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'STAD1530','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'STAD1530','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'STAD1530','@variante')
go

