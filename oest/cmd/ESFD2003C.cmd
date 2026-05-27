#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESID2003A.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 31/05/2012
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2220.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 18/04/2012 Roger Cassis :spot:23802 - Modifications pour Solvency
#[002] 31/07/2012 Lalatiana Rakotozafy  :spot:24041  - Modifications pour Solvency
#[003] 02/08/2012 -=Dch=-  :spot:24041 - Modifs techniques Solvency
#[004] 31/08/2012 R. Cassis meme spot  - Modifs techniques Solvency
#[005] 02/08/2012 -=Dch=-  :spot:24041 - Modifs techniques Solvency Ajout du paramètre ICLODAT_D pour ESTC1054
#                                        Autres modifs
#[006] 25/10/2012 JF VDV : [24041] - Modifications pour Solvency
#[008] 20/01/2013 -=PhP=-   :spot:24698 -   corrections pour la conso
#[009] 13/02/2013 -=PHP=-   :spot:24836  Corrections solvency 2
#[010] 30/09/2015 -=PHP=-   :spot:28941  Corrections postes Solvency créés à tort
#[011] 22/03/2016 Florent   :spot:29066  Formatage du fichier GLT
#[012] 14/04/2016 -=Dch=-   :spot:30465  Ajout pour le ESID8050 (Futures EBS)
#[013] 04/05/2016  SAS      :spot:30534  EBS - Futures Premiums (42511) & Charges(42512)
#[014] 26/05/2016 S.Behague :spot 30583: Spira 41148
#[015] 14/06/2016 S.ASKRI   :spot 30534: Spira 42512 Futures charges
#[016] 21/06/2016 -=Dch=-   :spot:30534  Modification des conditions du step 90
#[017] 07/07/2016 Florent   :spot:30890  EBS - Correction sur le calcul des futures pour traités NP
#[018] 07/04/2016 Florent   :spira:38697 ajustement pour écart entre IFRS et EBS programme ESTC1054
#[019] 23/07/2018 JYP       :spira:69871 migration to IFRS17 context2 , ESID2000 and ESPD2000 revamped in 3 new batch chains 
#[020] 11/09/2018 JYP       :IFRS17 req 10.6 req 10.1 : rename ESTC1064 by ESTC1065 
#[021] 19/10/2018 MZM       Spira:67650:IFRS17 REQ 10.4 REQ 10.5 : Future Fixed, Variables Premium, Future Brokerage, Future Claims
#[022] 20/02/2019 JYP :spira:69871  : IFRS17 req 10.6 req 10.1: new UPR_DAC file 
#[023] 26/02/2019 JYP :spira:69871  : IFRS17 req 10.6 req 10.1: bugfix UPR_DAC file 
#[024] 13/03/2019 MZM :spira:67650  : Future Variables Premium et Charges, Future Brokerage : Prise en compte des nouveaux TRNCODS "1A120022" ; "1A120032" ; "1A100022"
#[025] 10/04/2019 MZM :spira:74456  : Future Brokerage - Amount calculated incorrect  : Ajout du STEP 165, TRI du FICHIER FLOARAT
#[026] 17/05/2019 MZM :spira:77696  : REQ 10.4 - missing or incorrect future fixed commission ; Seul le poste ACMTRS_NT 10100 est utilisée pour les CHARGES
#[027] 02/08/2019 RAF :spira:77465  : REQ.10.12 - loss corridor
#[028] 08/07/2019 RC  :spira:68628 Ajoutparm dans parametre dans ESTC1054 FUTUR_CT Y/N
#[029] 30/08/2019 MZM :spira:70537 FUTURE AT INCEPTION : Prise en compte de la norme dans le calcul des FUTURE AT INCEPTION
#[030] 04/09/2019 RC  :spira:63929-79427 plus besoin du fichier FCLIENT pour le programme ESTC1054
#[031] 20/09/2019 RC  :spira:65656 - suite : Gestion PRS_CF pour IFRS4 ou EBS - ajout parametre PRS_CF dans divers programmes
#[032] 22/10/2019 RC  :spira:81934 - retire commentaire apres else
#[033] 24/10/2019 RC  :spira:81934 Maintenant on met l'IDFCT dans les noms de job au lieu du TYPEINV pour qu'ils soient bien reconnus dans le ESFD2003C.
#[034] 09/12/2019 RC  :spira:81496 Mise a jour de l'etablissement dans fichier FSTAT a partir de PERICASE
#[035] 14/01/2020 RC  :spira:65656 On remplace le montant IBNR de type Force apres le calcul du Delta
#[036] 03/02/2020 RC  :spira:84254 On remet le fichier FCLIENT dans le step du prog ESTC1054
#[037] 04/02/2020 JYP :spira:83851 closing at inception: bugfix date ESTC1019
#[038] 06/02/2020 MZM :spira:83722 Future Profit Commission formula : Appel du ESTC1019 apres le calcul des FUTURE Premiums
#[038] 11/02/2020 MZM :spira:82279 SPLIT DES FUTURES ESTC1065 --> ESTC1067 et ESTC1068
#[039] 24/02/2020 MZM :spira:82420 TRNCOD Standard At INCEPTION pour LOSS CORRIDOR
#[035] 21/02/2020 RC  :spira:65656 Finalement on ne reforce plus le mpontant IBNR, on retire les steps 201 a 204
#[036] 06/04/2020 JYP :spira:85691 bugfix EBS wrong PB - regression req 10.12
#[037] 10/04/2020 RC  :spira:81496 Modif technique de report de code sur spira 81496
#[038] 30/04/2020 MZM :spira:82761 Ajout de l'IDF_CT dans les inputs du calcul de Floarat et definition de la colonne ACMAMT_M pour format GTE
#[039] 14/05/2020 R. Cassis :spira:87041 On ne force pas l'etablissement a partir du Pericase si poste retro
#[040] 25/05/2020 MZM :spira:86500 Future Sliding Scale - Regression : 1A100012 --> 1A100013 qui contient la valeur (FUTURE_FIXE_PRM - UPR)
#[041] 14/07/2020 KBAGWE       :spira:81022 - NDIC floarat file genration step:_163
#[042] 31/07/2020 MZM :spira:88836 IFRS 17 - REQ 11.07 - Tax rate not applied when section >= 10 : Ajout du step 164, Tri du fichier IADPERIFCT sur No SECTION
#[043] 06/08/2020 MZM :spira:82420 IFRS 17 - REQ 11.07 - Transform NORME EBS En I17 AT INI
#[044] 14/08/2020 KBAGWE       :spira:81022 - NDIC floarat file genration step:215
#[045] 14/08/2020 NLD :spira:82420 IFRS 17 - REQ 11.07 - Transform NORME EBS En I17 AT INI, reverse of [43] 
#[046] 17/08/2020 MiS :spira:87933 Ajout fichier d'entrée ESTC1067
#[047] 08/09/2020 MZM :spira:89708 EBS - Estimates split : Tri du Fichier ${EST_DLCUMGTAATOT}
#[048] 11/09/2020 MZM :spira:82761 INI - TRI Des Fichies PRM et CLM intermediaire sur No Section AVANT Appel ESTC1016 ; 
#[049] 14/09/2020 MZM :spira:82761 INI - Variable Premiums - Regression TRI du IADPERIFCI  et supp TRNCOD INT AVNT Appel ESTC1054  
#[050] 21/09/2020 MZM :spira:90000 REQ 11.07 - IFRS 17 - Issues on some contracts in initial loss corridor calculation : Tri du Fichier ${EST_DLCUMGTAATOT}
#[051] 01/10/2020 MZM :spira:88836 IFRS 17 - REQ 11.07 - Tax rate not applied when section >= 10 : Ajout du parametre CHAIN pour trie par No Section Numerique si CHAIN = ESFD2220
#[052] 04/12/2020 HR  :spira:91121 addition of merge step - ESTC1067 DLCUMGTAATOT file  
#[053] 07/12/2020 NLD :spira:91536 Pericase INI, remove EPO_OIADVPERICASE
#[054] 15/01/2021 M.NAJI :spira:91531 Correction de $CRE_D par $PARM_CRE_D
#[055] 21/09/2020 MZM :spira:90000 REQ 11.07 - IFRS 17 - Issues on some contracts in initial loss corridor calculation : Tri du Fichier ${EST_DLCUMGTAATOT} Sur No Section
#[056] 10/03/2021 JYP:spira:94556 - manage mode EBS when microAOC
#[057] 23/03/2021 MZM :spira:95046 Suppression des TRNCOD "9L430003", "9L430002" "9L430102" "9L430602" en sortie du calcul des DAC ; Tri sur ENDORSEMENT END
#[058] 29/03/2021 MZM :spira:91121 Tri sur ENDORSEMENT END ; Et Ajout du fichier ESF_DLSGTAA dans le Mapping
#[059] 04/12/2020 HR  :spira:91121 addition of merge step 158 ; 160  - ESTC1067 DLCUMGTAATOT file
#[060] 13/03/2021 JYP :spira:94556 - manage mode EBS when microAOC
#[061] 28/04/2021 MZM :spira:91531 Ajout du fichier permanent ESF_FUTURE_FLOARAT des taux de charges des FUTURES
#[062] 27/07/2021 NLD :spira:95950 fix sort length
#[063] 18/08/2021 MZM :spira:95950 Ajout du fichier ESF_DLSGTAA et touch sur ce fichier
#[064] 29/09/2021 MZM :spira:98285 : UAT- TC sans contrepartie : Ne plus generer les TRNCOD "1A430602"  AND TRNCOD_CF != "1A120212"
#[065] 19/04/2022 RC  :spira:101543 Ajout du TYPEINV dans les noms de fichiers avec nom de job.
#[066] 12/08/2024 MZM :spira:111454 - I17 - Retro P - Incorrect NDIC PC calculation when underlying is internal assumed
#==========================================================================================================================
#set -x

