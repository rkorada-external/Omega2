-------------------------------
--mapping of  ESFT0020

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFT0020')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFT0020')
	delete BEST..TI17FNC where CHAIN_CT='ESFT0020'
	delete BEST..TI17CHN  where CHAIN_CT='ESFT0020'

	insert into BEST..TI17CHN values ('ESFT0020',  'IFRS17 - Transition File Generation')

	----------IDF_CT:   I17G_OMG_ALL_TRA ------------------

		insert into BEST..TI17FNC values ('I17G_OMG_ALL_TRA','IFRS17 - Transition File Generation','ESFT0020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_OMG_ALL_TRA','')

	----------IDF_CT:   I17L_OMG_ALL_TRA ------------------

		insert into BEST..TI17FNC values ('I17L_OMG_ALL_TRA','IFRS17 - Transition File Generation','ESFT0020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_OMG_ALL_TRA','')

	----------IDF_CT:   I17P_OMG_ALL_TRA ------------------

		insert into BEST..TI17FNC values ('I17P_OMG_ALL_TRA','IFRS17 - Transition File Generation','ESFT0020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_OMG_ALL_TRA','')

	----------IDF_CT:   I17S_OMG_ALL_TRA ------------------

		insert into BEST..TI17FNC values ('I17S_OMG_ALL_TRA','IFRS17 - Transition File Generation','ESFT0020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_OMG_ALL_TRA','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_OMG_ALL_TRA','')
go

