#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INTRADAY
# nom du script SHELL           : ESDJ0112.cmd
# date de creation              : 29/07/2015
# auteur                        : JFO
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Generation of file needed for intra day
#-----------------------------------------------------------------------------
# historiques des modifications
# [001]     JFO     29/07/2015  spot29095: Création du fichier
# [002]     DFI     19/02/2016  spot30233: Nettoyage des fichiers de l'intraday
# [003]     MBO     01/03/2016  spot30277: Nettoyage des fichiers $DFILT
# [004]     MBO     28/04/2016  spot30277: Correction current_time => ${IB}
# [005]     DFI     14/06/2016  spot:    : SPIRA:44675 Rapports sur type comptable 1 (survenance) : extraire tous les UWY
# [006]     MIS     12/04/2019  spira76548: Ajout condition Yearly/Quarterly
# [007] 26/02/2021 M.NAJI Spira 91531  commenter les suppression des fichier permanents
#======================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters
BALSHTYEA_NF=$1
CRE_D=$2
CLODAT_D=$3
BALSHTMTH_NF=$4
FORCE_OPENNING=$5

ECHO_LOG "# BALSHTYEA_NF   => $BALSHTYEA_NF"
ECHO_LOG "# CRE_D          => $CRE_D"
ECHO_LOG "# CLODAT_D       => $CLODAT_D"
ECHO_LOG "# BALSHTMTH_NF   => $BALSHTMTH_NF"
ECHO_LOG "# FORCE_OPENNING => $FORCE_OPENNING"

echo ${EST_FESB}
echo ${EST_FAVERATE}
echo ${EST_FIDLIFEST_MVT}
echo ${EST_FIDLIFEST_CALL}
echo ${EST_FSUBTRSBASE}

#[003]
############################################
# SUPPRESSION DES FICHIERS DFILI REDONDANT #
############################################

NSTEP=${NJOB}_040
RMFIL "`dirname ${EST_180_ESTC2040_OLD_LIFEST_O2}`/${NCHAIN}_180_ESTC2040_OLD_LIFEST_O2_*.dat
`dirname ${EST_ERRUPDBATCH}`/${NCHAIN}_ERRUPDBATCH_*.dat
`dirname ${EST_ESTC2040_LAST_LIFEST_O1}`/${NCHAIN}_ESTC2040_LAST_LIFEST_O1_*.dat
`dirname ${EST_FACCTRAA0}`/${NCHAIN}_FACCTRAA0_*.dat
`dirname ${EST_FAVERATE}`/${NCHAIN}_FAVERATE_*.dat
`dirname ${EST_FCURQUOT}`/${NCHAIN}_FCURQUOT_*.dat
`dirname ${EST_FESB}`/${NCHAIN}_FESB_*.dat
`dirname ${EST_FIDLIFEST_CALL}`/${NCHAIN}_FIDLIFEST_CALL_*.dat
`dirname ${EST_FIDLIFEST_MVT}`/${NCHAIN}_FIDLIFEST_MVT_*.dat
`dirname ${EST_FLIFDRI}`/${NCHAIN}_FLIFDRI_*.dat
`dirname ${EST_FLIFEST0}`/${NCHAIN}_FLIFEST${IT}0_*.dat
`dirname ${EST_FSUBSID}`/${NCHAIN}_EST_FSUBSID_*.dat
`dirname ${EST_FSUBTRSBASE}`/${NCHAIN}_FSUBTRSBASE_*.dat
`dirname ${EST_IARVPERICASE4}`/${NCHAIN}_IARVPERICASE4_*.dat
`dirname ${EST_IDAY_CALL}`/${NCHAIN}_EST_IDAY_CALL_*.dat
`dirname ${EST_LIFEST_IDAY}`/${NCHAIN}_EST_LIFEST_IDAY_*.dat
`dirname ${EST_SUBTRS}`/${NCHAIN}_SUBTRS_*.dat
`dirname ${EST_SUBTRSESBPROP}`/${NCHAIN}_SUBTRSESBPROP_*.dat
`dirname ${EST_TCALL}`/${NCHAIN}_TCALL_*.dat
`dirname ${EST_TGAPACCPRO}`/${NCHAIN}_TGAPACCPRO_*.dat
`dirname ${EST_TGAPTHR}`/${NCHAIN}_TGAPTHR_*.dat"

#`dirname ${EST_FCPLACC0}`/${NCHAIN}_FCPLACC0_*.dat

