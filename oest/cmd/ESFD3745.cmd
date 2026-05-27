#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 08.01 : IFRS17 TL data generation 
# Nom du script SHELL           : ESFD3745.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 17/08/2020
# Auteur                        : L.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-906572 : Assumed contract at inception
# http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-911737 : Retro contract at inception
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#       [001]           09/07/2020      L.DOAN          SPIRA : 87876           integrate GLT futures
#       [002]           22/02/2021      N.DOAN          SPIRA : 90091 Multiyear changes on GLT transformation
# 	[003]           10/06/2021      N.DOAN          SPIRA : 91532 filtre EBS transcodes	
# 	[004]           21/06/2022      D.TEIXEIRA      SPIRA : 104816  Merge future Onerous and Dummy T.CODE STD with ALl future INI  
#		[005] 					07/07/2022  		JBD							Spira : 104778  Build new closing for I17S norm
#		[006] 					25/07/2022  		DAD							Spira : 105570  update spira 104816 for I17G/S only
#		[007] 					22/09/2022  		MZM							Spira : 106944 Update counterparty in I17 RA/SAP interface following in I17
#		[008] 					17/10/2022  		DAD							Spira : 106803 transforme new TRNCODE STD for future Onerous and Dummy
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES " 


if [ ! -f ${EPO_DLREGTARSII} ]
then
        ECHO_LOG "EPO_DLREGTARSII=${EPO_DLREGTARSII}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${EPO_DLREGTARSII}"
fi

if [ ! -f ${EPO_DLREGTR} ]
then
        ECHO_LOG "EPO_DLREGTR=${EPO_DLREGTR}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${EPO_DLREGTR}"
fi

if [ ! -f ${EPO_DLDGTR_E} ]
then
        ECHO_LOG "EPO_DLDGTR_E=${EPO_DLDGTR_E}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${EPO_DLDGTR_E}"
fi


if [ ! -f ${ESF_DLDGTR_E} ]
then
        ECHO_LOG "ESF_DLDGTR_E=${ESF_DLDGTR_E}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLDGTR_E}"
fi

if [ ! -f ${EPO_DLDGTAA_E} ]
then
        ECHO_LOG "EPO_DLDGTAA_E=${EPO_DLDGTAA_E}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${EPO_DLDGTAA_E}"
fi


if [ ! -f ${EPO_DLDGTARSII_E} ]
then
        ECHO_LOG "EPO_DLDGTARSII_E=${EPO_DLDGTARSII_E}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${EPO_DLDGTARSII_E}"
fi

#################################################
# EBS futures to IFRS17                         #
#################################################

NORME_SUFFIX='R'

if [  $NORME_CF = I17G ] || [  $NORME_CF = I17S ]
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
        fi
    fi
fi

ECHO_LOG "NORME_SUFFIX = ${NORME_SUFFIX}"  >> $FLOG



NSTEP=${NJOB}_01A
#-----------------------------------------------------------------------------
LIBEL="Split EPO_DLDGTAA_E by TRNCODE STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLDGTAA_E} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
  CTR_NF        8:1 -  8:,
  END_NT        9:1 -  9:,
  SEC_NF        10:1 - 10:,
  UWY_NF        11:1 - 11:,
  UW_NT         12:1 - 12:,
	TRNCOD_CF     6:1 - 6:
/KEYS
  CTR_NF,
  END_NT,
  SEC_NF,
  UWY_NF,
  UW_NT
/CONDITION ONEFUT (TRNCOD_CF = "1A100012" or TRNCOD_CF = "1A100022" or TRNCOD_CF = "1A120012"  or TRNCOD_CF = "1A120052" or TRNCOD_CF = "1A120072" or TRNCOD_CF = "1A120062" or TRNCOD_CF = "1A494302" or TRNCOD_CF = "1A200712")
/OUTFILE ${SORT_O} overwrite
/INCLUDE ONEFUT
exit
EOF
SORT

NSTEP=${NJOB}_01B
#-----------------------------------------------------------------------------
LIBEL="Collection Future Onerous TRNCODE STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01A_${IB}_SORT_DLDGTAA_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_ONEFUT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF       8:1 -  8:,
        GT_END_NT       9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_TRNCOD_CF    6:1 - 6:,
        GT_ALL_COLS     1:1 - 71:,
        CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        TRNCOD_CF       6:1 - 6:
/joinkeys 
        GT_CTR_NF,
        GT_END_NT,
        GT_SEC_NF,
        GT_UWY_NF,
        GT_UW_NT,
        GT_TRNCOD_CF
