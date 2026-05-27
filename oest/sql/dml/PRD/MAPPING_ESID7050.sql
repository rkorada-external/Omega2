-------------------------------
--mapping of  ESID7050

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID7050')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID7050')
	delete BEST..TI17FNC where CHAIN_CT='ESID7050'
	delete BEST..TI17CHN  where CHAIN_CT='ESID7050'

	insert into BEST..TI17CHN values ('ESID7050',  '')

	----------IDF_CT:   ESID7050 ------------------

		insert into BEST..TI17FNC values ('ESID7050',' ','ESID7050',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLREJGTR','${DFILP}/${ENV_PREFIX}_ESID2900_DLREJGTR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLTOTGTR','${DFILP}/${ENV_PREFIX}_ESID2560_DLTOTGTR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLREJGTAA','${DFILP}/${ENV_PREFIX}_ESID2900_DLREJGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLREJGTAR','${DFILP}/${ENV_PREFIX}_ESID2900_DLREJGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLTOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_DLTOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLTOTGTAR','${DFILP}/${ENV_PREFIX}_ESID2560_DLTOTGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_CADVPERIESB0','${DFILP}/${ENV_PREFIX}_ESID0060_CADVPERIESB0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_CMGTR','${DFILP}/${ENV_PREFIX}_ESID7050_CMGTR_${PARM_CLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_CMGTAA','${DFILP}/${ENV_PREFIX}_ESID7050_CMGTAA_${PARM_CLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_CMGTAR','${DFILP}/${ENV_PREFIX}_ESID7050_CMGTAR_${PARM_CLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESID7050','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID7050','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID7050','@variante')
go

