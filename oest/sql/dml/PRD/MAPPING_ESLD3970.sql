-------------------------------
--mapping of  ESLD3970

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3970')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3970')
	delete BEST..TI17FNC where CHAIN_CT='ESLD3970'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD3970'

	insert into BEST..TI17CHN values ('ESLD3970',  'Merge GLT after SAP Feedback')

	----------IDF_CT:   ESLD3970 ------------------

		insert into BEST..TI17FNC values ('ESLD3970',' ','ESLD3970',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESLD3970',  'ESF_FTECLEDR','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3970',  'ESF_FTECLEDR_REJ','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3970',  'ESF_OPNG_EBS_RET','${DFILP}/empty.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3970',  'EPO_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_${PARM_ICLODAT_D}_${PARAM_LOCALSIT}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3970',  'EPO_FTECLEDA_RMN','${DFILP}/${ENV_PREFIX}_ESLD3910_FTECLEDA_RMN_I4I_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3970',  'ESF_FTECLEDR_MRG','${DFILP}/empty.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD3970',  'EPO_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESPD3970_FTECLEDA_MVT_I4I_LOC.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('Y',  'ESLD3970','')
go

