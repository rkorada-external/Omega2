-------------------------------
--mapping of  ESFD0050

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD0050')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD0050')
	delete BEST..TI17FNC where CHAIN_CT='ESFD0050'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD0050'

	insert into BEST..TI17CHN values ('ESFD0050',  'FTPget SAP gaap code setup')

	----------IDF_CT:   ESFD0050 ------------------

		insert into BEST..TI17FNC values ('ESFD0050','FTPget SAP gaap code setup','ESFD0050',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESFD0050',  'ESF_SAP_GAAPS_FILTER','${DFILP}/${ENV_PREFIX}_ESFD0050_SAP_GAAPS_FILTER.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESFD0050',  'ESF_SAP_FTP_FILE','GLOT0010_TLEDGERS','I','')
			insert into BEST..TI17PERMFIL values ('ESFD0050',  'ESF_SAP_ARCH_FILE','ESFD0050_TLEDGERS','O','')
			insert into BEST..TI17PERMFIL values ('ESFD0050',  'ESF_MAINTENANCE_SETUP','${DFILP}/${ENV_PREFIX}_ESFD0050_SAP_MAINTENANCE_SETUP.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('ALL',  'ESFD0050','')
go

