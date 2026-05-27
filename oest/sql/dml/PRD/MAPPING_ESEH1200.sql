-------------------------------
--mapping of  ESEH1200

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEH1200')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEH1200')
	delete BEST..TI17FNC where CHAIN_CT='ESEH1200'
	delete BEST..TI17CHN  where CHAIN_CT='ESEH1200'

	insert into BEST..TI17CHN values ('ESEH1200',  '')

	----------IDF_CT:   ESEH1200 ------------------

		insert into BEST..TI17FNC values ('ESEH1200',' ','ESEH1200',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCESANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FCESANT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FPLCANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FPLCANT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FSOBBLOB','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSOBBLOB_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FAPR0','${DFILP}/${ENV_PREFIX}_ESEH1110_FAPR0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FAMPROT0','${DFILP}/${ENV_PREFIX}_ESEH1110_FAMPROT0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FBSEGEST','${DFILP}/${ENV_PREFIX}_ESEH1110_FBSEGEST_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCPLACC0','${DFILP}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCTRGRO0','${DFILP}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCTRULT0','${DFILP}/${ENV_PREFIX}_ESEH1110_FCTRULT0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FUNDSTA0','${DFILP}/${ENV_PREFIX}_ESEH1110_FUNDSTA0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCESSION0','${DFILP}/${ENV_PREFIX}_ESEH1110_FCESSION0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FPLACEMT0','${DFILP}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_IADPERIFCT0','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERIFCT0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_IADPERICASE0','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FULTIMATES','${DFILP}/${ENV_PREFIX}_ESEH1200_FULTIMATES_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESEH1200','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESEH1200','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESEH1200','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESEH1200','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESEH1200','')
go

