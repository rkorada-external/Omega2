-------------------------------
--mapping of  ESFT0010

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFT0010')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFT0010')
	delete BEST..TI17FNC where CHAIN_CT='ESFT0010'
	delete BEST..TI17CHN  where CHAIN_CT='ESFT0010'

	insert into BEST..TI17CHN values ('ESFT0010',  'IFRS17 - Omega extract Generation')

	----------IDF_CT:   I17G_OMG_CSU_TRA ------------------

		insert into BEST..TI17FNC values ('I17G_OMG_CSU_TRA','IFRS17 - Omega extract Generation','ESFT0010',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_OMG_CSU_TRA','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_OMG_CSU_TRA','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_OMG_CSU_TRA','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_OMG_CSU_TRA','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_OMG_CSU_TRA','')

	----------IDF_CT:   I17S_OMG_CSU_TRA ------------------

		insert into BEST..TI17FNC values ('I17S_OMG_CSU_TRA','IFRS17 - Omega extract Generation','ESFT0010',0)
					

		----------  Perms---------------------


		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_OMG_CSU_TRA','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_OMG_CSU_TRA','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_OMG_CSU_TRA','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_OMG_CSU_TRA','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_OMG_CSU_TRA','')
go

