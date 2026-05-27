-------------------------------
--mapping of  ESFJ0090

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFJ0090')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFJ0090')
	delete BEST..TI17FNC where CHAIN_CT='ESFJ0090'
	delete BEST..TI17CHN  where CHAIN_CT='ESFJ0090'

	insert into BEST..TI17CHN values ('ESFJ0090',  'AE Life treatment')

	----------IDF_CT:   I17G_OMG_RET_LIF ------------------

		insert into BEST..TI17FNC values ('I17G_OMG_RET_LIF','AE Life treatment','ESFJ0090',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G_OMG_RET_LIF',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_RET_LIF',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_RET_LIF',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_RET_LIF',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_RET_LIF',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_RET_LIF',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_RET_LIF',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESFD0560_I17G_FCES_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_RET_LIF',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESFD0560_I17G_FPLC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17G_OMG_RET_LIF',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESFD0560_I17G_IADVPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G_OMG_RET_LIF','')

	----------IDF_CT:   I17L_OMG_RET_LIF ------------------

		insert into BEST..TI17FNC values ('I17L_OMG_RET_LIF','AE Life treatment','ESFJ0090',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L_OMG_RET_LIF',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_RET_LIF',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_RET_LIF',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_RET_LIF',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_RET_LIF',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_RET_LIF',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_RET_LIF',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESFD0560_I17G_FCES_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_RET_LIF',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESFD0560_I17G_FPLC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17L_OMG_RET_LIF',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESFD0560_I17G_IADVPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L_OMG_RET_LIF','')

	----------IDF_CT:   I17P_OMG_RET_LIF ------------------

		insert into BEST..TI17FNC values ('I17P_OMG_RET_LIF','AE Life treatment','ESFJ0090',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P_OMG_RET_LIF',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_RET_LIF',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_RET_LIF',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_RET_LIF',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_RET_LIF',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_RET_LIF',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_RET_LIF',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESFD0560_I17G_FCES_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_RET_LIF',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESFD0560_I17G_FPLC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17P_OMG_RET_LIF',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESFD0560_I17G_IADVPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P_OMG_RET_LIF','')

	----------IDF_CT:   I17S_OMG_RET_LIF ------------------

		insert into BEST..TI17FNC values ('I17S_OMG_RET_LIF','AE Life treatment','ESFJ0090',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S_OMG_RET_LIF',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0660_FDETTRS.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_RET_LIF',  'EST_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRSLNK.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_RET_LIF',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURCVSN.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_RET_LIF',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_RET_LIF',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURCVSNI.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_RET_LIF',  'EST_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESCJ0660_FTRANSCODE.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_RET_LIF',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESFD0560_I17S_FCES_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_RET_LIF',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESFD0560_I17S_FPLC_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
			insert into BEST..TI17PERMFIL values ('I17S_OMG_RET_LIF',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESFD0560_I17S_IADVPERICASE_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S_OMG_RET_LIF','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S_OMG_RET_LIF','')
go

