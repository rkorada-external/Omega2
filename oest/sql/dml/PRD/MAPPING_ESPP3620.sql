-------------------------------
--mapping of  ESPP3620

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPP3620')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESPP3620')
	delete BEST..TI17FNC where CHAIN_CT='ESPP3620'
	delete BEST..TI17CHN  where CHAIN_CT='ESPP3620'

	insert into BEST..TI17CHN values ('ESPP3620',  'Discount calcultion job ESID3703B')
go