# If the Lifest at 01 January file already exists, we DONT do this
NSTEP=${NJOB}_050
if [ "${IT}" = "Y" ]
then
if [[ $FORCE_OPENNING -eq 3 || ! -e ${DFILP}/${ENV_PREFIX}_EST_ESDJ0110_FLIFEST${IT}_OPENNING_${BALSHTYEA_NF}.dat ]]
    then
	# Extracting Lifest at 01 January
        #------------------------------------------------------------------------------
        LIBEL="Extracting Lifest at 01 January"
        BCP_WAY="OUT"
        BCP_VER="+" 
        BCP_O=${DFILT}/${NSTEP}_${IB}_FLIFEST${IT}_OPENNING.dat
        BCP_QRY="execute BEST..PsLIFEST_09_OUVERTURE ${BALSHTYEA_NF}"
        BCP

        #If FLIFEST_OPENNING extraction fails, job will exit before this, then the file will not be generated
        #------------------------------------------------------------------------------
        #mv ${DFILT}/${NSTEP}_${IB}_FLIFEST_OPENNING.dat ${DFILP}/${ENV_PREFIX}_EST_ESDJ0110_FLIFEST_OPENNING_${BALSHTYEA_NF}.dat

        NSTEP=${NJOB}_055
        # Sorting FIDLIFEST_OPENNING_2015
        #------------------------------------------------------------------------------
        LIBEL="Sorting FIDLIFEST_OPENNING_2015"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_050_${IB}_FLIFEST${IT}_OPENNING.dat 1000 1"
        SORT_O="${DFILP}/${ENV_PREFIX}_EST_ESDJ0110_FLIFEST${IT}_OPENNING_${BALSHTYEA_NF}.dat"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS
              SSD_CF        1:1  -  1:EN,
              CTR_NF        2:1  -  2:,
              SEC_NF        4:1  -  4:EN,
              UWY_NF        5:1  -  5:EN,
              ACY_NF        7:1  -  7:EN,
              DETTRNCOD_CF  20:1 - 20:EN,
              GAAP_NF       22:1 - 22:EN
        /KEYS
            SSD_CF,
            CTR_NF,
            SEC_NF,
            UWY_NF,
            ACY_NF,
            DETTRNCOD_CF,
            GAAP_NF
        exit
EOF
        SORT
    else
        echo \#-------------------------------------------------------------------------
        echo \#
        echo \#   Le fichier Lifest du premier janvier existe deja, Skipping ${NSTEP}
        echo \#                           ------------
        echo \#         First january file already exist, skipping step ${NSTEP}
        echo \#
        echo \#-------------------------------------------------------------------------
fi
fi

NSTEP=${NJOB}_080
# Testing if BEST..TIDLIFEST_CALL is empty
# ------------------------------------------------------------------------
LIBEL="Testing if BEST..TIDLIFEST_CALL is empty"
BCP_WAY="OUT"
BCP_VER="+" 
BCP_O=${DFILT}/${NSTEP}_${IB}_FIDLIFEST_CALL.dat
BCP_QRY="SELECT TOP 5 * FROM BEST..TIDLIFEST_CALL"
BCP

NSTEP=${NJOB}_090
# Looking for last sucessful inventory
# ------------------------------------------------------------------------
LIBEL="Testing testing last succeded closing"
BCP_WAY="OUT"
BCP_VER="+" 
BCP_O="${DFILP}/${NSTEP}_LSTCLOSING.dat"
BCP_QRY="SELECT MAX(DBCLO_D) FROM BEST..TREQJOBPLAN WHERE REQCOD_CT='D' AND END_D is not null AND site_cf='${HOST_PRDSIT}'"
BCP

NSTEP=${NJOB}_095
# Suppression du ficher CALL
# ------------------------------------------------------------------------
RMFIL ${EST_FIDLIFEST_CALL}

