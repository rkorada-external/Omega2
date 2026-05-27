-------------------------------
--mapping of  ESFD3910

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3910')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD3910')
	delete BEST..TI17FNC where CHAIN_CT='ESFD3910'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3910'

	insert into BEST..TI17CHN values ('ESFD3910',  'AE Life treatment SAP')

	----------IDF_CT:   I17G_OMG_SAP_LIF ------------------

		insert into BEST..TI17FNC values ('I17G_OMG_SAP_LIF','AE Life treatment SAP','ESFD3910',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_OMG_SAP_LIF',  'ESF_FDETTRS_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_SAP_LIF',  'ESF_FCTRI17PRD_NEW','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_SAP_LIF',  'ESF_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_SAP_LIF',  'ESF_FTECLEDA_I17AELIFE','${DFILP}/${ENV_PREFIX}_ESFD4030_I17G_OMG_CES_LIF_TECLEDAI17AELIFE_${TYPEINV}_${PARM_ICLODAT_D}.dat','U','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_SAP_LIF',  'ESF_FTECLEDR_I17AELIFE','${DFILP}/${ENV_PREFIX}_ESFD4030_I17G_OMG_CES_LIF_TECLEDRI17AELIFE_${TYPEINV}_${PARM_ICLODAT_D}.dat','U','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G_OMG_SAP_LIF','')

	----------IDF_CT:   I17L_OMG_SAP_LIF ------------------

		insert into BEST..TI17FNC values ('I17L_OMG_SAP_LIF','AE Life treatment SAP','ESFD3910',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_OMG_SAP_LIF',  'ESF_FDETTRS_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_SAP_LIF',  'ESF_FCTRI17PRD_NEW','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_SAP_LIF',  'ESF_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_SAP_LIF',  'ESF_FTECLEDA_I17AELIFE','${DFILP}/${ENV_PREFIX}_ESFD4030_I17L_OMG_CES_LIF_TECLEDAI17AELIFE_${TYPEINV}_${PARM_ICLODAT_D}.dat','U','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_SAP_LIF',  'ESF_FTECLEDR_I17AELIFE','${DFILP}/${ENV_PREFIX}_ESFD4030_I17L_OMG_CES_LIF_TECLEDRI17AELIFE_${TYPEINV}_${PARM_ICLODAT_D}.dat','U','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LYINVB',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LQINVB',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LYPOSP',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LQPOSP',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_OMG_SAP_LIF','')

	----------IDF_CT:   I17P_OMG_SAP_LIF ------------------

		insert into BEST..TI17FNC values ('I17P_OMG_SAP_LIF','AE Life treatment SAP','ESFD3910',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_OMG_SAP_LIF',  'ESF_FDETTRS_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS_TXT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_SAP_LIF',  'ESF_FCTRI17PRD_NEW','${DFILP}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_SAP_LIF',  'ESF_GAAPCOD_MAPPING','${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_SAP_LIF',  'ESF_FTECLEDA_I17AELIFE','${DFILP}/${ENV_PREFIX}_ESFD4030_I17P_OMG_CES_LIF_TECLEDAI17AELIFE_${TYPEINV}_${PARM_ICLODAT_D}.dat','U','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_SAP_LIF',  'ESF_FTECLEDR_I17AELIFE','${DFILP}/${ENV_PREFIX}_ESFD4030_I17P_OMG_CES_LIF_TECLEDRI17AELIFE_${TYPEINV}_${PARM_ICLODAT_D}.dat','U','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PQINVB',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PYINVB',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PQPOSP',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PYPOSP',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_OMG_SAP_LIF','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_OMG_SAP_LIF','')
go

