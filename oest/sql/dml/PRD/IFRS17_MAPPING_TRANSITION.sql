USE BEST
go

----------------------------------------------------------------------------------------------------------
-- [001] 05/05/2020 LEL : SPIRA 86487/86487/84496  : Set up new chain ESFT0000
-- [002] 12/05/2020 JYP : SPIRA 82719: RA files for transition
-- [003] 14/05/2020 JYP : SPIRA 82719: add ICR patterne file
-- [004] 19/05/2020 JYP : SPIRA 82719: add RARAT and CTRGRO file for transition
-- [005] 26/05/2020 JYP : SPIRA 82719: bugfix pattern file ICR
-- [006] 27/05/2020 JYP : SPIRA 82719: bugfix mapping ESFT0000
-- [007] 29/05/2020 LEL : SPIRA 82720: comment ESF_FSEGPATTERN_ICR ( not used )
-- [008] 04/06/2020 LEL : SPIRA 82718: Set up RETRO NP Chain ESFD2570
-- [008] 05/06/2020 LEL : SPIRA 82718: Set up RETRO P Chain ESFD2550
-- [009] 15/06/2020 LEL : SPIRA 82714: prepare DSC/LKI files
-- [010] 18/06/2020 LEL : SPIRA 84240: SSET UP CSF preparation
-- [011] 05/10/2020 LEL/JYP : SPIRA 84240: new file transition dat
-- [012] 05/10/2020 LEL/JYP : SPIRA 84240: new version with all transition mapping
-- [013] 20/10/2020 LEL/JYP : SPIRA 86487: new mapping for transition
-- [014] 21/10/2020 LEL : SPIRA 84240: transition cashflow
-- [015] 28/10/2020 JYP : SPIRA 83609 : microAOC, DSC now with date
-- [016] 16/11/2020 LEL : SPIRA 85404 : Initialisation mapping transition
-- [017] 18/11/2020 AGD : SPIRA 84457 : Set up mapping for transition of ESFD3720 and ESFD3750
-- [018] 23/11/2020 ART : SPIRA 84457 : Set up mapping for transition of ESFT0010 and ESFT0020
-- [019] 15/12/2020 LEL : SPIRA 90446 ADD new input files chain ESFD3690
-- [020] 21/12/2020 NLD : SPIRA 91536 : Pericase INI, Parent/Local 
-- [021] 08/01/2021 LEL : SPIRA 92596 : INPUT FILES NOT USED : EPO_DLDGTR_E & EPO_DLDGTAA
-- [022] 18/01/2021	CAS : SPIRA 91843 : Transition : Run Off Contracts
-- [023] 29/01/2021	CAS : SPIRA 91843 : Transition : Run Off Contracts
-- [024] 29/01/2021 LEL : SPIRA 92596 : use new RateIndex file INI+STD
-- [025] 18/01/2021	CAS : SPIRA 91843 : Transition : Run Off Contracts
-- [026] 03/01/2021 LEL : SPIRA 93580 : CLEAN SOME INPUT FILES ESFD3690
-- [027] 19/02/2021 CS  : SPIRA 93576 : CLEAN ESFT0020

----------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFT0000  : I17G_TRN_ALL_INI                                          --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>>  ESFT0000 I17G_TRN_ALL_INI' 

delete 	BEST..TI17TRAPERMFIL where IDF_CT = 'I17G_TRN_ALL_INI'
delete  BEST..TI17REQCHN where IDF_CT = 'I17G_TRN_ALL_INI'
delete  BEST..TI17CHN  where CHAIN_CT="ESFT0000"

insert into BEST..TI17CHN values ("ESFT0000","Data TRANSITION extraction")

delete  BEST..TI17FNC  where IDF_CT in ( 'I17G_TRN_ALL_INI'  )
insert into BEST..TI17FNC values ("I17G_TRN_ALL_INI","Get data IFRS 17 GROUP")

