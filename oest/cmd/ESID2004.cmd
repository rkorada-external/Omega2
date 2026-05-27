#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESID2004.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 31/05/2012
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 18/04/2012 Roger Cassis :spot:23802 - Modifications pour Solvency
#[002] 12/06/2012 JF VDV : [23390] - Modifications pour Solvency
#[003] 29/10/2012 Roger Cassis :spot:24041 - Modifications Solvency - Fichier temporaire devient fixe
#[004] 21/04/2015 R. Cassis    :spot:28305 - Add FAC RPCC code 11417002 into DLDGTAA
#[005] 12/08/2015 E. CHATAIN   :spot:29066 - formatage du fichier GLT
#[006] 11/04/2019 R. cassis    :spira:65656 - gestion du fichier FCTREST mode EBS supprimé car pas utilisé dans inventaire IFRS Std. 
#[007] 30/10/2019 M. NAJI      :spot:81838 - Commenter les gzip de EST_DTSTATGTAA, EST_CTRULT02, EST_FTTR_PRM, EST_DLCUMGTAAS, EST_IADPERIFR, EST_IADPERIFCI et EST_FCTREST
#[008] 27/04/2020 R. cassis    :spira:86503 - EST_FCTREST1_IFRS n'est plus utilisé car EST_FCTREST1 n'est utilisé que pour IFRS et plus pour EBS
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT


# Parameters
CRE_D=$1
CLOTYP_CT=$2
ICLODAT_D=$3
OPT_EBS=$4

NSTEP=${NJOB}_01
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers"
EXECKSH_MODE=P
RMFIL "${EST_DTSTATGTAA}.gz"
#EXECKSH "gzip ${EST_DTSTATGTAA}"

NSTEP=${NJOB}_05
#Last version of ESID2000 files deletion
#-----------------------------------------------------------------------------
RMFIL "`dirname ${EST_FLOARATSNEM}`/${NCHAIN}_FLOARATSNEM*.dat"

if [ "${EST_ESID2000_COND1}" = "Y" ]     # option EBS ?
then

	NSTEP=${NJOB}_10
	# Fusionne les fichiers EST_FPRMLOA_IFRS avec EST_FPRMLOA_EBS
	#------------------------------------------------------------------------------
	LIBEL="Fusionne les fichiers EST_FPRMLOA_IFRS avec EST_FPRMLOA_EBS"
	EXECKSH_MODE=P
	EXECKSH "cat ${EST_FPRMLOA_IFRS} ${EST_FPRMLOA_EBS} > ${EST_FPRMLOA}"

	NSTEP=${NJOB}_20
	# Fusionne les fichiers EST_FLOARAT_IFRS avec EST_FLOARAT_EBS
	#------------------------------------------------------------------------------
	LIBEL="Fusionne les fichiers EST_FLOARAT_IFRS avec EST_FLOARAT_EBS"
	EXECKSH_MODE=P
	EXECKSH "cat ${EST_FLOARAT_IFRS} ${EST_FLOARAT_EBS} > ${EST_FLOARAT}"

	NSTEP=${NJOB}_30
	# Fusionne les fichiers EST_FT_IFRS avec EST_FT_EBS
	#------------------------------------------------------------------------------
	LIBEL="Copie ${EST_FT_IFRS} dans ${EST_FT}"
	EXECKSH_MODE=P
	EXECKSH "cp ${EST_FT_IFRS} ${EST_FT}"
#[006]
#	NSTEP=${NJOB}_40
#	# Fusionne les fichiers EST_FCTREST1_IFRS avec EST_FCTREST1_EBS
#	#------------------------------------------------------------------------------
#	LIBEL="Fusionne les fichiers EST_FCTREST1_IFRS avec EST_FCTREST1_EBS"
#	EXECKSH_MODE=P
#	EXECKSH "cat ${EST_FCTREST1_IFRS} ${EST_FCTREST1_EBS} > ${EST_FCTREST1}"

else

	NSTEP=${NJOB}_50
	# Copie ${EST_FPRMLOA_IFRS} dans ${EST_FPRMLOA}
	#------------------------------------------------------------------------------
	LIBEL="Copie ${EST_FPRMLOA_IFRS} dans ${EST_FPRMLOA}"
	EXECKSH_MODE=P
	EXECKSH "cp ${EST_FPRMLOA_IFRS} ${EST_FPRMLOA}"

	NSTEP=${NJOB}_60
	# Copie ${EST_FLOARAT_IFRS} dans ${EST_FLOARAT}
	#------------------------------------------------------------------------------
	LIBEL="Copie ${EST_FLOARAT_IFRS} dans ${EST_FLOARAT}"
	EXECKSH_MODE=P
	EXECKSH "cp ${EST_FLOARAT_IFRS} ${EST_FLOARAT}"

	NSTEP=${NJOB}_70
	# Copie ${EST_FT_IFRS} dans ${EST_FT}
	#------------------------------------------------------------------------------
	LIBEL="Copie ${EST_FT_IFRS} dans ${EST_FT}"
	EXECKSH_MODE=P
	EXECKSH "cp ${EST_FT_IFRS} ${EST_FT}"

#[008]
#	NSTEP=${NJOB}_80
#	# Copie ${EST_FCTREST1_IFRS} dans ${EST_FCTREST1}
#	#------------------------------------------------------------------------------
#	LIBEL="Copie ${EST_FCTREST1_IFRS} dans ${EST_FCTREST1}"
#	EXECKSH_MODE=P
#	EXECKSH "cp ${EST_FCTREST1_IFRS} ${EST_FCTREST1}"
	
fi

#[003]
NSTEP=${NJOB}_90
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLGTAAPNAE} 500 1"
SORT_I2=${EST_DLGTAAPRE}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAPNAE_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	DEBUT           1:1 - 41:
/DERIVEDFIELD AJOUT30COL 30"~"
/OUTFILE ${SORT_O}
/REFORMAT DEBUT,AJOUT30COL
exit
EOF
SORT

#[004] Ajout fichier I4
NSTEP=${NJOB}_100
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLDGTAA_IFRS}
SORT_I2=${EST_DLDGTAA_E_TRNCODEBS}
SORT_I3=${DFILT}/${NJOB}_90_${IB}_SORT_DLGTAAPNAE_O.dat
SORT_I4=${DFILT}/${NCHAIN}_ESID2001_20_${IB}_SORT_DLGTAFACPNAERPCC_O3.dat
SORT_O="${EST_DLDGTAA} OVERWRITE"
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
/OUTFILE ${SORT_O}
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

###################
# SNEMs computing #
###################

NSTEP=${NJOB}_110
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Compute of loading rates for SNEM"
PRG=ESTC1024
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
CLODAT_D ${ICLODAT_D}
CLOTYP_CT ${CLOTYP_CT}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_PERICASESNEM}
export ${PRG}_I2=${EST_IADPERIFCT}
export ${PRG}_O1=${EST_FLOARATSNEM}
EXECPRG

JOBEND
