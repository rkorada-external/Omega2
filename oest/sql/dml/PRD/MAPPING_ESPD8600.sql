-------------------------------
--mapping of  ESPD8600

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8600')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD8600')
	delete BEST..TI17FNC where CHAIN_CT='ESPD8600'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8600'

	insert into BEST..TI17CHN values ('ESPD8600',  '')

	----------IDF_CT:   EBS_ESPD8600 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD8600',' ','ESPD8600',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD8600',  'EST_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLED_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD8600',  'EST_GTSII_RISKMARGIN','${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGIN_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD8600','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD8600','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD8600','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD8600','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD8600','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD8600','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD8600','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD8600','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD8600','')
go

