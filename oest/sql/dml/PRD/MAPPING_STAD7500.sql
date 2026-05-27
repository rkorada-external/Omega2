-------------------------------
--mapping of  STAD7500

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD7500')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STAD7500')
	delete BEST..TI17FNC where CHAIN_CT='STAD7500'
	delete BEST..TI17CHN  where CHAIN_CT='STAD7500'

	insert into BEST..TI17CHN values ('STAD7500',  '')

	----------IDF_CT:   STAD7500 ------------------

		insert into BEST..TI17FNC values ('STAD7500',' ','STAD7500',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_SUBTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_CPLIFDRI','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFDRI_${TYPEINV}_${BALSHTYEA}1231.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_CPLIFEST','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFEST_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_CPLIFDRIQ','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFDRIQ_${TYPEINV}_${BALSHTYEA}1231.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_FLIFEST0','${DFILP}/${ENV_PREFIX}_ESID0130_FLIFESTY0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_SUBTRSASSO','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRSASSO_${TYPEINV}_${BALSHTYEA}1231.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_IARVPERICASE4','${DFILP}/${ENV_PREFIX}_ESID2030_IARVPERICASE4_${TYPEINV}_${BALSHTYEA}1231.dat','I','')
			insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_FLIFESTQ','${DFILP}/${ENV_PREFIX}_STAD7500_FLIFESTQ_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_FLIFESTY','${DFILP}/${ENV_PREFIX}_STAD7500_FLIFESTY_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQINVB',  'STAD7500','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'STAD7500','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'STAD7500','')
go