insert into BEST..TI17REQCHN values ('I17GMINV',  "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GMINVB', "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GQINV',  "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GQINVB', "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOSB', "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GQPOCB', "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GYINV',  "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GYINVB', "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOS',  "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOC',  "ESFT0000","I17G_TRN_ALL_INI","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', "ESFT0000","I17G_TRN_ALL_INI","")

DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_TRN_ALL_INI')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','TRANSITION_DATA','${DFILP}/${PCH}ESFT0020_I17G_OMG_ALL_TRA_TRANSITION_FILE.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FSEGPATTERN_CSF_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FSEGPATTERN_ICR_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_ICR_${PARM_ICLODAT_D}.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_IRDPERICASE0_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','EPO_IRDPERICASE0','${DFILP}/${PCH}ESEH1100_IRDPERICASE_I17G_NP_INI_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','EPO_IRDPERICASE0_EBS','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','EPO_IADPERICASE','${DFILP}/${PCH}ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FMARKET_STD','${DFILP}/${PCH}ESFD0060_FMARKET_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FCTRGRO_STD','${DFILP}/${PCH}ESPT0000_FCTRGRO.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FRERETFACCTR_INI','${DFILP}/${PCH}ESFD1130_TRERETFACCTR_${NORME_CF}_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FMARKET_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FMARKET_${PARM_ICLODAT_D}.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FRARAT_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_RARAT_${param_Context_id}_${PARM_ICLODAT_D}.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FCTRGRO_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FCTRGRO.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FCTRGRO_SEGNF_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FCTRGRO_SEGNF.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FRERETFACCTR_INI_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FSEGEST_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FSEGEST_TRN_${PARM_ICLODAT_D}.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_IADVPERICASE_P','${DFILP}/${PCH}ESEH1100_IADVPERICASE_P_INI.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_IRDPERICASE0_P_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IADVPERICASE_P_TRN.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_IADPERICASE_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${PARM_ICLODAT_D}.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_IRDPERICASE0_PNP_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE0_PNP.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','ESF_FUWRETSEC_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FUWRETSEC.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_TRN_ALL_INI','PARM_IS_TRN','YES','','')
 
print '------>>>> End ESFT0000  ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFD3630 : I17G_IEX_ALL_INI                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>> Lahcen request : 82720 : ESFD3630 I17G_IEX_ALL_INI ' 

DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_IEX_ALL_INI')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','EPO_IADPERICASE','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','EPO_IRDPERICASE0','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','ESF_FMARKET','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FMARKET_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','EST_FSEGPATTERN_CSF','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','ESF_GTESTCUMUL_ACCRET','${DFILI}/${ENV_PREFIX}_ESFD3671_${IDF_CT}_GTESTCUMUL_ACCRET_TRN.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','EPO_IADPERICASE_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','ESF_GTESTCUMUL_RET','${DFILI}/${ENV_PREFIX}_ESFD3672_${IDF_CT}_GTESTCUMUL_RET_TRN.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','EPO_IRDPERICASE0_TRN','${DFILP}/${ENV_PREFIX}_ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','PARM_IS_TRN','YES','','')
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','EST_IADPERICASE_STD','${DFILP}/empty.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IEX_ALL_INI','EST_CSF_NDIC_AMOUNT','${DFILP}/empty.dat','I','')

print '------>>>> End Lahcen request : 82720 : ESFD3630 I17G_IEX_ALL_INI ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFD3650 : I17G_RAD_CKI_INI                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>> ESFD3650 : I17G_RAD_CKI_INI  ' 

DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_RAD_CKI_INI')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_CKI_INI','EPO_FCTRGRO','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FCTRGRO.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_CKI_INI','ESF_FMARKET','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FMARKET_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_CKI_INI','ESF_FUWRETSEC','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FUWRETSEC.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_CKI_INI','EPO_IADPERICASE','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_CKI_INI','EPO_FSEGPATTERN_ICR','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_ICR_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_CKI_INI','ESF_FRARAT','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_RARAT_${param_Context_id}_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_CKI_INI','ESF_IADVPERICASE_P','${DFILP}/empty.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_CKI_INI','ESF_IRDPERICASE_NP','${DFILP}/empty.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_CKI_INI','EPO_IRDPERICASE0','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE0_PNP.dat','I','')
 
