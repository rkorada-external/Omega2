#!/bin/ksh
#=============================================================================
# Application name          : ESTIMATION
# source file               : ESIJ7005bis.cmd
# revision                  : 10.2
# creation date             : 09/12/2010
# author                    : D.GATIBELZA
#-----------------------------------------------------------------------------
# description : Integration des mouvements compta dans le GT
#               ESTDOM20828: mouvements comptables non venus dans GLT  sur exercices ou numero ordre  FACULTATIVE  supprimé
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
#-----------------------------------------------------------------
LIBEL="Size of files "
EXECKSH "touch ${EST_GTA} ${EST_GTR} ${EST_FDRYTRN} ${EST_GTASW} ${EST_GTRSW}"
EXECKSH "wc ${EST_GTA} ${EST_GTR} ${EST_FDRYTRN} ${EST_GTASW} ${EST_GTRSW}"



NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Concatenation of files ${EST_GTA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FDRYTRN} 800  1"
SORT_O="${EST_GTA} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_20
# Extraction des fichiers GTASW
#-----------------------------------------------------------------------------
LIBEL="Extraction of GTASW file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FDRYTRN} 1000 1"
SORT_O="${EST_GTASW} APPEND"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF      1:1 - 1:  EN, 
        ESB_CF      2:1 - 2:  EN,
        TRNCOD1_CF  6:1 - 6:1 EN
/CONDITION LIGNESSDESB ( SSD_CF=18 and ESB_CF=3 and TRNCOD1_CF!=2 and TRNCOD1_CF!=4 ) 
/INCLUDE LIGNESSDESB
exit
EOF
SORT

NSTEP=${NJOB}_30
#-----------------------------------------------------------------
LIBEL="delete of files ${EST_FDRYTRN} "
RMFIL "${EST_FDRYTRN}"


NSTEP=${NJOB}_40
#-----------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
