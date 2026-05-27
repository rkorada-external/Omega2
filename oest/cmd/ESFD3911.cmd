#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Mapping Code Component Mapping
# nom du script SHELL           : ESFD3911.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 30/06/2020
# auteur                        : S.Behague
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  : SPIRA 87674  :   IFRS 17 - Omega SAP interface - SAS Engine transactions management
#  - Injection of gaap code into TECLEDA format		
#
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
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


ECHO_LOG "#===> ............INPUT ................................................."
ECHO_LOG "#===> EST_GAAPCOD_MAPPING .................: ${EST_GAAPCOD_MAPPING}"
ECHO_LOG "#===> ............OUTPUT ................................................."
ECHO_LOG "#===> EST_OUT .............................: ${EST_OUT}"

 
EST_OUT="$1"

EST_BASE=`basename "${1%.*}"`
EST_GAAPCOD_MAPPING="$2"

 
ECHO_LOG "#===> EST_GAAPCOD_MAPPING .................: ${EST_GAAPCOD_MAPPING}"
ECHO_LOG "#===> ............OUTPUT ................................................."
ECHO_LOG "#===> EST_OUT .............................: ${EST_OUT}"
ECHO_LOG "#===> EST_BASE.............................: ${EST_BASE}"

#JOBEND
 
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="sort input ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_CUR.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_PREV.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 - 1:,
        ESB_CF            2:1 - 2:,
        BALSHEY_NF        3:1 - 3: EN,
        BALSHRMTH_NF      4:1 - 4: EN,
        BALSHRDAY_NF      5:1 - 5: EN,
        DETTRS_CF         6:1 - 6:,
	GAAPCOD_NF	111:1 - 111:         
/KEYS   SSD_CF,
        ESB_CF,
        DETTRS_CF
/CONDITION POST_CUR ( GAAPCOD_NF = "" )
/OUTFILE ${SORT_O}
/INCLUDE POST_CUR
/OUTFILE ${SORT_O2}
/OMIT POST_CUR

exit
EOF
SORT



#${EST_OUT}
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="join GAAPCOD to ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_CUR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_CUR_GAAPCOD.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS S_SSD_CF            1:1 - 1:,
        S_ESB_CF            2:1 - 2:,
        S_DETTRS_CF         6:1 - 6:,
        S_HEAD              1:1 - 110:,
        S_TAIL              112:1 - 118:,
        SSD_CF            1:1 - 1:,
        ESB_CF            2:1 - 2:,
        DETTRS_CF         3:1 - 3:,
        GAAPCOD_CT        4:1 - 4:
/JOINKEYS
        S_SSD_CF,
        S_ESB_CF,
        S_DETTRS_CF
/INFILE ${EST_GAAPCOD_MAPPING} 2000 1 "~"
/JOINKEYS
        SSD_CF,
        ESB_CF,
        DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD, rightside : GAAPCOD_CT , leftside : S_TAIL
exit
EOF
SORT


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="merg files to ouput ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_${EST_BASE}_CUR_GAAPCOD.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_PREV.dat 2000 1"
SORT_O="${EST_OUT} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 - 1:,
        ESB_CF            2:1 - 2:,
        DETTRS_CF         6:1 - 6:        
/KEYS   SSD_CF,
        ESB_CF,
        DETTRS_CF

/OUTFILE ${SORT_O} OVERWRITE

exit
EOF
SORT

JOBEND


