-------------------------------
--mapping of  ESARCH20

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESARCH20')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESARCH20')
	delete BEST..TI17FNC where CHAIN_CT='ESARCH20'
	delete BEST..TI17CHN  where CHAIN_CT='ESARCH20'

	insert into BEST..TI17CHN values ('ESARCH20',  'Archive permanet files')

        ----------IDF_CT:   EBS_SAP_OMG_STD ----------------

		     insert into BEST..TI17FNC values ('I17G_ARCH_PERMS' , 'Archive permanet files','ESARCH20',0)
	
	 ----------   Reqs    ---------------------

			--insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_ARCH_PERMS','')
			--insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_ARCH_PERMS','')
			insert into BEST..TI17REQFNC values ('I17GQINVB', 'I17G_ARCH_PERMS','')
			--insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_ARCH_PERMS','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB', 'I17G_ARCH_PERMS','')
			--insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_ARCH_PERMS','')
			insert into BEST..TI17REQFNC values ('I17GYINVB', 'I17G_ARCH_PERMS','')
			--insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_ARCH_PERMS','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB', 'I17G_ARCH_PERMS','')
			--insert into BEST..TI17REQFNC values ('I17GQPOSP', 'I17G_ARCH_PERMS','')
			--insert into BEST..TI17REQFNC values ('I17GYPOSP', 'I17G_ARCH_PERMS','')
			
go


