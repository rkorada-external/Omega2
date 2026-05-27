-------------------------------
--mapping of  ESID8100

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8100')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8100')
	delete BEST..TI17FNC where CHAIN_CT='ESID8100'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8100'

	insert into BEST..TI17CHN values ('ESID8100',  '')

	----------IDF_CT:   ESID8100 ------------------

		insert into BEST..TI17FNC values ('ESID8100',' ','ESID8100',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_CLS','${ENV_PREFIX}_ESID8100_CLSTYPE_${HOST_PRDSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FILE_LIST','${ENV_PREFIX}_ESID8100_FILE_LIST_${HOST_PRDSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FTECLEDARA','${ENV_PREFIX}_ESID8100_BSAR_FTECLEDA_${PARM_ICLODAT_YEA}_${PARM_ICLODAT_QTR}Q_${HOST_PRDSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FTECLEDRRA','${ENV_PREFIX}_ESID8100_BSAR_FTECLEDR_${PARM_ICLODAT_YEA}_${PARM_ICLODAT_QTR}Q_${HOST_PRDSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FTECLEDAYTD','${ENV_PREFIX}_ESID8100_BSAR_FTECLEDA_YTD_${PARM_ICLODAT_YEA}_${PARM_ICLODAT_QTR}Q_${HOST_PRDSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FTECLEDRYTD','${ENV_PREFIX}_ESID8100_BSAR_FTECLEDR_YTD_${PARM_ICLODAT_YEA}_${PARM_ICLODAT_QTR}Q_${HOST_PRDSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FULTIMATESRA','${ENV_PREFIX}_ESID8100_BSAR_FTULTIMATESFULL_${PARM_ICLODAT_YEA}_${PARM_ICLODAT_QTR}Q_${HOST_PRDSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FTECLEDR',    '$DFILP/${ENV_PREFIX}_ESID8700_FTECLEDR_${NORME_CF}_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FTECLEDA',    '$DFILP/${ENV_PREFIX}_ESID8700_FTECLEDA_${NORME_CF}_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','O','')


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID8100','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID8100','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID8100','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID8100','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID8100','@variante')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESID8100','')
go

