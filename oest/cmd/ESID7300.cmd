#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATIONS - INVENTAIRE
#                               Chaine de d‚versement du closing dans le retard r‚tro
# nom du script SHELL		: ESID7300.cmd
# revision			        : $Revision:   1.0  $
# date de creation		    : 18/06/2010
# auteur			        : Dominique OURMIAH
#-----------------------------------------------------------------------------
# description
# D‚versement du closing dans le retard r‚tro
#-----------------------------------------------------------------------------
# historique des modifications
# OLE - 29/10/2010 - Utilisation paramètres du .prm en priorité
#[002] - CCH - 23/09/2015: Addition of a new parameter Simulation Closing mode. Only used in ESID7301.
#[003] - L. Rakotozafy - 18/10/2023 - User Story 737 - Dette technique - Decommissioning Infocentre (TTECLEDA)
#===============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

#[003]
# CLODAT_D YYYYMMDD
# SIMMOD_B 0 real - 1 simulation
ECHO_LOG "#========================================================================="
ECHO_LOG "===> SET DEVERSEMENT CLOSING PARAMETERS ESID7300 <=== "
ECHO_LOG "#========================================================================="

P_CLODAT_D=$(echo $2 | grep -E "^(19[0-9]{2}|[2-9][0-9]{3})(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$" )
P_SIMMOD_B=$(echo $3 | grep -E "^([0|1])$" )
P_BALSHTYEA_NF=$(echo $P_CLODAT_D | cut -c1-4)
P_BALSHTMTH_NF=$(echo $P_CLODAT_D | cut -c5-6)


if [ "${P_CLODAT_D}" != "" ] && [ "${P_BALSHTYEA_NF}" != "" ] && [ "${P_BALSHTMTH_NF}" != "" ] && [ "${P_SIMMOD_B}" != "" ]
then
   CLODAT_D=${P_CLODAT_D}
        ECHO_LOG "#========================================================================="
        ECHO_LOG "#===> CLODAT_D ${CLODAT_D} sent by parm overides .prm data"
        ECHO_LOG "#========================================================================="

        # Modification du .prm
                awk -v var="CLODAT_D" -v valeur="${CLODAT_D}" '{split($0,tab," "); if (tab[1] == var) print var " " valeur; else print $0}' ${DPRM}/ESID7300.prm > ${DFILT}/${NCHAIN}_${IB}_CLODAT_D_ESID7300_prm.log
                scp ${DFILT}/${NCHAIN}_${IB}_CLODAT_D_ESID7300_prm.log ${DPRM}/ESID7300.prm
                ECHO_LOG "#========================================================================="
                ECHO_LOG "#===> .prm modifie ${CLODAT_D} "
                ECHO_LOG "#========================================================================="
    
    BALSHTYEA_NF=${P_BALSHTYEA_NF}
        ECHO_LOG "#========================================================================="
        ECHO_LOG "#===> BALSHTYEA_NF ${BALSHTYEA_NF} sent by parm overides .prm data"
        ECHO_LOG "#========================================================================="

        # Modification du .prm
                awk -v var="BALSHTYEA_NF" -v valeur="${BALSHTYEA_NF}" '{split($0,tab," "); if (tab[1] == var) print var " " valeur; else print $0}' ${DPRM}/ESID7300.prm > ${DFILT}/${NCHAIN}_${IB}_BALSHTYEA_NF_ESID7300_prm.log
                scp ${DFILT}/${NCHAIN}_${IB}_BALSHTYEA_NF_ESID7300_prm.log ${DPRM}/ESID7300.prm
                ECHO_LOG "#========================================================================="
                ECHO_LOG "#===> .prm modifie ${BALSHTYEA_NF} "
                ECHO_LOG "#========================================================================="
               
     BALSHTMTH_NF=${P_BALSHTMTH_NF}
        ECHO_LOG "#========================================================================="
        ECHO_LOG "#===> BALSHTMTH_NF ${BALSHTMTH_NF} sent by parm overides .prm data"
        ECHO_LOG "#========================================================================="
   
        # Modification du .prm
                awk -v var="BALSHTMTH_NF" -v valeur="${BALSHTMTH_NF}" '{split($0,tab," "); if (tab[1] == var) print var " " valeur; else print $0}' ${DPRM}/ESID7300.prm > ${DFILT}/${NCHAIN}_${IB}_BALSHTMTH_NF_ESID7300_prm.log
                scp ${DFILT}/${NCHAIN}_${IB}_BALSHTMTH_NF_ESID7300_prm.log ${DPRM}/ESID7300.prm
                ECHO_LOG "#========================================================================="
                ECHO_LOG "#===> .prm modifie ${BALSHTMTH_NF} "
                ECHO_LOG "#========================================================================="
     
     SIMMOD_B=${P_SIMMOD_B}
        ECHO_LOG "#========================================================================="
        ECHO_LOG "#===> SIMMOD_B ${SIMMOD_B} sent by parm overides .prm data"
        ECHO_LOG "#========================================================================="
        
        # Modification du .prm
                awk -v var="SIMMOD_B" -v valeur="${SIMMOD_B}" '{split($0,tab," "); if (tab[1] == var) print var " " valeur; else print $0}' ${DPRM}/ESID7300.prm > ${DFILT}/${NCHAIN}_${IB}_SIMMOD_B_ESID7300_prm.log
                scp ${DFILT}/${NCHAIN}_${IB}_SIMMOD_B_ESID7300_prm.log ${DPRM}/ESID7300.prm
                ECHO_LOG "#========================================================================="
                ECHO_LOG "#===> .prm modifie ${SIMMOD_B} "
                ECHO_LOG "#========================================================================="
       
fi

# Get input parameters
set `GETPRM ${DPRM}/ESID7300.prm`
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODAT_D=$3
SIMMOD_B=$4

echo ""
echo "BALANCE SHEET YEAR :" ${BALSHTYEA_NF}  "- BALANCE SHEET MONTH :" ${BALSHTMTH_NF}  "- CLOSING DATE :" ${CLODAT_D} "- SIMULATION MODE :" ${SIMMOD_B}
echo ""

# Launch applicative job ESID7301
NJOB="ESID7301"
${DCMD}/ESID7301.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${SIMMOD_B} 2>&1 | ${TEE}

CHAINEND
