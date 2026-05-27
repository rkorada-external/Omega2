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
#[035 From ESID3702A] 02/04/2020 JYP SPIRA 92591: AE assumed , at inception
#[036 From ESID3702A] 12/04/2020 JYP SPIRA 92591: AE assumed , at inception
#[037 From ESID3702A] 12/04/2020 JYP SPIRA 92591: AE assumed , at inception
#[038 From ESID3702A] 20/04/2021 JYP SPIRA 92591: AE assumed , at inception bugfix
#[039 From ESID3702A] 26/08/2021 JYP SPIRA 92591: AE retro , at inception bugfix
#[035] 02/11/2020 M.NAJI SPIRA 91421  : optimisation, isolement des steps pour les mettre dans une chaine à part  
#[040] 14/04/2022 Dad spira : 103830 fix PARALLEL_INIT parameter
#[041] 19/04/2022 RC SPIRA 101543: Le EST_FTECLEDASII n'est plus pris dans le tri step 20 pour POSE et POCE
#[042] 07/07/2022 JYP SPIRA 105397: add a specific sort for transition file
#[043] 08/09/2023 MZM : SPIRA 109430 IO DUM : MERGE CASHFLOWS PREVIOUS DUMMY AND NEW DUMMY GENERATE FROM ESFD3610 IDF_CT =  I17G/L/P/S_CSF_MRG_INI
#[044] 18/04/2025 MZM : SPIRA 112870 BBNI- Undiscounted future transactions mapping
#[045] 17/07/2025 MZM : US 6065 BBNI- Missing 1A46060G
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


##[043]

if [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17S" ]
then
   NORME_SUFFIX=I
fi   
if [ "${NORME_CF}" = "I17L" ]
then
   NORME_SUFFIX=M
fi   
if [ "${NORME_CF}" = "I17P" ]
then
   NORME_SUFFIX=K      
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> NORME_SUFFIX ..............: ${NORME_SUFFIX} "
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}  "
ECHO_LOG "#===> PATTYP_CT..................: ${PATTYP_CT}  "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> PARM_IS_TRN ...............: ${PARM_IS_TRN} "
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
ECHO_LOG "#==> EST_DLDGTAA_DLSGTAA       ........:  $EST_DLDGTAA_DLSGTAA		      "
ECHO_LOG "#==> EST_DLDGTAR_DLSGTAR       ........:  $EST_DLDGTAR_DLSGTAR              "
ECHO_LOG "#========================================================================="


## [044]

if [ "${IDF_CT}" = "EBS_ESPD3610_BBNI" ]  
then	

## TRANSCODIFICATION DES TRNCOD BBNI ==> EBS STD 


NSTEP=${NJOB}_01
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1AxxxxxG' en EBS '1Axxxxx2'' "
AWK_I="${EST_DLSGTAA}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_DLSGTAA.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A10001G") { \$6 = "1A100012"; }  
if (\$6 == "1A10062G") { \$6 = "1A100022"; }  
if (\$6 == "1A14061G") { \$6 = "1A120062"; }  
if (\$6 == "1A12001G") { \$6 = "1A120012"; }  
if (\$6 == "1A12007G") { \$6 = "1A120052"; }  
if (\$6 == "1A49461G") { \$6 = "1A494302"; }  
if (\$6 == "1A49462G") { \$6 = "1A200712"; }   
if (\$6 == "1A41101G") { \$6 = "1A416012"; }  
if (\$6 == "1A12161G") { \$6 = "1A121212"; } 
if (\$6 == "1A46060G") { \$6 = "1A461112"; }


#####

##if (\$6 == "1A120052") { \$6 = "1A12007G";}
##if (\$6 == "1A120072") { \$6 = "1A12007G";}
##if (\$6 == "1A461112") { \$6 = "1A46060G";}
###
 

 print \$0; 

  }
exit
EOF
AWK

 
EXECKSH "cp  ${DFILT}/${NJOB}_01_${IB}_AWK_EST_DLSGTAA.dat ${EST_DLSGTAA}"


