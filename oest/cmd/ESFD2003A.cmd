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
#[027] 08/07/2019 RC  :spira:68628 Ajoutparm dans parametre dans ESTC1054 FUTUR_CT Y/N
#[028] 26/07/2019 MZM :spira:78999 TNR - EBS - future calculation on closed contracts : Filtre du PERICASE :  on ne prend que les contrats non terminés SECACCSTS_CT != 9
#[029] 19/08/2019 TY  :spira:70268 EBS - Future - Take into account portfolio origin 253 - no estimates
#[030] 04/09/2019 RC  :spira:63929-79427 plus besoin du fichier FCLIENT pour le programme ESTC1054
#[031] 03/02/2020 RC  :spira:84254 On remet le fichier FCLIENT dans le step du prog ESTC1054
#[032] 06/02/2020 MZM :spira:83722 Future Profit Commission formula : Appel du ESTC1019 apres le calcul des FUTURE Premiums et
#[032] 06/02/2020 MZM :spira 82279 Split du ESTC1065--> ESTC1067 (Calcul Des Primes) et ESTC1068 (Calcul des Charges) --> FLOARAT est genere dans ESFD2003C
#[033] 11/02/2020 HR  :spira 81813 EBS - Future Charges - Change Transaction codes
#[034] 19/02/2020 MZM :spira 84675 Origin portfolio 253 - Future calculations change [ PER_UWORG_CF != 253 OU (PER_UWORG_CF] = 253 ET CED_NF = 38466) ]
#[035] 06/08/2020 MZM :spira:82420 IFRS 17 - REQ 11.07 - Transform NORME EBS En I17 AT INI
#[036] 31/08/2020 MZM :spira:87324 Dummy contract at INI (RETINT CTRRET_B = "0" OR PORTFOLIO = "248")  
#[037] 21/10/2020 RC  :spira:82746 Now POCI data are taken into POCE
#[038] 29/03/2021 MZM :spira:91121 AJOUT DU Fichier ESF_DLSGTAA (suppression du code en dur)
#[039] 04/06/2021 MZM :spira:82746 Now POCI data are taken into POCE ET Creation d'un fichier Vide si absent
#[040] 30/06/2021 MZM :spira:97413 IFRS17- Calculate future at INI on portofolio 253
#[041] 10/09/2021 MZM :spira:92861 Calculate future on contracts recognized during POS : Add step 08 to identify "contracts recognized during POS"
#[042] 25/10/2021 RC  :spira:99751 POCI data are taken with new POCE data not with POSE data
#[043] 26/10/2021 RC  :spira:84340 On ne prend pas les postes "1A100022" et "1A120422" dans le tri step00 pour POCE
#[044] 10/01/2022 MZM  	SPIRA : 91532  	Bug Fix : Taille Syncsort de 1000 ==> 2000
#[045] 18/01/2022 M.NAJI spira 101406 remonter les steps 00 et 60 dans ESFD2211 de la chaine ESID2210
#[046] 01/02/2021 MZM :spira:99909 Channel I17 exceptions : Idem pour I17 Origin portfolio 253 - Future calculations change [ PER_UWORG_CF != 253 OU (PER_UWORG_CF] = 253 ET CED_NF = 38466) ]
#[047] 25/02/2022 M.NAJI         SPIRA : 96405 et 96768   commenter touch EPO_FTECLEDASO
#[048] 19/04/2022 RC  :spira:101543 Le fichier EPO_FTECLEDASIISO a été retiré par erreur, il doit etre remis step00 pour le POCE
#[049] 04/05/2023 JYP  :spira:108243 : use EBS overdue cancellation amount
#[050] 12/05/2023 JYP  :spira:108243 : bugfix use EBS overdue cancellation amount
#[051] 15/05/2024 MZM :spira:109347 EBS / I17 - Fac Accepted - Copy
#[052] 12/08/2024 MZM :spira:111454 - I17 - Retro P - Incorrect NDIC PC calculation when underlying is internal assumed : (Prendre encompte les Retro Internes pour les FLOARAT NDIC uniquement)
#=============================================================================
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



## TU
#ESF_IADPERICASE_DELTA_POS=/scordata_aenitko2batch/ubeu/perm/T_ESFD5010_IADPERICASE_STD_EBS_INV_20210930.dat
#ESF_IADPERICASE_DELTA_POS=/scordata_aenitko2batch/ubeu/perm/empty.dat
#EST_IADPERICASE=/scordata_aenitko2batch/ubeu/perm/T_ESFD5010_IADPERICASE_STD_EBS_POS_20210630.dat

