-------------------------------
--mapping of  ESFD8020

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8020')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD8020')
	delete BEST..TI17FNC where CHAIN_CT='ESFD8020'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD8020'

	insert into BEST..TI17CHN values ('ESFD8020',  'Pattern Renewall')

	----------IDF_CT:   EBS_ESFD8020 ------------------

		insert into BEST..TI17FNC values ('EBS_ESFD8020','EBS - Pattern Renewall','ESFD8020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('EBSEQINVB',  'EBS_ESFD8020','')
			insert into BEST..TI17REQFNC values ('EBSEYINVB',  'EBS_ESFD8020','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSB',  'EBS_ESFD8020','')
			insert into BEST..TI17REQFNC values ('EBSEYPOSB',  'EBS_ESFD8020','')

	----------IDF_CT:   I17G_PAT_NEW_STD ------------------

		insert into BEST..TI17FNC values ('I17G_PAT_NEW_STD','IFRS17 Group - Pattern Renewall','ESFD8020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_PAT_NEW_STD','')

	----------IDF_CT:   I17L_PAT_NEW_STD ------------------

		insert into BEST..TI17FNC values ('I17L_PAT_NEW_STD','IFRS17 Local - Pattern Renewall','ESFD8020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LQINVB',  'I17L_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINVB',  'I17L_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17L_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17L_PAT_NEW_STD','')

	----------IDF_CT:   I17P_PAT_NEW_STD ------------------

		insert into BEST..TI17FNC values ('I17P_PAT_NEW_STD','IFRS17 Parent - Pattern Renewall','ESFD8020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PQINVB',  'I17P_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINVB',  'I17P_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17P_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17P_PAT_NEW_STD','')

	----------IDF_CT:   I17S_PAT_NEW_STD ------------------

		insert into BEST..TI17FNC values ('I17S_PAT_NEW_STD','IFRS17 Simulation - Pattern Renewall','ESFD8020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SQINVB',  'I17S_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINVB',  'I17S_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSB',  'I17S_PAT_NEW_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSB',  'I17S_PAT_NEW_STD','')

	----------IDF_CT:   I4I_ESFD8020 ------------------

		insert into BEST..TI17FNC values ('I4I_ESFD8020','I4I - Pattern Renewall','ESFD8020',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQINVB',  'I4I_ESFD8020','')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'I4I_ESFD8020','')
go

