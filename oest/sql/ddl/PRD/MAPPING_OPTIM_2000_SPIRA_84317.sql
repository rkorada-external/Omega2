
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
	