-------------------------------
--mapping of  ESID2220

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2220')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID2220')
	delete BEST..TI17FNC where CHAIN_CT='ESID2220'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2220'

	insert into BEST..TI17CHN values ('ESID2220',  'EBS Losses and IBNR calculation')
go

