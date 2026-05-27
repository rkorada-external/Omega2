#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17  
# Nom du script SHELL           : ESFD2555.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 29/03/2022
# Auteur                        : MZM
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#[001] 06/04/2022 MZM      :spira:102507 AI NDIC INI TRANSCO en TRNCOD I17  
#[007] 20/06/2022 MZM :spira : 104778 AJOUT COULOIR I17S  
#[003] 22/09/2022 MZM :Spira : 106856 Update counterparty in I17 RA/SAP interface following in I17  
#[004] 03/10/2022 MZM :Spira : 106856 FRS17- Prod Issue - P&L TCs with multiple counterparts on 2022Q1  
#[005] 21/02/2023 MZM :Spira : 106770 I17G - Internal assumed initial amounts to be aligned with internal retro initial amounts (Filtre que sur Poste 49500)     
#[006] 19/06/2023 MZM :Spira : 109430 [I17 Prod] - IO - Missing Future closing positions on Internal Assumed from Dummies :Extention aux postes Futures de la FD     
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES " 


if [ ! -f ${EST_DLRGTAA} ]
then
        ECHO_LOG "EST_DLRGTAA=${EST_DLRGTAA}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${EST_DLRGTAA}"
fi



if [  $NORME_CF = I17G ]
then
    NORME_SUFFIX='I'
else
    if [  $NORME_CF = I17P ]
    then
         NORME_SUFFIX='K'
    else
        if [  $NORME_CF = I17L ]
        then
            NORME_SUFFIX='M'
        else
            if [  $NORME_CF = I17S ]
            then
               NORME_SUFFIX='I' 
            fi           
        fi
    fi
fi

ECHO_LOG "NORME_SUFFIX = ${NORME_SUFFIX}"  >> $FLOG

##[002]     ##[002] ##[004]

if [ "${IDF_CT}" = "I17G_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17L_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_NDC_RPO_INI" ]
then	


NSTEP=${NJOB}_10A
# Creation d'un fichier AT INI avec TRNCOD INI POUR NDC INI
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD NDC en Norme INI : "
AWK_I=${EST_DLRGTAA}
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DLRGTAA.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

		if ( substr(\$6,3,5)=="43013" ) { \$6=substr(\$6,1,2) "43011" substr(\$6,8,1);   }
		else if ( substr(\$6,3,5)=="43020" ) { \$6=substr(\$6,1,2) "43021" substr(\$6,8,1); }
		else if ( substr(\$6,3,5)=="43030" ) { \$6=substr(\$6,1,2) "43031" substr(\$6,8,1); }

 print \$0; 
  }
exit
EOF
AWK

##[004]
 
NSTEP=${NJOB}_15A
# Creation d'un fichier AT INI avec DBLTRNCOD INI POUR NDC INI
#-----------------------------------------------------------------------------
LIBEL="Transforme DBLTRNCOD NDC en Norme INI : "
AWK_I="${DFILT}/${NJOB}_10A_${IB}_AWK_DLRGTAA.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DLRGTAA.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

		if ( substr(\$7,3,5)=="43013" ) { \$7=substr(\$7,1,2) "43011" substr(\$7,8,1); }
		else if ( substr(\$7,3,5)=="43020" ) { \$7=substr(\$7,1,2) "43021" substr(\$7,8,1);   }
		else if ( substr(\$7,3,5)=="43030" ) { \$7=substr(\$7,1,2) "43031" substr(\$7,8,1);   } 
			

 print \$0; 
  }
exit
EOF
AWK


NSTEP=${NJOB}_20A
#-----------------------------------------------------------------------------
LIBEL="COPY TEMPORARY FILE TO PERM FILE  " 
EXECKSH "cp ${DFILT}/${NJOB}_15A_${IB}_AWK_DLRGTAA.dat  ${EST_DLRGTAA}"

fi

##[002] ##[003]

if [ "${IDF_CT}" = "I17G_FUT_RPO_INI" ] || [ "${IDF_CT}" = "I17S_FUT_RPO_INI" ] || [ "${IDF_CT}" = "I17L_FUT_RPO_INI" ] || [ "${IDF_CT}" = "I17P_FUT_RPO_INI" ]
then	

