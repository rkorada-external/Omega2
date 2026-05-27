-------------------------------
--mapping of  ESFD0060

	----------   Clean tables   ---------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD0060')
	delete BEST..TI17REQFNC where     IDF_CT  in ( select IDF_CT from BEST..TI17FNC where   CHAIN_CT='ESFD0060')
	delete BEST..TI17FNC where CHAIN_CT='ESFD0060'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD0060'

	insert into BEST..TI17CHN values ('ESFD0060',  'Data extraction')

	----------IDF_CT:   I17G___ ------------------

		insert into BEST..TI17FNC values ('I17G___','Get data IFRS 17 GROUP','ESFD0060',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FMARKET','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FRARAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RARAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____EXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FUOASII','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G___TUOASII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_GAAPMAP','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____GAAPMAP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FLOARAT_I17G','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FLOARAT${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FUWRETSEC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FUWRETSEC_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_GAAPMAPLIF','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____GAAPMAPLIF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_EPOSOCI','${DFILI}/${ENV_PREFIX}_ESFD0060_${NORME_CF}____EPOSOCI_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_RET_FEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RET_FEXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_RATIO_TEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RATIO_TEXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'EST_ANN_LIMIT_FAC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____EST_ANN_LIMIT_FAC_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'EST_ANN_LIMIT_TRT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____EST_ANN_LIMIT_TRT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FSEG_TSECIFRS_I17','${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____FSEG_TSECIFRS_I17_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17GMINV',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GQINV',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GQINVB',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GQPOS',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GQPOSB',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GYINV',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GYINVB',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GYPOS',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GYPOSB',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GQPOSP',  'I17G___','')
			insert into BEST..TI17REQFNC values ('I17GYPOSP',  'I17G___','')

	----------IDF_CT:   I17L___ ------------------

		insert into BEST..TI17FNC values ('I17L___','Get data IFRS 17 Local','ESFD0060',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_FMARKET','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_FRARAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____RARAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_FEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____EXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_FUOASII','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L___TUOASII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_GAAPMAP','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____GAAPMAP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_FLOARAT_I17G','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____FLOARAT${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_FUWRETSEC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____FUWRETSEC_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_GAAPMAPLIF','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____GAAPMAPLIF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_EPOSOCI','${DFILI}/${ENV_PREFIX}_ESFD0060_${NORME_CF}____EPOSOCI_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_RET_FEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____RET_FEXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_RATIO_TEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____RATIO_TEXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'EST_ANN_LIMIT_FAC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____EST_ANN_LIMIT_FAC_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'EST_ANN_LIMIT_TRT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____EST_ANN_LIMIT_TRT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17L___',  'ESF_FSEG_TSECIFRS_I17','${DFILP}/${ENV_PREFIX}_ESFD0060_I17L____FSEG_TSECIFRS_I17_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17LYPOSX',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LQPOSX',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LQINVB',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LQPOS',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LQPOSB',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LYINV',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LYINVB',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LYPOS',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LYPOSB',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LQPOSP',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LYPOSP',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LMINV',  'I17L___','')
			insert into BEST..TI17REQFNC values ('I17LQINV',  'I17L___','')

	----------IDF_CT:   I17P___ ------------------

		insert into BEST..TI17FNC values ('I17P___','Get data IFRS 17 Local','ESFD0060',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_FMARKET','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_FRARAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____RARAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_FEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____EXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_FUOASII','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P___TUOASII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_GAAPMAP','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____GAAPMAP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_FLOARAT_I17G','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____FLOARAT${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_FUWRETSEC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____FUWRETSEC_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_GAAPMAPLIF','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____GAAPMAPLIF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_EPOSOCI','${DFILI}/${ENV_PREFIX}_ESFD0060_${NORME_CF}____EPOSOCI_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_RET_FEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____RET_FEXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_RATIO_TEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____RATIO_TEXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'EST_ANN_LIMIT_FAC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____EST_ANN_LIMIT_FAC_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'EST_ANN_LIMIT_TRT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____EST_ANN_LIMIT_TRT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17P___',  'ESF_FSEG_TSECIFRS_I17','${DFILP}/${ENV_PREFIX}_ESFD0060_I17P____FSEG_TSECIFRS_I17_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17PYPOS',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PMINV',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PQINV',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PQINVB',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PQPOS',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PQPOSB',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PYINV',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PYINVB',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PYPOSB',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PYPOSP',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PQPOSP',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PYPOSX',  'I17P___','')
			insert into BEST..TI17REQFNC values ('I17PQPOSX',  'I17P___','')

	----------IDF_CT:   I17S___ ------------------

		insert into BEST..TI17FNC values ('I17S___','Get data IFRS 17 Simulation','ESFD0060',0)
					

		----------  Perms---------------------

			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_FMARKET','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S_FMARKET_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_FRARAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____RARAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_FEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____EXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_FUOASII','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S___TUOASII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_GAAPMAP','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____GAAPMAP_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_FLOARAT_I17G','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____FLOARAT${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_FUWRETSEC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____FUWRETSEC_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_GAAPMAPLIF','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____GAAPMAPLIF_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_EPOSOCI','${DFILI}/${ENV_PREFIX}_ESFD0060_${NORME_CF}____EPOSOCI_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_RET_FEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____RET_FEXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_RATIO_TEXPRAT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____RATIO_TEXPRAT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'EST_ANN_LIMIT_FAC','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____EST_ANN_LIMIT_FAC_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'EST_ANN_LIMIT_TRT','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____EST_ANN_LIMIT_TRT_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
			insert into BEST..TI17PERMFIL values ('I17S___',  'ESF_FSEG_TSECIFRS_I17','${DFILP}/${ENV_PREFIX}_ESFD0060_I17S____FSEG_TSECIFRS_I17_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

		----------   Reqs    ---------------------

			insert into BEST..TI17REQFNC values ('I17SMINV',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SQINV',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SQINVB',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SQPOS',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SQPOSB',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SYINV',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SYINVB',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SYPOS',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SYPOSB',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SQPOSP',  'I17S___','')
			insert into BEST..TI17REQFNC values ('I17SYPOSP',  'I17S___','')
go

