-------------------------------
--mapping of  ESFD3850

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3850')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3850')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3850'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3850'

	insert into BEST..TI17CHN values ('ESFD3850',  'Send GLT Movement EBS and IFRS17 to SAP')

	----------IDF_CT:   EBS_OMG_SAP_STD ------------------

		insert into BEST..TI17FNC values ('EBS_OMG_SAP_STD','Send GLT Movement EBS and IFRS17 to SAP','ESFD3850',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_OMG_SAP_STD',  'ESF_FICTOONEGL1','ESFD3840_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}','I','')
			insert into BEST..TI17PERMFIL values ('EBS_OMG_SAP_STD',  'ESF_FICFROMONEGL','FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('EBS_OMG_SAP_STD',  'ESF_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESFD3930_EBS_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'EBS_OMG_SAP_STD','')

	----------IDF_CT:   I17G_OMG_SAP_STD ------------------

		insert into BEST..TI17FNC values ('I17G_OMG_SAP_STD','Send GLT Movement EBS and IFRS17 to SAP','ESFD3850',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_OMG_SAP_STD',  'ESF_FICFROMONEGL','FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_SAP_STD',  'ESF_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESFD3930_I17G_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_SAP_STD',  'ESF_FICTOONEGL1','ESFD3840_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'I17G_OMG_SAP_STD','')

	----------IDF_CT:   I17L_OMG_SAP_STD ------------------

		insert into BEST..TI17FNC values ('I17L_OMG_SAP_STD','Send GLT Movement EBS and IFRS17 to SAP','ESFD3850',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_OMG_SAP_STD',  'ESF_FICTOONEGL1','ESFD3840_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_SAP_STD',  'ESF_FICFROMONEGL','FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_SAP_STD',  'ESF_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESFD3930_I17L_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'I17L_OMG_SAP_STD','')

	----------IDF_CT:   I17P_OMG_SAP_STD ------------------

		insert into BEST..TI17FNC values ('I17P_OMG_SAP_STD','Send GLT Movement EBS and IFRS17 to SAP','ESFD3850',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_OMG_SAP_STD',  'ESF_FICTOONEGL1','ESFD3840_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_SAP_STD',  'ESF_FICFROMONEGL','FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_SAP_STD',  'ESF_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESFD3930_I17P_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'I17P_OMG_SAP_STD','')

	----------IDF_CT:   I17S_OMG_SAP_STD ------------------

		insert into BEST..TI17FNC values ('I17S_OMG_SAP_STD','Send GLT Movement EBS and IFRS17 to SAP','ESFD3850',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_OMG_SAP_STD',  'ESF_FICFROMONEGL','FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}_${CRE_D}','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_SAP_STD',  'ESF_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESFD3930_I17S_DLT_SAP_STD_FTECLEDA_DELTA_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_SAP_STD',  'ESF_FICTOONEGL1','ESFD3840_FTECLEDA_${NORME_CF}_MVT_${HOST_PRDSIT}','O','')

		----------   Reqs    ---------------------

go

