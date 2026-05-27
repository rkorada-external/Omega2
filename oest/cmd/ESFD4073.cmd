#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4072.cmd
# revision                      : $Revision:   1.0  $
# date de creation				: 17/01/2024
# auteur						: Mehdi NAJI
# references ds specifications	: 
#-----------------------------------------------------------------------------
# description
#       IFRS17 Accouting Update
#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [001] 07/06/2021 Linh DOAN : SPIRA 92996 GLT IFRS17- Missing field in TTECLEDA and TTECLEDR format
# [001] 07/06/2021 Linh DOAN : SPIRA 97737 REQ20.1 - Exclude Life contracts
# [003] 21/02/2022 MZM : SPIRA 102371 : I17 Filtrer les fichiers I17 Par Normes (Ajout jointures avec les fichiers Pericases)  
# [004] 25/04/2022 MZM : SPIRA 103892: : Remise des champs GT de 73 a 118  pour Assume et de 73 a 71 pour Retro
# [005] 06/05/2022 MZM : SPIRA 85522:  : ONEROUS : Filtre  a partir des PERICASE :  Annulation et deplacement dans ESFD4033 et ESFD4035
# [006] 21/06/2022 MZM : SPIRA 105171:  :Ajout des ANNULATIONS LIFE en sortie du ESFD4030
# [007] 08/08/2022 HR : SPIRA 105449: INI RTO Missing (RA View)
# [008] 29/08/2022 MZ : SPIRA 105449: INI RTO Missing (RA View) Retrait de la SUM au _95B
# [009] 12/09/2022 MZM : SPIRA 106718 IFRS 17 - Annulations Life manquantes MAJ du step _55A
# [010] 17/10/2022 MZM : SPIRA 107357 IFRS 17 - RTO- Do not update opening and cancelation (Ajout Step _95D)
# [011] 10/19/2022 JBD : SPIRA 105609 IO contract info -> Update CSUOE if NOT RI line (step 120/130)
# [012] 16/11/2022 MZM : SPIRA 107725 IFRS 17 P&C closing - Exclusion of all Life treaties
# [013] 14/02/2023 MZM : SPIRA 108737 INT - Missing Retrocessionaire in RR view for I17 transactions : Mise à jour EST_FPLATXCUMALL ==> EST_FPLATXCUM
# [014] 13/03/2023 MZM : SPIRA 108587 Mixed retro : AEs are wrong in RA view : Variabilisation du Fichier FPLATXCUM (ALL ou CUM) en entree du ESTC1052B 
# [015] 12/10/2023 MZM : SPIRA 110675   20.1 - I17 - REQ 20.1 - remove content of NEWCOLS5_NF on reclass transactions
# [016] 08/01/2024 MZM : SPIRA 111009   OPTIM   
# [017] 17/01/2024 M.NAJI: SPIRA 111009   OPTIM : get data de l'ancien ESFD4037 à mettre le plus hat dans VTOM et en //   
#======================================================================================================================

#set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

