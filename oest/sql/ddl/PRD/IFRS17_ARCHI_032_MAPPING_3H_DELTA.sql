
USE BEST
go


-----------------------------------------------------------------------------------------------------------
--[001] 12/12/2019 JYP/Lahcen/Arnaud : SPIRA 77477/82888  : new chain ESFD3770 bugfix ESFD3630 EST_FSEGPATTERN_CSF
--[002] 17/12/2019 Belaid/JYP : SPIRA 80491: new mapping ESID8700 EST_IADVPERICASE
--[003] 20/12/2019 Arnaud/Maxence/JYP: SPIRA 77477 : corrections mapping ESFD3770  
--[004] 10/01/2020 Belaid/Lahcen/JYP : SPIRA 80491 82884 81645: add ESPD8700/EPO_OIADVPERICASE , SPIRA 82884 81645 EPO_FTECLEDA 
--[005] 14/01/2020 spira 83904 : mehdi ask to replace  param_Context_id by TYPINV
--[006] 14/01/2020 Lilian/JYP : SPIRA 81788: add closings BookingPOSE/POCE 
--[007] 14/01/2020 CAP Cyril/JYP: SPIRA 77472 new mapping ESFD3790
--[008] 21/01/2020 Martin/JYP: SPIRA 71539 : add mapping FUTURE Retro OVERRIDE 
--[009] 29/01/2020 Linh request : SPIRA 79100 ESFD3730 : add EST_IADPERICASE_DUMMY variable
--[010] 31/01/2020 Charles request : SPIRA 82557 add I17G_CSF_ALL_INI EST_FCURQUOT_TXT et EST_FCURQUOT_TXT
--[011] 04/02/2020 Roger: SPIRA 65656 et [81496] : add ESFD2220/EPO_FCTREST/I17G_CSF_ALL_INI et I17G_FUT_ALL_INI
--[012] 14/02/2020 Lahcen request : SPIRA 79102 : new retro mapping IDF_CT I17G_IEX_ALL_STD
--[013] 14/02/2020 JYP SPIRA 79070 : cashflow retro at inception
--[014] 14/02/2020 Charles request : SPIRA 77191 : ESFD3610 EST_FSEGPATTERN_BDT KO on UAT
--[015] 14/02/2020 Lahcen request : SPIRA 79102 : req 11.3 at inception
--[016] 14/02/2020 Charles request : SPIRA 77191 : ESFD3610 EST_FRATINGRTO KO on UAT
--[017] 17/02/2019 Roger : SPIRA xxxxx : Ajoute mapping pour ESPD3800 6 POCI (sans spira)
--[018] 19/02/2020 Linh/JYP : Spiras 83904/79070 : fermeture de closing I17G , req 11.7.2 retro at inception 
--[019] 21/02/2020 Roger : SPIRA 65656 : Nouveau mapping pour fichier EPO_FCTREST_LOADCTL
--[020] 25/02/2020 JYP : SPIRA 79070 : ESFD3650-RAD RetroP RetroNP at Inception
--[021] 26/02/2020 Linh request : SPIRA 82353 2 new Pericase Retro at Inception
--[022] 27/02/2020 Lahcen request: SPIRA 82353 : update I17G_IEX_ALL_INI/EPO_IRDPERICASE0
--[023] 27/02/2020 Martin request: SPIRA 79070 : add ESEH1110 EST_FLORETFACTOR
--[024] 11/12/2019 Roger : SPIRA xxxxx : Corrige mapping ESPT0000
--[025] 28/02/2020 Martin request: SPIRA 79070 : add ESFD0060 ESF_FLORETFACTOR
--[026] 02/03/2020 Roger : SPIRA xxxxx : Corrige mapping ESID0560 - EST_FPLCCOM
--[027] 02/03/2020 Martin request: SPIRA 79070 : new chain ESFD2570 retro NP
--[028] 03/03/2020 Mehdi request: SPIRA 81838 : Extraction d'une branche P&C  ( Split LIFE/P&C )
--[029] 03/03/2020 Mehdi request: SPIRA 84317 : Optimisation ESID2000 , le temps des TNR il s'appellera ESFD2000
--[030] 05/03/2020 Charles/Antoine request: SPIRA 77471_82557 : change mapping ESFD3750
--[031] 05/03/2020 Lahcen request: SPIRA 79102 update mapping I17G_IEX_ALL_STD
--[032] 06/03/2020 Charles/Antoine request: SPIRA 77471_82557 : change mapping ESFD3750
--[033] 09/03/2020 Charles request : SPIRA 83091 : add idf_ct for ESFD3620 EBS
--[034] 09/03/2020 Roger : SPIRA 65656 : Nouveau mapping pour fichier EPO_FCTREST_LOADCTL
--[035] 09/03/2020 Charles/Antoine requests : SPIRA 83091_77471 : mappings ESPD3620 ESFD3750 ESFD3780 
--[036] 10/03/2020 Antoine request : SPIRA 77471 : mapping ESFD3780
--[037] 10/03/2020 Charles/Lahcen requests : SPIRA 79102_83091 : RETRO NP EXPENSES , ESFD3620 EBS 
--[038] 10/03/2020 Martin/Antoine requests : SPIRA 77471_79070  mappings ESFD3780 ESFD2570
--[039] 11/03/2020 Charles/Lahcen requests : SPIRA 79102_83091 : RETRO NP EXPENSES , ESFD3620 EBS  
--[040] 12/03/2020 Martin requests : SPIRA 79070  mappings ESFD2570
--[041] 12/03/2020 JYP SPIRA 79070 :  mappings ESFD2570/ESFD3610
--[042] 13/03/2020 Martin request : SPIRA 79070 : ESFD2550 bouclette retro P
--[043] 13/03/2020  Mehdi request: SPIRA 84317 : Optimisation ESID2000 , le temps des TNR il s'appellera ESFD2000
--[044] 18/03/2020  Mehdi request: SPIRA 81838 : SPLIT LIFE P&C : correction du mapping INIT
--[045] 24/03/2020  Mehdi request: SPIRA 81838 , 84317 : Merge INT et ITK
--[046] 27/03/2020 Lahcen request: SPIRA 79102 : mapping EXPRAT retro
--[047] 30/03/2020 Lahcen request: SPIRA 79102 : mapping EXPRAT retro
--[048] 30/03/2020 Martin request: SPIRA 79070 : ESFD2550 bouclette retro P
--[049] 12/03/2020 JYP SPIRA 79070 :  mappings ESFD2550/ESFD3610
--[050] 24/03/2020 Antoine/Lahcen requests : SPIRA 84815_79102 : mappings ESFD3690/ESFD3770/ESFD3630
--[051] 01/04/2020 Mehdi NAJI drop de la contraint de la nouvelle table TI17TRAPERMFIL en attendant 
--[052] 03/04/2020 Antoine request : SPIRA 80653  mapping ESFD3770/ESFD3780
--[053] 06/04/2020 JYP SPIRA 79070 :  mappings ESFD2550/ESFD3610
--[054] 07/04/2020 JYP SPIRA 79070 :  revert mappings ESFD2550/ESFD3610
--[055] 09/04/2020 JYP SPIRA 79070 :  add mapping ESFD3650 EPO_IRDPERICASE0
--[056] 09/04/2020 Martin request:  SPIRA 42212 : add EST_FDATDERCPA ESID2000 ESID0060
--[057] 10/04/2020 Linh request : SPIRA 83103 82584 
--[058] 14/04/2020 JYP : SPIRA 84653 mapping dates : micro AOC- EBS and IFRS17 
--[059] 14/04/2020 Antoine request : SPIRA 80653  mapping ESFD3770/ESFD3780
--[060] 14/04/2020 Linh request : SPIRA 83103 82584 
--[061] 17/04/2020 martin request : SPIRA 42212  add ESDJ7010 EST_FDATDERCPA
--[062] 20/04/2020 Mehdi request : SPIRA 86064 : clean scripts linked to tables TIfrs17 
--[063] 21/04/2020 Arnaud request : SPIRA 75828 82867: add chain ESFD8010
--[064] 23/04/2020 Antoine request : SPIRA 85356 mapping ESFD3720 et ESFD8000
--[065] 23/04/2020 martin request : SPIRA 79070 mapping PERICASE ESFD2550
--[066] 27/04/2020 Mariem request : SPIRA 86558 clean TI17REQCHN 
--[067] 28/04/2020 Martin request: SPIRA 79070 : add ESFD2550 ESF_FLORETFACTOR
--[068] 28/04/2020 Charles request : SPIRA 86189 : EST_GTSII_CLACC_CASHFLOW
--[069] 22/04/2020 Roger : SPIRA 86503-86536 : Nouveau mapping pour fichiers FCTREST
--[070] 04/05/2020 Linh request : SPIRA 85506  : update mapping I17G
--[071] 07/05/2020 Charles request: SPIRA 86189 82584 : add ESFD3820
--[072] 12/05/2020 Linh request : SPIRA 85506/83103 update mapping ESID3810 ESFD3830
--[073] 12/05/2020 Charles request: SPIRA 83206 new EST_IADPERICASE_STD for ESTC1056A 
--[074] 12/05/2020 Charles/Lihn request: SPIRA 83206 ESTC1056A 85506 ESFD3810 ESID3810
--[075] 13/05/2020 Charles request: SPIRA 83206 ESTC1056A bugfix DFILI
--[076] 13/05/2020 Linh request: SPIRA 85506 ESPD3810 EBS
--[077] 14/05/2020 Linh/Maxence request: SPIRA 85741 add ESFD3840/3850 SPIRA 86189 

-- drop de la contraint de la nouvelle table TI17TRAPERMFIL en attendant 
IF EXISTS (SELECT * FROM sysconstraints WHERE constrid=object_id('FK_TI17TRAP_REF_FNCT__TI17FNC') and tableid=object_id('TI17TRAPERMFIL')) 
    alter table  BEST..TI17TRAPERMFIL drop constraint FK_TI17TRAP_REF_FNCT__TI17FNC 

-----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
print '------>>>>  ESFD3770 '

delete BEST..TI17PERMFIL where IDF_CT = 'I17G_CSM_AMR_STD'
delete BEST..TI17REQCHN where IDF_CT = 'I17G_CSM_AMR_STD'
delete BEST..TI17FNC where IDF_CT = 'I17G_CSM_AMR_STD'
delete BEST..TI17CHN where CHAIN_CT = 'ESFD3770'


insert into BEST..TI17FNC values ('I17G_CSM_AMR_STD','IFRS17 - CSM/LC pattern calculation')

insert into BEST..TI17CHN values ('ESFD3770','IFRS17 - CSM/LC pattern calculation')

insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EST_FPRMLOA','${DFILP}/${PCH}ESID2210_FPRMLOA_EBSSO.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EST_DLDGTAA','${DFILP}/${PCH}ESID2220_DLDGTAASIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EST_IADPERICASE_STD','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_STD.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','ESF_UPR','${DFILP}/${PCH}ESFD3690_ESFD3691_I17G_IRV_ALL_STD_UPR_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','ESF_CSM_LC_AMORT_PATTERN','${DFILP}/${ENV_PREFIX}_ESFD3770_I17G_CSM_AMR_STD_CSM_LC_AMORT_PATTERN_${PARM_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_AMR_STD','EST_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESPT0000_IRDPERICASE0.dat','I','')


insert into BEST..TI17REQCHN values ('I17GMINV','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMINVB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOS','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOSB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOC','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOCB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQINV','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQINVB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOS','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOSB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOC','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOCB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYINV','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYINVB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOS','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOSB','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOC','ESFD3770','I17G_CSM_AMR_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOCB','ESFD3770','I17G_CSM_AMR_STD','')

GO

print '------>>>>  end ESFD3770 OK '
-----------------------------------------------------------------------------------------------------------


print '------>>>>  bugfix I17G_IEX_ALL_INI  EST_FSEGPATTERN_CSF '

UPDATE BEST..TI17PERMFIL 
SET PATHPATTRN_LL= '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF.dat' 
WHERE PERMFIL_CT = 'EST_FSEGPATTERN_CSF'
AND IDF_CT = 'I17G_IEX_ALL_INI'
go

print '------>>>>  end  I17G_IEX_ALL_INI  EST_FSEGPATTERN_CSF OK '

-----------------------------------------------------------------------------------------------------------

---------------------------------------------------------------
print '------>>>>  new mapping ESID8700 EST_IADVPERICASE '

delete BEST..TI17PERMFIL where IDF_CT = 'ESID8700' and  permfil_ct = 'EST_IADVPERICASE'
INSERT INTO BEST..TI17PERMFIL values ('ESID8700','EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${ICLODAT}.dat','I','')

GO
print '------>>>>  end mapping ESID8700 EST_IADVPERICASE OK '
---------------------------------------------------------------


---------------------------------------------------------------
print '------>>>>  bugfix ESF_GTSII_CSM_CASHFLOW '
delete BEST..TI17PERMFIL where IDF_CT='I17G_SII_ALL_STD' and PERMFIL_CT='ESF_GTSII_CSM_CASHFLOW'

insert into BEST..TI17PERMFIL values ('I17G_SII_ALL_STD',  'ESF_GTSII_CSM_CASHFLOW','${DFILP}/${PCH}ESFD3750_I17G_CSM_ALL_STD_GTSII_CSM_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')

GO
print '------>>>>  end bugfix ESF_GTSII_CSM_CASHFLOW OK '
---------------------------------------------------------------


---------------------------------------------------------------
print '------>>>>  add ESPD8700/EPO_OIADVPERICASE '
delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_OIADVPERICASE'
and IDF_CT = 'ESPD8700'

insert into BEST..TI17PERMFIL values ('ESPD8700',  'EPO_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat','I','')
go
print '------>>>>  end ESPD8700/EPO_OIADVPERICASE '
----------------------------------------------------------------

---------------------------------------------------------------
print '------>>>>  spira SPIRA : 82884 81645 EPO_FTECLEDA '

delete from BEST..TI17PERMFIL where idf_ct in ('I17G_IEX_ALL_STD', 'I17G_IEX_ALL_INI') and PERMFIL_CT='EPO_DLDGTAAPNAE' 

delete from BEST..TI17PERMFIL where idf_ct in ('I17G_IEX_ALL_STD', 'I17G_IEX_ALL_INI') and PERMFIL_CT='EPO_FTECLEDA' 
 
insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_STD', 'EPO_FTECLEDA', '${DFILP}/${PCH}ESPD3800_FTECLEDA${TYPEINV0}.dat', 'I') 

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_INI', 'EPO_FTECLEDA', '${DFILP}/empty.dat', 'I')

go
print '------>>>> end spira SPIRA : 82884 81645 EPO_FTECLEDA '
---------------------------------------------------------------


print '------>>>> spira 83904 : mehdi ask to replace  param_Context_id'

update  BEST..TI17PERMFIL 
set PATHPATTRN_LL = str_replace(PATHPATTRN_LL,'param_Context_id', 'TYPEINV' )
where   pathpattrn_ll like '%param_Context_id%'
and permfil_ct in (
'EPO_DLEIFTECLEDSIIEI_POOL',
'EPO_GTEP_POOL',
'EPO_DLEIFTECLEDSIIEI',
'ESF_FEXPRAT',
'ESF_FRARAT' ,
'ESF_FEXPRAT_PREVQ')


update  BEST..TI17PERMFIL set PATHPATTRN_LL = '${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POC.dat'
where permfil_ct = 'EPO_DLEIFTECLEDSIIEI' and idf_ct = 'ESPD2050_POCE'

update  BEST..TI17PERMFIL set PATHPATTRN_LL = '${DFILP}/${PCH}ESPD3620_DLEIFTECLEDSIIEI_POS.dat'
where permfil_ct = 'EPO_DLEIFTECLEDSIIEI' and idf_ct = 'ESPD2050_POSE'

GO
print '------>>>> end spira 83904 : mehdi ask to replace  param_Context_id'
---------------------------------------------------------------




---------------------------------------------------------------
print '------>>>> new chain ESFD3790 '

delete BEST..TI17REQCHN where IDF_CT = 'I17G_SEG_PRO_STD'
delete BEST..TI17PERMFIL where IDF_CT = 'I17G_SEG_PRO_STD'
delete BEST..TI17PERMFIL where IDF_CT = 'I17G_OMG_TP_STD' and PERMFIL_CT = 'ESF_FSEGPROF_SEG_STD'
delete BEST..TI17CHN where CHAIN_CT = 'ESFD3790'
delete BEST..TI17FNC where IDF_CT = 'I17G_SEG_PRO_STD'

insert into BEST..TI17FNC values ('I17G_SEG_PRO_STD','IFRS17 - IFRS 17 segment net position indicator')

insert into BEST..TI17CHN values ('ESFD3790','IFRS17 - IFRS 17 segment net position indicator')

insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','EST_IADPERICASE_STD','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_STD.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','ESF_GTSII_ESCOMPTE_DSC','${DFILP}/${PCH}ESFD3620_I17G_DSC_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${PCH}ESFD3620_I17G_RAD_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_SEG_PRO_STD','ESF_FSEGPROF_SEG_STD','${DFILP}/${PCH}ESFD3790_I17G_SEG_PRO_STD_FSEGPROF_${PARM_ICLODAT_D}.dat','O','')

insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD','ESF_FSEGPROF_SEG_STD','${DFILP}/${PCH}ESFD3790_I17G_SEG_PRO_STD_FSEGPROF_${PARM_ICLODAT_D}.dat','I','')

insert into BEST..TI17REQCHN values ('I17GMINV','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMINVB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOS','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOSB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOC','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOCB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQINV','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQINVB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOS','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOSB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOC','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOCB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYINV','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYINVB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOS','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOSB','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOC','ESFD3790','I17G_SEG_PRO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOCB','ESFD3790','I17G_SEG_PRO_STD','')

print '------>>>> end new chain ESFD3790 '
GO
---------------------------------------------------------------

---------------------------------------------------------------
print '------>>>>  SPIRA 71539 : add mapping FUTURE Retro OVERRIDE '
delete from BEST..TI17PERMFIL  where idf_ct = 'ESPD2550' 
and PERMFIL_CT in (
'EPO_DLREGTR_OVRCO',		
'EPO_DLREGTR_OVRSIICO',		
'EPO_DLREGTR_OVRSIISO',		
'EPO_DLREGTR_OVRSO',	
'EPO_DLREGTAR_OVRCO',		
'EPO_DLREGTAR_OVRSIICO',	
'EPO_DLREGTAR_OVRSIISO',	
'EPO_DLREGTAR_OVRSO'	
)


delete from BEST..TI17PERMFIL  where idf_ct = 'ESPD3800' 
and PERMFIL_CT in (
'EPO_DLREGTR_OVRCO',		
'EPO_DLREGTR_OVRSIICO',		
'EPO_DLREGTR_OVRSIISO',		
'EPO_DLREGTR_OVRSO',	
'EPO_DLREGTAR_OVRSIICO',
'EPO_DLREGTAR_OVRSIISO',	
'EPO_DLREGTAR_OVRSO',
'EPO_DLREGTAR_OVRCO')

insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTR_OVRCO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRCO.dat',	    'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTR_OVRSIICO',			'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSIICO.dat',	  'O', '')
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTR_OVRSIISO',			'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSIISO.dat',	  'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTR_OVRSO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSO.dat',	    'O', '')	  
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTR_OVRCO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRCO.dat',	    'I', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTR_OVRSIICO',			'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSIICO.dat',	  'I', '')
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTR_OVRSIISO',			'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSIISO.dat',	  'I', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTR_OVRSO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTR_OVRSO.dat',	    'I', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTAR_OVRCO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRCO.dat',	    'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTAR_OVRSIICO',		'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSIICO.dat',	'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTAR_OVRSIISO',		'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSIISO.dat',	'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD2550',	'EPO_DLREGTAR_OVRSO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSO.dat',	    'O', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTAR_OVRSIICO',		'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSIICO.dat',	'I', '') 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTAR_OVRSIISO',		'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSIISO.dat',	'I', '')	 
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTAR_OVRSO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRSO.dat',	    'I', '')	
insert into  BEST..TI17PERMFIL values ('ESPD3800',	'EPO_DLREGTAR_OVRCO',				'${DFILP}/${ENV_PREFIX}_ESPD2550_DLREGTAR_OVRCO.dat',	    'I', '')


