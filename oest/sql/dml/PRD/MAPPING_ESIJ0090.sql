-------------------------------
--mapping of  ESIJ0090

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ0090')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESIJ0090')
	delete BEST..TI17FNC where CHAIN_CT='ESIJ0090'
	delete BEST..TI17CHN  where CHAIN_CT='ESIJ0090'

	insert into BEST..TI17CHN values ('ESIJ0090',  '')

	----------IDF_CT:   ESIJ0090 ------------------

		insert into BEST..TI17FNC values ('ESIJ0090',' ','ESIJ0090',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('A',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOSB',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOSB',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('I4IQPOCB',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('I4IYPOC',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('I4IYPOCB',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSP',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOSP',  'ESIJ0090','@variante')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'ESIJ0090','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'ESIJ0090','')
go

