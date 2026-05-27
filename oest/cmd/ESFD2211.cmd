#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESID2221.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 14/012022
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Optimisation de la chaine ESFD2220 , remonter le split du FTECLEDA_CUMULS_PREC_O dans le ESFD2210
#
# Job launched by ESID2220.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[006] 12/1//2022 : M.NAJI  :spira 101406  remonter le split du FTECLEDA_CUMULS_PREC_O dans le ESFD2210 
#=============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT


ICLODAT_A="${ICLODAT_YEA}"
ICLODAT_M="${ICLODAT_MTH}"
ICLODAT_J="${ICLODAT_DAY}"




if [ "${TYPEINV}" = "POC" -a "${NORME}" = "EBS" ]
then
	NSTEP=${NJOB}_10
	#------------------------------------------------------------------------------
	LIBEL="Format GLT for DLDGTAA_CUMULS_PREC"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EPO_FTECLEDASO} 1000 1"
	SORT_I2="${EPO_FTECLEDASIISO} 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_CUMULS_PREC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
DEBUT         1:1 -  40:,
TRNCOD_CF     6:1 -  6:,
RETINTAMT_M  88:1 -  88:,
FIN         103:1 - 118:
/CONDITION POCE TRNCOD_CF != "1A100022" AND TRNCOD_CF != "1A120422"
/COPY
/INCLUDE POCE
/REFORMAT
DEBUT,RETINTAMT_M,FIN
exit
EOF
	SORT
else	
	NSTEP=${NJOB}_10B
	#------------------------------------------------------------------------------
	LIBEL="Format GLT for DLDGTAA_CUMULS_PREC"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EPO_FTECLEDASO} 1000 1"
	SORT_O="${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA_CUMULS_PREC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
DEBUT         1:1 -  40:,
RETINTAMT_M  88:1 -  88:,
FIN         103:1 - 118:
/COPY
/REFORMAT
DEBUT,RETINTAMT_M,FIN
exit
EOF
	SORT
fi


#-----------------------------------------------------------------------------
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : Selection of movements ('1' CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND '13579' NC TRNCOD8_CF ) "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA_CUMULS_PREC_O.dat 1000 1"
SORT_O="${EST_DLDGTAA}  1000 1"
SORT_O2="${EST_DLDGTAA_UPR_DAC} 1000 1"
SORT_O3="${EST_DLDGTAA_PREC} 1000 1"
SORT_O4="${EST_DLA_DSI_GTAA} 1000 1"  # Plus utilise [030]
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:8,
        TRNCOD4_CF        6:1 -  6:4,
        TRNCOD8_CF        6:8 -  6:8,
        TRNCOD34_CF       6:3 -  6:4,
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
        FILLER71          1:1 - 71:,
        FILLER41          1:1 - 41:
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
/CONDITION ACCEPT ("1" CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND "13579" NC TRNCOD8_CF AND (TRNCOD4_CF !="1A41" AND TRNCOD4_CF !="1A43") )
/CONDITION UPR_DAC CTR_NF != "" AND BALSHEY_NF = ${ICLODAT_A} AND TRNCOD1_CF EQ "1" AND ( TRNCOD2_CF = '1' OR TRNCOD2_CF = '4' OR TRNCOD2_CF = 'A'  OR TRNCOD2_CF = 'E' )
/CONDITION POSTES ( TRNCOD1_CF = "1" AND "1A" CT TRNCOD2_CF AND BALSHEY_NF = ${ICLODAT_A} AND (TRNCOD4_CF !="1A41" AND TRNCOD4_CF !="1A43") )
/CONDITION COND_TRNCOD ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) AND ("AEJ" CT TRNCOD2_CF AND TRNCOD1_CF = "1") AND
                       ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" )
/OUTFILE ${SORT_O}
/INCLUDE ACCEPT
/REFORMAT FILLER41
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE UPR_DAC
/REFORMAT FILLER41
/OUTFILE ${SORT_O3} OVERWRITE
/INCLUDE POSTES
/REFORMAT FILLER71
/OUTFILE ${SORT_O4} OVERWRITE
/INCLUDE COND_TRNCOD
exit
EOF
SORT

JOBEND
 
