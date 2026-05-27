-------------------------------
--mapping of  DWUD9130

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='DWUD9130')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='DWUD9130')
	delete BEST..TI17FNC where CHAIN_CT='DWUD9130'
	delete BEST..TI17CHN  where CHAIN_CT='DWUD9130'

	insert into BEST..TI17CHN values ('DWUD9130',  '')

	----------IDF_CT:   DWUD9130 ------------------

		insert into BEST..TI17FNC values ('DWUD9130',' ','DWUD9130',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'DWUD9130','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'DWUD9130','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'DWUD9130','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'DWUD9130','')
go