FTECLEDA_IN=$1
FTECLEDA_OUT=$2

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="EXTEND ${FTECLEDA_IN} with infos of ${ESF_IADVPERICASE_CPLACC_SEG0_SEG_PRDCOD}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${FTECLEDA_IN} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA.dat "
COND_REJ="(TRNCOD34_CF != '82' AND  TRNCOD34_CF != '83' AND  TRNCOD345_CF != '841' AND TRNCOD345_CF != '842' AND  TRNCOD34_CF != '85' AND TRNCOD345_CF != '110' AND TRNCOD345_CF != '111' AND TRNCOD345_CF != '907' )" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    TECLEDA_CTR_NF        8:1 -  8:,
    TECLEDA_END_NT        9:1 -  9:,
    TECLEDA_SEC_NF       10:1 - 10:,
    TECLEDA_UWY_NF       11:1 - 11:,
    TECLEDA_UW_NT        12:1 - 12:,
    TECLEDA_1-44        1:1 - 44:,
    TECLEDA_88-119      88:1 - 119:,
    TECLEDA_LOBRET_CF	46	:1	 -	46	:,
    TECLEDA_SOBRET_CF	48	:1	 -	48	:,
    TECLEDA_TOPRET_CF	50	:1	 -	50	:,
    TECLEDA_NATRET_CF	52	:1	 -	52	:,
    TECLEDA_GARRET_CF	54	:1	 -	54	:,
    TECLEDA_PCPRSKTRYRET_CF	56	:1	 -	56	:,
    TECLEDA_USRCRTCODRET_CT	58	:1	 -	58	:,
    TECLEDA_USRCRTVALRET_LM	60	:1	 -	60	:,
    TECLEDA_RETCTRCAT_CF	62	:1	 -	62	:,
    TECLEDA_RETACCTYP_CT	67	:1	 -	67	:,
    TECLEDA_COMACC_B    68:1 - 68:              , 	
    TECLEDA_CPLACCUPD_D 69:1 - 69:              , 
    TECLEDA_VRS_NF      72:1 - 72:              ,
    TECLEDA_SEG_NF      73:1 - 73:             ,
    PER_CTR_NF				3	:1	 -	3	:,
    PER_END_NT				4	:1	 -	4	:,
    PER_SEC_NF				5	:1	 -	5	:,
    PER_UWY_NF				6	:1	 -	6	:,
    PER_UW_NT				7	:1	 -	7	:,
    PER_ACCESB_CF			8	:1	 -	8	:,
    PER_ANLCTY_CF			10	:1	 -	10	:,
    PER_CTRRET_B			20	:1	 -	20	:,
    PER_ESTCRB_CT			24	:1	 -	24	:,
    PER_ESTCTR_NF			25	:1	 -	25	:,
    PER_GAR_CF				32	:1	 -	32	:,
    PER_LOB_CF				38	:1	 -	38	:,
    PER_NAT_CF				49	:1	 -	49	:,
    PER_PCPRSKTRY_CF		52	:1	 -	52	:,
    PER_SOB_CF				81	:1	 -	81	:,
    PER_TOP_CF				84	:1	 -	84	:,
    PER_CTRNAT_CT			85	:1	 -	85	:,
    PER_UWGRP_CF			86	:1	 -	86	:,
    PER_WRKCAT_CT			88	:1	 -	88	:,
    PER_ACCADMTYP_CT		97	:1	 -	97	:,
    PER_USRCRTCOD_CT		115	:1	 -	115	:,
    PER_USRCRTVAL_LM		116	:1	 -	116	:,
    PER_UWORG_CF			119	:1	 -	119	:,
    PER_ORGCED_NF			126	:1	 -	126	:,
    PER_CEDHORDNBR_NT		152	:1	 -	152	:,
    PER_CEDSORDNBR_NT		153	:1	 -	153	:,
    PER_ORGCEDHORDNBR_NT	154	:1	 -	154	:,
    PER_ORGCEDSORDNBR_NT	155	:1	 -	155	:,
    PER_BRKHORDNBR_NT		156	:1	 -	156	:,
    PER_BRKSORDNBR_NT		157	:1	 -	157	:,
    PER_FACADMTYP_B			158	:1	 -	158	:,
    CMP_ACY_NF          207:1   -   207:,
    CMP_LSTUPD_D        208:1   -   208:,
    VRS_NF_GEN          209:1   -   209:,
    SEG_NF_GEN          210:1   -   210:,
    VRS_NF              211:1   -   211:,
    SEG_NF              212:1   -   212:,
    PRDCOD_CT           213:1   -   213:
/DERIVEDFIELD BLANC  "~"
/joinkeys
        TECLEDA_CTR_NF ,
        TECLEDA_END_NT ,
        TECLEDA_SEC_NF ,
        TECLEDA_UWY_NF ,
        TECLEDA_UW_NT
/INFILE ${ESF_IADVPERICASE_CPLACC_SEG0_SEG_PRDCOD} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE 
/OUTFILE ${SORT_O}
/REFORMAT
    leftside:TECLEDA_1-44        ,
    rightside:PER_LOB_CF         ,  
    leftside:TECLEDA_LOBRET_CF   ,
    rightside:PER_SOB_CF         ,
    leftside:TECLEDA_SOBRET_CF   ,
    rightside:PER_TOP_CF         ,
    leftside:TECLEDA_TOPRET_CF   ,
    rightside:PER_NAT_CF         ,
    leftside:TECLEDA_NATRET_CF   ,
    rightside:PER_GAR_CF         ,
    leftside:TECLEDA_GARRET_CF   ,
    rightside:PER_PCPRSKTRY_CF   ,
    leftside:TECLEDA_PCPRSKTRYRET_CF,
    rightside:PER_USRCRTCOD_CT   ,
    leftside:TECLEDA_USRCRTCODRET_CT   ,
    rightside:PER_USRCRTVAL_LM   ,
    leftside:TECLEDA_USRCRTVALRET_LM   ,
    rightside:PER_CTRNAT_CT      ,
    leftside:TECLEDA_RETCTRCAT_CF   ,
    rightside:PER_WRKCAT_CT      ,
    rightside:PRDCOD_CT       ,
    rightside:PER_ANLCTY_CF   ,
    rightside:PER_ACCADMTYP_CT   ,
    leftside:TECLEDA_RETACCTYP_CT   ,
    leftside:TECLEDA_COMACC_B   , 	
    leftside:TECLEDA_CPLACCUPD_D , 
    rightside:PER_CTRRET_B       ,
    rightside:PER_UWGRP_CF       ,
    leftside:TECLEDA_VRS_NF     ,
    leftside:TECLEDA_SEG_NF   ,
    rightside:PER_UWORG_CF       ,
    rightside:PER_ESTCRB_CT      ,
    rightside:PER_ESTCTR_NF      ,
    rightside:PER_ACCESB_CF      ,
    rightside:PER_ORGCED_NF      ,
    rightside:PER_CEDHORDNBR_NT     ,
    rightside:PER_CEDSORDNBR_NT     ,
    rightside:PER_ORGCEDHORDNBR_NT                ,
    rightside:PER_ORGCEDSORDNBR_NT                ,
    rightside:PER_BRKHORDNBR_NT     ,
    rightside:PER_BRKSORDNBR_NT     ,
    rightside:PER_FACADMTYP_B    ,
    BLANC   , 	
    BLANC             , 
    leftside:TECLEDA_88-119     ,
    rightside:CMP_ACY_NF      ,
    rightside:CMP_LSTUPD_D    ,
    rightside:VRS_NF_GEN      ,
    rightside:SEG_NF_GEN      ,
    rightside:VRS_NF          ,
    rightside:SEG_NF          ,
    rightside:PER_CTR_NF
      
