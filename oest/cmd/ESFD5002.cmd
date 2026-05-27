#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD5002.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 07\06\2021
# auteur                        : Arnaud RUFFAULT
#---------------------------------------------------------------------------------
# description
#  Generation of a row a pericase INI INV/POS
#
#---------------------------------------------------------------------------------
# [001] 20/10/2022 : MZM : spira 105660 LO FACTOR Table update process I17 
# [002] 21/12/2022 : MZM : spira 105660 LO FACTOR Table update process I17  Fix Bug ITK
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================INPUT PARAMETERS====================="
ECHO_LOG "#===> PARM_ICLODAT_D.....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> NORME_CF...........................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV............................................................: ${TYPEINV}"
ECHO_LOG "#===> X_DAYS.............................................................: ${X_DAYS}"
ECHO_LOG "#===> PARM_CRE_D.........................................................: ${PARM_CRE_D}"
ECHO_LOG "#===> ICLODAT_MTH........................................................: ${ICLODAT_MTH}"
ECHO_LOG "#===> PARM_SEGTYP_CT.....................................................: ${PARM_SEGTYP_CT}"
ECHO_LOG "#===> PARM_DBCLO_D.......................................................: ${PARM_DBCLO_D}"
ECHO_LOG "#===> PARM_BALSHTYEA_NF..................................................: ${PARM_BALSHTYEA_NF}"
ECHO_LOG "#===> QUARTER_END_FOUND..................................................: ${QUARTER_END_FOUND}"
ECHO_LOG "#===> PARM_IS_TRN........................................................: ${PARM_IS_TRN}"

ECHO_LOG "#====================================INPUT FILE=========================="
ECHO_LOG "#===> EST_IADPERICASE0_INI...............................................: ${EST_IADPERICASE0_INI}"
ECHO_LOG "#===> EST_IRDPERICASE_INI................................................: ${EST_IRDPERICASE_INI}"
ECHO_LOG "#===> EST_FSOBBLOB.......................................................: ${EST_FSOBBLOB}"
ECHO_LOG "#===> EST_FCURQUOT.......................................................: ${EST_FCURQUOT}"
ECHO_LOG "#====================================OUTPUT FILE=========================="
ECHO_LOG "#===> ESF_FPLACEMT0......................................................: ${ESF_FPLACEMT0}"
ECHO_LOG "#===> ESF_FPLACEMT2......................................................: ${ESF_FPLACEMT2}"
ECHO_LOG "#===> ESF_FPLATXCUMALL...................................................: ${ESF_FPLATXCUMALL}"
ECHO_LOG "#===> ESF_FCTRGROLESII...................................................: ${ESF_FCTRGROLESII}"
#ECHO_LOG "#===> ESF_FLOARAT_I17...................................................: ${ESF_FLOARAT_I17}"
ECHO_LOG "#===> ESF_FMARKET........................................................: ${ESF_FMARKET}"
ECHO_LOG "#===> ESF_FCES...........................................................: ${ESF_FCES}"
ECHO_LOG "#===> ESF_FCTRGRO........................................................: ${ESF_FCTRGRO}"
ECHO_LOG "#===> ESF_FCTRGRO1.......................................................: ${ESF_FCTRGRO1}"
ECHO_LOG "#===> ESF_FCTRULT........................................................: ${ESF_FCTRULT}"
ECHO_LOG "#===> ESF_FPLATXCUM......................................................: ${ESF_FPLATXCUM}"
ECHO_LOG "#===> ESF_FPLC...........................................................: ${ESF_FPLC}"
ECHO_LOG "#===> ESF_IADPERIFCI.....................................................: ${ESF_IADPERIFCI}"
ECHO_LOG "#===> ESF_IADPERIFCT.....................................................: ${ESF_IADPERIFCT}"
ECHO_LOG "#===> ESF_IADPERIFR......................................................: ${ESF_IADPERIFR}"
ECHO_LOG "#===> ESF_FULTIMATES.....................................................: ${ESF_FULTIMATES}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI...............................................: ${ESF_FLORETFACTOR_INI}"
ECHO_LOG "#========================================================================="

# Extract LOFACTOR I17 : Generation Fichier INV /POS

# Borne Inferieure DATE_DEB en fonction type de closing

