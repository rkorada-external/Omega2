-------------------------------
--mapping of  ESID2900

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2900')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2900')
	delete BEST..TI17FNC where CHAIN_CT='ESID2900'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2900'

	insert into BEST..TI17CHN values ('ESID2900',  '')

	----------IDF_CT:   ESID2900 ------------------

		insert into BEST..TI17FNC values ('ESID2900',' ','ESID2900',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_TOTGTR','${DFILP}/${ENV_PREFIX}_ESID2560_TOTGTR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_TOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_TOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_TOTGTAR','${DFILP}/${ENV_PREFIX}_ESID2560_TOTGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_DLREJGTR','${DFILP}/${ENV_PREFIX}_ESID2900_DLREJGTR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_DLREJGTAA','${DFILP}/${ENV_PREFIX}_ESID2900_DLREJGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_DLREJGTAR','${DFILP}/${ENV_PREFIX}_ESID2900_DLREJGTAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID2900','')
go