exit
EOF
SORT

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="UPDATE ${DFILT}/${NJOB}_10_${IB}_FTECLEDA.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_FTECLEDA.dat 2000 1"
SORT_O=${FTECLEDA_OUT} 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        TECLEDA_RETCTR_NF       24:1    -       24:,
        TECLEDA_ACY_NF	        14:1	-       14:,
        TECLEDA_PLC_NT		36:1	-	36:,
        TECLEDA_RTO_NF		37:1	-	37:,
        TECLEDA_TRNCOD1_CF      6:1     -       6:1 ,
        TECLEDA_COMACC_B	68:1	-	68:,
        TECLEDA_CPLACCUPD_D	69:1	-	69:,

        CMP_ACY_NF              120:1   -       120:,
        CMP_LSTUPD_D            121:1   -       121:,
        VRS_NF_GEN              122:1   -       122:,
        SEG_NF_GEN              123:1   -       123:,
        VRS_NF                  124:1   -       124:,
        SEG_NF                  125:1   -       125:,
        PER_CTR_NF              126:1   -       126: ,
        TECLEDA_COL1-35	        1:1     -       35:,
        TECLEDA_COL38-67	38:1    -       67:,
        CTRRET_B		70:1    -       70:,
        UWGRP                   71:1    -       71:,
        TECLEDA_COL74-85	74:1    -       85:,
        TECLEDA_COL88-103	88:1    -       103:,
        TECLEDA_ORICOD_LS       104:1   -       104:,
        TECLEDA_COL105-118	105:1   -       118:,
        TECLEDA_CLI_NF          119:1   -       119:
/CONDITION COND_CLI_NF TECLEDA_CLI_NF = "" 
/CONDITION  COND_ASSUMED TECLEDA_TRNCOD1_CF != "2"  and  TECLEDA_TRNCOD1_CF !=  "4" 
/DERIVEDFIELD PLC_NT IF COND_ASSUMED then TECLEDA_PLC_NT ELSE IF COND_CLI_NF THEN "" ELSE TECLEDA_PLC_NT
/DERIVEDFIELD RTO_NF IF COND_ASSUMED then TECLEDA_RTO_NF ELSE IF COND_CLI_NF THEN "" ELSE TECLEDA_RTO_NF
/DERIVEDFIELD BLANC  "~" 
/CONDITION COND_SANS_FILS PER_CTR_NF = "" 
/CONDITION COND_ACY CMP_ACY_NF >=  TECLEDA_ACY_NF 
/DERIVEDFIELD COMACC_B   if  COND_SANS_FILS then "0~" else if  COND_ACY then  "1~"         else "0~" 
/DERIVEDFIELD CPLACCUPD_D if COND_SANS_FILS then ""  else if  COND_ACY then  CMP_LSTUPD_D else ""
/CONDITION COND_SEG SEG_NF = ""
/DERIVEDFIELD NEW_SEG_NF if COND_SEG then  SEG_NF_GEN else SEG_NF
/DERIVEDFIELD NEW_VRS_NF if COND_SEG then  VRS_NF_GEN else VRS_NF
/CONDITION COND_CTRRET_B CTRRET_B = ""
/DERIVEDFIELD NEW_CTRRET_B if COND_SANS_FILS then "0" else CTRRET_B
/CONDITION COND_ORICOD_LS   PER_CTR_NF= "" and  
                            TECLEDA_ORICOD_LS != "ESID2561ESTC8805" and 
                            TECLEDA_ORICOD_LS != "RECLASSP" and 
                            TECLEDA_ORICOD_LS != "RECLASSL"
/DERIVEDFIELD NEW_TECLEDA_ORICOD_LS IF COND_ASSUMED  THEN
                                        if COND_SANS_FILS THEN "" else TECLEDA_ORICOD_LS
                                    ELSE 
                                        if  COND_ORICOD_LS then "" else TECLEDA_ORICOD_LS
/COPY
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        TECLEDA_COL1-35	,
        PLC_NT		,
        RTO_NF		,
        TECLEDA_COL38-67,
        COMACC_B	,
        CPLACCUPD_D	,
        NEW_CTRRET_B	,
        UWGRP           ,
        NEW_VRS_NF	,
        NEW_SEG_NF      ,
        TECLEDA_COL74-85,
        BLANC,
        BLANC,
        TECLEDA_COL88-103,
        NEW_TECLEDA_ORICOD_LS,
        TECLEDA_COL105-118	    
      
exit
EOF
SORT

JOBEND
