-------------------------------
--mapping of  ESFD1040

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD1040')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD1040')
	delete BEST..TI17FNC where CHAIN_CT='ESFD1040'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD1040'

	insert into BEST..TI17CHN values ('ESFD1040',  'Granularity products')

	----------IDF_CT:   EBS_GRN_UPD_ALL ------------------

		insert into BEST..TI17FNC values ('EBS_GRN_UPD_ALL','Granularity products','ESFD1040',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'EST_CURGTA','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'EST_CURGTR','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'EPO_DLREJGTRSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'EPO_DLREJGTAASIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'EPO_DLREJGTARSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'ESF_FCTRI17PRD','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'ESF_FI17PRODUCT','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'EST_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'ESF_FTECLEDA_REJ','${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDA_REJ_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'ESF_FTECLEDR_REJ','${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDR_REJ_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'ESF_FTECLEDA_OPNG','${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDA_OPNG_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_GRN_UPD_ALL',  'ESF_FTECLEDR_OPNG','${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDR_OPNG_${NORME_CF}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_GRN_UPD_ALL','')

	----------IDF_CT:   I17G_GRN_UPD_ALL ------------------

		insert into BEST..TI17FNC values ('I17G_GRN_UPD_ALL','Granularity products','ESFD1040',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'EST_CURGTA','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'EST_CURGTR','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'EPO_DLREJGTRSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'EPO_DLREJGTAASIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'EPO_DLREJGTARSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'ESF_FCTRI17PRD','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'ESF_FI17PRODUCT','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'EST_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'ESF_FTECLEDA_REJ','${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDA_REJ_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'ESF_FTECLEDR_REJ','${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDR_REJ_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'ESF_FTECLEDA_OPNG','${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDA_OPNG_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_GRN_UPD_ALL',  'ESF_FTECLEDR_OPNG','${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDR_OPNG_${NORME_CF}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G_GRN_UPD_ALL','')

	----------IDF_CT:   I17L_GRN_UPD_ALL ------------------

		insert into BEST..TI17FNC values ('I17L_GRN_UPD_ALL','Granularity products','ESFD1040',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'EST_CURGTA','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'EST_CURGTR','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'EPO_DLREJGTRSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'EPO_DLREJGTAASIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'EPO_DLREJGTARSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'ESF_FCTRI17PRD','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'ESF_FI17PRODUCT','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'EST_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'ESF_FTECLEDA_REJ','${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDA_REJ_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'ESF_FTECLEDR_REJ','${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDR_REJ_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'ESF_FTECLEDA_OPNG','${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDA_OPNG_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_GRN_UPD_ALL',  'ESF_FTECLEDR_OPNG','${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDR_OPNG_${NORME_CF}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LQINVB',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LYINVB',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LQPOSP',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LYPOSP',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_GRN_UPD_ALL','')

	----------IDF_CT:   I17P_GRN_UPD_ALL ------------------

		insert into BEST..TI17FNC values ('I17P_GRN_UPD_ALL','Granularity products','ESFD1040',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'EST_CURGTA','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'EST_CURGTR','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'EPO_DLREJGTRSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'EPO_DLREJGTAASIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'EPO_DLREJGTARSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'ESF_FCTRI17PRD','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'ESF_FI17PRODUCT','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'EST_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'ESF_FTECLEDA_REJ','${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDA_REJ_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'ESF_FTECLEDR_REJ','${DFILP}/${ENV_PREFIX}_ESFX7000_FTECLEDR_REJ_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'ESF_FTECLEDA_OPNG','${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDA_OPNG_${NORME_CF}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_GRN_UPD_ALL',  'ESF_FTECLEDR_OPNG','${DFILP}/${ENV_PREFIX}_ESFD2900_FTECLEDR_OPNG_${NORME_CF}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PYINVB',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PQPOSP',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PYPOSP',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PQINVB',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_GRN_UPD_ALL','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_GRN_UPD_ALL','')

	----------IDF_CT:   I4I_GRN_UPD_INVI ------------------

		insert into BEST..TI17FNC values ('I4I_GRN_UPD_INVI','Granularity products','ESFD1040',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'ESF_FTECLEDA_REJ','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'ESF_FTECLEDR_REJ','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'EPO_DLREJGTRSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'ESF_FTECLEDA_OPNG','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'ESF_FTECLEDR_OPNG','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'EPO_DLREJGTAASIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'EPO_DLREJGTARSIISO','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'ESF_FCTRI17PRD','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'ESF_FI17PRODUCT','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_INVI',  'EST_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'I4I_GRN_UPD_INVI','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'I4I_GRN_UPD_INVI','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'I4I_GRN_UPD_INVI','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'I4I_GRN_UPD_INVI','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'I4I_GRN_UPD_INVI','')

	----------IDF_CT:   I4I_GRN_UPD_POSI ------------------

		insert into BEST..TI17FNC values ('I4I_GRN_UPD_POSI','Granularity products','ESFD1040',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'ESF_FTECLEDA_REJ','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'ESF_FTECLEDR_REJ','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'ESF_FTECLEDA_OPNG','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'ESF_FTECLEDR_OPNG','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'ESF_FCTRI17PRD','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'ESF_FI17PRODUCT','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'EST_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'EPO_DLREJGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTR_${NORME_CF}_POS_${PARM_PREV_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'EPO_DLREJGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTAA_${NORME_CF}_POS_${PARM_PREV_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_GRN_UPD_POSI',  'EPO_DLREJGTARSIISO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTAR_${NORME_CF}_POS_${PARM_PREV_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'I4I_GRN_UPD_POSI','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'I4I_GRN_UPD_POSI','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I4I_GRN_UPD_POSI','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'I4I_GRN_UPD_POSI','')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'I4I_GRN_UPD_POSI','')
			insert into BEST..TI17REQFNC values ('I4IQPOCB',  'I4I_GRN_UPD_POSI','')
			insert into BEST..TI17REQFNC values ('I4IYPOC',  'I4I_GRN_UPD_POSI','')
			insert into BEST..TI17REQFNC values ('I4IYPOCB',  'I4I_GRN_UPD_POSI','')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'I4I_GRN_UPD_POSI','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'I4I_GRN_UPD_POSI','')
go