NSTEP=${NJOB}_03
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '2AxxxxxG' en EBS '2Axxxxx2'' "
AWK_I="${EST_DLSGTAR}"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_EST_DLSGTAR.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A10001G") { \$6 = "2A100012"; }  
if (\$6 == "2A10062G") { \$6 = "2A100022"; }  
if (\$6 == "2A14061G") { \$6 = "2A120062"; }  
if (\$6 == "2A12001G") { \$6 = "2A120012"; }  
if (\$6 == "2A12007G") { \$6 = "2A120052"; }  
if (\$6 == "2A49461G") { \$6 = "2A494302"; }  
if (\$6 == "2A49462G") { \$6 = "2A200712"; }   
if (\$6 == "2A41101G") { \$6 = "2A416012"; }  
if (\$6 == "2A12161G") { \$6 = "2A121212"; }  

 print \$0; 

  }
exit
EOF
AWK

  
EXECKSH "cp  ${DFILT}/${NJOB}_03_${IB}_AWK_EST_DLSGTAR.dat ${EST_DLSGTAR}"

fi





## [043]

if [ "${IDF_CT}" = "I17G_CSF_MRG_INI" ] || [ "${IDF_CT}" = "I17S_CSF_MRG_INI" ] || [ "${IDF_CT}" = "I17L_CSF_MRG_INI" ] || [ "${IDF_CT}" = "I17P_CSF_MRG_INI" ]  
then	

## TRANSCODIFICATION DES TRNCOD INI ==> STD 

ECHO_LOG "#==> ESF_DLDGTR_P       ........:  ${ESF_DLDGTR_P}              " 

NSTEP=${NJOB}_05
# Creation d'un fichier AT STD avec TRNCOD INI
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD de Norme INI  vers STD:  '21xxxxxI' en  '2Axxxxx2'"
AWK_I=${ESF_DLDGTR_P}
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DLDGTR_P.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2110061${NORME_SUFFIX}") { \$6 = "2A100012" ; }
if (\$6 == "2110062${NORME_SUFFIX}") { \$6 = "2A100022" ; }
if (\$6 == "2149461${NORME_SUFFIX}") { \$6 = "2A494302" ; }
if (\$6 == "2112061${NORME_SUFFIX}") { \$6 = "2A120012" ; }
if (\$6 == "2112062${NORME_SUFFIX}") { \$6 = "2A120052" ; }
if (\$6 == "2112063${NORME_SUFFIX}") { \$6 = "2A120072" ; }
if (\$6 == "2114061${NORME_SUFFIX}") { \$6 = "2A120062" ; }
if (\$6 == "2149462${NORME_SUFFIX}") { \$6 = "2A200712" ; }
if (\$6 == "2112161${NORME_SUFFIX}") { \$6 = "2A121212" ; }

                                                            
 print \$0; 
  }
exit
EOF
AWK

fi


NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
if [ "$PARM_IS_TRN" = "YES" ]  #specific transition project 
then 

LIBEL="TRANSITION : Sort assumed PERICASE for CTRGRO  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 2000 1"                                   
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_${IDF_CT}_$$.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF      1:1 - 1:EN,
        CTR_NF      3:1 -  3:,
        END_NT      4:1 -  4:,
        SEC_NF      5:1 -  5:,
        UWY_NF      6:1 -  6:,
        UW_NT       7:1 -  7:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT
else  # case non-transition 
LIBEL="PARM_IS_TRN=$PARM_IS_TRN : assumed PERICASE for CTRGRO  "
EXECKSH_MODE=P
EXECKSH "cp ${EST_IADPERICASE} ${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_${IDF_CT}_$$.dat "

fi 


PARALLEL_INIT 4