if  [ "${TYPEINV}" = "INV" ] 
then  
     if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
     then 
     		PARM_DATE_DEB_D="${PARM_BOOKING_D}"
     		PARM_DATE_FIN_D="${PARM_BOOKINGNEXT_D}"     		
     fi         
fi


if  [ "${TYPEINV}" = "POS" ] 
then  
     if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
     then 
     		PARM_DATE_DEB_D="${PARM_BOOKING_D}"
     		PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"     		
     fi              
fi

ECHO_LOG "#===> PARM_PSTOMGEND17_D..............................................: ${PARM_PSTOMGEND17_D}"
ECHO_LOG "#===> PARM_BOOKINGNEXT_D..............................................: ${PARM_BOOKINGNEXT_D}"
ECHO_LOG "#===> PARM_BOOKING_D..................................................: ${PARM_BOOKING_D}"
ECHO_LOG "#===> PARM_DATE_FIN_D.................................................: ${PARM_DATE_FIN_D}"

ECHO_LOG "#===> PARM_ICLODAT_D..................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PARM_DATE_DEB_D.................................................: ${PARM_DATE_DEB_D}"


NSTEP=${NJOB}_01
#Call PsLORETFACTOR_I17_01
#-----------------------------------------------------------------------------
LIBEL="Generation of Retro Loss Occuring File ESF_FLORETFACTOR AT INI I17"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FLORETFACTOR_INI}
BCP_QRY="execute BEST..PsLORETFACTOR_I17_01   '${PARM_ICLODAT_D}', '${PARM_ICLODAT_D}', '${PARM_DATE_FIN_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' "
BCP



NSTEP=${NJOB}_05
#Call PsCESSIONI17_01
#-----------------------------------------------------------------------------
LIBEL="PsCESSIONI17_01"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FCESSION0.dat
BCP_QRY="execute BEST..PsCESSIONI17_01 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_10
#Call PsCESSIONI17_01
#-----------------------------------------------------------------------------
LIBEL="PsSECTIONI17_10"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FCTRGRO0.dat
BCP_QRY="execute BEST..PsSECTIONI17_10"
BCP

NSTEP=${NJOB}_15
#Call PsCTRULTI17_01
#-----------------------------------------------------------------------------
LIBEL="PsCTRULTI17_01"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FCTRULT0.dat
BCP_QRY="execute BEST..PsCTRULTI17_01 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_20
#Call PsPLACEMTI17_01
#-----------------------------------------------------------------------------
LIBEL="PsPLACEMTI17_01"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FPLACEMT0}
BCP_QRY="execute BEST..PsPLACEMTI17_01 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_25
#Call PsPLACEMTI17_05
#-----------------------------------------------------------------------------
LIBEL="PsPLACEMTI17_05"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FPLACEMT2}
BCP_QRY="execute BEST..PsPLACEMTI17_05 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_30
#Call PsPLACEMTI17_35
#-----------------------------------------------------------------------------
LIBEL="PsPLACEMTI17_35"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FPLATXCUM0.dat
BCP_QRY="execute BRET..PsPLACEMTI17_35 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_35
#Call PsPLACEMTI17_35 ALL
#-----------------------------------------------------------------------------
LIBEL="PsPLACEMTI17_35 ALL"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FPLATXCUMALL}
BCP_QRY="execute BRET..PsPLACEMTI17_35 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}','ALL'"
BCP

NSTEP=${NJOB}_40
#Call PsSECTIONI17_04
#-----------------------------------------------------------------------------
LIBEL="PsSECTIONI17_04"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_IADPERIFCI0.dat
BCP_QRY="execute BEST..PsSECTIONI17_04  '${PARM_SEGTYP_CT}', '${PARM_CRE_D}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_45
#Call PsSECTIONI17_05
#-----------------------------------------------------------------------------
LIBEL="PsSECTIONI17_05"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_IADPERIFCT0.dat
BCP_QRY="execute BEST..PsSECTIONI17_05  '${PARM_SEGTYP_CT}', '${PARM_DBCLO_D}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}' with recompile"
BCP

NSTEP=${NJOB}_50
#Call PsSECTIONI17_03
#-----------------------------------------------------------------------------
LIBEL="PsSECTIONI17_03"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_IADPERIFR0.dat
BCP_QRY="execute BEST..PsSECTIONI17_03  '${PARM_SEGTYP_CT}', '${PARM_CRE_D}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_55
#Call PsUNDSTAI17_01
#-----------------------------------------------------------------------------
LIBEL="PsUNDSTAI17_01"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FUNDSTA0.dat
BCP_QRY="execute BEST..PsUNDSTAI17_01 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_60
#Call PsAPRI17_01
#-----------------------------------------------------------------------------
LIBEL="PsAPRI17_01"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FAPR0.dat
BCP_QRY="execute BEST..PsAPRI17_01"
BCP

