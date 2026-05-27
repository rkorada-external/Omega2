-------------------------------
--mapping of  ESID8120

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8120')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESID8120')
	delete BEST..TI17FNC where CHAIN_CT='ESID8120'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8120'

	insert into BEST..TI17CHN values ('ESID8120',  '')

	----------IDF_CT:   ESID8120 ------------------

		insert into BEST..TI17FNC values ('ESID8120',' ','ESID8120',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTE_SRV_PA','${DFILP}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PA_${BALSHTYEA}1231.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTEF_SRV_PA','${DFILP}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PA_${BALSHTYEA}1231.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${TYPEINV}_${PARM_ICLODAT2_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_ECRSRVAPC_PA','${DFILP}/${ENV_PREFIX}_ESID1520_ECRSRVAPC_PA_${TYPEINV}_${BALSHTYEA}1231.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_ECRSRVRPC_PA','${DFILP}/${ENV_PREFIX}_ESID1520_ECRSRVRPC_PA_${TYPEINV}_${BALSHTYEA}1231.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_IAVPERICASE0','${DFILP}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTE_SRV_PC','${DFILP}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PC_${TYPEINV}_${PARM_ICLODAT2_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTR_VENTIL','${DFILP}/${ENV_PREFIX}_ESID2040_SRGTR_VENTIL_${TYPEINV}_${PARM_ICLODAT2_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_IARVPERICASE4','${DFILP}/${ENV_PREFIX}_ESID2030_IARVPERICASE4_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTEF_SRV_PC','${DFILP}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PC_${TYPEINV}_${PARM_ICLODAT2_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_FLIFPLN1_VENTIL','${DFILP}/${ENV_PREFIX}_ESID1520_FLIFPLN1_VENTIL_${TYPEINV}_${PARM_ICLODAT2_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_FLIFPLN3_VENTIL','${DFILP}/${ENV_PREFIX}_ESID1520_FLIFPLN3_VENTIL_${TYPEINV}_${PARM_ICLODAT2_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I4IMINV',  'ESID8120','')
			insert into BEST..TI17REQFNC values ('I4IQINV',  'ESID8120','@variante')
			insert into BEST..TI17REQFNC values ('I4IQINVB',  'ESID8120','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINV',  'ESID8120','@variante')
			insert into BEST..TI17REQFNC values ('I4IYINVB',  'ESID8120','@variante')
go

