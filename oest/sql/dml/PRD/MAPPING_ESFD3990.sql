-------------------------------
--mapping of  ESFD3990

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3990')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3990')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3990'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3990'

	insert into BEST..TI17CHN values ('ESFD3990',  'IFRS17 - Annual Limit')

	----------IDF_CT:   I17G_CAL_ALL_STD ------------------

		insert into BEST..TI17FNC values ('I17G_CAL_ALL_STD','IFRS17 Group - Annual Limit','ESFD3990',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_CAL_ALL_STD',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_CAL_ALL_STD',  'EST_DLCUMGTAAR','${DFILP}/${ENV_PREFIX}_ESFD4020_DLCUMGTAAR_ITD_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_CAL_ALL_STD',  'EST_ANN_LIMIT_FAC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____EST_ANN_LIMIT_FAC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_CAL_ALL_STD',  'EST_ANN_LIMIT_TRT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____EST_ANN_LIMIT_TRT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_CAL_ALL_STD',  'EST_FLAG_ANN_LMT','${DFILP}/${ENV_PREFIX}_ESFD3990_I17G_EST_FLAG_ANN_LMT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G_CAL_ALL_STD','')

	----------IDF_CT:   I17S_CAL_ALL_STD ------------------

		insert into BEST..TI17FNC values ('I17S_CAL_ALL_STD','IFRS17 Simulation - Annual Limit','ESFD3990',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_CAL_ALL_STD',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_CAL_ALL_STD',  'EST_DLCUMGTAAR','${DFILP}/${ENV_PREFIX}_ESFD4020_DLCUMGTAAR_ITD_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_CAL_ALL_STD',  'EST_ANN_LIMIT_FAC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____EST_ANN_LIMIT_FAC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_CAL_ALL_STD',  'EST_ANN_LIMIT_TRT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____EST_ANN_LIMIT_TRT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_CAL_ALL_STD',  'EST_FLAG_ANN_LMT','${DFILP}/${ENV_PREFIX}_ESFD3990_I17S_EST_FLAG_ANN_LMT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINVB',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSB',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINVB',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSB',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSP',  'I17S_CAL_ALL_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSP',  'I17S_CAL_ALL_STD','')
go

