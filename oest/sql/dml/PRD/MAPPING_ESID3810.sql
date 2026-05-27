-------------------------------
--mapping of  ESID3810

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3810')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID3810')
	delete BEST..TI17FNC where CHAIN_CT='ESID3810'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3810'

	insert into BEST..TI17CHN values ('ESID3810',  'Gaapcod insertion')

	----------IDF_CT:   ESID3810 ------------------

		insert into BEST..TI17FNC values ('ESID3810','Gaapcod insertion','ESID3810',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID3810',  'ESF_FCTRI17PRD_NEW','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID3810',  'ESF_FI17PRODUCT_CUR','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID3810',  'EST_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID3810',  'ESF_FCTRI17PRD_OVR','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_OVR_MVT_I4I.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID3810',  'ESF_FI17PRODUCT_OVR','${DFILP}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT_OVR_MVT_I4I.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID3810',  'EST_FTECLEDA_MTH','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MTH_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID3810',  'EST_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MVT_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID3810',  'EST_FTECLEDA_REP','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_REP_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID3810',  'EST_FTECLEDR_CUR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_CUR_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESID3810',  'EST_FTECLEDR_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_MVT_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID3810','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESID3810','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID3810','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID3810','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID3810','')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID3810','')
go

