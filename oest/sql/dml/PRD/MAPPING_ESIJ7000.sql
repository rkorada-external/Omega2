-------------------------------
--mapping of  ESIJ7000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ7000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ7000')
	delete BEST..TI17FNC where CHAIN_CT='ESIJ7000'
	delete BEST..TI17CHN  where CHAIN_CT='ESIJ7000'

	insert into BEST..TI17CHN values ('ESIJ7000',  '')

	----------IDF_CT:   ESIJ7000 ------------------

		insert into BEST..TI17FNC values ('ESIJ7000',' ','ESIJ7000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_FRTOSTA','${DFILP}/${ENV_PREFIX}_RTCJ0500_FRTOSTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_STATGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_FACCTRTGT','${DFILP}/${ENV_PREFIX}_RTCJ0500_FACCTRTGT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_FDRYTRN','${DFILP}/${ENV_PREFIX}_ESIX7000_FDRYTRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_GTASW','${DFILP}/${ENV_PREFIX}_ESIJ7000_GTASW${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_GTRSW','${DFILP}/${ENV_PREFIX}_ESIJ7000_GTRSW${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_IGTR00','${DFILP}/${ENV_PREFIX}_ESIJ7000_IGTR00_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_IGTAA00','${DFILP}/${ENV_PREFIX}_ESIJ7000_IGTAA00_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESIJ7000','')
go

