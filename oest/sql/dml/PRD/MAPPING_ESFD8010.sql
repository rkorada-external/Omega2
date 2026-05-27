-------------------------------
--mapping of  ESFD8010

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8010')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8010')
	delete BEST..TI17FNC where CHAIN_CT='ESFD8010'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD8010'

	insert into BEST..TI17CHN values ('ESFD8010',  'IFRS17 - Booking')

	----------IDF_CT:   I17G_OMG_BOK_STD ------------------

		insert into BEST..TI17FNC values ('I17G_OMG_BOK_STD','IFRS17 Group - Booking','ESFD8010',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_OMG_BOK_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_OMG_BOK_STD','')

	----------IDF_CT:   I17L_OMG_BOK_STD ------------------

		insert into BEST..TI17FNC values ('I17L_OMG_BOK_STD','IFRS17 Local - Booking','ESFD8010',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17L_OMG_BOK_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17L_OMG_BOK_STD','')

	----------IDF_CT:   I17P_OMG_BOK_STD ------------------

		insert into BEST..TI17FNC values ('I17P_OMG_BOK_STD','IFRS17 Parent - Booking','ESFD8010',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17P_OMG_BOK_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17P_OMG_BOK_STD','')
go

