-------------------------------
--mapping of  ESEH1110

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEH1110')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESEH1110')
	delete BEST..TI17FNC where CHAIN_CT='ESEH1110'
	delete BEST..TI17CHN  where CHAIN_CT='ESEH1110'

	insert into BEST..TI17CHN values ('ESEH1110',  '')

	----------IDF_CT:   ESEH1110 ------------------

		insert into BEST..TI17FNC values ('ESEH1110',' ','ESEH1110',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FAPR0','${DFILP}/${ENV_PREFIX}_ESEH1110_FAPR0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FAMPROT0','${DFILP}/${ENV_PREFIX}_ESEH1110_FAMPROT0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FBSEGEST','${DFILP}/${ENV_PREFIX}_ESEH1110_FBSEGEST_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCPLACC0','${DFILP}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCTRGRO0','${DFILP}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCTRULT0','${DFILP}/${ENV_PREFIX}_ESEH1110_FCTRULT0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FUNDSTA0','${DFILP}/${ENV_PREFIX}_ESEH1110_FUNDSTA0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FVCTRGRO','${DFILP}/${ENV_PREFIX}_ESEH1110_FVCTRGRO_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCESSION0','${DFILP}/${ENV_PREFIX}_ESEH1110_FCESSION0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCESSION1','${DFILP}/${ENV_PREFIX}_ESEH1110_FCESSION1_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FPLACEMT0','${DFILP}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FPLACEMT1','${DFILP}/${ENV_PREFIX}_ESEH1110_FPLACEMT1_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FPLACEMT2','${DFILP}/${ENV_PREFIX}_ESEH1110_FPLACEMT2_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FVCTRGRO0','${DFILP}/${ENV_PREFIX}_ESEH1110_FVCTRGRO0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FPLACEMTCOM0','${DFILP}/${ENV_PREFIX}_ESEH1110_FPLACEMTCOM0_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_SAISPERICASE','${DFILP}/${ENV_PREFIX}_ESEH1110_SAISPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IQPOCB',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('I4IYPOC',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('I4IYPOCB',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('I4IYPOS',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('I4IYPOSB',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('EBSEYPOSB',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('I4IMINVB',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('I4IQPOC',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('I4IQPOS',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('I4IQPOSB',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('A',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('EBSEQPOC',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOCB',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOS',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('EBSEQPOSB',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOC',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOCB',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOS',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('I4IYPOSP',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('I4IQPOSP',  'ESEH1110','')
			insert into BEST..TI17REQFNC values ('EBSEQPOSP',  'ESEH1110','@variante')
			insert into BEST..TI17REQFNC values ('EBSEYPOSP',  'ESEH1110','@variante')
go

