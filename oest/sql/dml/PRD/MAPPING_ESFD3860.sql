-------------------------------
--mapping of  ESFD3860

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3860')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3860')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3860'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3860'

	insert into BEST..TI17CHN values ('ESFD3860',  'IFRS17 - Profitability Interface')

	----------IDF_CT:   I17G_PRO_INT_STD ------------------

		insert into BEST..TI17FNC values ('I17G_PRO_INT_STD','IFRS17 Group - Profitability Interface','ESFD3860',0)
					

		----------  Perms---------------------
			insert into BEST..TI17PERMFIL values ('I17G_PRO_INT_STD',  'ESF_FI17CLOPER','${DFILP}/${ENV_PREFIX}_ESFD1130_FI17CLOPER_I17G_DSC_ALL_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_PRO_INT_STD',  'ESF_EMPTY','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_PRO_INT_STD',  'ESF_PI_REPORT','${DFILP}/${ENV_PREFIX}_ESFD3860_I17G_PRO_INT_STD_PI_REPORT_${TYPEINV}_${CRE_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G_PRO_INT_STD',  'ESF_PI_ASSUM_EXTRACT','${DFILI}/${ENV_PREFIX}_ESFD3860_I17G_PRO_INT_STD_PI_ASSUM_EXTRACT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G_PRO_INT_STD',  'ESF_PI_UPDATE_TSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3860_I17G_PRO_INT_STD_PI_UPDATE_TSECIFRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_PRO_INT_STD','')

	----------IDF_CT:   I17L_PRO_INT_STD ------------------

		insert into BEST..TI17FNC values ('I17L_PRO_INT_STD','IFRS17 Local - Profitability Interface','ESFD3860',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_PRO_INT_STD',  'ESF_FI17CLOPER','${DFILP}/${ENV_PREFIX}_ESFD1130_FI17CLOPER_I17L_DSC_ALL_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_PRO_INT_STD',  'ESF_EMPTY','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_PRO_INT_STD',  'ESF_PI_REPORT','${DFILP}/${ENV_PREFIX}_ESFD3860_I17L_PRO_INT_STD_PI_REPORT_${TYPEINV}_${CRE_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L_PRO_INT_STD',  'ESF_PI_ASSUM_EXTRACT','${DFILI}/${ENV_PREFIX}_ESFD3860_I17L_PRO_INT_STD_PI_ASSUM_EXTRACT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L_PRO_INT_STD',  'ESF_PI_UPDATE_TSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3860_I17L_PRO_INT_STD_PI_UPDATE_TSECIFRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_PRO_INT_STD','')

	----------IDF_CT:   I17P_PRO_INT_STD ------------------

		insert into BEST..TI17FNC values ('I17P_PRO_INT_STD','IFRS17 Parent - Profitability Interface','ESFD3860',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_PRO_INT_STD',  'ESF_FI17CLOPER','${DFILP}/${ENV_PREFIX}_ESFD1130_FI17CLOPER_I17P_DSC_ALL_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_PRO_INT_STD',  'ESF_EMPTY','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_PRO_INT_STD',  'ESF_PI_REPORT','${DFILP}/${ENV_PREFIX}_ESFD3860_I17P_PRO_INT_STD_PI_REPORT_${TYPEINV}_${CRE_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P_PRO_INT_STD',  'ESF_PI_ASSUM_EXTRACT','${DFILI}/${ENV_PREFIX}_ESFD3860_I17P_PRO_INT_STD_PI_ASSUM_EXTRACT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P_PRO_INT_STD',  'ESF_PI_UPDATE_TSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3860_I17P_PRO_INT_STD_PI_UPDATE_TSECIFRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_PRO_INT_STD','')

	----------IDF_CT:   I17S_PRO_INT_STD ------------------

		insert into BEST..TI17FNC values ('I17S_PRO_INT_STD','IFRS17 Simulation - Profitability Interface','ESFD3860',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_PRO_INT_STD',  'ESF_FI17CLOPER','${DFILP}/${ENV_PREFIX}_ESFD1130_FI17CLOPER_I17S_DSC_ALL_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_PRO_INT_STD',  'ESF_EMPTY','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_PRO_INT_STD',  'ESF_PI_REPORT','${DFILP}/${ENV_PREFIX}_ESFD3860_I17S_PRO_INT_STD_PI_REPORT_${TYPEINV}_${CRE_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S_PRO_INT_STD',  'ESF_PI_ASSUM_EXTRACT','${DFILI}/${ENV_PREFIX}_ESFD3860_I17S_PRO_INT_STD_PI_ASSUM_EXTRACT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S_PRO_INT_STD',  'ESF_PI_UPDATE_TSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3860_I17S_PRO_INT_STD_PI_UPDATE_TSECIFRS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_PRO_INT_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_PRO_INT_STD','')
go