## TU FICHIERS EXEMPELS

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV...............................................: ${TYPEINV}"
ECHO_LOG "#===> NORME.................................................: ${NORME}"
ECHO_LOG "#===> NORME_CF..............................................: ${NORME_CF}"
ECHO_LOG "#===> param_Request_id......................................: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id......................................: ${param_Context_id}  "
ECHO_LOG "#===> CRE_D.................................................: $CRE_D "
#ECHO_LOG "#===> BALSHTYEA_NF.........................................: $BALSHTYEA_NF "
ECHO_LOG "#===> ICLODAT_D.............................................: $ICLODAT_D    " 
ECHO_LOG "#===> ICLODAT_A.............................................: $ICLODAT_A    " 
ECHO_LOG "#===> ICLODAT_M.............................................: $ICLODAT_M    " 
ECHO_LOG "#===> ICLODAT_J.............................................: $ICLODAT_J    " 
ECHO_LOG "#===> MIN_ICLODAT_A.........................................: $MIN_ICLODAT_A    "
ECHO_LOG "#===>     -------- input   ---------"
ECHO_LOG "#===> EST_ARCSTATGTA .......................................: $EST_ARCSTATGTA           "
ECHO_LOG "#===> EPO_FTECLEDASO .......................................: $EPO_FTECLEDASO           "
ECHO_LOG "#===> EPO_FTECLEDACO .......................................: $EPO_FTECLEDACO           "
ECHO_LOG "#===> EPO_FTECLEDASIISO ....................................: $EPO_FTECLEDASIISO        "
ECHO_LOG "#===> EST_FBOPRSLNK  .......................................: $EST_FBOPRSLNK            "
ECHO_LOG "#===> EST_FCLIENT    .......................................: $EST_FCLIENT              "
ECHO_LOG "#===> EST_FCPLACC    .......................................: $EST_FCPLACC              "
ECHO_LOG "#===> EST_FCTRGRO    .......................................: $EST_FCTRGRO              "
ECHO_LOG "#===> EST_FCURQUOT   .......................................: $EST_FCURQUOT             "
ECHO_LOG "#===> EST_FDETTRS    .......................................: $EST_FDETTRS              "
ECHO_LOG "#===> EST_FTRSLNK    .......................................: $EST_FTRSLNK              "
ECHO_LOG "#===> EST_IADPERICASE.......................................: $EST_IADPERICASE          "
ECHO_LOG "#===> ESF_IADPERICASE_DELTA_POS.............................: $ESF_IADPERICASE_DELTA_POS          "
ECHO_LOG "#===> EST_IADPERIFCT .......................................: $EST_IADPERIFCT           "
ECHO_LOG "#===> EST_IADPERIFCI .......................................: $EST_IADPERIFCI           "
ECHO_LOG "#===> EST_DLDGTAA_CUMULS_COUR...............................: $EST_DLDGTAA_CUMULS_COUR  "
ECHO_LOG "#===> EST_DLGTAAPNAE........................................: $EST_DLGTAAPNAE           "
ECHO_LOG "#===> EST_DLGTAAPRE ........................................: $EST_DLGTAAPRE            "
ECHO_LOG "#===> EST_FSEGEST_SOLVENCY..................................: $EST_FSEGEST_SOLVENCY     "
ECHO_LOG "#===> ESF_DLSGTAA...........................................: $ESF_DLSGTAA     "
ECHO_LOG "#===> ESF_IADPERICASE_FAC_ACCEPTED..........................: $ESF_IADPERICASE_FAC_ACCEPTED     "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> EST_DLDGTAA_E_TRNCODEBS ..............................: $EST_DLDGTAA_E_TRNCODEBS "
ECHO_LOG "#===> EST_FUTURE_EBS .......................................: $EST_FUTURE_EBS  "
ECHO_LOG "#===> EST_DLGTAUPUC ........................................: $EST_DLGTAUPUC   "
ECHO_LOG "#===> EST_DLDGTAA_E_TRNCODINI ..............................: $EST_DLDGTAA_E_TRNCODINI "
ECHO_LOG "#========================================================================="

#[035]
if [ ! -f ${EST_DLDGTAA_E_TRNCODINI} ]
then
	touch ${EST_DLDGTAA_E_TRNCODINI}
fi

#[039]
if [ ! -f ${EPO_FTECLEDACO} ]
then
	touch ${EPO_FTECLEDACO}
fi

#[039]
if [ ! -f ${EPO_FTECLEDASIISO} ]
then
	touch ${EPO_FTECLEDASIISO}
fi

#[039]
#if [ ! -f ${EPO_FTECLEDASO} ]
#then
#	touch ${EPO_FTECLEDASO}
#fi

##[043]
#if [ "${TYPEINV}" = "POC" -a "${NORME}" = "EBS" ]
#then
#	NSTEP=${NJOB}_00
#	#------------------------------------------------------------------------------
#	LIBEL="Format GLT for DLDGTAA_CUMULS_PREC"
#	SORT_WDIR=${SORTWORK}
#	SORT_CMD=`CFTMP`
#	SORT_I="${EPO_FTECLEDASO} 2000 1"
#	SORT_I2="${EPO_FTECLEDASIISO} 2000 1"
#	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_CUMULS_PREC_O.dat 2000 1"
#INPUT_TEXT ${SORT_CMD} << EOF
#/FIELDS
#DEBUT         1:1 -  40:,
#TRNCOD_CF     6:1 -  6:,
#RETINTAMT_M  88:1 -  88:,
#FIN         103:1 - 118:
#/CONDITION POCE TRNCOD_CF != "1A100022" AND TRNCOD_CF != "1A120422"
#/COPY
#/INCLUDE POCE
#/REFORMAT
#DEBUT,RETINTAMT_M,FIN
#exit
#EOF
#	SORT
#else	
#	NSTEP=${NJOB}_00B
#	#------------------------------------------------------------------------------
#	LIBEL="Format GLT for DLDGTAA_CUMULS_PREC"
#	SORT_WDIR=${SORTWORK}
#	SORT_CMD=`CFTMP`
#	SORT_I="${EPO_FTECLEDASO} 2000 1"
#	SORT_O="${DFILT}/${NJOB}_00_${IB}_SORT_FTECLEDA_CUMULS_PREC_O.dat 2000 1"
#INPUT_TEXT ${SORT_CMD} << EOF
#/FIELDS
#DEBUT         1:1 -  40:,
#RETINTAMT_M  88:1 -  88:,
#FIN         103:1 - 118:
#/COPY
#/REFORMAT
#DEBUT,RETINTAMT_M,FIN
#exit
#EOF
#	SORT
#fi

#[042]
NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Convert GLT POCI data to GT format"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDACO} 2000 1"
SORT_I2="${EPO_FTECLEDASIISO} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_POCIDATA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
DEBUT         1:1 -  40:,
RETINTAMT_M  88:1 -  88:
/DERIVEDFIELD PLUS_29_CHAMPS 29"~"
/OUTFILE ${SORT_O}
/REFORMAT
DEBUT,RETINTAMT_M,PLUS_29_CHAMPS
exit
EOF
SORT

