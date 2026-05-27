-------------------------------
--mapping of  ESID0130

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0130')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0130')
	delete BEST..TI17FNC where CHAIN_CT='ESID0130'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0130'

	insert into BEST..TI17CHN values ('ESID0130',  '')

	----------IDF_CT:   ESID0130 ------------------

		insert into BEST..TI17FNC values ('ESID0130',' ','ESID0130',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID0130',  'EST_FLIFESTY1','${DFILP}/${ENV_PREFIX}_ESID0120_FLIFESTY1_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID0130',  'EST_IAVPERICASE0','${DFILP}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID0130',  'EST_IRVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_IRVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID0130',  'EST_FLIFESTY0','${DFILP}/${ENV_PREFIX}_ESID0130_FLIFESTY0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID0130','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID0130','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID0130','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID0130','')
go

