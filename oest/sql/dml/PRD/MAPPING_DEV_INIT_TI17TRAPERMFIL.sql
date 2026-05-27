----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESID8700
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESID8700')  insert into BEST..TI17CHN values ('ESID8700',  '')

		-- ESID8700_I4_PC___ESID8700_I4_PC___

		delete BEST..TI17TRAPERMFIL where IDF_CT ='ESID8700_I4_PC___'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESID8700_I4_PC___'  ) insert into BEST..TI17FNC values ('ESID8700_I4_PC___',' ','ESID8700',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('ESID8700_I4_PC___',  'EST_FTECLEDA_EBS','${DFILP}/${ENV_PREFIX}_ESID8700_FTECLEDA_I4I_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('ESID8700_I4_PC___',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_INV_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'ESID8700_I4_PC___' 

		-- ESID8700ESID8700

		delete BEST..TI17TRAPERMFIL where IDF_CT ='ESID8700'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='ESID8700'  ) insert into BEST..TI17FNC values ('ESID8700',' ','ESID8700',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'ESID8700' 
		insert into BEST..TI17REQFNC values ('I4IMINV', 'ESID8700','')
		insert into BEST..TI17REQFNC values ('I4IQINV', 'ESID8700','@variante')
		insert into BEST..TI17REQFNC values ('I4IQINVB', 'ESID8700','@variante')
		insert into BEST..TI17REQFNC values ('I4IYINV', 'ESID8700','@variante')
		insert into BEST..TI17REQFNC values ('I4IYINVB', 'ESID8700','@variante')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3610
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3610')  insert into BEST..TI17CHN values ('ESFD3610',  'Cash flow at inception')

		-- I17L_CSF_ALL_INII17L_CSF_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_CSF_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_CSF_ALL_INI'  ) insert into BEST..TI17FNC values ('I17L_CSF_ALL_INI','cashflow at inception','ESFD3610',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_CSF_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_CSF_ALL_INI','')

		-- I17G_ESFD3610___AA3I17G_ESFD3610___AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD3610___AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD3610___AA3'  ) insert into BEST..TI17FNC values ('I17G_ESFD3610___AA3','MicroAOC Cashflow AA3','ESFD3610',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD3610___AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD3610___AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD3610___AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD3610___AA3','POSO')

		-- I17G_ESFD3610___AA2I17G_ESFD3610___AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD3610___AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD3610___AA2'  ) insert into BEST..TI17FNC values ('I17G_ESFD3610___AA2','MicroAOC Cashflow AA2','ESFD3610',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD3610___AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD3610___AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD3610___AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD3610___AA2','POSO')

		-- I17G_ESFD3610___AA1I17G_ESFD3610___AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD3610___AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD3610___AA1'  ) insert into BEST..TI17FNC values ('I17G_ESFD3610___AA1','MicroAOC Cashflow AA1','ESFD3610',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD3610___AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD3610___AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD3610___AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD3610___AA1','POSO')

		-- I17G_ESFD3610___AA0I17G_ESFD3610___AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD3610___AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD3610___AA0'  ) insert into BEST..TI17FNC values ('I17G_ESFD3610___AA0','MicroAOC Cashflow AA0','ESFD3610',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD3610___AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD3610___AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD3610___AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD3610___AA0','POSO')

		-- I17G_CSF_ALL_INII17G_CSF_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_CSF_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_CSF_ALL_INI'  ) insert into BEST..TI17FNC values ('I17G_CSF_ALL_INI','cashflow at inception','ESFD3610',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_IRDPERICASE0_INV_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDSIIGTR','${DFILP}/${ENV_PREFIX}_ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTR${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDSIIGTAA','${DFILP}/${ENV_PREFIX}_ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTAA${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDSIIGTAR','${DFILP}/${ENV_PREFIX}_ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTAR${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FCTRGRO_SEGNF${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESFD3610_I17G_CSF_ALL_INI_FTECLEDSII${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'ESF_IRDPERICASE_NP','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_FSEGPATTERN_CSF','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_CSF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSF_ALL_INI',  'EST_FSEGPATTERN_ICR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_ICR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_CSF_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_CSF_ALL_INI','')

		-- I17P_CSF_ALL_INII17P_CSF_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_CSF_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_CSF_ALL_INI'  ) insert into BEST..TI17FNC values ('I17P_CSF_ALL_INI','cashflow at inception','ESFD3610',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_CSF_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_CSF_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_CSF_ALL_INI','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3750
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3750')  insert into BEST..TI17CHN values ('ESFD3750',  'IFRS17 - CSM at closing assessment')

		-- I17G_CSM_ALL_STDI17G_CSM_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_CSM_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_CSM_ALL_STD'  ) insert into BEST..TI17FNC values ('I17G_CSM_ALL_STD','IFRS17 Group - CSM at closing assessment','ESFD3750',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_CSM','${DFILP}/${ENV_PREFIX}_ESFD3710_I17G_CSM_CSU_INI_GTSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17G_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'EST_FSEGPATTERN_DSC_f17','${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3690_I17G_IRV_ALL_STD_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_TRANSITION_FILE','${DFILP}/${ENV_PREFIX}_ESFT0020_I17G_OMG_ALL_TRA_TRANSITION_FILE${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_IFRS17_CSM','${DFILP}/${ENV_PREFIX}_ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_CSM${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_FSEGPROF_STD_PREVIOUS','${DFILP}/${ENV_PREFIX}_ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${TYPEINV}_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_ESCOMPTE_FWD','${DFILP}/${ENV_PREFIX}_ESFD3690_I17G_IRV_ALL_STD_GTSII_ESCOMPTE_FWD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_CSM_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_CSM_ALL_STD','')

		-- I17L_CSM_ALL_STDI17L_CSM_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_CSM_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_CSM_ALL_STD'  ) insert into BEST..TI17FNC values ('I17L_CSM_ALL_STD','IFRS17 Local - CSM at closing assessment','ESFD3750',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_CSM_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_CSM_ALL_STD','')

		-- I17P_CSM_ALL_STDI17P_CSM_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_CSM_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_CSM_ALL_STD'  ) insert into BEST..TI17FNC values ('I17P_CSM_ALL_STD','IFRS17 Parent - CSM at closing assessment','ESFD3750',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_CSM_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_CSM_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_CSM_ALL_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3720
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3720')  insert into BEST..TI17CHN values ('ESFD3720',  'IFRS17 - UOA definition at inception')

		-- I17P_CSM_CRE_INII17P_CSM_CRE_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_CSM_CRE_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_CSM_CRE_INI'  ) insert into BEST..TI17FNC values ('I17P_CSM_CRE_INI','IFRS17 - Parent - UOA definition at inception','ESFD3720',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_CSM_CRE_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_CSM_CRE_INI','')

		-- I17G_CSM_CRE_INII17G_CSM_CRE_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_CSM_CRE_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_CSM_CRE_INI'  ) insert into BEST..TI17FNC values ('I17G_CSM_CRE_INI','IFRS17 - Group - UOA definition at inception','ESFD3720',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'EPO_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT_TXT.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FUOASII','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G___TUOASII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_GTSII_CSM','${DFILP}/${ENV_PREFIX}_ESFD3710_I17G_CSM_CSU_INI_GTSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_IADPERICASE_INI','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17G_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FRERETFACCTR_INI','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FRETIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FRETIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSECIFRS${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FSEGPROF','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSEGPROF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FSECIFRS_LIGHT','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSECIFRS_LIGHT${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_CSM_CRE_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_CSM_CRE_INI','')

		-- I17L_CSM_CRE_INII17L_CSM_CRE_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_CSM_CRE_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_CSM_CRE_INI'  ) insert into BEST..TI17FNC values ('I17L_CSM_CRE_INI','IFRS17 - Local - UOA definition at inception','ESFD3720',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_CSM_CRE_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_CSM_CRE_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_CSM_CRE_INI','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3620
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3620')  insert into BEST..TI17CHN values ('ESFD3620',  'Discount at lock in rate')

		-- I17G_DSC_LKI_STD_AA3I17G_DSC_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA3','MicroAOC AA3_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA3','POSO')

		-- I17G_DSC_LKI_STD_AA2I17G_DSC_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA2','MicroAOC AA2_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA2','POSO')

		-- I17G_DSC_LKI_STD_AA1I17G_DSC_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA1','MicroAOC AA1_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA1','POSO')

		-- I17G_DSC_LKI_STD_AA0I17G_DSC_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA0','MicroAOC AA0_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA0','POSO')

		-- EBS_ESFD3620EBS_ESFD3620

		delete BEST..TI17TRAPERMFIL where IDF_CT ='EBS_ESFD3620'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD3620'  ) insert into BEST..TI17FNC values ('EBS_ESFD3620','DSC Post omega CONSO EBS','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'EBS_ESFD3620' 
		insert into BEST..TI17REQFNC values ('EBSEMINV', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEQPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEQPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOSB', 'EBS_ESFD3620','BookingPOS')
		insert into BEST..TI17REQFNC values ('EBSEYPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEYPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEYPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEYPOSB', 'EBS_ESFD3620','BookingPOS')

		-- I17G_RAD_LKI_STD_AA0I17G_RAD_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA0','MicroAOC AA0_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA0','POSO')

		-- I17G_RAD_DSI_STDI17G_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_DSI_STD','')

		-- I17P_DSC_DSI_STDI17P_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_DSI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_DSI_STD','')

		-- I17L_RAD_DSI_STDI17L_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_DSI_STD','')

		-- I17L_DSC_LKI_INII17L_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_INI','Local - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_INI','')

		-- I17P_RAD_LKI_STDI17P_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_STD','')

		-- I17L_DSC_LKI_STDI17L_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_STD','')

		-- I17P_RAD_LKI_INII17P_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_INI','')

		-- I17P_DSC_LKI_STDI17P_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_STD','')

		-- I17G_DSC_LKI_INII17G_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_INI','RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESID0060_FCURSII_INV_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FPRSMAP_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_INI','')

		-- I17L_RAD_LKI_STDI17L_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_STD','')

		-- I17L_RAD_LKI_INII17L_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_INI','')

		-- I17G_DSC_LKI_STDI17G_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_STD','')

		-- I17G_RAD_LKI_STD_AA1I17G_RAD_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA1','MicroAOC AA1_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA1','POSO')

		-- I17G_RAD_LKI_STD_AA2I17G_RAD_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA2','MicroAOC AA2_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA2','POSO')

		-- I17G_RAD_LKI_STD_AA3I17G_RAD_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA3','MicroAOC AA3_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA3','POSO')

		-- I17P_RAD_DSI_STDI17P_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_DSI_STD','')

		-- I17G_RAD_LKI_INII17G_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_INI','')

		-- I17L_DSC_DSI_STDI17L_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_DSI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_DSI_STD','')

		-- I17P_DSC_LKI_INII17P_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_INI','Parent - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_INI','')

		-- I17G_RAD_LKI_STDI17G_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_STD','')

		-- I17G_DSC_DSI_STDI17G_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_DSI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_DSI_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3620
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3620')  insert into BEST..TI17CHN values ('ESFD3620',  'Discount at lock in rate')

		-- I17G_DSC_LKI_STD_AA3I17G_DSC_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA3','MicroAOC AA3_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA3','POSO')

		-- I17G_DSC_LKI_STD_AA2I17G_DSC_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA2','MicroAOC AA2_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA2','POSO')

		-- I17G_DSC_LKI_STD_AA1I17G_DSC_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA1','MicroAOC AA1_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA1','POSO')

		-- I17G_DSC_LKI_STD_AA0I17G_DSC_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA0','MicroAOC AA0_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA0','POSO')

		-- EBS_ESFD3620EBS_ESFD3620

		delete BEST..TI17TRAPERMFIL where IDF_CT ='EBS_ESFD3620'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD3620'  ) insert into BEST..TI17FNC values ('EBS_ESFD3620','DSC Post omega CONSO EBS','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'EBS_ESFD3620' 
		insert into BEST..TI17REQFNC values ('EBSEMINV', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEQPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEQPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOSB', 'EBS_ESFD3620','BookingPOS')
		insert into BEST..TI17REQFNC values ('EBSEYPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEYPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEYPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEYPOSB', 'EBS_ESFD3620','BookingPOS')

		-- I17G_RAD_LKI_STD_AA0I17G_RAD_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA0','MicroAOC AA0_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA0','POSO')

		-- I17G_RAD_DSI_STDI17G_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_DSI_STD','')

		-- I17P_DSC_DSI_STDI17P_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_DSI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_DSI_STD','')

		-- I17L_RAD_DSI_STDI17L_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_DSI_STD','')

		-- I17L_DSC_LKI_INII17L_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_INI','Local - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_INI','')

		-- I17P_RAD_LKI_STDI17P_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_STD','')

		-- I17L_DSC_LKI_STDI17L_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_STD','')

		-- I17P_RAD_LKI_INII17P_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_INI','')

		-- I17P_DSC_LKI_STDI17P_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_STD','')

		-- I17G_DSC_LKI_INII17G_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_INI','RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESID0060_FCURSII_INV_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FPRSMAP_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_INI','')

		-- I17L_RAD_LKI_STDI17L_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_STD','')

		-- I17L_RAD_LKI_INII17L_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_INI','')

		-- I17G_DSC_LKI_STDI17G_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_STD','')

		-- I17G_RAD_LKI_STD_AA1I17G_RAD_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA1','MicroAOC AA1_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA1','POSO')

		-- I17G_RAD_LKI_STD_AA2I17G_RAD_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA2','MicroAOC AA2_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA2','POSO')

		-- I17G_RAD_LKI_STD_AA3I17G_RAD_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA3','MicroAOC AA3_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA3','POSO')

		-- I17P_RAD_DSI_STDI17P_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_DSI_STD','')

		-- I17G_RAD_LKI_INII17G_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_INI','')

		-- I17L_DSC_DSI_STDI17L_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_DSI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_DSI_STD','')

		-- I17P_DSC_LKI_INII17P_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_INI','Parent - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_INI','')

		-- I17G_RAD_LKI_STDI17G_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_STD','')

		-- I17G_DSC_DSI_STDI17G_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_DSI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_DSI_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3620
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3620')  insert into BEST..TI17CHN values ('ESFD3620',  'Discount at lock in rate')

		-- I17G_DSC_LKI_STD_AA3I17G_DSC_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA3','MicroAOC AA3_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA3','POSO')

		-- I17G_DSC_LKI_STD_AA2I17G_DSC_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA2','MicroAOC AA2_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA2','POSO')

		-- I17G_DSC_LKI_STD_AA1I17G_DSC_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA1','MicroAOC AA1_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA1','POSO')

		-- I17G_DSC_LKI_STD_AA0I17G_DSC_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA0','MicroAOC AA0_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA0','POSO')

		-- EBS_ESFD3620EBS_ESFD3620

		delete BEST..TI17TRAPERMFIL where IDF_CT ='EBS_ESFD3620'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD3620'  ) insert into BEST..TI17FNC values ('EBS_ESFD3620','DSC Post omega CONSO EBS','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'EBS_ESFD3620' 
		insert into BEST..TI17REQFNC values ('EBSEMINV', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEQPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEQPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOSB', 'EBS_ESFD3620','BookingPOS')
		insert into BEST..TI17REQFNC values ('EBSEYPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEYPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEYPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEYPOSB', 'EBS_ESFD3620','BookingPOS')

		-- I17G_RAD_LKI_STD_AA0I17G_RAD_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA0','MicroAOC AA0_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA0','POSO')

		-- I17G_RAD_DSI_STDI17G_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_DSI_STD','')

		-- I17P_DSC_DSI_STDI17P_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_DSI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_DSI_STD','')

		-- I17L_RAD_DSI_STDI17L_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_DSI_STD','')

		-- I17L_DSC_LKI_INII17L_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_INI','Local - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_INI','')

		-- I17P_RAD_LKI_STDI17P_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_STD','')

		-- I17L_DSC_LKI_STDI17L_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_STD','')

		-- I17P_RAD_LKI_INII17P_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_INI','')

		-- I17P_DSC_LKI_STDI17P_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_STD','')

		-- I17G_DSC_LKI_INII17G_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_INI','RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESID0060_FCURSII_INV_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FPRSMAP_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_INI','')

		-- I17L_RAD_LKI_STDI17L_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_STD','')

		-- I17L_RAD_LKI_INII17L_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_INI','')

		-- I17G_DSC_LKI_STDI17G_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_STD','')

		-- I17G_RAD_LKI_STD_AA1I17G_RAD_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA1','MicroAOC AA1_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA1','POSO')

		-- I17G_RAD_LKI_STD_AA2I17G_RAD_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA2','MicroAOC AA2_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA2','POSO')

		-- I17G_RAD_LKI_STD_AA3I17G_RAD_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA3','MicroAOC AA3_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA3','POSO')

		-- I17P_RAD_DSI_STDI17P_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_DSI_STD','')

		-- I17G_RAD_LKI_INII17G_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_INI','')

		-- I17L_DSC_DSI_STDI17L_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_DSI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_DSI_STD','')

		-- I17P_DSC_LKI_INII17P_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_INI','Parent - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_INI','')

		-- I17G_RAD_LKI_STDI17G_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_STD','')

		-- I17G_DSC_DSI_STDI17G_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_DSI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_DSI_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD2220
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD2220')  insert into BEST..TI17CHN values ('ESFD2220',  'Future at inception')

		-- I17P_FUT_ALL_INII17P_FUT_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_FUT_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_FUT_ALL_INI'  ) insert into BEST..TI17FNC values ('I17P_FUT_ALL_INI','Future at inception','ESFD2220',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_FUT_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_FUT_ALL_INI','')

		-- EBS_ESFD2220EBS_ESFD2220

		delete BEST..TI17TRAPERMFIL where IDF_CT ='EBS_ESFD2220'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD2220'  ) insert into BEST..TI17FNC values ('EBS_ESFD2220','IFRS4 Post omega  EBS','ESFD2220',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'EBS_ESFD2220' 
		insert into BEST..TI17REQFNC values ('EBSEMINV', 'EBS_ESFD2220','')
		insert into BEST..TI17REQFNC values ('EBSEQINV', 'EBS_ESFD2220','')
		insert into BEST..TI17REQFNC values ('EBSEQPOC', 'EBS_ESFD2220','')
		insert into BEST..TI17REQFNC values ('EBSEQPOS', 'EBS_ESFD2220','')
		insert into BEST..TI17REQFNC values ('EBSEYINV', 'EBS_ESFD2220','')
		insert into BEST..TI17REQFNC values ('EBSEYPOC', 'EBS_ESFD2220','')
		insert into BEST..TI17REQFNC values ('EBSEYPOS', 'EBS_ESFD2220','')

		-- I17L_FUT_ALL_INII17L_FUT_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_FUT_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_FUT_ALL_INI'  ) insert into BEST..TI17FNC values ('I17L_FUT_ALL_INI','Future at inception','ESFD2220',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_FUT_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_FUT_ALL_INI','')

		-- I17G_ESFD2220___AA1I17G_ESFD2220___AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2220___AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2220___AA1'  ) insert into BEST..TI17FNC values ('I17G_ESFD2220___AA1','Micro AOC Future Assumed AA1','ESFD2220',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2220___AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2220___AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2220___AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2220___AA1','POSO')

		-- I17G_ESFD2220___AA0I17G_ESFD2220___AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2220___AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2220___AA0'  ) insert into BEST..TI17FNC values ('I17G_ESFD2220___AA0','Micro AOC Future Assumed AA0','ESFD2220',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2220___AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2220___AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2220___AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2220___AA0','POSO')

		-- I17G_ESFD2220___AA3I17G_ESFD2220___AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2220___AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2220___AA3'  ) insert into BEST..TI17FNC values ('I17G_ESFD2220___AA3','Micro AOC Future Assumed AA3','ESFD2220',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2220___AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2220___AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2220___AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2220___AA3','POSO')

		-- I17G_ESFD2220___AA2I17G_ESFD2220___AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2220___AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2220___AA2'  ) insert into BEST..TI17FNC values ('I17G_ESFD2220___AA2','Micro AOC Future Assumed AA2','ESFD2220',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2220___AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2220___AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2220___AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2220___AA2','POSO')

		-- I17G_FUT_ALL_INII17G_FUT_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_FUT_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_FUT_ALL_INI'  ) insert into BEST..TI17FNC values ('I17G_FUT_ALL_INI','Future at inception','ESFD2220',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FCTRGRO${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_ALL_INI',  'EST_FSEGEST_SOLVENCY','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGEST_TRN_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_FUT_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_FUT_ALL_INI','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD2570
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD2570')  insert into BEST..TI17CHN values ('ESFD2570',  'Retro NP at Inception')

		-- I17P_FUT_RNP_INII17P_FUT_RNP_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_FUT_RNP_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_FUT_RNP_INI'  ) insert into BEST..TI17FNC values ('I17P_FUT_RNP_INI','Retro NP at Inception','ESFD2570',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_FUT_RNP_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_FUT_RNP_INI','')

		-- I17G_ESFD2570___AA1I17G_ESFD2570___AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2570___AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2570___AA1'  ) insert into BEST..TI17FNC values ('I17G_ESFD2570___AA1','Micro AOC FutureLR NP','ESFD2570',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2570___AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2570___AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2570___AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2570___AA1','POSO')

		-- I17G_ESFD2570___AA0I17G_ESFD2570___AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2570___AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2570___AA0'  ) insert into BEST..TI17FNC values ('I17G_ESFD2570___AA0','Micro AOC FutureLR NP','ESFD2570',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2570___AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2570___AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2570___AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2570___AA0','POSO')

		-- I17G_ESFD2570___AA3I17G_ESFD2570___AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2570___AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2570___AA3'  ) insert into BEST..TI17FNC values ('I17G_ESFD2570___AA3','Micro AOC FutureLR NP','ESFD2570',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2570___AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2570___AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2570___AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2570___AA3','POSO')

		-- I17G_ESFD2570___AA2I17G_ESFD2570___AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2570___AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2570___AA2'  ) insert into BEST..TI17FNC values ('I17G_ESFD2570___AA2','Micro AOC FutureLR NP','ESFD2570',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2570___AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2570___AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2570___AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2570___AA2','POSO')

		-- I17L_FUT_RNP_INII17L_FUT_RNP_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_FUT_RNP_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_FUT_RNP_INI'  ) insert into BEST..TI17FNC values ('I17L_FUT_RNP_INI','Retro NP at Inception','ESFD2570',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_FUT_RNP_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_FUT_RNP_INI','')

		-- I17G_FUT_RNP_INII17G_FUT_RNP_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_FUT_RNP_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_FUT_RNP_INI'  ) insert into BEST..TI17FNC values ('I17G_FUT_RNP_INI','Retro NP at Inception','ESFD2570',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_RNP_INI',  'EPO_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_FUT_RNP_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_FUT_RNP_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_FUT_RNP_INI','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD2550
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD2550')  insert into BEST..TI17CHN values ('ESFD2550',  'Bouclette Future RetroP Inception')

		-- I17L_LCC_RPO_INII17L_LCC_RPO_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_LCC_RPO_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_LCC_RPO_INI'  ) insert into BEST..TI17FNC values ('I17L_LCC_RPO_INI','RETRO ONE GAIN','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_LCC_RPO_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_LCC_RPO_INI','')

		-- I17P_LCC_RPO_INII17P_LCC_RPO_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_LCC_RPO_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_LCC_RPO_INI'  ) insert into BEST..TI17FNC values ('I17P_LCC_RPO_INI','RETRO ONE GAIN','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_LCC_RPO_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_LCC_RPO_INI','')

		-- I17P_NDC_RPO_INII17P_NDC_RPO_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_NDC_RPO_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_NDC_RPO_INI'  ) insert into BEST..TI17FNC values ('I17P_NDC_RPO_INI','RETRO ONE GAIN','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_NDC_RPO_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_NDC_RPO_INI','')

		-- I17G_LCC_RPO_STDI17G_LCC_RPO_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_LCC_RPO_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_LCC_RPO_STD'  ) insert into BEST..TI17FNC values ('I17G_LCC_RPO_STD','Retro LC and AOC component','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_LCC_RPO_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_LCC_RPO_STD','')

		-- I17L_LCC_RPO_STDI17L_LCC_RPO_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_LCC_RPO_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_LCC_RPO_STD'  ) insert into BEST..TI17FNC values ('I17L_LCC_RPO_STD','Retro LC and AOC component','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_LCC_RPO_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_LCC_RPO_STD','')

		-- I17G_FUT_RPO_INII17G_FUT_RPO_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_FUT_RPO_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_FUT_RPO_INI'  ) insert into BEST..TI17FNC values ('I17G_FUT_RPO_INI','Bouclette Future RetroP Inception','ESFD2550',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_FUT_RPO_INI',  'EPO_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_FUT_RPO_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_FUT_RPO_INI','')

		-- I17G_LCC_RPO_INII17G_LCC_RPO_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_LCC_RPO_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_LCC_RPO_INI'  ) insert into BEST..TI17FNC values ('I17G_LCC_RPO_INI','RETRO ONE GAIN','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_LCC_RPO_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_LCC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_LCC_RPO_INI','')

		-- I17L_FUT_RPO_INII17L_FUT_RPO_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_FUT_RPO_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_FUT_RPO_INI'  ) insert into BEST..TI17FNC values ('I17L_FUT_RPO_INI','Bouclette Future RetroP Inception','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_FUT_RPO_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_FUT_RPO_INI','')

		-- I17P_FUT_RPO_INII17P_FUT_RPO_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_FUT_RPO_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_FUT_RPO_INI'  ) insert into BEST..TI17FNC values ('I17P_FUT_RPO_INI','Bouclette Future RetroP Inception','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_FUT_RPO_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_FUT_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_FUT_RPO_INI','')

		-- I17P_LCC_RPO_STDI17P_LCC_RPO_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_LCC_RPO_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_LCC_RPO_STD'  ) insert into BEST..TI17FNC values ('I17P_LCC_RPO_STD','Retro LC and AOC component','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_LCC_RPO_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_LCC_RPO_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_LCC_RPO_STD','')

		-- I17L_NDC_RPO_INII17L_NDC_RPO_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_NDC_RPO_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_NDC_RPO_INI'  ) insert into BEST..TI17FNC values ('I17L_NDC_RPO_INI','RETRO ONE GAIN','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_NDC_RPO_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_NDC_RPO_INI','')

		-- I17G_ESFD2550___AA3I17G_ESFD2550___AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2550___AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2550___AA3'  ) insert into BEST..TI17FNC values ('I17G_ESFD2550___AA3','Bouclette microAOC AA3','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2550___AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2550___AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2550___AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2550___AA3','POSO')

		-- I17G_ESFD2550___AA2I17G_ESFD2550___AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2550___AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2550___AA2'  ) insert into BEST..TI17FNC values ('I17G_ESFD2550___AA2','Bouclette microAOC AA2','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2550___AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2550___AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2550___AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2550___AA2','POSO')

		-- I17G_ESFD2550___AA1I17G_ESFD2550___AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2550___AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2550___AA1'  ) insert into BEST..TI17FNC values ('I17G_ESFD2550___AA1','Bouclette microAOC AA1','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2550___AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2550___AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2550___AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2550___AA1','POSO')

		-- I17G_ESFD2550___AA0I17G_ESFD2550___AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_ESFD2550___AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_ESFD2550___AA0'  ) insert into BEST..TI17FNC values ('I17G_ESFD2550___AA0','Bouclette microAOC AA0','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_ESFD2550___AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_ESFD2550___AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_ESFD2550___AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_ESFD2550___AA0','POSO')

		-- EBS_ESFD2550EBS_ESFD2550

		delete BEST..TI17TRAPERMFIL where IDF_CT ='EBS_ESFD2550'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD2550'  ) insert into BEST..TI17FNC values ('EBS_ESFD2550','EBS Post omega NDIC','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'EBS_ESFD2550' 
		insert into BEST..TI17REQFNC values ('EBSEMINV', 'EBS_ESFD2550','')
		insert into BEST..TI17REQFNC values ('EBSEQINV', 'EBS_ESFD2550','')
		insert into BEST..TI17REQFNC values ('EBSEQPOC', 'EBS_ESFD2550','')
		insert into BEST..TI17REQFNC values ('EBSEQPOCB', 'EBS_ESFD2550','')
		insert into BEST..TI17REQFNC values ('EBSEQPOS', 'EBS_ESFD2550','')
		insert into BEST..TI17REQFNC values ('EBSEYINV', 'EBS_ESFD2550','')
		insert into BEST..TI17REQFNC values ('EBSEYPOC', 'EBS_ESFD2550','')
		insert into BEST..TI17REQFNC values ('EBSEYPOCB', 'EBS_ESFD2550','')
		insert into BEST..TI17REQFNC values ('EBSEYPOS', 'EBS_ESFD2550','')

		-- I17G_NDC_RPO_INII17G_NDC_RPO_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_NDC_RPO_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_NDC_RPO_INI'  ) insert into BEST..TI17FNC values ('I17G_NDC_RPO_INI','RETRO ONE GAIN','ESFD2550',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_NDC_RPO_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_NDC_RPO_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_NDC_RPO_INI','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3630
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3630')  insert into BEST..TI17CHN values ('ESFD3630',  'Maintenance/Acquisition expenses CSF')

		-- I17P_IEX_ALL_INII17P_IEX_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_IEX_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_IEX_ALL_INI'  ) insert into BEST..TI17FNC values ('I17P_IEX_ALL_INI','Maintenance/Acquisition expenses CSF INI','ESFD3630',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_IEX_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_IEX_ALL_INI','')

		-- I17G_IEX_ALL_INII17G_IEX_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IEX_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IEX_ALL_INI'  ) insert into BEST..TI17FNC values ('I17G_IEX_ALL_INI','Maintenance/Acquisition expenses CSF INI','ESFD3630',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'ESF_FMARKET','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EPO_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FCTRGRO_SEGNF${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EPO_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EPO_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EPO_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EPO_IRDPERICASE0_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'EST_FSEGPATTERN_CSF','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_CSF_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_IEX_ALL_INI',  'ESF_GTESTCUMUL_ACCRET','${DFILP}/${ENV_PREFIX}_ESFD3671_I17G_IEX_ALL_INI_GTESTCUMUL_ACCRET_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_IEX_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_IEX_ALL_INI','')

		-- I17G_IEX_ALL_STD_AA3I17G_IEX_ALL_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IEX_ALL_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IEX_ALL_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_IEX_ALL_STD_AA3','MicroAOC I17G_IEX_ALL_STD_AA3','ESFD3630',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_IEX_ALL_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_IEX_ALL_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_IEX_ALL_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_IEX_ALL_STD_AA3','POSO')

		-- I17G_IEX_ALL_STD_AA0I17G_IEX_ALL_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IEX_ALL_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IEX_ALL_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_IEX_ALL_STD_AA0','MicroAOC I17G_IEX_ALL_STD_AA0','ESFD3630',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_IEX_ALL_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_IEX_ALL_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_IEX_ALL_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_IEX_ALL_STD_AA0','POSO')

		-- I17G_IEX_ALL_STD_AA1I17G_IEX_ALL_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IEX_ALL_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IEX_ALL_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_IEX_ALL_STD_AA1','MicroAOC I17G_IEX_ALL_STD_AA1','ESFD3630',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_IEX_ALL_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_IEX_ALL_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_IEX_ALL_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_IEX_ALL_STD_AA1','POSO')

		-- I17G_IEX_ALL_STD_AA2I17G_IEX_ALL_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IEX_ALL_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IEX_ALL_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_IEX_ALL_STD_AA2','MicroAOC I17G_IEX_ALL_STD_AA2','ESFD3630',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_IEX_ALL_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_IEX_ALL_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_IEX_ALL_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_IEX_ALL_STD_AA2','POSO')

		-- I17L_IEX_ALL_STDI17L_IEX_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_IEX_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_IEX_ALL_STD'  ) insert into BEST..TI17FNC values ('I17L_IEX_ALL_STD','Maintenance/Acquisition expenses CSF STD','ESFD3630',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_IEX_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_IEX_ALL_STD','')

		-- I17P_IEX_ALL_STDI17P_IEX_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_IEX_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_IEX_ALL_STD'  ) insert into BEST..TI17FNC values ('I17P_IEX_ALL_STD','Maintenance/Acquisition expenses CSF STD','ESFD3630',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_IEX_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_IEX_ALL_STD','')

		-- I17L_IEX_ALL_INII17L_IEX_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_IEX_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_IEX_ALL_INI'  ) insert into BEST..TI17FNC values ('I17L_IEX_ALL_INI','Maintenance/Acquisition expenses CSF INI','ESFD3630',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_IEX_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_IEX_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_IEX_ALL_INI','')

		-- I17G_IEX_ALL_STDI17G_IEX_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IEX_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IEX_ALL_STD'  ) insert into BEST..TI17FNC values ('I17G_IEX_ALL_STD','Maintenance/Acquisition expenses CSF STD','ESFD3630',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_IEX_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_IEX_ALL_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3690
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3690')  insert into BEST..TI17CHN values ('ESFD3690',  'Revenue Calculation')

		-- I17L_IRV_ALL_STDI17L_IRV_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_IRV_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_IRV_ALL_STD'  ) insert into BEST..TI17FNC values ('I17L_IRV_ALL_STD','revenue calculation','ESFD3690',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_IRV_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_IRV_ALL_STD','')

		-- I17G_IRV_ALL_STDI17G_IRV_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IRV_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IRV_ALL_STD'  ) insert into BEST..TI17FNC values ('I17G_IRV_ALL_STD','revenue calculation','ESFD3690',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_IRV_ALL_STD',  'PARM_IS_TRN','YES','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_IRV_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_IRV_ALL_STD','')

		-- I17P_IRV_ALL_STDI17P_IRV_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_IRV_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_IRV_ALL_STD'  ) insert into BEST..TI17FNC values ('I17P_IRV_ALL_STD','revenue calculation','ESFD3690',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_IRV_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_IRV_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_IRV_ALL_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3640
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3640')  insert into BEST..TI17CHN values ('ESFD3640',  'ACF/PCA : Ratio calculation')

		-- I17L_IVR_CHR_STDI17L_IVR_CHR_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_IVR_CHR_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_IVR_CHR_STD'  ) insert into BEST..TI17FNC values ('I17L_IVR_CHR_STD','ACF/PCA: Ratio Calculation','ESFD3640',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_IVR_CHR_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_IVR_CHR_STD','')

		-- I17G_IVR_CHR_STDI17G_IVR_CHR_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_IVR_CHR_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_IVR_CHR_STD'  ) insert into BEST..TI17FNC values ('I17G_IVR_CHR_STD','ACF/PCA : Ratio calculation','ESFD3640',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_IVR_CHR_STD',  'PARM_IS_TRN','YES','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_IVR_CHR_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_IVR_CHR_STD','')

		-- I17P_IVR_CHR_STDI17P_IVR_CHR_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_IVR_CHR_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_IVR_CHR_STD'  ) insert into BEST..TI17FNC values ('I17P_IVR_CHR_STD','ACF/PCA : Ratio calculation','ESFD3640',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_IVR_CHR_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_IVR_CHR_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_IVR_CHR_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3970
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3970')  insert into BEST..TI17CHN values ('ESFD3970',  'IFRS17 - NDIC cashflow calculation')

		-- I17L_NDC_CSF_INII17L_NDC_CSF_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_NDC_CSF_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_NDC_CSF_INI'  ) insert into BEST..TI17FNC values ('I17L_NDC_CSF_INI','IFRS17 Local - NDIC cashflow calculation','ESFD3970',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_NDC_CSF_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_NDC_CSF_INI','')

		-- EBS_ESFD3970EBS_ESFD3970

		delete BEST..TI17TRAPERMFIL where IDF_CT ='EBS_ESFD3970'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD3970'  ) insert into BEST..TI17FNC values ('EBS_ESFD3970','EBS - NDIC STD cashflow calculation','ESFD3970',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'EBS_ESFD3970' 
		insert into BEST..TI17REQFNC values ('EBSEMINV', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEQINV', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEQPOC', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEQPOCB', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEQPOS', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEQPOSB', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEYINV', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEYPOC', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEYPOCB', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEYPOS', 'EBS_ESFD3970','')
		insert into BEST..TI17REQFNC values ('EBSEYPOSB', 'EBS_ESFD3970','')

		-- I17P_NDC_CSF_INII17P_NDC_CSF_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_NDC_CSF_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_NDC_CSF_INI'  ) insert into BEST..TI17FNC values ('I17P_NDC_CSF_INI','IFRS17 Parent - NDIC cashflow calculation','ESFD3970',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_NDC_CSF_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_NDC_CSF_INI','')

		-- I17G_NDC_CSF_INII17G_NDC_CSF_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_NDC_CSF_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_NDC_CSF_INI'  ) insert into BEST..TI17FNC values ('I17G_NDC_CSF_INI','IFRS17 Group - NDIC cashflow calculation','ESFD3970',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_NDC_CSF_INI',  'EPO_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FCTRGRO_SEGNF${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_NDC_CSF_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_NDC_CSF_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_NDC_CSF_INI','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0020
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0020')  insert into BEST..TI17CHN values ('ESFT0020',  'IFRS17 - Transition File Generation')

		-- I17G_OMG_ALL_TRAI17G_OMG_ALL_TRA

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_OMG_ALL_TRA'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_OMG_ALL_TRA'  ) insert into BEST..TI17FNC values ('I17G_OMG_ALL_TRA','IFRS17 - Transition File Generation','ESFT0020',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA',  'BUSINESS_LOGS','${DFILP}/${ENV_PREFIX}_BUISNESS_TRANSITION_LOG.log','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA',  'TRANSITION_INPUT_FILE','${DFILP}/${ENV_PREFIX}_BUISNESS_TRANSITION_I17G${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA',  'TRANSITION_OUTPUT_FILE','${DFILP}/${ENV_PREFIX}_ESFT0020_I17G_OMG_ALL_TRA_TRANSITION_FILE${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_OMG_ALL_TRA' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_OMG_ALL_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_OMG_ALL_TRA','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0010
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0010')  insert into BEST..TI17CHN values ('ESFT0010',  'IFRS17 - Omega extract Generation')

		-- I17G_OMG_CSU_TRAI17G_OMG_CSU_TRA

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_OMG_CSU_TRA'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_OMG_CSU_TRA'  ) insert into BEST..TI17FNC values ('I17G_OMG_CSU_TRA','IFRS17 - Omega extract Generation','ESFT0010',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_CSU_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_CSU_TRA',  'OMEGA_EXTRACT_TRN','${DFILP}/${ENV_PREFIX}_ESFT0010_I17G_OMG_CSU_TRA_OMEGA_EXTRACT${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_OMG_CSU_TRA' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_OMG_CSU_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_OMG_CSU_TRA','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0030
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0030')  insert into BEST..TI17CHN values ('ESFT0030',  'Data TRANSITION extraction')

		-- I17L_OMG_ROC_TRAI17L_OMG_ROC_TRA

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_OMG_ROC_TRA'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17L_OMG_ROC_TRA','IFRS17 - LOCAL - Update run off contracts','ESFT0030',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_OMG_ROC_TRA' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_OMG_ROC_TRA','')

		-- I17G_OMG_ROC_TRAI17G_OMG_ROC_TRA

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_OMG_ROC_TRA'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17G_OMG_ROC_TRA','Get data IFRS 17 GROUP','ESFT0030',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'EST_IADPERICASE_STD','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17G_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'ESF_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'ESF_IRDPERICASE0_PNP_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE0_PNP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ROC_TRA',  'ESF_IRDPERICASE0_P_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADVPERICASE_P_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_OMG_ROC_TRA' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_OMG_ROC_TRA','')

		-- I17P_OMG_ROC_TRAI17P_OMG_ROC_TRA

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_OMG_ROC_TRA'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_OMG_ROC_TRA'  ) insert into BEST..TI17FNC values ('I17P_OMG_ROC_TRA','IFRS17 - PARENT - Update run off contracts','ESFT0030',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_OMG_ROC_TRA' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_OMG_ROC_TRA','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_OMG_ROC_TRA','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3650
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3650')  insert into BEST..TI17CHN values ('ESFD3650',  'Risk Adjustment')

		-- I17P_RAD_CUR_STDI17P_RAD_CUR_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_CUR_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_CUR_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_CUR_STD','Risk Adjustment current rate','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_CUR_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_CUR_STD','')

		-- I17P_RAD_CKI_INII17P_RAD_CKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_CKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_CKI_INI'  ) insert into BEST..TI17FNC values ('I17P_RAD_CKI_INI','RA at inception','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_CKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_CKI_INI','')

		-- I17G_RAD_CUR_STDI17G_RAD_CUR_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_CUR_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_CUR_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_CUR_STD','Risk Adjustment current rate','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_CUR_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_CUR_STD','')

		-- I17L_RAD_CKI_INII17L_RAD_CKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_CKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_CKI_INI'  ) insert into BEST..TI17FNC values ('I17L_RAD_CKI_INI','RA at inception','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_CKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_CKI_INI','')

		-- I17G_RAD_CKI_INII17G_RAD_CKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_CKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_CKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_CKI_INI','RA at inception','ESFD3650',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_IADVPERICASE_P','${DFILP}/empty.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_FRARAT','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_RARAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'EPO_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FCTRGRO${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_FMARKET','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_FUWRETSEC','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FUWRETSEC${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'EPO_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'EST_IRDPERICASE','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE0_PNP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'EPO_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE0_PNP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'ESF_IRDPERICASE_NP','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_CKI_INI',  'EPO_FSEGPATTERN_ICR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_ICR_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_CKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_CKI_INI','')

		-- I17P_RAD_CKI_STDI17P_RAD_CKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_CKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_CKI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_CKI_STD','Risk Adjustment lock in rate','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_CKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_CKI_STD','')

		-- I17G_RAD_CKI_STDI17G_RAD_CKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_CKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_CKI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_CKI_STD','Risk Adjustment lock in rate','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_CKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_CKI_STD','')

		-- I17L_RAD_CUR_STDI17L_RAD_CUR_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_CUR_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_CUR_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_CUR_STD','Risk Adjustment current rate','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_CUR_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_CUR_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_CUR_STD','')

		-- I17L_RAD_CKI_STDI17L_RAD_CKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_CKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_CKI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_CKI_STD','Risk Adjustment lock in rate','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_CKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_CKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_CKI_STD','')

		-- I17G_RAD_CKI_STD_AA3I17G_RAD_CKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_CKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_CKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_RAD_CKI_STD_AA3','MicroAOC AA3_RAD_CKI_STD','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_CKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_CKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_CKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_CKI_STD_AA3','POSO')

		-- I17G_RAD_CKI_STD_AA2I17G_RAD_CKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_CKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_CKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_RAD_CKI_STD_AA2','MicroAOC AA2_RAD_CKI_STD','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_CKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_CKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_CKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_CKI_STD_AA2','POSO')

		-- I17G_RAD_CKI_STD_AA1I17G_RAD_CKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_CKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_CKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_RAD_CKI_STD_AA1','MicroAOC AA1_RAD_CKI_STD','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_CKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_CKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_CKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_CKI_STD_AA1','POSO')

		-- I17G_RAD_CKI_STD_AA0I17G_RAD_CKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_CKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_CKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_RAD_CKI_STD_AA0','MicroAOC AA0_RAD_CKI_STD','ESFD3650',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_CKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_CKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_CKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_CKI_STD_AA0','POSO')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3620
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3620')  insert into BEST..TI17CHN values ('ESFD3620',  'Discount at lock in rate')

		-- I17G_DSC_LKI_STD_AA3I17G_DSC_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA3','MicroAOC AA3_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA3','POSO')

		-- I17G_DSC_LKI_STD_AA2I17G_DSC_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA2','MicroAOC AA2_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA2','POSO')

		-- I17G_DSC_LKI_STD_AA1I17G_DSC_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA1','MicroAOC AA1_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA1','POSO')

		-- I17G_DSC_LKI_STD_AA0I17G_DSC_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA0','MicroAOC AA0_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA0','POSO')

		-- EBS_ESFD3620EBS_ESFD3620

		delete BEST..TI17TRAPERMFIL where IDF_CT ='EBS_ESFD3620'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD3620'  ) insert into BEST..TI17FNC values ('EBS_ESFD3620','DSC Post omega CONSO EBS','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'EBS_ESFD3620' 
		insert into BEST..TI17REQFNC values ('EBSEMINV', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEQPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEQPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOSB', 'EBS_ESFD3620','BookingPOS')
		insert into BEST..TI17REQFNC values ('EBSEYPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEYPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEYPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEYPOSB', 'EBS_ESFD3620','BookingPOS')

		-- I17G_RAD_LKI_STD_AA0I17G_RAD_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA0','MicroAOC AA0_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA0','POSO')

		-- I17G_RAD_DSI_STDI17G_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_DSI_STD','')

		-- I17P_DSC_DSI_STDI17P_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_DSI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_DSI_STD','')

		-- I17L_RAD_DSI_STDI17L_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_DSI_STD','')

		-- I17L_DSC_LKI_INII17L_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_INI','Local - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_INI','')

		-- I17P_RAD_LKI_STDI17P_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_STD','')

		-- I17L_DSC_LKI_STDI17L_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_STD','')

		-- I17P_RAD_LKI_INII17P_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_INI','')

		-- I17P_DSC_LKI_STDI17P_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_STD','')

		-- I17G_DSC_LKI_INII17G_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_INI','RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESID0060_FCURSII_INV_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FPRSMAP_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_INI','')

		-- I17L_RAD_LKI_STDI17L_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_STD','')

		-- I17L_RAD_LKI_INII17L_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_INI','')

		-- I17G_DSC_LKI_STDI17G_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_STD','')

		-- I17G_RAD_LKI_STD_AA1I17G_RAD_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA1','MicroAOC AA1_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA1','POSO')

		-- I17G_RAD_LKI_STD_AA2I17G_RAD_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA2','MicroAOC AA2_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA2','POSO')

		-- I17G_RAD_LKI_STD_AA3I17G_RAD_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA3','MicroAOC AA3_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA3','POSO')

		-- I17P_RAD_DSI_STDI17P_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_DSI_STD','')

		-- I17G_RAD_LKI_INII17G_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_INI','')

		-- I17L_DSC_DSI_STDI17L_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_DSI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_DSI_STD','')

		-- I17P_DSC_LKI_INII17P_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_INI','Parent - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_INI','')

		-- I17G_RAD_LKI_STDI17G_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_STD','')

		-- I17G_DSC_DSI_STDI17G_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_DSI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_DSI_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3620
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3620')  insert into BEST..TI17CHN values ('ESFD3620',  'Discount at lock in rate')

		-- I17G_DSC_LKI_STD_AA3I17G_DSC_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA3','MicroAOC AA3_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA3','POSO')

		-- I17G_DSC_LKI_STD_AA2I17G_DSC_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA2','MicroAOC AA2_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA2','POSO')

		-- I17G_DSC_LKI_STD_AA1I17G_DSC_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA1','MicroAOC AA1_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA1','POSO')

		-- I17G_DSC_LKI_STD_AA0I17G_DSC_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA0','MicroAOC AA0_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA0','POSO')

		-- EBS_ESFD3620EBS_ESFD3620

		delete BEST..TI17TRAPERMFIL where IDF_CT ='EBS_ESFD3620'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD3620'  ) insert into BEST..TI17FNC values ('EBS_ESFD3620','DSC Post omega CONSO EBS','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'EBS_ESFD3620' 
		insert into BEST..TI17REQFNC values ('EBSEMINV', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEQPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEQPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOSB', 'EBS_ESFD3620','BookingPOS')
		insert into BEST..TI17REQFNC values ('EBSEYPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEYPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEYPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEYPOSB', 'EBS_ESFD3620','BookingPOS')

		-- I17G_RAD_LKI_STD_AA0I17G_RAD_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA0','MicroAOC AA0_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA0','POSO')

		-- I17G_RAD_DSI_STDI17G_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_DSI_STD','')

		-- I17P_DSC_DSI_STDI17P_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_DSI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_DSI_STD','')

		-- I17L_RAD_DSI_STDI17L_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_DSI_STD','')

		-- I17L_DSC_LKI_INII17L_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_INI','Local - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_INI','')

		-- I17P_RAD_LKI_STDI17P_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_STD','')

		-- I17L_DSC_LKI_STDI17L_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_STD','')

		-- I17P_RAD_LKI_INII17P_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_INI','')

		-- I17P_DSC_LKI_STDI17P_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_STD','')

		-- I17G_DSC_LKI_INII17G_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_INI','RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESID0060_FCURSII_INV_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FPRSMAP_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_INI','')

		-- I17L_RAD_LKI_STDI17L_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_STD','')

		-- I17L_RAD_LKI_INII17L_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_INI','')

		-- I17G_DSC_LKI_STDI17G_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_STD','')

		-- I17G_RAD_LKI_STD_AA1I17G_RAD_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA1','MicroAOC AA1_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA1','POSO')

		-- I17G_RAD_LKI_STD_AA2I17G_RAD_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA2','MicroAOC AA2_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA2','POSO')

		-- I17G_RAD_LKI_STD_AA3I17G_RAD_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA3','MicroAOC AA3_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA3','POSO')

		-- I17P_RAD_DSI_STDI17P_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_DSI_STD','')

		-- I17G_RAD_LKI_INII17G_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_INI','')

		-- I17L_DSC_DSI_STDI17L_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_DSI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_DSI_STD','')

		-- I17P_DSC_LKI_INII17P_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_INI','Parent - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_INI','')

		-- I17G_RAD_LKI_STDI17G_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_STD','')

		-- I17G_DSC_DSI_STDI17G_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_DSI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_DSI_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3620
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3620')  insert into BEST..TI17CHN values ('ESFD3620',  'Discount at lock in rate')

		-- I17G_DSC_LKI_STD_AA3I17G_DSC_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA3','MicroAOC AA3_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA3','POSO')

		-- I17G_DSC_LKI_STD_AA2I17G_DSC_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA2','MicroAOC AA2_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA2','POSO')

		-- I17G_DSC_LKI_STD_AA1I17G_DSC_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA1','MicroAOC AA1_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA1','POSO')

		-- I17G_DSC_LKI_STD_AA0I17G_DSC_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD_AA0','MicroAOC AA0_DSC_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_DSC_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_DSC_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_DSC_LKI_STD_AA0','POSO')

		-- EBS_ESFD3620EBS_ESFD3620

		delete BEST..TI17TRAPERMFIL where IDF_CT ='EBS_ESFD3620'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='EBS_ESFD3620'  ) insert into BEST..TI17FNC values ('EBS_ESFD3620','DSC Post omega CONSO EBS','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'EBS_ESFD3620' 
		insert into BEST..TI17REQFNC values ('EBSEMINV', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEQPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEQPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEQPOSB', 'EBS_ESFD3620','BookingPOS')
		insert into BEST..TI17REQFNC values ('EBSEYPOC', 'EBS_ESFD3620','POCE')
		insert into BEST..TI17REQFNC values ('EBSEYPOCB', 'EBS_ESFD3620','BookingPOC')
		insert into BEST..TI17REQFNC values ('EBSEYPOS', 'EBS_ESFD3620','POSE')
		insert into BEST..TI17REQFNC values ('EBSEYPOSB', 'EBS_ESFD3620','BookingPOS')

		-- I17G_RAD_LKI_STD_AA0I17G_RAD_LKI_STD_AA0

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA0'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA0'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA0','MicroAOC AA0_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA0' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA0','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA0','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA0','POSO')

		-- I17G_RAD_DSI_STDI17G_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_DSI_STD','')

		-- I17P_DSC_DSI_STDI17P_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_DSI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_DSI_STD','')

		-- I17L_RAD_DSI_STDI17L_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_DSI_STD','')

		-- I17L_DSC_LKI_INII17L_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_INI','Local - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_INI','')

		-- I17P_RAD_LKI_STDI17P_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_STD','')

		-- I17L_DSC_LKI_STDI17L_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_LKI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_LKI_STD','')

		-- I17P_RAD_LKI_INII17P_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_LKI_INI','')

		-- I17P_DSC_LKI_STDI17P_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_STD','Parent - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_STD','')

		-- I17G_DSC_LKI_INII17G_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_INI','RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESID0060_FCURSII_INV_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FPRSMAP_TXT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${ENV_PREFIX}_ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_INI','')

		-- I17L_RAD_LKI_STDI17L_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_STD','')

		-- I17L_RAD_LKI_INII17L_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17L_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_RAD_LKI_INI','')

		-- I17G_DSC_LKI_STDI17G_DSC_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_LKI_STD','')

		-- I17G_RAD_LKI_STD_AA1I17G_RAD_LKI_STD_AA1

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA1'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA1'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA1','MicroAOC AA1_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA1' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA1','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA1','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA1','POSO')

		-- I17G_RAD_LKI_STD_AA2I17G_RAD_LKI_STD_AA2

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA2'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA2'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA2','MicroAOC AA2_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA2' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA2','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA2','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA2','POSO')

		-- I17G_RAD_LKI_STD_AA3I17G_RAD_LKI_STD_AA3

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD_AA3'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD_AA3'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD_AA3','MicroAOC AA3_RAD_LKI_STD','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD_AA3' 
		insert into BEST..TI17REQFNC values ('INVO', 'I17G_RAD_LKI_STD_AA3','INVO')
		insert into BEST..TI17REQFNC values ('POCO', 'I17G_RAD_LKI_STD_AA3','POCO')
		insert into BEST..TI17REQFNC values ('POSO', 'I17G_RAD_LKI_STD_AA3','POSO')

		-- I17P_RAD_DSI_STDI17P_RAD_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_RAD_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_RAD_DSI_STD'  ) insert into BEST..TI17FNC values ('I17P_RAD_DSI_STD','RA Discount risk adjustement current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_RAD_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_RAD_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_RAD_DSI_STD','')

		-- I17G_RAD_LKI_INII17G_RAD_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_INI'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_INI','RA Discount risk adjustement at inception','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_INI','')

		-- I17L_DSC_DSI_STDI17L_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17L_DSC_DSI_STD','Local - RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_DSC_DSI_STD','')

		-- I17P_DSC_LKI_INII17P_DSC_LKI_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_DSC_LKI_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_DSC_LKI_INI'  ) insert into BEST..TI17FNC values ('I17P_DSC_LKI_INI','Parent - RA Discount Calculation at inception','ESFD3620',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_DSC_LKI_INI' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_DSC_LKI_INI','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_DSC_LKI_INI','')

		-- I17G_RAD_LKI_STDI17G_RAD_LKI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_RAD_LKI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_RAD_LKI_STD'  ) insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD','RA Discount risk adjustement lock in rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_RAD_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_RAD_LKI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_RAD_LKI_STD','')

		-- I17G_DSC_DSI_STDI17G_DSC_DSI_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_DSC_DSI_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_DSC_DSI_STD'  ) insert into BEST..TI17FNC values ('I17G_DSC_DSI_STD','RA Discount Forward Calculation  current rate','ESFD3620',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_DSC_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_DSC_DSI_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_DSC_DSI_STD','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFT0000
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFT0000')  insert into BEST..TI17CHN values ('ESFT0000',  'Data TRANSITION extraction')

		-- I17G_TRN_ALL_INII17G_TRN_ALL_INI

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_TRN_ALL_INI'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_TRN_ALL_INI'  ) insert into BEST..TI17FNC values ('I17G_TRN_ALL_INI','Get data IFRS 17 GROUP','ESFT0000',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'PARM_IS_TRN','YES','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FCTRGRO_STD','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_INV_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FMARKET_STD','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'EPO_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFD5020_IADPERICASE_I17G_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_FRERETFACCTR_INI','${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'EPO_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESFD5020_IRDPERICASE_NP_I17G_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'EPO_IRDPERICASE0_EBS','${DFILP}/${ENV_PREFIX}_ESFD5020_IRDPERICASE_I17G_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17TRAPERMFIL values ('I17G_TRN_ALL_INI',  'ESF_IADVPERICASE_P','${DFILP}/${ENV_PREFIX}_ESFD5020_IADVPERICASE_P_I17G_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
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

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_TRN_ALL_INI' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_TRN_ALL_INI','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_TRN_ALL_INI','')

go

----------------------------------------------------------------------------------------------------------
-- [001] 02/06/2021 M.NAJI : SPIRA 87877 extraction du mapping 3K  
----------------------------------------------------------------------------------------------------------


-------------------------------
--	Init ESFD3660
-------------------------------


	if not exists ( select 1 from BEST..TI17CHN where CHAIN_CT='ESFD3660')  insert into BEST..TI17CHN values ('ESFD3660',  'Discount forward')

		-- I17P_UWD_ALL_STDI17P_UWD_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17P_UWD_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17P_UWD_ALL_STD'  ) insert into BEST..TI17FNC values ('I17P_UWD_ALL_STD','Parent - Discount forward','ESFD3660',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17P_UWD_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17PMINV', 'I17P_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINV', 'I17P_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQINVB', 'I17P_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOS', 'I17P_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PQPOSB', 'I17P_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINV', 'I17P_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYINVB', 'I17P_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOS', 'I17P_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17PYPOSB', 'I17P_UWD_ALL_STD','')

		-- I17L_UWD_ALL_STDI17L_UWD_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17L_UWD_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17L_UWD_ALL_STD'  ) insert into BEST..TI17FNC values ('I17L_UWD_ALL_STD','Local - Discount forward','ESFD3660',0)

		----------  Perms---------------------


		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17L_UWD_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17LMINV', 'I17L_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINV', 'I17L_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQINVB', 'I17L_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOS', 'I17L_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LQPOSB', 'I17L_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINV', 'I17L_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYINVB', 'I17L_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOS', 'I17L_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17LYPOSB', 'I17L_UWD_ALL_STD','')

		-- I17G_UWD_ALL_STDI17G_UWD_ALL_STD

		delete BEST..TI17TRAPERMFIL where IDF_CT ='I17G_UWD_ALL_STD'
		if not exists ( select 1 from BEST..TI17FNC where idf_ct ='I17G_UWD_ALL_STD'  ) insert into BEST..TI17FNC values ('I17G_UWD_ALL_STD','Group - Discount forward','ESFD3660',0)

		----------  Perms---------------------

		insert into BEST..TI17TRAPERMFIL values ('I17G_UWD_ALL_STD',  'ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs of chain   ---------------------

		delete BEST..TI17REQFNC where   IDF_CT = 'I17G_UWD_ALL_STD' 
		insert into BEST..TI17REQFNC values ('I17GMINV', 'I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINV', 'I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOS', 'I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINV', 'I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOS', 'I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_UWD_ALL_STD','')

go