NSTEP=${NJOB}_20
# when called by Q3 EBS
if [ "${CONTEXT_CT}" = "" ] 
then
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
SORT_I="${EST_DLDGTAA} 1000 1"
SORT_I2="${EST_DLSGTAA} 1000 1"
SORT_I3="${EST_CURGTA} 1000 1"
#SORT_I4="${EST_DLSGTAASII} 1000 1"  # on ne peut prendre 2 fois les ecritures de service du ESPD1800 - RC
#SORT_I4="${EST_FTECLEDASII} 1000 1" #[041]
SORT_O="$EST_DLSIIGTAA 1000 1"
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
/CONDITION COND_TRNCOD ( ( TRNCOD1_CF = "1" AND "1357" NC TRNCOD8_CF )
                   AND  ( BALSHEY_NF = "${ICLODAT_A}" AND BALSHRMTH_NF <= ${ICLODAT_M} )
                   AND  ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" AND TRNCOD3_CF != "1008" )
                   AND  ( TRNCOD4_CF != "49413" AND TRNCOD4_CF != "46000" AND TRNCOD4_CF != "20053" AND TRNCOD4_CF != "20910" AND TRNCOD4_CF != "46002")
                   AND  ( ("246" CT TRNCOD8_CF AND "1A" CT TRNCOD2_CF) OR "4EG" CT TRNCOD2_CF OR "0" CT TRNCOD8_CF)
                   AND  ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND  ( (TRNCOD34_CF != '81' AND TRNCOD34_CF != '84' ) or ( TRNCOD2_CF="G" AND (TRNCOD34_CF = '81' OR TRNCOD34_CF = '84' ))  ) 
                   OR   ( "$IDF_CT" = "I17G_CSF_MRG_INI"  OR   "$IDF_CT" = "I17S_CSF_MRG_INI"  OR   "$IDF_CT" = "I17P_CSF_MRG_INI" OR  "$IDF_CT" = "I17L_CSF_MRG_INI"   )  )
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

 

#-----------------------------------------------------------------------------
LIBEL="AT INCEPTION : GTA AGREGATES Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA_DLSGTAA} 1000 1"
SORT_O="$EST_DLSIIGTAA 1000 1"
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
#[014] [024] [030] [043]  OR  ( "$IDF_CT" = "I17G_CSF_MRG_INI"  OR   "$IDF_CT" = "I17S_CSF_MRG_INI"  OR   "$IDF_CT" = "I17P_CSF_MRG_INI" OR  "$IDF_CT" = "I17L_CSF_MRG_INI"   ) 
#-----------------------------------------------------------------------------
LIBEL="GTAR AGREGATES Merge and sort of dGTAR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CURGTA} 1000 1"
SORT_I2="${EST_DLREGTAR} 1000 1"
SORT_I3="${EST_DLREMAJGTAR} 1000 1"

SORT_I5="${EST_FTECLEDASII} 1000 1"
if [ "${IDF_CT}" = "I17G_CSF_MRG_INI" ] || [ "${IDF_CT}" = "I17S_CSF_MRG_INI" ] || [ "${IDF_CT}" = "I17L_CSF_MRG_INI" ] || [ "${IDF_CT}" = "I17P_CSF_MRG_INI" ]  
then 
SORT_I6="${DFILT}/${NJOB}_05_${IB}_AWK_DLDGTR_P.dat  1000 1"
else
SORT_I6="${ESF_DLDGTR_P} 1000 1"
fi
SORT_I7="${EPO_DLDGTAR_E} 1000 1"  # [030]
SORT_I8="${EST_DLDGTAR_DLSGTAR} 1000 1"
SORT_O="${EST_DLSIIGTAR} 1000 1"
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
/CONDITION COND_TRNCOD (( TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} )
                   AND ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" AND TRNCOD3_CF != "1008" )
                   AND ( TRNCOD4_CF != "49413" AND TRNCOD4_CF != "46000" AND TRNCOD4_CF != "20053" AND TRNCOD4_CF != "20910" AND TRNCOD4_CF != "46002")
                   AND ( ( ("246" CT TRNCOD8_CF AND "1A" CT TRNCOD2_CF) OR "4EG" CT TRNCOD2_CF OR "0" CT TRNCOD8_CF)   )
                   AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND ( (TRNCOD34_CF != '81' AND TRNCOD34_CF != '84' ) or ( TRNCOD2_CF="G" AND (TRNCOD34_CF = '81' OR TRNCOD34_CF = '84' ))  )   )
                    )
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


NSTEP=${NJOB}_35
#Comparison of period closing and segmentation perimeters
#(by the contract grouping file)
#-----------------------------------------------------------------------------
LIBEL="Extract SEG_NF information from ctrgro and put it into Pericase"
PRG=ESTM1004
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE_${IDF_CT}_$$.dat
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRGRO_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO_O.dat
export ${PRG}_O3="${EST_IADPERICASE_CTRGRO}"
PARALLEL EXECPRG



PARALLEL_END




JOBEND

