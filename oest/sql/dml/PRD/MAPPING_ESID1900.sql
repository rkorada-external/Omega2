-------------------------------
--mapping of  ESID1900

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1900')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID1900')
	delete BEST..TI17FNC where CHAIN_CT='ESID1900'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1900'

	insert into BEST..TI17CHN values ('ESID1900',  '')

	----------IDF_CT:   ESID1900 ------------------

		insert into BEST..TI17FNC values ('ESID1900',' ','ESID1900',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_IGTAA00','${DFILP}/${ENV_PREFIX}_ESIJ7000_IGTAA00_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_IGTR0','${DFILP}/${ENV_PREFIX}_ESID1900_IGTR0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_IGTAA0','${DFILP}/${ENV_PREFIX}_ESID1900_IGTAA0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_IGTAR0','${DFILP}/${ENV_PREFIX}_ESID1900_IGTAR0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_DLAGTR0','${DFILP}/${ENV_PREFIX}_ESID1900_DLAGTR0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_DLAGTAA0','${DFILP}/${ENV_PREFIX}_ESID1900_DLAGTAA0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_DLAGTAR0','${DFILP}/${ENV_PREFIX}_ESID1900_DLAGTAR0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESID1900','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID1900','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID1900','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID1900','@variante')
go

