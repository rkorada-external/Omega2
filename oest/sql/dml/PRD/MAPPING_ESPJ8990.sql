-------------------------------
--mapping of  ESPJ8990

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPJ8990')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPJ8990')
	delete BEST..TI17FNC where CHAIN_CT='ESPJ8990'
	delete BEST..TI17CHN  where CHAIN_CT='ESPJ8990'

	insert into BEST..TI17CHN values ('ESPJ8990',  'Post omega')

	----------IDF_CT:   EBS_ESPJ8990 ------------------

		insert into BEST..TI17FNC values ('EBS_ESPJ8990','IFRS4 Post omega  EBS','ESPJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEQPOSB',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEYINVB',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEYPOSB',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEQINVB',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEMINVB',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSP',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEYPOSP',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'EBS_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EBS_ESPJ8990','')

	----------IDF_CT:   I4I_ESPJ8990 ------------------

		insert into BEST..TI17FNC values ('I4I_ESPJ8990','IFRS4 Post omega  IFRS','ESPJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IYPOC',  'I4I_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'I4I_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('I4IQPOCB',  'I4I_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'I4I_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'I4I_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('I4IYPOCB',  'I4I_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'I4I_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'I4I_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'I4I_ESPJ8990','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'I4I_ESPJ8990','')
go

