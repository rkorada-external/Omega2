-------------------------------
--mapping of  ESLD3810

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3810')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESLD3810')
	delete BEST..TI17FNC where CHAIN_CT='ESLD3810'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD3810'

	insert into BEST..TI17CHN values ('ESLD3810',  'Gaapcod insertion')

	----------IDF_CT:   ESLD3810 ------------------

		insert into BEST..TI17FNC values ('ESLD3810','Gaapcod insertion','ESLD3810',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESLD3810',  'ESF_FCTRI17PRD_NEW','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3810',  'ESF_FI17PRODUCT_CUR','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3810',  'ESL_FTECLEDALO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDA_I4I_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3810',  'ESL_FTECLEDRLO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDR_I4I_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3810',  'EST_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3810',  'ESL_FTECLEDALO_MTH','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDA_MTH_I4I_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3810',  'ESL_FTECLEDALO_MVT','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDA_MVT_I4I_LOC.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESLD3810',  'ESF_FCTRI17PRD_OVR','${DFILP}/${ENV_PREFIX}_ESLD0040_FCTRI17PRD_OVR_MVT_LOC.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESLD3810',  'ESF_FI17PRODUCT_OVR','${DFILP}/${ENV_PREFIX}_ESLD0040_FI17PRODUCT_OVR_MVT_LOC.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('Y',  'ESLD3810','')
go

