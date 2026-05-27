-------------------------------
--mapping of  ESPD3640

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD3640')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD3640')
	delete BEST..TI17FNC where CHAIN_CT='ESPD3640'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3640'

	insert into BEST..TI17CHN values ('ESPD3640',  'Risk Marging calculation job ESPD3602A')

	----------IDF_CT:   EBS_ESPD3640 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD3640','IFRS4 Post omega  EBS','ESPD3640',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640',  'EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESCJ0660_OIADVPERICASE.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640',  'EST_FRISKMSII','${DFILP}/${ENV_PREFIX}_ESPD0060_FRISKMSII_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640',  'EST_FCTRGROLESII','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRGROLE_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640',  'EST_GTSII_ESCOMPTE_CLM','${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640',  'EST_DLDSIIGTAA','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640',  'EST_GTSII_RISKMARGIN','${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGIN_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD3640','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD3640','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD3640','	Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD3640','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD3640','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD3640','Annual INV')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD3640','Annual POC')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD3640','Annual POC')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD3640','Annual POS')

	----------IDF_CT:   EBS_ESPD3640_INI ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD3640_INI','IFRS4 Post omega  EBS INI','ESPD3640',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640_INI',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640_INI',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640_INI',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640_INI',  'EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESCJ0660_OIADVPERICASE.dat','I','')  -- OIADPERICASE_EBS_INI
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640_INI',  'EST_FRISKMSII','${DFILP}/${ENV_PREFIX}_ESPD0060_FRISKMSII_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','') --RISK MARGIN EBS INI
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640_INI',  'EST_FCTRGROLESII','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRGROLE_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','') -- FCTR
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640_INI',  'EST_GTSII_ESCOMPTE_CLM','${DFILP}/${ENV_PREFIX}_ESPD3620_INI_GTSII_ESCOMPTE_CLM_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640_INI',  'EST_DLDSIIGTAA','${DFILP}/${ENV_PREFIX}_ESPD3640_INI_ESPD3620_DLDSIIGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3640_INI',  'EST_GTSII_RISKMARGIN','${DFILP}/${ENV_PREFIX}_ESPD3640_INI_ESPD3640_GTSII_RISKMARGIN_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD3640_INI','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD3640_INI','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD3640_INI','	Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD3640_INI','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD3640_INI','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD3640_INI','Annual INV')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD3640_INI','Annual POC')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD3640_INI','Annual POC')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD3640_INI','Annual POS')


go