##-----------------------------------------------------------------------------
## Begin Merge and Sort [23390] - modif 002 12/06/2012
##-----------------------------------------------------------------------------
#NSTEP=${NJOB}_60
##-----------------------------------------------------------------------------
#LIBEL="FUTURES PREPARATION : Selection of movements ('1' CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND '13579' NC TRNCOD8_CF ) "
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_00_${IB}_SORT_FTECLEDA_CUMULS_PREC_O.dat 2000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat 2000 1"
#SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_UPR_DAC.dat 2000 1"
#SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_PREC_O.dat 2000 1"
#SORT_O4="${DFILT}/${NSTEP}_${IB}_SORT_DLA_DSI_GTAA_O.dat 2000 1"  # Plus utilise [030]
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF            1:1 -  1:EN,
#        ESB_CF            2:1 -  2:EN,
#        BALSHEY_NF        3:1 -  3:EN,
#        BALSHRMTH_NF      4:1 -  4:EN,
#        BALSHRDAY_NF      5:1 -  5:EN,
#        TRNCOD_CF         6:1 -  6:,
#        TRNCOD1_CF        6:1 -  6:1,
#        TRNCOD2_CF        6:2 -  6:2,
#        TRNCOD3_CF        6:3 -  6:8,
#        TRNCOD4_CF        6:1 -  6:4,
#        TRNCOD8_CF        6:8 -  6:8,
#        TRNCOD34_CF       6:3 -  6:4,
#        DBLTRNCOD_CF      7:1 -  7:,
#        CTR_NF            8:1 -  8:,
#        END_NT            9:1 -  9:,
#        SEC_NF           10:1 - 10:EN,
#        UWY_NF           11:1 - 11:,
#        UW_NT            12:1 - 12:,
#        OCCYEA_NF        13:1 - 13:,
#        ACY_NF           14:1 - 14:,
#        SCOSTRMTH_NF     15:1 - 15:EN,
#        SCOENDMTH_NF     16:1 - 16:EN,
#        CLM_NF           17:1 - 17:,
#        CUR_CF           18:1 - 18:,
#        AMT_M            19:1 - 19:EN 15/3,
#        CED_NF           20:1 - 20:,
#        BRK_NF           21:1 - 21:,
#        PAY_NF           22:1 - 22:,
#        KEY_NF           23:1 - 23:,
#        RETCTR_NF        24:1 - 24:,
#        RETEND_NT        25:1 - 25:EN,
#        RETSEC_NF        26:1 - 26:EN,
#        RTY_NF           27:1 - 27:,
#        RETUW_NT         28:1 - 28:EN,
#        RETOCCYEA_NF     29:1 - 29:,
#        RETACY_NF        30:1 - 30:,
#        RETSCOSTRMTH_NF  31:1 - 31:EN,
#        RETSCOENDMTH_NF  32:1 - 32:EN,
#        RCL_NF           33:1 - 33:,
#        RETCUR_CF        34:1 - 34:,
#        RETAMT_M         35:1 - 35:EN 15/3,
#        PLC_NT           36:1 - 36:,
#        RTO_NF           37:1 - 37:,
#        INT_NF           38:1 - 38:,
#        RETPAY_NF        39:1 - 39:,
#        RETKEY_CF        40:1 - 40:,
#        RETINTAMT_M      41:1 - 41:EN 15/3,
#        FILLER71          1:1 - 71:,
#        FILLER41          1:1 - 41:
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      CUR_CF,
#      TRNCOD_CF,
#      OCCYEA_NF,
#      ACY_NF,
#      SCOSTRMTH_NF,
#      SCOENDMTH_NF,
#      CLM_NF
#/CONDITION ACCEPT ("1" CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND "13579" NC TRNCOD8_CF AND (TRNCOD4_CF !="1A41" AND TRNCOD4_CF !="1A43") )
#/CONDITION UPR_DAC CTR_NF != "" AND BALSHEY_NF = ${ICLODAT_A} AND TRNCOD1_CF EQ "1" AND ( TRNCOD2_CF = '1' OR TRNCOD2_CF = '4' OR TRNCOD2_CF = 'A'  OR TRNCOD2_CF = 'E' )
#/CONDITION POSTES ( TRNCOD1_CF = "1" AND "1A" CT TRNCOD2_CF AND BALSHEY_NF = ${ICLODAT_A} AND (TRNCOD4_CF !="1A41" AND TRNCOD4_CF !="1A43") )
#/CONDITION COND_TRNCOD ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) AND ("AEJ" CT TRNCOD2_CF AND TRNCOD1_CF = "1") AND
#                       ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" )
#/OUTFILE ${SORT_O}
#/INCLUDE ACCEPT
#/REFORMAT FILLER41
#/OUTFILE ${SORT_O2}
#/INCLUDE UPR_DAC
#/REFORMAT FILLER41
#/OUTFILE ${SORT_O3}
#/INCLUDE POSTES
#/REFORMAT FILLER71
#/OUTFILE ${SORT_O4}
#/INCLUDE COND_TRNCOD
#exit
#EOF
#SORT

#[041]

#[051] Ajout du fichier des FAC ACCEPTE QUe pour ESFD2230

NSTEP=${NJOB}_06
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE_DELTA_POS --> Delta INV POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_DELTA_POS} 2000 1"
if [ "${NORME_CF}" = "EBS" -a   "${TYPEINV}" = "POS" -a  "${IDF_CT}" = "EBS_ESFD2230" ]
then
SORT_I2="${ESF_IADPERICASE_FAC_ACCEPTED} 2000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_PLUS_DELTA.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	ALL_F1 									1:1 - 249:,
	PER_RECOGNIZED          250:1 - 250: 
/DERIVEDFIELD PER_RECOGNIZED_POS "O~"	                             
/OUTFILE ${SORT_O}
/REFORMAT ALL_F1, RIGHTSIDE: PER_RECOGNIZED_POS
exit
EOF
SORT




#[041]