print '------>>>>  SPIRA 71539 : add mapping FUTURE Retro OVERRIDE '
GO
---------------------------------------------------------------



---------------------------------------------------------------
print '------>>>>  ESFD3730 : add EST_IADPERICASE_DUMMY variable  spira 79100  '

DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_SII_ALL_STD' and PERMFIL_CT='EST_IADPERICASE_DUMMY'
INSERT INTO BEST..TI17PERMFIL VALUES('I17G_SII_ALL_STD', 'EST_IADPERICASE_DUMMY', '${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_DUMMY.dat', 'I', '')


print '------>>>>  End ESFD3730 : add EST_IADPERICASE_DUMMY variable  spira 79100  '
GO
---------------------------------------------------------------


---------------------------------------------------------------
print '------>>>>  SPIRA 82557 add I17G_CSF_ALL_INI EST_FCURQUOT_TXT  '

DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSF_ALL_INI' and PERMFIL_CT in ('EST_FCURQUOT_TXT','EPO_FCURQUOT_TXT')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')


DELETE FROM BEST..TI17PERMFIL  where IDF_CT in ('I17G_IEX_ALL_INI', 'I17G_IEX_ALL_STD') and PERMFIL_CT = 'EST_FCURQUOT_TXT'
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')



print '------>>>>  End SPIRA 82557 add I17G_CSF_ALL_INI EST_FCURQUOT_TXT  '
GO
---------------------------------------------------------------

---------------------------------------------------------------
print '------>>>>  new variable ESFD2220/EPO_FCTREST/I17G_CSF_ALL_INI '
DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSF_ALL_INI' and PERMFIL_CT='EPO_FCTREST'

INSERT INTO BEST..TI17PERMFIL VALUES('I17G_CSF_ALL_INI', 'EPO_FCTREST', '${DFILP}/${PCH}ESPD0060_FCTRESTSIISO.dat', 'I', '')

print '------>>>>  new variable ESFD2220/EPO_FCTREST/I17G_CSF_ALL_INI OK '
GO

----------------------------------------------------------------------------------------------------------
--
-- CHAIN ESFD2220 	-- I17G_FUT_ALL_INI
--
----------------------------------------------------------------------------------------------------------
delete BEST..TI17PERMFIL where   IDF_CT = 'I17G_FUT_ALL_INI'

insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_IADPERICASE','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','')
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
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FDETTRS_TXT','${DFILP}/${PCH}ESPT0000_FDETTRS_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FTRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FSEGEST_SOLVENCY','${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCY${TYPEINV0}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FLOARAT','${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_IFRS_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_OIADVPERICASE','${DFILP}/${PCH}ESPT0000_OIADVPERICASE.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_FUTURE_EBS','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_FUTURE_${TYPEINV}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLGTAUPUC','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLGTAUPUC_${TYPEINV}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EST_DLDGTAA_E_TRNCODEBS','${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLDGTAASII${TYPEINV0}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI',  'EPO_FCTREST','${DFILP}/${PCH}ESPD0060_FCTRESTSIISO.dat',' ','')

print '------>>>>  [81496] ESFD2220 End'
go





----------------------------------------------------------------------------------------------------------
print '------>>>>  Spira 79102 - Lahcen - Start  '

delete from  BEST..TI17PERMFIL where idf_ct = 'I17G_IEX_ALL_STD' and permfil_ct in ('EPO_DLDGTR_E','EST_FPLACEMT22','EPO_IRDPERICASE0','ESF_RETRO_ITDPREMIUM','ESF_RETRO_UPR') 

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_STD', 'EPO_DLDGTR_E', '${DFILP}/${PCH}ESPD2570_DLDGTRSII${TYPEINV0}_E.dat', 'I')

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_STD', 'EST_FPLACEMT22', '${DFILI}/${PCH}ESPD0060_FPLACEMT22.dat', 'I')

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_STD', 'EPO_IRDPERICASE0', '${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat', 'I')

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_STD', 'ESF_RETRO_ITDPREMIUM', '${DFILI}/${PCH}ESPD2570_RETUPR_ESTIME.dat', 'I')

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_STD', 'ESF_RETRO_UPR', '${DFILI}/${PCH}ESPD2570_RETITDPRM.dat', 'I')


delete from  BEST..TI17PERMFIL where idf_ct = 'I17G_IEX_ALL_INI' and permfil_ct in ('EPO_DLDGTR_E','EST_FPLACEMT22','EPO_IRDPERICASE0','ESF_RETRO_ITDPREMIUM','ESF_RETRO_UPR') 


insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_INI', 'EPO_DLDGTR_E', '${DFILP}/${PCH}ESPD2570_DLDGTRSII${TYPEINV0}_E.dat', 'I')

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_INI', 'EST_FPLACEMT22', '${DFILI}/${PCH}ESPD0060_FPLACEMT22.dat', 'I')

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_INI', 'EPO_IRDPERICASE0', '${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat', 'I')

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_INI', 'ESF_RETRO_ITDPREMIUM', '${DFILP}/empty.dat', 'I')

insert into BEST..TI17PERMFIL (idf_ct, permfil_ct, PATHPATTRN_LL, IO )
values ('I17G_IEX_ALL_INI', 'ESF_RETRO_UPR', '${DFILP}/empty.dat', 'I')



print '------>>>>  Spira 79102 - Lahcen - End '
go

----------------------------------------------------------------------------------------------------------



---------------------------------------------------------------
print '------>>>>  SPIRA 79070 : cashflow retro at inception '


DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_RAD_CKI_INI' and PERMFIL_CT in ('ESF_IADVPERICASE_P','ESF_IRDPERICASE_NP','EPO_IRDPERICASE0')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_IADVPERICASE_P','${DFILP}/${PCH}ESEH1100_IADVPERICASE_P_INI.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'ESF_IRDPERICASE_NP','${DFILP}/${PCH}ESEH1100_IRDPERICASE_NP_INI.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'EPO_IRDPERICASE0','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','')
		
		
DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSF_ALL_INI' and PERMFIL_CT in ('EST_IRDPERICASE0','ESF_IADVPERICASE_P','ESF_IRDPERICASE_NP','ESF_DLDGTR_P','ESF_DLDGTR_NP','EST_DLREGTAR','EST_DLREMAJGTAR')

insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_IRDPERICASE0','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'ESF_IADVPERICASE_P','${DFILP}/${PCH}ESEH1100_IADVPERICASE_P_INI.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'ESF_IRDPERICASE_NP','${DFILP}/${PCH}ESEH1100_IRDPERICASE_NP_INI.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLREGTAR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_DLREMAJGTAR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'ESF_DLDGTR_P','${DFILP}/${PCH}ESFD2550_DLREGTARSIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'ESF_DLDGTR_NP','${DFILP}/${PCH}ESFD2570_DLDGTRSII${TYPEINV0}.dat','I','')


DELETE FROM BEST..TI17PERMFIL  where PERMFIL_CT in ('ESF_IRDPERICASE_NP','ESF_DLDGTR_P','ESF_DLDGTR_NP','ESF_IADVPERICASE_P')
and IDF_CT in
(
'ESPD3610_BookingPOCE',
'ESPD3610_BookingPOCEAnnuel',
'ESPD3610_BookingPOSE',
'ESPD3610_BookingPOSEAnnuel',
'ESPD3610_POCE',
'ESPD3610_POSE'
)


insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE',       'ESF_IRDPERICASE_NP', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel', 'ESF_IRDPERICASE_NP', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE',       'ESF_IRDPERICASE_NP', '${DFILP}/empty.dat', 'I', ' ')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel', 'ESF_IRDPERICASE_NP', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',              'ESF_IRDPERICASE_NP', '${DFILP}/empty.dat', 'I', ' ')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',              'ESF_IRDPERICASE_NP', '${DFILP}/empty.dat', 'I', ' ')


insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE',       'ESF_IADVPERICASE_P', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel', 'ESF_IADVPERICASE_P', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE',       'ESF_IADVPERICASE_P', '${DFILP}/empty.dat', 'I', ' ')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel', 'ESF_IADVPERICASE_P', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',              'ESF_IADVPERICASE_P', '${DFILP}/empty.dat', 'I', ' ')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',              'ESF_IADVPERICASE_P', '${DFILP}/empty.dat', 'I', ' ')



insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE',       'ESF_DLDGTR_P', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel', 'ESF_DLDGTR_P', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE',       'ESF_DLDGTR_P', '${DFILP}/empty.dat', 'I', ' ')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel', 'ESF_DLDGTR_P', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',              'ESF_DLDGTR_P', '${DFILP}/empty.dat', 'I', ' ')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',              'ESF_DLDGTR_P', '${DFILP}/empty.dat', 'I', ' ')


insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE',       'ESF_DLDGTR_NP', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel', 'ESF_DLDGTR_NP', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE',       'ESF_DLDGTR_NP', '${DFILP}/empty.dat', 'I', ' ')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel', 'ESF_DLDGTR_NP', '${DFILP}/empty.dat', 'I', ' ') 
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',              'ESF_DLDGTR_NP', '${DFILP}/empty.dat', 'I', ' ')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',              'ESF_DLDGTR_NP', '${DFILP}/empty.dat', 'I', ' ')



print '------>>>>  End SPIRA 79070 : cashflow retro at inception '
GO

---------------------------------------------------------------
print '------>>>>  Start plantage UAT : ESFD3610 '

DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSF_ALL_INI' and PERMFIL_CT in ( 'EST_FSEGPATTERN_BDT' , 'EST_FRATINGRTO') 

insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FSEGPATTERN_BDT','${DFILP}/${PCH}ESPD0060_FSEGPATTERN_BDT.dat','I','')

insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FRATINGRTO','${DFILP}/${PCH}ESPT0000_FRATINGRTO.dat','I','')


print '------>>>>  End plantage UAT : ESFD3610 '

GO

---------------------------------------------------------------
print '------>>>>  [xxxxx] ESPD3800 - POCI'

delete BEST..TI17PERMFIL
where IDF_CT = 'ESPD3800'  
and PERMFIL_CT in ('EPO_DLREGTARCO','EPO_DLREMAJGTARCO')

insert into BEST..TI17PERMFIL values('ESPD3800','EPO_DLREGTARCO','${DFILP}/${PCH}ESPD2550_DLREGTARCO.dat','I','')
insert into BEST..TI17PERMFIL values('ESPD3800','EPO_DLREMAJGTARCO','${DFILP}/${PCH}ESPD2550_DLREMAJGTARCO.dat','I','')

print '------>>>>  [xxxxx] End ESPD3800 - POCI'
go
---------------------------------------------------------------




---------------------------------------------------------------
print '------>>>>  Spira 83904 Linh : fermeture de closing I17G '

-------------------------------
--	Init  ESFJ8990, IDF_CT=I17G_OMG_CLO_STD
-------------------------------
delete BEST..TI17PERMFIL where IDF_CT = 'I17G_OMG_CLO_STD'
delete  BEST..TI17REQCHN where   IDF_CT = 'I17G_OMG_CLO_STD' and  CHAIN_CT in ('ESFJ8990','ESFJ8890')
delete  BEST..TI17CHN  where CHAIN_CT='ESFJ8990'
delete  BEST..TI17FNC  where IDF_CT =  'I17G_OMG_CLO_STD'

insert into BEST..TI17CHN values ('ESFJ8990','Generating IFRS 17 Group RA files')
insert into BEST..TI17FNC values ('I17G_OMG_CLO_STD','')

insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GMINVB', 'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOSB', 'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOCB', 'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GQINVB', 'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOSB', 'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOCB', 'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GYINVB', 'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOSB', 'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFJ8990','I17G_OMG_CLO_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOCB', 'ESFJ8990','I17G_OMG_CLO_STD','')

print '------>>>>  End Spira 83904 Linh : fermeture de closing I17G '
GO
---------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
print '------>>>>  ESFD3650-RAD RetroP RetroNP at Inception ' 

DELETE FROM BEST..TI17PERMFIL  where IDF_CT in ('I17G_RAD_CKI_STD','I17G_RAD_CUR_STD')  and PERMFIL_CT in ('ESF_IADVPERICASE_P','ESF_IRDPERICASE_NP')

insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_IADVPERICASE_P','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'ESF_IRDPERICASE_NP','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_IADVPERICASE_P','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'ESF_IRDPERICASE_NP','${DFILP}/empty.dat','I','')
	

print '------>>>>  End ESFD3650-RAD RetroP RetroNP at Inception ' 
go
----------------------------------------------------------------


----------------------------------------------------------------------------------
print '------>>>> SPIRA 82353 : 2 new Pericase Retro at Inception' 

delete from  BEST..TI17PERMFIL where IDF_CT='ESEH1100' and PERMFIL_CT in ('EST_IADVPERICASE_P_INI', 'EST_IRDPERICASE_NP_INI')

insert into BEST..TI17PERMFIL(IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) values ('ESEH1100','EST_IADVPERICASE_P_INI','${DFILP}/${ENV_PREFIX}_ESEH1100_IADVPERICASE_P_INI.dat','O',' ')
insert into BEST..TI17PERMFIL(IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) values ('ESEH1100','EST_IRDPERICASE_NP_INI','${DFILP}/${ENV_PREFIX}_ESEH1100_IRDPERICASE_NP_INI.dat','O',' ')


print '------>>>> End SPIRA 82353 : 2 new Pericase Retro at Inception' 
go
----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
print '------>>>>  SPIRA 82353 : update I17G_IEX_ALL_INI/EPO_IRDPERICASE0 '

UPDATE BEST..TI17PERMFIL 
SET PATHPATTRN_LL = '${DFILP}/${ENV_PREFIX}_ESEH1100_IRDPERICASE_NP_INI.dat'
WHERE IDF_CT = 'I17G_IEX_ALL_INI' 
AND PERMFIL_CT = 'EPO_IRDPERICASE0'

print '------>>>>  End SPIRA 82353 : update I17G_IEX_ALL_INI/EPO_IRDPERICASE0 '
GO
-----------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------
print '------>>>>  SPIRA 79070 : add ESFD0060 ESF_FLORETFACTOR'
delete from BEST..TI17PERMFIL where IDF_CT='ESEH1100' and PERMFIL_CT = 'EST_FLORETFACTOR'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G___' and PERMFIL_CT = 'ESF_FLORETFACTOR'

insert into BEST..TI17PERMFIL(IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) values ('I17G___','ESF_FLORETFACTOR',	'${DFILI}/${ENV_PREFIX}_ESFD0060_I17G___FLORETFACTOR.dat','O', '')

print '------>>>>  End SPIRA 79070 : add ESFD0060 ESF_FLORETFACTOR'
GO
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
print '------>>>>  [xxxxx] ESPT0000'

delete BEST..TI17PERMFIL
where IDF_CT = 'ESPT0000'  
and PERMFIL_CT in ('EST_FBOPRSLNK')

insert into BEST..TI17PERMFIL values('ESPT0000','EST_FBOPRSLNK','${DFILP}/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_${PARM0_ICLODAT_D}.dat','I','')

delete BEST..TI17PERMFIL
where IDF_CT = 'ESPT0000'  
and PERMFIL_CT in ('EST_FBOPRSLNK_TXT','EST_FCLIENT_TXT','EST_FCURQUOT_TXT','EST_FDETTRS_TXT','EST_FPRSMAP_TXT',
                   'EST_FSSDACTR_TXT','EST_FTRSLNK_TXT','EST_SUBTRSESBPROP_TXT','EST_SUBTRS_TXT')