print '------>>>> End ESFD3650 : I17G_RAD_CKI_INI  ' 
GO

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFD2550 : I17G_FUT_RPO_INI                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>> Transition CHAIN ESFD2550 : I17G_FUT_RPO_INI   ' 
go
DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_FUT_RPO_INI')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_FUT_RPO_INI','EPO_IADVPERICASE','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${PARM_ICLODAT_D}.dat','I','') 

print '------>>>> End Transition CHAIN ESFD2550 : I17G_FUT_RPO_INI   ' 
GO

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFD2570 : I17G_FUT_RNP_INI                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>>  START ESFD2570 SET UP  ' 

DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_FUT_RNP_INI')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_FUT_RNP_INI','EPO_IRDPERICASE0','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP.dat','I','') 

print '------>>>> End ESFD2570 : I17G_FUT_RNP_INI  ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFD2220 : I17G_FUT_ALL_INI                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>> 82718 : JYP : ESFD2220 FUTURES Assumed Transition  ' 
DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_FUT_ALL_INI')

INSERT INTO BEST..TI17TRAPERMFIL (IDF_CT,PERMFIL_CT,PATHPATTRN_LL,IO,PERM_LL) VALUES ('I17G_FUT_ALL_INI', 'EST_FSEGEST_SOLVENCY', '${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FSEGEST_TRN_${PARM_ICLODAT_D}.dat','I','' )
INSERT INTO BEST..TI17TRAPERMFIL ( IDF_CT, PERMFIL_CT, PATHPATTRN_LL, IO, PERM_LL ) VALUES ( 'I17G_FUT_ALL_INI', 'EST_IADPERICASE', '${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${PARM_ICLODAT_D}.dat', 'I', ' ' )
INSERT INTO BEST..TI17TRAPERMFIL ( IDF_CT, PERMFIL_CT, PATHPATTRN_LL, IO, PERM_LL ) VALUES ( 'I17G_FUT_ALL_INI', 'EST_FCTRGRO', '${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FCTRGRO.dat', 'I', ' ' )

print '------>>>> End 82718 : JYP : ESFD2220 FUTURES Assumed Transition  ' 
GO

----------------------------------------------------------------------------------------------------------
--																										--
-- 					CHAIN ESFD3620 : I17G_DSC_LKI_INI, I17G_RAD_LKI_INI                                 --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>>  START ESFD3620 SET UP  ' 

DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_DSC_LKI_INI', 'I17G_RAD_LKI_INI')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_DSC_LKI_INI','EPO_FCURSII','${DFILP}/${PCH}ESPT0000_FCURSII.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_DSC_LKI_INI','ESF_FPRSMAP_TXT','${DFILP}/${PCH}ESFD0060_I17G____FPRSMAP_TXT_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_DSC_LKI_INI','ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_DSC_LKI_INI','ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_DSC_LKI_INI','ESF_TRERETFACCTR','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_DSC_LKI_INI','ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_DSC_LKI_INI','ESF_GTSII_ESCOMPTE_RMNTP','${DFILP}/${PCH}ESFD3620_I17G_DSC_LKI_INI_GTSII_ESCOMPTE_RMNTP.dat','O','') 

print '------>>>> End ESFD3620 : I17G_DSC_LKI_INI  ' 
go

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_LKI_INI','ESF_FSEGPATTERNDSCf17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_RAD_LKI_INI','ESF_TRERETFACCTR','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN.dat','I','') 

