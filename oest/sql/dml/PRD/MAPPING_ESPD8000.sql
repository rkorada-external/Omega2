-------------------------------
--mapping of  ESPD8000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8000')
	delete BEST..TI17FNC where CHAIN_CT='ESPD8000'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8000'

	insert into BEST..TI17CHN values ('ESPD8000',  'Reload FCTREST data')

	----------IDF_CT:   EBS_ESPD8000 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD8000','IFRS4 Post omega  EBS','ESPD8000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD8000',  'EPO_FCTREST1','${DFILP}/${ENV_PREFIX}_ESID2210_FCTREST1_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8000',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8000',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8000',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8000',  'ESF_FRETEBSINI','${DFILP}/${ENV_PREFIX}_ESPD3710_INI_FRETEBSINI${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8000',  'ESF_FSECEBSINI','${DFILP}/${ENV_PREFIX}_ESFD3710_INI_FSECEBSINI${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD8000','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD8000','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD8000','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD8000','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD8000','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD8000','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD8000','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD8000','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD8000','')

	----------IDF_CT:   I4I_ESPD8000 ------------------

		insert into BEST..TI17FNC values ('I4I_ESPD8000','IFRS4 Post omega  IFRS','ESPD8000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESPD8000',  'EPO_FCTREST1','${DFILP}/${PCH}ESID2210_FCTREST1SIISO.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD8000',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIISO.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD8000',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIISO.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD8000',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIISO.dat','I','')

		----------   Reqs    ---------------------

go

