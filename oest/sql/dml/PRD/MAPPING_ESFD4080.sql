-------------------------------
--mapping of  ESFD4080

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD4080')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD4080')
	delete BEST..TI17FNC where CHAIN_CT='ESFD4080'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD4080'

	insert into BEST..TI17CHN values ('ESFD4080',  'Tag SAS AE from SAP POSTING file')

	----------IDF_CT:   I17G_SAP_AE_STD ------------------

		insert into BEST..TI17FNC values ('I17G_SAP_AE_STD','Tag SAS AE from SAP POSTING file','ESFD4080',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_SAP_AE_STD',  'ESF_FTECLEDA_POSTING','${DFILP}/${ENV_PREFIX}_ESFD3960_${NORME_CF}_SAP_OMG_STD_FTECLEDA_POSTING_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G_SAP_AE_STD','')

	----------IDF_CT:   I17L_SAP_AE_STD ------------------

		insert into BEST..TI17FNC values ('I17L_SAP_AE_STD','Tag SAS AE from SAP POSTING file','ESFD4080',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_SAP_AE_STD',  'ESF_FTECLEDA_POSTING','${DFILP}/${ENV_PREFIX}_ESFD3960_${NORME_CF}_SAP_OMG_STD_FTECLEDA_POSTING_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LQINVB',  'I17L_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17L_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINVB',  'I17L_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17L_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSP',  'I17L_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSP',  'I17L_SAP_AE_STD','')

	----------IDF_CT:   I17P_SAP_AE_STD ------------------

		insert into BEST..TI17FNC values ('I17P_SAP_AE_STD','Tag SAS AE from SAP POSTING file','ESFD4080',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_SAP_AE_STD',  'ESF_FTECLEDA_POSTING','${DFILP}/${ENV_PREFIX}_ESFD3960_${NORME_CF}_SAP_OMG_STD_FTECLEDA_POSTING_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PQINVB',  'I17P_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17P_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINVB',  'I17P_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17P_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSP',  'I17P_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSP',  'I17P_SAP_AE_STD','')

	----------IDF_CT:   I17S_SAP_AE_STD ------------------

		insert into BEST..TI17FNC values ('I17S_SAP_AE_STD','Tag SAS AE from SAP POSTING file','ESFD4080',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_SAP_AE_STD',  'ESF_FTECLEDA_POSTING','${DFILP}/${ENV_PREFIX}_ESFD3960_${NORME_CF}_SAP_OMG_STD_FTECLEDA_POSTING_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SQINVB',  'I17S_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSB',  'I17S_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINVB',  'I17S_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSB',  'I17S_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSP',  'I17S_SAP_AE_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSP',  'I17S_SAP_AE_STD','')
go

