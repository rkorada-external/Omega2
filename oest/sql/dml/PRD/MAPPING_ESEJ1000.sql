-------------------------------
--mapping of  ESEJ1000

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEJ1000')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEJ1000')
	delete BEST..TI17FNC where CHAIN_CT='ESEJ1000'
	delete BEST..TI17CHN  where CHAIN_CT='ESEJ1000'

	insert into BEST..TI17CHN values ('ESEJ1000',  '')

	----------IDF_CT:   ESEJ1000 ------------------

		insert into BEST..TI17FNC values ('ESEJ1000',' ','ESEJ1000',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_STATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOSB',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOSB',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('I4IQPOCB',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('I4IYPOC',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('I4IYPOCB',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSP',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOSP',  'ESEJ1000','@variante')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'ESEJ1000','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'ESEJ1000','')
go