NSTEP=${NJOB}_65
#Call PsFAMPROTI17_01
#-----------------------------------------------------------------------------
LIBEL="PsFAMPROTI17_01"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FAMPROT0.dat
BCP_QRY="execute BEST..PsFAMPROTI17_01 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_70
#Call PsCPLACCI17_02
#-----------------------------------------------------------------------------
LIBEL="PsCPLACCI17_02"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FCPLACC0.dat
BCP_QRY="execute BEST..PsCPLACCI17_02 '${PARM_ICLODAT_D}'"
BCP

#NSTEP=${NJOB}_75
##-----------------------------------------------------------------------------------
#LIBEL="CALL PROC BEST..PsFLOARAT_I17_01 TO EXTRACT PERM FILE ESF_FLOARAT_I17 "
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O="${ESF_FLOARAT_I17}"
#BCP_QRY="execute BEST..PsFLOARAT_I17_INI_01 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}'"
#BCP

NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Convertion of  ${EST_IADPERICASE0_INI} into PERICASE by region "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0_INI} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
		CTR_NF 3:1 - 3:,
		      END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_85
#-----------------------------------------------------------------------------
LIBEL="Convertion of  ${ESF_FCESSION0} into FCESSION file by region"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_FCESSION0.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCESSION.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT  5:1 - 5:,
		SSD_CF 14:1 - 14: EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_90
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file"
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_IADPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_85_${IB}_FCESSION.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCES_NEW.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_NOT_USE.dat
EXECPRG

NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_90_${IB}_ESTC2301_FCES_NEW.dat
SORT_O="${ESF_FCES} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF    1:1 - 1:,
        END_NT    2:1 - 2: ,
        SEC_NF    3:1 - 3: ,
        UWY_NF    4:1 - 4: ,
        UW_NT     5:1 - 5: ,
        RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7: ,
        RETSEC_NF 8:1 - 8: ,
        RTY_NF    9:1 - 9: ,
        RETUW_NT  10:1 - 10:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION RETRO RETCTR_NF EQ ""
/OMIT RETRO
exit
EOF
SORT

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Sorting FTCTRGRO file by region "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_BCP_FCTRGRO0.dat 1000 1"
SORT_O="${ESF_FCTRGRO} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    1:1 - 1:,
        END_NT    2:1 - 2:,
        SEC_NF    3:1 - 3:,
		SSD_CF    5:1 - 5: EN,
		SEGTYP_CT 6:1 - 6:,
        UWY_NF    21:1 - 21:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
  	UWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_105
#-----------------------------------------------------------------------------
LIBEL="Sorting IADPERICASE file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_IADPERICASE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_O2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		PER_SSD_CF						1:1 - 1:,	
        PER_CTR_NF 						3:1 - 3:,
        PER_END_NT						4:1 - 4:,
        PER_SEC_NF						5:1 - 5:,
        PER_UWY_NF						6:1 - 6:,
        PER_UW_NT 						7:1 - 7:,
		PER_CED_NF 						12:1 - 12:,
		PER_CTRRET_B					20:1 - 20:, 
		PER_EGPCUR_CF       			23:1 - 23:,
		PER_LOB_CF						38:1 - 38:,
		PER_LOSCOREXI_B		    		39:1 -  39:,
		PER_NAT_CF 						49:1 - 49:,
		PER_PCPRSKTRY_CF				52:1 - 52:,
		PER_SECACCSTS_CT    			77:1 - 77:,
		SECINC_D 						78:1 - 78: EN,
		PER_CTRNAT_CT   				85:1 - 85:,
		PER_UWORG_CF					119:1 - 119: ,
      	BEFORE_PER_LOSCOREXI_B 			1:1 -  38:,
		AFTER_PER_LOSCOREXI_B			40:1 -  206:,
		all_cols		 				1:1  - 206:
