-------------------------------
--mapping of  ESFD3710

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3710')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3710')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3710'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3710'

	insert into BEST..TI17CHN values ('ESFD3710',  'CSM at inception')

	----------IDF_CT:   I17G_CSM_CSU_INI ------------------

		insert into BEST..TI17FNC values ('I17G_CSM_CSU_INI',' ','ESFD3710',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_RAD_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_CSM_CSU_INI',  'ESF_GTSII_CSM','${DFILP}/${ENV_PREFIX}_ESFD3710_I17G_CSM_CSU_INI_GTSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_CSM_CSU_INI','')

	----------IDF_CT:   I17L_CSM_CSU_INI ------------------

		insert into BEST..TI17FNC values ('I17L_CSM_CSU_INI',' ','ESFD3710',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${ENV_PREFIX}_ESFD3620_I17L_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${ENV_PREFIX}_ESFD3620_I17L_RAD_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_CSM_CSU_INI',  'ESF_GTSII_CSM','${DFILP}/${ENV_PREFIX}_ESFD3710_I17L_CSM_CSU_INI_GTSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_CSM_CSU_INI','')

	----------IDF_CT:   I17P_CSM_CSU_INI ------------------

		insert into BEST..TI17FNC values ('I17P_CSM_CSU_INI',' ','ESFD3710',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${ENV_PREFIX}_ESFD3620_I17P_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${ENV_PREFIX}_ESFD3620_I17P_RAD_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_CSM_CSU_INI',  'ESF_GTSII_CSM','${DFILP}/${ENV_PREFIX}_ESFD3710_I17P_CSM_CSU_INI_GTSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_CSM_CSU_INI','')

	----------IDF_CT:   I17S_CSM_CSU_INI ------------------

		insert into BEST..TI17FNC values ('I17S_CSM_CSU_INI',' ','ESFD3710',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${ENV_PREFIX}_ESFD3620_I17S_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${ENV_PREFIX}_ESFD3620_I17S_RAD_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_CSM_CSU_INI',  'ESF_GTSII_CSM','${DFILP}/${ENV_PREFIX}_ESFD3710_I17S_CSM_CSU_INI_GTSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_CSM_CSU_INI','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_CSM_CSU_INI','')
go