/INFILE ${ESF_GTSII_ONEFUT_STD} 2000 1 "~"
/joinkeys 
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        GT_TRNCOD_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        LEFTSIDE:GT_ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_01C
#-----------------------------------------------------------------------------
LIBEL="Remove duplication for Future Onerous TRNCODE STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01B_${IB}_SORT_DLDGTAA_ONEFUT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_ONEFUT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
  ALL_COLLS   1:1 -  71:
/KEYS
  ALL_COLLS
/SUM 
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT

NSTEP=${NJOB}_01D
# #[043] Creation d'un fichier AT INI avec TRNCOD INI ####[007]
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme INI : '1Axxxxx2' en '11xxxxx${NORME_SUFFIX}' "
AWK_I="${DFILT}/${NJOB}_01A_${IB}_SORT_DLDGTAA_STD.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_INI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A100012") { \$6 = "1110014${NORME_SUFFIX}"; \$7 = "1210014${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A100022") { \$6 = "1110015${NORME_SUFFIX}"; \$7 = "1210015${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A120012") { \$6 = "1112014${NORME_SUFFIX}"; \$7 = "1212014${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A120052") { \$6 = "1112015${NORME_SUFFIX}"; \$7 = "1212015${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A120072") { \$6 = "1112019${NORME_SUFFIX}"; \$7 = "1212019${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A120062") { \$6 = "1112016${NORME_SUFFIX}"; \$7 = "1212016${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A494302") { \$6 = "1149431${NORME_SUFFIX}"; \$7 = "1249431${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A200712") { \$6 = "1120071${NORME_SUFFIX}"; \$7 = "1220071${NORME_SUFFIX}";print \$0;}
fi
  }
exit
EOF
AWK