# ***************************************************************************************
# ***************************************************************************************
#
# PHP rajouter fusion des EBS et IFRS pour fichiers FPRMLOA, FLOARAT et FT
#
# ESPT0000_DLDGTAA_IFRS  EN SORTIE DU ESID2000/ESID2002I   EST_DLDGTAA taux 'A'
# ESPT0000_DLDGTAA_EBS   EN SORTIE DU ESID2000/ESID2002E
#
# ESPD2000_DLDGTAA_EBS  EN SORTIE DU ESPD2000/ESID2002E    EST_DLDGTAA_EBSSO
# ESPD2000_DLDGTAA      EN SORTIE DU ESPD2000/ESID2003     EST_DLDGTAASO
#
# ***************************************************************************************
# ***************************************************************************************

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# Parameters
TYPEINV=$1
ICLODAT_D=$2

ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`

UWY_MIN=2

MIN_ICLODAT_A=`expr ${ICLODAT_A} - ${UWY_MIN}`

#[031]
if [ "${NORME}" = "IFRS" ]
then
	PRS=710
else
  # EBS 
	PRS=730
fi  

if [ "$NORME2" != "" ]  # mode double norme
then
   CLOSING_MODE="$NORME2"
else
   CLOSING_MODE="$NORME_CF"
fi


#[063]
if [ ! -f ${ESF_DLSGTAA} ]
then
	touch ${ESF_DLSGTAA}
fi

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> NORME2.....................: ${NORME2}"
ECHO_LOG "#===> CLOSING_MODE ..............: ${CLOSING_MODE}"
ECHO_LOG "#===> IDF_CT.....................: ${IDF_CT}"
ECHO_LOG "#===> PARM_ICLODAT_D ............: ${PARM_ICLODAT_D}  "
ECHO_LOG "#===> PARM_CLODAT_D .............: ${PARM_CLODAT_D}  "
ECHO_LOG "#===> ICLODAT_D .................: ${ICLODAT_D}"
ECHO_LOG "#===> ICLODAT_A .................: ${ICLODAT_A}"
ECHO_LOG "#===> ICLODAT_M .................: ${ICLODAT_M}"
ECHO_LOG "#===> ICLODAT_J .................: ${ICLODAT_J}"
ECHO_LOG "#===> MIN_ICLODAT_A .............: ${MIN_ICLODAT_A}"
ECHO_LOG "#===> PRS .......................: ${PRS}"
ECHO_LOG "#===> ESF_DLSGTAA .......................: ${ESF_DLSGTAA}"
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> EST_NDIC_FLOARAT .......................: ${EST_NDIC_FLOARAT}"
ECHO_LOG "#===> ESF_FUTURE_FLOARAT.........: ${ESF_FUTURE_FLOARAT}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_130
#[012]
#[015]
#[026] /CONDITION CHARGES (ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000')
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount of intermediary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_125_${IB}_ESTC3604_FSTAT_O.dat 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESFD2003B00${IDF_CT}${TYPEINV}_125_${IB}_ESTC3604_FSTAT_O_00.dat 1000 1"
SORT_I3="${DFILT}/${NCHAIN}_ESFD2003B01${IDF_CT}${TYPEINV}_125_${IB}_ESTC3604_FSTAT_O_01.dat 1000 1"
SORT_I4="${DFILT}/${NCHAIN}_ESFD2003B02${IDF_CT}${TYPEINV}_125_${IB}_ESTC3604_FSTAT_O_02.dat 1000 1"
SORT_I5="${DFILT}/${NCHAIN}_ESFD2003B03${IDF_CT}${TYPEINV}_125_${IB}_ESTC3604_FSTAT_O_03.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF         1:1 -  1:,
        END_NT         2:1 -  2:,
        SEC_NF         3:1 -  3:,
        UWY_NF         4:1 -  4:,
        UW_NT          5:1 -  5:,
        ACMTRS_NT      6:1 -  6:,
        COD_CT         7:1 -  7:,
        AMT_M          8:1 -  8:EN 15/3,
        CUR_CF         9:1 -  9:,
        SSD_CF        10:1 - 10:,
        ESB_CF        11:1 - 11:,
        BALSHEY_NF    12:1 - 12:,
        CED_NF        13:1 - 13:,
        BRK_NF        14:1 - 14:,
        PAY_NF        15:1 - 15:,
        KEY_NF        16:1 - 16:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_NT
/SUMMARIZE TOTAL AMT_M
/CONDITION PREMIUM (ACMTRS_NT='10000')
/CONDITION PREMPTF (ACMTRS_NT='10010' OR ACMTRS_NT= '10020')
/CONDITION PNA     (ACMTRS_NT='10030')
/CONDITION CHARGES (ACMTRS_NT='10100')
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD STRVIDE "~"
/DERIVEDFIELD OCCYEA_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD ACY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD SCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD FILLER18 18"~"
/DERIVEDFIELD FILLER15 15"~"
/DERIVEDFIELD ORICOD_LS "EBSPRM"
/DERIVEDFIELD AJOUT14COL 14"~"
/DERIVEDFIELD TRNCOD_CF_NEW if PREMIUM then "1A110002~" else if PREMPTF then "1A110003~" else if PNA then "1A100002~" else if CHARGES then "1A120002~" else "1A130002~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/CONDITION ACMTRS_FUTURES (ACMTRS_NT='10000' OR ACMTRS_NT='10010' OR ACMTRS_NT='10020' OR ACMTRS_NT='10030' OR ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000')
/OUTFILE ${SORT_O}
/INCLUDE ACMTRS_FUTURES
/REFORMAT
   SSD_CF
  ,ESB_CF
  ,BALSHEY_NF_NEW
  ,BALSHRMTH_NF_NEW
  ,BALSHRDAY_NF_NEW
  ,TRNCOD_CF_NEW
  ,STRVIDE
  ,CTR_NF
  ,END_NT
  ,SEC_NF
  ,UWY_NF
  ,UW_NT
  ,OCCYEA_NF_NEW
  ,ACY_NF_NEW
  ,SCOSTRMTH_NF_NEW
  ,SCOENDMTH_NF_NEW
  ,STRVIDE
  ,CUR_CF
  ,AMT_MC
  ,CED_NF
  ,BRK_NF
  ,PAY_NF
  ,KEY_NF
  ,FILLER18
  ,FILLER15
  ,ORICOD_LS
  ,AJOUT14COL
exit
EOF
SORT

#[034]
NSTEP=${NJOB}_131
#------------------------------------------------------------------------------
LIBEL="Get ESB from Pericase to DLDGTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_SORT_DLDGTAA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        all_cols1        1:1 - 71:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT 
/INFILE ${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_20_${IB}_SORT_IADPERICASE.dat 1000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT 
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
       ,rightside:PER_ESB_CF
exit
EOF
SORT

#[034] [039]
NSTEP=${NJOB}_132
#------------------------------------------------------------------------------
LIBEL="Replace ESB from Pericase to DLDGTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_131_${IB}_SORT_DLDGTAA.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -   1:,
        ESB_CF           2:1 -   2:,
        TRNCOD1_CF       6:1 -   6:1,
        CTR_NF           8:1 -   8:,
        END_NT           9:1 -   9:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        UW_NT           12:1 -  12:,
        all_cols1        3:1 -  71:,
        PER_ESB_CF      72:1 -  72:
/CONDITION blanc PER_ESB_CF = "" OR TRNCOD1_CF = "2" OR TRNCOD1_CF = "4"
/DERIVEDFIELD PER2_ESB_CF if blanc then ESB_CF else PER_ESB_CF
/OUTFILE   ${SORT_O}
/REFORMAT SSD_CF, PER2_ESB_CF, all_cols1
exit
EOF
SORT

#[037]
NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : Fusion des EBSACC et DLDGTAA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_100_${IB}_SORT_DLDGTAA_EBSACC.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_132_${IB}_SORT_DLDGTAA.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAA.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:                                         
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:EN
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:EN
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,ORICOD_LS       57:1 - 57:
       ,FILLER1          1:1 - 18:
       ,FILLER2         20:1 - 71:
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,ORICOD_LS
      ,TRNCOD_CF
      ,CUR_CF
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1
         ,AMT_MC
         ,FILLER2
exit
EOF
SORT


#[047] ${EST_DLCUMGTAATOT}
NSTEP=${NJOB}_152
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_DLCUMGTAATOT file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLCUMGTAATOT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAATOT_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DAC_DLCUMGTAATOT_O2.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        TRNCOD_CF          6:1 - 6:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:EN,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:
/KEYS 	CTR_NF,
      	END_NT,
      	SEC_NF,
      	UWY_NF,
      	UW_NT
/OUTFILE ${SORT_O}      	
exit
EOF
SORT



#[0592 [049] #[058] Tri du fichier EST_IADPERIFCI ; END_NT Numerique
NSTEP=${NJOB}_154
#-----------------------------------------------------------------------------
LIBEL="EST_IADPERIFCI file sort in progress...  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCI} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFCI_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:EN,
        SEC_NF       3:1 -  3:EN,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

#[049] Tri du fichier EST_IADPERIFR 
NSTEP=${NJOB}_156
#-----------------------------------------------------------------------------
LIBEL="EST_IADPERIFR file sort in progress...  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:EN,
        SEC_NF       3:1 -  3:EN,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


#[059] Filter AE EBS
NSTEP=${NJOB}_158
#------------------------------------------------------------------------------
LIBEL="Filter UPR_DAC ..."
SORT_WDIR=${DFILT}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA_UPR_DAC} 1000 1"	
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_UPR_DAC.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -   1:,
        ESB_CF           2:1 -   2:,
        TRNCOD1_CF       6:1 -   6:1,
        TRNCOD2_CF       6:2 -   6:2,
        CTR_NF           8:1 -   8:,
        END_NT           9:1 -   9:EN,
        SEC_NF          10:1 -  10:EN,
        UWY_NF          11:1 -  11:,
        UW_NT           12:1 -  12:,
        all_cols1        3:1 -  71:,
        PER_ESB_CF      72:1 -  72:
/CONDITION FILTCOME TRNCOD1_CF = "1" AND TRNCOD2_CF = "4"
/OUTFILE   ${SORT_O}
/INCLUDE FILTCOME
exit
EOF
SORT

#[059] Merge with AE EBS
NSTEP=${NJOB}_159
LIBEL="Merge DLCUMGTAATOT with DLDGTAA_UPR_DA and sort ..."
SORT_WDIR=${DFILT}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_152_${IB}_SORT_DLCUMGTAATOT_O.dat 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_158_${IB}_SORT_DLDGTAA_UPR_DAC.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAATOT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF  1:1 -  1:,
        ESB_CF  2:1 -  2:,
        CTR_NF  8:1 -  8:,
        END_NT  9:1 -  9:EN,
        SEC_NF 10:1 - 10:EN,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE   ${SORT_O}
exit
EOF
SORT

#SORT_I2="${DFILP}/${ENV_PREFIX}_ESPD1800_DLSGTAASIISO.dat 1000 1"

#[052] Merge with AE EBS [055] #[058] [059] Tri sur No Section et END_NT numerique et Ajout Fichier via MAPPING
NSTEP=${NJOB}_160
LIBEL="Merge DLCUMGTAATOT with AE EBS and sort ..."
SORT_WDIR=${DFILT}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_159_${IB}_SORT_DLCUMGTAATOT_O.dat 1000 1"
SORT_I2="${ESF_DLSGTAA} 1000 1"   #[062] [063]
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAATOT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF  1:1 -  1:,
        ESB_CF  2:1 -  2:,
        CTR_NF  8:1 -  8:,
        END_NT  9:1 -  9:EN,
        SEC_NF 10:1 - 10:EN,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_162
#------------------------------------------------------------------------------ 
#[038] 
#[046]
LIBEL="FUTURES CALCULATIONS :  Calcul of future premium and charges and claim premium..."
PRG=ESTC1067
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
MIN_ICLODAT_A ${MIN_ICLODAT_A}
CLODAT_D ${ICLODAT_D}
NORME ${CLOSING_MODE}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_20_${IB}_SORT_IADPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_150_${IB}_SORT_DLGTAA.dat
export ${PRG}_I3=${EPO_FCURQUOT}
export ${PRG}_I4=${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_160_${IB}_SORT_SEGEST_SOLVENCY_O.dat
export ${PRG}_I5=${EPO_FBOPRSLNK}                                          
#export ${PRG}_I6=${EST_IADPERIFR}
export ${PRG}_I6=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_156_${IB}_SORT_IADPERIFR_O.dat
export ${PRG}_I7=${EST_DLDGTAA_UPR_DAC}
#export ${PRG}_I8=${EST_DLCUMGTAATOT} 
#export ${PRG}_I8=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_152_${IB}_SORT_DLCUMGTAATOT_O.dat
export ${PRG}_I8=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_160_${IB}_SORT_DLCUMGTAATOT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAA.dat  
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAA_ANO.log
export ${PRG}_O3=${EST_FUTURE_EBS}
export ${PRG}_O4=${EST_DLGTAUPUC} 
EXECPRG

NSTEP=${NJOB}_163
#------------------------------------------------------------------------------ 
#[038] Ajout de la colonne ACMAMT_M pour le format GTE en input du ESTC1016 
#[039] 1A100012 --> 1A100013 qui contient la valeur (FUTURE FIXE_PRM - UPR)
#[039] 1A100012 --> 1A100013 qui contient la valeur (FUTURE FIXE_PRM - UPR)
#[048] Tri des Fichiers CLAIMS et FUTURES FIXED PRM
LIBEL="FUTURES CALCULATIONS :  Generate FUTURE CLAIMS And Future PREMIUMS Files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${DFILT}/${NJOB}_162_${IB}_ESTC1067_DLGTAA.dat
SORT_I="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_162_${IB}_ESTC1067_DLGTAA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_PRM_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_CLM_O2.dat 1000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_LOSSCOR_O3.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        BALSHEY_NF         3:1 - 3:,
        BALSHRMTH_NF       4:1 - 4:,
        BALSHRDAY_NF       5:1 - 5:,
        TRNCOD_CF          6:1 - 6:,
        DBLTRNCOD_CF       7:1 - 7:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
				SEC_NF            10:1 - 10:EN,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:,
        OCCYEA_NF         13:1 - 13:,
        ACY_NF            14:1 - 14:,
        SCOSTRMTH_NF      15:1 - 15:,
        SCOENDMTH_NF      16:1 - 16:,
        CLM_NF            17:1 - 17:,
        CUR_CF            18:1 - 18:,
        AMT_M             19:1 - 19:EN 15/3,
        CED_NF            20:1 - 20:,
        BRK_NF            21:1 - 21:,
        PAY_NF            22:1 - 22:,
        KEY_NF            23:1 - 23:,
        RETCTR_NF         24:1 - 24:,
        RETEND_NT         25:1 - 25:,
        RETSEC_NF         26:1 - 26:,
        RTY_NF            27:1 - 27:,
        RETUW_NT          28:1 - 28:,
        RETOCCYEA_NF      29:1 - 29:,
        RETACY_NF         30:1 - 30:,
        RETSCOSTRMTH_NF   31:1 - 31:,
        RETSCOENDMTH_NF   32:1 - 32:,
        RCL_NF            33:1 - 33:,
        RETCUR_CF         34:1 - 34:,
        RETAMT_M          35:1 - 35:EN 15/3,
        PLC_NT            36:1 - 36:,
        RTO_NF            37:1 - 37:,
        INT_NF            38:1 - 38:,
        RETPAY_NF         39:1 - 39:,
        RETKEY_CF         40:1 - 40:,
        RETINTAMT_M       41:1 - 41:EN 15/3,
        ESTCUR_CF 				42:1 - 42:,
				ACMAMT_M 				  43:1 - 43:EN 15/3												    
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC AMT_M COMPRESS
/CONDITION FUTPRM ( TRNCOD_CF = "1A100013")
/CONDITION FUTCLM ( TRNCOD_CF = "1A494302")
/CONDITION FUTLOSSCOR (TRNCOD_CF = "1A100012" OR TRNCOD_CF = "1A494302"  )
/OUTFILE ${SORT_O}
/INCLUDE FUTPRM
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
					ESTCUR_CF,
          ACMAMT_MC        
/OUTFILE ${SORT_O2}
/INCLUDE FUTCLM
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
					ESTCUR_CF,
          ACMAMT_MC   
/OUTFILE ${SORT_O3}
/INCLUDE FUTLOSSCOR
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
					ESTCUR_CF,
          ACMAMT_MC                    
exit
EOF
SORT


#[042] Tri du fichier EST_IADPERIFCT 
NSTEP=${NJOB}_164
#-----------------------------------------------------------------------------
LIBEL="EST_IADPERIFCT file sort in progress...  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFCT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:EN,
        SEC_NF       3:1 -  3:EN,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


if [ "${CONTEXT_CT}" = "INI" ] # Closing at Inception
then
	PARAM_DATE=$PARM_ICLODAT_D
else
	PARAM_DATE=$PARM_CLODAT_D
fi

#[038]  PRS_CF ${PRS} #[051] Ajout du Parametre {CHAIN}
NSTEP=${NJOB}_165
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Compute of loading rates"
PRG=ESTC1016
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${PARM_CRE_D}
CLODAT_D ${PARAM_DATE}
CLOTYP_CT ${PARM_CLOTYP_CT}
PRS_CF ${PRS}
NDICFLG F
CHAIN ESFD2220
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_20_${IB}_SORT_IADPERICASE.dat
export ${PRG}_I2=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_164_${IB}_SORT_IADPERIFCT_O.dat       # ${EST_IADPERIFCT}
export ${PRG}_I3=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_154_${IB}_SORT_IADPERIFCI_O.dat       # ${EST_IADPERIFCI}
export ${PRG}_I4=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_163_${IB}_SORT_DLDGTAA_CLM_O2.dat 		 # CLM ${EST_DLCUMGTAAS}   
export ${PRG}_I5=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_163_${IB}_SORT_DLDGTAA_PRM_O.dat  		 # PRM ${EST_DLGTAAPA}	   
export ${PRG}_I6=${DFILP}/empty.dat	    
export ${PRG}_I7=${DFILP}/empty.dat   
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCTREST2_O1.dat				
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FLOARAT_O2.dat				 
EXECPRG  

# [038] TRI DU FICHIER ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FLOARAT_O2.dat
NSTEP=${NJOB}_167
#-----------------------------------------------------------------------------
LIBEL="Sort of FLOARAT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${DFILT}/${NJOB}_165_${IB}_ESTC1016_FLOARAT_O2.dat 
SORT_I="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_165_${IB}_ESTC1016_FLOARAT_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLOARAT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF      1:1 -  1:,
        END_NT      2:1 -  2:EN,
        SEC_NF      3:1 -  3:EN,
        UWY_NF      4:1 -  4:,
        UW_NT       5:1 -  5:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


#[061]
NSTEP=${NJOB}_167A
#-----------------------------------------------------------------------------
LIBEL="Copy FUTURE FLOARAT PERM FILE "
EXECKSH "cp ${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_167_${IB}_SORT_FLOARAT_O.dat ${ESF_FUTURE_FLOARAT}"
#---------------------------------------------------------------------------


#[037]

if [ "${CONTEXT_CT}" = "INI" ] # Closing at Inception
then
	PARAM_DATE=$PARM_ICLODAT_D
else
	PARAM_DATE=$PARM_CLODAT_D
fi

#[021] Fin IFRS17 req 10.4 et req 10.5 

# Debut req 10.12 [027]

#[031] [050] [055]
NSTEP=${NJOB}_170
#------------------------------------------------------------------------------ 
LIBEL="LOSS CORRIDOR CALCUL $CONTEXT_CT "
PRG=ESTC1019
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${PARM_CRE_D}
CLODAT_D ${PARAM_DATE}
CLOTYP_CF ${PARM_CLOTYP_CT}
NORME ${CLOSING_MODE}
PRS_CF ${PRS}
TYPE_CF F
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_20_${IB}_SORT_IADPERICASE.dat
#export ${PRG}_I2=${EST_IADPERIFCI} 
export ${PRG}_I2=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_154_${IB}_SORT_IADPERIFCI_O.dat
#export ${PRG}_I3=${EST_DLCUMGTAATOT} 
export ${PRG}_I3=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_152_${IB}_SORT_DLCUMGTAATOT_O.dat
export ${PRG}_I4=${EST_DLGTAAPA}
export ${PRG}_I5=${EST_DLCUMGTAA}
export ${PRG}_I6=${EST_CTRESTLOSPBPAP}
export ${PRG}_I7=${EST_FCURQUOT}
export ${PRG}_I8=${EST_FTHRHLDUWY}
#export ${PRG}_I9=${DFILT}/${NJOB}_162_${IB}_ESTC1067_DLGTAA.dat  # [035] Fichieer GT contenant tous les future PREMIUM et CLAIMS 
#export ${PRG}_I9=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_162_${IB}_ESTC1067_DLGTAA.dat  # [038][035] Fichieer GT contenant tous les future PREMIUM et CLAIMS 
export ${PRG}_I9=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_163_${IB}_SORT_DLDGTAA_LOSSCOR_O3.dat
export ${PRG}_I10=${EPO_FBOPRSLNK}
export ${PRG}_I11=${EST_DLDGTAA_UPR_DAC}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAAPBPAPLOS_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCTREST3_O2.dat
EXECPRG


#[039] /CONDITION I17 TRNCOD_CF = "1120071I" OR TRNCOD_CF = "1120071K" OR TRNCOD_CF = "1120071M"  -->
NSTEP=${NJOB}_172
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of GT file LOSS CORRIDOR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_170_${IB}_ESTC1019_DLGTAAPBPAPLOS_O1.dat 1000 1"    
SORT_I="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_170_${IB}_ESTC1019_DLGTAAPBPAPLOS_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDGTAAPBPAPLOS_REFORMAT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:,
        SCOENDMTH_NF     16:1 - 16:,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:,
        RETSCOENDMTH_NF  32:1 - 32:,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/CONDITION EBS TRNCOD_CF = "1A200712"
/CONDITION I17 TRNCOD_CF = "1A200712"
/CONDITION COND_PB_PAP TRNCOD_CF != "11150002"
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD ACMTRS_NT IF EBS THEN "3202~" ELSE IF I17 THEN "3202~" ELSE "~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD ACMTRS ACMTRS_NT COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD EMPTY "~"
/DERIVEDFIELD PLUS_30_CHAMPS 26"~"
/OUTFILE ${SORT_O}
/INCLUDE COND_PB_PAP
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
		  EMPTY,
		  EMPTY,
		  ACMTRS,
          PLUS_30_CHAMPS
exit
EOF
SORT

# Fin req 10.12 [027] 

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1068 "
ECHO_LOG "#===> Nombre de lignes futures generees "
wc -l ${DFILT}/${NJOB}_172_${IB}_ESTC1068_DLGTAA.dat
ECHO_LOG "#===> Nombre de lignes PLAS generees "
wc -l ${EST_DLDGTAA_CUMULS_COUR}
ECHO_LOG "#===> Nombre de lignes DLGTAUPUC generees "
wc -l ${EST_DLGTAUPUC}
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_175
# TRI ET FUSION DES FUTURE PRIME ET DES FUTURES LOSS CORRIDOR
#------------------------------------------------------------------------------ 
LIBEL="FUTURES CALCULATIONS : Merge and Sort  Calcul of future premium and future Loss Corridor..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_162_${IB}_ESTC1067_DLGTAA.dat 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_172_${IB}_DLDGTAAPBPAPLOS_REFORMAT.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAA_PRMLOSS.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:8,
        TRNCOD4_CF        6:1 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
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
        CED_NF           20:1 - 20:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_180
#------------------------------------------------------------------------------ 
#[020] [021] [029] NORME_CF [035] [038] [049]
LIBEL="FUTURES CALCULATIONS :  Calcul of future and charges Only ..."
PRG=ESTC1068
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
MIN_ICLODAT_A ${MIN_ICLODAT_A}
CLODAT_D ${ICLODAT_D}
NORME ${CLOSING_MODE}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_20_${IB}_SORT_IADPERICASE.dat
export ${PRG}_I2=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_175_${IB}_SORT_DLGTAA_PRMLOSS.dat
export ${PRG}_I3=${EPO_FCURQUOT}
export ${PRG}_I4=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_167_${IB}_SORT_FLOARAT_O.dat
export ${PRG}_I5=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_154_${IB}_SORT_IADPERIFCI_O.dat         #[021]# Recupere le tableau de charges iterees
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAA.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAA_ANO.log
export ${PRG}_O3=${EST_FUTURE_EBS}			 
EXECPRG 



# Suppression des TRNCOD temporaires (TRNCOD_CF != "1A100013" AND TRNCOD_CF != "1A100072"  AND TRNCOD_CF != "1A100002"  AND TRNCOD_CF != "9L100082"  AND TRNCOD_CF != "9L100092"  AND TRNCOD_CF !="1A120002"  AND TRNCOD_CF != "9L99999" AND TRNCOD_CF != "9L430003"  AND TRNCOD_CF != "9L430002" AND  TRNCOD_CF != "9L430102"  AND  TRNCOD_CF != "9L430602" AND TRNCOD_CF != "9L999992")
# TRI ET FUSION DES FUTURE PRIME, LOSS CORRIDOR ET DES FUTURES CHARGES
NSTEP=${NJOB}_185
#------------------------------------------------------------------------------ 
LIBEL="FUTURES CALCULATIONS : Merge and Sort  Calcul of future premium, claims, Loss Corridor and charges..."
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="PLAS + FUTURES :  Merge and Sort of PLAS + FUTURES GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA_CUMULS_COUR} 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_180_${IB}_ESTC1068_DLGTAA.dat 1000 1"
SORT_I3="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_175_${IB}_SORT_DLGTAA_PRMLOSS.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_NEW_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:8,
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
        FIN              42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION TEMP_FUTURES  (TRNCOD_CF != "1A100013" AND TRNCOD_CF != "1A100072"  AND TRNCOD_CF != "1A100002"  AND TRNCOD_CF != "9L100082"  AND TRNCOD_CF != "9L100092"  AND TRNCOD_CF !="1A120002"  AND TRNCOD_CF != "9L99999" AND TRNCOD_CF != "9L430003"  AND TRNCOD_CF != "9L430002" AND  TRNCOD_CF != "9L430102"  AND  TRNCOD_CF != "9L430602" AND TRNCOD_CF != "9L999992")
/OUTFILE ${SORT_O}
/INCLUDE TEMP_FUTURES
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
          FIN
exit
EOF
SORT
#[038] fin

#[028][030][036] [038]
NSTEP=${NJOB}_190
#-----------------------------------------------------------------------------
LIBEL="PLAS + FUTURES :  Create Ecart Data for EBS - IFRS file"
PRG=ESTC1054
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
ACCRET_CT A
FUTUR_CT Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_185_${IB}_SORT_DLDGTAA_NEW_O.dat
export ${PRG}_I2=${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_30_${IB}_SORT_DLDGTAA_PREC_O.dat
export ${PRG}_I3=${EST_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA_E.dat   # oricod EBSGTA postes transformés
EXECPRG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1054 "
ECHO_LOG "#===> Nombre de lignes ecart pour le GLT generees "
wc -l ${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA_E.dat
ECHO_LOG "#===> Nombre de lignes annulation des postes EBS précédents "
#wc -l ${DFILT}/${NJOB}_03_${IB}_AWK_DLAGTAA_EBS.dat
ECHO_LOG "#========================================================================="


## [064] Suppression des TRNCOD en sortie EBS "TRNCOD_CF != "1A430602"  AND TRNCOD_CF != "1A120212" --> A voir

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
LIBEL="PLAS + FUTURES : Creation of DLDGTAA_E file from GTA files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_190_${IB}_ESTC1054_DLDGTAA_E.dat 1000 1"
#annulation des postes EBS précédents
#SORT_I2="${DFILT}/${NJOB}_03_${IB}_AWK_DLAGTAA_EBS.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_E.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF        1:1 -  1:EN
       ,ESB_CF        2:1 -  2:EN
       ,BALSHEY_NF    3:1 -  3:
       ,BALSHRMTH_NF  4:1 -  4:EN
       ,BALSHRDAY_NF  5:1 -  5:EN
       ,TRNCOD_CF     6:1 -  6:
       ,DBLTRNCOD_CF  7:1 -  7:
       ,CTR_NF        8:1 -  8:
       ,END_NT        9:1 -  9:EN
       ,SEC_NF       10:1 - 10:EN
       ,UWY_NF       11:1 - 11:
       ,UW_NT        12:1 - 12:EN
       ,OCCYEA_NF    13:1 - 13:
       ,ACY_NF       14:1 - 14:
       ,SCOSTRMTH_NF 15:1 - 15:EN
       ,SCOENDMTH_NF 16:1 - 16:EN
       ,CLM_NF       17:1 - 17:
       ,CUR_CF       18:1 - 18:
       ,AMT_M        19:1 - 19:EN 15/3
       ,FILLER52     20:1 - 71:
/KEYS  SSD_CF
      ,ESB_CF
      ,BALSHEY_NF
      ,BALSHRMTH_NF
      ,BALSHRDAY_NF
      ,TRNCOD_CF
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/CONDITION MVTZERO ( AMT_M != 0 AND TRNCOD_CF != "1A430602"  AND TRNCOD_CF != "1A120212" )
/OUTFILE ${SORT_O}
/INCLUDE MVTZERO
/REFORMAT
   SSD_CF
  ,ESB_CF
  ,BALSHEY_NF
  ,BALSHRMTH_NF
  ,BALSHRDAY_NF
  ,TRNCOD_CF
  ,DBLTRNCOD_CF
  ,CTR_NF
  ,END_NT
  ,SEC_NF
  ,UWY_NF
  ,UW_NT
  ,OCCYEA_NF
  ,ACY_NF
  ,SCOSTRMTH_NF
  ,SCOENDMTH_NF
  ,CLM_NF
  ,CUR_CF
  ,AMT_MC
  ,FILLER52
exit
EOF
SORT


#[004] [035] [038]
NSTEP=${NJOB}_210
#Double entry transaction code addition in dDVGTAr
#-----------------------------------------------------------------------------
LIBEL="PLAS + FUTURES : Double entry transaction code addition in dDVGTAr in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_200_${IB}_SORT_DLDGTAA_E.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLDGTAA_E_TRNCODEBS}
EXECPRG

## [029] SI CLOSING AT INCEPTION les STEPS  210 ne sont plus pris en compte
if [ "${NORME_CF}" != "EBS" ] && [ "$CLOSING_MODE" != "EBS" ]
then
# EXECKSH "cp ${DFILT}/${NJOB}_185_${IB}_SORT_DLDGTAA_NEW_O.dat ${EST_DLDGTAA_E_TRNCODEBS}"
 EXECKSH "cp ${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_200_${IB}_SORT_DLDGTAA_E.dat ${EST_DLDGTAA_E_TRNCODEBS}"
fi

## [066]

NSTEP=${NJOB}_215
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Compute of NDIC loading rates"
PRG=ESTC1016
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${PARM_CRE_D}
CLODAT_D ${PARAM_DATE}
CLOTYP_CT ${PARM_CLOTYP_CT}
PRS_CF ${PRS}
NDICFLG T
CHAIN ESFD2220
exit
EOF
export ${PRG}_PRM=${FPRM}
##export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_20_${IB}_SORT_IADPERICASE.dat  
##export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD2003A${IDF_CT}${TYPEINV}_15_${IB}_SORT_IADPERICASE.dat     ##  [066]                     
export ${PRG}_I2=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_164_${IB}_SORT_IADPERIFCT_O.dat			 #export ${PRG}_I2=${EST_IADPERIFCT}
export ${PRG}_I3=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_154_${IB}_SORT_IADPERIFCI_O.dat       ##export ${PRG}_I3=${EST_IADPERIFCI}
export ${PRG}_I4=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_163_${IB}_SORT_DLDGTAA_CLM_O2.dat 		 # CLM ${EST_DLCUMGTAAS}   
export ${PRG}_I5=${DFILT}/${NCHAIN}_ESFD2003C${IDF_CT}${TYPEINV}_163_${IB}_SORT_DLDGTAA_PRM_O.dat  		 # PRM ${EST_DLGTAAPA}	   
export ${PRG}_I6=${DFILP}/empty.dat	    
export ${PRG}_I7=${DFILP}/empty.dat   
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCTREST2_O1_NOT_USED.dat				
export ${PRG}_O2=${EST_NDIC_FLOARAT}			 
EXECPRG  


JOBEND
