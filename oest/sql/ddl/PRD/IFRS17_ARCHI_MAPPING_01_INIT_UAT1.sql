
-------------------------------
-- drop constraints FK_REQST_REQJOB_IFRS17 and FK_REQST_REQJOBPLAN_IFRS17
-------------------------------

USE BEST
go
 alter table dbo.TI17REQJOB drop constraint FK_REQST_REQJOB_IFRS17
 alter table dbo.TI17REQJOBPLAN drop constraint FK_REQST_REQJOBPLAN_IFRS17
go


-------------------------------
-- Clean tables
-------------------------------

	delete BEST..TI17PERMFIL
	delete BEST..TI17REQCHN
	delete BEST..TI17CHN
	delete BEST..TI17FNC
	delete BEST..TI17REQ

-------------------------------
--	load BEST..TI17REQ 
-------------------------------

	insert into BEST..TI17REQ values ('I17GMPOCB', 'Monthly POC IFRS 17 Group booking')
	insert into BEST..TI17REQ values ('I17GMINV', 'Monthly INV IFRS 17 Group')
	insert into BEST..TI17REQ values ('I17GQINV', 'Quarterly INV IFRS 17 Group')
	insert into BEST..TI17REQ values ('BookingPOSE', 'Post omega Social EBS4 Booking')
	insert into BEST..TI17REQ values ('BookingPOSI', 'Booking Post omega Social  IFRS4')
	insert into BEST..TI17REQ values ('BookingPOCE', 'Booking Post omega conso EBS')
	insert into BEST..TI17REQ values ('I17GQPOSB', 'Quarterly POS IFRS 17 Group booking')
	insert into BEST..TI17REQ values ('BookingPOCIAnnuel', 'Booking Post omega conso IFRS4')
	insert into BEST..TI17REQ values ('BookingPOSEAnnuel', 'Post omega Social EBS4 Booking annuel')
	insert into BEST..TI17REQ values ('I17GMPOS', 'Monthly POS IFRS 17 Group')
	insert into BEST..TI17REQ values ('I17GYINVB', 'Yearly  INV IFRS 17 Group technical booking')
	insert into BEST..TI17REQ values ('POSI', 'Post omega Social  IFRS4')
	insert into BEST..TI17REQ values ('BookingPOCI', 'Booking Post omega conso IFRS4')
	insert into BEST..TI17REQ values ('POSE', 'Post omega Social EBS4')
	insert into BEST..TI17REQ values ('I17GYPOSB', 'Yearly  POS IFRS 17 Group booking')
	insert into BEST..TI17REQ values ('I17GQINVB', 'Quarterly INV IFRS 17 Group technical booking')
	insert into BEST..TI17REQ values ('I17GMPOSB', 'Monthly POS IFRS 17 Group booking')
	insert into BEST..TI17REQ values ('I17GMPOC', 'Monthly POC IFRS 17 Group')
	insert into BEST..TI17REQ values ('I17GYINV', 'Yearly INV IFRS 17 Group')
	insert into BEST..TI17REQ values ('I17GQPOCB', 'Quarterly POC IFRS 17 Group booking')
	insert into BEST..TI17REQ values ('I17GMINVB', 'Monthly INV IFRS 17 Group technical booking')
	insert into BEST..TI17REQ values ('I17GYPOS', 'Yearly  POS IFRS 17 Group')
	insert into BEST..TI17REQ values ('I17GQPOS', 'Quarterly POS IFRS 17 Group')
	insert into BEST..TI17REQ values ('BookingPOCEAnnuel', 'Post omega conso annuel EBS')
	insert into BEST..TI17REQ values ('I17GYPOC', 'Yearly  POC IFRS 17 Group')
	insert into BEST..TI17REQ values ('POCI', 'Post omega conso IFRS4')
	insert into BEST..TI17REQ values ('BookingPOSIAnnuel', 'Booking annuel Post omega Social IFRS4')
	insert into BEST..TI17REQ values ('POCE', 'Post omega conso EBS')
	insert into BEST..TI17REQ values ('I17GYPOCB', 'Yearly  POC IFRS 17 Group booking')
	insert into BEST..TI17REQ values ('I17GQPOC', 'Quarterly POC IFRS 17 Group')