# [008]
NSTEP=${NJOB}_01E
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD for future onerous : '1Axxxxx2' to '11xxxxx${NORME_SUFFIX}' "
AWK_I="${DFILT}/${NJOB}_01C_${IB}_SORT_DLDGTAA_ONEFUT.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_ONEFUT.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "1A100012") { \$6 = "1110061${NORME_SUFFIX}"; \$7 = "1210061${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A100022") { \$6 = "1110062${NORME_SUFFIX}"; \$7 = "1210062${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A120012") { \$6 = "1112061${NORME_SUFFIX}"; \$7 = "1212061${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A120052") { \$6 = "1112062${NORME_SUFFIX}"; \$7 = "1212062${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A120072") { \$6 = "1112063${NORME_SUFFIX}"; \$7 = "1212063${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A120062") { \$6 = "1114061${NORME_SUFFIX}"; \$7 = "1214061${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A494302") { \$6 = "1149461${NORME_SUFFIX}"; \$7 = "1249461${NORME_SUFFIX}";print \$0;}
if (\$6 == "1A200712") { \$6 = "1149462${NORME_SUFFIX}"; \$7 = "1249462${NORME_SUFFIX}";print \$0;}
fi
  }
exit
EOF
AWK

NSTEP=${NJOB}_01
#-----------------------------------------------------------------------------
LIBEL="Merge Future Onerous STD and ALL INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01E_${IB}_SORT_DLDGTAA_ONEFUT.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_01D_${IB}_SORT_DLDGTAA_INI.dat 2000 1"
SORT_O="${ESF_DLDGTAA_E} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    8:1 -  8:,
        END_NT    9:1 -  9:,
        SEC_NF    10:1 - 10:,
        UWY_NF    11:1 - 11:,
        UW_NT     12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT


NSTEP=${NJOB}_02A
#-----------------------------------------------------------------------------
LIBEL="Split EPO_DLREGTARSII by TRNCODE STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLREGTARSII} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTARSII_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
  CTR_NF        8:1 -  8:,
  END_NT        9:1 -  9:,
  SEC_NF        10:1 - 10:,
  UWY_NF        11:1 - 11:,
  UW_NT         12:1 - 12:,
	TRNCOD_CF     6:1 - 6:
/KEYS
  CTR_NF,
  END_NT,
  SEC_NF,
  UWY_NF,
  UW_NT
/CONDITION DUMMYFUT (TRNCOD_CF = "2A100012" or TRNCOD_CF = "2A100022" or TRNCOD_CF = "2A120012"  or TRNCOD_CF = "2A120052" or TRNCOD_CF = "2A120072" or TRNCOD_CF = "2A120062" or TRNCOD_CF = "2A494302" or TRNCOD_CF = "2A200712" or TRNCOD_CF = "2A121212")
/OUTFILE ${SORT_O} overwrite
/INCLUDE DUMMYFUT
exit
EOF
SORT

NSTEP=${NJOB}_02B
#-----------------------------------------------------------------------------
LIBEL="Collection Future Dummy TRNCODE STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_02A_${IB}_SORT_DLREGTARSII_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTARSII_DUMMYFUT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF       8:1 -  8:,
        GT_END_NT       9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_TRNCOD_CF    6:1 - 6:,
        GT_ALL_COLS     1:1 - 71:,
        CTR_NF          8:1 - 8:,
        END_NT          9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        TRNCOD_CF       6:1 - 6:
/joinkeys 
        GT_CTR_NF,
        GT_END_NT,
        GT_SEC_NF,
        GT_UWY_NF,
        GT_UW_NT,
        GT_TRNCOD_CF
/INFILE ${ESF_GTSII_DUMMY_STD} 2000 1 "~"
/joinkeys 
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        GT_TRNCOD_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        LEFTSIDE:GT_ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_02C
#-----------------------------------------------------------------------------
LIBEL="Remove duplication for Future Dummy TRNCODE STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_02B_${IB}_SORT_DLREGTARSII_DUMMYFUT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTARSII_DUMMYFUT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
  ALL_COLLS   1:1 -  71:
/KEYS
  ALL_COLLS
/SUM 
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT


##[007]

NSTEP=${NJOB}_02D
# #[043] Creation d'un fichier AT INI avec TRNCOD INI
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD NP P en Norme INI : '2Axxxxx2' en '21xxxxxI' "
AWK_I="${DFILT}/${NJOB}_02A_${IB}_SORT_DLREGTARSII_STD.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTARSII_INI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2110014${NORME_SUFFIX}"; \$7 = "2210014${NORME_SUFFIX}";   print \$0;} 
if (\$6 == "2A100022") { \$6 = "2110015${NORME_SUFFIX}"; \$7 = "2210015${NORME_SUFFIX}";   print \$0;}
if (\$6 == "2A120012") { \$6 = "2112014${NORME_SUFFIX}"; \$7 = "2212014${NORME_SUFFIX}";   print \$0;}
if (\$6 == "2A120052") { \$6 = "2112015${NORME_SUFFIX}"; \$7 = "2212015${NORME_SUFFIX}";   print \$0;}
if (\$6 == "2A120072") { \$6 = "2112019${NORME_SUFFIX}"; \$7 = "2212019${NORME_SUFFIX}";   print \$0;}
if (\$6 == "2A120062") { \$6 = "2112016${NORME_SUFFIX}"; \$7 = "2212016${NORME_SUFFIX}";   print \$0;}
if (\$6 == "2A494302") { \$6 = "2149431${NORME_SUFFIX}"; \$7 = "2249431${NORME_SUFFIX}";   print \$0;}
if (\$6 == "2A200712") { \$6 = "2120071${NORME_SUFFIX}"; \$7 = "2220071${NORME_SUFFIX}";   print \$0;}
if (\$6 == "2A121212") { \$6 = "2112128${NORME_SUFFIX}"; \$7 = "2212128${NORME_SUFFIX}";   print \$0;}
fi                                                                                         
  }
exit
EOF
AWK

# [008]
NSTEP=${NJOB}_02E
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD for future onerous : '1Axxxxx2' to '11xxxxx${NORME_SUFFIX}' "
AWK_I="${DFILT}/${NJOB}_02C_${IB}_SORT_DLREGTARSII_DUMMYFUT.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTARSII_DUMMYFUT.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2110061${NORME_SUFFIX}"; \$7 = "2210061${NORME_SUFFIX}";print \$0;}
if (\$6 == "2A100022") { \$6 = "2110062${NORME_SUFFIX}"; \$7 = "2210062${NORME_SUFFIX}";print \$0;}
if (\$6 == "2A120012") { \$6 = "2112061${NORME_SUFFIX}"; \$7 = "2212061${NORME_SUFFIX}";print \$0;}
if (\$6 == "2A120052") { \$6 = "2112062${NORME_SUFFIX}"; \$7 = "2212062${NORME_SUFFIX}";print \$0;}
if (\$6 == "2A120072") { \$6 = "2112063${NORME_SUFFIX}"; \$7 = "2212063${NORME_SUFFIX}";print \$0;}
if (\$6 == "2A120062") { \$6 = "2114061${NORME_SUFFIX}"; \$7 = "2214061${NORME_SUFFIX}";print \$0;}
if (\$6 == "2A494302") { \$6 = "2149461${NORME_SUFFIX}"; \$7 = "2249461${NORME_SUFFIX}";print \$0;}
if (\$6 == "2A200712") { \$6 = "2149462${NORME_SUFFIX}"; \$7 = "2249462${NORME_SUFFIX}";print \$0;}
if (\$6 == "2A121212") { \$6 = "2112161${NORME_SUFFIX}"; \$7 = "2212161${NORME_SUFFIX}";   print \$0;}
fi
  }
exit
EOF
AWK

NSTEP=${NJOB}_02
#-----------------------------------------------------------------------------
LIBEL="Merge Future Dummy STD and ALL INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_02E_${IB}_SORT_DLREGTARSII_DUMMYFUT.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_02D_${IB}_SORT_DLREGTARSII_INI.dat 2000 1"
SORT_O="${ESF_DLREGTARSII} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    8:1 -  8:,
        END_NT    9:1 -  9:,
        SEC_NF    10:1 - 10:,
        UWY_NF    11:1 - 11:,
        UW_NT     12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT


NSTEP=${NJOB}_03
# #[043] Creation d'un fichier AT INI avec TRNCOD INI ##[007]
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD NP P en Norme INI : '2Axxxxx2' en '21xxxxxI' "
AWK_I=${EPO_DLREGTR}
AWK_O=${ESF_DLREGTR}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2110014${NORME_SUFFIX}"; \$7 = "2210014${NORME_SUFFIX}" ; print \$0;} 
if (\$6 == "2A100022") { \$6 = "2110015${NORME_SUFFIX}"; \$7 = "2210015${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120012") { \$6 = "2112014${NORME_SUFFIX}"; \$7 = "2212014${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120052") { \$6 = "2112015${NORME_SUFFIX}"; \$7 = "2212015${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120072") { \$6 = "2112019${NORME_SUFFIX}"; \$7 = "2212019${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120062") { \$6 = "2112016${NORME_SUFFIX}"; \$7 = "2212016${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A494302") { \$6 = "2149431${NORME_SUFFIX}"; \$7 = "2249431${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A200712") { \$6 = "2120071${NORME_SUFFIX}"; \$7 = "2220071${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A121212") { \$6 = "2112128${NORME_SUFFIX}"; \$7 = "2212128${NORME_SUFFIX}" ; print \$0;}	
fi
  }
