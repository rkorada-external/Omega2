-------------------------------
--mapping of  ESFJ8990

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFJ8990')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFJ8990')
	delete BEST..TI17FNC where CHAIN_CT='ESFJ8990'
	delete BEST..TI17CHN  where CHAIN_CT='ESFJ8990'

	insert into BEST..TI17CHN values ('ESFJ8990',  'Generating IFRS 17 Group RA files')

	----------IDF_CT:   I17G_OMG_CLO_AOC ------------------

		insert into BEST..TI17FNC values ('I17G_OMG_CLO_AOC',' ','ESFJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('INVO',  'I17G_OMG_CLO_AOC','INVO')
			insert into BEST..TI17REQFNC values ('POCO',  'I17G_OMG_CLO_AOC','POCO')
			insert into BEST..TI17REQFNC values ('POSO',  'I17G_OMG_CLO_AOC','POSO')

	----------IDF_CT:   I17G_OMG_CLO_STD ------------------

		insert into BEST..TI17FNC values ('I17G_OMG_CLO_STD',' ','ESFJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('S',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GMINVB',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G_OMG_CLO_STD','')

	----------IDF_CT:   I17L_OMG_CLO_STD ------------------

		insert into BEST..TI17FNC values ('I17L_OMG_CLO_STD',' ','ESFJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQINVB',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYINVB',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LMINVB',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSP',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSP',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_OMG_CLO_STD','')

	----------IDF_CT:   I17P_OMG_CLO_STD ------------------

		insert into BEST..TI17FNC values ('I17P_OMG_CLO_STD',' ','ESFJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQINVB',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYINVB',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PMINVB',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSP',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSP',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_OMG_CLO_STD','')

	----------IDF_CT:   I17S_OMG_CLO_AOC ------------------

		insert into BEST..TI17FNC values ('I17S_OMG_CLO_AOC',' ','ESFJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------


	----------IDF_CT:   I17S_OMG_CLO_STD ------------------

		insert into BEST..TI17FNC values ('I17S_OMG_CLO_STD',' ','ESFJ8990',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SQINVB',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SMINVB',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSB',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SYINVB',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSB',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SQPOSP',  'I17S_OMG_CLO_STD','')
			insert into BEST..TI17REQFNC values ('I17SYPOSP',  'I17S_OMG_CLO_STD','')
go