/CONDITION COND_PERM2 ( ( PER_UWORG_CF != "253" AND PER_UWORG_CF != "255" AND PER_UWORG_CF != "13") OR
						( PER_UWORG_CF = "253" AND PER_CED_NF = "38466" ) 
					  ) AND PER_SECACCSTS_CT != "9" AND SECINC_D <= ${PARM_ICLODAT_D}					  
/DERIVEDFIELD PER_LOSCOREXI_B_NEW if COND_PERM2 then "0" else PER_LOSCOREXI_B 
/OUTFILE ${SORT_O} 
/INCLUDE COND_PERM2
/REFORMAT 
	BEFORE_PER_LOSCOREXI_B
	,PER_LOSCOREXI_B_NEW
	,AFTER_PER_LOSCOREXI_B
/COPY
exit	
EOF
SORT

NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="Comparison of period closing process and segmentation perimeters"
PRG=ESTM1004
export ${PRG}_I1="${DFILT}/${NJOB}_105_${IB}_IADPERICASE_O2.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_10_${IB}_BCP_FCTRGRO0.dat"
export ${PRG}_O1=${ESF_FCTRGRO1}
export ${PRG}_O2="${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO_NOT_USE.dat"
export ${PRG}_O3="${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE_NOT_USE.dat"
EXECPRG

NSTEP=${NJOB}_115
#-----------------------------------------------------------------------------
LIBEL="Sorting FCTRULT file by region "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_BCP_FCTRULT0.dat 1000 1"
SORT_O="${ESF_FCTRULT} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 7:1 - 7: EN
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="Sorting FPLATXCUM file from ESF_FPLATXCUM0 by region"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_BCP_FPLATXCUM0.dat 1000 1"
SORT_O="${ESF_FPLATXCUM} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 2:1 - 2: EN,
        RTY_NF    3:1 - 3:,
        PLC_NF    4:1 - 4:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NF
exit
EOF
SORT

NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
LIBEL="Sorting FPLACEMT file by region"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FPLACEMT0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FPLACEMT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF    1:1 - 1: EN,
		RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4:,
        RETSEC_NF 5:1 - 5:EN,
        RTY_NF 	  6:1 - 6:,
        RETUW_NT  7:1 - 7:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_127
# SORT BCP_IRDPERICASE_INI
#-----------------------------------------------------------------------------
LIBEL="Trie IRDPERICASE_INI to EST_IRDPERICASE_INI with retro valid"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE_INI}  1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_NUMERIC_SORT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        PER_CTR_NF              3:1 - 3:,
        PER_END_NT              4:1 - 4: ,
        PER_SEC_NF              5:1 - 5:EN,
        PER_UWY_NF              6:1 - 6: ,
        PER_UW_NT               7:1 - 7:
/KEYS 
	PER_CTR_NF,
	PER_END_NT,
	PER_SEC_NF,
	PER_UWY_NF,
	PER_UW_NT

exit
EOF
SORT

NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
LIBEL="Computing new placement file"
PRG=ESTC2302
export ${PRG}_I1=${DFILT}/${NJOB}_127_${IB}_IRDPERICASE_NUMERIC_SORT.dat
export ${PRG}_I2=${DFILT}/${NJOB}_125_${IB}_FPLACEMT.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PLC_O.dat
EXECPRG

NSTEP=${NJOB}_135
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_130_${IB}_ESTC2302_PLC_O.dat
SORT_O="${ESF_FPLC} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4:,
        RETSEC_NF 5:1 - 5:,
        RTY_NF    6:1 - 6:,
        RETUW_NT  7:1 - 7:,
        PLC_NT    8:1 - 8:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
LIBEL="Sorting of XADPERIFCI Perimeter File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_BCP_IADPERIFCI0.dat 1000 1"
SORT_O="${ESF_IADPERIFCI} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
		END_NT 2:1 - 2:,
		SEC_NF 3:1 - 3:,
		UWY_NF 4:1 - 4:,
		UW_NT  5:1 - 5:,
		SSD_CF 14:1 - 14: EN
/KEYS 	CTR_NF,
		END_NT,
		SEC_NF,
		UWY_NF,
		UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_145
#-----------------------------------------------------------------------------
LIBEL="SORTING of XADPERIFCT Perimeter File "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_45_${IB}_BCP_IADPERIFCT0.dat
SORT_O="${ESF_IADPERIFCT} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3: EN,
        UWY_NF 4:1 - 4: EN,
        UW_NT  5:1 - 5: EN,
		SSD_CF 7:1 - 7: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