NSTEP=${NJOB}_08
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE POS + IADPERICASE INV --> Delta INV POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_AVEC_TOP_DELTA.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	PER_CTR_NF 							3:1 - 3:,
	PER_END_NT							4:1 - 4:,
	PER_SEC_NF							5:1 - 5:,
	PER_UWY_NF							6:1 - 6:,
	PER_UW_NT 							7:1 - 7:,
	ALL_F1 									1:1 - 249:,
	PER_CTR_NF_F2 						3:1 - 3:,
	PER_END_NT_F2							4:1 - 4:,
	PER_SEC_NF_F2							5:1 - 5:,
	PER_UWY_NF_F2							6:1 - 6:,
	PER_UW_NT_F2 							7:1 - 7:,
	PER_RECOGNIZED_F2         250:1 - 250:
/JOINKEYS 
         PER_CTR_NF, 
         PER_END_NT, 
         PER_SEC_NF, 
         PER_UWY_NF, 
         PER_UW_NT
/INFILE 	${DFILT}/${NJOB}_06_${IB}_SORT_IADPERICASE_PLUS_DELTA.dat  2000 1 "~"
/JOINKEYS
         PER_CTR_NF_F2, 
         PER_END_NT_F2, 
         PER_SEC_NF_F2, 
         PER_UWY_NF_F2, 
         PER_UW_NT_F2                  
/JOIN UNPAIRED LEFTSIDE                
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: PER_RECOGNIZED_F2
exit
EOF
SORT


#[002] ajout de SORT_I3
#[003]
#[004]
NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Filling segmentation perimeters in IADPERICASE ..."
PRG=ESTM1004
#export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I1="${DFILT}/${NJOB}_08_${IB}_SORT_IADPERICASE_AVEC_TOP_DELTA.dat"
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCTRGRO1.dat  # plus utilise
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO.dat   # plus utilise
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
EXECPRG

## [052] Generer un Pericase qui n exclt pas les contrats de RI afin de générer un fichier de RATIO pour les NDIC complet

NSTEP=${NJOB}_15
# MOD003 -  Sort of IRDPERICASE 
# [028] contrats non terminés Uniquement SECACCSTS_CT != "9"
# [029] omit contract with portfolio 253
# [034] omit contract with portfolio 253 a part of CED_NF = "38466"
# [036] Dummy contract at INI 
# [040] IFRS17- Calculate future at INI on portofolio 253
# [046] IFRS17 - Prise en compte Ced CED_NF = "38466" suppression ==> OR (PORTFOLIO = "253" AND "${CONTEXT_CT}" = "INI" )
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE + on Omet les mouvements de retro interne du Pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTM1004_IADPERICASE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       3:1 -  3:,
        END_NT       4:1 -  4:EN,
        SEC_NF       5:1 -  5:EN,
        UWY_NF       6:1 -  6:,
        UW_NT        7:1 -  7:EN, 
        CED_NF       12:1 - 12:,     
        CTRRET_B   	 20:1 - 20:,
        SECACCSTS_CT 77:1 - 77:,
				PORTFOLIO    119:1 - 119:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION RETINT_WITHOUT SECACCSTS_CT != "9" AND ( (PORTFOLIO != "253" OR  (PORTFOLIO = "253" AND CED_NF = "38466") )  )
/INCLUDE RETINT_WITHOUT
exit
EOF
SORT



#/CONDITION RETINT CTRRET_B = "0" AND SECACCSTS_CT != "9" AND PORTFOLIO != "253" 
# 				  

NSTEP=${NJOB}_20
# MOD003 -  Sort of IRDPERICASE
# [028] contrats non terminés Uniquement SECACCSTS_CT != "9"
# [029] omit contract with portfolio 253
# [034] omit contract with portfolio 253 a part of CED_NF = "38466"
# [036] Dummy contract at INI 
# [040] IFRS17- Calculate future at INI on portofolio 253
# [046] IFRS17 - Prise en compte Ced CED_NF = "38466" suppression ==> OR (PORTFOLIO = "253" AND "${CONTEXT_CT}" = "INI" )
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE + on Omet les mouvements de retro interne du Pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTM1004_IADPERICASE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       3:1 -  3:,
        END_NT       4:1 -  4:EN,
        SEC_NF       5:1 -  5:EN,
        UWY_NF       6:1 -  6:,
        UW_NT        7:1 -  7:EN, 
        CED_NF       12:1 - 12:,     
        CTRRET_B   	 20:1 - 20:,
        SECACCSTS_CT 77:1 - 77:,
				PORTFOLIO    119:1 - 119:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION RETINT (CTRRET_B = "0" OR (PORTFOLIO = "248" AND "${CONTEXT_CT}" = "INI") ) AND SECACCSTS_CT != "9" AND ( (PORTFOLIO != "253" OR  (PORTFOLIO = "253" AND CED_NF = "38466") )  )
/INCLUDE RETINT
exit
EOF
SORT


NSTEP=${NJOB}_20A
#------------------------------------------------------------------------------
LIBEL="Extract CUR of  BALSHTYEA=${ICLODAT_A}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCURQUOT_TXT}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCURQUOT_${ICLODAT_A}.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CURQUOT_UWY_NF   3:1 -  3:
/CONDITION IS_BALSHTYEA ( CURQUOT_UWY_NF = "${ICLODAT_A}" )
/INCLUDE IS_BALSHTYEA
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_20B
#------------------------------------------------------------------------------
LIBEL="Extend IADPERICASE with CURQUOT_RATE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_IADPERICASE.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
                all_cols                 1:1  - 205:
/joinkeys
       SSD_CF
      ,PCPCUR_CF
/INFILE ${DFILT}/${NJOB}_20A_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols
       ,rightside:CURQUOT_RATE

exit
EOF
SORT