insert into BEST..TI17PERMFIL values('ESPT0000','EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESCJ0060_FBOPRSLNK_TXT_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values('ESPT0000','EST_FCLIENT_TXT'  ,'${DFILP}/${PCH}ESCJ0060_FCLIENT_TXT_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values('ESPT0000','EST_FCURQUOT_TXT' ,'${DFILP}/${PCH}ESCJ0060_FCURQUOT_TXT_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values('ESPT0000','EST_FDETTRS_TXT'  ,'${DFILP}/${PCH}ESCJ0060_FDETTRS_TXT_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values('ESPT0000','EST_FPRSMAP_TXT'  ,'${DFILP}/${PCH}ESCJ0060_FPRSMAP_TXT_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values('ESPT0000','EST_FSSDACTR_TXT' ,'${DFILP}/${PCH}ESCJ0060_FSSDACTR_TXT_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values('ESPT0000','EST_FTRSLNK_TXT'  ,'${DFILP}/${PCH}ESCJ0060_FTRSLNK_TXT_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values('ESPT0000','EST_SUBTRS_TXT'   ,'${DFILP}/${PCH}ESCJ0060_FSUBTRS_TXT_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values('ESPT0000','EST_SUBTRSESBPROP_TXT','${DFILP}/${PCH}ESCJ0060_SUBTRSESBPROP_TXT_${PARM0_ICLODAT_D}.dat','I','')

delete BEST..TI17PERMFIL
where IDF_CT = 'ESPT0000'  
and PERMFIL_CT in ('EPO_FBOPRSLNK_TXT','EPO_FCLIENT_TXT','EPO_FCURQUOT_TXT','EPO_FDETTRS_TXT','EPO_FPRSMAP_TXT',
                   'EPO_FSSDACTR_TXT','EPO_FTRSLNK_TXT','EPO_SUBTRSESBPROP_TXT','EPO_SUBTRS_TXT')

insert into BEST..TI17PERMFIL values('ESPT0000','EPO_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values('ESPT0000','EPO_FCLIENT_TXT','${DFILP}/${PCH}ESPT0000_FCLIENT_TXT_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values('ESPT0000','EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values('ESPT0000','EPO_FDETTRS_TXT','${DFILP}/${PCH}ESPT0000_FDETTRS_TXT_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values('ESPT0000','EPO_FPRSMAP_TXT','${DFILP}/${PCH}ESPT0000_FPRSMAP_TXT_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values('ESPT0000','EPO_FSSDACTR_TXT','${DFILP}/${PCH}ESPT0000_FSSDACTR_TXT_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values('ESPT0000','EPO_FTRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values('ESPT0000','EPO_SUBTRS_TXT','${DFILP}/${PCH}ESPT0000_SUBTRS_TXT_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values('ESPT0000','EPO_SUBTRSESBPROP_TXT','${DFILP}/${PCH}ESPT0000_SUBTRSESBPROP_TXT_${CLODAT}.dat','O','')

print '------>>>>  [xxxxx] End ESPT0000'
go
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
print '------>>>>  SPIRA xxxxx : Corrige mapping ESID0560 - EST_FPLCCOM'
delete from BEST..TI17PERMFIL where IDF_CT='ESID0560' and PERMFIL_CT in ('EST_FPLCCOM')

insert into BEST..TI17PERMFIL(IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) values ('ESID0560','EST_FPLCCOM',	'${DFILP}/${ENV_PREFIX}_ESID2500_FPLCCOM_${CLODAT}.dat','O', '')

print '------>>>>  End SPIRA xxxxx : Corrige mapping ESID0560 - EST_FPLCCOM'
GO
-----------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------
print '------>>>>  SPIRA 79070 : new chain ESFD2570 retro NP'

-------------------------------
--	Init  ESFD2570
-------------------------------

delete BEST..TI17PERMFIL where IDF_CT in  ( select IDF_CT from BEST..TI17REQCHN where   CHAIN_CT='ESFD2570')
delete BEST..TI17REQCHN where   IDF_CT  in ('I17G_FUT_RET_INI', 'I17G_FUT_RNP_INI') and  CHAIN_CT='ESFD2570'
delete BEST..TI17CHN  where CHAIN_CT='ESFD2570'
delete BEST..TI17FNC where IDF_CT  in ( 'I17G_FUT_RET_INI' , 'I17G_FUT_RNP_INI')

insert into BEST..TI17CHN values ('ESFD2570',  'Retro NP at Inception')

insert into BEST..TI17FNC values ('I17G_FUT_RNP_INI', 'Retro NP at Inception' )
	
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_DLDGTAR_E',					'${DFILP}/${PCH}ESFD2570_DLDGTARSII${TYPEINV0}_E.dat',	'O', '')	 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_DLDGTARCO_E',					'${DFILP}/${PCH}ESFD2570_DLDGTARSIICO_E.dat',					'O', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_DLDGTARSO_E',					'${DFILP}/${PCH}ESFD2570_DLDGTARSIISO_E.dat',					'O', '')	 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_DLDGTR_CUMULS_PREC',		'${DFILP}/empty.dat',	'I', '')	 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_DLDGTR_E',							'${DFILP}/${PCH}ESFD2570_DLDGTRSII${TYPEINV0}_E.dat', 	'O', '')	 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_DLDGTRCO',							'${DFILP}/${PCH}ESFD2570_DLDGTRSIICO.dat', 'O', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_DLDGTRCO_E',						'${DFILP}/${PCH}ESFD2570_DLDGTRSIICO_E.dat', 'O', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_DLDGTRSO',							'${DFILP}/${PCH}ESFD2570_DLDGTRSIISO.dat', 'O', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_DLDGTRSO_E',						'${DFILP}/${PCH}ESFD2570_DLDGTRSIISO_E.dat', 'O', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_FBOPRSLNK',						'${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_FBOPRSLNK_TXT',				'${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_FCURQUOT',							'${DFILP}/${PCH}ESPT0000_FCURQUOT.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_FCURQUOT_TXT',					'${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_FPLACEMT22',						'${DFILI}/${PCH}ESPD0060_FPLACEMT22.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_FTECLEDR',							'${DFILP}/empty.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_FTECLEDRCO',						'${DFILP}/empty.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_FTECLEDRSO',						'${DFILP}/empty.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_IRDPERICASE0',					'${DFILP}/${PCH}ESEH1100_IRDPERICASE_NP_INI.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_RETITDPRM_UPR_ACT',		'${DFILP}/empty.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EST_FBOPRSLNK',						'${DFILP}/${PCH}ESPT0000_FBOPRSLNK.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EST_FBOPRSLNK_TXT',				'${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EST_FCURQUOT',							'${DFILP}/${PCH}ESPT0000_FCURQUOT.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EST_FCURQUOT_TXT',					'${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EST_FDETTRS',							'${DFILP}/${PCH}ESPT0000_FDETTRS.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EST_FDETTRS_TXT',					'${DFILP}/${PCH}ESPT0000_FDETTRS_TXT_${PARM_ICLODAT_D}.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EST_FTRSLNK',							'${DFILP}/${PCH}ESPT0000_FTRSLNK.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EST_FTRSLNK_TXT',					'${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RNP_INI',	'EPO_FUTURE_RETRO_EBS', '${DFILP}/${PCH}ESFD2570_FUTURE_RETRO_EBS_INI.dat', 'O' ,'')



----------   Reqs of chain   ---------------------
insert into BEST..TI17REQCHN values ('I17GMINV',  'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GMINVB', 'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GMPOC',  'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GMPOCB', 'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GMPOS',  'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GMPOSB', 'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GQINV',  'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GQINVB', 'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GQPOC',  'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GQPOCB', 'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GQPOS',  'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GQPOSB', 'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GYINV',  'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GYINVB', 'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GYPOC',  'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GYPOCB', 'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GYPOS',  'ESFD2570','I17G_FUT_RNP_INI','')
insert into BEST..TI17REQCHN values ('I17GYPOSB', 'ESFD2570','I17G_FUT_RNP_INI','')
		

print '------>>>> End  SPIRA 79070 : new chain ESFD2570 retro NP'
GO
-----------------------------------------------------------------------------------------------------------

print "------>>>> Start  SPIRA 81838 : Extraction d'une branche P&C"
-----------------------------------------------------------------------------------------------------------

--  ESID0560: : fonctional id of P&C execution   

delete BEST..TI17PERMFIL where  IDF_CT = 'ESID0560' and PERMFIL_CT in ('EST_FCES','EST_FCES_NEW','EST_FPLC','EST_FPLCCOM' )

-- input
insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FCES_NEW','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_NEW_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID0560',  'EST_FPLCCOM','${DFILP}/${ENV_PREFIX}_ESID25000_FPLCCOM_${CLODAT}.dat','O','')
                
go
delete BEST..TI17PERMFIL where  IDF_CT = 'ESID2500' and PERMFIL_CT in ('EST_FCES','EST_FCES_NEW','EST_FPLC','EST_DLREMAJGTR_PC','EST_DLREGTR_PC','EST_DLRGTAA_PC')

-- input
	
insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${ICLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_FCES_NEW','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_NEW_${ICLODAT2}.dat','O','')

insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLREMAJGTR_PC','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREMAJGTR_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLREGTR_PC','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREGTR_${PARM0_ICLODAT_D}.dat','IO','') 
insert into BEST..TI17PERMFIL values ('ESID2500',  'EST_DLRGTAA_PC','${DFILI}/${ENV_PREFIX}_ESID2050_I4_PC___DLRGTAA_${PARM0_ICLODAT_D}.dat','IO','')

go
-------------------------------
print	"--	Init  ESID2550"
-------------------------------

	
--  ESID2550_I4_PC___: : fonctional id of P&C execution   

delete BEST..TI17PERMFIL where  IDF_CT like 'ESID2550_I4_PC__%'
IF NOT EXISTS (SELECT * FROM BEST..TI17FNC where IDF_CT = 'ESID2550_I4_PC___' ) insert into BEST..TI17FNC values ( 'ESID2550_I4_PC___','')



-- inputI4_PC___
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_GTEP','${DFILP}/${ENV_PREFIX}_ESCJ0060_GTEP.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLSGTR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FRETTRF','${DFILP}/${ENV_PREFIX}_ESCJ0060_FRETTRF_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLRPGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLRTGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLVGTR','${DFILP}/empty.dat','I','')                                            
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLRNPGTR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLRTCGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLRTFGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FPLACEMT0','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLGTRSNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTRSNEM_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IRDVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_IADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${PARM_CLODAT_D}.dat','I','')

-- output 
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLREGTR','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREGTR_${PARM0_ICLODAT_D}.dat','IO','') 
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_I4_PC___DLRGTAA_${PARM0_ICLODAT_D}.dat','IO','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLREMAJGTR','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREMAJGTR_${PARM0_ICLODAT_D}.dat','IO','')

insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLREGTR0','${DFILP}/${ENV_PREFIX}_ESID2500_DLREGTR_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLRGTAA0','${DFILI}/${ENV_PREFIX}_ESID2050_DLRGTAA_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLREMAJGTR0','${DFILP}/${ENV_PREFIX}_ESID2500_DLREMAJGTR_${ICLODAT}.dat','I','')

insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLRIGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_I4_PC___DLRIGTAA_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLREMAJGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREMAJGTAR_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLDVGTR','${DFILI}/${ENV_PREFIX}_ESID2550_I4_PC___DLDVGTR_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLEIGTAA','${DFILI}/${ENV_PREFIX}_ESID2550_I4_PC___DLEIGTAA_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLREGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREGTAR_${PARM0_ICLODAT_D}.dat', 'O', ' ' )
insert into BEST..TI17PERMFIL values ('ESID2550_I4_PC___',  'EST_DLRIGTAANOS','${DFILI}/${ENV_PREFIX}_ESID2550_I4_PC___DLRIGTAANOS_${PARM0_ICLODAT_D}.dat','O','')
		
go
-------------------------------
print "--	Init  ESID2060"
-------------------------------



----------  IDF_CT = 'ESID2060_I4_PC___'  ---------------------
delete BEST..TI17PERMFIL where  IDF_CT = 'ESID2060_I4_PC___'
delete BEST..TI17PERMFIL where  IDF_CT = 'ESID2060_I4_PC___'
IF NOT EXISTS (SELECT * FROM BEST..TI17FNC where IDF_CT = 'ESID2060_I4_PC___' ) insert into BEST..TI17FNC values ( 'ESID2060_I4_PC___','')



-- input
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_MGTAA','${DFILP}/${ENV_PREFIX}_ESIX7000_MGTAA.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FCURQUOT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FCES','${DFILP}/${ENV_PREFIX}_ESID2500_FCES_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FPLC','${DFILP}/${ENV_PREFIX}_ESID2500_FPLC_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_IGTAAF','${DFILI}/${ENV_PREFIX}_ESID0560_IGTAAF_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FTRSLNK','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLAGTAA','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAA_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLDGTAA','${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLRGTAA','${DFILI}/${ENV_PREFIX}_ESID2050_I4_PC___DLRGTAA_${PARM0_ICLODAT_D}.dat','I','')   -- [01]
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLSGTAA','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAA_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_MVTPNAC','${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNAC_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FCURCVSN','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSN_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FCURCVSNI','${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURCVSNI_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_FTRANSCODE','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLASIIGTAA','${DFILI}/${ENV_PREFIX}_ESID3600_DLASIIGTAA_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLDSIIGTAA','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTAA_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLGTAASNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTAASNEM_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLVGTAA','${DFILP}/empty.dat','I','')                                              ---- [01]
-- output
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_TOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_I4_PC___TOTGTAA_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLTOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_I4_PC___DLTOTGTAA_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2060_I4_PC___',  'EST_DLTOTITGTAR','${DFILI}/${ENV_PREFIX}_ESID2060_I4_PC___DLTOTITGTAR_${PARM0_ICLODAT_D}.dat','O','')


delete BEST..TI17PERMFIL where  IDF_CT = 'ESID2060' and PERMFIL_CT ='EST_DLVGTAA'
insert into BEST..TI17PERMFIL values ('ESID2060',  'EST_DLVGTAA',"`ls -rt ${DFILP}/${ENV_PREFIX}_ESID2080_DLVGTAA_PC_${PARM0_ICLODAT_D}*.dat | tail -1 `",'I','')

go

-------------------------------
print	"--	Init  ESID2560_I4_PC___"
-------------------------------


----------  IDF_CT = 'ESID2560_I4_PC___'  ---------------------

delete BEST..TI17PERMFIL where  IDF_CT = 'ESID2560_I4_PC___'
IF NOT EXISTS (SELECT * FROM BEST..TI17FNC where IDF_CT = 'ESID2560_I4_PC___' ) insert into BEST..TI17FNC values ( 'ESID2560_I4_PC___','')

insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_IGTAR0','${DFILP}/${ENV_PREFIX}_ESID0560_IGTAR.dat','I','')

insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_MGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_MGTR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_IGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_I4_PC___IGTAR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_MGTAR','${DFILP}/${ENV_PREFIX}_ESIX7000_MGTAR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_IGTR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_FVENTNPANT','${DFILP}/${ENV_PREFIX}_ESIX7000_FVENTNPANT.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLAGTR','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLSGTR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_FDETTRS','${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_FLIBEL2','${DFILP}/${ENV_PREFIX}_ESCJ0060_FLIBEL2_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLAGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_DLAGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLDVGTR','${DFILI}/${ENV_PREFIX}_ESID2550_I4_PC___DLDVGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLREGTR','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRPGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRTGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLSGTAR','${DFILI}/${ENV_PREFIX}_ESID1800_DLSGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLVGTR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_FTRSLNK7','${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK7_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_FTVENTNP','${DFILP}/${ENV_PREFIX}_ESID0060_FTVENTNP_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLREGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREGTAR_${PARM0_ICLODAT_D}.dat', 'I', ' ' )
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRNPGTR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRPGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRPGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRTCGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRTFGTR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRTGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_VENTNP_TRIMCUR','${DFILP}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMCUR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRNPGTAR','${DFILP}/${ENV_PREFIX}_ESID1550_DLRNPGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRTCGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTCGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLRTFGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_DLRTFGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_FPLATXCUM','${DFILI}/${ENV_PREFIX}_ESID0560_FPLATXCUM_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_VENTNP_TRIMPREV','${DFILP}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMPREV.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLASIIGTAR','${DFILI}/${ENV_PREFIX}_ESID3600_DLASIIGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLDSIIGTAR','${DFILI}/${ENV_PREFIX}_ESID3700_DLDSIIGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLGTARSNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTARSNEM_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLREMAJGTR','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREMAJGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLREMAJGTAR','${DFILP}/${ENV_PREFIX}_ESID2500_I4_PC___DLREMAJGTAR_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_CADVPERIESB0','${DFILI}/${ENV_PREFIX}_ESID0060_CADVPERIESB0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_IADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_IRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_IRDVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLVGTAR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_IADVPERICASE_ENTIER','${DFILP}/${ENV_PREFIX}_ESID0560_IADVPERICASE_ENTIER_${PARM0_ICLODAT_D}.dat','I','')
--Output
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_TOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_I4_PC___TOTGTR_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_I4_PC___TOTGTAR_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLDVGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_I4_PC___DLDVGTAR_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLTOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_I4_PC___DLTOTGTR_${PARM0_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2560_I4_PC___',  'EST_DLTOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_I4_PC___DLTOTGTAR_${PARM0_ICLODAT_D}.dat','O','')



-------------------------------
print	"--	Init  ESID3800_I4_PC_M__"
-------------------------------


---------  IDF_CT = 'ESID3800_I4_PC_M__'  ---------------------

delete BEST..TI17PERMFIL where  IDF_CT = 'ESID3800_I4_PC_M__'
IF NOT EXISTS (SELECT * FROM BEST..TI17FNC where IDF_CT = 'ESID3800_I4_PC_M__' ) insert into BEST..TI17FNC values ( 'ESID3800_I4_PC_M__','')




-- input
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_DLREJGTR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_DLREJGTAA','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_DLREJGTAR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_IGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_I4_PC___IGTAR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
--insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FCLIENT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCLIENT_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FCTRGRO0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FSOBBLOB','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSOBBLOB_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_DLTOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_I4_PC___DLTOTGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FPLACEMT2','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT2_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_DLTOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_I4_PC___DLTOTGTAA_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_DLTOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_I4_PC___DLTOTGTAR_${PARM0_ICLODAT_D}.dat','I','')
--insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_DLGTAASNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTAASNEM_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_IADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_IRDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_IRDVPERICASE0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_OADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_OADVPERICASE0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_ORDVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1500_ORDVPERICASE0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
-- output 
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FSNEMHIST0','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FSNEMHIST0.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FTECLEDASNEM','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDASNEM.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FTECLEDA_MTH','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDA_MTH.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDA_MVT.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FTECLEDA_REP','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDA_REP.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FTECLEDRSNEM','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDRSNEM.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_M__',  'EST_FTECLEDR_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDR_MVT.dat','O','')

----------  IDF_CT = 'ESID3800_I4_PC_C__'  ---------------------

delete BEST..TI17PERMFIL where  IDF_CT = 'ESID3800_I4_PC_C__'
IF NOT EXISTS (SELECT * FROM BEST..TI17FNC where IDF_CT = 'ESID3800_I4_PC_C__' ) insert into BEST..TI17FNC values ( 'ESID3800_I4_PC_C__','')


-- input
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_DLREJGTR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_DLREJGTAA','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_DLREJGTAR','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_GTA','${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat','I','')
--insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_GTR','${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_IGTAR','${DFILP}/${ENV_PREFIX}_ESID0560_IGTAR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_CURGTA','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_CURGTR','${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat','I','')
--insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_SUBTRS','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FCLIENT','${DFILI}/${ENV_PREFIX}_ESCJ0060_FCLIENT_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FCPLACC','${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FCTRGRO','${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FCTRGRO0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FSOBBLOB','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSOBBLOB_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FSSDACTR','${DFILI}/${ENV_PREFIX}_ESCJ0060_FSSDACTR_${PARM_CLODAT_D}.dat','I','')
--insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_DLTOTGTR','${DFILI}/${ENV_PREFIX}_ESID2560_I4_PC___DLTOTGTR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FPLACEMT2','${DFILI}/${ENV_PREFIX}_ESEH1110_FPLACEMT2_${PARM_CLODAT_D}.dat','I','')
--insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_DLTOTGTAA','${DFILI}/${ENV_PREFIX}_ESID2060_I4_PC___DLTOTGTAA_${PARM0_ICLODAT_D}.dat','I','')
--insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_DLTOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_I4_PC___DLTOTGTAR_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_DLGTAASNEM','${DFILI}/${ENV_PREFIX}_ESID2100_DLGTAASNEM_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_IADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_IADVPERICASE0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_IRDVPERICASE0','${DFILP}/${ENV_PREFIX}_ESID1500_IRDVPERICASE0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_OADVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1000_OADVPERICASE0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_ORDVPERICASE0','${DFILI}/${ENV_PREFIX}_ESID1500_ORDVPERICASE0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_OIADVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIADVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_OIRDVPERICASE','${DFILP}/${ENV_PREFIX}_ESID0560_OIRDVPERICASE_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','O','')

insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FTECLEDA_CUR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_CUR.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID3800_I4_PC_C__',  'EST_FTECLEDR_CUR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_CUR.dat','O','')


-------------------------------
print	"--      Init  ESID8700"
-------------------------------


----------  IDF_CT = 'ESID8700_I4_PC___'  ---------------------

delete BEST..TI17PERMFIL where  IDF_CT = 'ESID8700_I4_PC___'
IF NOT EXISTS (SELECT * FROM BEST..TI17FNC where IDF_CT = 'ESID8700_I4_PC___' ) insert into BEST..TI17FNC values ( 'ESID8700_I4_PC___','')

-- Input	                                                        
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_FTECLEDA_CUR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_CUR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_FTECLEDA_MTH','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDA_MTH.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_FTECLEDA_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDA_MVT.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_FTECLEDA_REP','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDA_REP.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_FTECLEDR_CUR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_CUR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_FTECLEDR_MVT','${DFILP}/${ENV_PREFIX}_ESID3800_I4_PC___FTECLEDR_MVT.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_SUBTRS_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_FSUBTRS_TXT_${PARM0_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_SUBTRSESBPROP_TXT','${DFILP}/${ENV_PREFIX}_ESCJ0060_SUBTRSESBPROP_TXT_${PARM0_ICLODAT_D}.dat','I','')
-- Output	                                                       
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDA.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID8700_I4_PC___',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDR.dat','O','')
go

-------------------------------
print	"--      Init  ESID8710: TNR SPLIT"
-------------------------------


----------  IDF_CT = 'ESID8710'  ---------------------

delete BEST..TI17PERMFIL where  IDF_CT = 'ESID8710'
IF NOT EXISTS (SELECT * FROM BEST..TI17FNC where IDF_CT = 'ESID8710' ) insert into BEST..TI17FNC values ( 'ESID8710','')

-- Input	                                                        
insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDA_PC','${DFILP}/${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDA.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDR_PC','${DFILP}/${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDR.dat','I','')
-- Output	                                                       
insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDA_DIFF','${DFILI}/${ENV_PREFIX}_ESID8710_DIFF_FTECLEDA.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID8710',  'EST_FTECLEDR_DIFF','${DFILI}/${ENV_PREFIX}_ESID8710_DIFF_FTECLEDR.dat','O','')
go

-----------------------------------------------------------------------------------------------------------

print "------>>>> End  SPIRA 81838 : Extraction d'une branche P&C"
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------

print '------>>>> Start  SPIRA 84317 : Optimisation 2000'
-----------------------------------------------------------------------------------------------------------

-------------------------------
--	Init  ESFD2000
-------------------------------

delete BEST..TI17PERMFIL where IDF_CT ='ESFD2000'
delete BEST..TI17REQCHN where   IDF_CT = 'ESFD2000' and  CHAIN_CT='ESFD2000'
delete BEST..TI17CHN  where CHAIN_CT='ESFD2000'
delete BEST..TI17FNC where IDF_CT  ='ESFD2000'

insert into BEST..TI17CHN values ('ESFD2000',  '')

--  ESFD2000 

insert into BEST..TI17FNC values ('ESFD2000',  '')

----------  Perms---------------------
-- Input
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FDETTRS_TXT', '${DFILP}/${PCH}ESCJ0060_FDETTRS_TXT_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FTRSLNK_TXT', '${DFILP}/${PCH}ESCJ0060_FTRSLNK_TXT_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCURQUOT_TXT', '${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT_TXT_${ICLODAT}.dat', 'O', '')                                       

insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_MVTPNA', '${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNA_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCPLACC', '${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERICASE', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERIPRMD', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIPRMD_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTRGRO', '${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DTSTATGTAA', '${DFILI}/${ENV_PREFIX}_ESID0560_DTSTATGTAA_${ICLODAT}.dat', 'I', '')                                           
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_MVTPNAC', '${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNAC_${ICLODAT}.dat', 'I', '')                                                 

insert into BEST..TI17PERMFIL values ('ESFD2000',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${CLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESFD2000',  'EST_IADPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_${CLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESFD2000',  'EST_IADPERIPRMD0','${DFILI}/${ENV_PREFIX}_ESID0060_IADPERIPRMD0_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESFD2000',  'EST_FCTRGRO0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESFD2000',  'EST_MVTPNA0','${DFILI}/${ENV_PREFIX}_ESID0070_MVTPNA0_${CLODAT}.dat','O','')

--output
-- à changer en temporaire 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERICASE_EXTEND', '${DFILI}/${ENV_PREFIX}_ESFD2000_IADPERICASE_EXTEND_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DGTAA', '${DFILI}/${ENV_PREFIX}_ESFD2000_DGTAA_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_PERIANO', '${DFILI}/${ENV_PREFIX}_ESFD2000_PERIANO_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DSUMGTAA_TERM', '${DFILI}/${ENV_PREFIX}_ESFD2000_DSUMGTAA_TERM_${ICLODAT}.dat', 'O', '')  
-- fin à changé en temporaire 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERICASE_TERM', '${DFILI}/${ENV_PREFIX}_ESFD2000_IADPERICASE_TERM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERICASE_NON_TERM', '${DFILI}/${ENV_PREFIX}_ESFD2000_IADPERICASE_NON_TERM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAFACPNAE', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAFACPNAE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAFACPNAERPCC', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAFACPNAERPCC_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERIPRMD_CONV', '${DFILI}/${ENV_PREFIX}_ESFD2000_IADPERIPRMD_CONV_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DSUMGTAAREC', '${DFILI}/${ENV_PREFIX}_ESFD2000_DSUMGTAAREC_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAAFPRE', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAAFPRE_${ICLODAT}.dat', 'O', '')                                            
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DSUMGTAASNEM_ESTC1005A', '${DFILI}/${ENV_PREFIX}_ESFD2000_DSUMGTAASNEM_ESTC1005A_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_PERICASESNEM', '${DFILP}/${ENV_PREFIX}_ESFD2000_PERICASESNEM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTRGRO1', '${DFILI}/${ENV_PREFIX}_ESFD2000_FCTRGRO1_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLCUMGTAA_TERM', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLCUMGTAA_TERM_${ICLODAT}.dat', '1', '')              
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DSUMGTAA', '${DFILI}/${ENV_PREFIX}_ESFD2000_DSUMGTAA_${ICLODAT}.dat', 'O', '')                                               
go


--	Init  ESFD2000
-------------------------------

delete BEST..TI17PERMFIL where IDF_CT ='ESFD2000'
delete BEST..TI17REQCHN where   IDF_CT = 'ESFD2000' and  CHAIN_CT='ESFD2000'
delete BEST..TI17CHN  where CHAIN_CT='ESFD2000'
delete BEST..TI17FNC where IDF_CT  ='ESFD2000'

insert into BEST..TI17CHN values ('ESFD2000',  '')

--  ESFD2000 

insert into BEST..TI17FNC values ('ESFD2000',  '')

----------  Perms---------------------
--input																																													
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_CURGTA', '${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat', 'I', '')                                                              
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCURQUOT', '${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat', 'I', '')                                                          
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_ARCSTATGTA', '${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat', 'I', '')                                                      
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FDETTRS', '${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat', 'I', '')                                                  
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FTRSLNK', '${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat', 'I', '')                                                  
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCPLACC', '${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTREST', '${DFILI}/${ENV_PREFIX}_ESID0560_FCTREST_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTRGRO', '${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTRULT', '${DFILI}/${ENV_PREFIX}_ESID0560_FCTRULT_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FLABOCY', '${DFILI}/${ENV_PREFIX}_ESID0560_FLABOCY_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FSEGEST', '${DFILI}/${ENV_PREFIX}_ESID0560_FSEGEST_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_MVTPNAC', '${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNAC_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTREST0', '${DFILI}/${ENV_PREFIX}_ESID0060_FCTREST0_${CLODAT}.dat', 'I', '')                                                
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FTFAMCHG', '${DFILI}/${ENV_PREFIX}_ESCJ0060_FTFAMCHG_${CLODAT}.dat', 'I', '')                                                
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTRESTA', '${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT}.dat', 'I', '')                                               
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FBOPRSLNK', '${DFILI}/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_${CLODAT}.dat', 'I', '')                                              
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERIFR', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFR_${ICLODAT}.dat', 'I', '')                                             
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FTHRHLDUWY', '${DFILI}/${ENV_PREFIX}_ESID0060_FTHRHLDUWY_${CLODAT}.dat', 'I', '')                                            
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DTSTATGTAA', '${DFILI}/${ENV_PREFIX}_ESID0560_DTSTATGTAA_${ICLODAT}.dat', 'I', '')                                           
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERIFCI', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCI_${ICLODAT}.dat', 'I', '')                                           
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERIFCT', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCT_${ICLODAT}.dat', 'I', '')                                           
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERICASE', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT}.dat', 'I', '')                                         
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_SAISPERICASE', '${DFILP}/${ENV_PREFIX}_ESEH1110_SAISPERICASE_${CLODAT}.dat', 'I', '')                                        
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FSEGEST_SOLVENCY', '${DFILI}/${ENV_PREFIX}_ESID0560_FSEGEST_SOLVENCY_${ICLODAT}.dat', 'I', '')                               
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERICASE_TERM', '${DFILI}/${ENV_PREFIX}_ESFD2000_IADPERICASE_TERM_${ICLODAT}.dat', 'O', '')

-- input venant ESFD2000
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAAFPRE', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAAFPRE_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAFACPNAE', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAFACPNAE_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAFACPNAERPCC', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAFACPNAERPCC_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DSUMGTAASNEM_ESTC1005A', '${DFILI}/${ENV_PREFIX}_ESFD2000_DSUMGTAASNEM_ESTC1005A_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTRGRO1', '${DFILI}/${ENV_PREFIX}_ESFD2000_FCTRGRO1_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLCUMGTAA_TERM', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLCUMGTAA_TERM_${ICLODAT}.dat', '1', '')              
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERICASE_NON_TERM', '${DFILI}/${ENV_PREFIX}_ESFD2000_IADPERICASE_NON_TERM_${ICLODAT}.dat', 'I', '')  
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IADPERIPRMD_CONV', '${DFILI}/${ENV_PREFIX}_ESFD2000_IADPERIPRMD_CONV_${ICLODAT}.dat', 'I', '')  																																				
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DSUMGTAA', '${DFILI}/${ENV_PREFIX}_ESFD2000_DSUMGTAA_${ICLODAT}.dat', 'I', '')                                               
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DSUMGTAAREC', '${DFILI}/${ENV_PREFIX}_ESFD2000_DSUMGTAAREC_${ICLODAT}.dat', 'I', '')                                         
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_PERICASESNEM', '${DFILP}/${ENV_PREFIX}_ESFD2000_PERICASESNEM_${ICLODAT}.dat', 'O', '')
																																													
--output																																													
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAAPNAE', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAAPNAE_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAAPA', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAAPA_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FT', '${DFILI}/${ENV_PREFIX}_ESFD2000_FT_${ICLODAT}.dat', 'O', '')                                                           
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FTFAC', '${DFILI}/${ENV_PREFIX}_ESFD2000_FTFAC_${ICLODAT}.dat', 'O', '')                                                     
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FT_EBS', '${DFILI}/${ENV_PREFIX}_ESFD2000_FT_EBS_${ICLODAT}.dat', 'O', '')                                                   
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_NPSAIS', '${DFILI}/${ENV_PREFIX}_ESFD2000_NPSAIS_${ICLODAT}.dat', 'O', '')                                                   
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLCGTAA', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLCGTAA_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLDGTAA', '${DFILP}/${ENV_PREFIX}_ESFD2000_DLDGTAA_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FLOARAT', '${DFILI}/${ENV_PREFIX}_ESFD2000_FLOARAT_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FPRMLOA', '${DFILI}/${ENV_PREFIX}_ESFD2000_FPRMLOA_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FT_IFRS', '${DFILI}/${ENV_PREFIX}_ESFD2000_FT_IFRS_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_LABOCY1', '${DFILI}/${ENV_PREFIX}_ESFD2000_LABOCY1_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_CTRULT02', '${DFILI}/${ENV_PREFIX}_ESFD2000_CTRULT02_${ICLODAT}.dat', 'O', '')                                               
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTREST1', '${DFILI}/${ENV_PREFIX}_ESFD2000_FCTREST1_${ICLODAT}.dat', 'O', '')                                               
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FTTR_PRM', '${DFILI}/${ENV_PREFIX}_ESFD2000_FTTR_PRM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DCGTAALOA', '${DFILI}/${ENV_PREFIX}_ESFD2000_DCGTAALOA_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLCUMGTAA', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLCUMGTAA_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAAPRE', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAAPRE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLCGTAAREC', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLCGTAAREC_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLCUMGTAAS', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLCUMGTAAS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAARPPE', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAARPPE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FUTURE_EBS', '${DFILI}/${ENV_PREFIX}_ESFD2000_FUTURE_EBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLCGTAAEPPE', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLCGTAAEPPE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLDGTAA_EBS', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLDGTAA_EBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FLOARATSNEM', '${DFILP}/${ENV_PREFIX}_ESFD2000_FLOARATSNEM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FLOARAT_EBS', '${DFILI}/${ENV_PREFIX}_ESFD2000_FLOARAT_EBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FPRMLOA_EBS', '${DFILI}/${ENV_PREFIX}_ESFD2000_FPRMLOA_EBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLDGTAA_IFRS', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLDGTAA_IFRS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLGTAATFPNAE', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLGTAATFPNAE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DSUMGTAASNEM', '${DFILP}/${ENV_PREFIX}_ESFD2000_DSUMGTAASNEM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FLOARAT_IFRS', '${DFILI}/${ENV_PREFIX}_ESFD2000_FLOARAT_IFRS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FPRMLOA_IFRS', '${DFILI}/${ENV_PREFIX}_ESFD2000_FPRMLOA_IFRS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_FCTREST1_IFRS', '${DFILI}/${ENV_PREFIX}_ESFD2000_FCTREST1_IFRS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_BLANCHIMENT_RPCC', '${DFILI}/${ENV_PREFIX}_ESFD2000_BLANCHIMENT_RPCC_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLDGTAA_E_TRNCODEBS', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLDGTAA_E_TRNCODEBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_DLDGTAA_E_TRNCODBEST', '${DFILI}/${ENV_PREFIX}_ESFD2000_DLDGTAA_E_TRNCODBEST_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESFD2000', 'EST_IBNR_IFRS','${DFILI}/${ENV_PREFIX}_ESFD2000_IBNR_IFRS_${ICLODAT}.dat','O','')

go

-- version mapping définitif ESID2000

-------------------------------
--	Init  ESID2000
-------------------------------

delete BEST..TI17PERMFIL where IDF_CT ='ESID2000'
delete BEST..TI17REQCHN where   IDF_CT = 'ESID2000' and  CHAIN_CT='ESID2000'
delete BEST..TI17CHN  where CHAIN_CT='ESID2000'
delete BEST..TI17FNC where IDF_CT  ='ESID2000'

insert into BEST..TI17CHN values ('ESID2000',  '')

--  ESID2000 

insert into BEST..TI17FNC values ('ESID2000',  '')

----------  Perms---------------------
-- Input
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FDETTRS_TXT', '${DFILP}/${PCH}ESCJ0060_FDETTRS_TXT_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FTRSLNK_TXT', '${DFILP}/${PCH}ESCJ0060_FTRSLNK_TXT_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCURQUOT_TXT', '${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT_TXT_${ICLODAT}.dat', 'O', '')                                       

insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_MVTPNA', '${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNA_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCPLACC', '${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERICASE', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERIPRMD', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIPRMD_${ICLODAT}.dat', 'I', '')
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRGRO', '${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${ICLODAT}.dat', 'I', '')                                                 
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DTSTATGTAA', '${DFILI}/${ENV_PREFIX}_ESID0560_DTSTATGTAA_${ICLODAT}.dat', 'I', '')                                           
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_MVTPNAC', '${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNAC_${ICLODAT}.dat', 'I', '')                                                 

insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCPLACC0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0_${CLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_IADPERICASE0','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_${CLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_IADPERIPRMD0','${DFILI}/${ENV_PREFIX}_ESID0060_IADPERIPRMD0_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_FCTRGRO0','${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_${PARM_CLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2000',  'EST_MVTPNA0','${DFILI}/${ENV_PREFIX}_ESID0070_MVTPNA0_${CLODAT}.dat','O','')

--output
-- à changer en temporaire 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERICASE_EXTEND', '${DFILI}/${ENV_PREFIX}_ESID2000_IADPERICASE_EXTEND_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DGTAA', '${DFILI}/${ENV_PREFIX}_ESID2000_DGTAA_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_PERIANO', '${DFILI}/${ENV_PREFIX}_ESID2000_PERIANO_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DSUMGTAA_TERM', '${DFILI}/${ENV_PREFIX}_ESID2000_DSUMGTAA_TERM_${ICLODAT}.dat', 'O', '')  
-- fin à changé en temporaire 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERICASE_TERM', '${DFILI}/${ENV_PREFIX}_ESID2000_IADPERICASE_TERM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERICASE_NON_TERM', '${DFILI}/${ENV_PREFIX}_ESID2000_IADPERICASE_NON_TERM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAFACPNAE', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAFACPNAE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAFACPNAERPCC', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAFACPNAERPCC_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERIPRMD_CONV', '${DFILI}/${ENV_PREFIX}_ESID2000_IADPERIPRMD_CONV_${ICLODAT}.dat', 'O', '')
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DSUMGTAAREC', '${DFILI}/${ENV_PREFIX}_ESID2000_DSUMGTAAREC_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAAFPRE', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAFPRE_${ICLODAT}.dat', 'O', '')                                            
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DSUMGTAASNEM_ESTC1005A', '${DFILI}/${ENV_PREFIX}_ESID2000_DSUMGTAASNEM_ESTC1005A_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_PERICASESNEM', '${DFILP}/${ENV_PREFIX}_ESID2000_PERICASESNEM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRGRO1', '${DFILI}/${ENV_PREFIX}_ESID2000_FCTRGRO1_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLCUMGTAA_TERM', '${DFILI}/${ENV_PREFIX}_ESID2000_DLCUMGTAA_TERM_${ICLODAT}.dat', '1', '')              
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DSUMGTAA', '${DFILI}/${ENV_PREFIX}_ESID2000_DSUMGTAA_${ICLODAT}.dat', 'O', '')                                               
go




----------  Perms---------------------
--input																																													
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_CURGTA', '${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat', 'I', '')                                                              
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCURQUOT', '${DFILP}/${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat', 'I', '')                                                          
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_ARCSTATGTA', '${DFILP}/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat', 'I', '')                                                      
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FDETTRS', '${DFILP}/${ENV_PREFIX}_ESCJ0060_FDETTRS_${CLODAT}.dat', 'I', '')                                                  
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FTRSLNK', '${DFILI}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_${CLODAT}.dat', 'I', '')                                                  
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCPLACC', '${DFILP}/${ENV_PREFIX}_ESID0560_FCPLACC_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTREST', '${DFILI}/${ENV_PREFIX}_ESID0560_FCTREST_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRGRO', '${DFILP}/${ENV_PREFIX}_ESID0560_FCTRGRO_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRULT', '${DFILI}/${ENV_PREFIX}_ESID0560_FCTRULT_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FLABOCY', '${DFILI}/${ENV_PREFIX}_ESID0560_FLABOCY_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FSEGEST', '${DFILI}/${ENV_PREFIX}_ESID0560_FSEGEST_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_MVTPNAC', '${DFILI}/${ENV_PREFIX}_ESID0560_MVTPNAC_${ICLODAT}.dat', 'I', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTREST0', '${DFILI}/${ENV_PREFIX}_ESID0060_FCTREST0_${CLODAT}.dat', 'I', '')                                                
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FTFAMCHG', '${DFILI}/${ENV_PREFIX}_ESCJ0060_FTFAMCHG_${CLODAT}.dat', 'I', '')                                                
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRESTA', '${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT}.dat', 'I', '')                                               
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FBOPRSLNK', '${DFILI}/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_${CLODAT}.dat', 'I', '')                                              
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERIFR', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFR_${ICLODAT}.dat', 'I', '')                                             
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FTHRHLDUWY', '${DFILI}/${ENV_PREFIX}_ESID0060_FTHRHLDUWY_${CLODAT}.dat', 'I', '')                                            
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DTSTATGTAA', '${DFILI}/${ENV_PREFIX}_ESID0560_DTSTATGTAA_${ICLODAT}.dat', 'I', '')                                           
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERIFCI', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCI_${ICLODAT}.dat', 'I', '')                                           
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERIFCT', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERIFCT_${ICLODAT}.dat', 'I', '')                                           
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERICASE', '${DFILI}/${ENV_PREFIX}_ESID0560_IADPERICASE_${ICLODAT}.dat', 'I', '')                                         
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_SAISPERICASE', '${DFILP}/${ENV_PREFIX}_ESEH1110_SAISPERICASE_${CLODAT}.dat', 'I', '')                                        
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FSEGEST_SOLVENCY', '${DFILI}/${ENV_PREFIX}_ESID0560_FSEGEST_SOLVENCY_${ICLODAT}.dat', 'I', '')                               
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERICASE_TERM', '${DFILI}/${ENV_PREFIX}_ESID2000_IADPERICASE_TERM_${ICLODAT}.dat', 'O', '')

-- input venant ESID2000
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAAFPRE', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAFPRE_${ICLODAT}.dat', 'I', '')
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAFACPNAE', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAFACPNAE_${ICLODAT}.dat', 'I', '')
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAFACPNAERPCC', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAFACPNAERPCC_${ICLODAT}.dat', 'I', '')
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DSUMGTAASNEM_ESTC1005A', '${DFILI}/${ENV_PREFIX}_ESID2000_DSUMGTAASNEM_ESTC1005A_${ICLODAT}.dat', 'I', '')
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRGRO1', '${DFILI}/${ENV_PREFIX}_ESID2000_FCTRGRO1_${ICLODAT}.dat', 'I', '')
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLCUMGTAA_TERM', '${DFILI}/${ENV_PREFIX}_ESID2000_DLCUMGTAA_TERM_${ICLODAT}.dat', '1', '')              
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERICASE_NON_TERM', '${DFILI}/${ENV_PREFIX}_ESID2000_IADPERICASE_NON_TERM_${ICLODAT}.dat', 'I', '')  
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IADPERIPRMD_CONV', '${DFILI}/${ENV_PREFIX}_ESID2000_IADPERIPRMD_CONV_${ICLODAT}.dat', 'I', '')  																																				
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DSUMGTAA', '${DFILI}/${ENV_PREFIX}_ESID2000_DSUMGTAA_${ICLODAT}.dat', 'I', '')                                               
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DSUMGTAAREC', '${DFILI}/${ENV_PREFIX}_ESID2000_DSUMGTAAREC_${ICLODAT}.dat', 'I', '')                                         
--insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_PERICASESNEM', '${DFILP}/${ENV_PREFIX}_ESID2000_PERICASESNEM_${ICLODAT}.dat', 'O', '')
																																													
--output																																													
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAAPNAE', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAPNAE_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAAPA', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAPA_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FT', '${DFILI}/${ENV_PREFIX}_ESID2000_FT_${ICLODAT}.dat', 'O', '')                                                           
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FTFAC', '${DFILI}/${ENV_PREFIX}_ESID2000_FTFAC_${ICLODAT}.dat', 'O', '')                                                     
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FT_EBS', '${DFILI}/${ENV_PREFIX}_ESID2000_FT_EBS_${ICLODAT}.dat', 'O', '')                                                   
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_NPSAIS', '${DFILI}/${ENV_PREFIX}_ESID2000_NPSAIS_${ICLODAT}.dat', 'O', '')                                                   
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLCGTAA', '${DFILI}/${ENV_PREFIX}_ESID2000_DLCGTAA_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLDGTAA', '${DFILP}/${ENV_PREFIX}_ESID2000_DLDGTAA_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FLOARAT', '${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FPRMLOA', '${DFILI}/${ENV_PREFIX}_ESID2000_FPRMLOA_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FT_IFRS', '${DFILI}/${ENV_PREFIX}_ESID2000_FT_IFRS_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_LABOCY1', '${DFILI}/${ENV_PREFIX}_ESID2000_LABOCY1_${ICLODAT}.dat', 'O', '')                                                 
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_CTRULT02', '${DFILI}/${ENV_PREFIX}_ESID2000_CTRULT02_${ICLODAT}.dat', 'O', '')                                               
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTREST1', '${DFILI}/${ENV_PREFIX}_ESID2000_FCTREST1_${ICLODAT}.dat', 'O', '')                                               
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FTTR_PRM', '${DFILI}/${ENV_PREFIX}_ESID2000_FTTR_PRM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DCGTAALOA', '${DFILI}/${ENV_PREFIX}_ESID2000_DCGTAALOA_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLCUMGTAA', '${DFILI}/${ENV_PREFIX}_ESID2000_DLCUMGTAA_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAAPRE', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAAPRE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLCGTAAREC', '${DFILI}/${ENV_PREFIX}_ESID2000_DLCGTAAREC_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLCUMGTAAS', '${DFILI}/${ENV_PREFIX}_ESID2000_DLCUMGTAAS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAARPPE', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAARPPE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FUTURE_EBS', '${DFILI}/${ENV_PREFIX}_ESID2000_FUTURE_EBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLCGTAAEPPE', '${DFILI}/${ENV_PREFIX}_ESID2000_DLCGTAAEPPE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLDGTAA_EBS', '${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_EBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FLOARATSNEM', '${DFILP}/${ENV_PREFIX}_ESID2000_FLOARATSNEM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FLOARAT_EBS', '${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_EBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FPRMLOA_EBS', '${DFILI}/${ENV_PREFIX}_ESID2000_FPRMLOA_EBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLDGTAA_IFRS', '${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_IFRS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLGTAATFPNAE', '${DFILI}/${ENV_PREFIX}_ESID2000_DLGTAATFPNAE_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DSUMGTAASNEM', '${DFILP}/${ENV_PREFIX}_ESID2000_DSUMGTAASNEM_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FLOARAT_IFRS', '${DFILI}/${ENV_PREFIX}_ESID2000_FLOARAT_IFRS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FPRMLOA_IFRS', '${DFILI}/${ENV_PREFIX}_ESID2000_FPRMLOA_IFRS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTREST1_IFRS', '${DFILI}/${ENV_PREFIX}_ESID2000_FCTREST1_IFRS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_BLANCHIMENT_RPCC', '${DFILI}/${ENV_PREFIX}_ESID2000_BLANCHIMENT_RPCC_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLDGTAA_E_TRNCODEBS', '${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_E_TRNCODEBS_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_DLDGTAA_E_TRNCODBEST', '${DFILI}/${ENV_PREFIX}_ESID2000_DLDGTAA_E_TRNCODBEST_${ICLODAT}.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_IBNR_IFRS','${DFILI}/${ENV_PREFIX}_ESID2000_IBNR_IFRS_${ICLODAT}.dat','O','')

go

-----------------------------------------------------------------------------------------------------------

print "------>>>> End  SPIRA 84317 : Optimisation 2000"
-----------------------------------------------------------------------------------------------------------
	


-----------------------------------------------------------------------------------------------------------
print "------>>>> Charles/Antoine request: SPIRA 77471_82557 : change mapping ESFD3750"

DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSM_ALL_STD' and PERMFIL_CT in ('ESF_GTSII_CSESF_GTSII_CSMM','ESF_GTSII_CSM','ESF_CSM_PROF','ESF_FSEGPROF_STD')

insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD','ESF_GTSII_CSM','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD','ESF_CSM_PROF','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_PROF_BY_CTR_${PARM_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ALL_STD','ESF_FSEGPROF_STD','${DFILP}/${PCH}ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${PARM_ICLODAT_D}.dat','I','')

DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_IEX_ALL_INI' and PERMFIL_CT in ('EST_FCURQUOT_TXT')
DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_IEX_ALL_STD' and PERMFIL_CT in ('EST_FCURQUOT_TXT')
DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSF_ALL_INI' and PERMFIL_CT in ('EST_FCURQUOT_TXT')

insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','') 
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','')

	
print "------>>>> End Charles/Antoine request: SPIRA 77471_82557 : change mapping ESFD3750"
GO
-----------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------
print "------>>>> Lahcen request: SPIRA 79102 update mapping I17G_IEX_ALL_STD "


update BEST..TI17PERMFIL 
set pathpattrn_ll = '${DFILI}/${PCH}ESPD2570_RETITDPRM.dat'
where idf_ct= 'I17G_IEX_ALL_STD' 
and PERMFIL_CT = 'ESF_RETRO_ITDPREMIUM'

update BEST..TI17PERMFIL 
set pathpattrn_ll = '${DFILI}/${PCH}ESPD2570_RETUPR_ESTIME.dat'
where idf_ct= 'I17G_IEX_ALL_STD' 
and PERMFIL_CT = 'ESF_RETRO_UPR'

print "------>>>> End Lahcen request: SPIRA 79102 update mapping I17G_IEX_ALL_STD "

GO
-----------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------
print '------>>>> Charles request : SPIRA 83091 : add idf_ct for "ESFD3620 EBS"  '
 
delete BEST..TI17PERMFIL where                         IDF_CT in ('ESFD3620_POSE', 'ESFD3620_POCE','ESFD3620_BookingPOSE','ESFD3620_BookingPOCE', 'ESFD3620_BookingPOSEAnnuel','ESFD3620_BookingPOCEAnnuel') 
delete BEST..TI17REQCHN  where CHAIN_CT='ESFD3620' and IDF_CT in ('ESFD3620_POSE', 'ESFD3620_POCE','ESFD3620_BookingPOSE','ESFD3620_BookingPOCE', 'ESFD3620_BookingPOSEAnnuel','ESFD3620_BookingPOCEAnnuel')  
delete BEST..TI17FNC     where                         IDF_CT in ('ESFD3620_POSE', 'ESFD3620_POCE','ESFD3620_BookingPOSE','ESFD3620_BookingPOCE', 'ESFD3620_BookingPOSEAnnuel','ESFD3620_BookingPOCEAnnuel') 

insert into BEST..TI17FNC values ('ESFD3620_POSE',  'DSC Post omega social EBS')
insert into BEST..TI17FNC values ('ESFD3620_POCE',  'DSC Post omega CONSO EBS')
insert into BEST..TI17FNC values ('ESFD3620_BookingPOSE',  'DSC Post omega social EBS')
insert into BEST..TI17FNC values ('ESFD3620_BookingPOCE',  'DSC Post omega CONSO EBS')
insert into BEST..TI17FNC values ('ESFD3620_BookingPOSEAnnuel',  'DSC Post omega social EBS')
insert into BEST..TI17FNC values ('ESFD3620_BookingPOCEAnnuel',  'DSC Post omega CONSO EBS')
 
----------  Perms---------------------

insert into BEST..TI17PERMFIL values ('ESFD3620_POSE', 'ESF_FPRSMAP_TXT', '${DFILP}/${ENV_PREFIX}_ESPT0000_FPRSMAP_TXT_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POSE', 'EST_GTSII_GLOBAL_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POSE', 'EST_FSEGPATTERN_DSC', '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POSE', 'EPO_FCURSII', '${DFILP}/${ENV_PREFIX}_ESPT0000_FCURSII.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POSE', 'ESF_TRERETFACCTR', '${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR.dat ', 'I', '') 
insert into BEST..TI17PERMFIL values ('ESFD3620_POSE', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat', 'O', '')

insert into BEST..TI17PERMFIL values ('ESFD3620_POCE', 'ESF_FPRSMAP_TXT', '${DFILP}/${ENV_PREFIX}_ESPT0000_FPRSMAP_TXT_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POCE', 'EST_GTSII_GLOBAL_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POCE', 'EST_FSEGPATTERN_DSC', '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POCE', 'EPO_FCURSII', '${DFILP}/${ENV_PREFIX}_ESPT0000_FCURSII.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POCE', 'ESF_TRERETFACCTR', '${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR.dat ', 'I', '') 
insert into BEST..TI17PERMFIL values ('ESFD3620_POCE', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat', 'O', '')

insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSE', 'ESF_FPRSMAP_TXT', '${DFILP}/${ENV_PREFIX}_ESPT0000_FPRSMAP_TXT_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSE', 'EST_GTSII_GLOBAL_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSE', 'EST_FSEGPATTERN_DSC', '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSE', 'EPO_FCURSII', '${DFILP}/${ENV_PREFIX}_ESPT0000_FCURSII.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSE', 'ESF_TRERETFACCTR', '${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR.dat ', 'I', '') 
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSE', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat', 'O', '')

insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCE', 'ESF_FPRSMAP_TXT', '${DFILP}/${ENV_PREFIX}_ESPT0000_FPRSMAP_TXT_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCE', 'EST_GTSII_GLOBAL_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCE', 'EST_FSEGPATTERN_DSC', '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCE', 'EPO_FCURSII', '${DFILP}/${ENV_PREFIX}_ESPT0000_FCURSII.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCE', 'ESF_TRERETFACCTR', '${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR.dat ', 'I', '') 
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCE', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat', 'O', '')

insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSEAnnuel', 'ESF_FPRSMAP_TXT', '${DFILP}/${ENV_PREFIX}_ESPT0000_FPRSMAP_TXT_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSEAnnuel', 'EST_GTSII_GLOBAL_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSEAnnuel', 'EST_FSEGPATTERN_DSC', '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSEAnnuel', 'EPO_FCURSII', '${DFILP}/${ENV_PREFIX}_ESPT0000_FCURSII.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSEAnnuel', 'ESF_TRERETFACCTR', '${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR.dat ', 'I', '') 
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSEAnnuel', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat', 'O', '')
														   
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCEAnnuel', 'ESF_FPRSMAP_TXT', '${DFILP}/${ENV_PREFIX}_ESPT0000_FPRSMAP_TXT_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCEAnnuel', 'EST_GTSII_GLOBAL_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOW${TYPEINV0}_${ICLODAT}.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCEAnnuel', 'EST_FSEGPATTERN_DSC', '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCEAnnuel', 'EPO_FCURSII', '${DFILP}/${ENV_PREFIX}_ESPT0000_FCURSII.dat', 'I', '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCEAnnuel', 'ESF_TRERETFACCTR', '${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR.dat ', 'I', '') 
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCEAnnuel', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat', 'O', '')


insert into BEST..TI17REQCHN values ('POSE', 'ESFD3620','ESFD3620_POSE','POSE')
insert into BEST..TI17REQCHN values ('POCE', 'ESFD3620','ESFD3620_POCE','POCE')
insert into BEST..TI17REQCHN values ('BookingPOSE', 'ESFD3620','ESFD3620_BookingPOSE','BookingPOS')
insert into BEST..TI17REQCHN values ('BookingPOCE', 'ESFD3620','ESFD3620_BookingPOCE','BookingPOC')
insert into BEST..TI17REQCHN values ('BookingPOSEAnnuel', 'ESFD3620','ESFD3620_BookingPOSEAnnuel','BookingPOS')
insert into BEST..TI17REQCHN values ('BookingPOCEAnnuel', 'ESFD3620','ESFD3620_BookingPOCEAnnuel','BookingPOC')


print '------>>>> End Charles request : SPIRA 83091 : add idf_ct for "ESFD3620 EBS"  '
GO
----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
print '------>>>>  [65656] EPO_FCTREST_LOADCTL' 

delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_FCTREST_LOADCTL'
and IDF_CT in ('ESPD0060', 'ESPD8000_POSE', 'ESPD8000_POCE', 'ESPD8000_BookingPOSE', 'ESPD8000_BookingPOCE', 'ESPD8000_BookingPOSEAnnuel', 'ESPD8000_BookingPOCEAnnuel')

insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','O','')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel',  'EPO_FCTREST_LOADCTL','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST_LOADCTL.dat','I','')

print '------>>>>  [65656] End EPO_FCTREST_LOADCTL' 

go
----------------------------------------------------------------


----------------------------------------------------------------------- 
print '------>>>> Charles/Antoine requests : SPIRA 83091_77471 : mappings ESPD3620 ESFD3750 ESFD3780  '

delete BEST..TI17PERMFIL where IDF_CT in ('I17G_CSM_ALL_STD' ) and PERMFIL_CT='ESF_FSEGPROF_STD' 
delete BEST..TI17PERMFIL where IDF_CT in ('ESPD3620_POSE', 'ESPD3620_POCE','ESPD3620_BookingPOSE','ESPD3620_BookingPOCE', 'ESPD3620_BookingPOSEAnnuel','ESPD3620_BookingPOCEAnnuel' ) and PERMFIL_CT='ESF_GTSII_ESCOMPTE' 

insert into BEST..TI17PERMFIL values ('ESPD3620_POSE', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat' , 'I', '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat' , 'I', '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat' , 'I', '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat' , 'I', '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat' , 'I', '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel', 'ESF_GTSII_ESCOMPTE', '${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_ESCOMPTE_CLM_IFRS17.dat' , 'I', '')


print '------>>>> End Charles/Antoine requests : SPIRA 83091_77471 : mappings ESPD3620 ESFD3750 ESFD3780 '
 
go
----------------------------------------------------------------


----------------------------------------------------------------------- 
print '------>>>> Antoine request : SPIRA 77471 : mapping ESFD3780 '

delete BEST..TI17REQCHN where IDF_CT = 'I17G_CSM_ACC_STD'
delete BEST..TI17PERMFIL where IDF_CT = 'I17G_CSM_ACC_STD'
delete BEST..TI17CHN where CHAIN_CT = 'ESFD3780'
delete BEST..TI17FNC where IDF_CT = 'I17G_CSM_ACC_STD'

insert into BEST..TI17FNC values ('I17G_CSM_ACC_STD','IFRS17 - CSM/LC booking')

insert into BEST..TI17CHN values ('ESFD3780','IFRS17 - CSM/LC booking')

insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','EST_IADPERICASE_STD','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_STD.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_GTSII_CSM_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_GTSII_CSM_CASHFLOW_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_GTSII_CSM_CASHFLOW_PREV','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_GTSII_CSM_CASHFLOW_${PARM_PREV_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_GTSII_CSM','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_GTSII_IFRS17_CSM','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_CSM${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_CSM_LC_AMORT_PATTERN_PREV','${DFILP}/${ENV_PREFIX}_ESFD3770_I17G_CSM_AMR_STD_CSM_LC_AMORT_PATTERN_${PARM_PREV_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_CSM_PROF','${DFILP}/${ENV_PREFIX}_ESFD3750_I17G_CSM_ALL_STD_PROF_BY_CTR_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_FTECLEDA','${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDA_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','EST_FBOPRSLNK_TXT','${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_FSEGPROF_STD','${DFILP}/${PCH}ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_CSM_LC_FTECLEDA','${DFILP}/${ENV_PREFIX}_ESFD3780_I17G_CSM_ACC_STD_CSM_LC_FTECLEDA_${PARM_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_CSM_LC_FTECLEDA_ALL','${DFILP}/${ENV_PREFIX}_ESFD3780_I17G_CSM_ACC_STD_CSM_LC_FTECLEDA_ALL_${PARM_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_FTECLEDR','${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDR_${PARM_ICLODAT_D}.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_CSM_LC_FTECLEDR','${DFILP}/${ENV_PREFIX}_ESFD3780_I17G_CSM_ACC_STD_CSM_LC_FTECLEDR_${PARM_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','ESF_CSM_LC_FTECLEDR_ALL','${DFILP}/${ENV_PREFIX}_ESFD3780_I17G_CSM_ACC_STD_CSM_LC_FTECLEDR_ALL_${PARM_ICLODAT_D}.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_CSM_ACC_STD','EST_IRDPERICASE0','${DFILP}/${ENV_PREFIX}_ESPT0000_IRDPERICASE0.dat','I','')
 

insert into BEST..TI17REQCHN values ('I17GMINV','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GMINVB','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOS','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOSB','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOC','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GMPOCB','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GQINV','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GQINVB','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOS','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOSB','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOC','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOCB','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GYINV','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GYINVB','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOS','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOSB','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOC','ESFD3780','I17G_CSM_ACC_STD','')
insert into BEST..TI17REQCHN values ('I17GYPOCB','ESFD3780','I17G_CSM_ACC_STD','')

print '------>>>> End Antoine request : SPIRA 77471 : mapping ESFD3780 '

go
----------------------------------------------------------------



----------------------------------------------------------------------- 
print '------>>>> Lahcen SPIRA 79102 : RETRO NP EXPENSES at Inception '

--update BEST..TI17PERMFIL set PATHPATTRN_LL = '${DFILP}/${PCH}ESFD2570_DLDGTARSII${TYPEINV0}_E.dat' 
--where IDF_CT= 'I17G_IEX_ALL_INI' 
--AND PERMFIL_CT = 'EPO_DLDGTR_E'

--update BEST..TI17PERMFIL set PATHPATTRN_LL = '${DFILP}/${PCH}ESPD2570_DLDGTRSII${TYPEINV0}_E.dat' 
--where IDF_CT= 'I17G_IEX_ALL_INI' 
--AND PERMFIL_CT = 'EPO_DLDGTR_E'

update BEST..TI17PERMFIL set PATHPATTRN_LL = '${DFILP}/${PCH}ESFD2570_DLDGTRSII${TYPEINV0}_E.dat' 
where IDF_CT= 'I17G_IEX_ALL_INI' 
AND PERMFIL_CT = 'EPO_DLDGTR_E'

print '------>>>> End Lahcen SPIRA 79102 : RETRO NP EXPENSES at Inception '
go
----------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------
print '------>>>>  ESFD2550 Bouclette Future Retro P at inception  '

delete BEST..TI17PERMFIL where IDF_CT = 'I17G_FUT_RPO_INI'
delete BEST..TI17REQCHN where IDF_CT = 'I17G_FUT_RPO_INI'
delete BEST..TI17FNC where IDF_CT = 'I17G_FUT_RPO_INI'
delete BEST..TI17CHN where CHAIN_CT = 'ESFD2550'


insert into BEST..TI17FNC values ('I17G_FUT_RPO_INI','Bouclette Future RetroP Inception')

insert into BEST..TI17CHN values ('ESFD2550','Bouclette Future RetroP Inception')


delete from  BEST..TI17PERMFIL where IDF_CT = 'I17G_FUT_RPO_INI'


insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLDGTAASIICO', '${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLDGTAASIICO.dat', 	'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLDGTAASIISO', '${DFILP}/${PCH}ESFD2220_I17G_FUT_ALL_INI_DLDGTAASIISO.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLDSIIGTRCO', '${DFILP}/empty.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLDSIIGTRSO', '${DFILP}/empty.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLDVGTRCO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLDVGTRCO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLDVGTRSIICO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLDVGTRSIICO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLDVGTRSIISO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLDVGTRSIISO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLDVGTRSO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLDVGTRSO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLEIGTAA', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLEIGTAA.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTAR_OVRCO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTAR_OVRCO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTAR_OVRSIICO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTAR_OVRSIICO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTAR_OVRSIISO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTAR_OVRSIISO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTAR_OVRSO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTAR_OVRSO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTARCO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTARCO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTARSIICO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTARSIICO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTARSIISO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTARSIISO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTARSO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTARSO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTR_OVRCO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTR_OVRCO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTR_OVRSIICO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTR_OVRSIICO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTR_OVRSIISO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTR_OVRSIISO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTR_OVRSO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTR_OVRSO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTRCO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTRCO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTRSIICO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTRSIICO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTRSIISO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTRSIISO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREGTRSO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREGTRSO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREMAJGTARCO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREMAJGTARCO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREMAJGTARSIICO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREMAJGTARSIICO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREMAJGTARSIISO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREMAJGTARSIISO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREMAJGTARSO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREMAJGTARSO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREMAJGTRCO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREMAJGTRCO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREMAJGTRSIICO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREMAJGTRSIICO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREMAJGTRSIISO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREMAJGTRSIISO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLREMAJGTRSO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLREMAJGTRSO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',  'EPO_DLRGTAACO',	'${DFILP}/${ENV_PREFIX}_ESFD2550_DLRGTAACO.dat','O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',  'EPO_DLRGTAASIICO',	'${DFILP}/${ENV_PREFIX}_ESFD2550_DLRGTAASIICO.dat','O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',  'EPO_DLRGTAASIISO',	'${DFILP}/${ENV_PREFIX}_ESFD2550_DLRGTAASIISO.dat','O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',  'EPO_DLRGTAASO',	'${DFILP}/${ENV_PREFIX}_ESFD2550_DLRGTAASO.dat','O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLRIGTAACO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLRIGTAACO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLRIGTAANOS', '${DFILI}/${ENV_PREFIX}_ESFD2550_DLRIGTAANOS.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLRIGTAASIICO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLRIGTAASIICO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLRIGTAASIISO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLRIGTAASIISO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLRIGTAASO', '${DFILP}/${ENV_PREFIX}_ESFD2550_DLRIGTAASO.dat', 'O', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLSGTRCO', '${DFILP}/empty.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLSGTRSIICO', '${DFILP}/empty.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLSGTRSIISO', '${DFILP}/empty.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_DLSGTRSO', '${DFILP}/empty.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FCES', '${DFILP}/${PCH}ESPT0000_FCES.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FCURCVSN', '${DFILP}/${PCH}ESPT0000_FCURCVSN.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FCURCVSNI', '${DFILP}/${PCH}ESPT0000_FCURCVSNI.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FCURQUOT', '${DFILP}/${PCH}ESPT0000_FCURQUOT.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FDETTRS', '${DFILP}/${PCH}ESPT0000_FDETTRS.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FPLACEMT0', '${DFILP}/${PCH}ESPT0000_FPLACEMT0.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FPLC', '${DFILP}/${PCH}ESPT0000_FPLC.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FRETTRF', '${DFILP}/${PCH}ESPT0000_FRETTRF.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FSSDACTR', '${DFILP}/${PCH}ESPT0000_FSSDACTR.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FSUBTRS', '${DFILP}/${PCH}ESPT0000_FSUBTRS.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FTRANSCODE', '${DFILP}/${PCH}ESPT0000_FTRANSCODE.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FTRSLNK', '${DFILP}/${PCH}ESPT0000_FTRSLNK.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_GTEPCO', '${DFILP}/${PCH}ESPD4000_GTEPCO.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_GTEPSIICO', '${DFILP}/${PCH}ESPD4000_GTEPSIICO.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_GTEPSIISO', '${DFILP}/${PCH}ESPD4000_GTEPSIISO.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_GTEPSO', '${DFILP}/${PCH}ESPD4000_GTEPSO.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_IADVPERICASE', '${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_OIRDVPERICASE', '${DFILP}/${PCH}ESEH1100_IRDPERICASE_NP_INI.dat', 'I', '') 
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EST_DLREGTR', '${DFILP}/${PCH}ESPT0000_DLREGTR.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EST_FCURQUOT', '${DFILP}/${PCH}ESCJ0060_FCURQUOT.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FBOPRSLNK_TXT', '${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EPO_FCURQUOT_TXT', '${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EST_FBOPRSLNK_TXT', '${DFILP}/${PCH}ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EST_FCURQUOT_TXT', '${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EST_FDETTRS_TXT', '${DFILP}/${PCH}ESPT0000_FDETTRS_TXT_${PARM_ICLODAT_D}.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'EST_FTRSLNK_TXT', '${DFILP}/${PCH}ESPT0000_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat', 'I', '')
insert into  BEST..TI17PERMFIL values ('I17G_FUT_RPO_INI',	'ESF_FLORETFACTOR', '${DFILI}/${ENV_PREFIX}_ESFD0060_I17G___FLORETFACTOR.dat', 'I', '')

insert into BEST..TI17REQCHN values ('I17GMINV','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GMINVB','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GMPOS','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GMPOSB','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GMPOC','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GMPOCB','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GQINV','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GQINVB','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GQPOS','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GQPOSB','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GQPOC','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GQPOCB','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GYINV','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GYINVB','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GYPOS','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GYPOSB','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GYPOC','ESFD2550','I17G_FUT_RPO_INI','')
insert into BEST..TI17REQCHN values ('I17GYPOCB','ESFD2550','I17G_FUT_RPO_INI','')

print '------>>>>  end ESFD2550 Bouclette Future Retro P at inception '

GO
-----------------------------------------------------------------------------------------------------------

------------- [044]

delete from  BEST..TI17PERMFIL where IDF_CT = 'ESID2800' and PERMFIL_CT = 'EST_TOTGTAR'
delete from  BEST..TI17PERMFIL where IDF_CT = 'ESID2530' and PERMFIL_CT = 'EST_TOTGTAR'
delete from  BEST..TI17PERMFIL where IDF_CT = 'ESID2900' and PERMFIL_CT = 'EST_TOTGTAR'
delete from  BEST..TI17PERMFIL where IDF_CT = 'ESID2560' and PERMFIL_CT = 'EST_TOTGTAR'
delete from  BEST..TI17PERMFIL where IDF_CT = 'ESID2590' and PERMFIL_CT = 'EST_TOTGTAR'

insert into BEST..TI17PERMFIL values ('ESID2800',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2530',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2900',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2560',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2590',  'EST_TOTGTAR','${DFILI}/${ENV_PREFIX}_ESID2560_TOTGTAR_${CLODAT}.dat','I','')

GO
------------ END [044]


-----------------------------------------------------------------------------------------------------------
print '------>>>> [046][047] Lahcen request: SPIRA 79102 : mapping EXPRAT retro '

-- IDF_CT : I17G___
delete from  BEST..TI17PERMFIL where IDF_CT = 'I17G___' and PERMFIL_CT = 'ESF_RET_FEXPRAT'
insert into BEST..TI17PERMFIL(IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) values ('I17G___','ESF_RET_FEXPRAT', '${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RET_FEXPRAT_${PARM_ICLODAT_D}.dat' ,'O', '')

-- IDF_CT : I17G_IEX_ALL_STD
delete from  BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_STD' and PERMFIL_CT in ( 'ESF_RET_FEXPRAT' , 'ESF_RET_FEXPRAT_PREVQ' )

insert into BEST..TI17PERMFIL (IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) 
values ('I17G_IEX_ALL_STD', 'ESF_RET_FEXPRAT', '${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RET_FEXPRAT_${PARM_ICLODAT_D}.dat','I','' )
insert into BEST..TI17PERMFIL (IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) 
values ('I17G_IEX_ALL_STD', 'ESF_RET_FEXPRAT_PREVQ', '${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RET_FEXPRAT_${PARM_PREV_ICLODAT_D}.dat','I','' )

-- IDF_CT : I17G_IEX_ALL_INI
delete from  BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_INI' and PERMFIL_CT in ( 'ESF_RET_FEXPRAT' , 'ESF_RET_FEXPRAT_PREVQ' )

insert into BEST..TI17PERMFIL (IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) 
values ('I17G_IEX_ALL_INI', 'ESF_RET_FEXPRAT', '${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RET_FEXPRAT_${PARM_ICLODAT_D}.dat','I','' )
insert into BEST..TI17PERMFIL (IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) 
values ('I17G_IEX_ALL_INI', 'ESF_RET_FEXPRAT_PREVQ', '${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RET_FEXPRAT_${PARM_PREV_ICLODAT_D}.dat','I','' )


print '------>>>> End [046][047] Lahcen request: SPIRA 79102 : mapping EXPRAT retro '
GO
-----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------- 
print '------>>>> Antoine/Lahcen requests : SPIRA 84815 mapping ESFD3690 UPR '

delete BEST..TI17PERMFIL where IDF_CT in ('I17G_IRV_ALL_STD' ) and PERMFIL_CT='ESF_UPR' 
insert into  BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD',	'ESF_UPR',	'${DFILP}/${PCH}ESFD3690_ESFD3691_I17G_IRV_ALL_STD_UPR_${PARM_ICLODAT_D}.dat' , 'I', '') 

print '------>>>> End Antoine/Lahcen requests : SPIRA 84815 mapping ESFD3690 UPR '
go
----------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
print '------>>>>  [42212] Martin request :  add EST_FDATDERCPA ESID2000 ESID0060 ' 

delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EST_FDATDERCPA'
and IDF_CT in ('ESID2000', 'ESID0060') 

INSERT INTO BEST..TI17PERMFIL values ('ESID2000',  'EST_FDATDERCPA','${DFILP}/${PCH}ESID0060_FDATDERCPA.dat','I','')
INSERT INTO BEST..TI17PERMFIL values ('ESID0060',  'EST_FDATDERCPA','${DFILP}/${PCH}ESID0060_FDATDERCPA.dat','O','')

print '------>>>>  [42212] Martin request add EST_FDATDERCPA ESID2000 ESID0060 ' 
GO
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------
print '------>>>> Linh request : SPIRA 83103 82584 ' 




DELETE FROM BEST..TI17PERMFIL where IDF_CT='I17G_SII_ALL_STD' and PERMFIL_CT='ESF_GTSII_CASHFLOW'
go

INSERT INTO BEST..TI17PERMFIL (IDF_CT, PERMFIL_CT, PATHPATTRN_LL, IO, PERM_LL) VALUES('I17G_SII_ALL_STD', 'ESF_GTSII_CASHFLOW', '${DFILP}/${PCH}ESFD3730_I17G_SII_ALL_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'O', '')
go

delete from BEST..TI17PERMFIL where IDF_CT='ESCJ0060' and PERMFIL_CT='EST_GAAPCOD_MAPPING'
go
INSERT INTO BEST..TI17PERMFIL
(IDF_CT, PERMFIL_CT, PATHPATTRN_LL, IO, PERM_LL)
VALUES('ESCJ0060', 'EST_GAAPCOD_MAPPING', '${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat', 'O', '')
go


-------------------------------
--      Init  old ESID8310, new ESID3810
-------------------------------

delete BEST..TI17PERMFIL where IDF_CT ='ESID3810'
delete BEST..TI17REQCHN where   IDF_CT = 'ESID3810' and  CHAIN_CT='ESID3810'
delete BEST..TI17CHN  where CHAIN_CT='ESID3810'
delete BEST..TI17FNC where IDF_CT  ='ESID3810'

insert into BEST..TI17CHN values ('ESID3810',  'Gaapcod insertion')
insert into BEST..TI17FNC values ('ESID3810',  'Gaapcod insertion')

----------  Perms---------------------
-- Input
insert into BEST..TI17PERMFIL values ('ESID3810', 'EST_GAAPCOD_MAPPING', '${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat', 'I','')


--output
-- en temporaire, à changer 
insert into BEST..TI17PERMFIL values ('ESID3810', 'EST_FTECLEDA_MVT', '${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MVT.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID3810', 'EST_FTECLEDA_MTH', '${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_MTH.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID3810', 'EST_FTECLEDA_REP', '${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_REP.dat', 'O', '')
insert into BEST..TI17PERMFIL values ('ESID3810', 'EST_FTECLEDR_MVT', '${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_MVT.dat', 'O', '')


-- CHAIN ESFD3810	-- I17G_GLT_GAP_STD

delete BEST..TI17PERMFIL 	where IDF_CT = 'I17G_GLT_GAP_STD'
delete BEST..TI17REQCHN 	where IDF_CT = 'I17G_GLT_GAP_STD' and  CHAIN_CT="ESFD3810"
delete BEST..TI17FNC  		where IDF_CT =  "I17G_GLT_GAP_STD"
delete BEST..TI17CHN  		where CHAIN_CT="ESFD3810"

insert into BEST..TI17CHN values ("ESFD3810",			"GAAPCod BDA to GLT")
insert into BEST..TI17FNC values ("I17G_GLT_GAP_STD",	"GAAPCod BDA to GTL")


insert into BEST..TI17REQCHN values ('I17GMINV',	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GMINVB', 	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQINV',   	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQINVB', 	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOSB',	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOCB',	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYINV',    "ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYINVB',  	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOS',   	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', 	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOC',   	"ESFD3810","I17G_GLT_GAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', 	"ESFD3810","I17G_GLT_GAP_STD","")

insert into BEST..TI17PERMFIL values('I17G_GLT_GAP_STD', 'ESF_GAAPCOD_MAPPING', '${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_GLT_GAP_STD', 'ESF_FTECLEDA', '${DFILP}/${ENV_PREFIX}_ESFD3740_I17G_SII_GLT_STD_FTECLEDA_${PARM_ICLODAT_D}.dat', 'O', '')
insert into BEST..TI17PERMFIL values('I17G_GLT_GAP_STD', 'ESF_FTECLEDR', '${DFILP}/${ENV_PREFIX}_ESFD3740_I17G_SII_GLT_STD_FTECLEDR_${PARM_ICLODAT_D}.dat', 'O', '')


----------------------------------------------------------------------------------------------------------
--
-- CHAIN ESPD3810	-- EBS_GLT_GAP_STD
--
----------------------------------------------------------------------------------------------------------

--- old name ESFD
delete BEST..TI17PERMFIL 	where IDF_CT  in ('ESFD3810_POSE','ESFD3810_POCE', 'ESFD3810_BookingPOSE','ESFD3810_BookingPOCE','ESFD3810_BookingPOSEAnnuel' , 'ESFD3810_BookingPOCEAnnuel')
delete BEST..TI17REQCHN 	where IDF_CT  in ('ESFD3810_POSE','ESFD3810_POCE','ESFD3810_BookingPOSE','ESFD3810_BookingPOCE','ESFD3810_BookingPOSEAnnuel' , 'ESFD3810_BookingPOCEAnnuel')  and  CHAIN_CT="ESFD3810"
delete BEST..TI17FNC  		where IDF_CT  in ('ESFD3810_POSE','ESFD3810_POCE','ESFD3810_BookingPOSE','ESFD3810_BookingPOCE','ESFD3810_BookingPOSEAnnuel' , 'ESFD3810_BookingPOCEAnnuel')

--- new name ESPD 
delete BEST..TI17PERMFIL 	where IDF_CT  in ('ESPD3810_POSE','ESPD3810_POCE', 'ESPD3810_BookingPOSE','ESPD3810_BookingPOCE','ESPD3810_BookingPOSEAnnuel' , 'ESPD3810_BookingPOCEAnnuel')
delete BEST..TI17REQCHN 	where IDF_CT  in ('ESPD3810_POSE','ESPD3810_POCE','ESPD3810_BookingPOSE','ESPD3810_BookingPOCE','ESPD3810_BookingPOSEAnnuel' , 'ESPD3810_BookingPOCEAnnuel')  and  CHAIN_CT="ESPD3810"
delete BEST..TI17FNC  		where IDF_CT  in ('ESPD3810_POSE','ESPD3810_POCE','ESPD3810_BookingPOSE','ESPD3810_BookingPOCE','ESPD3810_BookingPOSEAnnuel' , 'ESPD3810_BookingPOCEAnnuel')
delete BEST..TI17CHN  		where CHAIN_CT="ESPD3810"

insert into BEST..TI17CHN values ("ESPD3810",			"GAAPCod BDA to GLT")

insert into BEST..TI17FNC values ("ESPD3810_POCE",	"GAAPCod BDA to GTL Post omega conso EBS")
insert into BEST..TI17FNC values ("ESPD3810_POSE",	"GAAPCod BDA to GTL Post omega social EBS")
insert into BEST..TI17FNC values ("ESPD3810_BookingPOCE",	"GAAPCod BDA to GTL Post omega conso EBS")
insert into BEST..TI17FNC values ("ESPD3810_BookingPOSE",	"GAAPCod BDA to GTL Post omega social EBS")
insert into BEST..TI17FNC values ("ESPD3810_BookingPOCEAnnuel",	"GAAPCod BDA to GTL Post omega conso EBS")
insert into BEST..TI17FNC values ("ESPD3810_BookingPOSEAnnuel",	"GAAPCod BDA to GTL Post omega social EBS")



INSERT INTO BEST..TI17REQCHN (REQCOD_CT,CHAIN_CT,IDF_CT,REQST_CHAIN_LL) VALUES ('POCE','ESPD3810','ESPD3810_POCE','POCE')
INSERT INTO BEST..TI17REQCHN (REQCOD_CT,CHAIN_CT,IDF_CT,REQST_CHAIN_LL) VALUES ('POSE','ESPD3810','ESPD3810_POSE','POSE')
INSERT INTO BEST..TI17REQCHN (REQCOD_CT,CHAIN_CT,IDF_CT,REQST_CHAIN_LL) VALUES ('POCE','ESPD3810','ESPD3810_BookingPOCE','POCE')
INSERT INTO BEST..TI17REQCHN (REQCOD_CT,CHAIN_CT,IDF_CT,REQST_CHAIN_LL) VALUES ('POSE','ESPD3810','ESPD3810_BookingPOSE','POSE')
INSERT INTO BEST..TI17REQCHN (REQCOD_CT,CHAIN_CT,IDF_CT,REQST_CHAIN_LL) VALUES ('POCE','ESPD3810','ESPD3810_BookingPOCEAnnuel','POCE')
INSERT INTO BEST..TI17REQCHN (REQCOD_CT,CHAIN_CT,IDF_CT,REQST_CHAIN_LL) VALUES ('POSE','ESPD3810','ESPD3810_BookingPOSEAnnuel','POSE')

-- INPUT EBS :  EPO_GAAPCOD_MAPPING
insert into BEST..TI17PERMFIL values('ESPD3810_POCE', 'EPO_GAAPCOD_MAPPING', '${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('ESPD3810_POSE', 'EPO_GAAPCOD_MAPPING', '${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCE', 'EPO_GAAPCOD_MAPPING', '${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSE', 'EPO_GAAPCOD_MAPPING', '${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCEAnnuel', 'EPO_GAAPCOD_MAPPING', '${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSEAnnuel', 'EPO_GAAPCOD_MAPPING', '${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat', 'I', '')

-- INPUT EBS :  EPO_FTECLEDA
insert into BEST..TI17PERMFIL values('ESPD3810_POSE', 'EPO_FTECLEDA', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_POCE', 'EPO_FTECLEDA', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSE', 'EPO_FTECLEDA', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCE', 'EPO_FTECLEDA', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSEAnnuel', 'EPO_FTECLEDA', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCEAnnuel', 'EPO_FTECLEDA', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat', 'O', '')

-- INPUT EBS :  EPO_FTECLEDR
insert into BEST..TI17PERMFIL values('ESPD3810_POSE', 'EPO_FTECLEDR', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_POCE', 'EPO_FTECLEDR', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSE', 'EPO_FTECLEDR', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCE', 'EPO_FTECLEDR', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSEAnnuel', 'EPO_FTECLEDR', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCEAnnuel', 'EPO_FTECLEDR', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO.dat', 'O', '')


-- EBS RA : EPO_FTECLEDASII
insert into BEST..TI17PERMFIL values('ESPD3810_POCE', 'EPO_FTECLEDASII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_POSE', 'EPO_FTECLEDASII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCE', 'EPO_FTECLEDASII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSE', 'EPO_FTECLEDASII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCEAnnuel', 'EPO_FTECLEDASII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSEAnnuel', 'EPO_FTECLEDASII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat', 'O', '')


-- EBS RA : EPO_FTECLEDRSII
insert into BEST..TI17PERMFIL values('ESPD3810_POCE', 'EPO_FTECLEDRSII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_POSE', 'EPO_FTECLEDRSII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCE', 'EPO_FTECLEDRSII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSE', 'EPO_FTECLEDRSII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOCEAnnuel', 'EPO_FTECLEDRSII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO.dat', 'O', '')
insert into BEST..TI17PERMFIL values('ESPD3810_BookingPOSEAnnuel', 'EPO_FTECLEDRSII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat', 'O', '')


print '------>>>> Linh request : SPIRA 83103 82584 ' 
go
-----------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------------------------
print '------>>>> SPIRA 84653 mapping dates : micro AOC- EBS and IFRS17'  

delete from BEST..TI17PERMFIL where IDF_CT = 'I17G___' and permfil_ct = 'ESF_FMARKET'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_INI' and permfil_ct = 'ESF_FMARKET'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_STD' and permfil_ct = 'ESF_FMARKET'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_RAD_CKI_INI' and permfil_ct = 'ESF_FMARKET'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_RAD_CKI_STD' and permfil_ct = 'ESF_FMARKET'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_RAD_CUR_STD' and permfil_ct = 'ESF_FMARKET'

delete from BEST..TI17PERMFIL where IDF_CT = 'ESPT0000' and permfil_ct = 'EPO_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD0060' and permfil_ct = 'EPO_FSEGEST_SOLVENCYCO'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD0060' and permfil_ct = 'EPO_FSEGEST_SOLVENCYSO'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3900' and permfil_ct = 'EPO_FSEGEST_SOLVENCYSO'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD0060' and permfil_ct = 'EPO_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPT0000' and permfil_ct = 'EPO_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD0060' and permfil_ct = 'EPO_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD0060' and permfil_ct = 'EPO_FULAERATCO'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD0060' and permfil_ct = 'EPO_FULAERATSO'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3900' and permfil_ct = 'EPO_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPT0000' and permfil_ct = 'EPO_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_STD' and permfil_ct = 'EPO_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_RAD_CKI_STD' and permfil_ct = 'EPO_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_RAD_CUR_STD' and permfil_ct = 'EPO_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_INI' and permfil_ct = 'ESF_EXPENSES'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_STD' and permfil_ct = 'ESF_EXPENSES'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSEAnnuel' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POCE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POSE' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_CSF_ALL_INI' and permfil_ct = 'EST_FPRSMAP'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POCE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POSE' and permfil_ct = 'EST_FSEGEST'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POCE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POSE' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_FUT_ALL_INI' and permfil_ct = 'EST_FSEGEST_SOLVENCY'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POCE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POSE' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_CSF_ALL_INI' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_INI' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_STD' and permfil_ct = 'EST_FSEGPATTERN_CSF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD3620_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD3620_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD3620_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD3620_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSEAnnuel' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POCE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POSE' and permfil_ct = 'EST_FSEGPATTERN_DSC'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSEAnnuel' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POCE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POSE' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_CSF_ALL_INI' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_INI' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IEX_ALL_STD' and permfil_ct = 'EST_FULAERAT'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSEAnnuel' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POCE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POSE' and permfil_ct = 'EST_GTSII_REMAINTOPAY_ULAEINF'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESFD2220_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOCEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_BookingPOSEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2210_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOCEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_BookingPOSEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESID2220_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOCEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_BookingPOSEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2050_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOCEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_BookingPOSEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD2570_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOCEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_BookingPOSEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3610_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOCEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_BookingPOSEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3620_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOCEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_BookingPOSEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3630_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOCEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_BookingPOSEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD3640_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOCEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_BookingPOSEAnnuel' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POCE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'ESPD8000_POSE' and permfil_ct = 'EST_IADPERICASE'
delete from BEST..TI17PERMFIL where IDF_CT = 'I17G_IRV_ALL_STD' and permfil_ct = 'EST_IADPERICASE'

insert into BEST..TI17PERMFIL values ('I17G___' , 'ESF_FMARKET' , '${DFILP}/${PCH}ESFD0060_FMARKET_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI' , 'ESF_FMARKET' , '${DFILP}/${PCH}ESFD0060_FMARKET_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD' , 'ESF_FMARKET' , '${DFILP}/${PCH}ESFD0060_FMARKET_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI' , 'ESF_FMARKET' , '${DFILP}/${PCH}ESFD0060_FMARKET_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD' , 'ESF_FMARKET' , '${DFILP}/${PCH}ESFD0060_FMARKET_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD' , 'ESF_FMARKET' , '${DFILP}/${PCH}ESFD0060_FMARKET_${PARM_ICLODAT_D}.dat' , 'I' , '')

insert into BEST..TI17PERMFIL values ('ESPT0000' , 'EPO_FPRSMAP' , '${DFILP}/${ENV_PREFIX}_ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('ESPD0060' , 'EPO_FSEGEST_SOLVENCYCO' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('ESPD0060' , 'EPO_FSEGEST_SOLVENCYSO' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('ESPD3900' , 'EPO_FSEGEST_SOLVENCYSO' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESPD0060' , 'EPO_FSEGPATTERN_CSF' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('ESPT0000' , 'EPO_FSEGPATTERN_CSF' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESPD0060' , 'EPO_FSEGPATTERN_DSC' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('ESPD0060' , 'EPO_FULAERATCO' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('ESPD0060' , 'EPO_FULAERATSO' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('ESPD3900' , 'EPO_IADPERICASE' , '${DFILP}/${ENV_PREFIX}_ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESPT0000' , 'EPO_IADPERICASE' , '${DFILP}/${ENV_PREFIX}_ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD' , 'EPO_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD' , 'EPO_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD' , 'EPO_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI' , 'ESF_EXPENSES' , '${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_EXPENSES_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD' , 'ESF_EXPENSES' , '${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_EXPENSES_${PARM_ICLODAT_D}.dat' , 'O' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI' , 'EST_FPRSMAP' , '${DFILP}/${PCH}ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE' , 'EST_FSEGEST' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('I17G_FUT_ALL_INI' , 'EST_FSEGEST_SOLVENCY' , '${DFILP}/${PCH}ESPD0060_FSEGEST_SOLVENCY${TYPEINV0}_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD' , 'EST_FSEGPATTERN_CSF' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESFD3620_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESFD3620_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE' , 'EST_FSEGPATTERN_DSC' , '${DFILP}/${PCH}ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERAT${TYPEINV0}_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERAT${TYPEINV0}_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD' , 'EST_FULAERAT' , '${DFILP}/${PCH}ESPD0060_FULAERAT${TYPEINV0}_${PARM_ICLODAT_D}.dat' , 'I' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE' , 'EST_GTSII_REMAINTOPAY_ULAE' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAE_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIICO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE' , 'EST_GTSII_REMAINTOPAY_ULAEINF' , '${DFILP}/${PCH}ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESFD2220_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOCEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_BookingPOSEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESID2220_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOCEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_BookingPOSEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2050_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOCEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_BookingPOSEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD2570_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3620_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOCEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_BookingPOSEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3630_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOCEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_BookingPOSEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD3640_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('ESPD8000_POSE' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , ' ' , '')
insert into BEST..TI17PERMFIL values ('I17G_IRV_ALL_STD' , 'EST_IADPERICASE' , '${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat' , 'I' , '')



print '------>>>> end SPIRA 84653 mapping dates : micro AOC- EBS and IFRS17'  
GO
------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------
print '------>>>> martin request : SPIRA 42212  add ESDJ7010 EST_FDATDERCPA '  
delete BEST..TI17PERMFIL where IDF_CT = 'ESDJ7010' and  permfil_ct = 'EST_FDATDERCPA'

insert into BEST..TI17PERMFIL values ('ESDJ7010' , 'EST_FDATDERCPA' , '${DFILP}/${PCH}ESID0060_FDATDERCPA.dat' , 'O' , '')

print '------>>>> End martin request : SPIRA 42212  add ESDJ7010 EST_FDATDERCPA '  
GO
------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------
print '------>>>>  Arnaud request : SPIRA 75828 82867: add chain ESFD8010 '  
 
delete BEST..TI17PERMFIL where IDF_CT = 'I17G_OMG_BOK_STD'
delete BEST..TI17REQCHN where IDF_CT = 'I17G_OMG_BOK_STD'
delete BEST..TI17FNC where IDF_CT = 'I17G_OMG_BOK_STD'
delete BEST..TI17CHN where CHAIN_CT = 'ESFD8010'

insert into BEST..TI17FNC values ('I17G_OMG_BOK_STD','IFRS 17- Booking')
insert into BEST..TI17CHN values ('ESFD8010','IFRS 17- Booking')


insert into BEST..TI17REQCHN values ('I17GYPOSB','ESFD8010','I17G_OMG_BOK_STD','')
insert into BEST..TI17REQCHN values ('I17GQPOSB','ESFD8010','I17G_OMG_BOK_STD','')

print '------>>>>  End Arnaud request : SPIRA 75828 82867: add chain ESFD8010 '  
GO
------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------
print '------>>>>  Arnaud request : SPIRA 85356 mapping ESFD3720 et ESFD8000 '  
 
delete BEST..TI17PERMFIL where IDF_CT = 'I17G_CSM_CRE_INI' and  permfil_ct = 'ESF_FRETIFRS'
delete BEST..TI17PERMFIL where IDF_CT = 'I17G_OMG_TP_STD'  and  permfil_ct = 'ESF_FRETIFRS'

insert into BEST..TI17PERMFIL values ('I17G_CSM_CRE_INI','ESF_FRETIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FRETIFRS.dat','O','')
insert into BEST..TI17PERMFIL values ('I17G_OMG_TP_STD','ESF_FRETIFRS','${DFILP}/${ENV_PREFIX}_ESFD3720_I17G_CSM_CRE_INI_FRETIFRS.dat','I','')

print '------>>>>  Arnaud request : SPIRA 85356 mapping ESFD3720 et ESFD8000 '  
GO
------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------
print '------>>>> Mariem request : SPIRA 86558 clean TI17REQCHN  '  

-- disable/enable FK and rename REQCOD_CT 
alter table dbo.TI17REQJOBPLAN drop constraint FK_REQST_REQJOBPLAN_IFRS17
go
update BEST..TI17REQJOBPLAN set REQCOD_CT = 'I17GQPOC' where REQCOD_CT = 'I17GMPOC'
update BEST..TI17REQJOBPLAN set REQCOD_CT = 'I17GQPOCB' where REQCOD_CT = 'I17GMPOCB'
update BEST..TI17REQJOBPLAN set REQCOD_CT = 'I17GQPOS' where REQCOD_CT = 'I17GMPOS'
update BEST..TI17REQJOBPLAN set REQCOD_CT = 'I17GQPOSB' where REQCOD_CT = 'I17GMPOSB'
GO
alter table dbo.TI17REQJOBPLAN   add constraint FK_REQST_REQJOBPLAN_IFRS17 foreign key (REQCOD_CT)       references TI17REQ (REQCOD_CT)
GO	


delete from BEST..TI17REQCHN
where REQCOD_CT='I17GQPOS'
and(  (CHAIN_CT = 'ESFD3650' and IDF_CT = 'I17G_RAD_CSF_INI' ) or
      (CHAIN_CT = 'ESFD3780' and IDF_CT = 'I17G_CSM_ACC_STD' ) 
   )


-- delete for other req too
delete from BEST..TI17REQCHN
where REQCOD_CT !='I17GQPOS'
and(  (CHAIN_CT = 'ESFD3650' and IDF_CT = 'I17G_RAD_CSF_INI' ) or
      (CHAIN_CT = 'ESFD3780' and IDF_CT = 'I17G_CSM_ACC_STD' ) 
   )
   
   
delete BEST..TI17REQ 
where REQCOD_CT in
(
'I17GMPOC'             ,
'I17GMPOCB'            ,
'I17GMPOS'             ,
'I17GMPOSB'            
)
   
print '------>>>> End Mariem request : SPIRA 86558 clean TI17REQCHN  '  
GO
------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------
print '------>>>> Charles request : SPIRA 86189 : EST_GTSII_CLACC_CASHFLOW  '

DELETE FROM BEST..TI17PERMFIL  where PERMFIL_CT in ('EST_GTSII_CLACC_CASHFLOW')
and IDF_CT in
(
'ESPD3610_BookingPOCE',
'ESPD3610_BookingPOCEAnnuel',
'ESPD3610_BookingPOSE',
'ESPD3610_BookingPOSEAnnuel',
'ESPD3610_POCE',
'ESPD3610_POSE'
)

insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',              'EST_GTSII_CLACC_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_CLACC_CASHFLOW${TYPEINV0}.dat' , 'O', '')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',              'EST_GTSII_CLACC_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_CLACC_CASHFLOW${TYPEINV0}.dat' , 'O', '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE',       'EST_GTSII_CLACC_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_CLACC_CASHFLOW${TYPEINV0}.dat' , 'O', '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE',       'EST_GTSII_CLACC_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_CLACC_CASHFLOW${TYPEINV0}.dat' , 'O', '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel', 'EST_GTSII_CLACC_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_CLACC_CASHFLOW${TYPEINV0}.dat' , 'O', '')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel', 'EST_GTSII_CLACC_CASHFLOW', '${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_CLACC_CASHFLOW${TYPEINV0}.dat' , 'O', '')


DELETE FROM BEST..TI17PERMFIL  where IDF_CT='I17G_CSF_ALL_INI' and PERMFIL_CT = 'EST_GTSII_CLACC_CASHFLOW'
insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_GTSII_CLACC_CASHFLOW','${DFILP}/${ENV_PREFIX}_ESFD3610_I17G_CSF_ALL_INI_GTSII_CLACC_CASHFLOW.dat','O','')

print '------>>>> End Charles request : SPIRA 86189 : EST_GTSII_CLACC_CASHFLOW  '
GO 
---------------------------------------------------------------

----------------------------------------------------------------
print '------>>>>  [86503-86536] EST_FCTRESTF - EST_FCTRESTA' 

-- Supprime ancien mapping plus valable
delete BEST..TI17PERMFIL
where PERMFIL_CT in ('EST_FCTREST','EST_FCTREST1_IFRS')

-- Supprime mapping
delete BEST..TI17PERMFIL
where PERMFIL_CT in ('EST_FCTRESTF','EST_FCTRESTF0','EST_FCTRESTA')
and IDF_CT in ('ESID0560', 'ESID2000', 'ESID8000')

insert into BEST..TI17PERMFIL values ('ESID0560', 'EST_FCTRESTF','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRESTF','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8000', 'EST_FCTRESTF','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID0560', 'EST_FCTRESTA','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID2000', 'EST_FCTRESTA','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID8000', 'EST_FCTRESTA','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTA_${ICLODAT}.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID0560', 'EST_FCTRESTF0','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF0_${ICLODAT2}.dat','O','')
insert into BEST..TI17PERMFIL values ('ESID8000', 'EST_FCTRESTF0','${DFILI}/${ENV_PREFIX}_ESID0560_FCTRESTF0_${ICLODAT}.dat','I','')

print '------>>>>  [86503-86536] End EST_FCTRESTF - EST_FCTRESTF0 - EST_FCTRESTA' 

go
----------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
print '------>>>>  [86503-86536] EPO_FCTREST' 

-- Supprime ancien mapping plus valable
delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_FCTREST_LOADCTL'

-- Supprime ancien mapping plus valable
delete BEST..TI17PERMFIL
where PERMFIL_CT = 'EPO_FCTREST'

delete BEST..TI17PERMFIL
where PERMFIL_CT in ('EPO_FCTRESTA','EPO_FCTRESTF','EPO_FCTRESTF0','EPO_FCTREST0')
and IDF_CT in ('ESPD8000_POSE', 'ESPD8000_POCE', 'ESPD8000_BookingPOSE', 'ESPD8000_BookingPOCE', 'ESPD8000_BookingPOSEAnnuel', 'ESPD8000_BookingPOCEAnnuel',
               'ESID2210_POSE', 'ESID2210_POCE', 'ESID2210_BookingPOSE', 'ESID2210_BookingPOCE', 'ESID2210_BookingPOSEAnnuel', 'ESID2210_BookingPOCEAnnuel','ESPD0060')

insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIISO.dat','O','')
insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIISO.dat','O','')
insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIISO.dat','O','')
insert into BEST..TI17PERMFIL values ('ESPD0060',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIISO.dat','O','')

insert into BEST..TI17PERMFIL values ('ESPD8000_POSE',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel',  'EPO_FCTRESTA','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTASIICO.dat','I','')

insert into BEST..TI17PERMFIL values ('ESPD8000_POSE',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel',  'EPO_FCTRESTF','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTFSIICO.dat','I','')

insert into BEST..TI17PERMFIL values ('ESPD8000_POSE',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel',  'EPO_FCTRESTF0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTRESTF0SIICO.dat','I','')

insert into BEST..TI17PERMFIL values ('ESPD8000_POSE',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_POCE',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSE',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCE',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOSEAnnuel',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD8000_BookingPOCEAnnuel',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_POSE',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_POCE',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSE',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCE',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIICO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOSEAnnuel',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIISO.dat','I','')
insert into BEST..TI17PERMFIL values ('ESID2210_BookingPOCEAnnuel',  'EPO_FCTREST0','${DFILP}/${ENV_PREFIX}_ESPD0060_FCTREST0SIICO.dat','I','')

print '------>>>>  [86503-86536] End EPO_FCTREST' 
go

----------------------------------------------------------------
print '------>>>> Linh request : SPIRA 85506  : update mapping I17G ' 

----------------------------------------------------------------------------------------------------------
--
-- CHAIN ESFD3830	-- I17G_SII_MRG_INI
--
----------------------------------------------------------------------------------------------------------

delete BEST..TI17PERMFIL where IDF_CT = 'I17G_SII_MRG_INI'
delete BEST..TI17REQCHN where   IDF_CT = 'I17G_SII_MRG_INI' and  CHAIN_CT="ESFD3830"
delete BEST..TI17CHN  where CHAIN_CT="ESFD3830"
delete BEST..TI17FNC  where IDF_CT =  "I17G_SII_MRG_INI"

insert into BEST..TI17CHN values ("ESFD3830","Merge cashflow and discount at inception")
insert into BEST..TI17FNC values ("I17G_SII_MRG_INI","Merge cashflow and discount at inception")

insert into BEST..TI17REQCHN values ('I17GMINV',   "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GMINVB', "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GMPOS',  "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GMPOSB',"ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GMPOC',  "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GMPOCB',"ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GQINV',   "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GQINVB', "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOSB',"ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOCB',"ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GYINV',    "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GYINVB',  "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOS',   "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOC',   "ESFD3830","I17G_SII_MRG_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', "ESFD3830","I17G_SII_MRG_INI","")

-- OUTPUT

insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_CASHFLOW', 				'${DFILP}/${PCH}ESFD3830_I17G_SII_MRG_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'O', '')

-- INPUT
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_GLOBAL_CASHFLOW', 		'${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat', 'I', '')

insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_ESCOMPTE_DSI', 			'${DFILP}/empty.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_ESCOMPTE_LKI', 			'${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_CASHFLOW_RAD_CUR', 		'${DFILP}/empty.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_CASHFLOW_RAD_CKI', 		'${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_INI_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_ESCOMPTE_RAD_LKI', 		'${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_ESCOMPTE_RAD_DSI', 		'${DFILP}/empty.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_ESCOMPTE_FWD', 			'${DFILP}/empty.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_ESCOMPTE_UWD', 			'${DFILP}/empty.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_IFRS17_REVENUE', 		'${DFILP}/empty.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_IFRS17_CSM', 			'${DFILP}/empty.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_CSM_CASHFLOW', 			'${DFILP}/empty.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_CLACC_CASHFLOW', 	'${DFILP}/${PCH}ESFD3610_I17G_CSF_ALL_INI_GTSII_CLACC_CASHFLOW.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_REMAINTOPAY_ULAE', 	'${DFILP}/${PCH}ESFD3610_I17G_CSF_ALL_INI_GTSII_RMTP_ULAE_SII${TYPEINV}.dat', 'I', '')

insert into BEST..TI17PERMFIL values('I17G_SII_MRG_INI', 'ESF_GTSII_IFRS17_CSM_ESCOMPTE', 	'${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat', 'I', '')





----------------------------------------------------------------------------------------------------------
--
-- CHAIN ESFD3830	-- I17G_SII_MRG_STD
--
----------------------------------------------------------------------------------------------------------

delete BEST..TI17PERMFIL where IDF_CT = 'I17G_SII_MRG_STD'
delete BEST..TI17REQCHN where   IDF_CT = 'I17G_SII_MRG_STD' and  CHAIN_CT="ESFD3830"
delete BEST..TI17CHN  where CHAIN_CT="ESFD3830"
delete BEST..TI17FNC  where IDF_CT =  "I17G_SII_MRG_STD"

insert into BEST..TI17CHN values ("ESFD3830","Merge cashflow and discount at standard")
insert into BEST..TI17FNC values ("I17G_SII_MRG_STD","Merge cashflow and discount at standard")

insert into BEST..TI17REQCHN values ('I17GMINV',   "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GMINVB', "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOS',  "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOSB',"ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOC',  "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOCB',"ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQINV',   "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQINVB', "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOSB',"ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOCB',"ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYINV',    "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYINVB',  "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOS',   "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOC',   "ESFD3830","I17G_SII_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', "ESFD3830","I17G_SII_MRG_STD","")


-- STD

-- OUTPUT

insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_CASHFLOW', 				'${DFILP}/${PCH}ESFD3830_I17G_SII_MRG_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'O', '')

--common

insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_CASHFLOW_RAD_CKI', 		'${DFILP}/${PCH}ESFD3650_I17G_RAD_CKI_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_ESCOMPTE_LKI', 			'${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_ESCOMPTE_RAD_LKI', 		'${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_GLOBAL_CASHFLOW', 		'${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_IFRS17_CSM_ESCOMPTE', 	'${DFILP}/empty.dat', 'I', '')

-- spécifique STD
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_CSM_CASHFLOW', 			'${DFILP}/${PCH}ESFD3750_I17G_CSM_ALL_STD_GTSII_CSM_CASHFLOW_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_IFRS17_CSM', 			'${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_CSM${TYPEINV0}_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_ESCOMPTE_RAD_DSI', 	'${DFILP}/${PCH}ESFD3620_I17G_RAD_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_CASHFLOW_RAD_CUR', 	'${DFILP}/${PCH}ESFD3650_I17G_RAD_CUR_STD_GTSII_CASHFLOW_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_ESCOMPTE_DSI', 		'${DFILP}/${PCH}ESFD3620_I17G_DSC_DSI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_ESCOMPTE_FWD', 		'${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_ESCOMPTE_FWD_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_ESCOMPTE_UWD', 		'${DFILP}/${PCH}ESFD3660_I17G_UWD_ALL_STD_GTSII_UNWIND_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_IFRS17_REVENUE', 		'${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_REVENUE${TYPEINV0}_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_CLACC_CASHFLOW', 	'${DFILP}/empty.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_MRG_STD', 'ESF_GTSII_REMAINTOPAY_ULAE', 	'${DFILP}/empty.dat', 'I', '')


----------------------------------------------------------------------------------------------------------
--
-- CHAIN ESFD3730	-- I17G_SII_ALL_STD
--
----------------------------------------------------------------------------------------------------------

delete BEST..TI17PERMFIL where IDF_CT = 'I17G_SII_ALL_STD'
delete BEST..TI17REQCHN where   IDF_CT = 'I17G_SII_ALL_STD' and  CHAIN_CT="ESFD3730"
delete BEST..TI17CHN  where CHAIN_CT="ESFD3730"
delete BEST..TI17FNC  where IDF_CT =  "I17G_SII_ALL_STD"

insert into BEST..TI17CHN values ("ESFD3730","Generation of FTECLEDSII")
insert into BEST..TI17FNC values ("I17G_SII_ALL_STD","Generation of FTECLEDSII")

insert into BEST..TI17REQCHN values ('I17GMINV',   "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GMINVB', "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOS',  "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOSB',"ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOC',  "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOCB',"ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GQINV',   "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GQINVB', "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOSB',"ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOCB',"ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GYINV',    "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GYINVB',  "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOS',   "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOC',   "ESFD3730","I17G_SII_ALL_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', "ESFD3730","I17G_SII_ALL_STD","")

-- STD

-- OUTPUT

insert into BEST..TI17PERMFIL values('I17G_SII_ALL_STD', 'ESF_FTECLEDSII', '${DFILP}/${PCH}ESFD3730_I17G_SII_ALL_STD_FTECLEDSII_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'O', '')

-- INPUT
insert into BEST..TI17PERMFIL values('I17G_SII_ALL_STD', 'ESF_GTSII_ALL_INI',		'${DFILP}/${PCH}ESFD3820_I17G_SII_IOR_INI_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_ALL_STD', 'ESF_GTSII_ALL_STD',		'${DFILP}/${PCH}ESFD3820_I17G_SII_IOR_STD_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_ALL_STD', 'ESF_GTSII_CASHFLOW_INI',		'${DFILP}/${PCH}ESFD3830_I17G_SII_MRG_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_ALL_STD', 'ESF_GTSII_CASHFLOW_STD',		'${DFILP}/${PCH}ESFD3830_I17G_SII_MRG_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'I', '')

-- OLD

insert into BEST..TI17PERMFIL values('I17G_SII_ALL_STD', 'EST_IADPERICASE_DUMMY', '${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_DUMMY.dat', 'I', '')

----------------------------------------------------------------------------------------------------------
--
-- CHAIN ESFD3740	-- I17G_SII_GLT_STD
--
----------------------------------------------------------------------------------------------------------

delete BEST..TI17PERMFIL 	where IDF_CT = 'I17G_SII_GLT_STD'
delete BEST..TI17REQCHN 	where IDF_CT = 'I17G_SII_GLT_STD' and  CHAIN_CT="ESFD3740"
delete BEST..TI17CHN  		where CHAIN_CT="ESFD3740"
delete BEST..TI17FNC  		where IDF_CT =  "I17G_SII_GLT_STD"

insert into BEST..TI17CHN values ("ESFD3740",			"Generation of FTECLEDSII")
insert into BEST..TI17FNC values ("I17G_SII_GLT_STD",	"Generation of FTECLEDSII")

insert into BEST..TI17REQCHN values ('I17GMINV',	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GMINVB', 	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOS',  	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOSB',	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOC',  	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GMPOCB',	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GQINV',   	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GQINVB', 	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOSB',	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOCB',	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GYINV',    "ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GYINVB',  	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOS',   	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', 	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOC',   	"ESFD3740","I17G_SII_GLT_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', 	"ESFD3740","I17G_SII_GLT_STD","")


-- STD

-- OUTPUT
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_GTSII_MAINT_EXPENSES_PAID', '${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_MAINTENANCE_EXPENSES_PAID_${PARM_ICLODAT_D}.dat', 'O', '')
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_FTECLEDA', '${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDA_${PARM_ICLODAT_D}.dat', 'O', '')
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_FTECLEDR', '${DFILP}/${PCH}ESFD3740_I17G_SII_GLT_STD_FTECLEDR_${PARM_ICLODAT_D}.dat', 'O', '')

-- INPUT
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_GTSII_ALL_INI',		'${DFILP}/${PCH}ESFD3820_I17G_SII_IOR_INI_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_GTSII_ALL_STD',		'${DFILP}/${PCH}ESFD3820_I17G_SII_IOR_STD_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_GTSII_CASHFLOW_INI',		'${DFILP}/${PCH}ESFD3830_I17G_SII_MRG_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_GTSII_CASHFLOW_STD',		'${DFILP}/${PCH}ESFD3830_I17G_SII_MRG_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat', 'I', '')

-- OLD

insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_FSECIFRS', '${DFILP}/${PCH}ESFD3720_I17G_CSM_CRE_INI_FSECIFRS.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_IADPERICASE_INI', '${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'EST_IADPERICASE_DUMMY', '${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_DUMMY.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_SII_GLT_STD', 'ESF_GTSII_GLOBAL_CASHFLOW_PREV', '${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_STD_GTSII_GLOBAL_CASHFLOW_${PARM_PREV_ICLODAT_D}.dat', 'I', '')


print '------>>>> End : Linh request : SPIRA 85506  : update mapping I17G ' 
go
----------------------------------------------------------------


----------------------------------------------------------------
print '------>>>> Charles request: SPIRA 86189 82584 : add ESFD3820 ' 

---------------------
--                   
-- CHAIN ESFD3820    
--                   
---------------------

delete BEST..TI17PERMFIL where IDF_CT = 'I17G_SII_IOR_INI'
delete BEST..TI17REQCHN where   IDF_CT = 'I17G_SII_IOR_INI' and  CHAIN_CT="ESFD3820"
delete BEST..TI17FNC where IDF_CT  =  "I17G_SII_IOR_INI" 
delete BEST..TI17CHN  where CHAIN_CT="ESFD3820"

insert into BEST..TI17CHN values ("ESFD3820","IO management in cashflow and discount calculation")
insert into BEST..TI17FNC values ("I17G_SII_IOR_INI","IO management in cashflow and discount calculation")


insert into BEST..TI17REQCHN values ('I17GMINV',  "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GMINVB', "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GQINV',  "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GQINVB', "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOSB', "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOCB', "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GYINV',  "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GYINVB', "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOS',  "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOC',  "ESFD3820","I17G_SII_IOR_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', "ESFD3820","I17G_SII_IOR_INI","")
 

insert into TI17PERMFIL values('I17G_SII_IOR_INI','ESF_FTECLEDSII','${DFILP}/${PCH}ESFD3830_I17G_SII_MRG_INI_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_INI','EST_FPLC','${DFILP}/${PCH}ESPT0000_FPLC.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_INI','EST_FSSDACTR','${DFILP}/${PCH}ESPT0000_FSSDACTR.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_INI','EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_INI','EST_DLEIFTECLEDSIIEP','${DFILP}/${PCH}ESPD4000_DLEIFTECLEDSIIEP${TYPEINV0}.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_INI','EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat','I','')

insert into TI17PERMFIL values('I17G_SII_IOR_INI','ESF_FTECLEDSII_IFRS17','${DFILP}/${PCH}ESFD3820_I17G_SII_IOR_INI_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')

delete BEST..TI17PERMFIL where IDF_CT = 'I17G_SII_IOR_STD'
delete BEST..TI17REQCHN where   IDF_CT = 'I17G_SII_IOR_STD' and  CHAIN_CT="ESFD3820"
delete BEST..TI17FNC where IDF_CT  =  "I17G_SII_IOR_STD" 

insert into BEST..TI17FNC values ("I17G_SII_IOR_STD","IO management in cashflow and discount calculation")

insert into BEST..TI17REQCHN values ('I17GMINV',  "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GMINVB', "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GQINV',  "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GQINVB', "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOSB', "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOCB', "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GYINV',  "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GYINVB', "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOS',  "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOC',  "ESFD3820","I17G_SII_IOR_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', "ESFD3820","I17G_SII_IOR_STD","")
 

insert into TI17PERMFIL values('I17G_SII_IOR_STD','ESF_FTECLEDSII','${DFILP}/${PCH}ESFD3830_I17G_SII_MRG_STD_GTSII_CASHFLOW_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_STD','EST_FPLC','${DFILP}/${PCH}ESPT0000_FPLC.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_STD','EST_FSSDACTR','${DFILP}/${PCH}ESPT0000_FSSDACTR.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_STD','EST_FDETTRS','${DFILP}/${PCH}ESPT0000_FDETTRS.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_STD','EST_DLEIFTECLEDSIIEP','${DFILP}/${PCH}ESPD4000_DLEIFTECLEDSIIEP${TYPEINV0}.dat','I','')
insert into TI17PERMFIL values('I17G_SII_IOR_STD','EST_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat','I','')

insert into TI17PERMFIL values('I17G_SII_IOR_STD','ESF_FTECLEDSII_IFRS17','${DFILP}/${PCH}ESFD3820_I17G_SII_IOR_STD_GTSII_ALL_${TYPEINV}_${PARM_ICLODAT_D}.dat','O','')


print '------>>>> End Charles request: SPIRA 86189 82584 : add ESFD3820 ' 
go
----------------------------------------------------------------



----------------------------------------------------------------
print '------>>>> Charles request: SPIRA 83206 new EST_IADPERICASE_STD for ESTC1056A ' 
go

delete BEST..TI17PERMFIL where PERMFIL_CT= 'EST_IADPERICASE_STD'
and IDF_CT in  ('I17G_CSF_ALL_INI',
                'I17G_IEX_ALL_INI',
                'I17G_IEX_ALL_STD',
                'I17G_RAD_CUR_STD',
                'I17G_RAD_CKI_INI',
                'I17G_RAD_CKI_STD',			
                'ESPD3610_POSE',            
                'ESPD3610_POCE',            
                'ESPD3610_BookingPOSE',     
                'ESPD3610_BookingPOCE',     
                'ESPD3610_BookingPOSEAnnuel',
                'ESPD3610_BookingPOCEAnnuel',
                'ESPD3620_POSE',            
                'ESPD3620_POCE',            
                'ESPD3620_BookingPOSE',     
                'ESPD3620_BookingPOCE',     
                'ESPD3620_BookingPOSEAnnuel',
                'ESPD3620_BookingPOCEAnnuel' )


insert into BEST..TI17PERMFIL values ('I17G_CSF_ALL_INI',  'EST_IADPERICASE_STD','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_INI',  'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_IEX_ALL_STD',  'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CUR_STD',  'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_INI',  'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('I17G_RAD_CKI_STD',  'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')


insert into BEST..TI17PERMFIL values ('ESPD3610_POSE',             'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3610_POCE',             'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSE',      'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCE',      'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOSEAnnuel','EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3610_BookingPOCEAnnuel','EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')


insert into BEST..TI17PERMFIL values ('ESPD3620_POSE',             'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3620_POCE',             'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSE',      'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCE',      'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOSEAnnuel','EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
insert into BEST..TI17PERMFIL values ('ESPD3620_BookingPOCEAnnuel','EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')

go

delete BEST..TI17PERMFIL where IDF_CT ="ESPP3620_POSE"  AND PERMFIL_CT= 'EST_IADPERICASE_STD'
insert into BEST..TI17PERMFIL values ('ESPP3620_POSE',  'EST_IADPERICASE_STD','${DFILP}/empty.dat','I','')
print '------>>>> End Charles request: SPIRA 83206 new EST_IADPERICASE_STD for ESTC1056A ' 
go
----------------------------------------------------------------


----------------------------------------------------------------
print '------>>>> Start Linh request: SPIRA 85741 add ESFD3840 ESFD3850 ' 
go

--CHAIN ESFD3840	-- I17G_GLT_MRG_STD -- Merge GLT Movement EBS and IFRS17
delete BEST..TI17PERMFIL 	where IDF_CT = 'I17G_GLT_MRG_STD'
delete BEST..TI17REQCHN 	where IDF_CT = 'I17G_GLT_MRG_STD' and  CHAIN_CT="ESFD3840"
delete BEST..TI17CHN  		where CHAIN_CT="ESFD3840"
delete BEST..TI17FNC  		where IDF_CT =  "I17G_GLT_MRG_STD"

insert into BEST..TI17CHN values ("ESFD3840",			"Merge GLT Movement EBS and IFRS17")
insert into BEST..TI17FNC values ("I17G_GLT_MRG_STD",	"Merge GLT Movement EBS and IFRS17")

insert into BEST..TI17REQCHN values ('I17GMINV',	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GMINVB', 	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQINV',   	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQINVB', 	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOSB',	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOCB',	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYINV',    "ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYINVB',  	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOS',   	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', 	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOC',   	"ESFD3840","I17G_GLT_MRG_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', 	"ESFD3840","I17G_GLT_MRG_STD","")


-- OUTPUT IFRS17

insert into BEST..TI17PERMFIL values('I17G_GLT_MRG_STD', 'ESF_FTECLEDA_MVT', '${DFILP}/${ENV_PREFIX}_ESFD3840_I17G_GLT_MRG_STD_FTECLEDA_MVT_${PARM_ICLODAT_D}.dat', 'O', '')
insert into BEST..TI17PERMFIL values('I17G_GLT_MRG_STD', 'ESF_FTECLEDR_MVT', '${DFILP}/${ENV_PREFIX}_ESFD3840_I17G_GLT_MRG_STD_FTECLEDR_MVT_${PARM_ICLODAT_D}.dat', 'O', '')

-- INPUT IFRS17

insert into BEST..TI17PERMFIL values('I17G_GLT_MRG_STD', 'ESF_FTRSLNK_TXT', '${DFILP}/${ENV_PREFIX}_ESCJ0060_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat', 'I', '')

insert into BEST..TI17PERMFIL values('I17G_GLT_MRG_STD', 'ESF_FTECLEDA', '${DFILP}/${ENV_PREFIX}_ESFD3740_I17G_SII_GLT_STD_FTECLEDA_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_GLT_MRG_STD', 'ESF_FTECLEDR', '${DFILP}/${ENV_PREFIX}_ESFD3740_I17G_SII_GLT_STD_FTECLEDR_${PARM_ICLODAT_D}.dat', 'I', '')
-- input  EBS
insert into BEST..TI17PERMFIL values('I17G_GLT_MRG_STD', 'EPO_FTECLEDASII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASII${TYPEINV0}.dat', 'I', '')
-- input  EBS
insert into BEST..TI17PERMFIL values('I17G_GLT_MRG_STD', 'EPO_FTECLEDRSII', '${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSII${TYPEINV0}.dat', 'I', '')


-- CHAIN ESFD3850	-- I17G_OMG_SAP_STD --Merge GLT Movement EBS and IFRS17

delete BEST..TI17PERMFIL 	where IDF_CT = 'I17G_OMG_SAP_STD'
delete BEST..TI17REQCHN 	where IDF_CT = 'I17G_OMG_SAP_STD' and  CHAIN_CT="ESFD3850"
delete BEST..TI17CHN  		where CHAIN_CT="ESFD3850"
delete BEST..TI17FNC  		where IDF_CT =  "I17G_OMG_SAP_STD"

insert into BEST..TI17CHN values ("ESFD3850",			"Send GLT Movement EBS and IFRS17 to SAP")
insert into BEST..TI17FNC values ("I17G_OMG_SAP_STD",	"Send GLT Movement EBS and IFRS17 to SAP")

insert into BEST..TI17REQCHN values ('I17GMINV',	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GMINVB', 	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQINV',   	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQINVB', 	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOSB',	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GQPOCB',	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYINV',    "ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYINVB',  	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOS',   	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', 	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOC',   	"ESFD3850","I17G_OMG_SAP_STD","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', 	"ESFD3850","I17G_OMG_SAP_STD","")

-- input 

insert into BEST..TI17PERMFIL values('I17G_OMG_SAP_STD', 'ESF_FTECLEDA_MVT', '${DFILP}/${ENV_PREFIX}_ESFD3840_I17G_GLT_MRG_STD_FTECLEDA_MVT_${PARM_ICLODAT_D}.dat', 'I', '')
insert into BEST..TI17PERMFIL values('I17G_OMG_SAP_STD', 'ESF_FTECLEDR_MVT', '${DFILP}/${ENV_PREFIX}_ESFD3840_I17G_GLT_MRG_STD_FTECLEDR_MVT_${PARM_ICLODAT_D}.dat', 'I', '')


print '------>>>> End Linh request: SPIRA 85741 add ESFD3840 ESFD3850 ' 
go
----------------------------------------------------------------





