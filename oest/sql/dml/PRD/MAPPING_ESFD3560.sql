-------------------------------
--mapping of  ESFD3560

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3560')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3560')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3560'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3560'

	insert into BEST..TI17CHN values ('ESFD3560',  'check SAP file feedback')

	----------IDF_CT:   I17G_SAP_CHK_SIMU ------------------

		insert into BEST..TI17FNC values ('I17G_SAP_CHK_SIMU','check SAP file feedback','ESFD3560',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_PREV','${DFILP}/${ENV_PREFIX}_ESFD3930_${NORME_CF}_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SAP_CHK_SIMU',  'ESF_FICFROMONEGL','OTGL0030_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${PARM_CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('I17G_SAP_CHK_SIMU',  'ESF_SAP_RETURN_CHECKS','${DFILI}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_SAP_RETURN_CHECKS.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_TMP','${DFILT}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARM_CRE_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G_SAP_CHK_SIMU','')

	----------IDF_CT:   I17L_SAP_CHK_SIMU ------------------

		insert into BEST..TI17FNC values ('I17L_SAP_CHK_SIMU','check SAP file feedback','ESFD3560',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_PREV','${DFILP}/${ENV_PREFIX}_ESFD3930_${NORME_CF}_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SAP_CHK_SIMU',  'ESF_FICFROMONEGL','OTGL0030_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${PARM_CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('I17L_SAP_CHK_SIMU',  'ESF_SAP_RETURN_CHECKS','${DFILI}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_SAP_RETURN_CHECKS.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_TMP','${DFILT}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARM_CRE_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LQINVB',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LYINVB',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LQPOSP',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LYPOSP',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_SAP_CHK_SIMU','')

	----------IDF_CT:   I17P_SAP_CHK_SIMU ------------------

		insert into BEST..TI17FNC values ('I17P_SAP_CHK_SIMU','check SAP file feedback','ESFD3560',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_PREV','${DFILP}/${ENV_PREFIX}_ESFD3930_${NORME_CF}_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SAP_CHK_SIMU',  'ESF_FICFROMONEGL','OTGL0030_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${PARM_CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('I17P_SAP_CHK_SIMU',  'ESF_SAP_RETURN_CHECKS','${DFILI}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_SAP_RETURN_CHECKS.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_TMP','${DFILT}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARM_CRE_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PQINVB',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PYINVB',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PQPOSP',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PYPOSP',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_SAP_CHK_SIMU','')



	----------IDF_CT:   EBS_SAP_CHK_SIMU ------------------

		insert into BEST..TI17FNC values ('EBS_SAP_CHK_SIMU','check SAP file feedback','ESFD3560',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_PREV','${DFILP}/${ENV_PREFIX}_ESFD3930_${NORME_CF}_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_SAP_CHK_SIMU',  'ESF_FICFROMONEGL','OTGL0030_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${PARM_CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('EBS_SAP_CHK_SIMU',  'ESF_SAP_RETURN_CHECKS','${DFILI}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_SAP_RETURN_CHECKS.dat','O','')
			insert into BEST..TI17PERMFIL values ('EBS_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_TMP','${DFILT}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARM_CRE_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_SAP_CHK_SIMU','')
			
	----------IDF_CT:   I4I_SAP_CHK_SIMU ------------------

		insert into BEST..TI17FNC values ('I4I_SAP_CHK_SIMU','check SAP file feedback','ESFD3560',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_PREV','${DFILP}/${ENV_PREFIX}_ESFD3930_FTECLEDA_DELTA_I4I_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_SAP_CHK_SIMU',  'ESF_FICFROMONEGL','OTGL0030_FTECLEDA_MVT_${HOST_PRDSIT}_${CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('I4I_SAP_CHK_SIMU',  'ESF_SAP_RETURN_CHECKS','${DFILI}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_SAP_RETURN_CHECKS.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_SAP_CHK_SIMU',  'ESF_FTECLEDA_MVT_TMP','${DFILT}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARM_CRE_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'I4I_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'I4I_SAP_CHK_SIMU','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'I4I_SAP_CHK_SIMU','')


	----------IDF_CT:   I4I_SAP_POSI_SIMU ------------------

		insert into BEST..TI17FNC values ('I4I_SAP_POSI_SIMU','check SAP file feedback','ESFD3560',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_SAP_POSI_SIMU',  'ESF_FTECLEDA_MVT_PREV','${DFILP}/${ENV_PREFIX}_ESFD3930_FTECLEDA_DELTA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_SAP_POSI_SIMU',  'ESF_FICFROMONEGL','OTGL0030_FTECLEDASO_MVT_${HOST_PRDSIT}_${CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('I4I_SAP_POSI_SIMU',  'ESF_SAP_RETURN_CHECKS','${DFILI}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_SAP_RETURN_CHECKS.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_SAP_POSI_SIMU',  'ESF_FTECLEDA_MVT_TMP','${DFILT}/${ENV_PREFIX}_ESFD3560_${IDF_CT}_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}_${PARM_CRE_D}.dat','O','')

		----------   Reqs    ---------------------
			insert into BEST..TI17REQFNC values ('I4IQPOS',   'I4I_SAP_POSI_SIMU','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',   'I4I_SAP_POSI_SIMU','')
go

	
go

