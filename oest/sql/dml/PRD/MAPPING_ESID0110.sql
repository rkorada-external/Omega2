-------------------------------
--mapping of  ESID0110

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0110')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID0110')
	delete BEST..TI17FNC where CHAIN_CT='ESID0110'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0110'

	insert into BEST..TI17CHN values ('ESID0110',  '')

	----------IDF_CT:   ESID0110 ------------------

		insert into BEST..TI17FNC values ('ESID0110',' ','ESID0110',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID0110',  'EST_FACCTRAA0','${DFILP}/${ENV_PREFIX}_ESID0110_FACCTRAA0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID0110','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID0110','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESID0110','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID0110','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID0110','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID0110','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID0110','@variante')
go

