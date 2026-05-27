-------------------------------
--mapping of  ESFD3930

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3930')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3930')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3930'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3930'

	insert into BEST..TI17CHN values ('ESFD3930',  'IFRS17 - SAP Posting')

	----------IDF_CT:   EBS_DLT_SAP_STD ------------------

		insert into BEST..TI17FNC values ('EBS_DLT_SAP_STD','EBS - SAP Posting','ESFD3930',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_DLT_SAP_STD',  'ESF_FTECLEDA_GLT_MVT','${DFILP}/${ENV_PREFIX}_ESPD3910_EBS_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_DLT_SAP_STD',  'ESF_FTECLEDA_SAP_MVT','`if [ "${TYPEINV}" = "POC" ];then echo ${DFILP}/empty.dat;else echo ${DFILP}/${ENV_PREFIX}_ESFD3960_EBS_SAP_OMG_STD_FTECLEDA_POSTING_${PARM_ICLODAT_D}.dat;fi;`','I','')
			insert into BEST..TI17PERMFIL values ('EBS_DLT_SAP_STD',  'ESF_FTECLEDA_DELTA','${DFILP}/${ENV_PREFIX}_ESFD3930_EBS_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('EBS_DLT_SAP_STD',  'ESF_FTECLEDA_EXCLUDED','${DFILI}/${ENV_PREFIX}_ESFD3930_${IDF_CT}_FTECLEDA_EXCL_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEYPOSB',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('S',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEQINVB',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSB',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEYINVB',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEYPOSP',  'EBS_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSP',  'EBS_DLT_SAP_STD','')

	----------IDF_CT:   I17G_DLT_SAP_STD ------------------

		insert into BEST..TI17FNC values ('I17G_DLT_SAP_STD','IFRS17 Group - SAP Posting','ESFD3930',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_DLT_SAP_STD',  'ESF_FTECLEDA_SAP_MVT','${DFILP}/${ENV_PREFIX}_ESFD3960_I17G_SAP_OMG_STD_FTECLEDA_POSTING_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_DLT_SAP_STD',  'ESF_FTECLEDA_GLT_MVT','${DFILP}/${ENV_PREFIX}_ESPD3910_I17G_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_DLT_SAP_STD',  'ESF_FTECLEDA_DELTA','${DFILP}/${ENV_PREFIX}_ESFD3930_I17G_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G_DLT_SAP_STD',  'ESF_FTECLEDA_EXCLUDED','${DFILI}/${ENV_PREFIX}_ESFD3930_${IDF_CT}_FTECLEDA_EXCL_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('S',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G_DLT_SAP_STD','')

	----------IDF_CT:   I17L_DLT_SAP_STD ------------------

		insert into BEST..TI17FNC values ('I17L_DLT_SAP_STD','IFRS17 Local - SAP Posting','ESFD3930',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_DLT_SAP_STD',  'ESF_FTECLEDA_SAP_MVT','${DFILP}/${ENV_PREFIX}_ESFD3960_I17L_SAP_OMG_STD_FTECLEDA_POSTING_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_DLT_SAP_STD',  'ESF_FTECLEDA_GLT_MVT','${DFILP}/${ENV_PREFIX}_ESPD3910_I17L_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_DLT_SAP_STD',  'ESF_FTECLEDA_DELTA','${DFILP}/${ENV_PREFIX}_ESFD3930_I17L_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L_DLT_SAP_STD',  'ESF_FTECLEDA_EXCLUDED','${DFILI}/${ENV_PREFIX}_ESFD3930_${IDF_CT}_FTECLEDA_EXCL_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LQINVB',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINVB',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('S',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSP',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSP',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_DLT_SAP_STD','')

	----------IDF_CT:   I17P_DLT_SAP_STD ------------------

		insert into BEST..TI17FNC values ('I17P_DLT_SAP_STD','IFRS17 Parent - SAP Posting','ESFD3930',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_DLT_SAP_STD',  'ESF_FTECLEDA_SAP_MVT','${DFILP}/${ENV_PREFIX}_ESFD3960_I17P_SAP_OMG_STD_FTECLEDA_POSTING_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_DLT_SAP_STD',  'ESF_FTECLEDA_GLT_MVT','${DFILP}/${ENV_PREFIX}_ESPD3910_I17P_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_DLT_SAP_STD',  'ESF_FTECLEDA_DELTA','${DFILP}/${ENV_PREFIX}_ESFD3930_I17P_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P_DLT_SAP_STD',  'ESF_FTECLEDA_EXCLUDED','${DFILI}/${ENV_PREFIX}_ESFD3930_${IDF_CT}_FTECLEDA_EXCL_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSP',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSP',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PQINVB',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINVB',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('S',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_DLT_SAP_STD','')

	----------IDF_CT:   I17S_DLT_SAP_STD ------------------

		insert into BEST..TI17FNC values ('I17S_DLT_SAP_STD','IFRS17 Simulation - SAP Posting','ESFD3930',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_DLT_SAP_STD',  'ESF_FTECLEDA_SAP_MVT','${DFILP}/${ENV_PREFIX}_ESFD3960_I17S_SAP_OMG_STD_FTECLEDA_POSTING_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_DLT_SAP_STD',  'ESF_FTECLEDA_GLT_MVT','${DFILP}/${ENV_PREFIX}_ESPD3910_I17S_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_DLT_SAP_STD',  'ESF_FTECLEDA_DELTA','${DFILP}/${ENV_PREFIX}_ESFD3930_I17S_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S_DLT_SAP_STD',  'ESF_FTECLEDA_EXCLUDED','${DFILI}/${ENV_PREFIX}_ESFD3930_${IDF_CT}_FTECLEDA_EXCL_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINVB',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSB',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINVB',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSB',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSP',  'I17S_DLT_SAP_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSP',  'I17S_DLT_SAP_STD','')

	----------IDF_CT:   I4I_ESFD3930_INV ------------------

		insert into BEST..TI17FNC values ('I4I_ESFD3930_INV','I4I - SAP Posting INV','ESFD3930',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESFD3930_INV',  'ESF_FTECLEDA_SAP_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MVT_I4I_POSTING_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESFD3930_INV',  'ESF_FTECLEDA_GLT_MVT','${DFILP}/${ENV_PREFIX}_ESID3820_FTECLEDA_MVT_I4I_${TYPEINV}_QTD_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESFD3930_INV',  'ESF_FTECLEDA_DELTA','${DFILP}/${ENV_PREFIX}_ESFD3930_FTECLEDA_DELTA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESFD3930_INV',  'ESF_FTECLEDA_EXCLUDED','${DFILI}/${ENV_PREFIX}_ESFD3930_${IDF_CT}_FTECLEDA_EXCL_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'I4I_ESFD3930_INV','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'I4I_ESFD3930_INV','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'I4I_ESFD3930_INV','')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'I4I_ESFD3930_INV','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'I4I_ESFD3930_INV','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'I4I_ESFD3930_INV','')

	----------IDF_CT:   I4I_ESFD3930_POS_POC ------------------

		insert into BEST..TI17FNC values ('I4I_ESFD3930_POS_POC','I4I - SAP Posting POS/POC','ESFD3930',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESFD3930_POS_POC',  'ESF_FTECLEDA_SAP_MVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_MVT_I4I_POSTING_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESFD3930_POS_POC',  'ESF_FTECLEDA_GLT_MVT','${DFILP}/${ENV_PREFIX}_ESID3820_FTECLEDA_MVT_I4I_${TYPEINV}_QTD_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESFD3930_POS_POC',  'ESF_FTECLEDA_DELTA','${DFILP}/${ENV_PREFIX}_ESFD3930_FTECLEDA_DELTA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESFD3930_POS_POC',  'ESF_FTECLEDA_EXCLUDED','${DFILI}/${ENV_PREFIX}_ESFD3930_${IDF_CT}_FTECLEDA_EXCL_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'I4I_ESFD3930_POS_POC','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'I4I_ESFD3930_POS_POC','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I4I_ESFD3930_POS_POC','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'I4I_ESFD3930_POS_POC','')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'I4I_ESFD3930_POS_POC','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'I4I_ESFD3930_POS_POC','')
go

