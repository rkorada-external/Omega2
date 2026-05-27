----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3610
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3610')  insert into BEST..TI17CHN values ('ESFD3610',  'Cash flow at inception')

		-- I17G_CSF_ALL_INII17G_CSF_ALL_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_CSF_ALL_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_CSF_ALL_INI'  ) insert into BEST..TI17FNC values ('I17G_CSF_ALL_INI',  'cashflow at inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_IRDPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'ESF_IADVPERICASE_P','${DFILP}/${ENV_PREFIX}_ESEH1100_IADVPERICASE_P_INI${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDSIIGTR','${DFILP}/${ENV_PREFIX}_ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTR${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDSIIGTAA','${DFILP}/${ENV_PREFIX}_ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTAA${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDSIIGTAR','${DFILP}/${ENV_PREFIX}_ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTAR${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESFD3610_I17G_CSF_ALL_INI_FTECLEDSII${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'ESF_IRDPERICASE_NP','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_FSEGPATTERN_CSF','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_CSF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_FSEGPATTERN_ICR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_ICR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_CSF_ALL_INI' and  CHAIN_CT='ESFD3610'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3610','I17G_CSF_ALL_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3750
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3750')  insert into BEST..TI17CHN values ('ESFD3750',  'IFRS17 - CSM at closing assessment')

		-- I17G_CSM_ALL_STDI17G_CSM_ALL_STD

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_CSM_ALL_STD'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_CSM_ALL_STD'  ) insert into BEST..TI17FNC values ('I17G_CSM_ALL_STD',  'IFRS17 Group - CSM at closing assessment')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESID0060_FCURSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_DLCUMGTAAR','${DFILP}/${ENV_PREFIX}_ESFD4020_DLCUMGTAAR_MVT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_CSM','${DFILP}/${ENV_PREFIX}_ESFD3710_I17G_CSM_CSU_INI_GTSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17G_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_FSEGPROF_INI','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'EST_FSEGPATTERN_DSC_f17','${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_I17G_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3690_I17G_IRV_ALL_STD_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_TRANSITION_FILE','${DFILP}/${ENV_PREFIX}_ESFT0020_I17G_OMG_ALL_TRA_TRANSITION_FILE${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_IFRS17_CSM','${DFILP}/${ENV_PREFIX}_ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_CSM${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_FSEGPROF_STD_PREVIOUS','${DFILP}/${ENV_PREFIX}_ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_ESCOMPTE_FWD','${DFILP}/${ENV_PREFIX}_ESFD3690_I17G_IRV_ALL_STD_GTSII_ESCOMPTE_FWD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_CSM_LC_AMORT_PATTERN','${DFILP}/${ENV_PREFIX}_ESFD3770_I17G_CSM_AMR_STD_CSM_LC_AMORT_PATTERN_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_CSM_CASHFLOW_PREV','${DFILP}/${ENV_PREFIX}_ESFD3760_I17G_UOA_PRO_STD_GTSII_CSM_CASHFLOW_${TYPEINV}_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_CSM_LC_AMORT_PATTERN_PREV','${DFILP}/${ENV_PREFIX}_ESFD3770_I17G_CSM_AMR_STD_CSM_LC_AMORT_PATTERN_${TYPEINV}_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_CSM_PROF','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_PROF_BY_CTR_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_CSM_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_GTSII_CSM_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_CSM_TMP_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_GTSII_CSM_TMP_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_CSM_ALL_STD' and  CHAIN_CT='ESFD3750'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3750','I17G_CSM_ALL_STD','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3720
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3720')  insert into BEST..TI17CHN values ('ESFD3720',  'IFRS17 - UOA definition at inception')

		-- I17G_CSM_CRE_INII17G_CSM_CRE_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_CSM_CRE_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_CSM_CRE_INI'  ) insert into BEST..TI17FNC values ('I17G_CSM_CRE_INI',  'IFRS17 - Group - UOA definition at inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FUOASII','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G___TUOASII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_GTSII_CSM','${DFILP}/${ENV_PREFIX}_ESFD3710_I17G_CSM_CSU_INI_GTSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_IADPERICASE_INI','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17G_INI_${PARM_ICLODAT_D}_${TYPEINV}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FRERETFACCTR_INI','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FRETIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FRETIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSECIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FSEGPROF','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FSECIFRS_LIGHT','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSECIFRS_LIGHT${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_CSM_CRE_INI' and  CHAIN_CT='ESFD3720'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3720','I17G_CSM_CRE_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3620
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3620')  insert into BEST..TI17CHN values ('ESFD3620',  'Discount at lock in rate')

		-- I17G_DSC_LKI_INII17G_DSC_LKI_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_INI',  'RA Discount Calculation at inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESID0060_FCURSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FPRSMAP_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_DSC_LKI_INI' and  CHAIN_CT='ESFD3620'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_DSC_LKI_INI','')

		-- I17G_RAD_LKI_INII17G_RAD_LKI_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_INI',  'RA Discount risk adjustement at inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_RAD_LKI_INI' and  CHAIN_CT='ESFD3620'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_RAD_LKI_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD2220
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD2220')  insert into BEST..TI17CHN values ('ESFD2220',  'Future at inception')

		-- I17G_FUT_ALL_INII17G_FUT_ALL_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_FUT_ALL_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_FUT_ALL_INI'  ) insert into BEST..TI17FNC values ('I17G_FUT_ALL_INI',  'Future at inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FCTRGRO${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_ALL_INI',  'EST_FSEGEST_SOLVENCY','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGEST_TRN_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD2220'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD2220','I17G_FUT_ALL_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD2570
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD2570')  insert into BEST..TI17CHN values ('ESFD2570',  'Retro NP at Inception')

		-- I17G_FUT_RNP_INII17G_FUT_RNP_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_FUT_RNP_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_FUT_RNP_INI'  ) insert into BEST..TI17FNC values ('I17G_FUT_RNP_INI',  'Retro NP at Inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_RNP_INI',  'EPO_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_RNP_INI' and  CHAIN_CT='ESFD2570'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD2570','I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD2570','I17G_FUT_RNP_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD2550
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD2550')  insert into BEST..TI17CHN values ('ESFD2550',  'Bouclette Future RetroP Inception')

		-- I17G_FUT_RPO_INII17G_FUT_RPO_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_FUT_RPO_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_FUT_RPO_INI'  ) insert into BEST..TI17FNC values ('I17G_FUT_RPO_INI',  'Bouclette Future RetroP Inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_RPO_INI',  'EPO_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_RPO_INI' and  CHAIN_CT='ESFD2550'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD2550','I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD2550','I17G_FUT_RPO_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3630
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3630')  insert into BEST..TI17CHN values ('ESFD3630',  'Maintenance/Acquisition expenses CSF')

		-- I17G_IEX_ALL_INII17G_IEX_ALL_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IEX_ALL_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IEX_ALL_INI'  ) insert into BEST..TI17FNC values ('I17G_IEX_ALL_INI',  'Maintenance/Acquisition expenses CSF INI')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EST_CSF_NDIC_AMOUNT','${DFILP}/empty.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'ESF_FMARKET','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EPO_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EPO_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EPO_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EPO_IRDPERICASE0_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EST_FSEGPATTERN_CSF','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_CSF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'ESF_GTESTCUMUL_RET','${DFILP}/${ENV_PREFIX}_ESFD3672_I17G_IEX_ALL_INI_GTESTCUMUL_RET_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'ESF_GTESTCUMUL_ACCRET','${DFILP}/${ENV_PREFIX}_ESFD3671_I17G_IEX_ALL_INI_GTESTCUMUL_ACCRET_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_IEX_ALL_INI' and  CHAIN_CT='ESFD3630'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3630','I17G_IEX_ALL_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3690
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3690')  insert into BEST..TI17CHN values ('ESFD3690',  'Revenue Calculation')

		-- I17G_IRV_ALL_STDI17G_IRV_ALL_STD

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IRV_ALL_STD'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IRV_ALL_STD'  ) insert into BEST..TI17FNC values ('I17G_IRV_ALL_STD',  'revenue calculation')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_IRV_ALL_STD',  'PARM_IS_TRN','YES','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_IRV_ALL_STD' and  CHAIN_CT='ESFD3690'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3690','I17G_IRV_ALL_STD','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0020
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0020')  insert into BEST..TI17CHN values ('ESFT0020',  'IFRS17 - Transition File Generation')

		-- I17G_OMG_ALL_TRAI17G_OMG_ALL_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_OMG_ALL_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_OMG_ALL_TRA'  ) insert into BEST..TI17FNC values ('I17G_OMG_ALL_TRA',  'IFRS17 - Transition File Generation')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA',  'BUSINESS_LOGS','${DFILP}/${ENV_PREFIX}_BUISNESS_TRANSITION_LOG.log','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA',  'TRANSITION_INPUT_FILE','${DFILP}/${ENV_PREFIX}_BUISNESS_TRANSITION_I17G${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA',  'TRANSITION_OUTPUT_FILE','${DFILP}/${ENV_PREFIX}_ESFT0020_I17G_OMG_ALL_TRA_TRANSITION_FILE${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_OMG_ALL_TRA' and  CHAIN_CT='ESFT0020'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFT0020','I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFT0020','I17G_OMG_ALL_TRA','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0010
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0010')  insert into BEST..TI17CHN values ('ESFT0010',  'IFRS17 - Omega extract Generation')

		-- I17G_OMG_CSU_TRAI17G_OMG_CSU_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_OMG_CSU_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_OMG_CSU_TRA'  ) insert into BEST..TI17FNC values ('I17G_OMG_CSU_TRA',  'IFRS17 - Omega extract Generation')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_CSU_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_CSU_TRA',  'OMEGA_EXTRACT_TRN','${DFILP}/${ENV_PREFIX}_ESFT0010_I17G_OMG_CSU_TRA_OMEGA_EXTRACT${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_OMG_CSU_TRA' and  CHAIN_CT='ESFT0010'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFT0010','I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFT0010','I17G_OMG_CSU_TRA','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0030
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0030')  insert into BEST..TI17CHN values ('ESFT0030',  'Data TRANSITION extraction')

		-- I17L_OMG_ROC_TRAI17L_OMG_ROC_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_OMG_ROC_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17L_OMG_ROC_TRA',  'IFRS17 - LOCAL - Update run off contracts')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17L_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17L_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17L_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17L_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17L_OMG_ROC_TRA' and  CHAIN_CT='ESFT0030'
		insert into BEST..TI17REQCHN values ('I17LMINV',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LMINVB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQINV',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQINVB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOS',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOSB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOC',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOCB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYINV',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYINVB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOS',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOSB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOC',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOCB',  'ESFT0030','I17L_OMG_ROC_TRA','')

		-- I17G_OMG_ROC_TRAI17G_OMG_ROC_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_OMG_ROC_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17G_OMG_ROC_TRA',  'Get data IFRS 17 GROUP')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17G_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_OMG_ROC_TRA' and  CHAIN_CT='ESFT0030'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFT0030','I17G_OMG_ROC_TRA','')

		-- I17P_OMG_ROC_TRAI17P_OMG_ROC_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_OMG_ROC_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17P_OMG_ROC_TRA',  'IFRS17 - PARENT - Update run off contracts')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17P_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17P_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17P_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17P_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17P_OMG_ROC_TRA' and  CHAIN_CT='ESFT0030'
		insert into BEST..TI17REQCHN values ('I17PMINV',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PMINVB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQINV',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQINVB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOS',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOSB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOC',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOCB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYINV',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYINVB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOS',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOSB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOC',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOCB',  'ESFT0030','I17P_OMG_ROC_TRA','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3650
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3650')  insert into BEST..TI17CHN values ('ESFD3650',  'Risk Adjustment')

		-- I17G_RAD_CKI_INII17G_RAD_CKI_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_CKI_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_CKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_CKI_INI',  'RA at inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_IADVPERICASE_P','${DFILP}/empty.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_IRDPERICASE_NP','${DFILP}/empty.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_FRARAT','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_RARAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'EPO_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FCTRGRO${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_FMARKET','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_FUWRETSEC','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FUWRETSEC${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'EPO_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'EPO_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE0_PNP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'EPO_FSEGPATTERN_ICR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_ICR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_RAD_CKI_INI' and  CHAIN_CT='ESFD3650'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3650','I17G_RAD_CKI_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3620
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3620')  insert into BEST..TI17CHN values ('ESFD3620',  'Discount at lock in rate')

		-- I17G_DSC_LKI_INII17G_DSC_LKI_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_INI',  'RA Discount Calculation at inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESID0060_FCURSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FPRSMAP_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_DSC_LKI_INI' and  CHAIN_CT='ESFD3620'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_DSC_LKI_INI','')

		-- I17G_RAD_LKI_INII17G_RAD_LKI_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_INI',  'RA Discount risk adjustement at inception')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_RAD_LKI_INI' and  CHAIN_CT='ESFD3620'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_RAD_LKI_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0000
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0000')  insert into BEST..TI17CHN values ('ESFT0000',  'Data TRANSITION extraction')

		-- I17G_TRN_ALL_INII17G_TRN_ALL_INI

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_TRN_ALL_INI'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_TRN_ALL_INI'  ) insert into BEST..TI17FNC values ('I17G_TRN_ALL_INI',  'Get data IFRS 17 GROUP')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FCTRGRO_STD','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'EPO_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FMARKET_STD','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'EPO_IRDPERICASE0_EBS','${DFILP}/${ENV_PREFIX}_ESID0060_IRDPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FRERETFACCTR_INI','${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'EPO_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESEH1100_IRDPERICASE_I17G_NP_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_IADVPERICASE_P','${DFILP}/${ENV_PREFIX}_ESEH1100_IADVPERICASE_I17G_P_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'TRANSITION_DATA','${DFILP}/${ENV_PREFIX}_ESFT0020_I17G_OMG_ALL_TRA_TRANSITION_FILE${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FRARAT_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_RARAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FCTRGRO_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FCTRGRO${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FMARKET_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FUWRETSEC_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FUWRETSEC${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FSEGEST_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGEST_TRN_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FCTRGRO_SEGNF_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FCTRGRO_SEGNF${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_IRDPERICASE0_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FRERETFACCTR_INI_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_IRDPERICASE0_PNP_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE0_PNP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_IRDPERICASE0_P_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADVPERICASE_P_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_TRN_ALL_INI' and  CHAIN_CT='ESFT0000'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFT0000','I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFT0000','I17G_TRN_ALL_INI','')

select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0030
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0030')  insert into BEST..TI17CHN values ('ESFT0030',  'Data TRANSITION extraction')

		-- I17L_OMG_ROC_TRAI17L_OMG_ROC_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_OMG_ROC_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17L_OMG_ROC_TRA',  'IFRS17 - LOCAL - Update run off contracts')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17L_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17L_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17L_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17L_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17L_OMG_ROC_TRA' and  CHAIN_CT='ESFT0030'
		insert into BEST..TI17REQCHN values ('I17LMINV',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LMINVB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQINV',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQINVB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOS',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOSB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOC',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOCB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYINV',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYINVB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOS',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOSB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOC',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOCB',  'ESFT0030','I17L_OMG_ROC_TRA','')

		-- I17G_OMG_ROC_TRAI17G_OMG_ROC_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_OMG_ROC_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17G_OMG_ROC_TRA',  'Get data IFRS 17 GROUP')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17G_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_OMG_ROC_TRA' and  CHAIN_CT='ESFT0030'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFT0030','I17G_OMG_ROC_TRA','')

		-- I17P_OMG_ROC_TRAI17P_OMG_ROC_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_OMG_ROC_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17P_OMG_ROC_TRA',  'IFRS17 - PARENT - Update run off contracts')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17P_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17P_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17P_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17P_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17P_OMG_ROC_TRA' and  CHAIN_CT='ESFT0030'
		insert into BEST..TI17REQCHN values ('I17PMINV',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PMINVB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQINV',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQINVB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOS',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOSB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOC',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOCB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYINV',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYINVB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOS',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOSB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOC',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOCB',  'ESFT0030','I17P_OMG_ROC_TRA','')
select "coucou"
go


----------------------------------------------------------------------------------------------------------
-- [001] 04/03/2021 M.NAJI : SPIRA 91531 Intialisation du mapping  chaine par fichier  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0030
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0030')  insert into BEST..TI17CHN values ('ESFT0030',  'Data TRANSITION extraction')

		-- I17L_OMG_ROC_TRAI17L_OMG_ROC_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_OMG_ROC_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17L_OMG_ROC_TRA',  'IFRS17 - LOCAL - Update run off contracts')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17L_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17L_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17L_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17L_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17L_OMG_ROC_TRA' and  CHAIN_CT='ESFT0030'
		insert into BEST..TI17REQCHN values ('I17LMINV',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LMINVB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQINV',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQINVB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOS',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOSB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOC',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LQPOCB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYINV',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYINVB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOS',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOSB',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOC',  'ESFT0030','I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17LYPOCB',  'ESFT0030','I17L_OMG_ROC_TRA','')

		-- I17G_OMG_ROC_TRAI17G_OMG_ROC_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_OMG_ROC_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17G_OMG_ROC_TRA',  'Get data IFRS 17 GROUP')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17G_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_OMG_ROC_TRA' and  CHAIN_CT='ESFT0030'
		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFT0030','I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFT0030','I17G_OMG_ROC_TRA','')

		-- I17P_OMG_ROC_TRAI17P_OMG_ROC_TRA

	delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_OMG_ROC_TRA'
	if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17P_OMG_ROC_TRA',  'IFRS17 - PARENT - Update run off contracts')

	----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17P_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17P_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17P_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17P_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

	delete BEST..TI17REQCHN where   IDF_CT = 'I17P_OMG_ROC_TRA' and  CHAIN_CT='ESFT0030'
		insert into BEST..TI17REQCHN values ('I17PMINV',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PMINVB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQINV',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQINVB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOS',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOSB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOC',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PQPOCB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYINV',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYINVB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOS',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOSB',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOC',  'ESFT0030','I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQCHN values ('I17PYPOCB',  'ESFT0030','I17P_OMG_ROC_TRA','')

select "coucou"
go


