-------------------------------
--mapping of  ESID1500

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1500')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1500')
	delete BEST..TI17FNC where CHAIN_CT='ESID1500'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1500'

	insert into BEST..TI17CHN values ('ESID1500',  '')

	----------IDF_CT:   ESID1500 ------------------

		insert into BEST..TI17FNC values ('ESID1500',' ','ESID1500',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_IRDPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_IRVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_IRVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_ORDPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_ORDPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_ORVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_ORVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_IRDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_IRDVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_ORDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_ORDVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID1500','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID1500','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESID1500','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID1500','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID1500','@variante')
go