LIBEL="SORTING of IADPERIFR Perimeter File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_BCP_IADPERIFR0.dat 1000 1"
SORT_O="${ESF_IADPERIFR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF  1:1 - 1:,
		END_NT  2:1 - 2:,
		SEC_NF  3:1 - 3:,
		UWY_NF  4:1 - 4:,
		UW_NT   5:1 - 5:,
		 SSD_CF 12:1 - 12: EN
/KEYS 	CTR_NF,
		END_NT,
		SEC_NF,
		UWY_NF,
		UW_NT
exit
EOF
SORT 

NSTEP=${NJOB}_155
#------------------------------------------------------------------------------
LIBEL="Generation of binary format Files"
PRG=ESTX3602
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_FBSEGEST.dat"
EXECPRG


NSTEP=${NJOB}_160
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${ESF_FPLC}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLACUMUL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   3:1 - 3:,
		RETEND_NT   4:1 - 4: EN,
		RETSEC_NF   5:1 - 5: EN,
		RTY_NF      6:1 - 6: EN,
		RETUW_NT    7:1 - 7: EN,
		SSDRTO_B    15:1 - 15:,
		RETSIGSHA_R 16:1 - 16:EN 1/8
/KEYS 	RETCTR_NF,
		RETEND_NT, 
		RETSEC_NF, 
		RTY_NF, 
		RETUW_NT, 
		SSDRTO_B
/SUMMARIZE TOTAL RETSIGSHA_R
exit
EOF
SORT

NSTEP=${NJOB}_165
#-----------------------------------------------------------------------------
LIBEL="Sort of cession file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${ESF_FCES}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCESANT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 6:1 - 6:,
		RETEND_NT 7:1 - 7: EN,
		RETSEC_NF 8:1 - 8: EN,
		RTY_NF    9:1 - 9: EN,
		RETUW_NT  10:1 - 10: EN
/KEYS 	RETCTR_NF,
		RETEND_NT,
		RETSEC_NF,
		RTY_NF, 
		RETUW_NT
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_170
#------------------------------------------------------------------------------
LIBEL="Synchro between cessions and placements files"
PRG=ESTC3601
export ${PRG}_I1=${DFILT}/${NJOB}_160_${IB}_SORT_FPLACUMUL_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_165_${IB}_SORT_FCESANT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSHARE_O.dat
EXECPRG

NSTEP=${NJOB}_175
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_170_${IB}_ESTC3601_FSHARE_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCEDANT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 	  1:1 - 1:,
		END_NT	  2:1 - 2: EN,
		SEC_NF	  3:1 - 3: EN,
		UWY_NF	  4:1 - 4: EN,
		UW_NT 	  5:1 - 5: EN,
		SHARERI_R 6:1 - 6: EN 1/8,
		SHARERE_R 7:1 - 7: EN 1/8
/KEYS 	CTR_NF, 
		END_NT,
		SEC_NF,
		UWY_NF,
		UW_NT
/SUMMARIZE TOTAL SHARERI_R, TOTAL SHARERE_R
exit
EOF
SORT

NSTEP=${NJOB}_180
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${ESF_FPLACEMT0}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLACUMUL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   3:1 - 3:,
        RETEND_NT   4:1 - 4: EN,
        RETSEC_NF   5:1 - 5: EN,
        RTY_NF	    6:1 - 6: EN,
        RETUW_NT    7:1 - 7: EN,
        SSDRTO_B    15:1 - 15:,
        RETSIGSHA_R 16:1 - 16:EN 1/8
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      SSDRTO_B
/SUMMARIZE TOTAL RETSIGSHA_R
exit
EOF
SORT

NSTEP=${NJOB}_185
#-----------------------------------------------------------------------------
LIBEL="Sort of perimeter file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0_INI} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 		 3:1 - 3:,
        END_NT 		 4:1 - 4:,
        SEC_NF		 5:1 - 5:,
        UWY_NF		 6:1 - 6:,
        UW_NT		 7:1 - 7:,
        SECACCSTS_CT 77:1 - 77:,
        CRTVRSINC_D  159:1 - 159:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION CLOSEDACC (SECACCSTS_CT EQ "9" AND CRTVRSINC_D >= "${LIMITINF_D}") or SECACCSTS_CT != "9"