print '------>>>> End ESFD3620 :  I17G_RAD_LKI_INI  ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFD3610 : I17G_CSF_ALL_INI                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>>  Lahcen request : START ESFD3610 SET UP  ' 
GO
DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_CSF_ALL_INI')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','EST_IRDPERICASE0','${DFILP}/${PCH}ESPT0000_IRDPERICASE0.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','EST_FSEGPATTERN_CSF','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','EST_FSEGPATTERN_ICR','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FSEGPATTERN_ICR_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','EST_IADPERICASE','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','EST_IADPERICASE_STD','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','ESF_IADVPERICASE_P','${DFILP}/${PCH}ESEH1100_IADVPERICASE_P_INI.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','ESF_IRDPERICASE_NP','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IRDPERICASE_NP.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','EST_FTECLEDSII','${DFILI}/${PCH}ESFD3610_I17G_CSF_ALL_INI_FTECLEDSII.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','EST_DLDSIIGTAA','${DFILI}/${PCH}ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTAA.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','EST_DLDSIIGTAR','${DFILI}/${PCH}ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTAR.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','EST_DLDSIIGTR','${DFILI}/${PCH}ESFD3610_I17G_CSF_ALL_INI_DLDSIIGTR.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSF_ALL_INI','PARM_IS_TRN','YES','','')

print '------>>>>  End Lahcen request : START ESFD3610 SET UP  ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFD3690 : I17G_IRV_ALL_STD                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>> Lahcen request : 85404 : ESFD3690 I17G_IRV_ALL_STD ' 

DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_IRV_ALL_STD')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_IRV_ALL_STD','PARM_IS_TRN','YES','','') 
 
print '------>>>> End Lahcen request : 85404 : ESFD3690 I17G_IRV_ALL_STD ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFD3720 : I17G_CSM_CRE_INI                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>> AGD request : 84457 : ESFD3720 I17G_CSM_CRE_INI ' 

DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_CSM_CRE_INI')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_CRE_INI','EPO_FCURQUOT_TXT','${DFILP}/${PCH}ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_CRE_INI','ESF_IADPERICASE_INI','${DFILI}/${PCH}ESEH1100_IADPERICASE_INI.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_CRE_INI','ESF_FRERETFACCTR_INI','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_FRERETFACCTR_TRN.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_CRE_INI','ESF_GTSII_CSM','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_CRE_INI','ESF_GTSII_GLOBAL_CASHFLOW','${DFILP}/${PCH}ESFD3630_I17G_IEX_ALL_INI_GTSII_GLOBAL_CASHFLOW_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_CRE_INI','ESF_FSEGPROF','${DFILP}/${PCH}ESFD3720_I17G_CSM_CRE_INI_FSEGPROF_${PARM_ICLODAT_D}.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_CRE_INI','PARM_IS_TRN','YES','','')
 
print '------>>>> End AGD request : 84457 : ESFD3720 I17G_CSM_CRE_INI ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFD3750 : I17G_CSM_ALL_STD                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>> AGD request : 84457 : ESFD3750 I17G_CSM_ALL_STD ' 

DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_CSM_ALL_STD')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','ESF_TRANSITION_FILE','${DFILP}/${PCH}ESFT0020_I17G_OMG_ALL_TRA_TRANSITION_FILE.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','ESF_TRERETFACCTR','${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_${NORME_CF}_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','EST_FSEGPATTERN_DSC_f17','${DFILP}/${PCH}ESFD1130_FSEGPATTERNDSCf17_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','EST_IADPERICASE_STD','${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_STD.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','ESF_GTSII_CSM','${DFILP}/${PCH}ESFD3710_I17G_CSM_CSU_INI_GTSII_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','ESF_GTSII_ESCOMPTE','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','ESF_GTSII_ESCOMPTE_RAD','${DFILP}/${PCH}ESFD3620_I17G_RAD_LKI_STD_GTSII_ESCOMPTE_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','ESF_FSEGPROF_STD_PREVIOUS','${DFILP}/${PCH}ESFD3760_I17G_UOA_PRO_STD_FSEGPROF_${PARM_PREV_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','ESF_GTSII_ESCOMPTE_FWD','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_ESCOMPTE_FWD_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','ESF_GTSII_IFRS17_CSM','${DFILP}/${PCH}ESFD3690_I17G_IRV_ALL_STD_GTSII_IFRS17_CSM${TYPEINV0}_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_CSM_ALL_STD','PARM_IS_TRN','YES','','')
 
