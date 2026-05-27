#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EBS SOLVENCY - Calcul des Cashflow 
# nom du script SHELL           : ESID3702A.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28/06/2018
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Calcul des Cashflow et valeur escompte (copied from old ESID3702.cmd)
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[01] 29/08/2012 R. Cassis     :spot:24041 - Modifs Solvency 2
#[02] 20/01/2013 - -=PhP=-     :spot:24698 corrections pour la conso
#[03] 20/01/2013 - -=PhP=-     :spot:24836 corrections pour la conso
#[04] 20/01/2013 - -=PhP=-     :spot:24867 corrections pour la conso
#[05] 29/05/2013 PPEZOUT       :spot:25171 Modifications Solvency
#[06] 20/01/2013 - -=PhP=-     :spot:25399 corrections pour la conso
#[07] 23/05/2014 A. Ben Jeddou :spot 26838 Corrections sur le batch solvency P&C : reprise de code suite au passage  de 2A â.. la 1B
#[08] 10/07/2014 C. DESPRET    :spot:xxxxx Remove Life subsidiaries
#[09] 24/10/2013 :spot:26391 - Cyrille  - Prise en compte des fichiers GT Funds WithHeld accept et retro
#[10] 28/10/2013 :spot:26391 - Cyrille  - Ventilation par acceptation des depots GT Retro proportionnelle
#[11] 28/04/2015 :spot:26391 - Florent  - ajout condition poste 84
#[12] 04/06/2015 :spot:26391 - Roger    - Correction condition sur tri/include 'NO' en 'NON' sur condition depot step 255
#[13] 08/06/2015 :spot:26391 - Roger    - Diverses corrections sur tri steps 261 et 271
#[14] 17/06/2015 :spot:26391 - Roger    - Diverses corrections sur tri steps 255 et 261 et 18 et 50
#[15] 25/06/2015 :spot:28941 - PP/Roger - Diverses corrections pour EST49A2 EBS ULAE et Risk Management
#[16] 05/11/2015 :spot:29641 - Florent  - EBS : pb de ventilation par placements des agrâ..gats dâ..pots, step 271
#[17] 02/11/2015 :spot:29615 - P PEZOUT
#[18] 26/05/2016 S.Behague :spot:30583: Spira 41148
#[19] 10/06/2016 Roger Cassis  :spot:29629 gestion de l'allocation Râ..tro des NP
#[20] 28/06/2016 :spot:31251 - Florent       - spira 48151- EBS - UPR cancel - correction pour le mix of internal and external retrocessionaire: modif step 150 et 250 pour GTAA et GTAR
#                                            - ne plus mettre â.. zâ..ro le RETINTAMT_M
#[021] 23/04/2018 Roger Cassis :spira:61675 Le ICLODAT_D est ajoutâ.. au parm du ESTC8805 pour compatibilitâ.. avec ESID2561.cmd
#[022] 28/06/2018 JYP - PERSEE :  SPIRA 069426 : REQ 00.01 - this job manage cashflow calculation 
#[023] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums) 
#[024] 05/12/2018 Roger Cassis SPIRA 073340 : REQ 00.01 - this job manage cashflow calculation 
#[025] 05/02/2019 Quentin Desmettre : EXT-IFRS17-903121  REQ 10.09-10 : Funds Held Modelling: Investment Income Modelling
#[026] 21/01/2019 L.ELFAHIM    SPIRA 68072  : EBS - Cash Flow Table - Transactional Currency
#[027] 25/04/2019 JYP - PERSEE : spira 71570 :  3 files EST_GTSII moved from interm to perm
#[028] 13/06/2019 M.NAJI add syncsort to optimize job
#[029] 30/08/2019 JYP - PERSEE : spira 77663 : new version compatible with new archi IFRS17 (with IDF_CT)
#[030] 18/09/2019 MZM Spira 73772:Manage retro contract and merge input to cashflow calculations 
#[031] 29/01/2020 JYP SPIRA 79070: debug touch issue, retro at inception 
#[032] 13/02/2020 JYP SPIRA 82420: work with standard T.codes for Inception
#[033] 21/01/2020 Charles Socie : SPIRA 82557 : EBS - Future - Currency 
#[033] 24/01/2020 KBagwe  :spira:79904 STEP262, 269
#[034] 12/03/2020 JYP SPIRA 79070: retro at inception 
#[035] 02/04/2020 JYP SPIRA 92591: AE assumed , at inception
#[036] 12/04/2020 JYP SPIRA 92591: AE assumed , at inception
#[037] 12/04/2020 JYP SPIRA 92591: AE assumed , at inception
#[038] 20/04/2021 JYP SPIRA 92591: AE assumed , at inception bugfix
#[039] 26/08/2021 JYP SPIRA 92591: AE retro , at inception bugfix
#[040] 10/01/2022 MZM :spira:91532 Bug Fix : Taille Syncsort de 1000 ==> 2000  
#[041] 14/04/2022 Dad spira : 103830 fix PARALLEL_INIT parameter
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


# Job Initialisation
JOBINIT

# Get input parameters


BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
ICLODAT_D=$3
TYPEINV=$4
IDF_CT=$5
ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`



datej=`date '+%Y%m%d%H%M%S'`
datedel=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-1; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel1=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-2; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel2=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-3; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}  "
ECHO_LOG "#===> PATTYP_CT..................: ${PATTYP_CT}  "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D.................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D..............: $PARM_CLODAT_D"
ECHO_LOG "#===> ICLODAT_D .................: $ICLODAT_D "
ECHO_LOG "#===> PARM_INVCONSO_D ...........: $PARM_INVCONSO_D"
ECHO_LOG "#===> ICLODAT_A .................: $ICLODAT_A  "
ECHO_LOG "#===> ICLODAT_M .................: $ICLODAT_M  "
ECHO_LOG "#===> ICLODAT_J .................: $ICLODAT_J  "
ECHO_LOG "#===> PARM_INVCONSO_D .................: $PARM_INVCONSO_D  "
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#==> EST_DLDGTAA ......................:  $EST_DLDGTAA "
ECHO_LOG "#==> EST_CURGTA .......................:  $EST_CURGTA                       "
ECHO_LOG "#==> EST_DLREGTAR .....................:  $EST_DLREGTAR                     "
ECHO_LOG "#==> EST_DLREMAJGTAR ..................:  $EST_DLREMAJGTAR                  "
ECHO_LOG "#==> EST_DLRGTAA ......................:  $EST_DLRGTAA                      "
ECHO_LOG "#==> EST_DLSGTAA ......................:  $EST_DLSGTAA                      "
ECHO_LOG "#==> EST_DLSGTAR ......................:  $EST_DLSGTAR                      "
ECHO_LOG "#==> EST_FBOPRSLNK ....................:  $EST_FBOPRSLNK                    "
ECHO_LOG "#==> EST_FBOPRSLNK_TXT ................:  $EST_FBOPRSLNK_TXT                "
ECHO_LOG "#==> EST_FCTRFWH ......................:  $EST_FCTRFWH                      "
ECHO_LOG "#==> EST_FCTRGRO ......................:  $EST_FCTRGRO                      "
ECHO_LOG "#==> EST_FCURSII ......................:  $EST_FCURSII                      "
ECHO_LOG "#==> EST_FDETTRS ......................:  $EST_FDETTRS                      "
ECHO_LOG "#==> EST_FLIBEL2 ......................:  $EST_FLIBEL2                      "
ECHO_LOG "#==> EST_FPLATXCUMALL .................:  $EST_FPLATXCUMALL                 "
ECHO_LOG "#==> EST_FPRSMAP ......................:  $EST_FPRSMAP                      "
ECHO_LOG "#==> EST_FPRSMAP_TXT ..................:  $EST_FPRSMAP_TXT                  "
ECHO_LOG "#==> EST_FSEGPATTERN_CSF ..............:  $EST_FSEGPATTERN_CSF              "
ECHO_LOG "#==> EST_FSEGPATTERN_INF ..............:  $EST_FSEGPATTERN_INF              "
ECHO_LOG "#==> EST_FSEGPATTERNFWH  ..............:  $EST_FSEGPATTERNFWH               "
ECHO_LOG "#==> EST_FTECLEDASII ..................:  $EST_FTECLEDASII                  "
ECHO_LOG "#==> EST_FTRSLNK ......................:  $EST_FTRSLNK                      "
ECHO_LOG "#==> EST_FULAERAT .....................:  $EST_FULAERAT                     "
ECHO_LOG "#==> EST_FWHGTA .......................:  $EST_FWHGTA                       "
ECHO_LOG "#==> EST_FWHGTR .......................:  $EST_FWHGTR                       "
ECHO_LOG "#==> EST_IADPERICASE ..................:  $EST_IADPERICASE                  "
ECHO_LOG "#==> EST_IRDPERICASE0 .................:  $EST_IRDPERICASE0                 "
ECHO_LOG "#==> EST_FCURQUOT_TXT .................:  $EST_FCURQUOT_TXT                 "
ECHO_LOG "#==> ESF_IRDPERICASE_NP ...............:  $ESF_IRDPERICASE_NP               "
ECHO_LOG "#==> ESF_IADVPERICASE_P ...............:  $ESF_IADVPERICASE_P               "
ECHO_LOG "#==> ESF_DLDGTR_P .....................:  $ESF_DLDGTR_P                     "
ECHO_LOG "#==> ESF_DLDGTR_NP ....................:  $ESF_DLDGTR_NP                    "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#==> EST_DLCUMGTAAR ...................:  $EST_DLCUMGTAAR                   "
ECHO_LOG "#==> EST_DLCUMGTAAR_IBNR_FUTCLAIMS ....:  $EST_DLCUMGTAAR_IBNR_FUTCLAIMS    "
ECHO_LOG "#==> EST_GTSII_CASHFLOW ...............:  $EST_GTSII_CASHFLOW               "
ECHO_LOG "#==> EST_GTSII_REMAINTOPAY_ULAE .......:  $EST_GTSII_REMAINTOPAY_ULAE       "
ECHO_LOG "#==> EST_GTSII_REMAINTOPAY_ULAEINF ....:  $EST_GTSII_REMAINTOPAY_ULAEINF    "
ECHO_LOG "#==> EST_DLDGTAA_DLSGTAA       ........:  $EST_DLDGTAA_DLSGTAA    "
ECHO_LOG "#==> EST_DLDGTAR_DLSGTAR       ........:  $EST_DLDGTAR_DLSGTAR     "
ECHO_LOG "#========================================================================="







NSTEP=${NJOB}_05
# Split EST_FBOPRSLNK_TXT by accept and retro and AE IFRS17
#-----------------------------------------------------------------------------
LIBEL="Split EST_FBOPRSLNK_TXT by accept and retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FBOPRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FBOPRSLNK_ACCEPT.dat 500 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FBOPRSLNK_RETRO.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DETTRS1_CF    9:1 -  9:1
		,TRSTYP_NT    8:1 -  8:1
		,DETTRS12_CF  9:1 -  9:2
		,TRNTYP_CT    14:1 - 14:EN
		,ACMTRSL3_NT  5:1 -  5: 
		,all_cols     1:1  - 14:
/CONDITION IS_ACCEPT ( DETTRS1_CF = "1" AND TRSTYP_NT = "3"  )
/CONDITION IS_RETRO ( DETTRS1_CF = "2" AND TRSTYP_NT = "3"  )
/OUTFILE $SORT_O
/INCLUDE IS_ACCEPT
/OUTFILE $SORT_O2 
/INCLUDE IS_RETRO
/COPY
exit
EOF
SORT
 


NSTEP=${NJOB}_10
# Extend EST_FBOPRSLNK_TXT with ACMTRS_NT and PARM1 of EST_FPRSMAP_TXT
#-----------------------------------------------------------------------------
LIBEL="Extend EST_FBOPRSLNK_TXT with ACMTRS_NT and PARM1 of EST_FPRSMAP_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FBOPRSLNK_TXT}  500 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FBOPRSLNK_FPRSMAP.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACMTRSL3_NT      5:1 -  5:,
        DETTRS_CF        9:1 -  9:,
		PRS_CF			 1:1  - 1:,
        ACMTRS_NT        2:1 -  2:,
		PARM1			 3:1  -  3:,
		all_cols		 1:1  - 14:
/joinkeys 
       ACMTRSL3_NT
/INFILE ${EST_FPRSMAP_TXT} 500 1 "~"
/joinkeys 
       ACMTRS_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:all_cols
	,rightside:ACMTRS_NT   
	,rightside:PARM1   
exit
EOF
SORT


NSTEP=${NJOB}_15
# Filter EST_FTRSLNK_TXT on PRS_CF = "751"
#-----------------------------------------------------------------------------
LIBEL="Filter EST_FTRSLNK_TXT on PRS_CF = "751""
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  PRS_CF    1:1 -  1:
/CONDITION IS_PRS_751 ( PRS_CF = "751" )
/OUTFILE $SORT_O
/INCLUDE IS_PRS_751
/COPY
exit
EOF
SORT


PARALLEL_INIT 6

# when called by Q3 EBS
if [ "${CONTEXT_CT}" = "" ] 
then
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
# GTAa files merge
#[006]
#[007]
#[008] Remove Life subsidiaries
#[009] Suppression des doublons Funds WithHeld : on ne conserve que ceux du fichier des Funds withheld (EST_FWHGTA)
# on supprime ceux contenus dans les autres fichiers : TRNCOD34_CF != '81' et '84' (code depot)
# on veut aussi conserver les écritures service dont le 2ieme caractere du code est G (meme pour les depots)
#[014] [024]
#-----------------------------------------------------------------------------
LIBEL="GTA AGREGATES Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA} 2000 1"
SORT_I2="${EST_DLSGTAA} 2000 1"
SORT_I3="${EST_CURGTA} 2000 1"
#SORT_I4="${EST_DLSGTAASII} 2000 1"  # on ne peut prendre 2 fois les ecritures de service du ESPD1800 - RC
SORT_I4="${EST_FTECLEDASII} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        AMT_M            19:1 - 19:EN 15/3,
        RETAMT_M         35:1 - 35:EN 15/3,
        FILLER1           1:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF
/CONDITION COND_TRNCOD TRNCOD1_CF = "1" AND "1357" NC TRNCOD8_CF
                   AND ( BALSHEY_NF = "${ICLODAT_A}" AND BALSHRMTH_NF <= ${ICLODAT_M} )
                   AND ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" AND TRNCOD3_CF != "1008" )
                   AND ( TRNCOD4_CF != "49413" AND TRNCOD4_CF != "46000" AND TRNCOD4_CF != "20053" AND TRNCOD4_CF != "20910" AND TRNCOD4_CF != "46002")
                   AND ( ("246" CT TRNCOD8_CF AND "1A" CT TRNCOD2_CF) OR "4EG" CT TRNCOD2_CF OR "0" CT TRNCOD8_CF)
                   AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND ( (TRNCOD34_CF != '81' AND TRNCOD34_CF != '84' ) or ( TRNCOD2_CF="G" AND (TRNCOD34_CF = '81' OR TRNCOD34_CF = '84' ))  )
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A" 
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
/REFORMAT FILLER1,PLUS_16_CHAMPS,ORICOD_LS
exit
EOF
PARALLEL SORT	


NSTEP=${NJOB}_20B
#-----------------------------------------------------------------------------
LIBEL="merge futures with ESPD1800-AE into EST_DLDGTAR_DLSGTAR and EST_DLDGTAA_DLSGTAA"
EXECKSH_MODE=P
EXECKSH "cat $ESF_DLDGTR_NP $EST_DLSGTAR  > $EST_DLDGTAR_DLSGTAR "
EXECKSH_MODE=P
EXECKSH "cat $EST_DLDGTAA $EST_DLSGTAA  > $EST_DLDGTAA_DLSGTAA "
EXECKSH_MODE=P
EXECKSH "wc -l $EST_DLDGTAA $EST_DLSGTAA $EST_DLDGTAA_DLSGTAA "
EXECKSH_MODE=P
EXECKSH "wc -l $ESF_DLDGTR_NP $EST_DLSGTAR $EST_DLDGTAR_DLSGTAR "



else  #========= CONTEXT = "INI" when I17G call

 
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="AT INCEPTION : GTA AGREGATES Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA_DLSGTAA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        AMT_M            19:1 - 19:EN 15/3,
        RETAMT_M         35:1 - 35:EN 15/3,
        FILLER1           1:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~~"
/DERIVEDFIELD ORICOD_LS "INIGTA"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,PLUS_16_CHAMPS,ORICOD_LS
exit
EOF
PARALLEL SORT	


fi



NSTEP=${NJOB}_25
touch ${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAR_O.dat

#Accumulation of acceptation and retrocession amount by ACMTRS_NT
#[006]
#[007]
#[008] Remove Life subsidiaries
#[009] Suppression des doublons Funds WithHeld : on ne conserve que ceux du fichier des Funds withheld (EST_FWHGTR)
# on supprime ceux contenus dans les autres fichiers : TRNCOD34_CF != '81' et '84'(code depot)
# on veut aussi conserver les écritures service dont le 2ieme caractere du code est G (meme pour les depots)
#[014] [024] [030]
#-----------------------------------------------------------------------------
LIBEL="GTAR AGREGATES Merge and sort of dGTAR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CURGTA} 2000 1"
SORT_I2="${EST_DLREGTAR} 2000 1"
SORT_I3="${EST_DLREMAJGTAR} 2000 1"
SORT_I5="${EST_FTECLEDASII} 2000 1"
SORT_I6="${ESF_DLDGTR_P} 2000 1"
SORT_I7="${EPO_DLDGTAR_E} 2000 1"  # [030]
SORT_I8="${EST_DLDGTAR_DLSGTAR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 35:,
        FILLER2          38:1 - 40:
/KEYS   RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CUR_CF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RETCUR_CF,
        PLC_NT,
        RTO_NF                                                           
/CONDITION COND_TRNCOD TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} )
                   AND ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" AND TRNCOD3_CF != "1008" )
                   AND ( TRNCOD4_CF != "49413" AND TRNCOD4_CF != "46000" AND TRNCOD4_CF != "20053" AND TRNCOD4_CF != "20910" AND TRNCOD4_CF != "46002")
                   AND ( ("246" CT TRNCOD8_CF AND "1A" CT TRNCOD2_CF) OR "4EG" CT TRNCOD2_CF OR "0" CT TRNCOD8_CF)
                   AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND ( (TRNCOD34_CF != '81' AND TRNCOD34_CF != '84' ) or ( TRNCOD2_CF="G" AND (TRNCOD34_CF = '81' OR TRNCOD34_CF = '84' ))  )     
/DERIVEDFIELD PLUS_16_CHAMPS "~P~~~~~~~~~~~~~~~"
/DERIVEDFIELD PLUS_02_CHAMPS "~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
/REFORMAT FILLER1,PLUS_02_CHAMPS,FILLER2,PLUS_16_CHAMPS,ORICOD_LS
exit
EOF
PARALLEL SORT



NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
# GTAa Funds Withheld
#-----------------------------------------------------------------------------
LIBEL="GTAa Funds Withheld"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FWHGTA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FWHGTAA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        AMT_M            19:1 - 19:EN 15/3,
        RETAMT_M         35:1 - 35:EN 15/3,
        FILLER1           1:1 - 41:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF
/CONDITION COND_TRNCOD TRNCOD1_CF = "1"
                   AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND (TRNCOD34_CF = '81' OR TRNCOD34_CF = '84')                                             
/DERIVEDFIELD PLUS_15_CHAMPS "~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
/REFORMAT FILLER1,PLUS_15_CHAMPS,ORICOD_LS
exit
EOF
PARALLEL SORT

NSTEP=${NJOB}_35
#Comparison of period closing and segmentation perimeters
#(by the contract grouping file)
#-----------------------------------------------------------------------------
LIBEL="Extract SEG_NF information from ctrgro and put it into Pericase"
PRG=ESTM1004
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRGRO_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
PARALLEL EXECPRG

NSTEP=${NJOB}_40
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLATXCUMALL}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUMALL.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 2:1 - 2:EN,
        RETRTY_NF 3:1 - 3:,
        PLC_NT    4:1 - 4:EN
/KEYS RETCTR_NF, RETRTY_NF, RETSEC_NF, PLC_NT
/SUM
/STABLE
exit
EOF
PARALLEL SORT

PARALLEL_END




PARALLEL_INIT 2

NSTEP=${NJOB}_45
#  Filter GTAA: GTAA and FBOPRSLNK_ACCEPT join on FBOPRSLNK_ACCEPT.DETTRS_CF = GTAA.TRNCOD_CF
#-----------------------------------------------------------------------------
LIBEL="Filter GTAA: GTAA and FBOPRSLNK_ACCEPT join on FBOPRSLNK_ACCEPT.DETTRS_CF = GTAA.TRNCOD_CF"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_FBOPRSLNK_ACCEPT.dat  500 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        DETTRS_CF        9:1 -  9:,
		all_cols		 1:1  - 57:
/joinkeys 
       DETTRS_CF
/INFILE ${DFILT}/${NJOB}_20_${IB}_SORT_DLSIIGTAA_O.dat 2000 1 "~"
/joinkeys 
       TRNCOD_CF 
/OUTFILE ${SORT_O} overwrite
/REFORMAT 
	rightside:all_cols
exit
EOF
PARALLEL SORT


NSTEP=${NJOB}_50
# Filter GTAR: GTAR and FBOPRSLNK_ACCEPT join on FBOPRSLNK_RETRO.DETTRS_CF = GTAA.TRNCOD_CF
#-----------------------------------------------------------------------------
LIBEL="Filter GTAR: GTAR and FBOPRSLNK_ACCEPT join on FBOPRSLNK_RETRO.DETTRS_CF = GTAA.TRNCOD_CF "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_FBOPRSLNK_RETRO.dat  500 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        DETTRS_CF        9:1 -  9:,
		RETCTR_NF        24:1 - 24:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        PLC_NT           36:1 - 36:,
		all_cols		 1:1  - 57:
/joinkeys 
       DETTRS_CF
/INFILE ${DFILT}/${NJOB}_25_${IB}_SORT_DLSIIGTAR_O.dat  2000 1 "~"
/joinkeys 
       TRNCOD_CF 
/OUTFILE ${SORT_O} overwrite
/REFORMAT 
	rightside:all_cols
exit
EOF
PARALLEL SORT
PARALLEL_END


NSTEP=${NJOB}_55
#Accumulation of acceptation and retrocession amount by ACMTRS_NT
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES Accumulation of retrocession amount by ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_SORT_GTAR.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR.dat
#SORT_I="${DFILT}/${NJOB}_50B_${IB}_SORT_DLSIIGTAR_O.dat 2000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 18:,
        FILLER2          20:1 - 34:,
        FILLER3          36:1 - 40:,
        FILLER4          42:1 - 56:
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        PLC_NT,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        RTO_NF,
        TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
/CONDITION COND_ORIGINE ( "AEJ" CT TRNCOD2_CF )
/DERIVEDFIELD VAL_ORIGINE if COND_ORIGINE then "EBSGTA" else "GTAR" 
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
/REFORMAT FILLER1,AMT_MC,FILLER2,RETAMT_MC,FILLER3,RETINTAMT_MC,FILLER4,VAL_ORIGINE
exit
EOF
SORT


NSTEP=${NJOB}_60
# Affectation par placement
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES retro Affectation par placement"
PRG=ESTC1052
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_FPLATXCUMALL.dat
export ${PRG}_I2=${DFILT}/${NJOB}_55_${IB}_SORT_GTAR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSIIGTAR.dat
EXECPRG

NSTEP=${NJOB}_65
# Extend GTAAR with TRNCOD_CF of EST_FTRSLNK_TXT
#---------------------------------------------------------------------------
LIBEL="Extend GTAAR with TRNCOD_CF of EST_FTRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_FTRSLNK_751.dat 500 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_GTAAR_FTRSLNK.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        DETTRS_CF        3:1 -  3:,
        ACMTRS_NT        2:1 -  2:,
		all_cols		 1:1  - 57:
/joinkeys 
       DETTRS_CF
/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_FWHGTAA_O.dat 2000 1 "~"
/INFILE ${DFILT}/${NJOB}_45_${IB}_SORT_GTAA.dat  2000 1 "~"
/INFILE ${DFILT}/${NJOB}_60_${IB}_ESTC1052_DLSIIGTAR.dat  2000 1 "~"
/joinkeys 
       TRNCOD_CF
/JOIN UNPAIRED RIGHTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	rightside:all_cols
	,leftside:ACMTRS_NT   
exit
EOF
SORT

NSTEP=${NJOB}_70
# Extend GTAAR with ACMTRSL2_NT, ACMTRSL3_NT, TRNTYP_CT  of EST_FBOPRSLNK_TXT
#---------------------------------------------------------------------------
LIBEL="Extend GTAAR with ACMTRSL2_NT, ACMTRSL3_NT, TRNTYP_CT  of EST_FBOPRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FBOPRSLNK_FPRSMAP.dat 500 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_GTAAR_FTRSLNK_FBOPRSLNK_FPRSMAP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FBOPRSLNK_DETTRS_CF        9:1 -  9:,
        DETTRS_CF        6:1 -  6:,	
        ACMTRSL2_NT     4:1 -  4:,
		ACMTRSL3_NT     5:1 -  5:,
		TRNTYP_CT      14:1 - 14:,
		ACMTRS_NT  	   15:1 - 15:,
		PARM1      	   16:1 - 16:,
		all_cols	   1:1  - 58:
/joinkeys 
       FBOPRSLNK_DETTRS_CF
/INFILE ${DFILT}/${NJOB}_65_${IB}_GTAAR_FTRSLNK.dat  2000 1 "~"
/joinkeys 
       DETTRS_CF
/JOIN UNPAIRED RIGHTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT 	rightside:all_cols
	,leftside:ACMTRSL2_NT    
	,leftside:ACMTRSL3_NT    
	,leftside:TRNTYP_CT     	
	,leftside:ACMTRS_NT
	,leftside:PARM1
exit
EOF
SORT

NSTEP=${NJOB}_75
# MOD003 -  Sort of IADPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_ESTM1004_IADPERICASE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    3:1 -  3:,
        END_NT    4:1 -  4:,
        SEC_NF    5:1 -  5:EN,
        UWY_NF    6:1 -  6:,
        UW_NT     7:1 -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_80
#Accumulation of acceptation and retrocession
#-----------------------------------------------------------------------------
LIBEL="GTA + GTAR AGREGATES Accumulation of acceptation and retrocession"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_GTAAR_FTRSLNK_FBOPRSLNK_FPRSMAP.dat		  2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAAR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 41:,
		FILLER2          58:1 - 63:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT
/DERIVEDFIELD PLUS_15_CHAMPS "~~~~~~~~~~~~~~~"
/DERIVEDFIELD PLUS_1_CHAMPS "~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,PLUS_15_CHAMPS,ORICOD_LS,PLUS_1_CHAMPS,FILLER2
exit
EOF
SORT

#[023]change 750 to 751
NSTEP=${NJOB}_85
#------------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 ACCEPT Add cols data to GT format ACMTRS/LOB/CUR + CONVERSION "
PRG=ESTC1051A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${BALSHTYEA_NF}
PRS_CF 751 
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_75_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_80_${IB}_SORT_DLSIIGTAAR_O.dat
export ${PRG}_I3=${EST_FCURQUOT_TXT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTESTCUMUL1_ACCRET.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG



NSTEP=${NJOB}_87
#-----------------------------------------------------------------------------
LIBEL="Extract SEG_NF information from ctrgro and put it into RETRO_P Pericase"
PRG=ESTM1004
export ${PRG}_I1=${ESF_IADVPERICASE_P}
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRGRO_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADVPERICASEP.dat
EXECPRG




NSTEP=${NJOB}_90
touch ${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE_O.dat
#-----------------------------------------------------------------------------
LIBEL="Sort of IRDPERICASE IRDPERICASE_NP IADVPERICASE_P "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 2000 1"
SORT_I2="${ESF_IRDPERICASE_NP} 2000 1"
#SORT_I3="${ESF_IADVPERICASE_P} 2000 1"
SORT_I3="${DFILT}/${NJOB}_87_${IB}_${PRG}_IADVPERICASEP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE_O.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    3:1 -  3:,
        END_NT    4:1 -  4:,
        SEC_NF    5:1 -  5:EN,
        UWY_NF    6:1 -  6:,
        UW_NT     7:1 -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT






NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 SORT OF retrocession"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_85_${IB}_ESTC1051A_GTESTCUMUL1_ACCRET.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD3_CF        6:3 -  6:6,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52:
/KEYS   RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "") OR TYP_CT != "A"
/OUTFILE ${SORT_O}
/INCLUDE LOB
exit
EOF
SORT



 #[023]change 750 to 751
NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 RETROCESSION Add cols data to GT format ACMTRS/LOB/CUR + CONVERSION "
PRG=ESTC1051A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${BALSHTYEA_NF}
PRS_CF 751
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_SORT_IRDPERICASE_O.dat # Perimetre Accept ou retro selon valeur ACCRET
export ${PRG}_I2=${DFILT}/${NJOB}_95_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
export ${PRG}_I3=${EST_FCURQUOT_TXT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTESTCUMUL1_ACCRET.dat # Sortie Accept ou retro selon valeur ACCRET
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG



# --------------------------------------------
# [010] Begin
# Allocate Retro Funds withheld by acceptation
# --------------------------------------------

#[010] [012] [014] [023]add new columns
NSTEP=${NJOB}_255
# FWH Retro : Allocation key : Get and summarize proportionnal retrocession
# i.e. : 
#  Proportionnal retro is Retrocession with acceptation : TYP_CT = 'R' (retro) and CTR_NF != '' (there is an accept contract)
#  For P&C : LOB != 30 or 31
#  Don't get Funds withheld : they are amounts that will be allocated
#
# Sum amounts by retro / ctr to have the allocation key. Don't use PLC
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : Allocation key : Get and summarize proportionnal retrocession"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTC1051A_GTESTCUMUL1_ACCRET.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        TRNCOD3_CF        6:3 -  6:6,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        CTR2_NF           8:1 -  8:1,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS   RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT       
       ,ACMCUR_CF       
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT       
/CONDITION  COND_DEPOT (ACMTRS_NT='902' AND TRNCOD34_CF='84') OR ACMTRS_NT='702'
/DERIVEDFIELD DEPOT IF COND_DEPOT THEN 'YES' ELSE 'NON' CHAR 3
/CONDITION  RETACC ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "") AND (TYP_CT = "R" AND CTR_NF != '' AND CTR2_NF != ' ') AND DEPOT='NON'
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RETACC
exit
EOF
SORT


#[010]
NSTEP=${NJOB}_256
LIBEL="FWH Retro : Allocation key : Compute acceptation ratio per retro contract"
#------------------------------------------------------------------------------
LIBEL="FWH Retro : Allocation key : Compute acceptation ratio per retro contract"
PRG=ESTC1055
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_255_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_ALLOC_KEY_O.dat
EXECPRG


#[010]
NSTEP=${NJOB}_260
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWHGTR : Filter funds for EBS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FWHGTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FWHGTR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 40:
/KEYS   RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CUR_CF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RETCUR_CF,
        PLC_NT,
        RTO_NF
/CONDITION COND_TRNCOD TRNCOD1_CF = "2"
                   AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND TRNCOD34_CF = '81' OR TRNCOD34_CF = '84'                                           
/DERIVEDFIELD PLUS_16_CHAMPS "~P~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
/REFORMAT FILLER1,PLUS_16_CHAMPS,ORICOD_LS
exit
EOF
SORT


#[010] [013] [014] [015]
NSTEP=${NJOB}_261
# FWH Retro : FWHGTR : Summarize EBS funds CSU / RCSU / PLC / TRNCOD
# AMT is set to RETAMT to be re-allocated by "accept / RSCU" allocation key
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWHGTR : Summarize EBS funds CSU / RCSU / PLC / TRNCOD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_260_${IB}_SORT_FWHGTR_O.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SUM_FWHGTR_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_SUM_FWHGTR_O2.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD34_CF 6:3 -  6:4,
        DBLTRNCOD_CF 7:1 - 7:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        FILLER1   1:1 - 17:,
        FILLER2  20:1 - 55:
/KEYS RETCTR_NF,
      RETEND_NT,
      RTY_NF,
      RETUW_NT,
      RETSEC_NF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      RETCUR_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      TRNCOD34_CF
/CONDITION RETAMT RETAMT_M != 0
/CONDITION RETAMT0 RETAMT_M = 0
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD PLUS_10_CHAMPS "~~~~~~~~~~"
/DERIVEDFIELD zero1 "01~"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE RETAMT
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, zero1, TRNCOD_CF, DBLTRNCOD_CF, PLUS_10_CHAMPS, RETCUR_CF, RETAMT_M, FILLER2
/OUTFILE ${SORT_O2}
/INCLUDE RETAMT0
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, zero1, TRNCOD_CF, DBLTRNCOD_CF, PLUS_10_CHAMPS, RETCUR_CF, RETAMT_M, FILLER2
exit
EOF
SORT


#[010]
NSTEP=${NJOB}_262
# FWH Retro : FWHGTR : Sort EBS funds by RCSU
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWHGTR : Sort EBS funds by RCSU"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_261_${IB}_SORT_SUM_FWHGTR_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SUM_FWHGTR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RTY_NF 27:1 - 27:EN,
        RETSEC_NF 26:1 - 26:EN,
        RETCUR_CF 18:1 - 18:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_CF_SUFIX 6:7 - 6:8,
        TRNCOD_CF_PREFIX 6:1 - 6:2
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      RETCUR_CF,
      TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[010] Liste des codes depot dans le fichier FWHGTR
#[023]change 750 to 751
NSTEP=${NJOB}_265
# FWH Retro : FWH GTR->GTAR : Get TRSLNK for EBS funds
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTR->GTAR : Get TRSLNK for EBS funds"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_262_${IB}_SORT_SUM_FWHGTR_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRSLNK_FWHGTR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/KEYS   TRNCOD_CF
/SUM
/STABLE
/DERIVEDFIELD PRS_CF "751~" 
/DERIVEDFIELD ACMTRS_NT "31~"
/OUTFILE ${SORT_O}
/REFORMAT PRS_CF, ACMTRS_NT, TRNCOD_CF
exit
EOF
SORT


#[010]
NSTEP=${NJOB}_266
# FWH Retro : FWH GTR->GTAR : Sort pericase
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTR->GTAR : Sort pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDVPERICASE_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
            RTY_NF 6:1 - 6:EN,
            RETSEC_NF 5:1 - 5:EN,
            RETCTRCAT_CF 107:1 - 107:
/KEYS RETCTR_NF, RTY_NF, RETSEC_NF
exit
EOF
SORT


#[015]
#[034]
NSTEP=${NJOB}_269
#-----------------------------------------------------------------------------
LIBEL="Sort of ESTC1055_GTAR_ALLOC_KEY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_256_${IB}_ESTC1055_GTAR_ALLOC_KEY_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTVENTNP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RTY_NF    2:1 - 2:EN,
        RETSEC_NF 3:1 - 3:EN,
        CUR_CF   18:1- 18:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT



if [ "${CONTEXT_CT}" = "INI" ] || [ "${PATCAT_CT}" = "NDC" ] # Closing at Inception
then
NSTEP=${NJOB}_270
PRG=ESTC8805
LIBEL="AT INCEPTION : touch retro files for context I17G INI "
EXECKSH_MODE=P
EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.dat"
EXECKSH_MODE=P
EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.ano"
EXECKSH_MODE=P
EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_${PRG}_VENTNPGTAR_vide.dat"

else  #when called by Q3 EBS

NSTEP=${NJOB}_270
# FWH Retro : FWH GTR->GTAR : Allocate acceptation per retro contract
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTR->GTAR : Allocate acceptation per retro contract"
PRG=ESTC8805
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
TYPE_EDITION 1
CRE_D ${ICLODAT_D}
ICLODAT_D ${ICLODAT_D}
CUR_B T		
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_262_${IB}_SORT_SUM_FWHGTR_O.dat 
export ${PRG}_I2=${DFILT}/${NJOB}_269_${IB}_SORT_FTVENTNP_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_265_${IB}_TRSLNK_FWHGTR_O.dat
export ${PRG}_I4=${DFILT}/${NJOB}_266_${IB}_SORT_IRDVPERICASE_O.dat
export ${PRG}_I5=${EST_FLIBEL2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.ano
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_VENTNPGTAR_vide.dat   #[19]
EXECPRG

fi


NSTEP=${NJOB}_270a
# Extend GTAAR with ACMTRSL2_NT, ACMTRSL3_NT, TRNTYP_CT  of EST_FBOPRSLNK_TXT
#---------------------------------------------------------------------------
LIBEL="Extend GTAAR with ACMTRSL2_NT, ACMTRSL3_NT, TRNTYP_CT  of EST_FBOPRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FBOPRSLNK_FPRSMAP.dat 500 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC8805_FWHGTARR.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FBOPRSLNK_DETTRS_CF        9:1 -  9:,
        DETTRS_CF        6:1 -  6:,	
        ACMTRSL2_NT     4:1 -  4:,
		ACMTRSL3_NT     5:1 -  5:,
		TRNTYP_CT      14:1 - 14:,
		ACMTRS_NT  	   15:1 - 15:,
		PARM1      	   16:1 - 16:,
		all_cols	   1:1  - 58:
/joinkeys 
       FBOPRSLNK_DETTRS_CF
/INFILE ${DFILT}/${NJOB}_270_${IB}_${PRG}_FWHGTARR.dat 2000 1 "~"
/joinkeys 
       DETTRS_CF
/JOIN UNPAIRED RIGHTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT 	rightside:all_cols
	,leftside:ACMTRSL2_NT    
	,leftside:ACMTRSL3_NT    
	,leftside:TRNTYP_CT     	
	,leftside:ACMTRS_NT
	,leftside:PARM1
exit
EOF
SORT

#[010] [013] [015]
NSTEP=${NJOB}_271
#------------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTARR : Sort by CSU / RCSU"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270a_${IB}_ESTC8805_FWHGTARR.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FWHGTARR.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        AMT_M            19:1 - 19:EN 15/3,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,RETCUR_CF
       ,TRNCOD34_CF
       ,PLC_NT
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M
/CONDITION NONNULL (AMT_M != 0 OR RETAMT_M != 0)
/OUTFILE ${SORT_O}
/INCLUDE NONNULL
exit
EOF
SORT

#[010]
#[023] change 750 to 751
NSTEP=${NJOB}_272
#------------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTARR : Fill ACMTRS, currencies, segmentaion for Retro"
PRG=ESTC1051A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${BALSHTYEA_NF}
PRS_CF 751  
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_75_${IB}_SORT_IADPERICASE_O.dat      
export ${PRG}_I2=${DFILT}/${NJOB}_271_${IB}_SORT_FWHGTARR.dat
export ${PRG}_I3=${EST_FCURQUOT_TXT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG


#[010]
NSTEP=${NJOB}_273
#------------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTARR : Sort by RCSU / CSU"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_272_${IB}_ESTC1051A_FWHGTARR.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FWHGTARR.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        PLC_NT           36:1 - 36:        
/KEYS   RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


#[010]
NSTEP=${NJOB}_274
#[023]change 750 to 751
#------------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTARR : Fill ACMTRS, currencies, segmentation for Retro"
PRG=ESTC1051A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${BALSHTYEA_NF}
PRS_CF 751  
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_SORT_IRDPERICASE_O.dat # Perimetre Accept ou retro selon valeur ACCRET
export ${PRG}_I2=${DFILT}/${NJOB}_273_${IB}_SORT_FWHGTARR.dat
export ${PRG}_I3=${EST_FCURQUOT_TXT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.dat # Sortie Accept ou retro selon valeur ACCRET
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG


# --------------------------------------------
# [010] End
# Allocate Retro Funds withheld by acceptation
# --------------------------------------------

#[015]
NSTEP=${NJOB}_400
#[023]add new columns
#[009] Ajout du ACMTRS 702 = Funds No life a prendre en compte
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES Accumulation of acceptation and retrocession amount by ACMTRS_NT, TYP ==> file agregate"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTC1051A_GTESTCUMUL1_ACCRET.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_274_${IB}_ESTC1051A_FWHGTARR.dat 500 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_GTESTCUMUL1_ACCRET.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT        52:1 - 52: 
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT
/CONDITION COND_TRNCOD ( ACMTRS_NT = "101" OR ACMTRS_NT = "105" OR ACMTRS_NT = "201" OR ACMTRS_NT = "205" OR 
                         ACMTRS_NT = "301" OR ACMTRS_NT = "303" OR ACMTRS_NT = "307" OR ACMTRS_NT = "309" OR ACMTRS_NT = "311" OR ACMTRS_NT = "316" OR ACMTRS_NT = "320" OR 
                         ACMTRS_NT = "702" OR (ACMTRS_NT = "902" AND TRNCOD34_CF = "84") ) AND
                         ( LOB_CF != "30" AND LOB_CF != "31" ) AND ACMAMT_M != 0
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          ACMTRS_NT,
          ACMAMT_MC,
          ACMCUR_CF,
          PRS_CF,
          SEG_NF,
          LOB_CF,
          NAT_CF,
          TYP_CT,
          PATTYP_CF,
          SEGLOB_CF,
	  ACMTRS3_NT  
exit
EOF
SORT

#[015]
#[023]add new columns
NSTEP=${NJOB}_500
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES ULAE extraction"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_400_${IB}_GTESTCUMUL1_ACCRET.dat 500 1"
SORT_O="${EST_DLCUMGTAAR_IBNR_FUTCLAIMS} 500 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT
/CONDITION COND_IBNR_FUTURECLAIMS ( ACMTRS_NT = "309" OR  ACMTRS_NT = "320" )  
/CONDITION COND_ULAE_FUTURECLAIMS TYP_CT= "A" AND 
                                 (ACMTRS_NT = "301" OR ACMTRS_NT = "303" OR ACMTRS_NT = "307" OR ACMTRS_NT = "309" OR ACMTRS_NT = "316" OR ACMTRS_NT = "320" ) 
/OUTFILE ${SORT_O}
/INCLUDE COND_IBNR_FUTURECLAIMS
/OUTFILE ${SORT_O2}
/INCLUDE COND_ULAE_FUTURECLAIMS
exit
EOF
SORT


NSTEP=${NJOB}_520
#-----------------------------------------------------------------------------
LIBEL="SORT FULAERAT by ledger"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FULAERAT}"
SORT_O="${DFILT}/${NSTEP}_${IB}_FULAERAT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:
/KEYS SSD_CF,
      ESB_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_530
#-----------------------------------------------------------------------------
LIBEL="SORT GTESTCUMUL1_ACCRET_ULAE by ledger"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_500_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:
/KEYS SSD_CF,
      ESB_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_550
#------------------------------------------------------------------------------
LIBEL="ULAE AGREGATES CALCULATION "
PRG=ESTC1070A
export ${PRG}_I1=${DFILT}/${NJOB}_530_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat # Perimetre Accept ou retro selon valeur ACCRET
export ${PRG}_I2=${DFILT}/${NJOB}_520_${IB}_FULAERAT.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTESTCUMUL1_ACCRET_ULAE.dat # ULAE aggregates (aggregates x ratio)
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LEDGER_wo_ULAE.dat # log missing ledger rates
EXECPRG

#[023]add new columns
NSTEP=${NJOB}_800
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES TOTAL GENERAL+ULAE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_400_${IB}_GTESTCUMUL1_ACCRET.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_550_${IB}_ESTC1070A_GTESTCUMUL1_ACCRET_ULAE.dat 500 1"
SORT_O="${EST_DLCUMGTAAR} 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT 
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

JOBEND

