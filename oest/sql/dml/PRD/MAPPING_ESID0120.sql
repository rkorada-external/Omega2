-------------------------------
--mapping of  ESID0120

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0120')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0120')
	delete BEST..TI17FNC where CHAIN_CT='ESID0120'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0120'

	insert into BEST..TI17CHN values ('ESID0120',  '')

	----------IDF_CT:   ESID0120 ------------------

		insert into BEST..TI17FNC values ('ESID0120',' ','ESID0120',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID0120',  'EST_FLIFESTQ0','${DFILP}/${ENV_PREFIX}_ESID0120_FLIFESTQ0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID0120',  'EST_FLIFESTY1','${DFILP}/${ENV_PREFIX}_ESID0120_FLIFESTY1_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID0120',  'EST_FLIFESTY1_ARCH','${DFILP}/${ENV_PREFIX}_ESID0120_FLIFESTY1_ARCH.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID0120','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID0120','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID0120','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID0120','@variante')
go