-------------------------------
--	Init  ESPD3710
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3710')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD3710'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3710'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3710')

	insert into BEST..TI17CHN values ('ESPD3710',  '')

		--  ESPD3710 

	insert into BEST..TI17FNC values ('ESPD3710',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESPT0000_FLIBEL2.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_FTRSLNK8','${DFILP}/${ENV_PREFIX}_ESPD0060_FTRSLNK8.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_FTVENTNP','${DFILP}/${ENV_PREFIX}_ESPT0000_FTVENTNP.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_FVENTNPANT','${DFILP}/${ENV_PREFIX}_ESPT0000_FVENTNPANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_IRDVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EST_DLDSIIGTARCO','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTARCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EST_DLDSIIGTARSO','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_VENTNPSIICO','${DFILP}/${ENV_PREFIX}_ESPD3710_VENTNPSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_VENTNPSIISO','${DFILP}/${ENV_PREFIX}_ESPD3710_VENTNPSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_DLDSIIGTARCO','${DFILP}/${ENV_PREFIX}_ESPD3710_DLDSIIGTARCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3710',  'EPO_DLDSIIGTARSO','${DFILP}/${ENV_PREFIX}_ESPD3710_DLDSIIGTARSO.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD2550
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD2550')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD2550'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD2550'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD2550')

	insert into BEST..TI17CHN values ('ESPD2550',  '')

		--  ESPD2550 

	insert into BEST..TI17FNC values ('ESPD2550',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FCES','${DFILP}/${ENV_PREFIX}_ESPT0000_FCES.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FPLC','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_GTEPCO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_GTEPSO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FRETTRF','${DFILP}/${ENV_PREFIX}_ESPT0000_FRETTRF.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FSUBTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FSUBTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EST_DLREGTR','${DFILP}/${ENV_PREFIX}_ESPT0000_DLREGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLSGTRCO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLSGTRSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSN.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESPT0000_FSSDACTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSNI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FPLACEMT0','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLACEMT0.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_GTEPSIICO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_GTEPSIISO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRANSCODE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLDSIIGTRCO','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLDSIIGTRSO','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLSGTRSIICO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLSGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLDGTAASIICO','${DFILP}/${ENV_PREFIX}_ESID2220_DLDGTAASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLDGTAASIISO','${DFILP}/${ENV_PREFIX}_ESID2220_DLDGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_IADVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIRDVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLEIGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLEIGTAA.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLDVGTRCO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLDVGTRCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLDVGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLDVGTRSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREGTRCO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLRGTAACO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAACO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLRGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREGTARCO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTARCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTARSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLRIGTAACO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRIGTAACO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLRIGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRIGTAASO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLRIGTAANOS','${DFILI}/${ENV_PREFIX}_ESPD2550_DLRIGTAANOS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLDVGTRSIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLDVGTRSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLDVGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLDVGTRSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREGTRSIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREMAJGTRCO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREMAJGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLRGTAASIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLRGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREGTARSIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTARSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREGTARSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTARSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREMAJGTARCO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTARCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREMAJGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTARSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLRIGTAASIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRIGTAASIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLRIGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRIGTAASIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREMAJGTRSIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREMAJGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREMAJGTARSIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTARSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2550',  'EPO_DLREMAJGTARSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTARSIISO.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3730
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3730')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3730'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3730'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3730')

	insert into BEST..TI17CHN values ('ESFD3730',  'Merge cashflow and discount')

		--  I17G_SII_ALL_STD 

	insert into BEST..TI17FNC values ('I17G_SII_ALL_STD',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'EPO_FTECLEDSII','${DFILP}/${PCH}ESPD3700_FTECLEDSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'EPO_FTECLEDSIICO','${DFILP}/${PCH}ESPD3700_FTECLEDSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'EPO_FTECLEDSIISO','${DFILP}/${PCH}ESPD3700_FTECLEDSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'EPO_GTSII_RISKMARGIN','${DFILP}/${PCH}ESPD3700_GTSII_RISKMARGIN.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'EPO_GTSII_RISKMARGINCO','${DFILP}/${PCH}ESPD3700_GTSII_RISKMARGINCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'EPO_GTSII_RISKMARGINSO','${DFILP}/${PCH}ESPD3700_GTSII_RISKMARGINSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_IFRS17_CSM_ESCOMPTE','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_ESCOMPTE_UWD_STD','${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_UNWIND_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_ESCOMPTE_DSI_STD','${DFILP}/${PCH}ESFD3620_I17G_DSC_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_ESCOMPTE_LKI_INI','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_ESCOMPTE_LKI_STD','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_CASHFLOW_RAD_CKI_INI','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_INI_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_CASHFLOW_RAD_CKI_STD','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_CASHFLOW_RAD_CUR_STD','${DFILP}/${PCH}ESFD3650_I17G_RAD_CUR_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_ESCOMPTE_FWD_STD','${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_ESCOMPTE_FWD_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_ESCOMPTE_RAD_DSI_STD','${DFILP}/${PCH}ESFD3620_I17G_RAD_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_ESCOMPTE_RAD_LKI_INI','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_ESCOMPTE_RAD_LKI_STD','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_IFRS17_CSM','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_CSM${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_INI','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_STD','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_IFRS17_REVENUE','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_REVENUE${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_FTECLEDSII','${DFILP}/${PCH}ESFD3730_I17G_SII_ALL_STD_FTECLEDSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3730','I17G_SII_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3730','I17G_SII_ALL_STD','')

go


-------------------------------
--	Init  ESFD3630
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3630')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3630'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3630'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3630')

	insert into BEST..TI17CHN values ('ESFD3630',  'Maintenance/Acquisition expenses CSF')

		--  I17G_IEX_ALL_INI 

	insert into BEST..TI17FNC values ('I17G_IEX_ALL_INI',  'Maintenance/Acquisition expenses CSF INI')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_IGTAA0','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EPO_DLGTAAPRE','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EPO_DLDGTAAPNAE','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_FSEGPATTERN_CSF','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EPO_FCTRGRO','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'ESF_FMARKET','${DFILI}/${PCH}ESFD0060_FMARKET.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EPO_IADPERICASE','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_FULAERAT','${DFILP}/${PCH}ESPD0060_FULAERAT${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_FCLIENT_TXT','${DFILP}/${PCH}ESPT0000_FCLIENT_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EPO_DLDGTAA','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLDGTAASII${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'ESF_FEXPRAT','${DFILP}/${PCH}ESFD0060_I17G____EXPRAT_${param_Context_id}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'ESF_FEXPRAT_PREVQ','${DFILP}/${PCH}ESFD0060_I17G____EXPRAT_${param_Context_id}_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EPO_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3610_I17G_CSF_ALL_INI_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'ESF_EXPENSES','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_EXPENSES.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3630','I17G_IEX_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3630','I17G_IEX_ALL_INI','')

		--  I17G_IEX_ALL_STD 

	insert into BEST..TI17FNC values ('I17G_IEX_ALL_STD',  'Maintenance/Acquisition expenses CSF STD')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'ESF_FMARKET','${DFILI}/${PCH}ESFD0060_FMARKET.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EPO_DLGTAAPRE','${DFILP}/${PCH}ESPT0000_DLGTAAPRE.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EPO_DLDGTAAPNAE','${DFILP}/${PCH}ESPT0000_DLGTAAPNAE.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EPO_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EPO_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_FULAERAT','${DFILP}/${PCH}ESPD0060_FULAERAT${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_FSEGPATTERN_CSF','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_FCLIENT_TXT','${DFILP}/${PCH}ESPT0000_FCLIENT_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_IGTAA0','`ls ${DFILI}/${PCH}ESID1900_IGTAA0_*.dat $DFILP/empty.dat 2>/dev/null | head -1`','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'ESF_FEXPRAT','${DFILP}/${PCH}ESFD0060_I17G____EXPRAT_${param_Context_id}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'ESF_FEXPRAT_PREVQ','${DFILP}/${PCH}ESFD0060_I17G____EXPRAT_${param_Context_id}_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EPO_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESPD3610_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EPO_DLDGTAA','`case $TYPEINV0 in SO|CO)echo "$DFILP/${PCH}ESID2220_DLDGTAASII$TYPEINV0.dat";;*)echo "$DFILP/empty.dat";;esac`','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'ESF_EXPENSES','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_EXPENSES.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3630','I17G_IEX_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3630','I17G_IEX_ALL_STD','')

go


-------------------------------
--	Init  ESLD2900
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD2900')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESLD2900'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD2900'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD2900')

	insert into BEST..TI17CHN values ('ESLD2900',  '')

		--  ESLD2900 

	insert into BEST..TI17FNC values ('ESLD2900',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLSGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTRLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLSGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTAALO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLSGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTARLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD2900',  'ESL_DLREJGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD8600
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8600')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD8600'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8600'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8600')

	insert into BEST..TI17CHN values ('ESPD8600',  '')

		--  ESPD8600 

	insert into BEST..TI17FNC values ('ESPD8600',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD8600',  'EPO_FTECLEDSIICO','${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8600',  'EPO_FTECLEDSIISO','${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8600',  'EPO_GTSII_RISKMARGINCO','${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8600',  'EPO_GTSII_RISKMARGINSO','${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINSO.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID3600
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3600')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID3600'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3600'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3600')

	insert into BEST..TI17CHN values ('ESID3600',  '')

		--  ESID3600 

	insert into BEST..TI17FNC values ('ESID3600',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_IGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTAR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_IGTR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLAGTR','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLSGTR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_IGTAAF','${DFILI}/${ENV_PREFIX}_ESID0560_IGTAAF_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLAGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLAGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLREGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRPGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRTGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLSGTAA','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLSGTAR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLREGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRNPGTR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRPGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRTCGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRTFGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRTGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRNPGTAR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRTCGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLRTFGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_FPLATXCUM','${DFILI}/${ENV_PREFIX}_ESID0560_FPLATXCUM_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLREMAJGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLREMAJGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_IADPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_IRDPERICASE','${DFILI}/${ENV_PREFIX}_ESID3700_IRDPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_IRDPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRDPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLASIIGTR','${DFILI}/${ENV_PREFIX}_ESID3600_DLASIIGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLASIIGTAA','${DFILI}/${ENV_PREFIX}_ESID3600_DLASIIGTAA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3600',  'EST_DLASIIGTAR','${DFILI}/${ENV_PREFIX}_ESID3600_DLASIIGTAR_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD8700
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8700')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD8700'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8700'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8700')

	insert into BEST..TI17CHN values ('ESPD8700',  '')

		--  ESPD8700 

	insert into BEST..TI17FNC values ('ESPD8700',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD8700',  'EPO_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESPT0000_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8700',  'EPO_FTECLEDASO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8700',  'EPO_FTECLEDASO_CUR','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_CUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8700',  'EPO_FTECLEDASO_MTH','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_MTH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8700',  'EPO_FTECLEDASO_MVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_MVT.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESDJ0110
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ0110')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESDJ0110'
	delete BEST..TI17CHN  where CHAIN_CT='ESDJ0110'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ0110')

	insert into BEST..TI17CHN values ('ESDJ0110',  '')

		--  ESDJ0110 

	insert into BEST..TI17FNC values ('ESDJ0110',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FCURQUOT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FSUBSID','${DFILI}/${ENV_PREFIX}_ESDJ1010_FSUBSID_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FLIFDRI','${DFILI}/${ENV_PREFIX}_ESDJ1010_FLIFDRI${IT}_ALL_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE4_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FESB','${DFILI}/${ENV_PREFIX}_ESDJ0110_FESB_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_TCALL','${DFILI}/${ENV_PREFIX}_ESDJ0110_TCALL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_TGAPTHR','${DFILI}/${ENV_PREFIX}_ESDJ0110_TGAPTHR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FAVERATE','${DFILI}/${ENV_PREFIX}_ESDJ0110_FAVERATE_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESDJ0110_FCPLACC0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FACCTRAA0','${DFILI}/${ENV_PREFIX}_ESDJ0110_FACCTRAA0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_TGAPACCPRO','${DFILI}/${ENV_PREFIX}_ESDJ0110_TGAPACCPRO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FLIFEST0','${DFILI}/${ENV_PREFIX}_ESDJ0110_FLIFEST${IT}0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_ERRUPDBATCH','${DFILI}/${ENV_PREFIX}_ESDJ0110_ERRUPDBATCH_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FSUBTRSBASE','${DFILI}/${ENV_PREFIX}_ESDJ0110_FSUBTRSBASE_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FIDLIFEST_MVT','${DFILI}/${ENV_PREFIX}_ESDJ0110_FIDLIFEST_MVT_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_FIDLIFEST_CALL','${DFILI}/${ENV_PREFIX}_ESDJ0110_FIDLIFEST_CALL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_ESTC2040_LAST_LIFEST_O1','${DFILI}/${ENV_PREFIX}_ESDJ0110_ESTC2040_LAST_LIFEST_O1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ0110',  'EST_180_ESTC2040_OLD_LIFEST_O2','${DFILI}/${ENV_PREFIX}_ESDJ0110_180_ESTC2040_OLD_LIFEST_O2_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESRD2530
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESRD2530')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESRD2530'
	delete BEST..TI17CHN  where CHAIN_CT='ESRD2530'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESRD2530')

	insert into BEST..TI17CHN values ('ESRD2530',  '')

		--  ESRD2530 

	insert into BEST..TI17FNC values ('ESRD2530',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESRD2530',  'EST_FCESANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FCESANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD2530',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD2530',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD2530',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD2530',  'EST_FACCTRAA','${DFILP}/${ENV_PREFIX}_ESID0560_FACCTRAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD2530',  'EST_FOUTTRAA','${DFILI}/${ENV_PREFIX}_ESID0560_FOUTTRAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD2530',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD2530',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD2530',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${ICLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2040
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2040')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2040'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2040'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2040')

	insert into BEST..TI17CHN values ('ESID2040',  '')

		--  ESID2040 

	insert into BEST..TI17FNC values ('ESID2040',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_FGRP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FGRP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_FSUBSID','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBSID_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTC','${DFILI}/${ENV_PREFIX}_ESID2030_SRGTC${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_FACCPAR0','${DFILI}/${ENV_PREFIX}_ESID0060_FACCPAR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_FACMTRSH','${DFILI}/${ENV_PREFIX}_ESCJ0060_FACMTRSH_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_FBANTECL','${DFILI}/${ENV_PREFIX}_ESCJ0060_FBANTECL_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SEGRATANO','${DFILI}/${ENV_PREFIX}_ESID2070_SEGRATANO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_CPLIFDRI','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRI${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSASSO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_CRIBLEANO','${DFILI}/${ENV_PREFIX}_ESID2070_CRIBLEANO${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_FVPLACEMT','${DFILI}/${ENV_PREFIX}_ESID2070_FVPLACEMT${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_LIFENDCPT','${DFILI}/${ENV_PREFIX}_ESID2070_LIFENDCPT${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_IAVPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IAVPERICASE_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_IRVPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IRVPERICASE_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_LIFTRANSFR','${DFILI}/${ENV_PREFIX}_ESID2030_LIFTRANSFR${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_VLIFEST195','${DFILI}/${ENV_PREFIX}_ESID2030_VLIFEST195${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_LIFESTNOACC','${DFILI}/${ENV_PREFIX}_ESID2070_LIFESTNOACC${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID2070_IARVPERICASE0${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESID2070_IARVPERICASE4${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SIGNANO','${DFILI}/${ENV_PREFIX}_ESID2040_SIGNANO${IT}_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTE_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_PC${IT}_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_DLVGTR_PC','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTR_PC${IT}_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTEF_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_PC${IT}_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_CMPCALC_PC','${DFILI}/${ENV_PREFIX}_ESID2040_CMPCALC_PC${IT}_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTE_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_PA${IT}_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_DLVGTR_PA','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTR_PA${IT}_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTEF_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_PA${IT}_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTE_SRV_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PC${IT}_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTR_VENTIL','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTR_VENTIL${IT}_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_CMPCALC_PA','${DFILI}/${ENV_PREFIX}_ESID2040_CMPCALC_PA${IT}_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_DLVGTAA_PA','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAA_PA${IT}_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_DLVGTAR_PA','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAR_PA${IT}_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTEF_SRV_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PC${IT}_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_DLVGTAA_PC','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAA_PC${IT}_${ICLODAT2}_${CRE_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_DLVGTAR_PC','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAR_PC${IT}_${ICLODAT2}_${CRE_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTE_SRV_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PA${IT}_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2040',  'EST_SRGTEF_SRV_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PA${IT}_${BALSHTYEA}1231.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD8600
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD8600')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD8600'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD8600'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD8600')

	insert into BEST..TI17CHN values ('ESFD8600',  'Booking IFRS 17 cashflow and accounting files to infocenter')

		--  I17G_OMG_DW_STD 

	insert into BEST..TI17FNC values ('I17G_OMG_DW_STD',  'Booking IFRS17 to infocenter')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'EST_FTECLEDA','${DFILP}/${PCH}ESPD3800_FTECLEDA${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'EST_FTECLEDR','${DFILP}/${PCH}ESPD3800_FTECLEDR${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'EPO_FTECLEDSII','${DFILP}/${PCH}ESPD3700_FTECLEDSII${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'EST_FTECLEDASII','${DFILP}/${PCH}ESPD3800_FTECLEDASII${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'EST_FTECLEDRSII','${DFILP}/${PCH}ESPD3800_FTECLEDRSII${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'EST_FTECLEDA_ANNULMVT','${DFILP}/${PCH}ESPD3800_FTECLEDASII${TYPEINV0}_ANNULMVT.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'EST_FTECLEDR_ANNULMVT','${DFILP}/${PCH}ESPD3800_FTECLEDRSII${TYPEINV0}_ANNULMVT.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'ESF_FTECLEDA','${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDA_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'ESF_FTECLEDR','${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDR_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_DW_STD',  'ESF_FTECLEDSII','${DFILP}/${PCH}ESFD3730_I17G_SII_ALL_STD_FTECLEDSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD8600','I17G_OMG_DW_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD8600','I17G_OMG_DW_STD','')

go


-------------------------------
--	Init  DWPD0010
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='DWPD0010')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='DWPD0010'
	delete BEST..TI17CHN  where CHAIN_CT='DWPD0010'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='DWPD0010')

	insert into BEST..TI17CHN values ('DWPD0010',  '')

		--  DWPD0010 

	insert into BEST..TI17FNC values ('DWPD0010',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('DWPD0010',  'EPO_FTECLEDACO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWPD0010',  'EPO_FTECLEDASO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWPD0010',  'EPO_FTECLEDASIICO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWPD0010',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD3620
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3620')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD3620'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3620'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3620')

	insert into BEST..TI17CHN values ('ESPD3620',  'Discount calcultion job ESID3703B')

		--  ESPD3620_POCE 

	insert into BEST..TI17FNC values ('ESPD3620_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FPLC','${DFILP}/${PCH}ESPT0000_FPLC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FCLIENT','${DFILP}/${PCH}ESPT0000_FCLIENT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FSSDACTR','${DFILP}/${PCH}ESPT0000_FSSDACTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FRATINGRTO','${DFILP}/${PCH}ESPT0000_FRATINGRTO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FTECLEDSII','${DFILP}/${PCH}ESPD3700_FTECLEDSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FSEGPATTERN_BDT','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_BDT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FSEGPATTERN_DSC','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_FSEGPATTERN_ICR','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${PCH}ESPD4000_DLEIFTECLEDSIIEPCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_GTSII_ESCOMPTE_CLM','${DFILP}/${PCH}ESPD3700_GTSII_ESCOMPTE_CLM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_GTSII_REMAINTOPAY_ULAE','${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_GTSII_CASHFLOW','${DFILP}/${PCH}ESPD3610_GTSII_CASHFLOW_POCE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_DLCUMGTAAR_IBNR_FUTCLAIMS','${DFILP}/${PCH}ESPD3610_DLCUMGTAAR_IBNR_FUTCLAIMS_POCE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_GTSII_REMAINTOPAY_ULAEINF','${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_DLDSIIGTR','${DFILP}/${PCH}ESPD3620_DLDSIIGTRCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_DLDSIIGTAA','${DFILP}/${PCH}ESPD3620_DLDSIIGTAACO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_DLDSIIGTAR','${DFILP}/${PCH}ESPD3620_DLDSIIGTARCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',  'EST_DLEIFTECLEDSIIEI','${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POCE.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESPD3620','ESPD3620_POCE','POCE')

		--  ESPD3620_POSE 

	insert into BEST..TI17FNC values ('ESPD3620_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FPLC','${DFILP}/${PCH}ESPT0000_FPLC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FCLIENT','${DFILP}/${PCH}ESPT0000_FCLIENT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FSSDACTR','${DFILP}/${PCH}ESPT0000_FSSDACTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FRATINGRTO','${DFILP}/${PCH}ESPT0000_FRATINGRTO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FTECLEDSII','${DFILP}/${PCH}ESPD3700_FTECLEDSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FSEGPATTERN_BDT','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_BDT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FSEGPATTERN_DSC','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_FSEGPATTERN_ICR','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_DLEIFTECLEDSIIEP','${DFILP}/${PCH}ESPD4000_DLEIFTECLEDSIIEPSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_GTSII_ESCOMPTE_CLM','${DFILP}/${PCH}ESPD3700_GTSII_ESCOMPTE_CLM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_GTSII_REMAINTOPAY_ULAE','${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_GTSII_CASHFLOW','${DFILP}/${PCH}ESPD3610_GTSII_CASHFLOW_POSE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_DLCUMGTAAR_IBNR_FUTCLAIMS','${DFILP}/${PCH}ESPD3610_DLCUMGTAAR_IBNR_FUTCLAIMS_POSE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_GTSII_REMAINTOPAY_ULAEINF','${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_DLDSIIGTR','${DFILP}/${PCH}ESPD3620_DLDSIIGTRSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_DLDSIIGTAA','${DFILP}/${PCH}ESPD3620_DLDSIIGTAASO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_DLDSIIGTAR','${DFILP}/${PCH}ESPD3620_DLDSIIGTARSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',  'EST_DLEIFTECLEDSIIEI','${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POSE.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESPD3620','ESPD3620_POSE','POSE')

go


-------------------------------
--	Init  ESID2800
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2800')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2800'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2800'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2800')

	insert into BEST..TI17CHN values ('ESID2800',  '')

		--  ESID2800 

	insert into BEST..TI17FNC values ('ESID2800',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_TOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_TOTGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_DLREJGTAA','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_DLREJGTAR','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTAR_${ICLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESEH1200
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESEH1200')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESEH1200'
	delete BEST..TI17CHN  where CHAIN_CT='ESEH1200'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESEH1200')

	insert into BEST..TI17CHN values ('ESEH1200',  '')

		--  ESEH1200 

	insert into BEST..TI17FNC values ('ESEH1200',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCESANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FCESANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FPLCANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FPLCANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FAPR0','${DFILI}/${ENV_PREFIX}_ESEH1110_FAPR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FAMPROT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FAMPROT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FBSEGEST','${DFILP}/${ENV_PREFIX}_ESEH1110_FBSEGEST_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCTRGRO0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCTRULT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRULT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FSOBBLOB','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSOBBLOB_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FUNDSTA0','${DFILI}/${ENV_PREFIX}_ESEH1110_FUNDSTA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FCESSION0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCESSION0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FPLACEMT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_IADPERIFCT0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERIFCT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_IADPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1200',  'EST_FULTIMATES','${DFILI}/${ENV_PREFIX}_ESEH1200_FULTIMATES_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD3640
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3640')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD3640'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3640'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3640')

	insert into BEST..TI17CHN values ('ESPD3640',  'Risk Marging calculation job ESPD3602A')

		--  ESPD3640_POCE 

	insert into BEST..TI17FNC values ('ESPD3640_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3640_POCE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POCE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POCE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POCE',  'EST_FRISKMSII','${DFILP}/${PCH}ESPD0060_FRISKMSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POCE',  'EST_DLDSIIGTAA','${DFILP}/${PCH}ESPD3620_DLDSIIGTAACO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POCE',  'EST_FCTRGROLESII','${DFILP}/${PCH}ESPT0000_FCTRGROLESII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POCE',  'EST_GTSII_RISKMARGIN','${DFILP}/${PCH}ESPD3700_GTSII_RISKMARGINCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POCE',  'EST_GTSII_ESCOMPTE_CLM','${DFILP}/${PCH}ESPD3700_GTSII_ESCOMPTE_CLM.dat','I','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESPD3640','ESPD3640_POCE','POCE')

		--  ESPD3640_POSE 

	insert into BEST..TI17FNC values ('ESPD3640_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3640_POSE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POSE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POSE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POSE',  'EST_FRISKMSII','${DFILP}/${PCH}ESPD0060_FRISKMSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POSE',  'EST_DLDSIIGTAA','${DFILP}/${PCH}ESPD3620_DLDSIIGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POSE',  'EST_FCTRGROLESII','${DFILP}/${PCH}ESPT0000_FCTRGROLESII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POSE',  'EST_GTSII_RISKMARGIN','${DFILP}/${PCH}ESPD3700_GTSII_RISKMARGINSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3640_POSE',  'EST_GTSII_ESCOMPTE_CLM','${DFILP}/${PCH}ESPD3700_GTSII_ESCOMPTE_CLM.dat','I','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESPD3640','ESPD3640_POSE','POSE')

go


-------------------------------
--	Init  ESFD3740
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3740')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3740'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3740'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3740')

	insert into BEST..TI17CHN values ('ESFD3740',  'Calculation Paid')

		--  I17G_SII_GLT_STD 

	insert into BEST..TI17FNC values ('I17G_SII_GLT_STD',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_IADPERICASE_INI','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_FSECIFRS','${DFILP}/${PCH}ESFD3720_I17G_CSM_CRE_INI_FSECIFRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_IFRS17_CSM_ESCOMPTE','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_ESCOMPTE_UWD_STD','${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_UNWIND_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_ESCOMPTE_DSI_STD','${DFILP}/${PCH}ESFD3620_I17G_DSC_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_ESCOMPTE_LKI_INI','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_ESCOMPTE_LKI_STD','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_CASHFLOW_RAD_CKI_INI','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_INI_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_CASHFLOW_RAD_CKI_STD','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_CASHFLOW_RAD_CUR_STD','${DFILP}/${PCH}ESFD3650_I17G_RAD_CUR_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_ESCOMPTE_FWD_STD','${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_ESCOMPTE_FWD_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_ESCOMPTE_RAD_DSI_STD','${DFILP}/${PCH}ESFD3620_I17G_RAD_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_ESCOMPTE_RAD_LKI_INI','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_ESCOMPTE_RAD_LKI_STD','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_IFRS17_CSM','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_CSM${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_INI','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_STD','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_IFRS17_REVENUE','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_REVENUE${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_PREV','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_GTSII_GLOBAL_CASHFLOW_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_FTECLEDA','${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDA_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_FTECLEDR','${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDR_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_SII_GLT_STD',  'ESF_GTSII_MAINT_EXPENSES_PAID','${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_MAINTENANCE_EXPENSES_PAID_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3740','I17G_SII_GLT_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3740','I17G_SII_GLT_STD','')

go


-------------------------------
--	Init  ESPD3850
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3850')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD3850'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3850'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3850')

	insert into BEST..TI17CHN values ('ESPD3850',  '')

		--  ESPD3850 

	insert into BEST..TI17FNC values ('ESPD3850',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3850',  'EPO_FTECLEDACO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3850',  'EPO_FTECLEDRCO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3850',  'EPO_FTECLEDASIICO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3850',  'EPO_FTECLEDRSIICO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3850',  'EPO_FTECLEDASO_MVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_MVT.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3620
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3620')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3620'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3620'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3620')

	insert into BEST..TI17CHN values ('ESFD3620',  'Discount at lock in rate')

		--  I17G_DSC_LKI_STD 

	insert into BEST..TI17FNC values ('I17G_DSC_LKI_STD',  'RA Discount Forward Calculation  current rate')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_STD',  'EPO_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${PCH}ESFD1130_TRERETFACCTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_STD',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_STD',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_STD',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_STD_GTSII_ESCOMPTE_RMNTP.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_DSC_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_DSC_LKI_STD','')

		--  I17G_RAD_LKI_STD 

	insert into BEST..TI17FNC values ('I17G_RAD_LKI_STD',  'RA Discount risk adjustement lock in rate')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_STD',  'EPO_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_STD',  'ESF_TRERETFACCTR','${DFILP}/${PCH}ESFD1130_TRERETFACCTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_STD',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_STD',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_STD',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_RMNTP.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_RAD_LKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_RAD_LKI_STD','')

		--  I17G_RAD_LKI_INI 

	insert into BEST..TI17FNC values ('I17G_RAD_LKI_INI',  'RA Discount risk adjustement at inception')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_INI',  'EPO_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${PCH}ESFD1130_FRERETFACCTR_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_INI',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_INI_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_INI_GTSII_ESCOMPTE_RMNTP.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_RAD_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_RAD_LKI_INI','')

		--  I17G_DSC_DSI_STD 

	insert into BEST..TI17FNC values ('I17G_DSC_DSI_STD',  'RA Discount Forward Calculation  current rate')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_DSC_DSI_STD',  'EPO_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${PCH}ESFD1130_TRERETFACCTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_DSI_STD',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_DSI_STD',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_DSI_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_DSI_STD',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${PCH}ESFD3620_I17G_DSC_DSI_STD_GTSII_ESCOMPTE_RMNTP.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_DSI_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_DSC_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_DSC_DSI_STD','')

		--  I17G_RAD_DSI_STD 

	insert into BEST..TI17FNC values ('I17G_RAD_DSI_STD',  'RA Discount risk adjustement current rate')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_RAD_DSI_STD',  'EPO_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_DSI_STD',  'ESF_TRERETFACCTR','${DFILP}/${PCH}ESFD1130_TRERETFACCTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_DSI_STD',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_DSI_STD',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_DSI_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3650_I17G_RAD_CUR_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_DSI_STD',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${PCH}ESFD3620_I17G_RAD_DSI_STD_GTSII_ESCOMPTE_RMNTP.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_DSI_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_RAD_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_RAD_DSI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_RAD_DSI_STD','')

		--  I17G_DSC_LKI_INI 

	insert into BEST..TI17FNC values ('I17G_DSC_LKI_INI',  'RA Discount Calculation at inception')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_INI',  'EPO_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_INI',  'ESF_TRERETFACCTR','${DFILP}/${PCH}ESFD1130_FRERETFACCTR_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_INI',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_LKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3620','I17G_DSC_LKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3620','I17G_DSC_LKI_INI','')

go


-------------------------------
--	Init  ESID2530
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2530')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2530'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2530'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2530')

	insert into BEST..TI17CHN values ('ESID2530',  '')

		--  ESID2530 

	insert into BEST..TI17FNC values ('ESID2530',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCESANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FCESANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FPLCANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FPLCANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_TOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_TOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_TOTGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FACCTRAA','${DFILP}/${ENV_PREFIX}_ESID0560_FACCTRAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FACCTRAI','${DFILP}/${ENV_PREFIX}_ESID0560_FACCTRAI_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCMUSPLI','${DFILP}/${ENV_PREFIX}_ESID0560_FCMUSPLI_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FOUTTRAA','${DFILI}/${ENV_PREFIX}_ESID0560_FOUTTRAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FCMUSPLIT','${DFILP}/${ENV_PREFIX}_ESID0560_FCMUSPLIT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_FRAPP','${DFILI}/${ENV_PREFIX}_ESID2530_FRAPP_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD8830
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8830')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD8830'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8830'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8830')

	insert into BEST..TI17CHN values ('ESPD8830',  '')

		--  ESPD8830 

	insert into BEST..TI17FNC values ('ESPD8830',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_FPLC','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_GTEP','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEP.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_GTEPSO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EST_STATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EST_STATGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLEIGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLEIGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLSGTRSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESPT0000_FTECLEDR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLRGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLSGTAASO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLSGTARSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_GTEPSIISO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREJGTRSO','${DFILI}/${ENV_PREFIX}_ESPD2900_DLREJGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_FTECLEDASO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_FTECLEDRSO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EST_ARCSTATGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLASIIGTRSO','${DFILP}/${ENV_PREFIX}_ESPD3630_DLASIIGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLDSIIGTRSO','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREJGTAASO','${DFILI}/${ENV_PREFIX}_ESPD2900_DLREJGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREJGTARSO','${DFILI}/${ENV_PREFIX}_ESPD2900_DLREJGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLSGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_CRVPERICASE0','${DFILP}/${ENV_PREFIX}_ESPT0000_CRVPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREMAJGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLRGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREJGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREJGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREJGTARSIISO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTARSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_FTECLEDASO_CUR','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_CUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLREMAJGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_DLEIFTECLEDSIIEP','${DFILP}/${ENV_PREFIX}_ESPD4000_DLEIFTECLEDSIIEPSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8830',  'EPO_GTRANO','${DFILI}/${ENV_PREFIX}_ESPD8830_GTRANO.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESIJ1000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESIJ1000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESIJ1000'
	delete BEST..TI17CHN  where CHAIN_CT='ESIJ1000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESIJ1000')

	insert into BEST..TI17CHN values ('ESIJ1000',  '')

		--  ESIJ1000 

	insert into BEST..TI17FNC values ('ESIJ1000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESIJ1000',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ1000',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID0120
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0120')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID0120'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0120'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0120')

	insert into BEST..TI17CHN values ('ESID0120',  '')

		--  ESID0120 

	insert into BEST..TI17FNC values ('ESID0120',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID0120',  'EST_FLIFESTQ0','${DFILI}/${ENV_PREFIX}_ESID0120_FLIFESTQ0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0120',  'EST_FLIFESTY1','${DFILI}/${ENV_PREFIX}_ESID0120_FLIFESTY1_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID1500
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1500')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID1500'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1500'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1500')

	insert into BEST..TI17CHN values ('ESID1500',  '')

		--  ESID1500 

	insert into BEST..TI17FNC values ('ESID1500',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_IRDPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRDPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_IRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_ORDPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_ORDPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_ORVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_ORVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_IRDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_IRDVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1500',  'EST_ORDVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1500_ORDVPERICASE0_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPJ0090
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPJ0090')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPJ0090'
	delete BEST..TI17CHN  where CHAIN_CT='ESPJ0090'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPJ0090')

	insert into BEST..TI17CHN values ('ESPJ0090',  '')

		--  ESPJ0090 

	insert into BEST..TI17FNC values ('ESPJ0090',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPJ0090',  'EPO_FCES','${DFILP}/${ENV_PREFIX}_ESPT0000_FCES.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPJ0090',  'EPO_FPLC','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPJ0090',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPJ0090',  'EPO_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSN.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPJ0090',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPJ0090',  'EPO_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSNI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPJ0090',  'EPO_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRANSCODE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPJ0090',  'EPO_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_IADVPERICASE.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESDJ7000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ7000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESDJ7000'
	delete BEST..TI17CHN  where CHAIN_CT='ESDJ7000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ7000')

	insert into BEST..TI17CHN values ('ESDJ7000',  '')

		--  ESDJ7000 

	insert into BEST..TI17FNC values ('ESDJ7000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_FDRYTRN_ID','${DFILI}/${ENV_PREFIX}_ESIX7000_FDRYTRN.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_TCALL','${DFILI}/${ENV_PREFIX}_ESDJ0110_TCALL_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_ARCSTATGTA_ID','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IAVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_IRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IRVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESDJ7000_GTA_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_GTA_ID','${DFILP}/${ENV_PREFIX}_ESDJ7000_GTA_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_GTR_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_GTR_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_GTASW_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_GTASW_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_GTRSW_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_GTRSW_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_STATGTA','${DFILP}/${ENV_PREFIX}_ESDJ7000_STATGTA_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_CURGTA_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_CURGTA_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_IGTR00_ID','${DFILP}/${ENV_PREFIX}_ESDJ7000_IGTR00_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_FRTOSTA_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_FRTOSTA_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_IGTAA00_ID','${DFILP}/${ENV_PREFIX}_ESDJ7000_IGTAA00_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_STATGTA_ID','${DFILP}/${ENV_PREFIX}_ESDJ7000_STATGTA_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_STATGTR_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_STATGTR_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_FACCTRTGT_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_FACCTRTGT_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_DTSTATGTAA0_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_DTSTATGTAA0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_VTSTATGTA0_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_VTSTATGTA0_ID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7000',  'EST_TSTATGTAANO_ID','${DFILI}/${ENV_PREFIX}_ESDJ7000_TSTATGTAANO_ID_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD0060
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD0060')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD0060'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD0060'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD0060')

	insert into BEST..TI17CHN values ('ESFD0060',  'Data extraction')

		--  I17G___ 

	insert into BEST..TI17FNC values ('I17G___',  'Get data IFRS 17 GROUP')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FMARKET','${DFILI}/${PCH}ESFD0060_FMARKET.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FUWRETSEC','${DFILP}/${PCH}ESFD0060_FUWRETSEC.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FLOARAT_I17G','${DFILP}/${PCH}ESFD0060_I17G____FLOARAT.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FUOASII','${DFILI}/${ENV_PREFIX}_ESFD0060_I17G___TUOASII_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FRARAT','${DFILP}/${PCH}ESFD0060_I17G____RARAT_${param_Context_id}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G___',  'ESF_FEXPRAT','${DFILP}/${PCH}ESFD0060_I17G____EXPRAT_${param_Context_id}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD0060','I17G___','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD0060','I17G___','')

go


-------------------------------
--	Init  STAD1550
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD1550')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='STAD1550'
	delete BEST..TI17CHN  where CHAIN_CT='STAD1550'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD1550')

	insert into BEST..TI17CHN values ('STAD1550',  '')

		--  STAD1550 

	insert into BEST..TI17FNC values ('STAD1550',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('STAD1550',  'STA_LIFINVDIF','${DFILP}/${ENV_PREFIX}_STAD1530_LIFINVDIF.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1550',  'STA_LIFSTADIF','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTADIF.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1550',  'STA_LIFSTAREP','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1550',  'EST_FLIFPLN2','${DFILI}/${ENV_PREFIX}_ESID1520_EST_FLIFPLN2_${ICLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID3850
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3850')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID3850'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3850'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3850')

	insert into BEST..TI17CHN values ('ESID3850',  '')

		--  ESID3850 

	insert into BEST..TI17FNC values ('ESID3850',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID3850',  'EST_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MVT.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD0060
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD0060')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD0060'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD0060'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD0060')

	insert into BEST..TI17CHN values ('ESPD0060',  '')

		--  ESPD0060 

	insert into BEST..TI17FNC values ('ESPD0060',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FULTIMATES','${DFILP}/${ENV_PREFIX}_ESPT0000_FULTIMATES.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FSEGEST_SOLVENCY','${DFILP}/${ENV_PREFIX}_ESPT0000_FSEGEST_SOLVENCY.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_EPOCONS','${DFILI}/${ENV_PREFIX}_ESPD0060_EPOCONS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_EPOSOCI','${DFILI}/${ENV_PREFIX}_ESPD0060_EPOSOCI.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRFWH','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRFWH.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_EPOSIICO','${DFILI}/${ENV_PREFIX}_ESPD0060_EPOSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_EPOSIISO','${DFILI}/${ENV_PREFIX}_ESPD0060_EPOSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FTRSLNK8','${DFILP}/${ENV_PREFIX}_ESPD0060_FTRSLNK8.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRESTCO','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRESTSO','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FPLACEMT22','${DFILI}/${ENV_PREFIX}_ESPD0060_FPLACEMT22.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FULAERATCO','${DFILP}/${ENV_PREFIX}_ESPD0060_FULAERATCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FULAERATSO','${DFILP}/${ENV_PREFIX}_ESPD0060_FULAERATSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FRISKMSIICO','${DFILP}/${ENV_PREFIX}_ESPD0060_FRISKMSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FRISKMSIISO','${DFILP}/${ENV_PREFIX}_ESPD0060_FRISKMSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTREST0_EBS','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0_EBS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRESTSIICO','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRESTSIISO','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTREST0_IFRS','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0_IFRS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRESTASIICO','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRESTASIISO','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FSEGPATTERNFWH','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERNFWH.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FSEGPATTERN_BDT','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_BDT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FSEGPATTERN_CSF','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FSEGPATTERN_DSC','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FSEGPATTERN_ICR','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_ICR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FSEGPATTERN_INF','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_INF.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FULTIMATESSIICO','${DFILP}/${ENV_PREFIX}_ESPD0060_FULTIMATESSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FULTIMATESSIISO','${DFILP}/${ENV_PREFIX}_ESPD0060_FULTIMATESSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FSEGEST_SOLVENCYCO','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FSEGEST_SOLVENCYSO','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_RETITDPRM_UPR_ACTCO','${DFILP}/${ENV_PREFIX}_ESPD0060_RETITDPRM_UPR_ACTCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_RETITDPRM_UPR_ACTSO','${DFILP}/${ENV_PREFIX}_ESPD0060_RETITDPRM_UPR_ACTSO.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  STPD1500
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STPD1500')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='STPD1500'
	delete BEST..TI17CHN  where CHAIN_CT='STPD1500'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STPD1500')

	insert into BEST..TI17CHN values ('STPD1500',  '')

		--  STPD1500 

	insert into BEST..TI17FNC values ('STPD1500',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_SUBTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FSUBTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_CPLIFDRI','${DFILP}/${ENV_PREFIX}_ESPT0000_CPLIFDRI.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_ECRSOCAPC','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCAPC.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_ECRSOCRPC','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCRPC.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_FVPLACEMT','${DFILP}/${ENV_PREFIX}_ESPT0000_FVPLACEMT.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_LIFSTAREP','${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_ECRSOCACBP','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCACBP.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_ECRSOCRCBP','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCRCBP.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_LIFSTAREP_AS','${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP_AS.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESPT0000_IARVPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'STA_LIFSTAREP_BILANPREC','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_BILANPREC.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'STA_LIFSTAREP_CBP_RETRO','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP_CBP_RETRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1500',  'EPO_LIFSTAREP_BRIDG','${DFILP}/${ENV_PREFIX}_STPD1500_LIFSTAREP_BRIDG.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2030
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2030')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2030'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2030'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2030')

	insert into BEST..TI17CHN values ('ESID2030',  '')

		--  ESID2030 

	insert into BEST..TI17FNC values ('ESID2030',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_LIFEP','${DFILP}/${ENV_PREFIX}_ESCJ0060_LIFEP.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FFAMCNA','${DFILI}/${ENV_PREFIX}_ESID0060_FFAMCNA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_TACCPAR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTACCPAR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FACCPAR0','${DFILI}/${ENV_PREFIX}_ESID0060_FACCPAR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSASSO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_SUBTRSBASE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSBASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FTRSLNKVRET','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNKVRET_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FVPLACEMT','${DFILI}/${ENV_PREFIX}_ESID2070_FVPLACEMT${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_LIFENDCPT','${DFILI}/${ENV_PREFIX}_ESID2070_LIFENDCPT${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_LIFESTLIB','${DFILI}/${ENV_PREFIX}_ESID2070_LIFESTLIB${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_IRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FVPLACEMT2','${DFILI}/${ENV_PREFIX}_ESID2070_FVPLACEMT2${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_LIFESTNOACC','${DFILI}/${ENV_PREFIX}_ESID2070_LIFESTNOACC${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_VLIFEST2070','${DFILI}/${ENV_PREFIX}_ESID2070_VLIFEST2070${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_FTRANSCODEVRET','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODEVRET_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_310_SORT_GT_O','${DFILI}/${ENV_PREFIX}_ESID2070_310_SORT_GT${IT}_O_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_430_SORT_GT_O','${DFILI}/${ENV_PREFIX}_ESID2070_430_SORT_GT${IT}_O_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_470_SORT_GT_O','${DFILI}/${ENV_PREFIX}_ESID2070_470_SORT_GT${IT}_O_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID2070_IARVPERICASE0${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESID2070_IARVPERICASE4${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_IAVPERICASE0_ADDI','${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_ADDI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_160_SORT_CPLACC_O','${DFILI}/${ENV_PREFIX}_ESID2070_160_SORT_CPLACC${IT}_O_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_180_SORT_LSTMTH_O','${DFILI}/${ENV_PREFIX}_ESID2070_180_SORT_LSTMTH${IT}_O_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_ESTC2035_LIFDRI_O1','${DFILI}/${ENV_PREFIX}_ESID2070_ESTC2035_LIFDRI${IT}_O1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_200_ESTC2034_GTB1_O','${DFILI}/${ENV_PREFIX}_ESID2070_200_ESTC2034_GTB1${IT}_O_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_180_ESTC2040_OLD_LIFEST_O2','${DFILI}/${ENV_PREFIX}_ESID2070_180_ESTC2040_OLD_LIFEST${IT}_O2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_SRGTC','${DFILI}/${ENV_PREFIX}_ESID2030_SRGTC${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_SRGTCB1','${DFILI}/${ENV_PREFIX}_ESID2030_SRGTCB1${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_CPLIFDRI','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRI${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_CPLIFEST','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFEST${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_DLRLIFEI','${DFILI}/${ENV_PREFIX}_ESID2030_DLRLIFEI${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_DLRLIFEP','${DFILI}/${ENV_PREFIX}_ESID2030_DLRLIFEP${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_CPLIFDRIN','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRIN${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_LIFTRANSFR','${DFILI}/${ENV_PREFIX}_ESID2030_LIFTRANSFR${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_VLIFEST195','${DFILI}/${ENV_PREFIX}_ESID2030_VLIFEST195${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_CPLIFDRIASC','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRIASC${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_CPLIFEST_MVT','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFEST_MVT${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_VLIFEST_AUTOSEG','${DFILI}/${ENV_PREFIX}_ESID2030_VLIFEST_AUTOSEG${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_IARVPERICASE4_AUTOSEG','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE4_AUTOSEG${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_ESTC2040_LAST_LIFEST_O1','/scor/scordata/ubeu/temporaire/${ENV_PREFIX}_ESID2030_ESTC2040_LAST_LIFEST_O1${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_75_ESTC2035_END_LIFEST_O5','/scor/scordata/ubeu/temporaire/${ENV_PREFIX}_ESID2030_75_ESTC2035_END_LIFEST_O5${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2030',  'EST_205_ESTC2040_OLD_LIFEST_O2','/scor/scordata/ubeu/temporaire/${ENV_PREFIX}_ESID2030_205_ESTC2040_OLD_LIFEST_O2${IT}_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID8050
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8050')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8050'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8050'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8050')

	insert into BEST..TI17CHN values ('ESID8050',  '')

		--  ESID8050 

	insert into BEST..TI17FNC values ('ESID8050',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_NPSAIS','${DFILI}/${ENV_PREFIX}_ESID2000_NPSAIS_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_IBNR_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_IBNR_EBS_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_PNARETRO','${DFILI}/${ENV_PREFIX}_ESID0060_PNARETRO_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_IBNR_IFRS','${DFILI}/${ENV_PREFIX}_ESID2000_IBNR_IFRS_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_FUTURE_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_FUTURE_EBS_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8050',  'EST_BLANCHIMENT_RPCC','${DFILI}/${ENV_PREFIX}_ESID2000_BLANCHIMENT_RPCC_${ICLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID7550
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID7550')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID7550'
	delete BEST..TI17CHN  where CHAIN_CT='ESID7550'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID7550')

	insert into BEST..TI17CHN values ('ESID7550',  '')

		--  ESID7550 

	insert into BEST..TI17FNC values ('ESID7550',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID7550',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID7000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID7000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID7000'
	delete BEST..TI17CHN  where CHAIN_CT='ESID7000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID7000')

	insert into BEST..TI17CHN values ('ESID7000',  '')

		--  ESID7000 

	insert into BEST..TI17FNC values ('ESID7000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_GTACTL','${DFILP}/${ENV_PREFIX}_ESIX7000_GTACTL.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_GTRANO','${DFILI}/${ENV_PREFIX}_ESIX7000_GTRANO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FCESANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FCESANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FPLCANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FPLCANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_STATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_STATGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_CURGTACTL','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTACTL.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_IGTA','${DFILI}/${ENV_PREFIX}_ESID7050_IGTA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_IGTR','${DFILI}/${ENV_PREFIX}_ESID7050_IGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_ARCSTATGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FVENTNPANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FVENTNPANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_STATGTACTL','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTACTL.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FCLIENT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCLIENT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FTECLEDA_MTH','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MTH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MVT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_DLREJGTR','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_DLTOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_DLTOTGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FSOBBLOB','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSOBBLOB_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FTVENTNP','${DFILP}/${ENV_PREFIX}_ESID0060_FTVENTNP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_DLREJGTAA','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_DLREJGTAR','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTAR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_DLTOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_DLTOTGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_DLTOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_DLTOTGTAR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FPLACEMT2','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FPLATXCUM','${DFILI}/${ENV_PREFIX}_ESID0560_FPLATXCUM_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_VENTNP_TRIMCUR','${DFILP}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMCUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_VENTNP_TRIMPREV','${DFILP}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMPREV.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_FTVENTNPHIS','${DFILI}/${ENV_PREFIX}_ESID0060_FTVENTNPHIS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_CRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_CRVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FCES','${DFILP}/${ENV_PREFIX}_ESID7000_FCES.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FPLC','${DFILP}/${ENV_PREFIX}_ESID7000_FPLC.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FCLIENT','${DFILP}/${ENV_PREFIX}_ESID7000_FCLIENT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID7000_FCPLACC.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID7000_FCTRGRO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FSUBTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FSUBTRS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESID7000_FTRSLNK.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSN.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESID7000_FCURQUOT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FSOBBLOB','${DFILP}/${ENV_PREFIX}_ESID7000_FSOBBLOB.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESID7000_FSSDACTR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSNI.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FPLACEMT2','${DFILP}/${ENV_PREFIX}_ESID7000_FPLACEMT2.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESID7000_FPLATXCUM.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESID7000_FTRANSCODE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_CRVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID7000_CRVPERICASE0.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_IADVPERICASE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_OIADVPERICASE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'ESL_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_OIRDVPERICASE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_ARCCURGTA','${DFILP}/${ENV_PREFIX}_ESID7000_ARCCURGTA_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_ARCCURGTR','${DFILP}/${ENV_PREFIX}_ESID7000_ARCCURGTR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_DLTOTGTRC','${DFILI}/${ENV_PREFIX}_ESID7000_DLTOTGTRC_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_DLTOTGTAAC','${DFILI}/${ENV_PREFIX}_ESID7000_DLTOTGTAAC_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_DLTOTGTARC','${DFILI}/${ENV_PREFIX}_ESID7000_DLTOTGTARC_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7000',  'EST_ANOBALSHEYGT','${DFILI}/${ENV_PREFIX}_ESID7000_ANOBALSHEYGT_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID0560
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0560')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID0560'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0560'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0560')

	insert into BEST..TI17CHN values ('ESID0560',  '')

		--  ESID0560 

	insert into BEST..TI17FNC values ('ESID0560',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESCJ0060_GTEP.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FAPR0','${DFILI}/${ENV_PREFIX}_ESEH1110_FAPR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FSNEMHIST0','${DFILP}/${ENV_PREFIX}_ESID3800_FSNEMHIST0.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IGTR0','${DFILI}/${ENV_PREFIX}_ESID1900_IGTR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IGTAA0','${DFILI}/${ENV_PREFIX}_ESID1900_IGTAA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IGTAR0','${DFILI}/${ENV_PREFIX}_ESID1900_IGTAR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_DLAGTR0','${DFILI}/${ENV_PREFIX}_ESID1900_DLAGTR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_MVTPNA0','${DFILI}/${ENV_PREFIX}_ESID0070_MVTPNA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_DLAGTAA0','${DFILI}/${ENV_PREFIX}_ESID1900_DLAGTAA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_DLAGTAR0','${DFILI}/${ENV_PREFIX}_ESID1900_DLAGTAR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FACCSUP0','${DFILI}/${ENV_PREFIX}_ESID0060_FACCSUP0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FAMPROT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FAMPROT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCTREST0','${DFILI}/${ENV_PREFIX}_ESID0060_FCTREST0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCTRGRO0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCTRULT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRULT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FLABOCY0','${DFILI}/${ENV_PREFIX}_ESID0060_FLABOCY0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FLIFPLN0','${DFILI}/${ENV_PREFIX}_ESID0060_FLIFPLN0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FSEGEST0','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGEST0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FACCSUP12','${DFILI}/${ENV_PREFIX}_ESID0060_FACCSUP12_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FACCTRAA0','${DFILI}/${ENV_PREFIX}_ESID0110_FACCTRAA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FACCTRAI0','${DFILI}/${ENV_PREFIX}_ESID0060_FACCTRAI0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCESSION0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCESSION0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCMUSPLI0','${DFILI}/${ENV_PREFIX}_ESID0060_FCMUSPLI0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FOUTTRAA0','${DFILI}/${ENV_PREFIX}_ESID0060_FOUTTRAA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FOUTTRAI0','${DFILI}/${ENV_PREFIX}_ESID0060_FOUTTRAI0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLACEMT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCMUSPLIT0','${DFILI}/${ENV_PREFIX}_ESID0060_FCMUSPLIT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLATXCUM0','${DFILI}/${ENV_PREFIX}_ESID0060_FPLATXCUM0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FTHRHLDUWY','${DFILI}/${ENV_PREFIX}_ESID0060_FTHRHLDUWY_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERIFR0','${DFILI}/${ENV_PREFIX}_ESID0060_IADPERIFR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_DTSTATGTAA0','${DFILI}/${ENV_PREFIX}_ESID1010_DTSTATGTAA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERIFCI0','${DFILI}/${ENV_PREFIX}_ESID0060_IADPERIFCI0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERIFCT0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERIFCT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLACEMTCOM0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMTCOM0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERIPRMD0','${DFILI}/${ENV_PREFIX}_ESID0060_IADPERIPRMD0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLATXCUMALL0','${DFILI}/${ENV_PREFIX}_ESID0060_FPLATXCUMALL0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IRDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_IRDVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_OADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_OADVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_ORDVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1500_ORDVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FSEGEST_SOLVENCY0','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGEST_SOLVENCY0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADVPERICASE_ENTIER0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE_ENTIER0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTAR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FAPR','${DFILP}/${ENV_PREFIX}_ESID0560_FAPR_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IGTR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTR_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_DLAGTR','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTR_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IGTAAF','${DFILI}/${ENV_PREFIX}_ESID0560_IGTAAF_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_MVTPNA','${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNA_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLCCOM','${DFILP}/${ENV_PREFIX}_ESID25000_FPLCCOM_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_DLAGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAA_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_DLAGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAR_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FACCSUP','${DFILI}/${ENV_PREFIX}_ESID0560_FACCSUP_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FAMPROT','${DFILP}/${ENV_PREFIX}_ESID0560_FAMPROT_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCTREST','${DFILI}/${ENV_PREFIX}_ESID0560_FCTREST_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCTRULT','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRULT_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FLABOCY','${DFILI}/${ENV_PREFIX}_ESID0560_FLABOCY_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FLIFPLN','${DFILI}/${ENV_PREFIX}_ESID0560_FLIFPLN_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FSEGEST','${DFILI}/${ENV_PREFIX}_ESID0560_FSEGEST_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_MVTPNAC','${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNAC_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_DLRIGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_DLRIGTAA_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FACCSUPF','${DFILI}/${ENV_PREFIX}_ESID0560_FACCSUPF_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FACCTRAA','${DFILP}/${ENV_PREFIX}_ESID0560_FACCTRAA_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FACCTRAI','${DFILP}/${ENV_PREFIX}_ESID0560_FACCTRAI_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCESSION','${DFILI}/${ENV_PREFIX}_ESID0560_FCESSION_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCES_NEW','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_NEW_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCMUSPLI','${DFILP}/${ENV_PREFIX}_ESID0560_FCMUSPLI_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCTRESTA','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FOUTTRAA','${DFILI}/${ENV_PREFIX}_ESID0560_FOUTTRAA_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FOUTTRAI','${DFILI}/${ENV_PREFIX}_ESID0560_FOUTTRAI_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLACEMT','${DFILI}/${ENV_PREFIX}_ESID0560_FPLACEMT_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCMUSPLIT','${DFILP}/${ENV_PREFIX}_ESID0560_FCMUSPLIT_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCTRGROBO','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRGROBO_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLATXCUM','${DFILI}/${ENV_PREFIX}_ESID0560_FPLATXCUM_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FSNEMHIST','${DFILP}/${ENV_PREFIX}_ESID0560_FSNEMHIST_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERIFR','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFR_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_DTSTATGTAA','${DFILI}/${ENV_PREFIX}_ESID0560_DTSTATGTAA_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERIFCI','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCI_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERIFCT','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCT_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLACEMTCOM','${DFILI}/${ENV_PREFIX}_ESID0560_FPLACEMTCOM_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADPERIPRMD','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIPRMD_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IAVPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IAVPERICASE_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IRVPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IRVPERICASE_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLATXCUMALL','${DFILI}/${ENV_PREFIX}_ESID0560_FPLATXCUMALL_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IRDVPERICASE_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_OADVPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_OADVPERICASE_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_ORDVPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_ORDVPERICASE_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FSEGEST_SOLVENCY','${DFILI}/${ENV_PREFIX}_ESID0560_FSEGEST_SOLVENCY_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_IADVPERICASE_ENTIER','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_ENTIER_${ICLODAT2}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3750
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3750')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3750'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3750'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3750')

	insert into BEST..TI17CHN values ('ESFD3750',  'IFRS17 - CSM at closing assessment')

		--  I17G_CSM_ALL_STD 

	insert into BEST..TI17FNC values ('I17G_CSM_ALL_STD',  'IFRS17 - CSM at closing assessment')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_TRERETFACCTR','${DFILP}/${PCH}ESFD1130_TRERETFACCTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'EST_FSEGPATTERN_DSC_f17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'EST_IADPERICASE_STD','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_STD.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_CSESF_GTSII_CSMM','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_FSEGPROF_INI','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSEGPROF_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_FSEGPROF_STD_PREVIOUS','${DFILP}/${PCH}ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_ESCOMPTE_FWD','${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_ESCOMPTE_FWD_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_IFRS17_CSM','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_CSM${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_CSM_LC_AMORT_PATTERN','${DFILP}/${ENV_PREFIX}_ESFD3770_I17G_CSM_AMR_STD_CSM_LC_AMORT_PATTERN_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_CSM_CASHFLOW_PREV','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_GTSII_CSM_CASHFLOW_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_CSM_LC_AMORT_PATTERN_PREV','${DFILP}/${ENV_PREFIX}_ESFD3770_I17G_CSM_AMR_STD_CSM_LC_AMORT_PATTERN_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD',  'ESF_GTSII_CSM_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_GTSII_CSM_CASHFLOW_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3750','I17G_CSM_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3750','I17G_CSM_ALL_STD','')

go


-------------------------------
--	Init  ESPT0000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPT0000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPT0000'
	delete BEST..TI17CHN  where CHAIN_CT='ESPT0000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPT0000')

	insert into BEST..TI17CHN values ('ESPT0000',  '')

		--  ESPT0000 

	insert into BEST..TI17FNC values ('ESPT0000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_GTEPCO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_GTEPSO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCTRFWH','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRFWH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FT','${DFILI}/${ENV_PREFIX}_ESID2000_FT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLEIGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLEIGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCTRSTAT','${DFILP}/${ENV_PREFIX}_ESID3900_FCTRSTAT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_GTEPSIICO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_GTEPSIISO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'STA_LIFSTAREP','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESID3700_FTECLEDSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTFAC','${DFILI}/${ENV_PREFIX}_ESID2000_FTFAC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FVENTNPANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FVENTNPANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FT_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_FT_EBS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FWHGTA','${DFILI}/${ENV_PREFIX}_ESID0060_FWHGTA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FWHGTR','${DFILI}/${ENV_PREFIX}_ESID0060_FWHGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLCGTAA','${DFILI}/${ENV_PREFIX}_ESID2000_DLCGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCLIENT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCLIENT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCTRFWH','${DFILI}/${ENV_PREFIX}_ESPD0060_FCTRFWH_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCTRULT','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRULT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCURSII','${DFILI}/${ENV_PREFIX}_ESID0060_FCURSII_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FLIBEL1','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FLOARAT','${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPLCCOM','${DFILP}/${ENV_PREFIX}_ESID2500_FPLCCOM_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPRMLOA','${DFILI}/${ENV_PREFIX}_ESID2000_FPRMLOA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPRSMAP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FPRSMAP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FRETTRF','${DFILP}/${ENV_PREFIX}_ESCJ0060_FRETTRF_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FSEGEST','${DFILI}/${ENV_PREFIX}_ESID0560_FSEGEST_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_LABOCY1','${DFILI}/${ENV_PREFIX}_ESID2000_LABOCY1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_MVTPNA0','${DFILI}/${ENV_PREFIX}_ESID0070_MVTPNA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'STA_LIFSTAREP_AS','${DFILI}/${ENV_PREFIX}_STAD1500_LIFSTAREP_AS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_CPLIFDRI','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_CTRULT02','${DFILI}/${ENV_PREFIX}_ESID2000_CTRULT02_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLGTAAPA','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAPA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCESSION','${DFILI}/${ENV_PREFIX}_ESID0560_FCESSION_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCTRGRO1','${DFILI}/${ENV_PREFIX}_ESID2000_FCTRGRO1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FSOBBLOB','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSOBBLOB_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTFAMCHG','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTFAMCHG_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTTR_PRM','${DFILI}/${ENV_PREFIX}_ESID2000_FTTR_PRM_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTVENTNP','${DFILP}/${ENV_PREFIX}_ESID0060_FTVENTNP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FSEGPATTERNFWH','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERNFWH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DCGTAALOA','${DFILI}/${ENV_PREFIX}_ESID2000_DCGTAALOA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLCUMGTAA','${DFILI}/${ENV_PREFIX}_ESID2000_DLCUMGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLDSIIGTR','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLGTAAPRE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAPRE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPLACEMT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPLACEMT2','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPLATXCUM','${DFILI}/${ENV_PREFIX}_ESID0560_FPLATXCUM_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FVPLACEMT','${DFILI}/${ENV_PREFIX}_ESID2030_FVPLACEMT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_IADPERIFR','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FSEGPATTERN_CSF','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLCGTAAREC','${DFILI}/${ENV_PREFIX}_ESID2000_DLCGTAAREC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLCUMGTAAS','${DFILI}/${ENV_PREFIX}_ESID2000_DLCUMGTAAS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLDSIIGTAA','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLDSIIGTAR','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTAR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLGTAAFPRE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAFPRE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLGTAAPNAE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAPNAE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLGTAARPPE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAARPPE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DTSTATGTAA','${DFILI}/${ENV_PREFIX}_ESID0560_DTSTATGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FRATINGRTO','${DFILI}/${ENV_PREFIX}_ESID0060_FRATINGRTO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTHRHLDUWY','${DFILI}/${ENV_PREFIX}_ESID0060_FTHRHLDUWY_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FULTIMATES','${DFILI}/${ENV_PREFIX}_ESEH1200_FULTIMATES_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_IADPERIFCI','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_IADPERIFCT','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSASSO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_SUBTRSBASE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSBASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLCGTAAEPPE','${DFILI}/${ENV_PREFIX}_ESID2000_DLCGTAAEPPE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLDGTAA_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_EBS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FLOARAT_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_EBS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPRMLOA_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_FPRMLOA_EBS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_IADPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_CRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_CRVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLDGTAA_IFRS','${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_IFRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLGTAATFPNAE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAATFPNAE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPLATXCUMALL','${DFILI}/${ENV_PREFIX}_ESID0560_FPLATXCUMALL_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_IRDPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRDPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IRDVPERICASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FBOPRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FSEGPATTERNFWH','${DFILI}/${ENV_PREFIX}_ESPD0060_FSEGPATTERNFWH_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_SUBTRS_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCLIENT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCLIENT_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FDETTRS_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FPRSMAP_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FSEGPATTERN_CSF','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_CSF_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FTRSLNK_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FCURQUOT_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FSSDACTR_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_FBOPRSLNK_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_SUBTRSBLOCKLIFEST','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSBLOCKLIFEST_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLDGTAA_E_TRNCODEBS','${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_E_TRNCODEBS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_DLDGTAA_E_TRNCODBEST','${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_E_TRNCODBEST_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EST_SUBTRSESBPROP_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_SUBTRSESBPROP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCES','${DFILP}/${ENV_PREFIX}_ESPT0000_FCES.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FPLC','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLC.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTFAC','${DFILP}/${ENV_PREFIX}_ESPT0000_FTFAC.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_EDIVIE','${DFILP}/${ENV_PREFIX}_ESPT0000_EDIVIE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FT_EBS','${DFILP}/${ENV_PREFIX}_ESPT0000_FT_EBS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FWHGTA','${DFILP}/${ENV_PREFIX}_ESPT0000_FWHGTA.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FWHGTR','${DFILP}/${ENV_PREFIX}_ESPT0000_FWHGTR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_SUBTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FSUBTRS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_CMGTRSO','${DFILP}/${ENV_PREFIX}_ESPT0000_CMGTRSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLCGTAA','${DFILP}/${ENV_PREFIX}_ESPT0000_DLCGTAA.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCLIENT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCLIENT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCPLACC','${DFILP}/${ENV_PREFIX}_ESPT0000_FCPLACC.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCTRULT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCTRULT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCURSII','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURSII.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FDETTRS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FLIBEL1','${DFILP}/${ENV_PREFIX}_ESPT0000_FLIBEL1.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESPT0000_FLIBEL2.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FPLCCOM','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLCCOM.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FPRSMAP','${DFILP}/${ENV_PREFIX}_ESPT0000_FPRSMAP.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FRETTRF','${DFILP}/${ENV_PREFIX}_ESPT0000_FRETTRF.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRSLNK.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_LABOCY1','${DFILP}/${ENV_PREFIX}_ESPT0000_LABOCY1.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_CMGTAASO','${DFILP}/${ENV_PREFIX}_ESPT0000_CMGTAASO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_CMGTARSO','${DFILP}/${ENV_PREFIX}_ESPT0000_CMGTARSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_CPLIFDRI','${DFILP}/${ENV_PREFIX}_ESPT0000_CPLIFDRI.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_CTRULT02','${DFILP}/${ENV_PREFIX}_ESPT0000_CTRULT02.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLGTAAPA','${DFILP}/${ENV_PREFIX}_ESPT0000_DLGTAAPA.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCTRGRO1','${DFILP}/${ENV_PREFIX}_ESPT0000_FCTRGRO1.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCTRSTAT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCTRSTAT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSN.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURQUOT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FSOBBLOB','${DFILP}/${ENV_PREFIX}_ESPT0000_FSOBBLOB.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESPT0000_FSSDACTR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESPT0000_FTECLEDA.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESPT0000_FTECLEDR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTFAMCHG','${DFILP}/${ENV_PREFIX}_ESPT0000_FTFAMCHG.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTTR_PRM','${DFILP}/${ENV_PREFIX}_ESPT0000_FTTR_PRM.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTVENTNP','${DFILP}/${ENV_PREFIX}_ESPT0000_FTVENTNP.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DCGTAALOA','${DFILP}/${ENV_PREFIX}_ESPT0000_DCGTAALOA.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLCUMGTAA','${DFILP}/${ENV_PREFIX}_ESPT0000_DLCUMGTAA.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLGTAAPRE','${DFILP}/${ENV_PREFIX}_ESPT0000_DLGTAAPRE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FBOPRSLNK','${DFILP}/${ENV_PREFIX}_ESPT0000_FBOPRSLNK.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSNI.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FPLACEMT0','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLACEMT0.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FPLACEMT2','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLACEMT2.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLATXCUM.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FVPLACEMT','${DFILP}/${ENV_PREFIX}_ESPT0000_FVPLACEMT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_IADPERIFR','${DFILP}/${ENV_PREFIX}_ESPT0000_IADPERIFR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_LIFSTAREP','${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLCGTAAREC','${DFILP}/${ENV_PREFIX}_ESPT0000_DLCGTAAREC.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLCUMGTAAS','${DFILP}/${ENV_PREFIX}_ESPT0000_DLCUMGTAAS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLGTAAFPRE','${DFILP}/${ENV_PREFIX}_ESPT0000_DLGTAAFPRE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLGTAAPNAE','${DFILP}/${ENV_PREFIX}_ESPT0000_DLGTAAPNAE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLGTAARPPE','${DFILP}/${ENV_PREFIX}_ESPT0000_DLGTAARPPE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DTSTATGTAA','${DFILP}/${ENV_PREFIX}_ESPT0000_DTSTATGTAA.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FRATINGRTO','${DFILP}/${ENV_PREFIX}_ESPT0000_FRATINGRTO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTHRHLDUWY','${DFILP}/${ENV_PREFIX}_ESPT0000_FTHRHLDUWY.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRANSCODE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FULTIMATES','${DFILP}/${ENV_PREFIX}_ESPT0000_FULTIMATES.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FVENTNPANT','${DFILP}/${ENV_PREFIX}_ESPT0000_FVENTNPANT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_IADPERIFCI','${DFILP}/${ENV_PREFIX}_ESPT0000_IADPERIFCI.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_IADPERIFCT','${DFILP}/${ENV_PREFIX}_ESPT0000_IADPERIFCT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_SUBTRSASSO','${DFILP}/${ENV_PREFIX}_ESPT0000_FSUBTRSASSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_SUBTRSBASE','${DFILP}/${ENV_PREFIX}_ESPT0000_FSUBTRSBASE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLCGTAAEPPE','${DFILP}/${ENV_PREFIX}_ESPT0000_DLCGTAAEPPE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_IADPERICASE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_CADVPERIESB0','${DFILP}/${ENV_PREFIX}_ESPT0000_CADVPERIESB0.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_CRVPERICASE0','${DFILP}/${ENV_PREFIX}_ESPT0000_CRVPERICASE0.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLDGTAA_IFRS','${DFILP}/${ENV_PREFIX}_ESPT0000_DLDGTAA_IFRS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLGTAATFPNAE','${DFILP}/${ENV_PREFIX}_ESPT0000_DLGTAATFPNAE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCTRGROLESII','${DFILP}/${ENV_PREFIX}_ESPT0000_FCTRGROLESII.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FPLATXCUMALL','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLATXCUMALL.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_IADVPERICASE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESPT0000_IRDPERICASE0.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_IRDVPERICASE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_LIFSTAREP_AS','${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP_AS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESPT0000_IARVPERICASE0.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIRDVPERICASE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_SUBTRSESBPROP','${DFILP}/${ENV_PREFIX}_ESPT0000_FSUBTRSESBPROP.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_SUBTRS_TXT','${DFILP}/${PCH}ESPT0000_SUBTRS_TXT_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCLIENT_TXT','${DFILP}/${PCH}ESPT0000_FCLIENT_TXT_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FDETTRS_TXT','${DFILP}/${PCH}ESPT0000_FDETTRS_TXT_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FPRSMAP_TXT','${DFILP}/${PCH}ESPT0000_FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FTRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FSSDACTR_TXT','${DFILP}/${PCH}ESPT0000_FSSDACTR_TXT_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_SUBTRSBLOCKLIFEST','${DFILP}/${ENV_PREFIX}_ESPT0000_FSUBTRSBLOCKLIFEST.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_DLDGTAA_E_TRNCODEBS','${DFILP}/${ENV_PREFIX}_ESPT0000_DLDGTAA_E_TRNCODEBS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPT0000',  'EPO_SUBTRSESBPROP_TXT','${DFILP}/${PCH}ESPT0000_SUBTRSESBPROP_TXT_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESLJ0090
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLJ0090')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESLJ0090'
	delete BEST..TI17CHN  where CHAIN_CT='ESLJ0090'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLJ0090')

	insert into BEST..TI17CHN values ('ESLJ0090',  '')

		--  ESLJ0090 

	insert into BEST..TI17FNC values ('ESLJ0090',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FCES','${DFILP}/${ENV_PREFIX}_ESID7000_FCES.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FPLC','${DFILP}/${ENV_PREFIX}_ESID7000_FPLC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESID7000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSN.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESID7000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSNI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESID7000_FPLATXCUM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESID7000_FTRANSCODE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_IADVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_OIRDVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_EPOSOCLO','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_EPOSOCLO_CUR','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_CUR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_EPOSOCLO_NEW','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_NEW.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLJ0090',  'ESL_EPOSOCLO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_CURNEW.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3610
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3610')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3610'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3610'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3610')

	insert into BEST..TI17CHN values ('ESFD3610',  'Cash flow at inception')

		--  I17G_CSF_ALL_INI 

	insert into BEST..TI17FNC values ('I17G_CSF_ALL_INI',  'cashflow at inception')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'DLCUMGTAA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_CURGTA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FWHGTA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FWHGTR','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLRGTAA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLSGTAA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLSGTAR','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FLIBEL2','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLREGTAR','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EPO_DLDGTAR_E','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLREMAJGTAR','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FTECLEDASII','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_IRDPERICASE0','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FCTRFWH','${DFILP}/${PCH}ESPD0060_FCTRFWH.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FCTRGRO','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FPRSMAP','${DFILP}/${PCH}ESPT0000_FPRSMAP.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FPLATXCUMALL','${DFILP}/${PCH}ESPT0000_FPLATXCUMALL.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_IADPERICASE','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FULAERAT','${DFILP}/${PCH}ESPD0060_FULAERAT${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FSEGPATTERNFWH','${DFILP}/${PCH}ESPD0060_FSEGPATTERNFWH.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FSEGPATTERN_CSF','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FSEGPATTERN_ICR','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FSEGPATTERN_INF','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_INF.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDSIIGTR','${DFILI}/${PCH}ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDSIIGTAA','${DFILI}/${PCH}ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDSIIGTAR','${DFILI}/${PCH}ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTAR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FTECLEDSII','${DFILI}/${PCH}ESFD3610_I17G_CSF_ALL_INI_FTECLEDSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FPRSMAP_TXT','${DFILP}/${PCH}ESPT0000_FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FTRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLDGTAA','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLDGTAASII${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLCUMGTAAR','${DFILI}/${PCH}ESFD3610_I17G_CSF_ALL_INI_DLCUMGTAAR.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLCUMGTAAR_IBNR_FUTCLAIMS','${DFILP}/${PCH}ESFD3610_I17G_CSF_ALL_INI_DLCUMGTAAR_IBNR_FUTCLAIMS.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_GTSII_REMAINTOPAY_ULAE','${DFILP}/${PCH}ESFD3610_I17G_CSF_ALL_INI_GTSII_RMTP_ULAE_SII${TYPEINV0}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_GTSII_CASHFLOW','${DFILP}/${PCH}ESFD3610_I17G_CSF_ALL_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_GTSII_REMAINTOPAY_ULAEINF','${DFILP}/${PCH}ESFD3610_I17G_CSF_ALL_INI_GTSII_RMTP_ULAEINF_SII${TYPEINV0}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3610_I17G_CSF_ALL_INI_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3610','I17G_CSF_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3610','I17G_CSF_ALL_INI','')

go


-------------------------------
--	Init  ESID2220
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2220')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2220'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2220'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2220')

	insert into BEST..TI17CHN values ('ESID2220',  'EBS Losses and IBNR calculation')

		--  ESID2220_POSE 

	insert into BEST..TI17FNC values ('ESID2220_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EPO_FTECLEDASIISO','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FCPLACC','${DFILP}/${PCH}ESPT0000_FCPLACC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FCTRGRO','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_DLGTAAPA','${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EPO_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_DLCUMGTAA','${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FLOARAT','${DFILP}/${PCH}ESID2210_FLOARAT_EBS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_IADPERIFR','${DFILP}/${PCH}ESPT0000_IADPERIFR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EPO_FTECLEDASO','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_ARCSTATGTA','${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FPRMLOA','${DFILP}/${PCH}ESID2210_FPRMLOA_EBSSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FTHRHLDUWY','${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_IADPERIFCI','${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_DLDGTAA_CUMULS_COUR','${DFILP}/${PCH}ESID2210_DLDGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FSEGEST_SOLVENCY','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_DLGTAUPUC','${DFILP}/${PCH}ESID2220_DLGTAUPUC__.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_FUTURE_EBS','${DFILP}/${PCH}ESID2220_FUTURE_EBSSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POSE',  'EST_DLDGTAA_E_TRNCODEBS','${DFILP}/${PCH}ESID2220_DLDGTAASIISO.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESID2220','ESID2220_POSE','POSE')

		--  ESID2220_POCE 

	insert into BEST..TI17FNC values ('ESID2220_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FCPLACC','${DFILP}/${PCH}ESPT0000_FCPLACC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FCTRGRO','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_DLGTAAPA','${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EPO_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_DLCUMGTAA','${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FLOARAT','${DFILP}/${PCH}ESID2210_FLOARAT_EBS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_IADPERIFR','${DFILP}/${PCH}ESPT0000_IADPERIFR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EPO_FTECLEDASO','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_ARCSTATGTA','${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FPRMLOA','${DFILP}/${PCH}ESID2210_FPRMLOA_EBSCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FTHRHLDUWY','${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_IADPERIFCI','${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EPO_FTECLEDASIISO','${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_DLDGTAA_CUMULS_COUR','${DFILP}/${PCH}ESID2210_DLDGTAASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FSEGEST_SOLVENCY','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_DLGTAUPUC','${DFILP}/${PCH}ESID2220_DLGTAUPUC__.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_FUTURE_EBS','${DFILP}/${PCH}ESID2220_FUTURE_EBSCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2220_POCE',  'EST_DLDGTAA_E_TRNCODEBS','${DFILP}/${PCH}ESID2220_DLDGTAASIICO.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESID2220','ESID2220_POCE','POCE')

go


-------------------------------
--	Init  ESEH1110
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESEH1110')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESEH1110'
	delete BEST..TI17CHN  where CHAIN_CT='ESEH1110'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESEH1110')

	insert into BEST..TI17CHN values ('ESEH1110',  '')

		--  ESEH1110 

	insert into BEST..TI17FNC values ('ESEH1110',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FAPR0','${DFILI}/${ENV_PREFIX}_ESEH1110_FAPR0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FAMPROT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FAMPROT0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FBSEGEST','${DFILP}/${ENV_PREFIX}_ESEH1110_FBSEGEST_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCTRGRO0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCTRULT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRULT0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FUNDSTA0','${DFILI}/${ENV_PREFIX}_ESEH1110_FUNDSTA0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FVCTRGRO','${DFILI}/${ENV_PREFIX}_ESEH1110_FVCTRGRO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCESSION0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCESSION0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FCESSION1','${DFILI}/${ENV_PREFIX}_ESEH1110_FCESSION1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FPLACEMT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FPLACEMT1','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FPLACEMT2','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT2_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FVCTRGRO0','${DFILI}/${ENV_PREFIX}_ESEH1110_FVCTRGRO0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_FPLACEMTCOM0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMTCOM0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1110',  'EST_SAISPERICASE','${DFILP}/${ENV_PREFIX}_ESEH1110_SAISPERICASE_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID0130
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0130')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID0130'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0130'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0130')

	insert into BEST..TI17CHN values ('ESID0130',  '')

		--  ESID0130 

	insert into BEST..TI17FNC values ('ESID0130',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID0130',  'EST_FLIFESTY1','${DFILI}/${ENV_PREFIX}_ESID0120_FLIFESTY1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0130',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0130',  'EST_IRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0130',  'EST_FLIFESTY0','${DFILI}/${ENV_PREFIX}_ESID0130_FLIFESTY0_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESLD8100
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD8100')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESLD8100'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD8100'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD8100')

	insert into BEST..TI17CHN values ('ESLD8100',  '')

		--  ESLD8100 

	insert into BEST..TI17FNC values ('ESLD8100',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESLD8100',  'ESL_FTECLEDALO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDALO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8100',  'ESL_FTECLEDRLO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDRLO.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD3800
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3800')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD3800'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3800'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3800')

	insert into BEST..TI17CHN values ('ESPD3800',  '')

		--  ESPD3800 

	insert into BEST..TI17FNC values ('ESPD3800',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_SUBTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FSUBTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FCLIENT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCLIENT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FCPLACC','${DFILP}/${ENV_PREFIX}_ESPT0000_FCPLACC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTRCO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTRSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FSOBBLOB','${DFILP}/${ENV_PREFIX}_ESPT0000_FSOBBLOB.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESPT0000_FSSDACTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESPT0000_FTECLEDR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREGTRCO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLRGTAACO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAACO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLRGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTAACO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAACO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTAASO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTARCO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTARSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FBOPRSLNK','${DFILP}/${ENV_PREFIX}_ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FPLACEMT2','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLACEMT2.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLATXCUM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLASIIGTRCO','${DFILP}/${ENV_PREFIX}_ESPD3630_DLASIIGTRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLASIIGTRSO','${DFILP}/${ENV_PREFIX}_ESPD3630_DLASIIGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDSIIGTRCO','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDSIIGTRSO','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTRSIICO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_VENTNPSIICO','${DFILP}/${ENV_PREFIX}_ESPD3710_VENTNPSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_VENTNPSIISO','${DFILP}/${ENV_PREFIX}_ESPD3710_VENTNPSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLASIIGTAACO','${DFILP}/${ENV_PREFIX}_ESPD3630_DLASIIGTAACO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLASIIGTAASO','${DFILP}/${ENV_PREFIX}_ESPD3630_DLASIIGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLASIIGTARCO','${DFILP}/${ENV_PREFIX}_ESPD3630_DLASIIGTARCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLASIIGTARSO','${DFILP}/${ENV_PREFIX}_ESPD3630_DLASIIGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDGTAASIICO','${DFILP}/${ENV_PREFIX}_ESID2220_DLDGTAASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDGTAASIISO','${DFILP}/${ENV_PREFIX}_ESID2220_DLDGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDSIIGTAACO','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTAACO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDSIIGTAASO','${DFILP}/${ENV_PREFIX}_ESPD3620_DLDSIIGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDSIIGTARCO','${DFILP}/${ENV_PREFIX}_ESPD3710_DLDSIIGTARCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDSIIGTARSO','${DFILP}/${ENV_PREFIX}_ESPD3710_DLDSIIGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREGTRSIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREMAJGTRCO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREMAJGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLRGTAASIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLRGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTAASIICO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTARSIICO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLSGTARSIISO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDGTRSIICO_E','${DFILP}/${ENV_PREFIX}_ESPD2570_DLDGTRSIICO_E.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDGTRSIISO_E','${DFILP}/${ENV_PREFIX}_ESPD2570_DLDGTRSIISO_E.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREGTARSIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTARSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREGTARSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTARSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREMAJGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIRDVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDGTARSIICO_E','${DFILP}/${ENV_PREFIX}_ESPD2570_DLDGTARSIICO_E.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLDGTARSIISO_E','${DFILP}/${ENV_PREFIX}_ESPD2570_DLDGTARSIISO_E.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREMAJGTRSIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREMAJGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREMAJGTARSIICO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTARSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_DLREMAJGTARSIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTARSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_GTSII_RISKMARGINCO','${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_GTSII_RISKMARGINSO','${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDACO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDRCO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDRSO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDASIICO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDRSIICO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDRSIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDASO_CUR','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_CUR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDASO_MTH','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_MTH.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDASO_MVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_MVT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDACO_ANNULMVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO_ANNULMVT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDRCO_ANNULMVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO_ANNULMVT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDASIICO_ANNULMVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO_ANNULMVT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3800',  'EPO_FTECLEDRSIICO_ANNULMVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO_ANNULMVT.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3690
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3690')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3690'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3690'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3690')

	insert into BEST..TI17CHN values ('ESFD3690',  'Revenue Calculation')

		--  I17G_IRV_ALL_STD 

	insert into BEST..TI17FNC values ('I17G_IRV_ALL_STD',  'revenue calculation')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'EST_FCURQUOT','${DFILP}/${PCH}ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'EST_IRDPERICASE0','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'EPO_FTECLEDASII','${DFILP}/${PCH}ESPD3800_FTECLEDA${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'EPO_FTECLEDRSII','${DFILP}/${PCH}ESPD3800_FTECLEDR${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'ESF_GTSII_CASHFLOW_INI','${DFILP}/${PCH}ESFD3610_CASHFLOW_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'EPO_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESPD3610_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'ESF_GTSII_DSC_LKI_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'ESF_GTSII_RAD_LKI_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'ESF_GTSII_DSC_FWD_ESCOMPTE','${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_ESCOMPTE_FWD_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'EPO_GTSII_GLOBAL_CASHFLOW_PREV','${DFILP}/${PCH}ESPD3610_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'ESF_GTSII_IFRS17_CSM','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_CSM${TYPEINV0}_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',  'ESF_GTSII_IFRS17_REVENUE','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_REVENUE${TYPEINV0}_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3690','I17G_IRV_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3690','I17G_IRV_ALL_STD','')

go


-------------------------------
--	Init  ESCJ0060
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESCJ0060')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESCJ0060'
	delete BEST..TI17CHN  where CHAIN_CT='ESCJ0060'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESCJ0060')

	insert into BEST..TI17CHN values ('ESCJ0060',  '')

		--  ESCJ0060 

	insert into BEST..TI17FNC values ('ESCJ0060',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'ESL_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESID7000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESCJ0060_GTEP.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_LIFEP','${DFILP}/${ENV_PREFIX}_ESCJ0060_LIFEP.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FGRP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FGRP_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FCLIENT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCLIENT_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FCTRFIC','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCTRFIC_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FCTRNAT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCTRNAT_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FLIBEL1','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FLIFDRI','${DFILI}/${ENV_PREFIX}_ESCJ0060_FLIFDRI_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FLIFTHR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FLIFTHR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FPRSMAP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FPRSMAP_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FRETPAR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FRETPAR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FRETTRF','${DFILP}/${ENV_PREFIX}_ESCJ0060_FRETTRF_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FSEGPAR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSEGPAR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FSUBSID','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBSID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_TACCPAR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTACCPAR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FACMTRSH','${DFILI}/${ENV_PREFIX}_ESCJ0060_FACMTRSH_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FBANTECL','${DFILI}/${ENV_PREFIX}_ESCJ0060_FBANTECL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FSEGMENT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSEGMENT_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FSOBBLOB','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSOBBLOB_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FTFAMCHG','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTFAMCHG_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FTRSLNK7','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK7_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSASSO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_SUBTRSBASE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSBASE_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FLIFDRI_ALL','${DFILI}/${ENV_PREFIX}_ESCJ0060_FLIFDRI_ALL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FTRSLNKVRET','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNKVRET_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_SUBTRS_TXT','${DFILP}/${PCH}ESCJ0060_FSUBTRS_TXT_${PARM0_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FCLIENT_TXT','${DFILP}/${PCH}ESCJ0060_FCLIENT_TXT_${PARM0_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FDETTRS_TXT','${DFILP}/${PCH}ESCJ0060_FDETTRS_TXT_${PARM0_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FPRSMAP_TXT','${DFILP}/${PCH}ESCJ0060_FPRSMAP_TXT_${PARM0_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FTRSLNK_TXT','${DFILP}/${PCH}ESCJ0060_FTRSLNK_TXT_${PARM0_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FLIFDRIQ_ALL','${DFILI}/${ENV_PREFIX}_ESCJ0060_FLIFDRIQ_ALL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FLIFDRIY_ALL','${DFILI}/${ENV_PREFIX}_ESCJ0060_FLIFDRIY_ALL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESCJ0060_FCURQUOT_TXT_${PARM0_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FSSDACTR_TXT','${DFILP}/${PCH}ESCJ0060_FSSDACTR_TXT_${PARM0_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FBOPRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_${PARM0_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESCJ0060_FBOPRSLNK_TXT_${PARM0_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSESBPROP_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_FTRANSCODEVRET','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODEVRET_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_SUBTRSBLOCKLIFEST','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSBLOCKLIFEST_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESCJ0060',  'EST_SUBTRSESBPROP_TXT','${DFILP}/${PCH}ESCJ0060_SUBTRSESBPROP_TXT_${PARM0_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID8600
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8600')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8600'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8600'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8600')

	insert into BEST..TI17CHN values ('ESID8600',  '')

		--  ESID8600 

	insert into BEST..TI17FNC values ('ESID8600',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8600',  'EST_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESID3700_FTECLEDSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8600',  'EPO_FTECLEDSIISO','${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDSIISO.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID3900
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3900')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID3900'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3900'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3900')

	insert into BEST..TI17CHN values ('ESID3900',  '')

		--  ESID3900 

	insert into BEST..TI17FNC values ('ESID3900',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FCESANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FCESANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FPLCANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FPLCANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FAPR','${DFILP}/${ENV_PREFIX}_ESID0560_FAPR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_TOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_TOTGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FAMPROT','${DFILP}/${ENV_PREFIX}_ESID0560_FAMPROT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FCTRULT','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRULT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FBSEGEST','${DFILP}/${ENV_PREFIX}_ESEH1110_FBSEGEST_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FSOBBLOB','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSOBBLOB_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FUNDSTA0','${DFILI}/${ENV_PREFIX}_ESEH1110_FUNDSTA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FCESSION','${DFILI}/${ENV_PREFIX}_ESID0560_FCESSION_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FPLACEMT','${DFILI}/${ENV_PREFIX}_ESID0560_FPLACEMT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FCTRGROBO','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRGROBO_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_IADPERIFCT','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_IADPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FCTRSTAT','${DFILP}/${ENV_PREFIX}_ESID3900_FCTRSTAT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FSEGSTAT','${DFILP}/${ENV_PREFIX}_ESID3900_FSEGSTAT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FCTRSTAT_EBS','${DFILI}/${ENV_PREFIX}_ESID3900_FCTRSTAT_EBS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FSEGSTAT_EBS','${DFILI}/${ENV_PREFIX}_ESID3900_FSEGSTAT_EBS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FCTRSTAT_IFRS','${DFILI}/${ENV_PREFIX}_ESID3900_FCTRSTAT_IFRS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3900',  'EST_FSEGSTAT_IFRS','${DFILI}/${ENV_PREFIX}_ESID3900_FSEGSTAT_IFRS_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2020
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2020')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2020'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2020'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2020')

	insert into BEST..TI17CHN values ('ESID2020',  '')

		--  ESID2020 

	insert into BEST..TI17FNC values ('ESID2020',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2020',  'EST_DLRLIFEI','${DFILI}/${ENV_PREFIX}_ESID2030_DLRLIFEI_${CLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESLD3850
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD3850')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESLD3850'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD3850'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD3850')

	insert into BEST..TI17CHN values ('ESLD3850',  '')

		--  ESLD3850 

	insert into BEST..TI17FNC values ('ESLD3850',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESLD3850',  'ESL_FTECLEDALO_MVT','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDALO_MVT.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID8040
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8040')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8040'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8040'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8040')

	insert into BEST..TI17CHN values ('ESID8040',  '')

		--  ESID8040 

	insert into BEST..TI17FNC values ('ESID8040',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_CMPCALC','${DFILI}/${ENV_PREFIX}_ESID2040_CMPCALC_PC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_TGAPTHR','${DFILI}/${ENV_PREFIX}_ESID8040_TGAPTHR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID8040',  'EST_FLIFEST0','${DFILI}/${ENV_PREFIX}_ESID8040_FLIFEST0_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3760
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3760')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3760'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3760'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3760')

	insert into BEST..TI17CHN values ('ESFD3760',  'IFRS17 - UoA signature at subsequent measurement')

		--  I17G_UOA_PRO_STD 

	insert into BEST..TI17FNC values ('I17G_UOA_PRO_STD',  'IFRS17 - UoA signature at subsequent measurement')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_UOA_PRO_STD',  'EST_IADPERICASE_STD','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_STD.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UOA_PRO_STD',  'EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UOA_PRO_STD',  'ESF_FSEGPROF_INI','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSEGPROF_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UOA_PRO_STD',  'ESF_GTSII_CSM_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_GTSII_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UOA_PRO_STD',  'ESF_FSEGPROF_STD_PREVIOUS','${DFILP}/${ENV_PREFIX}_ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UOA_PRO_STD',  'ESF_FSEGPROF_STD','${DFILP}/${ENV_PREFIX}_ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3760','I17G_UOA_PRO_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3760','I17G_UOA_PRO_STD','')

go


-------------------------------
--	Init  ESDJ5020
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ5020')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESDJ5020'
	delete BEST..TI17CHN  where CHAIN_CT='ESDJ5020'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ5020')

	insert into BEST..TI17CHN values ('ESDJ5020',  '')

		--  ESDJ5020 

	insert into BEST..TI17FNC values ('ESDJ5020',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FESB','${DFILI}/${ENV_PREFIX}_ESDJ0110_FESB_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESDJ1010_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FACCPAR0','${DFILI}/${ENV_PREFIX}_ESDJ1010_FACCPAR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FAVERATE','${DFILI}/${ENV_PREFIX}_ESDJ0110_FAVERATE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'STA_LIFSTAREP_PLAN','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSASSO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FSUBTRSBASE','${DFILI}/${ENV_PREFIX}_ESDJ0110_FSUBTRSBASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FIDLIFEST_MVT','${DFILI}/${ENV_PREFIX}_ESDJ0110_FIDLIFEST_MVT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE4_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'EST_FIDLIFEST_CALL','${DFILI}/${ENV_PREFIX}_ESDJ0110_FIDLIFEST_CALL_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ5020',  'SAVED_LIFSTAREP_PLAN','${DFILI}/${ENV_PREFIX}_ESDJ5020_LIFSTAREP_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2900
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2900')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2900'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2900'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2900')

	insert into BEST..TI17CHN values ('ESID2900',  '')

		--  ESID2900 

	insert into BEST..TI17FNC values ('ESID2900',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_TOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_TOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_TOTGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_DLREJGTR','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_DLREJGTAA','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTAA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_DLREJGTAR','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTAR_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESEH1100
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESEH1100')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESEH1100'
	delete BEST..TI17CHN  where CHAIN_CT='ESEH1100'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESEH1100')

	insert into BEST..TI17CHN values ('ESEH1100',  '')

		--  ESEH1100 

	insert into BEST..TI17FNC values ('ESEH1100',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IADPERICASE_INI','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_INI.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IADPERICASE_STD','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_STD.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IADPERIFCT0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERIFCT0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IADPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IAVPERICASE0_ADDI','${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_ADDI_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESEH1100',  'EST_IADPERICASE_ENTIER0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_ENTIER0_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD8100
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD8100')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD8100'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD8100'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD8100')

	insert into BEST..TI17CHN values ('ESFD8100',  'Generating IFRS 17 Group RA files')

		--  I17G_OMG_RA_STD 

	insert into BEST..TI17FNC values ('I17G_OMG_RA_STD',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'EST_FTECLEDA','${DFILP}/${PCH}ESPD3800_FTECLEDA${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'EST_FTECLEDR','${DFILP}/${PCH}ESPD3800_FTECLEDR${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'EST_FTECLEDASII','${DFILP}/${PCH}ESPD3800_FTECLEDASII${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'EST_FTECLEDRSII','${DFILP}/${PCH}ESPD3800_FTECLEDRSII${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDA','${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDA_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDR','${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDR_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDSII','${DFILP}/${PCH}ESFD3730_I17G_SII_ALL_STD_FTECLEDSII_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_GTSII_RISKMARGIN','${DFILP}/${PCH}ESFD3730_I17G_SII_ALL_STD_GTSII_RISKMARGIN${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDACO_ANNULMVT','${DFILP}/${PCH}ESFD3730_I17G_SII_ALL_STD_FTECLEDACO_ANNULMVT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDRCO_ANNULMVT','${DFILP}/${PCH}ESFD3730_I17G_SII_ALL_STD_FTECLEDRCO_ANNULMVT_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDARA','${PCH}ESFD8100_BSAR_${IDF_CT}_FTECLEDARA_${CLODATMAX_YEA}_${CLODATMAX_QTR}Q_${HOST_PRDSIT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDRRA','${PCH}ESFD8100_BSAR_${IDF_CT}_FTECLEDRRA_${CLODATMAX_YEA}_${CLODATMAX_QTR}Q_${HOST_PRDSIT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDAYTD','${PCH}ESFD8100_BSAR_${IDF_CT}_FTECLEDAYTD_${CLODATMAX_YEA}_${CLODATMAX_QTR}Q_${HOST_PRDSIT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDRYTD','${PCH}ESFD8100_BSAR_${IDF_CT}_FTECLEDRYTD_${CLODATMAX_YEA}_${CLODATMAX_QTR}Q_${HOST_PRDSIT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FTECLEDSIIRA','${PCH}ESFD8100_BSAR_${IDF_CT}_FTECLEDSIIRA_${CLODATMAX_YEA}_${CLODATMAX_QTR}Q_${HOST_PRDSIT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_RA_STD',  'ESF_FULTIMATESRA','${PCH}ESFD8100_BSAR_${IDF_CT}_FULTIMATESRA_${CLODATMAX_YEA}_${CLODATMAX_QTR}Q_${HOST_PRDSIT}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD8100','I17G_OMG_RA_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD8100','I17G_OMG_RA_STD','')

go


-------------------------------
--	Init  ESLD1800
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD1800')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESLD1800'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD1800'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD1800')

	insert into BEST..TI17CHN values ('ESLD1800',  '')

		--  ESLD1800 

	insert into BEST..TI17FNC values ('ESLD1800',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FCES','${DFILP}/${ENV_PREFIX}_ESID7000_FCES.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FPLC','${DFILP}/${ENV_PREFIX}_ESID7000_FPLC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESID7000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_EPOSOCLO','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSN.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESID7000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESID7000_FCURCVSNI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESID7000_FPLATXCUM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESID7000_FTRANSCODE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_IADVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_OIRDVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_DLSGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTRLO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_DLSGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTAALO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1800',  'ESL_DLSGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTARLO.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID0070
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0070')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID0070'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0070'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0070')

	insert into BEST..TI17CHN values ('ESID0070',  '')

		--  ESID0070 

	insert into BEST..TI17FNC values ('ESID0070',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID0070',  'EST_MVTPNA0','${DFILI}/${ENV_PREFIX}_ESID0070_MVTPNA0_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2550
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2550')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2550'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2550'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2550')

	insert into BEST..TI17CHN values ('ESID2550',  '')

		--  ESID2550 

	insert into BEST..TI17FNC values ('ESID2550',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESCJ0060_GTEP.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLSGTR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FRETTRF','${DFILP}/${ENV_PREFIX}_ESCJ0060_FRETTRF_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLREGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLRPGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLRTGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLVGTR','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTR_PC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLREGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLRIGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_DLRIGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLRNPGTR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLRTCGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLRTFGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FPLACEMT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLGTRSNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTRSNEM_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLREMAJGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLREMAJGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IRDVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_IADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLDVGTR','${DFILI}/${ENV_PREFIX}_ESID2550_DLDVGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLEIGTAA','${DFILI}/${ENV_PREFIX}_ESID2550_DLEIGTAA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2550',  'EST_DLRIGTAANOS','${DFILI}/${ENV_PREFIX}_ESID2550_DLRIGTAANOS_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2090
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2090')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2090'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2090'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2090')

	insert into BEST..TI17CHN values ('ESID2090',  '')

		--  ESID2090 

	insert into BEST..TI17FNC values ('ESID2090',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_FLIBEL1','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_TOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_TOTGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2090',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_${ICLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESRD0010
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESRD0010')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESRD0010'
	delete BEST..TI17CHN  where CHAIN_CT='ESRD0010'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESRD0010')

	insert into BEST..TI17CHN values ('ESRD0010',  '')

		--  ESRD0010 

	insert into BEST..TI17FNC values ('ESRD0010',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESRD0010',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD0010',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD0010',  'EST_FCLIENT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCLIENT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD0010',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD0010',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESRD0010',  'EST_FBOPRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_${PARM0_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD2570
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD2570')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD2570'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD2570'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD2570')

	insert into BEST..TI17CHN values ('ESPD2570',  'FUTURE FOR RETRO NP CONTRACT')

		--  ESPD2570_POCE 

	insert into BEST..TI17FNC values ('ESPD2570_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_FPLACEMT22','${DFILI}/${PCH}ESPD0060_FPLACEMT22.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_FTECLEDRSO','${DFILP}/${PCH}ESPD3800_FTECLEDRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_IRDPERICASE0','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_RETITDPRM_UPR_ACT','${DFILP}/${PCH}ESPD0060_RETITDPRM_UPR_ACTCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_DLDGTRCO','${DFILP}/${PCH}ESPD2570_DLDGTRSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_DLDGTRSO','${DFILP}/${PCH}ESPD2570_DLDGTRSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_DLDGTR_E','${DFILP}/${PCH}ESPD2570_DLDGTRSIICO_E.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_DLDGTAR_E','${DFILP}/${PCH}ESPD2570_DLDGTARSIICO_E.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POCE',  'EPO_FUTURE_RETRO_EBS','${DFILP}/${PCH}ESPD2570_FUTURE_RETRO_EBS.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESPD2570','ESPD2570_POCE','POCE')

		--  ESPD2570_POSE 

	insert into BEST..TI17FNC values ('ESPD2570_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_FPLACEMT22','${DFILI}/${PCH}ESPD0060_FPLACEMT22.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_FTECLEDRSO','${DFILP}/${PCH}ESPD3800_FTECLEDRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_IRDPERICASE0','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_RETITDPRM_UPR_ACT','${DFILP}/${PCH}ESPD0060_RETITDPRM_UPR_ACTSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_DLDGTRSO','${DFILP}/${PCH}ESPD2570_DLDGTRSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_DLDGTR_E','${DFILP}/${PCH}ESPD2570_DLDGTRSIISO_E.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_DLDGTAR_E','${DFILP}/${PCH}ESPD2570_DLDGTARSIISO_E.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2570_POSE',  'EPO_FUTURE_RETRO_EBS','${DFILP}/${PCH}ESPD2570_FUTURE_RETRO_EBS.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESPD2570','ESPD2570_POSE','POSE')

go


-------------------------------
--	Init  ESID1900
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1900')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID1900'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1900'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1900')

	insert into BEST..TI17CHN values ('ESID1900',  '')

		--  ESID1900 

	insert into BEST..TI17FNC values ('ESID1900',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_IGTAA00','${DFILP}/${ENV_PREFIX}_ESIJ7000_IGTAA00.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_IGTR0','${DFILI}/${ENV_PREFIX}_ESID1900_IGTR0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_IGTAA0','${DFILI}/${ENV_PREFIX}_ESID1900_IGTAA0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_IGTAR0','${DFILI}/${ENV_PREFIX}_ESID1900_IGTAR0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_DLAGTR0','${DFILI}/${ENV_PREFIX}_ESID1900_DLAGTR0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_DLAGTAA0','${DFILI}/${ENV_PREFIX}_ESID1900_DLAGTAA0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1900',  'EST_DLAGTAR0','${DFILI}/${ENV_PREFIX}_ESID1900_DLAGTAR0_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD3610
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3610')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD3610'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3610'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3610')

	insert into BEST..TI17CHN values ('ESPD3610',  'Cach flow calculation jobs ESID3702A et ESID3703A')

		--  ESPD3610_POCE 

	insert into BEST..TI17FNC values ('ESPD3610_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_FWHGTA','${DFILP}/${PCH}ESPT0000_FWHGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_FWHGTR','${DFILP}/${PCH}ESPT0000_FWHGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_FCTRFWH','${DFILP}/${PCH}ESPD0060_FCTRFWH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_DLDSIIGTR','${DFILP}/${PCH}ESPD3620_DLDSIIGTRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_DLDSIIGTAA','${DFILP}/${PCH}ESPD3620_DLDSIIGTAACO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_DLDSIIGTAR','${DFILP}/${PCH}ESPD3620_DLDSIIGTARCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_FTECLEDSII','${DFILP}/${PCH}ESPD3700_FTECLEDSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_FSEGPATTERNFWH','${DFILP}/${PCH}ESPD0060_FSEGPATTERNFWH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_FSEGPATTERN_CSF','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_FSEGPATTERN_ICR','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_FSEGPATTERN_INF','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_INF.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_DLCUMGTAAR','${DFILP}/${PCH}ESPD3610_DLCUMGTAAR_POCE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_GTSII_REMAINTOPAY_ULAE','${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_GTSII_CASHFLOW','${DFILP}/${PCH}ESPD3610_GTSII_CASHFLOW_POCE_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_GTSII_REMAINTOPAY_ULAEINF','${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',  'EST_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESPD3610_GTSII_GLOBAL_CASHFLOWCO_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESPD3610','ESPD3610_POCE','POCE')

		--  ESPD3610_POSE 

	insert into BEST..TI17FNC values ('ESPD3610_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_FWHGTA','${DFILP}/${PCH}ESPT0000_FWHGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_FWHGTR','${DFILP}/${PCH}ESPT0000_FWHGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_FCTRFWH','${DFILP}/${PCH}ESPD0060_FCTRFWH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_DLDSIIGTR','${DFILP}/${PCH}ESPD3620_DLDSIIGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_DLDSIIGTAA','${DFILP}/${PCH}ESPD3620_DLDSIIGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_DLDSIIGTAR','${DFILP}/${PCH}ESPD3620_DLDSIIGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_FTECLEDSII','${DFILP}/${PCH}ESPD3700_FTECLEDSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_FSEGPATTERNFWH','${DFILP}/${PCH}ESPD0060_FSEGPATTERNFWH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_FSEGPATTERN_CSF','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_FSEGPATTERN_ICR','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_FSEGPATTERN_INF','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_INF.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_DLCUMGTAAR','${DFILP}/${PCH}ESPD3610_DLCUMGTAAR_POSE.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_GTSII_REMAINTOPAY_ULAE','${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_GTSII_CASHFLOW','${DFILP}/${PCH}ESPD3610_GTSII_CASHFLOW_POSE_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_GTSII_REMAINTOPAY_ULAEINF','${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',  'EST_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESPD3610_GTSII_GLOBAL_CASHFLOWSO_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESPD3610','ESPD3610_POSE','POSE')

go


-------------------------------
--	Init  ESPD8900
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8900')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD8900'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8900'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8900')

	insert into BEST..TI17CHN values ('ESPD8900',  '')

		--  ESPD8900 

	insert into BEST..TI17FNC values ('ESPD8900',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD8900',  'EPO_FCTRSTATSO','${DFILP}/${ENV_PREFIX}_ESPD3900_FCTRSTATSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8900',  'EPO_FSEGSTATSO','${DFILP}/${ENV_PREFIX}_ESPD3900_FSEGSTATSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8900',  'EPO_FCTRSTATSOSII','${DFILP}/${ENV_PREFIX}_ESPD3900_FCTRSTATSOSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8900',  'EPO_FSEGSTATSOSII','${DFILP}/${ENV_PREFIX}_ESPD3900_FSEGSTATSOSII.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID0110
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0110')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID0110'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0110'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0110')

	insert into BEST..TI17CHN values ('ESID0110',  '')

		--  ESID0110 

	insert into BEST..TI17FNC values ('ESID0110',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID0110',  'EST_FACCTRAA0','${DFILI}/${ENV_PREFIX}_ESID0110_FACCTRAA0_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2080
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2080')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2080'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2080'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2080')

	insert into BEST..TI17CHN values ('ESID2080',  '')

		--  ESID2080 

	insert into BEST..TI17FNC values ('ESID2080',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTCQ','${DFILI}/${ENV_PREFIX}_ESID2030_SRGTCQ_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTCY','${DFILI}/${ENV_PREFIX}_ESID2030_SRGTCY_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTCB1Q','${DFILI}/${ENV_PREFIX}_ESID2030_SRGTCB1Q_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTCB1Y','${DFILI}/${ENV_PREFIX}_ESID2030_SRGTCB1Y_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_PCQ','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_PCQ_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_PCY','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_PCY_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SIGNANOQ_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SIGNANOQ_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SIGNANOY_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SIGNANOY_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTR_PCQ','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTR_PCQ_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTR_PCY','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTR_PCY_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_PCQ','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_PCQ_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_PCY','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_PCY_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_VLIFEST195Q','${DFILI}/${ENV_PREFIX}_ESID2030_VLIFEST195Q_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_VLIFEST195Y','${DFILI}/${ENV_PREFIX}_ESID2030_VLIFEST195Y_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_CMPCALC_PCQ','${DFILI}/${ENV_PREFIX}_ESID2040_CMPCALC_PCQ_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_CMPCALC_PCY','${DFILI}/${ENV_PREFIX}_ESID2040_CMPCALC_PCY_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_PAQ','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_PAQ_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_PAY','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_PAY_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SIGNANOQ_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SIGNANOQ_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SIGNANOY_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SIGNANOY_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTR_PAQ','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTR_PAQ_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTR_PAY','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTR_PAY_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_PAQ','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_PAQ_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_PAY','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_PAY_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_IARVPERICASE4Y','${DFILI}/${ENV_PREFIX}_ESID2070_IARVPERICASE4Y_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_SRV_PCQ','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PCQ_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_SRV_PCY','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PCY_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_CMPCALC_PAQ','${DFILI}/${ENV_PREFIX}_ESID2040_CMPCALC_PAQ_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_CMPCALC_PAY','${DFILI}/${ENV_PREFIX}_ESID2040_CMPCALC_PAY_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAA_PAQ','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAA_PAQ_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAA_PAY','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAA_PAY_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAR_PAQ','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAR_PAQ_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAR_PAY','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAR_PAY_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_SRV_PCQ','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PCQ_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_SRV_PCY','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PCY_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAA_PCY','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAA_PCY_${ICLODAT2}_${CRE_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAR_PCY','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAR_PCY_${ICLODAT2}_${CRE_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_SRV_PAQ','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PAQ_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_SRV_PAY','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PAY_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_SRV_PAQ','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PAQ_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_SRV_PAY','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PAY_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAA_PCQ','`ls -rt ${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAA_PCQ_${ICLODAT2}*.dat | tail -1 `','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAR_PCQ','`ls -rt ${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAR_PCQ_${ICLODAT2}*.dat | tail -1 `','I','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTC','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTC_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTCB1','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTCB1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_PC','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTE_PC_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SIGNANO_PC','${DFILI}/${ENV_PREFIX}_ESID2080_SIGNANO_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTR_PC','${DFILP}/${ENV_PREFIX}_ESID2080_DLVGTR_PC_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_PC','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTEF_PC_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_VLIFEST195','${DFILI}/${ENV_PREFIX}_ESID2080_VLIFEST195_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_CMPCALC_PC','${DFILI}/${ENV_PREFIX}_ESID2080_CMPCALC_PC_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_PA','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTE_PA_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SIGNANO_PA','${DFILI}/${ENV_PREFIX}_ESID2080_SIGNANO_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTR_PA','${DFILP}/${ENV_PREFIX}_ESID2080_DLVGTR_PA_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_PA','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTEF_PA_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_SRV_PC','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTE_SRV_PC_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_CMPCALC_PA','${DFILI}/${ENV_PREFIX}_ESID2080_CMPCALC_PA_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAA_PA','${DFILP}/${ENV_PREFIX}_ESID2080_DLVGTAA_PA_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAR_PA','${DFILP}/${ENV_PREFIX}_ESID2080_DLVGTAR_PA_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_SRV_PC','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTEF_SRV_PC_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAA_PC','${DFILP}/${ENV_PREFIX}_ESID2080_DLVGTAA_PC_${ICLODAT2}_${CRE_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_DLVGTAR_PC','${DFILP}/${ENV_PREFIX}_ESID2080_DLVGTAR_PC_${ICLODAT2}_${CRE_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTE_SRV_PA','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTE_SRV_PA_${BALSHTYEA}1231.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2080',  'EST_SRGTEF_SRV_PA','${DFILI}/${ENV_PREFIX}_ESID2080_SRGTEF_SRV_PA_${BALSHTYEA}1231.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID0060
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0060')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID0060'
	delete BEST..TI17CHN  where CHAIN_CT='ESID0060'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID0060')

	insert into BEST..TI17CHN values ('ESID0060',  '')

		--  ESID0060 

	insert into BEST..TI17FNC values ('ESID0060',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FWHGTA','${DFILI}/${ENV_PREFIX}_ESID0060_FWHGTA_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FWHGTR','${DFILI}/${ENV_PREFIX}_ESID0060_FWHGTR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FCALEND','${DFILI}/${ENV_PREFIX}_ESID0060_FCALEND_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FCURSII','${DFILI}/${ENV_PREFIX}_ESID0060_FCURSII_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FFAMCNA','${DFILI}/${ENV_PREFIX}_ESID0060_FFAMCNA_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FINTWIT','${DFILI}/${ENV_PREFIX}_ESID0060_FINTWIT_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FLSTMTH','${DFILI}/${ENV_PREFIX}_ESID0060_FLSTMTH_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FACCPAR0','${DFILI}/${ENV_PREFIX}_ESID0060_FACCPAR0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FACCSUP0','${DFILI}/${ENV_PREFIX}_ESID0060_FACCSUP0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FCTREST0','${DFILI}/${ENV_PREFIX}_ESID0060_FCTREST0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FLABOCY0','${DFILI}/${ENV_PREFIX}_ESID0060_FLABOCY0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FLIFEST1','${DFILI}/${ENV_PREFIX}_ESID0060_FLIFEST1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FLIFPLN0','${DFILI}/${ENV_PREFIX}_ESID0060_FLIFPLN0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FSEGEST0','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGEST0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FTVENTNP','${DFILP}/${ENV_PREFIX}_ESID0060_FTVENTNP_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FVSEGEST','${DFILI}/${ENV_PREFIX}_ESID0060_FVSEGEST_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_PNARETRO','${DFILI}/${ENV_PREFIX}_ESID0060_PNARETRO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FACCSUP12','${DFILI}/${ENV_PREFIX}_ESID0060_FACCSUP12_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FACCTRAI0','${DFILI}/${ENV_PREFIX}_ESID0060_FACCTRAI0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FCMUSPLI0','${DFILI}/${ENV_PREFIX}_ESID0060_FCMUSPLI0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FDEPOSIT0','${DFILI}/${ENV_PREFIX}_ESID0060_FDEPOSIT0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FOUTTRAA0','${DFILI}/${ENV_PREFIX}_ESID0060_FOUTTRAA0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FOUTTRAI0','${DFILI}/${ENV_PREFIX}_ESID0060_FOUTTRAI0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FPFUNWIT0','${DFILI}/${ENV_PREFIX}_ESID0060_FPFUNWIT0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FPINTWIT0','${DFILI}/${ENV_PREFIX}_ESID0060_FPINTWIT0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FVSEGEST0','${DFILI}/${ENV_PREFIX}_ESID0060_FVSEGEST0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_RETPNAGTR','${DFILI}/${ENV_PREFIX}_ESID0060_RETPNAGTR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FCMUSPLIT0','${DFILI}/${ENV_PREFIX}_ESID0060_FCMUSPLIT0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FPLATXCUM0','${DFILI}/${ENV_PREFIX}_ESID0060_FPLATXCUM0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FRATINGRTO','${DFILI}/${ENV_PREFIX}_ESID0060_FRATINGRTO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FTHRHLDUWY','${DFILI}/${ENV_PREFIX}_ESID0060_FTHRHLDUWY_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_IADPERIFR0','${DFILI}/${ENV_PREFIX}_ESID0060_IADPERIFR0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FTVENTNPHIS','${DFILI}/${ENV_PREFIX}_ESID0060_FTVENTNPHIS_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_IADPERIFCI0','${DFILI}/${ENV_PREFIX}_ESID0060_IADPERIFCI0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_CADVPERIESB0','${DFILI}/${ENV_PREFIX}_ESID0060_CADVPERIESB0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_CRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_CRVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_IADPERIPRMD0','${DFILI}/${ENV_PREFIX}_ESID0060_IADPERIPRMD0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_IRDPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRDPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_IRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_OADPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_OADPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_OAVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_OAVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_ORDPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_ORDPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_ORVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_ORVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FPLATXCUMALL0','${DFILI}/${ENV_PREFIX}_ESID0060_FPLATXCUMALL0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FSEGPATTERN_BDT','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_BDT_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FSEGPATTERN_CSF','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_CSF_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FSEGPATTERN_DSC','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_DSC_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FSEGPATTERN_ICR','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_ICR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID0060',  'EST_FSEGEST_SOLVENCY0','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGEST_SOLVENCY0_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  STAD1500
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD1500')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='STAD1500'
	delete BEST..TI17CHN  where CHAIN_CT='STAD1500'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD1500')

	insert into BEST..TI17CHN values ('STAD1500',  '')

		--  STAD1500 

	insert into BEST..TI17FNC values ('STAD1500',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'STA_LIFSTADIF','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTADIF.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTC','${DFILI}/${ENV_PREFIX}_ESID2030_SRGTC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTCB1','${DFILI}/${ENV_PREFIX}_ESID2030_SRGTCB1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_CPLIFDRI','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_CPLIFDRIN','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRIN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_FVPLACEMT','${DFILI}/${ENV_PREFIX}_ESID2030_FVPLACEMT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_LIFENDCPT','${DFILI}/${ENV_PREFIX}_ESID2030_LIFENDCPT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTE_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_PC_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'STA_LIFSTAREP_PLAN','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_ECRSRVAPC','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVAPC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_ECRSRVRPC','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVRPC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_FVPLACEMT2','${DFILI}/${ENV_PREFIX}_ESID2030_FVPLACEMT2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTEF_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_PC_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_VLIFEST195','${DFILI}/${ENV_PREFIX}_ESID2030_VLIFEST195_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_ECRSRVACBP','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVACBP_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_ECRSRVRCBP','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVRCBP_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_FLIFPLN1','${DFILI}/${ENV_PREFIX}_ESID1520_EST_FLIFPLN1_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_FLIFPLN3','${DFILI}/${ENV_PREFIX}_ESID1520_EST_FLIFPLN3_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSASSO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_LIFESTNOACC','${DFILI}/${ENV_PREFIX}_ESID2030_LIFESTNOACC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTE_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_PA_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTEF_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_PA_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE4_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'STA_LIFSTAREP_BILANPREC','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_BILANPREC.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'STA_LIFSTAREP_TRIMEPREC','${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_TRIMEPREC.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'STA_LIFSTAREP','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat','O','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTEFAR','${DFILI}/${ENV_PREFIX}_STAD1500_SRGTEFAR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_LIFNEWBIZ','${DFILI}/${ENV_PREFIX}_STAD1500_FLIFNEWBIZ_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'STA_LIFSTAREP_BRIDG','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP_BRIDGE.dat','O','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTCB1_RETRO','${DFILI}/${ENV_PREFIX}_STAD1500_SRGTCB1_RETRO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTEFR_VENTIL','${DFILI}/${ENV_PREFIX}_STAD1500_SRGTEFR_VENTIL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_SRGTEF_BILAN','${DFILI}/${ENV_PREFIX}_STAD1500_EST_SRGTEF_BILAN_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'STA_LIFSTAREP_CBP_RETRO','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP_CBP_RETRO.dat','O','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_FLIFPLN1_VENTIL','${DFILI}/${ENV_PREFIX}_STAD1500_FLIFPLN1_VENTIL_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('STAD1500',  'EST_ECRSRVRPC_VENTIL','${DFILI}/${ENV_PREFIX}_STAD1500_ECRSRVRPC_VENTIL_${ICLODAT2}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2560
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2560')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2560'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2560'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2560')

	insert into BEST..TI17CHN values ('ESID2560',  '')

		--  ESID2560 

	insert into BEST..TI17FNC values ('ESID2560',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_MGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_MGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_IGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTAR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_MGTAR','${DFILP}/${ENV_PREFIX}_ESIX7000_MGTAR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_IGTR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_FVENTNPANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FVENTNPANT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLAGTR','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLSGTR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLAGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLDVGTR','${DFILI}/${ENV_PREFIX}_ESID2550_DLDVGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLREGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRPGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRTGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLSGTAR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLVGTR','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTR_PC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_FTRSLNK7','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK7_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_FTVENTNP','${DFILP}/${ENV_PREFIX}_ESID0060_FTVENTNP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLREGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRNPGTR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRPGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRTCGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRTFGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRTGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_VENTNP_TRIMCUR','${DFILP}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMCUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRNPGTAR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRTCGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLRTFGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_FPLATXCUM','${DFILI}/${ENV_PREFIX}_ESID0560_FPLATXCUM_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_VENTNP_TRIMPREV','${DFILP}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMPREV.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLASIIGTAR','${DFILI}/${ENV_PREFIX}_ESID3600_DLASIIGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLDSIIGTAR','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLGTARSNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTARSNEM_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLREMAJGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLREMAJGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLTOTITGTAR','${DFILI}/${ENV_PREFIX}_ESID2060_DLTOTITGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_CADVPERIESB0','${DFILI}/${ENV_PREFIX}_ESID0060_CADVPERIESB0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IRDVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLVGTAR','${DFILP}/${ENV_PREFIX}_ESID2040_DLVGTAR_PC_${ICLODAT}_${CRE_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_IADVPERICASE_ENTIER','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_ENTIER_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_TOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLTOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_DLTOTGTR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLDVGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_DLDVGTAR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_DLTOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_DLTOTGTAR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID1550
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1550')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID1550'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1550'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1550')

	insert into BEST..TI17CHN values ('ESID1550',  '')

		--  ESID1550 

	insert into BEST..TI17FNC values ('ESID1550',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FACCSUP','${DFILI}/${ENV_PREFIX}_ESID0560_FACCSUP_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_RETPNAGTR','${DFILI}/${ENV_PREFIX}_ESID0060_RETPNAGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_DLRNPGTR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_DLRNPGTAA','${DFILI}/${ENV_PREFIX}_ESID1550_DLRNPGTAA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1550',  'EST_DLRNPGTAR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTAR_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD3900
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3900')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD3900'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3900'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3900')

	insert into BEST..TI17CHN values ('ESPD3900',  '')

		--  ESPD3900 

	insert into BEST..TI17FNC values ('ESPD3900',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FCPLACC','${DFILP}/${ENV_PREFIX}_ESPT0000_FCPLACC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FCTRSTAT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCTRSTAT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_DLRGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_DLSGTAASO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FTECLEDASO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_IADPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_DLDGTAASIISO','${DFILP}/${ENV_PREFIX}_ESID2220_DLDGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_DLRGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_DLSGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FSEGEST_SOLVENCYSO','${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FCTRSTATSO','${DFILP}/${ENV_PREFIX}_ESPD3900_FCTRSTATSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FSEGSTATSO','${DFILP}/${ENV_PREFIX}_ESPD3900_FSEGSTATSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FCTRSTATSOSII','${DFILP}/${ENV_PREFIX}_ESPD3900_FCTRSTATSOSII.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3900',  'EPO_FSEGSTATSOSII','${DFILP}/${ENV_PREFIX}_ESPD3900_FSEGSTATSOSII.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2000'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2000')

	insert into BEST..TI17CHN values ('ESID2000',  '')

		--  ESID2000 

	insert into BEST..TI17FNC values ('ESID2000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_MVTPNA','${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCTREST','${DFILI}/${ENV_PREFIX}_ESID0560_FCTREST_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCTRULT','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRULT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FLABOCY','${DFILI}/${ENV_PREFIX}_ESID0560_FLABOCY_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FSEGEST','${DFILI}/${ENV_PREFIX}_ESID0560_FSEGEST_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_MVTPNAC','${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNAC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCTREST0','${DFILI}/${ENV_PREFIX}_ESID0060_FCTREST0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FTFAMCHG','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTFAMCHG_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCTRESTA','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_IADPERIFR','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FTHRHLDUWY','${DFILI}/${ENV_PREFIX}_ESID0060_FTHRHLDUWY_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DTSTATGTAA','${DFILI}/${ENV_PREFIX}_ESID0560_DTSTATGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_IADPERIFCI','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCI_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_IADPERIFCT','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_IADPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_IADPERIPRMD','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIPRMD_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_SAISPERICASE','${DFILP}/${ENV_PREFIX}_ESEH1110_SAISPERICASE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FSEGEST_SOLVENCY','${DFILI}/${ENV_PREFIX}_ESID0560_FSEGEST_SOLVENCY_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FT','${DFILI}/${ENV_PREFIX}_ESID2000_FT_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FTFAC','${DFILI}/${ENV_PREFIX}_ESID2000_FTFAC_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FT_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_FT_EBS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_NPSAIS','${DFILI}/${ENV_PREFIX}_ESID2000_NPSAIS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLCGTAA','${DFILI}/${ENV_PREFIX}_ESID2000_DLCGTAA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FLOARAT','${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FPRMLOA','${DFILI}/${ENV_PREFIX}_ESID2000_FPRMLOA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FT_IFRS','${DFILI}/${ENV_PREFIX}_ESID2000_FT_IFRS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_LABOCY1','${DFILI}/${ENV_PREFIX}_ESID2000_LABOCY1_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_PERIANO','${DFILI}/${ENV_PREFIX}_ESID2000_PERIANO_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_CTRULT02','${DFILI}/${ENV_PREFIX}_ESID2000_CTRULT02_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLGTAAPA','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAPA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCTREST1','${DFILI}/${ENV_PREFIX}_ESID2000_FCTREST1_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCTRGRO1','${DFILI}/${ENV_PREFIX}_ESID2000_FCTRGRO1_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FTTR_PRM','${DFILI}/${ENV_PREFIX}_ESID2000_FTTR_PRM_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_IBNR_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_IBNR_EBS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DCGTAALOA','${DFILI}/${ENV_PREFIX}_ESID2000_DCGTAALOA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLCUMGTAA','${DFILI}/${ENV_PREFIX}_ESID2000_DLCUMGTAA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLGTAAPRE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAPRE_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_IBNR_IFRS','${DFILI}/${ENV_PREFIX}_ESID2000_IBNR_IFRS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLCGTAAREC','${DFILI}/${ENV_PREFIX}_ESID2000_DLCGTAAREC_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLCUMGTAAS','${DFILI}/${ENV_PREFIX}_ESID2000_DLCUMGTAAS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLGTAAFPRE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAFPRE_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLGTAAPNAE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAPNAE_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLGTAARPPE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAARPPE_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FUTURE_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_FUTURE_EBS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLCGTAAEPPE','${DFILI}/${ENV_PREFIX}_ESID2000_DLCGTAAEPPE_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLDGTAA_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_EBS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FLOARATSNEM','${DFILP}/${ENV_PREFIX}_ESID2000_FLOARATSNEM_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FLOARAT_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_EBS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FPRMLOA_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_FPRMLOA_EBS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLDGTAA_IFRS','${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_IFRS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLGTAATFPNAE','${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAATFPNAE_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DSUMGTAASNEM','${DFILP}/${ENV_PREFIX}_ESID2000_DSUMGTAASNEM_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FLOARAT_IFRS','${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_IFRS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FPRMLOA_IFRS','${DFILI}/${ENV_PREFIX}_ESID2000_FPRMLOA_IFRS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_PERICASESNEM','${DFILP}/${ENV_PREFIX}_ESID2000_PERICASESNEM_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCTREST1_IFRS','${DFILI}/${ENV_PREFIX}_ESID2000_FCTREST1_IFRS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_BLANCHIMENT_RPCC','${DFILI}/${ENV_PREFIX}_ESID2000_BLANCHIMENT_RPCC_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLDGTAA_E_TRNCODEBS','${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_E_TRNCODEBS_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_DLDGTAA_E_TRNCODBEST','${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_E_TRNCODBEST_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD8050
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8050')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD8050'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8050'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8050')

	insert into BEST..TI17CHN values ('ESPD8050',  '')

		--  ESPD8050 

	insert into BEST..TI17FNC values ('ESPD8050',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD8050',  'EPO_FUTURE_EBS','${DFILI}/${ENV_PREFIX}ESID2220_FUTURE_EBSSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8050',  'EPO_IBNR_EBS','${DFILI}/${ENV_PREFIX}_ESID2000_IBNR_EBS_${ICLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID8800
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8800')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8800'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8800'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8800')

	insert into BEST..TI17CHN values ('ESID8800',  '')

		--  ESID8800 

	insert into BEST..TI17FNC values ('ESID8800',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8800',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8800',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID8700
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8700')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8700'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8700'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8700')

	insert into BEST..TI17CHN values ('ESID8700',  '')

		--  ESID8700 

	insert into BEST..TI17FNC values ('ESID8700',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_FTECLEDA_CUR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_CUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_FTECLEDA_MTH','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MTH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MVT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_FTECLEDA_REP','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_REP.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_FTECLEDR_CUR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_CUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_FTECLEDR_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_MVT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_SUBTRS_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_TXT_${PARM0_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8700',  'EST_SUBTRSESBPROP_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_SUBTRSESBPROP_TXT_${PARM0_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID3800
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3800')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID3800'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3800'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3800')

	insert into BEST..TI17CHN values ('ESID3800',  '')

		--  ESID3800 

	insert into BEST..TI17FNC values ('ESID3800',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_DLREJGTR','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_DLREJGTAA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_DLREJGTAR','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_IGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTAR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FCLIENT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCLIENT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_DLTOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_DLTOTGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FCTRGRO0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FSOBBLOB','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSOBBLOB_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_DLTOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_DLTOTGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_DLTOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_DLTOTGTAR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FPLACEMT2','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${PARM0_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${PARM0_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_IADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_IRDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_IRDVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_OADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_OADVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_ORDVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1500_ORDVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_DLGTAASNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTAASNEM_${PARM0_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FSNEMHIST0','${DFILP}/${ENV_PREFIX}_ESID3800_FSNEMHIST0.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDASNEM','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDASNEM.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDA_CUR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_CUR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDA_MTH','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MTH.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MVT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDA_REP','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_REP.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDRSNEM','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDRSNEM.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDR_CUR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_CUR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3800',  'EST_FTECLEDR_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_MVT.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD2220
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD2220')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD2220'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD2220'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD2220')

	insert into BEST..TI17CHN values ('ESFD2220',  'Future at inception')

		--  ESFD2220_POCE 

	insert into BEST..TI17FNC values ('ESFD2220_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_DLGTAAPA','${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EPO_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_DLCUMGTAA','${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_IADPERIFR','${DFILP}/${PCH}ESPT0000_IADPERIFR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_FPRMLOA','${DFILP}/${PCH}ESID2210_FPRMLOA_EBSCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_FTHRHLDUWY','${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_IADPERIFCI','${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_DLCUMGTAATOT','${DFILI}/${PCH}ESID2210_DLCUMGTAATOTCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_CTRESTLOSPBPAP','${DFILI}/${PCH}ESID2210_CTRESTLOSPBPAPCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_DLDGTAA_CUMULS_COUR','${DFILP}/${PCH}ESID2210_DLDGTAASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_DLGTAUPUC','${DFILP}/${PCH}ESID2220_DLGTAUPUC__.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_FUTURE_EBS','${DFILP}/${PCH}ESID2220_FUTURE_EBSCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POCE',  'EST_DLDGTAA_E_TRNCODEBS','${DFILP}/${PCH}ESID2220_DLDGTAASIICO.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESFD2220','ESFD2220_POCE','POCE')

		--  ESFD2220_POSE 

	insert into BEST..TI17FNC values ('ESFD2220_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_DLGTAAPA','${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_DLCUMGTAA','${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_IADPERIFR','${DFILP}/${PCH}ESPT0000_IADPERIFR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_FPRMLOA','${DFILP}/${PCH}ESID2210_FPRMLOA_EBSSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_FTHRHLDUWY','${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_IADPERIFCI','${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_DLCUMGTAATOT','${DFILI}/${PCH}ESID2210_DLCUMGTAATOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_CTRESTLOSPBPAP','${DFILI}/${PCH}ESID2210_CTRESTLOSPBPAP.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_DLDGTAA_CUMULS_COUR','${DFILP}/${PCH}ESID2210_DLDGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_DLGTAUPUC','${DFILP}/${PCH}ESID2220_DLGTAUPUC__.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_FUTURE_EBS','${DFILP}/${PCH}ESID2220_FUTURE_EBSSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESFD2220_POSE',  'EST_DLDGTAA_E_TRNCODEBS','${DFILP}/${PCH}ESID2220_DLDGTAASIISO.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESFD2220','ESFD2220_POSE','POSE')

		--  I17G_FUT_ALL_INI 

	insert into BEST..TI17FNC values ('I17G_FUT_ALL_INI',  'Future at inception')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FWHGTA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FWHGTR','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FPRMLOA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLGTAAPA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLCUMGTAA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLGTAAPRE','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FTECLEDASO','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_ARCSTATGTA','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLGTAAPNAE','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLCUMGTAATOT','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FTECLEDASIISO','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_CTRESTLOSPBPAP','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLDGTAA_CUMULS_COUR','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCLIENT','${DFILP}/${PCH}ESPT0000_FCLIENT.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCPLACC','${DFILP}/${PCH}ESPT0000_FCPLACC.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCTRFWH','${DFILP}/${PCH}ESPD0060_FCTRFWH.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCTRGRO','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERIFR','${DFILP}/${PCH}ESPT0000_IADPERIFR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FTHRHLDUWY','${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERIFCI','${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERIFCT','${DFILP}/${PCH}ESPT0000_IADPERIFCT.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERICASE','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FDETTRS_TXT','${DFILP}/${PCH}ESPT0000_FDETTRS_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FTRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FSEGEST_SOLVENCY','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCY${TYPEINV0}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FLOARAT','${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_IFRS_${PARM0_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FUTURE_EBS','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_FUTURE_${TYPEINV}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLGTAUPUC','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLGTAUPUC_${TYPEINV}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLDGTAA_E_TRNCODEBS','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLDGTAASII${TYPEINV0}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD2220','I17G_FUT_ALL_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD2220','I17G_FUT_ALL_INI','')

go


-------------------------------
--	Init  ESID8000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8000'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8000')

	insert into BEST..TI17CHN values ('ESID8000',  '')

		--  ESID8000 

	insert into BEST..TI17FNC values ('ESID8000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FT','${DFILI}/${ENV_PREFIX}_ESID2000_FT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_TOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_TOTGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FLOARAT','${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FPRMLOA','${DFILI}/${ENV_PREFIX}_ESID2000_FPRMLOA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FCTREST0','${DFILI}/${ENV_PREFIX}_ESID0060_FCTREST0_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FCTREST1','${DFILI}/${ENV_PREFIX}_ESID2000_FCTREST1_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FBESTCONPAR','${DFILI}/${ENV_PREFIX}_ESID2500_FBESTCONPAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_IADPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_FBESTCESSION','${DFILI}/${ENV_PREFIX}_ESID2500_FBESTCESSION_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8000',  'EST_DLDGTAA_E_TRNCODBEST','${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_E_TRNCODBEST_${ICLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID8530
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8530')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8530'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8530'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8530')

	insert into BEST..TI17CHN values ('ESID8530',  '')

		--  ESID8530 

	insert into BEST..TI17FNC values ('ESID8530',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8530',  'EST_FRAPP','${DFILI}/${ENV_PREFIX}_ESID2530_FRAPP_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8530',  'EST_FRETCOMP','${DFILP}/${ENV_PREFIX}_ESID8530_FRETCOMP.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3660
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3660')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3660'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3660'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3660')

	insert into BEST..TI17CHN values ('ESFD3660',  'Discount forward')

		--  I17G_UWD_ALL_STD 

	insert into BEST..TI17FNC values ('I17G_UWD_ALL_STD',  'Discount forward')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'EPO_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_TRERETFACCTR','${DFILP}/${PCH}ESFD1130_TRERETFACCTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_INI_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_ESCOMPTE_PREVCLODAT','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_STD_GTSII_ESCOMPTE_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_ESCOMPTE_RAD_PREVCLODAT','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_RAD_PREV','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_STD_GTSII_CASHFLOW_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_GLOBAL_CASHFLOW_PREV','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_GTSII_GLOBAL_CASHFLOW_${PARM_PREV_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_UNWIND','${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_UNWIND_${PARM_ICLODAT_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_UWD_ALL_STD',  'ESF_GTSII_ESCOMPTE_FWD','${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_ESCOMPTE_FWD_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3660','I17G_UWD_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3660','I17G_UWD_ALL_STD','')

go


-------------------------------
--	Init  STAD7500
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD7500')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='STAD7500'
	delete BEST..TI17CHN  where CHAIN_CT='STAD7500'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD7500')

	insert into BEST..TI17CHN values ('STAD7500',  '')

		--  STAD7500 

	insert into BEST..TI17FNC values ('STAD7500',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_CPLIFEST','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFEST_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_FLIFEST0','${DFILI}/${ENV_PREFIX}_ESID0130_FLIFESTY0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_CPLIFDRI','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRI_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSASSO_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD7500',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE4_${BALSHTYEA}1231.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID8120
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8120')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8120'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8120'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8120')

	insert into BEST..TI17CHN values ('ESID8120',  '')

		--  ESID8120 

	insert into BEST..TI17FNC values ('ESID8120',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE4_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTE_SRV_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PC_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTR_VENTIL','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTR_VENTIL_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTEF_SRV_PC','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PC_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_ECRSRVAPC_PA','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVAPC_PA_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_ECRSRVRPC_PA','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVRPC_PA_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTE_SRV_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTE_SRV_PA_${BALSHTYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_FLIFPLN1_VENTIL','${DFILI}/${ENV_PREFIX}_ESID1520_FLIFPLN1_VENTIL_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_FLIFPLN3_VENTIL','${DFILI}/${ENV_PREFIX}_ESID1520_FLIFPLN3_VENTIL_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8120',  'EST_SRGTEF_SRV_PA','${DFILI}/${ENV_PREFIX}_ESID2040_SRGTEF_SRV_PA_${BALSHTYEA}1231.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESDJ7010
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ7010')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESDJ7010'
	delete BEST..TI17CHN  where CHAIN_CT='ESDJ7010'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ7010')

	insert into BEST..TI17CHN values ('ESDJ7010',  '')

		--  ESDJ7010 

	insert into BEST..TI17FNC values ('ESDJ7010',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_FCURQUOT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_ARCSTATGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESDJ1010_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_IGTR00','${DFILP}/${ENV_PREFIX}_ESDJ7000_IGTR00_ID_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_FACCPAR0','${DFILI}/${ENV_PREFIX}_ESDJ1010_FACCPAR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESDJ0110_FCPLACC0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_IGTAA00','${DFILP}/${ENV_PREFIX}_ESDJ7000_IGTAA00_ID_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSASSO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_FLIFEST0','${DFILI}/${ENV_PREFIX}_ESDJ0110_FLIFEST${IT}0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_FLIFDRI','${DFILI}/${ENV_PREFIX}_ESDJ1010_FLIFDRI${IT}_ALL_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_VTSTATGTA0','${DFILI}/${ENV_PREFIX}_ESDJ7000_VTSTATGTA0_ID_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IAVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_IRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IRVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE4_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_31_SORT_R_IAVPERICASE_O','/scor/scordata/ubeu/temporaire/${ENV_PREFIX}_ESDJ1010_31_SORT_R_IAVPERICASE_O_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_SRGTC','${DFILI}/${ENV_PREFIX}_ESDJ7010_SRGTC${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_FLSTMTH','${DFILI}/${ENV_PREFIX}_ESDJ7010_FLSTMTH${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_SRGTCB1','${DFILI}/${ENV_PREFIX}_ESDJ7010_SRGTCB${IT}1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_CPLIFDRI','${DFILI}/${ENV_PREFIX}_ESDJ7010_CPLIFDRI${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_CPLIFEST','${DFILI}/${ENV_PREFIX}_ESDJ7010_CPLIFEST${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_FLIFEST1','${DFILI}/${ENV_PREFIX}_ESDJ7010_FLIFEST${IT}1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_CPLIFDRIN','${DFILI}/${ENV_PREFIX}_ESDJ7010_CPLIFDRIN${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_CRIBLEANO','${DFILI}/${ENV_PREFIX}_ESDJ7010_CRIBLEANO${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_LIFENDCPT','${DFILI}/${ENV_PREFIX}_ESDJ7010_LIFENDCPT${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_LIFESTANA','${DFILI}/${ENV_PREFIX}_ESDJ7010_LIFESTANA${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_LIFESTLIB','${DFILI}/${ENV_PREFIX}_ESDJ7010_LIFESTLIB${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_VLIFEST195','${DFILI}/${ENV_PREFIX}_ESDJ7010_VLIFEST195${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_CPLIFDRIASC','${DFILI}/${ENV_PREFIX}_ESDJ7010_CPLIFDRIASC${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_ERRUPDBATCH','${DFILI}/${ENV_PREFIX}_ESDJ7010_ERRUPDBATCH${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_LIFESTNOACC','${DFILI}/${ENV_PREFIX}_ESDJ7010_LIFESTNOACC${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_VLIFEST2070','${DFILI}/${ENV_PREFIX}_ESDJ7010_VLIFEST2070${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_310_SORT_GT_O','${DFILI}/${ENV_PREFIX}_ESDJ7010_310_SORT_GT${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_430_SORT_GT_O','${DFILI}/${ENV_PREFIX}_ESDJ7010_430_SORT_GT${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_470_SORT_GT_O','${DFILI}/${ENV_PREFIX}_ESDJ7010_470_SORT_GT${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_160_SORT_CPLACC_O','${DFILI}/${ENV_PREFIX}_ESDJ7010_160_SORT_CPLACC${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_180_SORT_LSTMTH_O','${DFILI}/${ENV_PREFIX}_ESDJ7010_180_SORT_LSTMTH${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_ESTC2035_LIFDRI_O1','${DFILI}/${ENV_PREFIX}_ESDJ7010_ESTC2035_LIFDRI${IT}_O1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_200_ESTC2034_GTB1_O','${DFILI}/${ENV_PREFIX}_ESDJ7010_200_ESTC2034_GTB1${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_180_ESTC2040_OLD_LIFEST_O2','${DFILI}/${ENV_PREFIX}_ESDJ7010_180_ESTC2040_OLD_LIFEST${IT}_O2_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ7010',  'EST_205_ESTC2040_OLD_LIFEST_O2','${DFILI}/${ENV_PREFIX}_ESDJ7010_205_ESTC2040_OLD_LIFEST${IT}_O2_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESDJ1010
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ1010')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESDJ1010'
	delete BEST..TI17CHN  where CHAIN_CT='ESDJ1010'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ1010')

	insert into BEST..TI17CHN values ('ESDJ1010',  '')

		--  ESDJ1010 

	insert into BEST..TI17FNC values ('ESDJ1010',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FCURQUOT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESDJ1010_FDETTRS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'ESL_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESDJ1010_FTRSLNK.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FGRP','${DFILI}/${ENV_PREFIX}_ESDJ1010_FGRP_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRS_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FCTRFIC','${DFILI}/${ENV_PREFIX}_ESDJ1010_FCTRFIC_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FCTRNAT','${DFILI}/${ENV_PREFIX}_ESDJ1010_FCTRNAT_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FDETTRS','${DFILI}/${ENV_PREFIX}_ESDJ1010_FDETTRS_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FLIFDRI','${DFILI}/${ENV_PREFIX}_ESDJ1010_FLIFDRI_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FLIFTHR','${DFILI}/${ENV_PREFIX}_ESDJ1010_FLIFTHR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FRETTRF','${DFILI}/${ENV_PREFIX}_ESDJ1010_FRETTRF_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FSEGPAR','${DFILI}/${ENV_PREFIX}_ESDJ1010_FSEGPAR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FSUBSID','${DFILI}/${ENV_PREFIX}_ESDJ1010_FSUBSID_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESDJ1010_FTRSLNK_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_TACCPAR','${DFILI}/${ENV_PREFIX}_ESDJ1010_TACCPAR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FACCPAR0','${DFILI}/${ENV_PREFIX}_ESDJ1010_FACCPAR0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FACMTRSH','${DFILI}/${ENV_PREFIX}_ESDJ1010_FACMTRSH_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FBANTECL','${DFILI}/${ENV_PREFIX}_ESDJ1010_FBANTECL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FSEGMENT','${DFILI}/${ENV_PREFIX}_ESDJ1010_FSEGMENT_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FSOBBLOB','${DFILI}/${ENV_PREFIX}_ESDJ1010_FSOBBLOB_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FTFAMCHG','${DFILI}/${ENV_PREFIX}_ESDJ1010_FTFAMCHG_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FTRSLNK7','${DFILI}/${ENV_PREFIX}_ESDJ1010_FTRSLNK7_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FVCTRGRO','${DFILI}/${ENV_PREFIX}_ESDJ1010_FVCTRGRO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FCURCVSN','${DFILI}/${ENV_PREFIX}_ESDJ1010_FCURCVSNI_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FCURCVSNI','${DFILI}/${ENV_PREFIX}_ESDJ1010_FCURCVSNI_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FVCTRGRO0','${DFILI}/${ENV_PREFIX}_ESDJ1010_FVCTRGRO0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_SEGRATANO','${DFILI}/${ENV_PREFIX}_ESDJ1010_SEGRATANO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESDJ1010_FTRANSCODE_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSASSO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_SUBTRSBASE','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSBASE_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FLIFDRI_ALL','${DFILI}/${ENV_PREFIX}_ESDJ1010_FLIFDRI_ALL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FTRSLNKVRET','${DFILI}/${ENV_PREFIX}_ESDJ1010_FTRSLNKVRET_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_IADPERIFCT0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IADPERIFCT0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FLIFDRIQ_ALL','${DFILI}/${ENV_PREFIX}_ESDJ1010_FLIFDRIQ_ALL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FLIFDRIY_ALL','${DFILI}/${ENV_PREFIX}_ESDJ1010_FLIFDRIY_ALL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FRATTACHEVOL','${DFILI}/${ENV_PREFIX}_ESDJ1010_FRATTACHEVOL_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_IADPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IADPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IAVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_IRDPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IRDPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_IRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IRVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_OADPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_OADPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_OAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_OAVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_ORDPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_ORDPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_ORVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_ORVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE4_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSESBPROP_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_FTRANSCODEVRET','${DFILI}/${ENV_PREFIX}_ESDJ1010_FTRANSCODEVRET_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_SUBTRSBLOCKLIFEST','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSBLOCKLIFEST_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_IADPERICASE_ENTIER0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IADPERICASE_ENTIER0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_IAVPERICASE0_ADDI','${DFILI}/${ENV_PREFIX}_ESDJ1010_EST_IAVPERICASE0_ADDI_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ1010',  'EST_31_SORT_R_IAVPERICASE_O','/scor/scordata/ubeu/temporaire/${ENV_PREFIX}_ESDJ1010_31_SORT_R_IAVPERICASE_O_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESLD1900
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD1900')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESLD1900'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD1900'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD1900')

	insert into BEST..TI17CHN values ('ESLD1900',  '')

		--  ESLD1900 

	insert into BEST..TI17FNC values ('ESLD1900',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLSGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTRLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLSGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTAALO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLSGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTARLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTRLO_CUR','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO_CUR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTRLO_NEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO_NEW.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTAALO_CUR','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO_CUR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTAALO_NEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO_NEW.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTARLO_CUR','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO_CUR.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTARLO_NEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO_NEW.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTRLO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO_CURNEW.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTAALO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO_CURNEW.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD1900',  'ESL_DLREJGTARLO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO_CURNEW.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD8000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD8000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD8000'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD8000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD8000')

	insert into BEST..TI17CHN values ('ESFD8000',  'IFRS17 - Group - Loading TP O2 Tables')

		--  I17G_OMG_TP_STD 

	insert into BEST..TI17FNC values ('I17G_OMG_TP_STD',  'IFRS17 - Group - Loading TP O2 Tables')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FCR','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FCR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSECIFRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FSEGPROF_INI','${DFILP}/${PCH}ESFD3720_I17G_CSM_CRE_INI_FSEGPROF_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD',  'ESF_FSEGPROF_STD','${DFILP}/${PCH}ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${PARM_ICLODAT_D}.dat','I','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD8000','I17G_OMG_TP_STD','IFRS17 - G')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD8000','I17G_OMG_TP_STD','IFRS17 - G')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD8000','I17G_OMG_TP_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD8000','I17G_OMG_TP_STD','')

go


-------------------------------
--	Init  ESPD2050
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD2050')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD2050'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD2050'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD2050')

	insert into BEST..TI17CHN values ('ESPD2050',  '')

		--  ESPD2050_POCE 

	insert into BEST..TI17FNC values ('ESPD2050_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD2050_POCE',  'EPO_DLEIFTECLEDSIIEI','${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POCE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2050_POCE',  'EST_DLEIFTECLEDSIIEI','${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POCE.dat','I','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESPD2050','ESPD2050_POCE','POCE')

		--  ESPD2050_POSE 

	insert into BEST..TI17FNC values ('ESPD2050_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD2050_POSE',  'EPO_DLEIFTECLEDSIIEI','${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POSE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2050_POSE',  'EST_DLEIFTECLEDSIIEI','${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POSE.dat','I','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESPD2050','ESPD2050_POSE','POSE')

		--  ESPD2050 

	insert into BEST..TI17FNC values ('ESPD2050',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD2050',  'EPO_DLEIGTAA','${DFILP}/${ENV_PREFIX}_ESPD2550_DLEIGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2050',  'EPO_DLEIFTECLEDSIIEI','${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_${param_Context_id}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESEJ1000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESEJ1000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESEJ1000'
	delete BEST..TI17CHN  where CHAIN_CT='ESEJ1000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESEJ1000')

	insert into BEST..TI17CHN values ('ESEJ1000',  '')

		--  ESEJ1000 

	insert into BEST..TI17FNC values ('ESEJ1000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_STATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESEJ1000',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  STAD1540
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD1540')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='STAD1540'
	delete BEST..TI17CHN  where CHAIN_CT='STAD1540'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD1540')

	insert into BEST..TI17CHN values ('STAD1540',  '')

		--  STAD1540 

	insert into BEST..TI17FNC values ('STAD1540',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('STAD1540',  'STA_LIFSTAREP','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1540',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1540',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE4_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1540',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1540',  'STA_RFAMPRM','${DFILI}/${ENV_PREFIX}_STAD1540_RFAMPRM_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD7000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD7000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD7000'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD7000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD7000')

	insert into BEST..TI17CHN values ('ESPD7000',  '')

		--  ESPD7000 

	insert into BEST..TI17FNC values ('ESPD7000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTRSO','${DFILP}/${ENV_PREFIX}_ESPT0000_CMGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTAASO','${DFILP}/${ENV_PREFIX}_ESPT0000_CMGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTARSO','${DFILP}/${ENV_PREFIX}_ESPT0000_CMGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLSGTRSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLREGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLRGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLSGTAASO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLSGTARSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLREGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CADVPERIESB0','${DFILP}/${ENV_PREFIX}_ESPT0000_CADVPERIESB0.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLREMAJGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_DLREMAJGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTR','${DFILP}/${ENV_PREFIX}_ESPD7000_CMGTR_${BOOKING_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTAA','${DFILP}/${ENV_PREFIX}_ESPD7000_CMGTAA_${BOOKING_D}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD7000',  'EPO_CMGTAR','${DFILP}/${ENV_PREFIX}_ESPD7000_CMGTAR_${BOOKING_D}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD1520
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD1520')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD1520'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD1520'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD1520')

	insert into BEST..TI17CHN values ('ESPD1520',  '')

		--  ESPD1520 

	insert into BEST..TI17FNC values ('ESPD1520',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FCES','${DFILP}/${ENV_PREFIX}_ESPT0000_FCES.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FPLC','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_EPOSOCI','${DFILI}/${ENV_PREFIX}_ESPD0060_EPOSOCI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSN.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSNI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRANSCODE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_IADVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESPT0000_IARVPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_ECRSOCAPC','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCAPC.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_ECRSOCRPC','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCRPC.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_ECRSOCACBP','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCACBP.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1520',  'EPO_ECRSOCRCBP','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCRCBP.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD1800
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD1800')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD1800'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD1800'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD1800')

	insert into BEST..TI17CHN values ('ESPD1800',  '')

		--  ESPD1800 

	insert into BEST..TI17FNC values ('ESPD1800',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_FCES','${DFILP}/${ENV_PREFIX}_ESPT0000_FCES.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_FPLC','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_EPOCONS','${DFILI}/${ENV_PREFIX}_ESPD0060_EPOCONS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_EPOSOCI','${DFILI}/${ENV_PREFIX}_ESPD0060_EPOSOCI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_FTRSLNK','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_EPOSIICO','${DFILI}/${ENV_PREFIX}_ESPD0060_EPOSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_EPOSIISO','${DFILI}/${ENV_PREFIX}_ESPD0060_EPOSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSN.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESPT0000_FCURCVSNI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLATXCUM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_FTRANSCODE','${DFILP}/${ENV_PREFIX}_ESPT0000_FTRANSCODE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_IADVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIRDVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTRCO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTRSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTAACO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAACO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTAASO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTARCO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTARSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTRSIICO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTAASIICO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTARSIICO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD1800',  'EPO_DLSGTARSIISO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARSIISO.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2070
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2070')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2070'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2070'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2070')

	insert into BEST..TI17CHN values ('ESID2070',  '')

		--  ESID2070 

	insert into BEST..TI17FNC values ('ESID2070',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_IGTR00','${DFILP}/${ENV_PREFIX}_ESIJ7000_IGTR00.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_IGTAA00','${DFILP}/${ENV_PREFIX}_ESIJ7000_IGTAA00.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_ARCSTATGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FCTRFIC','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCTRFIC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FINTWIT','${DFILI}/${ENV_PREFIX}_ESID0060_FINTWIT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FLSTMTH','${DFILI}/${ENV_PREFIX}_ESID0060_FLSTMTH_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FSEGPAR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSEGPAR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FVCTRGRO','${DFILI}/${ENV_PREFIX}_ESEH1110_FVCTRGRO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FCESSION0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCESSION0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FCESSION1','${DFILI}/${ENV_PREFIX}_ESEH1110_FCESSION1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FDEPOSIT0','${DFILI}/${ENV_PREFIX}_ESID0060_FDEPOSIT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FPFUNWIT0','${DFILI}/${ENV_PREFIX}_ESID0060_FPFUNWIT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FPINTWIT0','${DFILI}/${ENV_PREFIX}_ESID0060_FPINTWIT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FPLACEMT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FPLACEMT1','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_VTSTATGTA0','${DFILI}/${ENV_PREFIX}_ESID1010_VTSTATGTA0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FLIFDRI','${DFILI}/${ENV_PREFIX}_ESCJ0060_FLIFDRI${IT}_ALL_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_IRVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FLIFEST0','`if [ "${IT}" = "Q" ];then CH="2";else CH="3";fi;echo "${DFILI}/${ENV_PREFIX}_ESID01${CH}0_FLIFEST${IT}0_${CLODAT}.dat";`','I','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_SEGRATANO','${DFILI}/${ENV_PREFIX}_ESID2070_SEGRATANO_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_CRIBLEANO','${DFILI}/${ENV_PREFIX}_ESID2070_CRIBLEANO${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FVPLACEMT','${DFILI}/${ENV_PREFIX}_ESID2070_FVPLACEMT${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_LIFENDCPT','${DFILI}/${ENV_PREFIX}_ESID2070_LIFENDCPT${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_LIFESTANA','${DFILI}/${ENV_PREFIX}_ESID2070_LIFESTANA${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_LIFESTLIB','${DFILI}/${ENV_PREFIX}_ESID2070_LIFESTLIB${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FVPLACEMT1','${DFILI}/${ENV_PREFIX}_ESID2070_FVPLACEMT1${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FVPLACEMT2','${DFILI}/${ENV_PREFIX}_ESID2070_FVPLACEMT2${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_ERRUPDBATCH','${DFILI}/${ENV_PREFIX}_ESID2070_ERRUPDBATCH${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_LIFESTNOACC','${DFILI}/${ENV_PREFIX}_ESID2070_LIFESTNOACC${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_VLIFEST2070','${DFILI}/${ENV_PREFIX}_ESID2070_VLIFEST2070${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_FRATTACHEVOL','${DFILI}/${ENV_PREFIX}_ESID2070_FRATTACHEVOL${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_310_SORT_GT_O','${DFILI}/${ENV_PREFIX}_ESID2070_310_SORT_GT${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_430_SORT_GT_O','${DFILI}/${ENV_PREFIX}_ESID2070_430_SORT_GT${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_470_SORT_GT_O','${DFILI}/${ENV_PREFIX}_ESID2070_470_SORT_GT${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID2070_IARVPERICASE0${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESID2070_IARVPERICASE4${IT}_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_160_SORT_CPLACC_O','${DFILI}/${ENV_PREFIX}_ESID2070_160_SORT_CPLACC${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_180_SORT_LSTMTH_O','${DFILI}/${ENV_PREFIX}_ESID2070_180_SORT_LSTMTH${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_ESTC2035_LIFDRI_O1','${DFILI}/${ENV_PREFIX}_ESID2070_ESTC2035_LIFDRI${IT}_O1_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_200_ESTC2034_GTB1_O','${DFILI}/${ENV_PREFIX}_ESID2070_200_ESTC2034_GTB1${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_31_SORT_R_IAVPERICASE_O','${DFILI}/${ENV_PREFIX}_ESID2070_31_SORT_R_IAVPERICASE${IT}_O_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2070',  'EST_180_ESTC2040_OLD_LIFEST_O2','${DFILI}/${ENV_PREFIX}_ESID2070_180_ESTC2040_OLD_LIFEST${IT}_O2_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  DWUD9130
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='DWUD9130')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='DWUD9130'
	delete BEST..TI17CHN  where CHAIN_CT='DWUD9130'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='DWUD9130')

	insert into BEST..TI17CHN values ('DWUD9130',  '')

		--  DWUD9130 

	insert into BEST..TI17FNC values ('DWUD9130',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('DWUD9130',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD9130',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD9130',  'EPO_FTECLEDASO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD9130',  'EPO_FTECLEDRSO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD9130',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD9130',  'EPO_FTECLEDRSIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESIJ7000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESIJ7000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESIJ7000'
	delete BEST..TI17CHN  where CHAIN_CT='ESIJ7000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESIJ7000')

	insert into BEST..TI17CHN values ('ESIJ7000',  '')

		--  ESIJ7000 

	insert into BEST..TI17FNC values ('ESIJ7000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_FDRYTRN','${DFILI}/${ENV_PREFIX}_ESIX7000_FDRYTRN.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_FRTOSTA','${DFILP}/${ENV_PREFIX}_RTCJ0500_FRTOSTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_STATGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_FACCTRTGT','${DFILP}/${ENV_PREFIX}_RTCJ0500_FACCTRTGT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_GTASW','${DFILP}/${ENV_PREFIX}_ESIJ7000_GTASW.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_GTRSW','${DFILP}/${ENV_PREFIX}_ESIJ7000_GTRSW.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_IGTR00','${DFILP}/${ENV_PREFIX}_ESIJ7000_IGTR00.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESIJ7000',  'EST_IGTAA00','${DFILP}/${ENV_PREFIX}_ESIJ7000_IGTAA00.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD8000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD8000'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8000')

	insert into BEST..TI17CHN values ('ESPD8000',  'Reload FCTREST data')

		--  ESPD8000_POCE 

	insert into BEST..TI17FNC values ('ESPD8000_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD8000_POCE',  'EPO_FCTREST0','${DFILP}/${PCH}ESPD0060_FCTREST0_EBS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8000_POCE',  'EPO_FCTREST1','${DFILP}/${PCH}ESID2210_FCTREST1SIICO.dat','I','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESPD8000','ESPD8000_POCE','POCE')

		--  ESPD8000_POSE 

	insert into BEST..TI17FNC values ('ESPD8000_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD8000_POSE',  'EPO_FCTREST0','${DFILP}/${PCH}ESPD0060_FCTREST0_EBS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8000_POSE',  'EPO_FCTREST1','${DFILP}/${PCH}ESID2210_FCTREST1SIISO.dat','I','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESPD8000','ESPD8000_POSE','POSE')

go


-------------------------------
--	Init  ESID8830
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8830')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8830'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8830'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8830')

	insert into BEST..TI17CHN values ('ESID8830',  '')

		--  ESID8830 

	insert into BEST..TI17FNC values ('ESID8830',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_DLTOTGTRC','${DFILI}/${ENV_PREFIX}_ESID7000_DLTOTGTRC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_DLTOTGTAAC','${DFILI}/${ENV_PREFIX}_ESID7000_DLTOTGTAAC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_DLTOTGTARC','${DFILI}/${ENV_PREFIX}_ESID7000_DLTOTGTARC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8830',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_${CLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  DWUD0130
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='DWUD0130')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='DWUD0130'
	delete BEST..TI17CHN  where CHAIN_CT='DWUD0130'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='DWUD0130')

	insert into BEST..TI17CHN values ('DWUD0130',  '')

		--  DWUD0130 

	insert into BEST..TI17FNC values ('DWUD0130',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('DWUD0130',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD0130',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD0130',  'EPO_FTECLEDASO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD0130',  'EPO_FTECLEDRSO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD0130',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('DWUD0130',  'EPO_FTECLEDRSIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3650
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3650')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3650'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3650'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3650')

	insert into BEST..TI17CHN values ('ESFD3650',  'Risk Adjustment')

		--  I17G_RAD_CUR_STD 

	insert into BEST..TI17FNC values ('I17G_RAD_CUR_STD',  'Risk Adjustment current rate')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'EPO_FCTRGRO','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_FMARKET','${DFILI}/${PCH}ESFD0060_FMARKET.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_FUWRETSEC','${DFILP}/${PCH}ESFD0060_FUWRETSEC.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'EPO_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'EPO_IRDPERICASE0','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'EPO_FSEGPATTERN_ICR','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_FRARAT','${DFILP}/${PCH}ESFD0060_I17G____RARAT_${param_Context_id}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_GTSII_RMTP_ULAE','${DFILI}/${PCH}ESFD3650_I17G_RAD_CUR_STD_GTSII_RMTP_ULAE.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_GTSII_CASHFLOW_WK','${DFILI}/${PCH}ESFD3650_I17G_RAD_CUR_STD_GTSII_CASHFLOW_WK.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_GTSII_RMTP_ULAEINF','${DFILI}/${PCH}ESFD3650_I17G_RAD_CUR_STD_GTSII_RMTP_ULAEINF.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_GTSII_CASHFLOW','${DFILP}/${PCH}ESFD3650_I17G_RAD_CUR_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3650','I17G_RAD_CUR_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3650','I17G_RAD_CUR_STD','')

		--  I17G_RAD_CSF_INI 

	insert into BEST..TI17FNC values ('I17G_RAD_CSF_INI',  'RA at lock in rate CSF')

	----------  Perms---------------------


	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3650','I17G_RAD_CSF_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3650','I17G_RAD_CSF_INI','')

		--  I17G_RAD_CKI_STD 

	insert into BEST..TI17FNC values ('I17G_RAD_CKI_STD',  'Risk Adjustment lock in rate')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'EPO_FCTRGRO','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_FMARKET','${DFILI}/${PCH}ESFD0060_FMARKET.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_FUWRETSEC','${DFILP}/${PCH}ESFD0060_FUWRETSEC.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'EPO_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'EPO_IRDPERICASE0','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'EPO_FSEGPATTERN_ICR','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_FRARAT','${DFILP}/${PCH}ESFD0060_I17G____RARAT_${param_Context_id}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_GTSII_RMTP_ULAE','${DFILI}/${PCH}ESFD3650_I17G_RAD_CKI_STD_GTSII_RMTP_ULAE.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_GTSII_CASHFLOW_WK','${DFILI}/${PCH}ESFD3650_I17G_RAD_CKI_STD_GTSII_CASHFLOW_WK.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_GTSII_RMTP_ULAEINF','${DFILI}/${PCH}ESFD3650_I17G_RAD_CKI_STD_GTSII_RMTP_ULAEINF.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_GTSII_CASHFLOW','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3650','I17G_RAD_CKI_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3650','I17G_RAD_CKI_STD','')

		--  I17G_RAD_CKI_INI 

	insert into BEST..TI17FNC values ('I17G_RAD_CKI_INI',  'RA at inception')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'EPO_IRDPERICASE0','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'EPO_FCTRGRO','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_FMARKET','${DFILI}/${PCH}ESFD0060_FMARKET.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_FUWRETSEC','${DFILP}/${PCH}ESFD0060_FUWRETSEC.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'EPO_IADPERICASE','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'EPO_FSEGPATTERN_ICR','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_ICR.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_FRARAT','${DFILP}/${PCH}ESFD0060_I17G____RARAT_${param_Context_id}_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_GTSII_RMTP_ULAE','${DFILI}/${PCH}ESFD3650_I17G_RAD_CKI_INI_GTSII_RMTP_ULAE.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_GTSII_CASHFLOW_WK','${DFILI}/${PCH}ESFD3650_I17G_RAD_CKI_INI_GTSII_CASHFLOW_WK.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_GTSII_RMTP_ULAEINF','${DFILI}/${PCH}ESFD3650_I17G_RAD_CKI_INI_GTSII_RMTP_ULAEINF.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_GTSII_CASHFLOW','${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_INI_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3650','I17G_RAD_CKI_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3650','I17G_RAD_CKI_INI','')

go


-------------------------------
--	Init  STPD1280
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STPD1280')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='STPD1280'
	delete BEST..TI17CHN  where CHAIN_CT='STPD1280'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STPD1280')

	insert into BEST..TI17CHN values ('STPD1280',  '')

		--  STPD1280 

	insert into BEST..TI17FNC values ('STPD1280',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('STPD1280',  'EPO_LIFSTAREP_BRIDG','${DFILP}/${ENV_PREFIX}_STPD1500_LIFSTAREP_BRIDG.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID8030
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8030')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8030'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8030'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8030')

	insert into BEST..TI17CHN values ('ESID8030',  '')

		--  ESID8030 

	insert into BEST..TI17FNC values ('ESID8030',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_FLIFMOD','${DFILI}/${ENV_PREFIX}_ESID1530_FLIFMOD_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_FLIFPEN','${DFILI}/${ENV_PREFIX}_ESID1530_FLIFPEN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_FLIFMOD2','${DFILI}/${ENV_PREFIX}_ESID1530_FLIFMOD2_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_CPLIFDRI','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRIY_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_CPLIFDRIQ','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRIQ_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_FRATTACHEVOL','${DFILI}/${ENV_PREFIX}_ESID2030_FRATTACHEVOL_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_CPLIFEST_MVT','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFEST_MVTY_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8030',  'EST_CPLIFEST_MVTQ','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFEST_MVTQ_${CLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID1800
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1800')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID1800'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1800'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1800')

	insert into BEST..TI17CHN values ('ESID1800',  '')

		--  ESID1800 

	insert into BEST..TI17FNC values ('ESID1800',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FACCSUP','${DFILI}/${ENV_PREFIX}_ESID0560_FACCSUP_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_DLSGTR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_DLSGTAA','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1800',  'EST_DLSGTAR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAR_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD8800
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8800')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD8800'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8800'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8800')

	insert into BEST..TI17CHN values ('ESPD8800',  '')

		--  ESPD8800 

	insert into BEST..TI17FNC values ('ESPD8800',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD8800',  'EPO_FTECLEDASO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8800',  'EPO_FTECLEDRSO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8800',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8800',  'EPO_FTECLEDRSIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3710
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3710')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3710'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3710'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3710')

	insert into BEST..TI17CHN values ('ESFD3710',  'CSM at inception')

		--  I17G_CSM_CSU_INI 

	insert into BEST..TI17FNC values ('I17G_CSM_CSU_INI',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CSU_INI',  'ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CSU_INI',  'ESF_GTSII_CSM','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3710','I17G_CSM_CSU_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3710','I17G_CSM_CSU_INI','')

go


-------------------------------
--	Init  ESPD2900
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD2900')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD2900'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD2900'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD2900')

	insert into BEST..TI17CHN values ('ESPD2900',  '')

		--  ESPD2900 

	insert into BEST..TI17FNC values ('ESPD2900',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_FDETTRS','${DFILP}/${ENV_PREFIX}_ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLSGTRSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLRGTAASO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLRGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLSGTAASO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLSGTARSO','${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_FPLATXCUM','${DFILP}/${ENV_PREFIX}_ESPT0000_FPLATXCUM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREMAJGTRSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREMAJGTARSO','${DFILP}/${ENV_PREFIX}_ESPD2550_DLREMAJGTARSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_FTECLEDRSIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREJGTRSO','${DFILI}/${ENV_PREFIX}_ESPD2900_DLREJGTRSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREJGTAASO','${DFILI}/${ENV_PREFIX}_ESPD2900_DLREJGTAASO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREJGTARSO','${DFILI}/${ENV_PREFIX}_ESPD2900_DLREJGTARSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREJGTRSIISO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTRSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREJGTAASIISO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTAASIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD2900',  'EPO_DLREJGTARSIISO','${DFILP}/${ENV_PREFIX}_ESPD2900_DLREJGTARSIISO.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID3700
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3700')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID3700'
	delete BEST..TI17CHN  where CHAIN_CT='ESID3700'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID3700')

	insert into BEST..TI17CHN values ('ESID3700',  '')

		--  ESID3700 

	insert into BEST..TI17FNC values ('ESID3700',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_IGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTAR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_IGTAAF','${DFILI}/${ENV_PREFIX}_ESID0560_IGTAAF_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FCURSII','${DFILI}/${ENV_PREFIX}_ESID0060_FCURSII_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLAGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLAGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLSGTAA','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLSGTAR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLREGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLRPGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLRTGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLRNPGTAR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLRTCGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLRTFGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FRATINGRTO','${DFILI}/${ENV_PREFIX}_ESID0060_FRATINGRTO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLREMAJGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTAR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_IADPERICASE','${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_IRDPERICASE0','${DFILI}/${ENV_PREFIX}_ESID0060_IRDPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FPLATXCUMALL','${DFILI}/${ENV_PREFIX}_ESID0560_FPLATXCUMALL_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FSEGPATTERN_BDT','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_BDT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FSEGPATTERN_CSF','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_CSF_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FSEGPATTERN_DSC','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_DSC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FSEGPATTERN_ICR','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_ICR_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FSEGPATTERN_INF','${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_INF_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESID3700_FTECLEDSII.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLDSIIGTR','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLDSIIGTAA','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTAA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLDSIIGTAR','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTAR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID3700',  'EST_DLEIFTECLEDSII','${DFILP}/${ENV_PREFIX}_ESID3700_DLEIFTECLEDSII_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2500
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2500')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2500'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2500'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2500')

	insert into BEST..TI17CHN values ('ESID2500',  '')

		--  ESID2500 

	insert into BEST..TI17FNC values ('ESID2500',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_IGTAAF','${DFILI}/${ENV_PREFIX}_ESID0560_IGTAAF_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_MVTPNA','${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FRETPAR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FRETPAR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FRETTRF','${DFILP}/${ENV_PREFIX}_ESCJ0060_FRETTRF_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FCESSION','${DFILI}/${ENV_PREFIX}_ESID0560_FCESSION_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FOUTTRAA','${DFILI}/${ENV_PREFIX}_ESID0560_FOUTTRAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FOUTTRAI','${DFILI}/${ENV_PREFIX}_ESID0560_FOUTTRAI_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FPLACEMT','${DFILI}/${ENV_PREFIX}_ESID0560_FPLACEMT_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FPLACEMT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FPLACEMTCOM','${DFILI}/${ENV_PREFIX}_ESID0560_FPLACEMTCOM_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IRDVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLREGTR_PC','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREGTR_${PARM0_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRGTAA_PC','${DFILI}/${ENV_PREFIX}_ESID2050_I4_PC___DLRGTAA_${PARM0_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLREGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRPGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRTGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FPLCCOM','${DFILP}/${ENV_PREFIX}_ESID2500_FPLCCOM_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLREGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTAR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRPGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTAR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRTCGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRTFGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRTGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTAR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FCES_NEW','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_NEW_${ICLODAT2}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRTCGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTAR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRTFGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTAR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLREMAJGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLREMAJGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTAR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FBESTCONPAR','${DFILI}/${ENV_PREFIX}_ESID2500_FBESTCONPAR_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FBESTCESSION','${DFILI}/${ENV_PREFIX}_ESID2500_FBESTCESSION_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLREMAJGTR_PC','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREMAJGTR_${PARM0_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESDJ8040
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ8040')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESDJ8040'
	delete BEST..TI17CHN  where CHAIN_CT='ESDJ8040'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESDJ8040')

	insert into BEST..TI17CHN values ('ESDJ8040',  '')

		--  ESDJ8040 

	insert into BEST..TI17FNC values ('ESDJ8040',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_FCURQUOT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_TCALL','${DFILI}/${ENV_PREFIX}_ESDJ0110_TCALL_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESDJ1010_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_TGAPTHR','${DFILI}/${ENV_PREFIX}_ESDJ0110_TGAPTHR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SRGTC','${DFILI}/${ENV_PREFIX}_ESDJ7010_SRGTC${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_FACCPAR0','${DFILI}/${ENV_PREFIX}_ESDJ1010_FACCPAR0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SUBTRSASSO','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSASSO_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_CPLIFDRI','${DFILI}/${ENV_PREFIX}_ESDJ7010_CPLIFDRI${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_VLIFEST195','${DFILI}/${ENV_PREFIX}_ESDJ7010_VLIFEST195${IT}_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESDJ1010_IARVPERICASE4_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SUBTRSESBPROP','${DFILI}/${ENV_PREFIX}_ESDJ1010_SUBTRSESBPROP_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SRGTE','${DFILI}/${ENV_PREFIX}_ESDJ8040_SRGTE${IT}_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_SIGNANO','${DFILI}/${ENV_PREFIX}_ESDJ8040_SIGNANO${IT}_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_CMPCALC','${DFILI}/${ENV_PREFIX}_ESDJ8040_CMPCALC_PC${IT}_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESDJ8040',  'EST_CMPCALC_PC','${DFILI}/${ENV_PREFIX}_ESDJ8040_CMPCALC_PC${IT}_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID1000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID1000'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1000')

	insert into BEST..TI17CHN values ('ESID1000',  '')

		--  ESID1000 

	insert into BEST..TI17FNC values ('ESID1000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IADPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IAVPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_OADPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_OADPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_OAVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID0060_OAVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IADPERICASE_ENTIER0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_ENTIER0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_OADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_OADVPERICASE0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1000',  'EST_IADVPERICASE_ENTIER0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE_ENTIER0_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID1530
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1530')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID1530'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1530'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1530')

	insert into BEST..TI17CHN values ('ESID1530',  '')

		--  ESID1530 

	insert into BEST..TI17FNC values ('ESID1530',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FLIFTHR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FLIFTHR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_CPLIFDRI','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFDRI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_CPLIFEST','${DFILI}/${ENV_PREFIX}_ESID2030_CPLIFEST_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FLIFMOD','${DFILI}/${ENV_PREFIX}_ESID1530_FLIFMOD_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FLIFPEN','${DFILI}/${ENV_PREFIX}_ESID1530_FLIFPEN_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1530',  'EST_FLIFMOD2','${DFILI}/${ENV_PREFIX}_ESID1530_FLIFMOD2_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESLD8700
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD8700')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESLD8700'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD8700'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD8700')

	insert into BEST..TI17CHN values ('ESLD8700',  '')

		--  ESLD8700 

	insert into BEST..TI17FNC values ('ESLD8700',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_FTECLEDALO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDALO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_EPOSOCLO_CUR','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_CUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_DLREJGTRLO_CUR','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO_CUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_FTECLEDALO_MTH','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDALO_MTH.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_FTECLEDALO_MVT','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDALO_MVT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_DLREJGTAALO_CUR','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO_CUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_DLREJGTARLO_CUR','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO_CUR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_EPOSOCLO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLJ0090_EPOSOCLO_CURNEW.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_DLREJGTRLO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO_CURNEW.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_DLREJGTAALO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO_CURNEW.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD8700',  'ESL_DLREJGTARLO_CURNEW','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO_CURNEW.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2060
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2060')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2060'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2060'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2060')

	insert into BEST..TI17CHN values ('ESID2060',  '')

		--  ESID2060 

	insert into BEST..TI17FNC values ('ESID2060',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_MGTAA','${DFILP}/${ENV_PREFIX}_ESIX7000_MGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_IGTAAF','${DFILI}/${ENV_PREFIX}_ESID0560_IGTAAF_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLAGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLSGTAA','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_MVTPNAC','${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNAC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLASIIGTAA','${DFILI}/${ENV_PREFIX}_ESID3600_DLASIIGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLDSIIGTAA','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLGTAASNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTAASNEM_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLVGTAA','`ls -rt ${DFILP}/${ENV_PREFIX}_ESID2080_DLVGTAA_PC_${PARM0_ICLODAT_D}*.dat | tail -1 `','I','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_TOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_TOTGTAA_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLTOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_DLTOTGTAA_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLTOTITGTAR','${DFILI}/${ENV_PREFIX}_ESID2060_DLTOTITGTAR_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2100
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2100')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2100'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2100'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2100')

	insert into BEST..TI17CHN values ('ESID2100',  '')

		--  ESID2100 

	insert into BEST..TI17FNC values ('ESID2100',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FSNEMHIST','${DFILP}/${ENV_PREFIX}_ESID0560_FSNEMHIST_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_FLOARATSNEM','${DFILP}/${ENV_PREFIX}_ESID2000_FLOARATSNEM_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DSUMGTAASNEM','${DFILP}/${ENV_PREFIX}_ESID2000_DSUMGTAASNEM_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_PERICASESNEM','${DFILP}/${ENV_PREFIX}_ESID2000_PERICASESNEM_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLGTRSNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTRSNEM_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLGTAASNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTAASNEM_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLGTARSNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTARSNEM_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2100',  'EST_DLFTSNEMHIST','${DFILI}/${ENV_PREFIX}_ESID2100_DLFTSNEMHIST_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  DWUD0030
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='DWUD0030')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='DWUD0030'
	delete BEST..TI17CHN  where CHAIN_CT='DWUD0030'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='DWUD0030')

	insert into BEST..TI17CHN values ('DWUD0030',  '')

		--  DWUD0030 

	insert into BEST..TI17FNC values ('DWUD0030',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('DWUD0030',  'EST_FCALEND','${DFILI}/${ENV_PREFIX}_ESID0060_FCALEND_${CLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD4000
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD4000')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD4000'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD4000'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD4000')

	insert into BEST..TI17CHN values ('ESPD4000',  '')

		--  ESPD4000 

	insert into BEST..TI17FNC values ('ESPD4000',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD4000',  'EPO_GTEPCO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD4000',  'EPO_GTEPSO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD4000',  'EPO_GTEPSIICO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD4000',  'EPO_GTEPSIISO','${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD4000',  'EPO_DLEIFTECLEDSIIEPCO','${DFILP}/${ENV_PREFIX}_ESPD4000_DLEIFTECLEDSIIEPCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD4000',  'EPO_DLEIFTECLEDSIIEPSO','${DFILP}/${ENV_PREFIX}_ESPD4000_DLEIFTECLEDSIIEPSO.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESIJ0090
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESIJ0090')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESIJ0090'
	delete BEST..TI17CHN  where CHAIN_CT='ESIJ0090'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESIJ0090')

	insert into BEST..TI17CHN values ('ESIJ0090',  '')

		--  ESIJ0090 

	insert into BEST..TI17FNC values ('ESIJ0090',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESIJ0090',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${CLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD1130
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD1130')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD1130'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD1130'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD1130')

	insert into BEST..TI17CHN values ('ESFD1130',  'Data extraction')

		--  I17G_DSC_ALL_STD 

	insert into BEST..TI17FNC values ('I17G_DSC_ALL_STD',  'Data extraction')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_DSC_ALL_STD',  'ESF_TRERETFACCTR','${DFILP}/${PCH}ESFD1130_TRERETFACCTR.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_ALL_STD',  'ESF_FRERETFACCTR_INI','${DFILP}/${PCH}ESFD1130_FRERETFACCTR_INI.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_DSC_ALL_STD',  'ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD1130','I17G_DSC_ALL_STD','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD1130','I17G_DSC_ALL_STD','')

go


-------------------------------
--	Init  ESID7050
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID7050')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID7050'
	delete BEST..TI17CHN  where CHAIN_CT='ESID7050'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID7050')

	insert into BEST..TI17CHN values ('ESID7050',  '')

		--  ESID7050 

	insert into BEST..TI17FNC values ('ESID7050',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLREJGTR','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLTOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_DLTOTGTR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLREJGTAA','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLREJGTAR','${DFILI}/${ENV_PREFIX}_ESID2900_DLREJGTAR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLTOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_DLTOTGTAA_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_DLTOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_DLTOTGTAR_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_CADVPERIESB0','${DFILI}/${ENV_PREFIX}_ESID0060_CADVPERIESB0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_IGTA','${DFILI}/${ENV_PREFIX}_ESID7050_IGTA_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_IGTR','${DFILI}/${ENV_PREFIX}_ESID7050_IGTR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_CMGTR','${DFILP}/${ENV_PREFIX}_ESID7050_CMGTR_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_CMGTAA','${DFILP}/${ENV_PREFIX}_ESID7050_CMGTAA_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID7050',  'EST_CMGTAR','${DFILP}/${ENV_PREFIX}_ESID7050_CMGTAR_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID8100
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8100')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8100'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8100'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8100')

	insert into BEST..TI17CHN values ('ESID8100',  '')

		--  ESID8100 

	insert into BEST..TI17FNC values ('ESID8100',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8100',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8100',  'ESL_FTECLEDALO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDALO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8100',  'ESL_FTECLEDRLO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDRLO.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESFD3720
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3720')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESFD3720'
	delete BEST..TI17CHN  where CHAIN_CT='ESFD3720'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD3720')

	insert into BEST..TI17CHN values ('ESFD3720',  'IFRS17 - Group - UOA definition at inception')

		--  I17G_CSM_CRE_INI 

	insert into BEST..TI17FNC values ('I17G_CSM_CRE_INI',  'IFRS17 - Group - UOA definition at inception')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI',  'ESF_IADPERICASE_INI','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FRERETFACCTR_INI','${DFILP}/${PCH}ESFD1130_FRERETFACCTR_INI.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI',  'EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FUOASII','${DFILI}/${ENV_PREFIX}_ESFD0060_I17G___TUOASII_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI',  'ESF_GTSII_CSM','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI',  'ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FCR','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FCR.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FSECIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FSECIFRS.dat','O','')
		insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI',  'ESF_FSEGPROF','${DFILP}/${PCH}ESFD3720_I17G_CSM_CRE_INI_FSEGPROF_${PARM_ICLODAT_D}.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD3720','I17G_CSM_CRE_INI','IFRS17 - G')
		insert into BEST..TI17REQCHN values ('I17GMINVB',  'ESFD3720','I17G_CSM_CRE_INI','IFRS17 - G')
		insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD3720','I17G_CSM_CRE_INI','IFRS17 - G')
		insert into BEST..TI17REQCHN values ('I17GMPOCB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD3720','I17G_CSM_CRE_INI','IFRS17 - G')
		insert into BEST..TI17REQCHN values ('I17GMPOSB',  'ESFD3720','I17G_CSM_CRE_INI','IFRS17 - G')
		insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQINVB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOCB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GQPOSB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYINVB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOCB',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD3720','I17G_CSM_CRE_INI','')
		insert into BEST..TI17REQCHN values ('I17GYPOSB',  'ESFD3720','I17G_CSM_CRE_INI','')

go


-------------------------------
--	Init  STAD1530
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD1530')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='STAD1530'
	delete BEST..TI17CHN  where CHAIN_CT='STAD1530'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STAD1530')

	insert into BEST..TI17CHN values ('STAD1530',  '')

		--  STAD1530 

	insert into BEST..TI17FNC values ('STAD1530',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('STAD1530',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1530',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1530',  'STA_LIFSTAREP','${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1530',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1530',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('STAD1530',  'STA_LIFINVDIF','${DFILP}/${ENV_PREFIX}_STAD1530_LIFINVDIF.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2210
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2210')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2210'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2210'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2210')

	insert into BEST..TI17CHN values ('ESID2210',  'IFRS Losses and IBNR calculation')

		--  ESID2210_POCE 

	insert into BEST..TI17FNC values ('ESID2210_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FT','${DFILP}/${PCH}ESPT0000_FT_EBS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FTFAC','${DFILP}/${PCH}ESPT0000_FTFAC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLCGTAA','${DFILP}/${PCH}ESPT0000_DLCGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FCTRULT','${DFILP}/${PCH}ESPT0000_FCTRULT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_LABOCY1','${DFILP}/${PCH}ESPT0000_LABOCY1.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLGTAAPA','${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FCTRGRO1','${DFILP}/${PCH}ESPT0000_FCTRGRO1.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FTFAMCHG','${DFILP}/${PCH}ESPT0000_FTFAMCHG.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FTTR_PRM','${DFILP}/${PCH}ESPT0000_FTTR_PRM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DCGTAALOA','${DFILP}/${PCH}ESPT0000_DCGTAALOA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLCUMGTAA','${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLGTAAPRE','${DFILP}/${PCH}ESPT0000_DLGTAAPRE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_IADPERIFR','${DFILP}/${PCH}ESPT0000_IADPERIFR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EPO_FCTREST','${DFILP}/${PCH}ESPD0060_FCTRESTSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EPO_FCTREST0','${DFILP}/${PCH}ESPD0060_FCTREST0_EBS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLCGTAAREC','${DFILP}/${PCH}ESPT0000_DLCGTAAREC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLCUMGTAAS','${DFILP}/${PCH}ESPT0000_DLCUMGTAAS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLGTAAFPRE','${DFILP}/${PCH}ESPT0000_DLGTAAFPRE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLGTAARPPE','${DFILP}/${PCH}ESPT0000_DLGTAARPPE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DTSTATGTAA','${DFILP}/${PCH}ESPT0000_DTSTATGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FTHRHLDUWY','${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_IADPERIFCI','${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_IADPERIFCT','${DFILP}/${PCH}ESPT0000_IADPERIFCT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EPO_FCTRESTA','${DFILP}/${PCH}ESPD0060_FCTRESTASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLCGTAAEPPE','${DFILP}/${PCH}ESPT0000_DLCGTAAEPPE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLGTAATFPNAE','${DFILP}/${PCH}ESPT0000_DLGTAATFPNAE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FSEGEST','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_IBNR','${DFILP}/${PCH}ESID2210_IBNR_EBSCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FLOARAT','${DFILP}/${PCH}ESID2210_FLOARAT_EBS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_FPRMLOA','${DFILP}/${PCH}ESID2210_FPRMLOA_EBSCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EPO_FCTREST1','${DFILP}/${PCH}ESID2210_FCTREST1SIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLCUMGTAATOT','${DFILI}/${PCH}ESID2210_DLCUMGTAATOTCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_CTRESTLOSPBPAP','${DFILI}/${PCH}ESID2210_CTRESTLOSPBPAPCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_DLDGTAA_CUMULS_COUR','${DFILP}/${PCH}ESID2210_DLDGTAASIICO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EST_BLANCHIMENT_RPCC','${DFILP}/${PCH}ESID2210_BLANCHIMENT_RPCCSIICO.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESID2210','ESID2210_POCE','POCE')

		--  ESID2210_POSE 

	insert into BEST..TI17FNC values ('ESID2210_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FT','${DFILP}/${PCH}ESPT0000_FT_EBS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FTFAC','${DFILP}/${PCH}ESPT0000_FTFAC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLCGTAA','${DFILP}/${PCH}ESPT0000_DLCGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FCTRULT','${DFILP}/${PCH}ESPT0000_FCTRULT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_LABOCY1','${DFILP}/${PCH}ESPT0000_LABOCY1.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLGTAAPA','${DFILP}/${PCH}ESPT0000_DLGTAAPA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FCTRGRO1','${DFILP}/${PCH}ESPT0000_FCTRGRO1.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FTFAMCHG','${DFILP}/${PCH}ESPT0000_FTFAMCHG.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FTTR_PRM','${DFILP}/${PCH}ESPT0000_FTTR_PRM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DCGTAALOA','${DFILP}/${PCH}ESPT0000_DCGTAALOA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLCUMGTAA','${DFILP}/${PCH}ESPT0000_DLCUMGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLGTAAPRE','${DFILP}/${PCH}ESPT0000_DLGTAAPRE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_IADPERIFR','${DFILP}/${PCH}ESPT0000_IADPERIFR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EPO_FCTREST','${DFILP}/${PCH}ESPD0060_FCTRESTSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EPO_FCTREST0','${DFILP}/${PCH}ESPD0060_FCTREST0_EBS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLCGTAAREC','${DFILP}/${PCH}ESPT0000_DLCGTAAREC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLCUMGTAAS','${DFILP}/${PCH}ESPT0000_DLCUMGTAAS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLGTAAFPRE','${DFILP}/${PCH}ESPT0000_DLGTAAFPRE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLGTAARPPE','${DFILP}/${PCH}ESPT0000_DLGTAARPPE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DTSTATGTAA','${DFILP}/${PCH}ESPT0000_DTSTATGTAA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FTHRHLDUWY','${DFILP}/${PCH}ESPT0000_FTHRHLDUWY.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_IADPERIFCI','${DFILP}/${PCH}ESPT0000_IADPERIFCI.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_IADPERIFCT','${DFILP}/${PCH}ESPT0000_IADPERIFCT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EPO_FCTRESTA','${DFILP}/${PCH}ESPD0060_FCTRESTASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLCGTAAEPPE','${DFILP}/${PCH}ESPT0000_DLCGTAAEPPE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLGTAATFPNAE','${DFILP}/${PCH}ESPT0000_DLGTAATFPNAE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FSEGEST','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_IBNR','${DFILP}/${PCH}ESID2210_IBNR_EBSSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FLOARAT','${DFILP}/${PCH}ESID2210_FLOARAT_EBS.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_FPRMLOA','${DFILP}/${PCH}ESID2210_FPRMLOA_EBSSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EPO_FCTREST1','${DFILP}/${PCH}ESID2210_FCTREST1SIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLCUMGTAATOT','${DFILI}/${PCH}ESID2210_DLCUMGTAATOT.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_CTRESTLOSPBPAP','${DFILI}/${PCH}ESID2210_CTRESTLOSPBPAP.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_DLDGTAA_CUMULS_COUR','${DFILP}/${PCH}ESID2210_DLDGTAASIISO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EST_BLANCHIMENT_RPCC','${DFILP}/${PCH}ESID2210_BLANCHIMENT_RPCCSIISO.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESID2210','ESID2210_POSE','POSE')

go


-------------------------------
--	Init  ESID8900
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8900')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID8900'
	delete BEST..TI17CHN  where CHAIN_CT='ESID8900'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID8900')

	insert into BEST..TI17CHN values ('ESID8900',  '')

		--  ESID8900 

	insert into BEST..TI17FNC values ('ESID8900',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID8900',  'EST_FCTRSTAT','${DFILP}/${ENV_PREFIX}_ESID3900_FCTRSTAT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID8900',  'EST_FSEGSTAT','${DFILP}/${ENV_PREFIX}_ESID3900_FSEGSTAT.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID1010
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1010')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID1010'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1010'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1010')

	insert into BEST..TI17CHN values ('ESID1010',  '')

		--  ESID1010 

	insert into BEST..TI17FNC values ('ESID1010',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_STATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_ARCSTATGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_IADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_IRDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_IRDVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_VTSTATGTA0','${DFILI}/${ENV_PREFIX}_ESID1010_VTSTATGTA0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_DTSTATGTAA0','${DFILI}/${ENV_PREFIX}_ESID1010_DTSTATGTAA0_${CLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1010',  'EST_TSTATGTAANO','${DFILI}/${ENV_PREFIX}_ESID1010_TSTATGTAANO_${CLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID1520
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1520')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID1520'
	delete BEST..TI17CHN  where CHAIN_CT='ESID1520'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID1520')

	insert into BEST..TI17CHN values ('ESID1520',  '')

		--  ESID1520 

	insert into BEST..TI17FNC values ('ESID1520',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESCJ0060_GTEP.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FACCSUP','${DFILI}/${ENV_PREFIX}_ESID0560_FACCSUP_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FLIFPLN','${DFILI}/${ENV_PREFIX}_ESID0560_FLIFPLN_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FACCSUPF','${DFILI}/${ENV_PREFIX}_ESID0560_FACCSUPF_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FCESSION0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCESSION0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FPLACEMT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FVPLACEMT','${DFILI}/${ENV_PREFIX}_ESID2030_FVPLACEMT_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT2}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_IADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_IARVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_IARVPERICASE4','${DFILI}/${ENV_PREFIX}_ESID2030_IARVPERICASE4_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_IRDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_IRDVPERICASE0_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FCES','${DFILI}/${ENV_PREFIX}_ESID1520_FCES_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FPLC','${DFILI}/${ENV_PREFIX}_ESID1520_FPLC_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_ECRSRVAPC','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVAPC_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_ECRSRVRPC','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVRPC_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_ECRSRVACBP','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVACBP_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_ECRSRVRCBP','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVRCBP_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FLIFPLN1','${DFILI}/${ENV_PREFIX}_ESID1520_EST_FLIFPLN1_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FLIFPLN2','${DFILI}/${ENV_PREFIX}_ESID1520_EST_FLIFPLN2_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FLIFPLN3','${DFILI}/${ENV_PREFIX}_ESID1520_EST_FLIFPLN3_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_ECRSRVAPC_PA','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVAPC_PA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_ECRSRVRPC_PA','${DFILI}/${ENV_PREFIX}_ESID1520_ECRSRVRPC_PA_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FLIFPLN1_VENTIL','${DFILI}/${ENV_PREFIX}_ESID1520_FLIFPLN1_VENTIL_${ICLODAT}.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESID1520',  'EST_FLIFPLN3_VENTIL','${DFILI}/${ENV_PREFIX}_ESID1520_FLIFPLN3_VENTIL_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2050
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2050')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2050'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2050'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2050')

	insert into BEST..TI17CHN values ('ESID2050',  '')

		--  ESID2050 

	insert into BEST..TI17FNC values ('ESID2050',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2050',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${ICLODAT}.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  STPD1200
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STPD1200')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='STPD1200'
	delete BEST..TI17CHN  where CHAIN_CT='STPD1200'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='STPD1200')

	insert into BEST..TI17CHN values ('STPD1200',  '')

		--  STPD1200 

	insert into BEST..TI17FNC values ('STPD1200',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_CPLIFDRI','${DFILP}/${ENV_PREFIX}_ESPT0000_CPLIFDRI.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_ECRSOCAPC','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCAPC.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_ECRSOCRPC','${DFILI}/${ENV_PREFIX}_ESPD1520_ECRSOCRPC.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_FVPLACEMT','${DFILP}/${ENV_PREFIX}_ESPT0000_FVPLACEMT.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_IARVPERICASE0','${DFILP}/${ENV_PREFIX}_ESPT0000_IARVPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_EDIVIE','${DFILP}/${ENV_PREFIX}_ESPT0000_EDIVIE_${CONSOYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1200',  'STA_EDIVIE','${DFILP}/${ENV_PREFIX}_STAD1200_EDIVIE_${CONSOYEA}1231.dat','I','')
		insert into BEST..TI17PERMFIL values ('STPD1200',  'EPO_EPOVIE','${DFILP}/${ENV_PREFIX}_STPD1200_EDIVIE_${CONSOYEA}1231.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESLD3800
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD3800')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESLD3800'
	delete BEST..TI17CHN  where CHAIN_CT='ESLD3800'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESLD3800')

	insert into BEST..TI17CHN values ('ESLD3800',  '')

		--  ESLD3800 

	insert into BEST..TI17FNC values ('ESLD3800',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FCLIENT','${DFILP}/${ENV_PREFIX}_ESID7000_FCLIENT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID7000_FCPLACC.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID7000_FCTRGRO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FDETTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FSUBTRS','${DFILP}/${ENV_PREFIX}_ESID7000_FSUBTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLSGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTRLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FSOBBLOB','${DFILP}/${ENV_PREFIX}_ESID7000_FSOBBLOB.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FSSDACTR','${DFILP}/${ENV_PREFIX}_ESID7000_FSSDACTR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLSGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTAALO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLSGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1800_DLSGTARLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FPLACEMT2','${DFILP}/${ENV_PREFIX}_ESID7000_FPLACEMT2.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLREJGTRLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTRLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLREJGTAALO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTAALO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_DLREJGTARLO','${DFILP}/${ENV_PREFIX}_ESLD1900_DLREJGTARLO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_OIADVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID7000_OIRDVPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FTECLEDALO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDALO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FTECLEDRLO','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDRLO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FTECLEDALO_MTH','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDALO_MTH.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESLD3800',  'ESL_FTECLEDALO_MVT','${DFILP}/${ENV_PREFIX}_ESLD3800_FTECLEDALO_MVT.dat','O','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD8100
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8100')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD8100'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD8100'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD8100')

	insert into BEST..TI17CHN values ('ESPD8100',  '')

		--  ESPD8100 

	insert into BEST..TI17FNC values ('ESPD8100',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDACO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDASO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDRCO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDRSO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EST_FTECLEDSII','${DFILP}/${ENV_PREFIX}_ESID3700_FTECLEDSII.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDSIICO','${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDSIISO','${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDASIICO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDASIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDRSIICO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDRSIISO','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FULTIMATESSIICO','${DFILP}/${ENV_PREFIX}_ESPD0060_FULTIMATESSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FULTIMATESSIISO','${DFILP}/${ENV_PREFIX}_ESPD0060_FULTIMATESSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EST_FULTIMATES','${DFILI}/${ENV_PREFIX}_ESEH1200_FULTIMATES_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_GTSII_RISKMARGINCO','${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINCO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_GTSII_RISKMARGINSO','${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDACO_ANNULMVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO_ANNULMVT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDRCO_ANNULMVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO_ANNULMVT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDASIICO_ANNULMVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO_ANNULMVT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD8100',  'EPO_FTECLEDRSIICO_ANNULMVT','${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO_ANNULMVT.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESID2590
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2590')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESID2590'
	delete BEST..TI17CHN  where CHAIN_CT='ESID2590'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESID2590')

	insert into BEST..TI17CHN values ('ESID2590',  '')

		--  ESID2590 

	insert into BEST..TI17FNC values ('ESID2590',  '')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_FLIBEL1','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL1_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_${ICLODAT}.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${ICLODAT}.dat','I','')

	----------   Reqs of chain   ---------------------


go


-------------------------------
--	Init  ESPD3630
-------------------------------

	delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3630')
	delete BEST..TI17REQCHN where   IDF_CT = 'I17G_FUT_ALL_INI' and  CHAIN_CT='ESPD3630'
	delete BEST..TI17CHN  where CHAIN_CT='ESPD3630'
	delete BEST..TI17FNC where IDF_CT  in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESPD3630')

	insert into BEST..TI17CHN values ('ESPD3630',  'UPR cancellation job ESID3601A')

		--  ESPD3630_POCE 

	insert into BEST..TI17FNC values ('ESPD3630_POCE',  'IFRS4 Post omega conso EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_IGTAAF','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLSGTR','${DFILP}/${PCH}ESPD1800_DLSGTRSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_FPLATXCUM','${DFILP}/${PCH}ESPT0000_FPLATXCUM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLDGTAA','${DFILP}/${PCH}ESID2220_DLDGTAASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLREGTR','${DFILP}/${PCH}ESPD2550_DLREGTRSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLRGTAA','${DFILP}/${PCH}ESPD2550_DLRGTAASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLSGTAA','${DFILP}/${PCH}ESPD1800_DLSGTAASIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLSGTAR','${DFILP}/${PCH}ESPD1800_DLSGTARSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EPO_FTECLEDRSO','${DFILP}/${PCH}ESPD3800_FTECLEDRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_FTECLEDASO','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLREGTAR','${DFILP}/${PCH}ESPD2550_DLREGTARSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_FTECLEDASII','${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_IRDPERICASE0','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLREMAJGTR','${DFILP}/${PCH}ESPD2550_DLREMAJGTRSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_FTECLEDASIISO','${DFILP}/${PCH}ESPD3800_FTECLEDASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLREMAJGTAR','${DFILP}/${PCH}ESPD2550_DLREMAJGTARSIICO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLASIIGTR','${DFILP}/${PCH}ESPD3630_DLASIIGTRCO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLASIIGTAA','${DFILP}/${PCH}ESPD3630_DLASIIGTAACO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POCE',  'EST_DLASIIGTAR','${DFILP}/${PCH}ESPD3630_DLASIIGTARCO.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POCE',  'ESPD3630','ESPD3630_POCE','POCE')

		--  ESPD3630_POSE 

	insert into BEST..TI17FNC values ('ESPD3630_POSE',  'IFRS4 Post omega social EBS')

	----------  Perms---------------------

		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_FTECLEDASII','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_FTECLEDASIISO','${DFILP}/empty.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_FTRSLNK','${DFILP}/${PCH}ESPT0000_FTRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_FCURQUOT','${DFILP}/${PCH}ESPT0000_FCURQUOT.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_IGTAAF','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLSGTR','${DFILP}/${PCH}ESPD1800_DLSGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_FBOPRSLNK','${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_FPLATXCUM','${DFILP}/${PCH}ESPT0000_FPLATXCUM.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLDGTAA','${DFILP}/${PCH}ESID2220_DLDGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLREGTR','${DFILP}/${PCH}ESPD2550_DLREGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLRGTAA','${DFILP}/${PCH}ESPD2550_DLRGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLSGTAA','${DFILP}/${PCH}ESPD1800_DLSGTAASIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLSGTAR','${DFILP}/${PCH}ESPD1800_DLSGTARSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EPO_FTECLEDRSO','${DFILP}/${PCH}ESPD3800_FTECLEDRSO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_FTECLEDASO','${DFILP}/${PCH}ESPD3800_FTECLEDASO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLREGTAR','${DFILP}/${PCH}ESPD2550_DLREGTARSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_IRDPERICASE0','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLREMAJGTR','${DFILP}/${PCH}ESPD2550_DLREMAJGTRSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLREMAJGTAR','${DFILP}/${PCH}ESPD2550_DLREMAJGTARSIISO.dat','I','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLASIIGTR','${DFILP}/${PCH}ESPD3630_DLASIIGTRSO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLASIIGTAA','${DFILP}/${PCH}ESPD3630_DLASIIGTAASO.dat','O','')
		insert into BEST..TI17PERMFIL values ('ESPD3630_POSE',  'EST_DLASIIGTAR','${DFILP}/${PCH}ESPD3630_DLASIIGTARSO.dat','O','')

	----------   Reqs of chain   ---------------------

		insert into BEST..TI17REQCHN values ('POSE',  'ESPD3630','ESPD3630_POSE','POSE')

go


-------------------------------
-- drop constraints FK_REQST_REQJOB_IFRS17 and FK_REQST_REQJOBPLAN_IFRS17
-------------------------------

	alter table dbo.TI17REQJOB    add constraint FK_REQST_REQJOB_IFRS17 foreign key (REQCOD_CT)       references TI17REQ (REQCOD_CT)
	alter table dbo.TI17REQJOBPLAN    add constraint FK_REQST_REQJOBPLAN_IFRS17 foreign key (REQCOD_CT)       references TI17REQ (REQCOD_CT)
go

