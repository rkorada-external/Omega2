-------------------------------
--mapping of  ESID8000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8000')
	delete BEST..TI17FNC where CHAIN_CT='ESID8000'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8000'

	insert into BEST..TI17CHN values ('ESID8000',  '')

	----------IDF_CT:   ESID8000 ------------------

		insert into BEST..TI17FNC values ('ESID8000',' ','ESID8000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FT','${DFILP}/${ENV_PREFIX}_ESID2000_FT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FLOARAT','${DFILP}/${ENV_PREFIX}_ESID2000_FLOARAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FPRMLOA','${DFILP}/${ENV_PREFIX}_ESID2000_FPRMLOA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_TOTGTAA','${DFILP}/${ENV_PREFIX}_ESID2060_TOTGTAA_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADPERICASE_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FCTREST0','${DFILP}/${ENV_PREFIX}_ESID0060_FCTREST0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FCTREST1','${DFILP}/${ENV_PREFIX}_ESID2000_FCTREST1_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRESTF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRESTF0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FBESTCONPAR','${DFILP}/${ENV_PREFIX}_ESID2500_FBESTCONPAR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FBESTCESSION','${DFILP}/${ENV_PREFIX}_ESID2500_FBESTCESSION_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID8000','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID8000','@variante')
go

