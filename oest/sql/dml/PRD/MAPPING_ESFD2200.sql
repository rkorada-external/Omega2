-------------------------------
--mapping of  ESFD2200 

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD2200')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD2200')
	delete BEST..TI17FNC where CHAIN_CT='ESFD2200'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD2200'

	insert into BEST..TI17CHN values ('ESFD2200',  'Future at inception')

	----------IDF_CT:   EBS_ESFD2200 ------------------

		insert into BEST..TI17FNC values ('EBS_ESFD2200','IFRS4 Post omega  EBS','ESFD2200',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESFD2200',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCPLACC.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD2200',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD2200',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD2200',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD2200',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD2200',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD2200',  'EST_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESFD5040_IADPERICASE_STD_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESFD2200',  'EST_FSTAT','${DFILP}/${ENV_PREFIX}_ESFD2200_I17G_FUT_ALL_INI_FSTAT_INI_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESFD2200','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESFD2200','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESFD2200','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESFD2200','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESFD2200','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESFD2200','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESFD2200','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESFD2200','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESFD2200','')
go

