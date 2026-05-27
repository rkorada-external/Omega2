-------------------------------
--mapping of  ESFD8030

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8030')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8030')
	delete BEST..TI17FNC where CHAIN_CT='ESFD8030'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD8030'

	insert into BEST..TI17CHN values ('ESFD8030',  'IFRS17 - Update SECIFRS Tables')

	----------IDF_CT:   I17G_SEC_UPD_STD ------------------

		insert into BEST..TI17FNC values ('I17G_SEC_UPD_STD','IFRS17 - Group - IFRS17 - Update SECIFRS Tables','ESFD8030',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_SEC_UPD_STD','')

	----------IDF_CT:   I17L_SEC_UPD_STD ------------------

		insert into BEST..TI17FNC values ('I17L_SEC_UPD_STD','IFRS17 - Local - IFRS17 - Update SECIFRS Tables','ESFD8030',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_SEC_UPD_STD','')

	----------IDF_CT:   I17P_SEC_UPD_STD ------------------

		insert into BEST..TI17FNC values ('I17P_SEC_UPD_STD','IFRS17 - Parent - IFRS17 - Update SECIFRS Tables','ESFD8030',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_SEC_UPD_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_SEC_UPD_STD','')
go

