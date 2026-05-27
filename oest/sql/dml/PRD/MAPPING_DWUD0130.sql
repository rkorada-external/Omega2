-------------------------------
--mapping of  DWUD0130

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='DWUD0130')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='DWUD0130')
	delete BEST..TI17FNC where CHAIN_CT='DWUD0130'
	delete BEST..TI17CHN  where CHAIN_CT='DWUD0130'

	insert into BEST..TI17CHN values ('DWUD0130',  '')

	----------IDF_CT:   DWUD0130 ------------------

		insert into BEST..TI17FNC values ('DWUD0130',' ','DWUD0130',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('DWUD0130',  'EPO_FTECLEDASO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_I4I_POS_${PARM_PREV_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('DWUD0130',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_I4I_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('DWUD0130',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_EBS_POS_${PARM_PREV_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('DWUD0130',  'EPO_FTECLEDRSIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDR_EBS_POS_${PARM_PREV_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('DWUD0130',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ES${PARM_FTECLED}D3800_FTECLEDR_I4I_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('DWUD0130',  'EPO_FTECLEDRSO','${DFILP}/${ENV_PREFIX}_ES${PARM_FTECLED}D3800_FTECLEDR_I4I_${PARM_PREV_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'DWUD0130','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('A',  'DWUD0130','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOSB',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOSB',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'DWUD0130','')
			insert into BEST..TI17REQFNC values ('I4IQPOCB',  'DWUD0130','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'DWUD0130','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('I4IYPOC',  'DWUD0130','')
			insert into BEST..TI17REQFNC values ('I4IYPOCB',  'DWUD0130','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'DWUD0130','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSP',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOSP',  'DWUD0130','@variante')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'DWUD0130','')
go