# If calling table (BEST..TIDLIFEST_CALL) is empty we dont extract files.
if [[ -s ${DFILT}/${NJOB}_080_${IB}_FIDLIFEST_CALL.dat ]]
    then

    NSTEP=${NJOB}_100
    # Extracting TESB for Intraday
    #------------------------------------------------------------------------------
    LIBEL="Extracting TESB for Intraday"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${EST_FESB}
    BCP_QRY="execute BREF..PsTESB_01"
    BCP
    

    NSTEP=${NJOB}_120
    # Extracting TAVERATE for Intraday
    # ------------------------------------------------------------------------------
    LIBEL="Extracting TAVERATE for Intraday"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${EST_FAVERATE}
    BCP_QRY="execute BREF..PsTAVERATE_01 '${CRE_D}'"
    BCP


    NSTEP=${NJOB}_150
    # Extracting last mvt Lifest
    #------------------------------------------------------------------------------
    LIBEL="Extracting last mvt Lifest"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${EST_FIDLIFEST_MVT}
    BCP_QRY="execute BEST..PsLIFEST_09_ID2 ${BALSHTYEA_NF}"
    # BCP_QRY="execute BTRAV..PsLIFEST_09_ID2 ${BALSHTYEA_NF}"
    BCP
    
    
    NSTEP=${NJOB}_200
    # Extracting Call table for Intraday
    #------------------------------------------------------------------------------
    LIBEL="Extracting Call table for Intraday"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${EST_FIDLIFEST_CALL}
    BCP_QRY="execute BEST..PsIDLIFEST_CALL_01 ${BALSHTYEA_NF}"  # [005]
    BCP

    gzip -c ${EST_FIDLIFEST_CALL}        > ${DFILI}/${NSTEP}_FIDLIFEST_CALL_${IB}.dat.gz # [004]

    NSTEP=${NJOB}_210
    # Extracting FSUBTRSBASE for Intraday
    #------------------------------------------------------------------------------
    LIBEL="Extracting FSUBTRSBASE for Intraday"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${EST_FSUBTRSBASE}
    BCP_QRY="execute BEST..PsSUBTRSBASE_01"
    BCP
fi


NSTEP=${NJOB}_220
# Testing if BTRAV..TCALL is empty
# -----------------------------------------------------------------------
LIBEL="Testing if BEST..TCALL is empty"
BCP_WAY="OUT"
BCP_VER="+" 
BCP_O=${DFILT}/${NSTEP}_${IB}_TCALL.dat
BCP_QRY="SELECT TOP 5 * FROM  BEST..TCALL"
BCP


# If calling table (BEST..TCALL) is empty we dont extract files.
if [[ ${DFILT}/${NJOB}_220_${IB}_TCALL.dat ]];
    then
    
    if [ "${IT}" = "Y" ]
    then
    NSTEP=${NJOB}_250
    # Extracting EST_FLIFEST0 for Intraday
    #------------------------------------------------------------------------------
    LIBEL="Extracting EST_FLIFEST0 for Intraday"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${DFILT}/${NSTEP}_${IB}_LIFEST.dat
    BCP_QRY="execute BEST..PsLIFEST_09_ID1"
    BCP

    NSTEP=${NJOB}_300
    #------------------------------------------
    # Suppression des notifications sans UWGRP 
    # (car pas d'UWGRP dans le perimetre retro pour l'instant)
    #------------------------------------------
    set -x
    grep -v "~$" ${DFILT}/${NJOB}_250_${IB}_LIFEST.dat | sort | uniq > ${EST_FLIFEST0}
    set +x

    else

    NSTEP=${NJOB}_250
    # Extracting EST_FLIFEST0 for Intraday
    #------------------------------------------------------------------------------
    LIBEL="Extracting EST_FLIFEST0 for Intraday"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${DFILT}/${NSTEP}_${IB}_LIFEST.dat
    BCP_QRY="execute BEST..PsLIFEST_10_ID1"
    BCP

    NSTEP=${NJOB}_300
    #------------------------------------------
    # Suppression des notifications sans UWGRP
    # (car pas d'UWGRP dans le perimetre retro pour l'instant)
    #------------------------------------------
    set -x
    grep -v "~$" ${DFILT}/${NJOB}_250_${IB}_LIFEST.dat | sort | uniq > ${EST_FLIFEST0}
    set +x

    fi    

    NSTEP=${NJOB}_350
    # Extracting Call table for Intraday
    #------------------------------------------------------------------------------
    LIBEL="Extracting Call table for Intraday"

    BCP_WAY="OUT"
    BCP_VER="+" 
    BCP_O=${EST_TCALL}
    BCP_QRY="execute BEST..PsTCALL_ID"
    BCP

    gzip -c ${EST_TCALL}        > ${DFILI}/${NSTEP}_EST_TCALL_${IB}.dat.gz # [004]

    NSTEP=${NJOB}_400
    # Extracting TGAPTHR for Intraday
    #------------------------------------------------------------------------------
    LIBEL="Extracting TGAPTHR for Intraday"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${EST_TGAPTHR}
    BCP_QRY="execute BEST..PsTGAPTHR_ID"
    BCP

    NSTEP=${NJOB}_450
    # Current Generation of Complete Accounts Files
    #------------------------------------------------------------------------------
    LIBEL="Current Generation of Complete Accounts Files"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${EST_FCPLACC0}
    BCP_QRY="execute BEST..PsCPLACC_02 '${CLODAT_D}'"
    BCP
fi

# NSTEP=${NJOB}_500
# # Erase temporary files [002][003]
# #------------------------------------------------------------------------------
# LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${DFILT}/${NJOB}_080_*_FIDLIFEST_CALL.dat"

JOBEND
