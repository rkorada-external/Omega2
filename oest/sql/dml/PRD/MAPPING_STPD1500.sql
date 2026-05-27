-------------------------------
--mapping of  STPD1500

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STPD1500')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='STPD1500')
	delete BEST..TI17FNC where CHAIN_CT='STPD1500'
	delete BEST..TI17CHN  where CHAIN_CT='STPD1500'

	insert into BEST..TI17CHN values ('STPD1500',  '')

	----------IDF_CT:   STPD1500 ------------------

		insert into BEST..TI17FNC values ('STPD1500',' ','STPD1500',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_SUBTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_LIFSTAREP','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP_INV.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_CPLIFDRI','${DFILP}/${ENV_PREFIX}_ESID2030_CPLIFDRI_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_FVPLACEMT','${DFILP}/${ENV_PREFIX}_ESID2030_FVPLACEMT_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID2030_IARVPERICASE0_INV_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_ECRSOCAPC','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCAPC_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_ECRSOCRPC','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCRPC_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_ECRSOCRCBP','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCRCBP_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_LIFSTAREP_BRIDG','${DFILP}/${ENV_PREFIX}_STPD1500_LIFSTAREP_BRIDG_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'STA_LIFSTAREP_BILANPREC','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_BILANPREC.dat','O','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'STA_LIFSTAREP_CBP_RETRO','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP_CBP_RETRO.dat','O','')
			insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_ECRSOCACBP','${DFILP}/${ENV_PREFIX}_ESPD1520_ECRSOCACBP_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOS',  'STPD1500','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'STPD1500','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'STPD1500','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'STPD1500','')
go

go