/OUTFILE ${SORT_O}
/INCLUDE CLOSEDACC
exit
EOF
SORT

NSTEP=${NJOB}_190
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_05_${IB}_BCP_FCESSION0.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCESSION_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
		SEC_NF 3:1 - 3:,
		UWY_NF 4:1 - 4:,
		UW_NT  5:1 - 5:
/KEYS 	CTR_NF,
		SEC_NF,
		UWY_NF,
		UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_195
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file"
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_185_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_190_${IB}_SORT_FCESSION_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCES_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_NOT_USE.dat
EXECPRG

NSTEP=${NJOB}_200
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_195_${IB}_ESTC2301_FCES_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 6:1 - 6:,
		RETEND_NT 7:1 - 7: EN,
		RETSEC_NF 8:1 - 8: EN,
		RTY_NF    9:1 - 9: EN,
		RETUW_NT  10:1 - 10: EN
/KEYS   RETCTR_NF, 
		RETEND_NT,
		RETSEC_NF, 
		RTY_NF, 
		RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_205
#------------------------------------------------------------------------------
LIBEL="Synchro between cessions and placements files"
PRG=ESTC3601
export ${PRG}_I1=${DFILT}/${NJOB}_180_${IB}_SORT_FPLACUMUL_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_200_${IB}_SORT_FCES_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSHARE_O.dat
EXECPRG

NSTEP=${NJOB}_210
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_205_${IB}_ESTC3601_FSHARE_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCEDBIL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    1:1 - 1:,
		END_NT    2:1 - 2: EN,
		SEC_NF    3:1 - 3: EN,
		UWY_NF    4:1 - 4: EN,
		UW_NT     5:1 - 5: EN,
		SHARERI_R 6:1 - 6: EN 1/8,
		SHARERE_R 7:1 - 7: EN 1/8
/KEYS   CTR_NF, 
		END_NT,
		SEC_NF,
		UWY_NF,
		UW_NT
/SUMMARIZE TOTAL SHARERI_R, TOTAL SHARERE_R
exit
EOF
SORT

NSTEP=${NJOB}_215
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of the ultimates file"
PRG=ESTC3603
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${PARM_BALSHTYEA_NF}
OPTION Q
SEGTYP_CT A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IADPERICASE0_INI}
export ${PRG}_I2=${DFILT}/${NJOB}_155_${IB}_ESTX3602_FBSEGEST.dat
export ${PRG}_I3=${DFILT}/${NJOB}_10_${IB}_BCP_FCTRGRO0.dat
export ${PRG}_I4=${DFILT}/${NJOB}_55_${IB}_BCP_FUNDSTA0.dat
export ${PRG}_I5=${DFILT}/${NJOB}_15_${IB}_BCP_FCTRULT0.dat
export ${PRG}_I6=${DFILT}/${NJOB}_60_${IB}_BCP_FAPR0.dat
export ${PRG}_I7=${DFILT}/${NJOB}_65_${IB}_BCP_FAMPROT0.dat
export ${PRG}_I8=${DFILT}/${NJOB}_45_${IB}_BCP_IADPERIFCT0.dat
export ${PRG}_I9=${DFILT}/${NJOB}_210_${IB}_SORT_FCEDBIL_O.dat
export ${PRG}_I10=${DFILT}/${NJOB}_175_${IB}_SORT_FCEDANT_O.dat
export ${PRG}_I11=${EST_FSOBBLOB}
export ${PRG}_I12=${EST_FCURQUOT}
export ${PRG}_I13=${DFILT}/${NJOB}_70_${IB}_BCP_FCPLACC0.dat
export ${PRG}_O1=${ESF_FULTIMATES}
EXECPRG

NSTEP=${NJOB}_220
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_225
#Call PsRISKMARGIN_SEGI17
#-----------------------------------------------------------------------------
LIBEL="PsRISKMARGIN_SEGI17"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${ESF_FCTRGROLESII}"
BCP_QRY="execute BSAR..PsRISKMARGIN_SEGI17 '${PARM_ICLODAT_D}', '${TYPEINV}','${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}' with recompile"
BCP

NSTEP=${NJOB}_230
#-----------------------------------------------------------------------------
LIBEL="EXTRACTION de la table BSBO..TUWSEC to Permanent file ESF_FMARKET_O..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FMARKET}
BCP_QRY="execute BSAR..PsGetMARKETI17_01 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

JOBEND