NSTEP=${NJOB}_20C
#------------------------------------------------------------------------------
LIBEL="Extend IADPERICASE with EGPCUR_RATE, PCPCUR and EGPCUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20B_${IB}_IADPERICASE_PCP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP_EGP_O.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        EGPCUR_CF        23:1 - 23:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
                all_cols                 1:1  - 206:
/joinkeys
       SSD_CF
      ,EGPCUR_CF
/INFILE ${DFILT}/${NJOB}_20A_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:all_cols
        ,rightside:CURQUOT_RATE
        ,leftside:PCPCUR_CF
        ,leftside:EGPCUR_CF
exit
EOF
SORT


NSTEP=${NJOB}_20D
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20C_${IB}_IADPERICASE_PCP_EGP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP_EGP.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

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


NSTEP=${NJOB}_28
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en '11xxxxx2' "
AWK_I=${EST_DLDGTAA_PREC}
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLDGTAA_PREC_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
#[032] [033] 1A120032 replaced with 1A120062
#    if (\$6 != "1A100012" && \$6 != "1A494302" && \$6 != "1A120012" && \$6 != "1A120022" && \$6 != "1A120032" && \$6 != "1A100022")
    if (\$6 != "1A100012" && \$6 != "1A494302" && \$6 != "1A120012" && \$6 != "1A120022" && \$6 != "1A120062" && \$6 != "1A100022"  && \$6 != "1A120052"  && \$6 != "1A120072")
    {
      if ( substr(\$6,2,1)=="A" ) \$6=substr(\$6,1,1) "1" substr(\$6,3,6);
      if ( substr(\$6,2,1)=="E" ) \$6=substr(\$6,1,1) "4" substr(\$6,3,6);
      if ( substr(\$6,2,1)=="J" ) \$6=substr(\$6,1,1) "7" substr(\$6,3,6);
    }
    print \$0;
  }
exit
EOF
AWK