NSTEP=${NJOB}_10
# Creation d'un fichier AT INI avec TRNCOD INI
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme INI : '1Axxxxx2' en '11xxxxxI' "
AWK_I=${EST_DLRGTAA}
#AWK_O=${EST_DLRGTAA}
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DLRGTAA.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A100012") { \$6 = "1110014${NORME_SUFFIX}"; \$7 = "1210014${NORME_SUFFIX}"; print \$0;}
if (\$6 == "1A100022") { \$6 = "1110015${NORME_SUFFIX}"; \$7 = "1210015${NORME_SUFFIX}"; print \$0;}
if (\$6 == "1A120012") { \$6 = "1112014${NORME_SUFFIX}"; \$7 = "1212014${NORME_SUFFIX}"; print \$0;}
if (\$6 == "1A120052") { \$6 = "1112015${NORME_SUFFIX}"; \$7 = "1212015${NORME_SUFFIX}"; print \$0;}
if (\$6 == "1A120072") { \$6 = "1112019${NORME_SUFFIX}"; \$7 = "1212019${NORME_SUFFIX}"; print \$0;}
if (\$6 == "1A120062") { \$6 = "1112016${NORME_SUFFIX}"; \$7 = "1212016${NORME_SUFFIX}"; print \$0;}
if (\$6 == "1A494302") { \$6 = "1149431${NORME_SUFFIX}"; \$7 = "1249431${NORME_SUFFIX}"; print \$0;}
if (\$6 == "1A121212") { \$6 = "1112128${NORME_SUFFIX}"; \$7 = "1212128${NORME_SUFFIX}"; print \$0;}
if (\$6 == "1A200712") { \$6 = "1120071${NORME_SUFFIX}"; \$7 = "1220071${NORME_SUFFIX}"; print \$0;}
                                                                                         



fi
  }
exit
EOF
AWK

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="COPY TEMPORARY FILE TO PERM FILE  " 
EXECKSH "cp ${DFILT}/${NJOB}_10_${IB}_AWK_DLRGTAA.dat  ${EST_DLRGTAA}"

fi

#[005] Filtre des Fichiers I17G_LCC_RPO_INI DLGTAR et DLGTR que sur le poste 49500

 
#[006] /CONDITION ONLY_LC (TRNCOD_CF = "2149500I")

if [ "${IDF_CT}" = "I17G_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_LCC_RPO_INI" ]  || [ "${IDF_CT}" = "I17L_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_LCC_RPO_INI" ]  
then 

NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_DLREGTAR file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLREGTAR}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLREGTAR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        TRNCOD_CF          6:1 - 6:, 
        TRNCOD5_CF         6:3 - 6:7,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:EN,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:

/CONDITION COND_NEW   ( TRNCOD5_CF = "10061" OR TRNCOD5_CF = "10062" OR TRNCOD5_CF = "12061" OR TRNCOD5_CF = "12062" OR TRNCOD5_CF = "12063" OR TRNCOD5_CF = "14061" OR TRNCOD5_CF = "49461" OR TRNCOD5_CF = "49462" OR TRNCOD5_CF = "49500" OR TRNCOD5_CF = "12161"  OR TRNCOD5_CF = "43014" OR TRNCOD5_CF = "43024" OR TRNCOD5_CF = "43034")
/OUTFILE ${SORT_O}
/INCLUDE COND_NEW      	
exit
EOF
SORT

NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="COPY TEMPORARY FILE TO PERM FILE  " 
EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_SORT_DLREGTAR_O.dat  ${EST_DLREGTAR}"


NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_DLREGTR file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLREGTR}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        TRNCOD_CF          6:1 - 6:, 
        TRNCOD5_CF         6:3 - 6:7,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:EN,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:

/CONDITION COND_NEW   ( TRNCOD5_CF = "10061" OR TRNCOD5_CF = "10062" OR TRNCOD5_CF = "12061" OR TRNCOD5_CF = "12062" OR TRNCOD5_CF = "12063" OR TRNCOD5_CF = "14061" OR TRNCOD5_CF = "49461" OR TRNCOD5_CF = "49462" OR TRNCOD5_CF = "49500" OR TRNCOD5_CF = "12161"  OR TRNCOD5_CF = "43014" OR TRNCOD5_CF = "43024" OR TRNCOD5_CF = "43034")
/OUTFILE ${SORT_O}
/INCLUDE COND_NEW      	
exit
EOF
SORT

NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="COPY TEMPORARY FILE TO PERM FILE  " 
EXECKSH "cp ${DFILT}/${NJOB}_40_${IB}_SORT_DLREGTR_O.dat  ${EST_DLREGTR}"

fi


JOBEND
