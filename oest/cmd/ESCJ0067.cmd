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
#[002] 05/12/2023 : SPIRA 110602: JYP : replace digit 2 by 0 into gaap_code
#[003] 07/08/2025 : SPIRA 113075: JYP : SERQS split files by site 
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
ECHO_LOG "#===> EST_GAAPCOD_MAPPING .................: ${EST_GAAPCOD_MAPPING}"
ECHO_LOG "#===> ESF_GAAPCOD_MAPPING_TOAS .................: ${ESF_GAAPCOD_MAPPING_TOAS}"
ECHO_LOG "#===> ESF_GAAPCOD_MAPPING_TOEU .................: ${ESF_GAAPCOD_MAPPING_TOEU}"
ECHO_LOG "#===> ESF_GAAPCOD_MAPPING_TOAM .................: ${ESF_GAAPCOD_MAPPING_TOAM}"
	
			
NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Generation of the file GAAPCOD_MAPPING for all type of closing"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_GAAPCOD.dat
BCP_QRY="execute BREF..PsGAAPCOD_01"
BCP




NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="update digit 2 to 0 "
AWK_I=${DFILT}/${NJOB}_05_${IB}_BCP_GAAPCOD.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_GAAPCOD_UPDATED.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~"; }
{
			
   if ( \$4 !~ /1/ || \$4 !~ /2/ ) 
   {
    print \$0 ;
   } 
   else 
   {  
	 gsub(\/2\/,"0",\$4); 
     print \$0 ;
   }
}
exit
EOF
AWK

NTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="sort GAAPCOD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_GAAPCOD_UPDATED.dat 1000 1"
SORT_O="${EST_GAAPCOD_MAPPING} 1000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 - 1:,
        ESB_CF            2:1 - 2:,
        DETTRS_CF         3:1 - 3:,
        GAAPCOD_CT        4:1 - 4:     
/KEYS   SSD_CF,
        ESB_CF,
        DETTRS_CF

/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT


NSTEP=${NJOB}_55
#------------------------------------------------------------------------------
LIBEL="copy product link to all sites "
	EXECKSH_MODE=P
	EXECKSH "cp ${EST_GAAPCOD_MAPPING} ${ESF_GAAPCOD_MAPPING_TOAS} "
	EXECKSH_MODE=P
	EXECKSH "cp ${EST_GAAPCOD_MAPPING} ${ESF_GAAPCOD_MAPPING_TOEU} "
	EXECKSH_MODE=P
	EXECKSH "cp  ${EST_GAAPCOD_MAPPING} ${ESF_GAAPCOD_MAPPING_TOAM}"
	

JOBEND 
