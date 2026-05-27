-------------------------------
--mapping of  ESFD3680

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3680')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3680')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3680'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3680'

	insert into BEST..TI17CHN values ('ESFD3680',  'Merge RA and RA Prudence')


    ----------IDF_CT:   I17G_RAD_GLO_INI ------------------

		insert into BEST..TI17FNC values ('I17G_RAD_GLO_INI','Group Merge RA and RA Prudence at inception','ESFD3680',0)
					
		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAD_CKI_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAP_CKI_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17G_RAD_GLO_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_RAD_GLO_INI','')


    ----------IDF_CT:   I17G_RAD_GLO_STD ------------------

		insert into BEST..TI17FNC values ('I17G_RAD_GLO_STD','Group Merge RA and RA Prudence','ESFD3680',0)
					
		----------  Perms---------------------

            insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAD_CUR_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAP_CUR_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17G_RAD_GLO_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')	

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_RAD_GLO_STD','')


	----------IDF_CT:   I17G_RAD_GLO_STD_AA0 ------------------

		insert into BEST..TI17FNC values ('I17G_RAD_GLO_STD_AA0','MicroAOC AA0_RAD_GLO_STD','ESFD3680',0)
					
		----------  Perms---------------------

            insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA0',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAD_CKI_STD_AA0_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA0',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAP_CKI_STD_AA0_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA0',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17G_RAD_GLO_STD_AA0_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('INVO',  'I17G_RAD_GLO_STD_AA0','INVO')
			insert into BEST..TI17REQFNC values ('POCO',  'I17G_RAD_GLO_STD_AA0','POCO')
			insert into BEST..TI17REQFNC values ('POSO',  'I17G_RAD_GLO_STD_AA0','POSO')


    ----------IDF_CT:   I17G_RAD_GLO_STD_AA1 ------------------

		insert into BEST..TI17FNC values ('I17G_RAD_GLO_STD_AA1','MicroAOC AA1_RAD_GLo_STD','ESFD3680',0)
					
		----------  Perms---------------------

            insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA1',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAD_CKI_STD_AA1_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA1',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAP_CKI_STD_AA1_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA1',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17G_RAD_GLO_STD_AA1_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('INVO',  'I17G_RAD_GLO_STD_AA1','INVO')
			insert into BEST..TI17REQFNC values ('POCO',  'I17G_RAD_GLO_STD_AA1','POCO')
			insert into BEST..TI17REQFNC values ('POSO',  'I17G_RAD_GLO_STD_AA1','POSO')


    ----------IDF_CT:   I17G_RAD_GLO_STD_AA2 ------------------

		insert into BEST..TI17FNC values ('I17G_RAD_GLO_STD_AA2','MicroAOC AA2_RAD_GLO_STD','ESFD3680',0)
					
		----------  Perms---------------------

            insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA2',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAD_CKI_STD_AA2_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA2',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAP_CKI_STD_AA2_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA2',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17G_RAD_GLO_STD_AA2_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('INVO',  'I17G_RAD_GLO_STD_AA2','INVO')
			insert into BEST..TI17REQFNC values ('POCO',  'I17G_RAD_GLO_STD_AA2','POCO')
			insert into BEST..TI17REQFNC values ('POSO',  'I17G_RAD_GLO_STD_AA2','POSO')


    ----------IDF_CT:   I17G_RAD_GLO_STD_AA3 ------------------

		insert into BEST..TI17FNC values ('I17G_RAD_GLO_STD_AA3','MicroAOC AA3_RAD_GLO_STD','ESFD3680',0)
					
		----------  Perms---------------------

            insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA3',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAD_CKI_STD_AA3_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA3',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17G_RAP_CKI_STD_AA3_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_RAD_GLO_STD_AA3',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17G_RAD_GLO_STD_AA3_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('INVO',  'I17G_RAD_GLO_STD_AA3','INVO')
			insert into BEST..TI17REQFNC values ('POCO',  'I17G_RAD_GLO_STD_AA3','POCO')
			insert into BEST..TI17REQFNC values ('POSO',  'I17G_RAD_GLO_STD_AA3','POSO')



    ----------IDF_CT:   I17L_RAD_GLO_INI ------------------

		insert into BEST..TI17FNC values ('I17L_RAD_GLO_INI','Local Merge RA and RA Prudence at inception','ESFD3680',0)
					
		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17L_RAD_CKI_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17L_RAP_CKI_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17L_RAD_GLO_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_RAD_GLO_INI','')


    ----------IDF_CT:   I17L_RAD_GLO_STD ------------------

		insert into BEST..TI17FNC values ('I17L_RAD_GLO_STD','Local Merge RA and RA Prudence','ESFD3680',0)
					
		----------  Perms---------------------

            insert into BEST..TI17PERMFIL values ('I17L_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17L_RAD_CUR_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17L_RAP_CUR_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17L_RAD_GLO_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')	

		----------   Reqs    ---------------------

            insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_RAD_GLO_STD','')


    ----------IDF_CT:   I17P_RAD_GLO_INI ------------------

		insert into BEST..TI17FNC values ('I17P_RAD_GLO_INI','Parent Merge RA and RA Prudence at inception','ESFD3680',0)
					
		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17P_RAD_CKI_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17P_RAP_CKI_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17P_RAD_GLO_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_RAD_GLO_INI','')


    ----------IDF_CT:   I17P_RAD_GLO_STD ------------------

		insert into BEST..TI17FNC values ('I17P_RAD_GLO_STD','Parent Merge RA and RA Prudence','ESFD3680',0)
					
		----------  Perms---------------------

            insert into BEST..TI17PERMFIL values ('I17P_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17P_RAD_CUR_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17P_RAP_CUR_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17P_RAD_GLO_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')	

		----------   Reqs    ---------------------

            insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_RAD_GLO_STD','')



    ----------IDF_CT:   I17S_RAD_GLO_INI ------------------

		insert into BEST..TI17FNC values ('I17S_RAD_GLO_INI','Simu Merge RA and RA Prudence at inception','ESFD3680',0)
					
		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17S_RAD_CKI_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17S_RAP_CKI_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_RAD_GLO_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17S_RAD_GLO_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_RAD_GLO_INI','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_RAD_GLO_INI','')


    ----------IDF_CT:   I17S_RAD_GLO_STD ------------------

		insert into BEST..TI17FNC values ('I17S_RAD_GLO_STD','Simu Merge RA and RA Prudence','ESFD3680',0)
					
		----------  Perms---------------------

            insert into BEST..TI17PERMFIL values ('I17S_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${ENV_PREFIX}_ESFD3650_I17S_RAD_CUR_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAP','${DFILP}/${ENV_PREFIX}_ESFD3650_I17S_RAP_CUR_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_RAD_GLO_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3680_I17S_RAD_GLO_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')	

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_RAD_GLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_RAD_GLO_STD','')

go   
    