exit
EOF
AWK


NSTEP=${NJOB}_04
# #[043] Creation d'un fichier AT INI avec TRNCOD INI ## [007]
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD NP P en Norme INI  : '2Axxxxx2' en '21xxxxxI' "
AWK_I=${EPO_DLDGTR_E}
AWK_O=${ESF_DLDGTR_E}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2110014${NORME_SUFFIX}"; \$7 = "2210014${NORME_SUFFIX}" ; print \$0;} 
if (\$6 == "2A100022") { \$6 = "2110015${NORME_SUFFIX}"; \$7 = "2210015${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120012") { \$6 = "2112014${NORME_SUFFIX}"; \$7 = "2212014${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120052") { \$6 = "2112015${NORME_SUFFIX}"; \$7 = "2212015${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120072") { \$6 = "2112019${NORME_SUFFIX}"; \$7 = "2212019${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120062") { \$6 = "2112016${NORME_SUFFIX}"; \$7 = "2212016${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A494302") { \$6 = "2149431${NORME_SUFFIX}"; \$7 = "2249431${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A200712") { \$6 = "2120071${NORME_SUFFIX}"; \$7 = "2220071${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A121212") { \$6 = "2112128${NORME_SUFFIX}"; \$7 = "2212128${NORME_SUFFIX}" ; print \$0;}	
fi
  }
exit
EOF
AWK

NSTEP=${NJOB}_05
# #[043] Creation d'un fichier AT INI avec TRNCOD INI
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD NP P en Norme INI : '2Axxxxx2' en '21xxxxxI' "
AWK_I=${EPO_DLDGTARSII_E}
AWK_O=${ESF_DLDGTARSII}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2110014${NORME_SUFFIX}"; \$7 = "2210014${NORME_SUFFIX}" ; print \$0;} 
if (\$6 == "2A100022") { \$6 = "2110015${NORME_SUFFIX}"; \$7 = "2210015${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120012") { \$6 = "2112014${NORME_SUFFIX}"; \$7 = "2212014${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120052") { \$6 = "2112015${NORME_SUFFIX}"; \$7 = "2212015${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120072") { \$6 = "2112019${NORME_SUFFIX}"; \$7 = "2212019${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A120062") { \$6 = "2112016${NORME_SUFFIX}"; \$7 = "2212016${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A494302") { \$6 = "2149431${NORME_SUFFIX}"; \$7 = "2249431${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A200712") { \$6 = "2120071${NORME_SUFFIX}"; \$7 = "2220071${NORME_SUFFIX}" ; print \$0;}
if (\$6 == "2A121212") { \$6 = "2112128${NORME_SUFFIX}"; \$7 = "2212128${NORME_SUFFIX}" ; print \$0;}	
fi
  }
exit
EOF
AWK

	

JOBEND

