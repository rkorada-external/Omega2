-------------------------------
--mapping of  ESFD3790

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3790')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3790')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3790'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3790'

	insert into BEST..TI17CHN values ('ESFD3790',  'IFRS17 - IFRS 17 segment net position indicator')

	----------IDF_CT:   I17G_SEG_PRO_STD ------------------

		insert into BEST..TI17FNC values ('I17G_SEG_PRO_STD','IFRS17 Group - IFRS 17 segment net position indicator','ESFD3790',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17G_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD',  'ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${ENV_PREFIX}_ESFD3980_I17G_SII_IOR_STD_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD',  'ESF_FSEGPROF_SEG_STD','${DFILP}/${ENV_PREFIX}_ESFD3790_I17G_SEG_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_SEG_PRO_STD','')

	----------IDF_CT:   I17L_SEG_PRO_STD ------------------

		insert into BEST..TI17FNC values ('I17L_SEG_PRO_STD','IFRS17 Local - IFRS 17 segment net position indicator','ESFD3790',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_SEG_PRO_STD',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SEG_PRO_STD',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17L_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SEG_PRO_STD',  'ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${ENV_PREFIX}_ESFD3620_I17L_DSC_DSI_STD_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SEG_PRO_STD',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${ENV_PREFIX}_ESFD3620_I17L_RAD_DSI_STD_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}${PARM_POSX}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SEG_PRO_STD',  'ESF_FSEGPROF_SEG_STD','${DFILP}/${ENV_PREFIX}_ESFD3790_I17L_SEG_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_SEG_PRO_STD','')

	----------IDF_CT:   I17P_SEG_PRO_STD ------------------

		insert into BEST..TI17FNC values ('I17P_SEG_PRO_STD','IFRS17 Parent - IFRS 17 segment net position indicator','ESFD3790',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_SEG_PRO_STD',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SEG_PRO_STD',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17P_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SEG_PRO_STD',  'ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${ENV_PREFIX}_ESFD3620_I17P_DSC_DSI_STD_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SEG_PRO_STD',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${ENV_PREFIX}_ESFD3620_I17P_RAD_DSI_STD_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}${PARM_POSX}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SEG_PRO_STD',  'ESF_FSEGPROF_SEG_STD','${DFILP}/${ENV_PREFIX}_ESFD3790_I17P_SEG_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_SEG_PRO_STD','')

	----------IDF_CT:   I17S_SEG_PRO_STD ------------------

		insert into BEST..TI17FNC values ('I17S_SEG_PRO_STD','IFRS17 Simulation - IFRS 17 segment net position indicator','ESFD3790',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_SEG_PRO_STD',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SEG_PRO_STD',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SEG_PRO_STD',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17S_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SEG_PRO_STD',  'ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${ENV_PREFIX}_ESFD3980_I17S_SII_IOR_STD_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SEG_PRO_STD',  'ESF_FSEGPROF_SEG_STD','${DFILP}/${ENV_PREFIX}_ESFD3790_I17S_SEG_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_SEG_PRO_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_SEG_PRO_STD','')
go

