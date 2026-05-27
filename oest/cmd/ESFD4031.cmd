#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Mapping Code Component Mapping
# nom du script SHELL           : ESFD4031.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 04/01/2021
# auteur                        : Nhat Linh DOAN
# references des specifications : REQ 20.1
#-----------------------------------------------------------------------------
# description
#  : SPIRA 83101  :   Transcode Transformation between GAAPs
#
# Asynchronous Job launched by the TP 
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 04/01/2021 : SPIRA 83101 : NLD : generate file EST_GAAPMAP for all closing
#[002] 04/27/2022 : SPIRA 103672: Remove bcp, add it to ESFD0062/ESPD0061
#===============================================================================

# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

EST_FGAAPMAP_ASSUMED="$1"
EST_FGAAPMAP_RETRO="$2"


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
ECHO_LOG "#===> EST_FGAAPMAP_ASSUMED .................: ${EST_FGAAPMAP_ASSUMED}"
ECHO_LOG "#===> EST_FGAAPMAP_RETRO ...................: ${EST_FGAAPMAP_RETRO}"

#[002]
#NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
#LIBEL="Generation of the file GAAPCOD_MAPPING using Norme"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_GAAPMAP.dat
#BCP_QRY="execute BREF..PsGAAPMAP_01 '${NORME_CF}', '${PARM_CRE_D}'"
#BCP

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="sort GAAPMAP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GAAPMAP} 1000 1"
SORT_O="${EST_FGAAPMAP_ASSUMED} 1000 1"
SORT_O2="${EST_FGAAPMAP_RETRO} 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	ORIGAPACMTRS_NT 1:1 - 1:,
	ORIACMTRS_NT 	2:1 - 2:, 
	ORIDETTRS_CF 	3:1 - 3:, 
	ORIDETTRS1_CF   3:1 - 3:1,	
	TARGAPACMTRS_NT 4:1 - 4:,  
	TARGACMTRS_NT   5:1 - 5:, 
	TARGDETTRS1_CF  6:1 - 6:1,
	TARGDETTRS_CF   6:1 - 6:
/KEYS   ORIGAPACMTRS_NT,
	ORIACMTRS_NT, 
	ORIDETTRS_CF, 
	TARGAPACMTRS_NT,  
	TARGACMTRS_NT, 
	TARGDETTRS_CF
/CONDITION RETRO (TARGDETTRS1_CF = "2" or TARGDETTRS1_CF = "4") and (ORIDETTRS1_CF = "2" or ORIDETTRS1_CF = "4")
/CONDITION ASUMMED ((TARGDETTRS1_CF = "1" or TARGDETTRS1_CF = "3") and (ORIDETTRS1_CF = "1" or ORIDETTRS1_CF = "3")) or ((TARGDETTRS1_CF = "2" or TARGDETTRS1_CF = "4") and (ORIDETTRS1_CF = "2" or ORIDETTRS1_CF = "4")
)
/OUTFILE ${SORT_O} overwrite
/INCLUDE ASUMMED
/OUTFILE ${SORT_O2} overwrite
/INCLUDE RETRO

exit
EOF
SORT


wc -l ${EST_FGAAPMAP_ASSUMED}
 
wc -l ${EST_FGAAPMAP_RETRO}


JOBEND 
