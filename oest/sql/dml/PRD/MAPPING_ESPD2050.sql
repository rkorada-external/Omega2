-------------------------------
--mapping of  ESPD2050

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD2050')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD2050')
	delete BEST..TI17FNC where CHAIN_CT='ESPD2050'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD2050'

	insert into BEST..TI17CHN values ('ESPD2050',  '')

	----------IDF_CT:   EBS_ESPD2050 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD2050','IFRS4 Post omega  EBS','ESPD2050',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD2050',  'EST_DLEIGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLEIGTAA_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD2050',  'EST_DLEIFTECLEDSIIEI','${DFILP}/${ENV_PREFIX}_ESPD3620_DLEIFTECLEDSIIEI_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD2050','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD2050','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD2050','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD2050','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD2050','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD2050','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD2050','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD2050','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD2050','')
			
	----------IDF_CT:   EBS_ESPD2050_INI ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD2050_INI','IFRS4 Post omega  EBS','ESPD2050',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD2050_INI',  'EST_DLEIGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLEIGTAA_EBS_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD2050_INI',  'EST_DLEIFTECLEDSIIEI','${DFILP}/${ENV_PREFIX}_ESPD3620_DLEIFTECLEDSIIEI_EBS_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD2050_INI','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD2050_INI','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD2050_INI','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD2050_INI','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD2050_INI','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD2050_INI','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD2050_INI','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD2050_INI','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD2050_INI','')

	----------IDF_CT:   I4I_ESPD2050 ------------------

		insert into BEST..TI17FNC values ('I4I_ESPD2050','IFRS4 Post omega  IFRS','ESPD2050',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESPD2050',  'EST_DLEIGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLEIGTAA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD2050',  'EST_DLEIFTECLEDSIIEI','${DFILP}/${ENV_PREFIX}_ESPD3620_DLEIFTECLEDSIIEI_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'I4I_ESPD2050','')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'I4I_ESPD2050','')
			insert into BEST..TI17REQFNC values ('I4IQPOCB',  'I4I_ESPD2050','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'I4I_ESPD2050','')
			insert into BEST..TI17REQFNC values ('I4IYPOC',  'I4I_ESPD2050','')
			insert into BEST..TI17REQFNC values ('I4IYPOCB',  'I4I_ESPD2050','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'I4I_ESPD2050','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I4I_ESPD2050','')
go

