-------------------------------
--mapping of  ESFD3770 

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3770')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3770')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3770'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3770'

	insert into BEST..TI17CHN values ('ESFD3770',  'IFRS17 - CSM/LC pattern calculation')

	----------IDF_CT:   EBS_ESFD3770 ------------------

		insert into BEST..TI17FNC values ('EBS_ESFD3770','EBS - CSM/LC pattern calculation','ESFD3770',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'EST_FBOPRSLNK_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FBOPRSLNK_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'MANUAL_OVERWRITE','`ls -t ${DUSERS}/DIP_CSM_I17G_${PARM_ICLODAT_D}_*.txt | head -1 `','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESFD2230_DLDGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'EST_DLSGTAA','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'ESF_NDIC_NCB_STD','${DFILP}/${ENV_PREFIX}_ESPD0060_NDIC_NCB_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'EST_DLCUMGTAAR','${DFILP}/${ENV_PREFIX}_ESFD4020_DLCUMGTAAR_ITD_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'EST_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESFD5010_IRDPERICASE0_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFD5040_IADPERICASE_STD_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'ESF_CSM_LC_AMORT_PATTERN','${DFILP}/${ENV_PREFIX}_ESFD3770_CSM_LC_AMORT_PATTERN_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD3770',  'ESF_DLRGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			
		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESFD3770','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESFD3770','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESFD3770','')
			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESFD3770','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESFD3770','')

	----------IDF_CT:   I17G_CSM_AMR_STD ------------------

		insert into BEST..TI17FNC values ('I17G_CSM_AMR_STD','IFRS17 Group - CSM/LC pattern calculation','ESFD3770',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------


	----------IDF_CT:   I17G_ESFD3770 ------------------

		insert into BEST..TI17FNC values ('I17G_ESFD3770','EBS - CSM/LC pattern calculation','ESFD3770',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'EST_FBOPRSLNK_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FBOPRSLNK_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2220_DLDGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'EST_DLSGTAA','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'MANUAL_OVERWRITE','`ls -t ${DUSERS}/DIP_CSM_${NORME_CF}_${PARM_ICLODAT_D}_*.txt | head -1 `','I','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'ESF_NDIC_NCB_STD','${DFILP}/${ENV_PREFIX}_ESPD0060_NDIC_NCB_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'EST_DLCUMGTAAR','${DFILP}/${ENV_PREFIX}_ESFD4020_DLCUMGTAAR_ITD_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'EST_IRDPERICASE0','`ls -t ${DFILP}/${ENV_PREFIX}_ESFD5010_IRDPERICASE0_EBS_PO*_${PARM_ICLODAT_D}.dat | head -1 `','I','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'EST_IADPERICASE_STD','`ls -t ${DFILP}/${ENV_PREFIX}_ESFD5010_IADPERICASE_STD_EBS_PO*_${PARM_ICLODAT_D}.dat | head -1`','I','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'ESF_CSM_LC_AMORT_PATTERN','${DFILP}/${ENV_PREFIX}_ESFD3770_CSM_LC_AMORT_PATTERN_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G_ESFD3770',  'ESF_DLRGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_ESFD3770','')
			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_ESFD3770','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_ESFD3770','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_ESFD3770','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_ESFD3770','')

	----------IDF_CT:   I17L_CSM_AMR_STD ------------------

		insert into BEST..TI17FNC values ('I17L_CSM_AMR_STD','IFRS17 Local - CSM/LC pattern calculation','ESFD3770',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------


	----------IDF_CT:   I17P_CSM_AMR_STD ------------------

		insert into BEST..TI17FNC values ('I17P_CSM_AMR_STD','IFRS17 Parent - CSM/LC pattern calculation','ESFD3770',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------


	----------IDF_CT:   I17S_CSM_AMR_STD ------------------

		insert into BEST..TI17FNC values ('I17S_CSM_AMR_STD','IFRS17 Simulation - CSM/LC pattern calculation','ESFD3770',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------


	----------IDF_CT:   I17S_ESFD3770 ------------------

		insert into BEST..TI17FNC values ('I17S_ESFD3770','EBS - CSM/LC pattern calculation','ESFD3770',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'EST_FBOPRSLNK_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FBOPRSLNK_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2220_DLDGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'EST_DLSGTAA','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'MANUAL_OVERWRITE','`ls -t ${DUSERS}/DIP_CSM_${NORME_CF}_${PARM_ICLODAT_D}_*.txt | head -1 `','I','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'ESF_NDIC_NCB_STD','${DFILP}/${ENV_PREFIX}_ESPD0060_NDIC_NCB_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'EST_DLCUMGTAAR','${DFILP}/${ENV_PREFIX}_ESFD4020_DLCUMGTAAR_ITD_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'EST_IRDPERICASE0','`ls -t ${DFILP}/${ENV_PREFIX}_ESFD5010_IRDPERICASE0_EBS_PO*_${PARM_ICLODAT_D}.dat | head -1 `','I','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'EST_IADPERICASE_STD','`ls -t ${DFILP}/${ENV_PREFIX}_ESFD5010_IADPERICASE_STD_EBS_PO*_${PARM_ICLODAT_D}.dat | head -1`','I','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'ESF_CSM_LC_AMORT_PATTERN','${DFILP}/${ENV_PREFIX}_ESFD3770_CSM_LC_AMORT_PATTERN_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S_ESFD3770',  'ESF_DLRGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_ESFD3770','')
			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_ESFD3770','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_ESFD3770','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_ESFD3770','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_ESFD3770','')
go

