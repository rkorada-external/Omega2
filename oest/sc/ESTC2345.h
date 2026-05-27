/***********************************************************************************
**                                                                                **
**  Application name : ESTC2345 header                                            **
**  Date de creation : 06/03/2020                                                 **
**  Author           : S.Behague                                                  **
**  Description      : definition de la structure FACCSUP                         **
**                                                                                **
**  Spira            : 82196 - IFRS17- REQ.LIF.01: AE interface for Life from SAS **
**                                                                                **
***********************************************************************************/


#ifndef PER_STRUCT
#define PER_STRUCT
                 
/* Position des champs dans FACCSUP */                                      
#define ES_SSD_CF                        0
#define ES_ESB_CF                        1
#define ES_NUMLIGNE_CT                   2
#define ES_BALSHEY_NF                    3
#define ES_BALSHRMTH_NF                  4
#define ES_BALSHRDAY_NF                  5
#define ES_VALPERY_NF                    6
#define ES_VALPERMTH_NF                  7
#define ES_TRNCOD_CF                     8
#define ES_RETAUTGEN_B                   9
#define ES_CTR_NF                       10
#define ES_END_NT                       11
#define ES_SEC_NF                       12
#define ES_UWY_NF                       13
#define ES_UW_NT                        14
#define ES_OCCYEA_NF                    15
#define ES_ACY_NF                       16
#define ES_SCOSTRMTH_NF                 17
#define ES_SCOENDMTH_NF                 18
#define ES_CLM_NF                       19
#define ES_CUR_CF                       20
#define ES_AMT_M                        21
#define ES_RETCTR_NF                    22
#define ES_RETEND_NT                    23
#define ES_RETSEC_NF                    24
#define ES_RTY_NF                       25
#define ES_RETUW_NT                     26
#define ES_PLC_NT                       27
#define ES_RETOCCYEA_NF                 28
#define ES_RETACY_NF                    29
#define ES_RETSCOSTRMTH_NF              30
#define ES_RETSCOENDMTH_NF              31
#define ES_RCL_NF                       32
#define ES_RETCUR_CF                    33
#define ES_RETAMT_M                     34
#define ES_COMMAC_LL                    35
#define ES_SPEENTTYP_CF                 36
#define ES_SPEENTNAT_CT                 37
#define ES_EVT_NF                       38
#define ES_REVT_NF                      39
#undef  ES_NBCOL                        
#define ES_NBCOL             				    40

#endif