print '------>>>> End AGD request : 84457 : ESFD3750 I17G_CSM_ALL_STD ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFT0010 : I17G_OMG_CSU_TRA                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>>  ESFT0010 I17G_OMG_CSU_TRA ' 

delete 	BEST..TI17TRAPERMFIL where IDF_CT = 'I17G_OMG_CSU_TRA'

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_OMG_CSU_TRA','OMEGA_EXTRACT_TRN','${DFILP}/${ENV_PREFIX}_ESFT0010_I17G_OMG_CSU_TRA_OMEGA_EXTRACT.dat','O','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_OMG_CSU_TRA','PARM_IS_TRN','YES','','')

print '------>>>> End ART request : 84457 : ESFT0010 I17G_OMG_CSU_TRA ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFT0020 : I17G_OMG_ALL_TRA                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>>  ESFT0020 I17G_OMG_ALL_TRA ' 

delete 	BEST..TI17TRAPERMFIL where IDF_CT = 'I17G_OMG_ALL_TRA'

insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA','TRANSITION_INPUT_FILE','${DFILP}/${ENV_PREFIX}_BUISNESS_TRANSITION_${NORME_CF}.dat','I','')
insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA','BUSINESS_LOGS','${DFILP}/${ENV_PREFIX}_BUISNESS_TRANSITION_LOG.log','I','')
insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA','TRANSITION_OUTPUT_FILE','${DFILP}/${ENV_PREFIX}_ESFT0020_I17G_OMG_ALL_TRA_TRANSITION_FILE.dat','O','')
insert into BEST..TI17TRAPERMFIL values ('I17G_OMG_ALL_TRA',  'PARM_IS_TRN', 'YES', ' ', ' ' )
 
print '------>>>> End ART request : 84457 : ESFT0020 I17G_OMG_ALL_TRA ' 
go

----------------------------------------------------------------------------------------------------------
--																										--
-- 							CHAIN ESFT0030 : I17G_OMG_ROC_TRA                                           --
--                                                                                                      --
----------------------------------------------------------------------------------------------------------
print '------>>>>  ESFT0030 I17G_OMG_ROC_TRA' 

delete 	BEST..TI17TRAPERMFIL where IDF_CT = 'I17G_OMG_ROC_TRA'
delete  BEST..TI17REQCHN where IDF_CT = 'I17G_OMG_ROC_TRA'
delete  BEST..TI17CHN  where CHAIN_CT="ESFT0030"

insert into BEST..TI17CHN values ("ESFT0030","Data TRANSITION extraction")

delete  BEST..TI17FNC  where IDF_CT in ( 'I17G_OMG_ROC_TRA'  )
insert into BEST..TI17FNC values ("I17G_OMG_ROC_TRA","Get data IFRS 17 GROUP")

insert into BEST..TI17REQCHN values ('I17GMINV',  "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GMINVB', "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GQINV',  "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GQINVB', "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GQPOS',  "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GQPOSB', "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GQPOC',  "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GQPOCB', "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GYINV',  "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GYINVB', "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GYPOS',  "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GYPOSB', "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GYPOC',  "ESFT0030","I17G_OMG_ROC_TRA","")
insert into BEST..TI17REQCHN values ('I17GYPOCB', "ESFT0030","I17G_OMG_ROC_TRA","")

DELETE FROM  BEST..TI17TRAPERMFIL where IDF_CT IN ('I17G_OMG_ROC_TRA')

INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_OMG_ROC_TRA','ESF_IADPERICASE_TRN','${DFILP}/${PCH}ESFT0000_I17G_TRN_ALL_INI_IADPERICASE_${PARM_ICLODAT_D}.dat','I','') 
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_OMG_ROC_TRA','EST_IADPERICASE_I17G_STD','${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_I17G_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat','I','')
INSERT INTO BEST..TI17TRAPERMFIL VALUES ('I17G_OMG_ROC_TRA','PARM_IS_TRN','YES','','')
  
print '------>>>> End ESFT0030  ' 
go