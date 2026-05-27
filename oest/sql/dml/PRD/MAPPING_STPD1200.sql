-------------------------------
--mapping of  STPD1200

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STPD1200')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STPD1200')
	delete BEST..TI17FNC where CHAIN_CT='STPD1200'
	delete BEST..TI17CHN  where CHAIN_CT='STPD1200'

	insert into BEST..TI17CHN values ('STPD1200',  '')

	----------IDF_CT:   STPD1200 ------------------

		insert into BEST..TI17FNC values ('STPD1200',' ','STPD1200',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_CPLIFDRI','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFDRI_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_FVPLACEMT','${DFILP}/${ENV_PREFIX}_ESID2030_FVPLACEMT_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID2030_IARVPERICASE0_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_ECRSOCAPC','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCAPC_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_ECRSOCRPC','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCRPC_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'STPD1200','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'STPD1200','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'STPD1200','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'STPD1200','')
go

