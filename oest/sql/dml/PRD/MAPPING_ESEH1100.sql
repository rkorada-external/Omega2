-------------------------------
--mapping of  ESEH1100

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEH1100')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEH1100')
	delete BEST..TI17FNC where CHAIN_CT='ESEH1100'
	delete BEST..TI17CHN  where CHAIN_CT='ESEH1100'

	insert into BEST..TI17CHN values ('ESEH1100',  '')

	----------IDF_CT:   ESEH1100 ------------------

		insert into BEST..TI17FNC values ('ESEH1100',' ','ESEH1100',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IADPERIFCT0','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERIFCT0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IADPERICASE0','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IAVPERICASE0','${DFILP}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IADPERICASE_ENTIER0','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_ENTIER0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESEH1100','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESEH1100','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESEH1100','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'ESEH1100','')
			insert into BEST..TI17REQFNC values ('A',  'ESEH1100','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESEH1100','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESEH1100','')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'ESEH1100','')
go

