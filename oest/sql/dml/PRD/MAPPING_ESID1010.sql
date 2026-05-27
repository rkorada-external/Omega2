-------------------------------
--mapping of  ESID1010

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1010')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1010')
	delete BEST..TI17FNC where CHAIN_CT='ESID1010'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1010'

	insert into BEST..TI17CHN values ('ESID1010',  '')

	----------IDF_CT:   ESID1010 ------------------

		insert into BEST..TI17FNC values ('ESID1010',' ','ESID1010',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_STATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_IADVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_IRDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_IRDVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_VTSTATGTA0','${DFILP}/${ENV_PREFIX}_ESID1010_VTSTATGTA0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_DTSTATGTAA0','${DFILP}/${ENV_PREFIX}_ESID1010_DTSTATGTAA0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_TSTATGTAANO','${DFILP}/${ENV_PREFIX}_ESID1010_TSTATGTAANO_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID1010','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID1010','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID1010','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID1010','@variante')
go

