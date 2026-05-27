-------------------------------
--mapping of  ESFD3980

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3980')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3980')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3980'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3980'

	insert into BEST..TI17CHN values ('ESFD3980',  'IO management in cashflow and discount calculation')

	----------IDF_CT:   I17G_SII_IOR_STD ------------------

		insert into BEST..TI17FNC values ('I17G_SII_IOR_STD','Group - IO management in cashflow and discount calculation','ESFD3980',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'ESF_GTSII_ICR','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'NDIC_CASHFLOW','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'ESF_GTSII_ONE_STD','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'ESF_GTSII_DUMMY_STD','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'EST_FCLIENT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCLIENT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'EST_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESCJ0660_FSSDACTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESFD5010_FPLC_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'EPO_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESFD5010_FPLATXCUM_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'ESF_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESFD3830_I17G_SII_MRG_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'ESF_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESFD3980_I17G_SII_IOR_STD_DLEIFTECLEDSIIEP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'ESF_IADPERICASE_I17_MERGE','${DFILP}/${ENV_PREFIX}_ESPD1800_I17G_AET_RPO_I17_IADPERICASE_I17_MERGE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'ESF_FTECLEDSII_IFRS17','${DFILP}/${ENV_PREFIX}_ESFD3980_I17G_SII_IOR_STD_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G_SII_IOR_STD',  'ESF_DLEIFTECLEDSIIEI','${DFILP}/${ENV_PREFIX}_ESFD3980_I17G_SII_IOR_STD_DLEIFTECLEDSIIEI${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_SII_IOR_STD','')

	----------IDF_CT:   I17L_SII_IOR_STD ------------------

		insert into BEST..TI17FNC values ('I17L_SII_IOR_STD','Local - IO management in cashflow and discount calculation','ESFD3980',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'ESF_GTSII_ICR','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'ESF_FTECLEDSII','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'EST_FCLIENT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCLIENT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'EST_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESCJ0660_FSSDACTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESFD5010_FPLC_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'NDIC_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3970_NDC_CSF_STD_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'EPO_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESFD5010_FPLATXCUM_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'ESF_GTSII_ONE_STD','${DFILP}/${ENV_PREFIX}_ESFD3830_I17L_SII_MRG_INI_GTSII_ONEFUT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOW_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'ESF_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESFD3980_I17L_SII_IOR_STD_DLEIFTECLEDSIIEP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'ESF_GTSII_DUMMY_STD','${DFILP}/${ENV_PREFIX}_ESFD3610_I17L_CSF_MRG_INI_GTSII_DUMMY_ALL_MRG_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')		
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'ESF_IADPERICASE_I17_MERGE','${DFILP}/${ENV_PREFIX}_ESPD1800_I17L_AET_RPO_I17_IADPERICASE_I17_MERGE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'ESF_FTECLEDSII_IFRS17','${DFILP}/${ENV_PREFIX}_ESFD3980_I17L_SII_IOR_STD_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L_SII_IOR_STD',  'ESF_DLEIFTECLEDSIIEI','${DFILP}/${ENV_PREFIX}_ESFD3980_I17L_SII_IOR_STD_DLEIFTECLEDSIIEI${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_SII_IOR_STD','')

	----------IDF_CT:   I17P_SII_IOR_STD ------------------

		insert into BEST..TI17FNC values ('I17P_SII_IOR_STD','Parent - IO management in cashflow and discount calculation','ESFD3980',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'ESF_GTSII_ICR','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'ESF_FTECLEDSII','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'EST_FCLIENT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCLIENT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'EST_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESCJ0660_FSSDACTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESFD5010_FPLC_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'NDIC_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3970_NDC_CSF_STD_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'EPO_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESFD5010_FPLATXCUM_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'ESF_GTSII_ONE_STD','${DFILP}/${ENV_PREFIX}_ESFD3830_I17P_SII_MRG_INI_GTSII_ONEFUT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOW_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'ESF_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESFD3980_I17P_SII_IOR_STD_DLEIFTECLEDSIIEP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'ESF_GTSII_DUMMY_STD','${DFILP}/${ENV_PREFIX}_ESFD3610_I17P_CSF_MRG_INI_GTSII_DUMMY_ALL_MRG_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'ESF_IADPERICASE_I17_MERGE','${DFILP}/${ENV_PREFIX}_ESPD1800_I17P_AET_RPO_I17_IADPERICASE_I17_MERGE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'ESF_FTECLEDSII_IFRS17','${DFILP}/${ENV_PREFIX}_ESFD3980_I17P_SII_IOR_STD_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P_SII_IOR_STD',  'ESF_DLEIFTECLEDSIIEI','${DFILP}/${ENV_PREFIX}_ESFD3980_I17P_SII_IOR_STD_DLEIFTECLEDSIIEI${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_SII_IOR_STD','')

	----------IDF_CT:   I17S_SII_IOR_STD ------------------

		insert into BEST..TI17FNC values ('I17S_SII_IOR_STD','Simulation - IO management in cashflow and discount calculation','ESFD3980',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'ESF_GTSII_ICR','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'NDIC_CASHFLOW','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'ESF_GTSII_ONE_STD','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'ESF_GTSII_DUMMY_STD','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'EST_FCLIENT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCLIENT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'EST_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESCJ0660_FSSDACTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESFD5010_FPLC_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'EPO_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESFD5010_FPLATXCUM_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'ESF_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESFD3830_I17S_SII_MRG_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'ESF_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESFD3980_I17S_SII_IOR_STD_DLEIFTECLEDSIIEP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'ESF_IADPERICASE_I17_MERGE','${DFILP}/${ENV_PREFIX}_ESPD1800_I17S_AET_RPO_I17_IADPERICASE_I17_MERGE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'ESF_FTECLEDSII_IFRS17','${DFILP}/${ENV_PREFIX}_ESFD3980_I17S_SII_IOR_STD_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S_SII_IOR_STD',  'ESF_DLEIFTECLEDSIIEI','${DFILP}/${ENV_PREFIX}_ESFD3980_I17S_SII_IOR_STD_DLEIFTECLEDSIIEI${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_SII_IOR_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_SII_IOR_STD','')
go

