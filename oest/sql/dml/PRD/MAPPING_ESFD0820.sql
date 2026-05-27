-------------------------------
--mapping of  ESFD0820

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD0820')
	delete BEST..TI17REQFNC  where IDF_CT in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD0820')
	delete BEST..TI17FNC     where CHAIN_CT='ESFD0820'
	delete BEST..TI17CHN     where CHAIN_CT='ESFD0820'

	insert into BEST..TI17CHN values ('ESFD0820',  'extract NTAP to update')

	----------IDF_CT:   ESFD0820 ------------------

	insert into BEST..TI17FNC values ('I17G_ESFD0820','extract NTAP to update','ESFD0820',0)

	----------  Perms---------------------



	----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G_ESFD0820','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G_ESFD0820','')
			
go

