#!/bin/ksh
#=============================================================================
# nom de l'application          : Adding product_id into TTECLEDR
# nom du script SHELL           : ESFD3818.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 14/12/2021
# auteur                        : JYP
# references des specifications : Granularity
#-----------------------------------------------------------------------------
# description
#  - override product code into TECLEDR format		
#

#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 14/12/2021 : SPIRA 101025 : JYP : creation
#[002] 20/12/2021 : SPIRA 101025 : JYP : exclude life
#[003] 20/12/2021 : SPIRA 101025 : JYP : new output file ESF_FCTRI17PRD_OVR
#[004] 22/12/2021 : SPIRA 101025 : JYP : retro : R02 prod code to change
#[005] 04/07/2022 : SPIRA 104778: JBD : Build new closing for I17S norm 
#[006] 24/10/2022 : SPIRA 107336: JYP : spiras 107336 100748, rework override retro 
#===============================================================================

# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

EST_BASE=`basename "${1%.*}"`
ESF_FCTRI17PRD_NEW="$2"
EST_OUT="$1"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CONTEXT_CT.................: ${CONTEXT_CT}  "
ECHO_LOG "#===> PARM_ICLODAT_D.............: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"


ECHO_LOG "#===> ............INPUT ................................................."
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW  .................: ${ESF_FCTRI17PRD_NEW}"
ECHO_LOG "#===> EST_OUT  ............................: ${EST_OUT}"
ECHO_LOG "#===> ESF_FI17PRODUCT_CUR  ................: ${ESF_FI17PRODUCT_CUR} "
ECHO_LOG "#===> ............OUTPUT ................................................."
ECHO_LOG "#===> EST_OUT .............................: ${EST_OUT}"
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR .................: ${ESF_FI17PRODUCT_OVR}"
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR  .................: ${ESF_FCTRI17PRD_OVR}"


case "${PARM_BATCHUSER}" in
        "ubas") PREFIX="AS" ;;
        "ubeu") PREFIX="EU" ;;
        "ubam") PREFIX="AM" ;;
        *)   STEPEND 10 ;; 
esac


ECHO_LOG "#===> ............................................................."
ECHO_LOG "#===> PREFIX       .................: ${PREFIX} "
ECHO_LOG "#===> PARM_BATCHUSER       .........: ${PARM_BATCHUSER} "

ECHO_LOG "BEFORE : stats product for EST_OUT=$EST_OUT "
cat $EST_OUT | cut -d~ -f65| cut -c1-2 | sort | uniq -c
 
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="RETRO TTECLEDR : split input ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EMPTY.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_PRDCODE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
		TRNCOD_CF1		    6:1 - 6:1,
        RETCTR_NF           24:1 - 24:,
        RETEND_NT           25:1 - 25:,
        RETSEC_NF           26:1 - 26:,
        RETRTY_NF           27:1 - 27:,
        RETUW_NT            28:1 - 28:,
		LOBRET_CF			45:1 - 45:,			
        I17PRDCOD_CT_12     65:1 - 65:2,
        I17PRDCOD_CT        65:1 - 65:
/KEYS  RETCTR_NF
/CONDITION COD_KO ( I17PRDCOD_CT = "" )  
/OUTFILE ${SORT_O}
/INCLUDE COD_KO
/OUTFILE ${SORT_O2}
/OMIT COD_KO


exit
EOF
SORT



NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="RETRO TTECLEDR : add defaulting product code into RETRO_EMPTY"
ECHO_LOG "-----------------------------------------------------" 
ECHO_LOG "Step $NSTEP $LIBEL" 
AWK_I=${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_EMPTY.dat
AWK_O=${DFILT}/${NJOB}_20_${IB}_${EST_BASE}_EMPTY_UPDATED.dat

awk -v nbfields="71" -v site="$PARM_BATCHUSER"  '
BEGIN{ FS="~";
       OFS="~";
     }
 {
    PRDRET="";

   if (substr($6,1,1) == "2" || substr($6,1,1) == "4" )
        AR="R";
   else AR="A";

   typ="PC";
   if ($45 == "30" || $45 == "31")
      typ="LIFE";

 		
  if ( site == "ubas" && nbfields == "71" && $65 == "" )
  {
    if (AR == "R" && typ == "PC")
	PRDRET="PCRETAS000";
    if (AR == "R" && typ == "LIFE" )
    PRDRET="SGLRETAS00";
  }  
  else if ( site == "ubeu" && nbfields == "71" && $65 == ""  )
  {
    if (AR == "R" && typ == "PC")
	PRDRET="PCRETEU000";
    if (AR == "R" && typ == "LIFE" )
    PRDRET="SGLRETEU00"; 	
  }  
  else if ( site == "ubam" && nbfields == "71" && $65 == "" )
  {
    if (AR == "R" && typ == "PC")
	PRDRET="PCRETAM000";
    if (AR == "R" && typ == "LIFE" )
    PRDRET="SGLRETAM00";		
  }  
  
  if ( nbfields == "71" && $65 == ""  )
  {
    if (AR == "R")
    $65=PRDRET;
  }

  print $0;
 }
' $AWK_I > $AWK_O 
RC=$?
nb_ovr=`wc -l $AWK_O  | cut -d" " -f1  ` 
ECHO_LOG "Step $NSTEP : nb_ovr=$nb_ovr return code = $RC "
ls -ltr $AWK_O
wc -l $AWK_O


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------

if [ $nb_ovr -gt 0 ]
then
#------------------------------------------------------------------------------------
LIBEL="merge files to ouput ${EST_OUT}"
SORT_I="${DFILT}/${NJOB}_20_${IB}_${EST_BASE}_EMPTY_UPDATED.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_PRDCODE.dat 2000 1"
SORT_O="${EST_OUT} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        RETCTR_NF        24:1  - 24:,
        FORMAT_71       1:1   - 71:
/KEYS RETCTR_NF 
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT

else
	ECHO_LOG "===> /!\ $NSTEP : nothing updated into $EST_OUT, nb_ovr=$nb_ovr  "
fi 
	
	
	

JOBEND


