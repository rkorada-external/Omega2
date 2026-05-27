-------------------------------
--mapping of  EXTJ0010

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='EXTJ0010')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='EXTJ0010')
	delete BEST..TI17FNC where CHAIN_CT='EXTJ0010'
	delete BEST..TI17CHN  where CHAIN_CT='EXTJ0010'

	insert into BEST..TI17CHN values ('EXTJ0010',  'EXTRACT DATA for TNR Tool')

	----------IDF_CT:   EXTJ0010 ------------------

		insert into BEST..TI17FNC values ('EXTJ0010','EXTRACT DATA for TNR Tool','EXTJ0010',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('EBSEMINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('EBSEQINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('EBSEYINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17GMINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17LMINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17PMINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17SMINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17SQPOC',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17SYPOC',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I4IYPOC',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'EXTJ0010','')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'EXTJ0010','')
go

