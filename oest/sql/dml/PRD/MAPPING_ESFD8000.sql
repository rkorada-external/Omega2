-- 12/04/2024 M.NAJI: SPIRA 111551 I17L/P booking - remove ESFD4030 and ESFD3840 
-------------------------------
--mapping of  ESFD8000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8000')
	delete BEST..TI17FNC where CHAIN_CT='ESFD8000'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD8000'

	insert into BEST..TI17CHN values ('ESFD8000',  'IFRS17 - Loading TP O2 Tables')

	----------IDF_CT:   I17G_OMG_TP_STD ------------------

		insert into BEST..TI17FNC values ('I17G_OMG_TP_STD','IFRS17 - Group - Loading TP O2 Tables','ESFD8000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FRETIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FRETIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSECIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FSEGPROF_INI','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FSEGPROF_STD','${DFILP}/${ENV_PREFIX}_ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FSEGPROF_SEG_STD','${DFILP}/${ENV_PREFIX}_ESFD3790_I17G_SEG_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FSECIFRS_LIGHT','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSECIFRS_LIGHT${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_PI_UPDATE_TSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3860_I17G_PRO_INT_STD_PI_UPDATE_TSECIFRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_OMG_TP_STD','')

	----------IDF_CT:   I17L_OMG_TP_STD ------------------

		insert into BEST..TI17FNC values ('I17L_OMG_TP_STD','IFRS17 - Local - Loading TP O2 Tables','ESFD8000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_OMG_TP_STD',  'ESF_FRETIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17L_CSM_CRE_INI_FRETIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_TP_STD',  'ESF_FSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17L_CSM_CRE_INI_FSECIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_TP_STD',  'ESF_FSEGPROF_INI','${DFILP}/${ENV_PREFIX}_ESFD3720_I17L_CSM_CRE_INI_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_TP_STD',  'ESF_FSEGPROF_STD','${DFILP}/${ENV_PREFIX}_ESFD3760_I17L_UOA_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_TP_STD',  'ESF_FSEGPROF_SEG_STD','${DFILP}/${ENV_PREFIX}_ESFD3790_I17L_SEG_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_TP_STD',  'ESF_FSECIFRS_LIGHT','${DFILP}/${ENV_PREFIX}_ESFD3720_I17L_CSM_CRE_INI_FSECIFRS_LIGHT${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_TP_STD',  'ESF_PI_UPDATE_TSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3860_I17L_PRO_INT_STD_PI_UPDATE_TSECIFRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_OMG_TP_STD','')

	----------IDF_CT:   I17P_OMG_TP_STD ------------------

		insert into BEST..TI17FNC values ('I17P_OMG_TP_STD','IFRS17 - Parent - Loading TP O2 Tables','ESFD8000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_OMG_TP_STD',  'ESF_FRETIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17P_CSM_CRE_INI_FRETIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_TP_STD',  'ESF_FSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17P_CSM_CRE_INI_FSECIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_TP_STD',  'ESF_FSEGPROF_INI','${DFILP}/${ENV_PREFIX}_ESFD3720_I17P_CSM_CRE_INI_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_TP_STD',  'ESF_FSEGPROF_STD','${DFILP}/${ENV_PREFIX}_ESFD3760_I17P_UOA_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_TP_STD',  'ESF_FSEGPROF_SEG_STD','${DFILP}/${ENV_PREFIX}_ESFD3790_I17P_SEG_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_TP_STD',  'ESF_FSECIFRS_LIGHT','${DFILP}/${ENV_PREFIX}_ESFD3720_I17P_CSM_CRE_INI_FSECIFRS_LIGHT${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_TP_STD',  'ESF_PI_UPDATE_TSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3860_I17P_PRO_INT_STD_PI_UPDATE_TSECIFRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_OMG_TP_STD','')

	----------IDF_CT:   I17S_OMG_TP_STD ------------------

		insert into BEST..TI17FNC values ('I17S_OMG_TP_STD','IFRS17 - Simulation - Loading TP O2 Tables','ESFD8000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_OMG_TP_STD',  'ESF_FRETIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17S_CSM_CRE_INI_FRETIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_TP_STD',  'ESF_FSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17S_CSM_CRE_INI_FSECIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_TP_STD',  'ESF_FSEGPROF_INI','${DFILP}/${ENV_PREFIX}_ESFD3720_I17S_CSM_CRE_INI_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_TP_STD',  'ESF_FSEGPROF_STD','${DFILP}/${ENV_PREFIX}_ESFD3760_I17S_UOA_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_TP_STD',  'ESF_FSEGPROF_SEG_STD','${DFILP}/${ENV_PREFIX}_ESFD3790_I17S_SEG_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_TP_STD',  'ESF_FSECIFRS_LIGHT','${DFILP}/${ENV_PREFIX}_ESFD3720_I17S_CSM_CRE_INI_FSECIFRS_LIGHT${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_TP_STD',  'ESF_PI_UPDATE_TSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3860_I17S_PRO_INT_STD_PI_UPDATE_TSECIFRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINVB',  'I17S_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINVB',  'I17S_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSP',  'I17S_OMG_TP_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSP',  'I17S_OMG_TP_STD','')
go

