-------------------------------
--mapping of  ESID1000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1000')
	delete BEST..TI17FNC where CHAIN_CT='ESID1000'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1000'

	insert into BEST..TI17CHN values ('ESID1000',  '')

	----------IDF_CT:   ESID1000 ------------------

		insert into BEST..TI17FNC values ('ESID1000',' ','ESID1000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IADPERICASE0','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IAVPERICASE0','${DFILP}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_OADPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_OADPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_OAVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_OAVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IADPERICASE_ENTIER0','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_ENTIER0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IADVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_OADVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1000_OADVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IADVPERICASE_ENTIER0','${DFILP}/${ENV_PREFIX}_ESID1000_IADVPERICASE_ENTIER0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID1000','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID1000','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESID1000','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID1000','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID1000','@variante')
go