#[23390] - modif 002 12/06/2012
#[010] correction pour enlever les dates des montants de retro interne
NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Sort AND summarize of PREVIOUS files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_28_${IB}_AWK_DLDGTAA_PREC_O.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_PREC_O.dat
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
/DERIVEDFIELD PLUS_30_CHAMPS 29"~"
/DERIVEDFIELD CHAMPS_ZERO "0~"
/CONDITION MONTANT ( AMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
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
          CHAMPS_ZERO,
          PLUS_30_CHAMPS
exit
EOF
SORT


NSTEP=${NJOB}_40
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Sort and summarize current PLAS file ${EST_DLDGTAA_CUMULS_COUR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA_CUMULS_COUR} 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_SORT_POCIDATA_O.dat 2000 1"  #[042]
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_COUR.dat
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
/SUMMARIZE  TOTAL AMT_M
/CONDITION POSTES ( TRNCOD1_CF = "1" AND BALSHEY_NF = "${ICLODAT_A}" AND (TRNCOD4_CF !="1A41" AND TRNCOD4_CF !="1A43") )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
exit
EOF
SORT


#[027][030][031]
NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="PLAS :  Create Ecart Data for CURRENT (EBS) - PREVIOUS (IFRS) file"
PRG=ESTC1054
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
ACCRET_CT A
FUTUR_CT N
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_DLDGTAA_COUR.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_DLDGTAA_PREC_O.dat
export ${PRG}_I3=${EST_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA_E.dat   # oricod EBSGTA postes transformés
EXECPRG


NSTEP=${NJOB}_70
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en '11xxxxx2' "
AWK_I=${EST_DLDGTAA}
AWK_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
    if ( substr(\$6,2,1)=="A" ) \$6=substr(\$6,1,1) "1" substr(\$6,3,6);
    if ( substr(\$6,2,1)=="E" ) \$6=substr(\$6,1,1) "4" substr(\$6,3,6);
    if ( substr(\$6,2,1)=="J" ) \$6=substr(\$6,1,1) "7" substr(\$6,3,6);
    print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_70A
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_DLDGTAA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_RATE.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF          11:1 - 11:,
        CUR_CF          18:1 - 18:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 51:

/joinkeys 
      SSD_CF
	   ,CUR_CF
/INFILE ${DFILT}/${NJOB}_20A_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
/joinkeys 
      CURQUOT_SSD_CF
	   ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	   leftside:all_cols
	  ,rightside:CURQUOT_RATE   

exit
EOF
SORT


NSTEP=${NJOB}_70B
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70A_${IB}_SORT_DLDGTAA_RATE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_RATE_RETRATE.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF            1:1 -  1:,
        RTY_NF           27:1 - 27:,
        RETCUR_CF        34:1 - 34:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 52:

/joinkeys 
      SSD_CF
	   ,RETCUR_CF
/INFILE ${DFILT}/${NJOB}_20A_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
/joinkeys 
      CURQUOT_SSD_CF
	   ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	   leftside:all_cols
	  ,rightside:CURQUOT_RATE   

exit
EOF
SORT


NSTEP=${NJOB}_70C
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTRSLNK_TXT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_EBS.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PRS_CF       1:1 -  1:
		,all_cols       1:1  - 3:
/CONDITION IS_EBS ( PRS_CF = "713" )
/INCLUDE IS_EBS
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_70D
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70B_${IB}_SORT_DLDGTAA_RATE_RETRATE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_RATE_RETRATE_EBS.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS TRNCOD_CF         6:1 -  6:,
        DETTRS_CF        3:1 -  3:,
        ACMTRS_NT        2:1 -  2:,
        all_cols         1:1  - 53:
/joinkeys 
       TRNCOD_CF 
/INFILE ${DFILT}/${NJOB}_70C_${IB}_FTRSLNK_EBS.dat  2000 1 "~"
/joinkeys 
       DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
      leftside:all_cols
     ,rightside:ACMTRS_NT   

exit
EOF
SORT


NSTEP=${NJOB}_70E
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70D_${IB}_SORT_DLDGTAA_RATE_RETRATE_EBS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_RATE_RETRATE_EBS_FBOPRSLNK.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS 
        TRNCOD_CF         		6:1 -  6:,
		FBOPRSLNK_ACMTRSL2_NT     4:1 -  4:,
		FBOPRSLNK_ACMTRSL3_NT     5:1 -  5:,
		FBOPRSLNK_DETTRS_CF       9:1 -  9:,
		FBOPRSLNK_TRNTYP_CT      14:1 - 14:,
		all_cols		              1:1  - 54:
/joinkeys 
       TRNCOD_CF
/INFILE ${EST_FBOPRSLNK_TXT} 2000 1 "~"
/joinkeys 
       FBOPRSLNK_DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:all_cols
	,rightside:FBOPRSLNK_ACMTRSL2_NT    
	,rightside:FBOPRSLNK_ACMTRSL3_NT    
	,rightside:FBOPRSLNK_TRNTYP_CT     

exit
EOF
SORT


NSTEP=${NJOB}_70F
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70E_${IB}_SORT_DLDGTAA_RATE_RETRATE_EBS_FBOPRSLNK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_RATE_RETRATE_EBS_FBOPRSLNK.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS 
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        PLC_NT           36:1 - 36:,
        all_cols          1:1  - 57:
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

exit
EOF
SORT


NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : AJOUT CODE REGROUPEMENT + LOB + CONVERSION DES MONTANTS DANS DEVISE ALIMENT "
PRG=ESTC1051B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 713
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20D_${IB}_IADPERICASE_PCP_EGP.dat
export ${PRG}_I2=${DFILT}/${NJOB}_70F_${IB}_SORT_DLDGTAA_RATE_RETRATE_EBS_FBOPRSLNK.dat
#export ${PRG}_I2=${DFILT}/${NJOB}_70_${IB}_SORT_DLDGTAA.dat
#export ${PRG}_I3=${EST_FTRSLNK}
#export ${PRG}_I4=${EST_FCURQUOT}
#export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA.dat
EXECPRG


NSTEP=${NJOB}_90
#[012]
#[015]
#[026] /CONDITION CHARGES (ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000')
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : EXCLUSION DES LOB 30 ET 31 et Ajout 16 champs ET AUTRES POSTES DIFFERENTS DE PRM PNA CHARGES"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC1051B_DLDGTAA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_OMIT.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_EBSACC.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN
       ,ESB_CF            2:1 -  2:EN
       ,BALSHEY_NF        3:1 -  3:EN
       ,BALSHRMTH_NF      4:1 -  4:EN
       ,BALSHRDAY_NF      5:1 -  5:
       ,TRNCOD_CF         6:1 -  6:
       ,TRNCOD1_CF        6:1 -  6:1
       ,TRNCOD2_CF        6:2 -  6:2
       ,TRNCOD8_CF        6:8 -  6:8
       ,DBLTRNCOD_CF      7:1 -  7:
       ,CTR_NF            8:1 -  8:
       ,END_NT            9:1 -  9:EN
       ,SEC_NF           10:1 - 10:EN
       ,UWY_NF           11:1 - 11:EN
       ,UW_NT            12:1 - 12:EN
       ,OCCYEA_NF        13:1 - 13:
       ,ACY_NF           14:1 - 14:
       ,SCOSTRMTH_NF     15:1 - 15:EN
       ,SCOENDMTH_NF     16:1 - 16:EN
       ,CLM_NF           17:1 - 17:
       ,FILLER1           1:1 - 17:
       ,CUR_CF           18:1 - 18:
       ,AMT_M            19:1 - 19:EN 15/3
       ,FILLER2          20:1 - 33:
       ,RETCUR_CF        34:1 - 34:
       ,RETAMT_M         35:1 - 35:EN 15/3
       ,FILLER3          36:1 - 40:
       ,ACMTRS_NT        42:1 - 42:
       ,ACMAMT_M         43:1 - 43:EN 15/3
       ,ACMCUR_CF        44:1 - 44:
       ,PRS_CF           45:1 - 45:
       ,SEG_NF           46:1 - 46:
       ,LOB_CF           47:1 - 47:
       ,NAT_CF           48:1 - 48:
       ,TYP_CT           49:1 - 49:
       ,PATTYP_CF        50:1 - 50:
       ,SEGLOB_CF        51:1 - 51:
/DERIVEDFIELD PLUS_16_CHAMPS 15"~"
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/DERIVEDFIELD PLUS_30_CHAMPS 30"~"
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      TRNCOD_CF
/CONDITION LOB  ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "" ) AND "1" CT TRNCOD1_CF AND BALSHEY_NF = ${ICLODAT_A} AND
                ( ACMTRS_NT='10000' OR ACMTRS_NT='10010' OR ACMTRS_NT='10020' OR ACMTRS_NT='10030' OR ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000') AND
                ( ( TRNCOD8_CF="0" AND ("${TYPEINV}" = "INV" OR "${ICLODAT_M}" != "12") ) OR TRNCOD8_CF !="0" ) AND ACMAMT_M !=0
/CONDITION ESTM ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "" ) AND (
				("1" CT TRNCOD1_CF AND BALSHEY_NF = ${ICLODAT_A} AND ( ACMTRS_NT='10000' OR ACMTRS_NT='10030' ) AND 
				( "246" CT TRNCOD8_CF OR TRNCOD_CF="11410000" ) AND ACMAMT_M !=0 ) OR  (NAT_CF = "N" and UWY_NF > ${MIN_ICLODAT_A} ))   
/CONDITION PREMIUM (ACMTRS_NT='10000') 
/CONDITION PREMPTF (ACMTRS_NT= '10010' OR ACMTRS_NT= '10020')
/CONDITION PNA     (ACMTRS_NT='10030')
/CONDITION CHARGES (ACMTRS_NT='10100')
/DERIVEDFIELD RETACMAMT_M if PNA then ACMAMT_M else 0
/DERIVEDFIELD ORICOD_LS "EBSACC"
/DERIVEDFIELD ORICOD_LS2 "EBSPRM"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD TRNCOD_CF_NEW if PREMIUM then "1A110002~" else if PREMPTF then "1A110003~" else if PNA then "1A100002~" else if CHARGES then "1A120002~" else "1A130002~"
/DERIVEDFIELD STRVIDE "~"
/SUMMARIZE TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
/INCLUDE LOB
/REFORMAT SSD_CF
         ,ESB_CF
         ,BALSHEY_NF
         ,BALSHRMTH_NF_NEW
         ,BALSHRDAY_NF_NEW
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
         ,ACMCUR_CF
         ,ACMAMT_M
         ,FILLER2
         ,STRVIDE
         ,STRVIDE
         ,FILLER3
         ,STRVIDE
         ,PLUS_16_CHAMPS
         ,ORICOD_LS2
         ,PLUS_14_CHAMPS
         ,BALSHEY_NF_NEW
         ,BALSHRMTH_NF_NEW
         ,BALSHRDAY_NF_NEW
         ,TRNCOD_CF_NEW
         ,ACMTRS_NT
/OUTFILE ${SORT_O2}
/OMIT LOB
/OUTFILE ${SORT_O3}
/INCLUDE ESTM
/REFORMAT FILLER1
         ,ACMCUR_CF
         ,ACMAMT_M
         ,FILLER2
         ,ACMCUR_CF
         ,RETACMAMT_M
         ,FILLER3
         ,STRVIDE
         ,PLUS_30_CHAMPS
exit
EOF
SORT


NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : creation d une ligne temoin par contrat / sec/uwy avec ORICOD = EBSACC "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_SORT_DLDGTAA_EBSACC.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_EBSACC.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:
       ,BALSHRMTH_NF     4:1 -  4:EN
       ,BALSHRDAY_NF     5:1 -  5:EN
       ,TRNCOD_CF        6:1 -  6:
       ,DBLTRNCOD_CF     7:1 -  7:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:EN
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:EN
       ,OCCYEA_NF       13:1 - 13:
       ,ACY_NF          14:1 - 14:
       ,SCOSTRMTH_NF    15:1 - 15:EN
       ,SCOENDMTH_NF    16:1 - 16:EN
       ,CLM_NF          17:1 - 17:
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,CED_NF          20:1 - 20:
       ,BRK_NF          21:1 - 21:
       ,PAY_NF          22:1 - 22:
       ,KEY_NF          23:1 - 23:
       ,RETCTR_NF       24:1 - 24:
       ,RETEND_NT       25:1 - 25:EN
       ,RETSEC_NF       26:1 - 26:EN
       ,RTY_NF          27:1 - 27:
       ,RETUW_NT        28:1 - 28:EN
       ,RETOCCYEA_NF    29:1 - 29:
       ,RETACY_NF       30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:EN
       ,RETSCOENDMTH_NF 32:1 - 32:EN
       ,RCL_NF          33:1 - 33:
       ,RETCUR_CF       34:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,PLC_NT          36:1 - 36:
       ,RTO_NF          37:1 - 37:
       ,INT_NF          38:1 - 38:
       ,RETPAY_NF       39:1 - 39:
       ,RETKEY_CF       40:1 - 40:
       ,RETINTAMT_M     41:1 - 41:EN 15/3
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M
/DERIVEDFIELD AJOUT15COL 15"~"
/DERIVEDFIELD ORICOD_LS "EBSACC"
/DERIVEDFIELD AJOUT14COL 14"~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
/OUTFILE ${SORT_O}
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
  ,CED_NF
  ,BRK_NF
  ,PAY_NF
  ,KEY_NF
  ,RETCTR_NF
  ,RETEND_NT
  ,RETSEC_NF
  ,RTY_NF
  ,RETUW_NT
  ,RETOCCYEA_NF
  ,RETACY_NF
  ,RETSCOSTRMTH_NF
  ,RETSCOENDMTH_NF
  ,RCL_NF
  ,RETCUR_CF
  ,RETAMT_MC
  ,PLC_NT
  ,RTO_NF
  ,INT_NF
  ,RETPAY_NF
  ,RETKEY_CF
  ,RETINTAMT_M
  ,AJOUT15COL
  ,ORICOD_LS
  ,AJOUT14COL
exit
EOF
SORT


#[010] filtrer également les lignes où tous les montants sont à zero
NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : creation DU FICHIER DES ECRITURES INPUT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_SORT_DLDGTAA.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_50_${IB}_ESTC1054_DLDGTAA_E.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAPREPNAE.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_EBS_EOC.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:EN
       ,BALSHRMTH_NF     4:1 -  4:
       ,BALSHRDAY_NF     5:1 -  5:
       ,TRNCOD_CF        6:1 -  6:
       ,TRNCOD1_CF       6:1 -  6:1
       ,TRNCOD2_CF       6:2 -  6:2	   
       ,TRNCOD3_CF       6:3 -  6:7
       ,TRNCOD38_CF      6:3 -  6:8	   
       ,TRNCOD8_CF       6:8 -  6:8
       ,DBLTRNCOD_CF     7:1 -  7:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:
       ,SEC_NF          10:1 - 10:
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:
       ,OCCYEA_NF       13:1 - 13:
       ,ACY_NF          14:1 - 14:
       ,SCOSTRMTH_NF    15:1 - 15:EN
       ,SCOENDMTH_NF    16:1 - 16:EN
       ,CLM_NF          17:1 - 17:
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,CED_NF          20:1 - 20:
       ,BRK_NF          21:1 - 21:
       ,PAY_NF          22:1 - 22:
       ,KEY_NF          23:1 - 23:
       ,RETCTR_NF       24:1 - 24:
       ,RETEND_NT       25:1 - 25:EN
       ,RETSEC_NF       26:1 - 26:EN
       ,RTY_NF          27:1 - 27:
       ,RETUW_NT        28:1 - 28:EN
       ,RETOCCYEA_NF    29:1 - 29:
       ,RETACY_NF       30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:EN
       ,RETSCOENDMTH_NF 32:1 - 32:EN
       ,RCL_NF          33:1 - 33:
       ,RETCUR_CF       34:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,PLC_NT          36:1 - 36:
       ,RTO_NF          37:1 - 37:
       ,INT_NF          38:1 - 38:
       ,RETPAY_NF       39:1 - 39:
       ,RETKEY_CF       40:1 - 40:
       ,RETINTAMT_M     41:1 - 41:EN 15/3
/CONDITION ACCEPT0 ("1" CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND "1357" NC TRNCOD8_CF )
/CONDITION ACCEPT  "1" CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND "1357" NC TRNCOD8_CF AND ( ( TRNCOD8_CF="0" AND ("${TYPEINV}" = "INV" OR "${ICLODAT_M}" != "12") ) OR TRNCOD8_CF !="0" )
                   and (AMT_M!=0 OR RETAMT_M!=0 OR RETINTAMT_M  !=0)
/CONDITION EBS_EOC  "1" CT TRNCOD1_CF  AND "AE" CT TRNCOD2_CF AND TRNCOD38_CF = "104012" AND BALSHEY_NF <= ${ICLODAT_A} 
                   and (AMT_M!=0 OR RETAMT_M!=0 OR RETINTAMT_M  !=0)				   
/CONDITION BILANCOUR (BALSHEY_NF=${ICLODAT_A})
/DERIVEDFIELD BALSMTH_NF2 if BILANCOUR then BALSHRMTH_NF else "12"
/DERIVEDFIELD BALSDAY_NF2 if BILANCOUR then BALSHRDAY_NF else "28"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD AMT_M_NEW AMT_M COMPRESS
/DERIVEDFIELD AJOUT15COL 15"~"
/DERIVEDFIELD ORICOD_LS "EBSPRM~"
/DERIVEDFIELD AJOUT14COL 14"~"
/DERIVEDFIELD STRVIDE "~"
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,ACY_NF
      ,SCOENDMTH_NF
      ,SCOSTRMTH_NF
      ,OCCYEA_NF
      ,CLM_NF
      ,CUR_CF
      ,TRNCOD_CF
      ,BALSHEY_NF
      ,BALSMTH_NF2
      ,BALSDAY_NF2
/SUMMARIZE TOTAL AMT_M
/OUTFILE ${SORT_O}
/INCLUDE ACCEPT
/REFORMAT
   SSD_CF
  ,ESB_CF
  ,BALSHEY_NF
  ,BALSMTH_NF2
  ,BALSDAY_NF2
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
  ,AMT_M_NEW
  ,CED_NF
  ,BRK_NF
  ,PAY_NF
  ,KEY_NF
  ,RETCTR_NF
  ,RETEND_NT
  ,RETSEC_NF
  ,RTY_NF
  ,RETUW_NT
  ,RETOCCYEA_NF
  ,RETACY_NF
  ,RETSCOSTRMTH_NF
  ,RETSCOENDMTH_NF
  ,RCL_NF
  ,RETCUR_CF
  ,RETAMT_M
  ,PLC_NT
  ,RTO_NF
  ,INT_NF
  ,RETPAY_NF
  ,RETKEY_CF
  ,RETINTAMT_M
  ,AJOUT15COL
  ,ORICOD_LS
  ,AJOUT14COL
  ,BALSHEY_NF_NEW
  ,BALSHRMTH_NF_NEW
  ,BALSHRDAY_NF_NEW
/OUTFILE ${SORT_O2}
/INCLUDE EBS_EOC
/REFORMAT SSD_CF         
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
        ,AMT_M          
        ,CED_NF         
        ,BRK_NF         
        ,PAY_NF         
        ,KEY_NF         
        ,RETCTR_NF      
        ,RETEND_NT      
        ,RETSEC_NF      
        ,RTY_NF         
        ,RETUW_NT       
        ,RETOCCYEA_NF   
        ,RETACY_NF      
        ,RETSCOSTRMTH_NF
        ,RETSCOENDMTH_NF
        ,RCL_NF         
        ,RETCUR_CF      
        ,RETAMT_M       
        ,PLC_NT         
        ,RTO_NF         
        ,INT_NF         
        ,RETPAY_NF      
        ,RETKEY_CF      
        ,RETINTAMT_M    
exit
EOF
SORT


NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : calculation of fstat avec arcstatgta"
PRG=ESTC3604
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${ICLODAT_A}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${DFILP}/empty.dat
export ${PRG}_I3=${DFILT}/${NJOB}_110_${IB}_SORT_DLGTAAPREPNAE.dat
export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_I5=${EST_FCURQUOT}
export ${PRG}_I6=${EST_FCPLACC}
export ${PRG}_I7=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSTAT_O.dat
EXECPRG


NSTEP=${NJOB}_160
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : FSEGEST_SOLVENCY file sort in progress... EST_FSEGEST_SOLVENCY:${EST_FSEGEST_SOLVENCY} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FSEGEST_SOLVENCY}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SEGEST_SOLVENCY_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF    1:1 - 1:EN
       ,SEG_NF    2:1 - 2:
       ,UWY_NF    3:1 - 3:
       ,AMORAT_CT 8:1 - 8:
/KEYS SSD_CF
     ,SEG_NF
     ,UWY_NF
/CONDITION BOOK AMORAT_CT = "R"
/INCLUDE BOOK
exit
EOF
SORT


gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_SEGEST_SOLVENCY_O.dat    > ${DFILT}/${NJOB}_160_SORT_SEGEST_SOLVENCY_O.dat.gz


#[032] Ce step a ete supprime ; le Fichier FLOARAT est généré dans ESFD2003C


JOBEND
 
