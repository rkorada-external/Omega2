#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Mapping Code Component Mapping
# nom du script SHELL           : ESID0083.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 01/04/2020
# auteur                        : Nhat Linh DOAN
# references des specifications : BPR-EST-913082
#-----------------------------------------------------------------------------
# description
#  : SPIRA 83103  :   GAAP Code Referential per T. Code and Ledger creation
#
# Asynchronous Job launched by the TP 
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 01/04/2019 : SPIRA 83103 : NLD : generate file EST_GAAPCOD_MAPPING for all closing
#===============================================================================

# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CONTEXT_CT.................: ${CONTEXT_CT}  "

ECHO_LOG "#===> PARM_ICLODAT_D.............: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}"
ECHO_LOG "#===> PARM_CRE_D.................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_BLCSHTYEA_NF..........: ${PARM_BLCSHTYEA_NF}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"


ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> EST_GAAPCOD_MAPPING .................: ${DFILP}/${PCH}ESID0080_GAAPCOD_MAPPING_${PARM_ICLODAT_D}dat"

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Generation of the file GAAPCOD_MAPPING for all type of closing"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_GAAPCOD.dat
BCP_QRY="execute BREF..PsGAAPCOD_01"
BCP

NTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="sort GAAPCOD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_GAAPCOD.dat 1000 1"
SORT_O="${DFILP}/${PCH}ESID0080_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat 1000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 - 1:,
        ESB_CF            2:1 - 2:,
        DETTRS_CF         3:1 - 3:,
        GAAPCOD_CT        4:1 - 4:     
/KEYS   SSD_CF,
        ESB_CF,
        DETTRS_CF

/OUTFILE ${SORT_O}
exit
EOF
SORT


wc -l ${DFILP}/${PCH}ESID0080_GAAPCOD_MAPPING_${PARM_ICLODAT_D}.dat 



JOBEND 
