-------------------------------
--mapping of  ESPD3710

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD3710')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD3710')
	delete BEST..TI17FNC where CHAIN_CT='ESPD3710'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3710'

	insert into BEST..TI17CHN values ('ESPD3710',  '')

	----------IDF_CT:   EBS_ESPD3710 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD3710',' ','ESPD3710',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710',  'EPO_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710',  'EPO_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710',  'EPO_FVENTNPANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FVENTNPANT.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710',  'EPO_FTRSLNK8','${DFILP}/${ENV_PREFIX}_ESPD0060_FTRSLNK8_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710',  'EST_DLDSIIGTAR','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTAR_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710',  'EPO_FTVENTNP','${DFILP}/${ENV_PREFIX}_ESFD5010_FTVENTNP_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710',  'EPO_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESFD5010_IRDVPERICASE_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710',  'EPO_VENTNPSII','${DFILP}/${ENV_PREFIX}_ESPD3710_VENTNP_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710',  'EPO_DLDSIIGTAR','${DFILP}/${ENV_PREFIX}_ESPD3710_DLDSIIGTAR_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD3710','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD3710','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD3710','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD3710','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD3710','Annual INV')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD3710','Annual POC')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD3710','Annual POS')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD3710','Quaterly')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD3710','Annual POC')
			
	----------IDF_CT:   EBS_ESPD3710_INI ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD3710_INI',' ','ESPD3710',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'EPO_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'EPO_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'EPO_FVENTNPANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FVENTNPANT.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'EPO_FTRSLNK8','${DFILP}/${ENV_PREFIX}_ESPD0060_FTRSLNK8_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'EST_DLDSIIGTAR','${DFILP}/${ENV_PREFIX}_ESPD3620_INI_DLDSIIGTAR_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'EPO_FTVENTNP','${DFILP}/${ENV_PREFIX}_ESFD5010_FTVENTNP_EBS_${PARM_TYPEINV2}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'EPO_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESFD5060_IRDPERICASE_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')	
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'EPO_VENTNPSII','${DFILP}/${ENV_PREFIX}_ESPD3710_INI_VENTNP_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'EPO_DLDSIIGTAR','${DFILP}/${ENV_PREFIX}_ESPD3710_INI_DLDSIIGTAR_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'ESF_FRETEBSINI','${DFILP}/${ENV_PREFIX}_ESPD3710_INI_FRETEBSINI${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD3710_INI',  'ESF_FSECEBSINI','${DFILP}/${ENV_PREFIX}_ESFD3710_INI_FSECEBSINI${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')			

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD3710_INI','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD3710_INI','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD3710_INI','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD3710_INI','Quarterly')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD3710_INI','Annual INV')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD3710_INI','Annual POC')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD3710_INI','Annual POS')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD3710_INI','Quaterly')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD3710_INI','Annual POC')

go

