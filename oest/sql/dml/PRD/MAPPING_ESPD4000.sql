-------------------------------
--mapping of  ESPD4000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD4000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPD4000')
	delete BEST..TI17FNC where CHAIN_CT='ESPD4000'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD4000'

	insert into BEST..TI17CHN values ('ESPD4000',  '')

	----------IDF_CT:   EBS_ESPD4000 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPD4000',' ','ESPD4000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('EBS_ESPD4000',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEP_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('EBS_ESPD4000',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESPD4000_DLEIFTECLEDSIIEP_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD4000','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD4000','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD4000','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD4000','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD4000','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD4000','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD4000','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD4000','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD4000','')



----------IDF_CT:   EBS_ESPD4000_BBNI ------------------

   insert into BEST..TI17FNC values ('EBS_ESPD4000_BBNI',' ','ESPD4000',0)


---------  Perms---------------------

       insert into BEST..TI17PERMFIL values ('EBS_ESPD4000_BBNI',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESPD4000_BBNI_GTEP_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
       insert into BEST..TI17PERMFIL values ('EBS_ESPD4000_BBNI',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESPD4000_BBNI_DLEIFTECLEDSIIEP_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

---------   Reqs    ---------------------

       insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD4000_BBNI','')
       insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD4000_BBNI','')
       insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD4000_BBNI','')
       insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD4000_BBNI','')
       insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD4000_BBNI','')
       insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD4000_BBNI','')
       insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD4000_BBNI','')
       insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD4000_BBNI','')
       insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD4000_BBNI','')

----------IDF_CT:   EBS_ESPD4000_INI ------------------

   insert into BEST..TI17FNC values ('EBS_ESPD4000_INI',' ','ESPD4000',0)

	
---------  Perms---------------------

       insert into BEST..TI17PERMFIL values ('EBS_ESPD4000_INI',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESPD4000_INI_GTEP_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
       insert into BEST..TI17PERMFIL values ('EBS_ESPD4000_INI',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESPD4000_INI_DLEIFTECLEDSIIEP_EBS_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

---------   Reqs    ---------------------

       insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPD4000_INI','')
       insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPD4000_INI','')
       insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPD4000_INI','')
       insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPD4000_INI','')
       insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPD4000_INI','')
       insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPD4000_INI','')
       insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPD4000_INI','')
       insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPD4000_INI','')
       insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPD4000_INI','')


	----------IDF_CT:   I17G_AEG_RPO_INI ------------------

		insert into BEST..TI17FNC values ('I17G_AEG_RPO_INI',' ','ESPD4000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_AEG_RPO_INI',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESPD4000_I17G_AEG_RPO_INI_GTEP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G_AEG_RPO_INI',  'EST_GTEPSII','${DFILP}/${ENV_PREFIX}_ESPD4000_I17G_AEG_RPO_INI_GTEPSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G_AEG_RPO_INI',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESPD4000_I17G_AEG_RPO_INI_DLEIFTECLEDSIIEP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_AEG_RPO_INI','')

	----------IDF_CT:   I17L_AEG_RPO_INI ------------------

		insert into BEST..TI17FNC values ('I17L_AEG_RPO_INI',' ','ESPD4000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_AEG_RPO_INI',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESPD4000_I17L_AEG_RPO_INI_GTEP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L_AEG_RPO_INI',  'EST_GTEPSII','${DFILP}/${ENV_PREFIX}_ESPD4000_I17L_AEG_RPO_INI_GTEPSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L_AEG_RPO_INI',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESPD4000_I17L_AEG_RPO_INI_DLEIFTECLEDSIIEP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_AEG_RPO_INI','')

	----------IDF_CT:   I17P_AEG_RPO_INI ------------------

		insert into BEST..TI17FNC values ('I17P_AEG_RPO_INI',' ','ESPD4000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_AEG_RPO_INI',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESPD4000_I17P_AEG_RPO_INI_GTEP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P_AEG_RPO_INI',  'EST_GTEPSII','${DFILP}/${ENV_PREFIX}_ESPD4000_I17P_AEG_RPO_INI_GTEPSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P_AEG_RPO_INI',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESPD4000_I17P_AEG_RPO_INI_DLEIFTECLEDSIIEP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_AEG_RPO_INI','')

	----------IDF_CT:   I17S_AEG_RPO_INI ------------------

		insert into BEST..TI17FNC values ('I17S_AEG_RPO_INI',' ','ESPD4000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_AEG_RPO_INI',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESPD4000_I17S_AEG_RPO_INI_GTEP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S_AEG_RPO_INI',  'EST_GTEPSII','${DFILP}/${ENV_PREFIX}_ESPD4000_I17S_AEG_RPO_INI_GTEPSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S_AEG_RPO_INI',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESPD4000_I17S_AEG_RPO_INI_DLEIFTECLEDSIIEP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_AEG_RPO_INI','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_AEG_RPO_INI','')

	----------IDF_CT:   I4I_ESPD4000 ------------------

		insert into BEST..TI17FNC values ('I4I_ESPD4000',' ','ESPD4000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I4I_ESPD4000',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEP_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I4I_ESPD4000',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESPD4000_DLEIFTECLEDSIIEP_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYPOCB',  'I4I_ESPD4000','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'I4I_ESPD4000','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I4I_ESPD4000','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'I4I_ESPD4000','')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'I4I_ESPD4000','')
			insert into BEST..TI17REQFNC values ('I4IQPOCB',  'I4I_ESPD4000','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'I4I_ESPD4000','')
			insert into BEST..TI17REQFNC values ('I4IYPOC',  'I4I_ESPD4000','')
go

