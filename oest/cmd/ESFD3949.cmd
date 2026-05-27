#!/bin/ksh
#=============================================================================
# nom de l'application          : override product_id into TTECLEDA
# nom du script SHELL           : ESFD3849.cmd
# date de creation              : 14/12/2021
# auteur                        : JYP
# references des specifications : Granularity
#-----------------------------------------------------------------------------
# description
#  - override product code into TECLEDA format		
#

#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 14/12/2021 : SPIRA 101025 : JYP : creation : missing retro product code
#[002] 20/12/2021 : SPIRA 101025 : JYP : exclude life
#[003] 20/12/2021 : SPIRA 101025 : JYP : new output file ESF_FCTRI17PRD_OVR
#[004] 21/12/2021 : SPIRA 101025 : JYP : retro : R02 prod code to change
#[005] 24/12/2021 : SPIRA 101025 : JYP : retro : optimisation for big files
#[006] 24/12/2021 : SPIRA 101025 : JYP : retro : init ESF_FCTRI17PRD_OVR 
#[007] 04/07/2022 : SPIRA 104778 : JBD : Build new closing for I17S norm 
#[008] 24/10/2022 : SPIRA 107336 : JYP : spiras 107336 100748, rework override retro 
#[009] 23/08/2023 : SPIRA 999999 : JYP : optimisation step 60 KO on INT-EU volume Q4 KO
#[010] 05/02/2025 : SPIRA 112713 : JYP : PROD- Closing performance
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
ECHO_LOG "#===> PARM_CRE_D.................: ${PARM_CRE_D}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"


ECHO_LOG "#===> ............INPUT ................................................."
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW  .................: ${ESF_FCTRI17PRD_NEW}"
ECHO_LOG "#===> EST_OUT  ............................: ${EST_OUT}"
ECHO_LOG "#===> ESF_FI17PRODUCT_CUR  ................: ${ESF_FI17PRODUCT_CUR} "

ECHO_LOG "#===> ............OUTPUT ................................................."
ECHO_LOG "#===> EST_OUT .............................: ${EST_OUT}"
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR .................: ${ESF_FI17PRODUCT_OVR}"
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR  .................: ${ESF_FCTRI17PRD_OVR} "


case "${PARM_BATCHUSER}" in
        "ubas") PREFIX="AS" ;;
        "ubeu") PREFIX="EU" ;;
        "ubam") PREFIX="AM" ;;
             *) STEPEND 10 ;;
esac


ECHO_LOG "#===> ............................................................."
ECHO_LOG "#===> PARM_BATCHUSER  ..............: ${PARM_BATCHUSER} "
ECHO_LOG "#===> PREFIX       .................: ${PREFIX} "

#ECHO_LOG "BEFORE : stats product for EST_OUT=$EST_OUT "
#cat $EST_OUT | cut -d~ -f112 | cut -c1-2 | sort | uniq -c


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="split empty prod_code with others, input ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PRD_KO.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        TRNCOD_CF1      6:1  - 6:1,
        RETCTR_NF       24:1 - 24:,	
        LOBACC_CF       45:1 - 45:,	
        LOBRET_CF       46:1 - 46:,
        I17PRDCOD_CT_12 112:1 - 112:2,
        I17PRDCOD_CT   112:1 - 112:
/CONDITION PRODUCT_KO ( I17PRDCOD_CT = "" ) 
/OUTFILE ${SORT_O}
/INCLUDE PRODUCT_KO
/OUTFILE ${SORT_O2}
/OMIT PRODUCT_KO
exit
EOF
SORT



NSTEP=${NJOB}_40
#------------------------------------------------------------------------------------
LIBEL="add defaulting product code"
ECHO_LOG "-----------------------------------------------------" 
ECHO_LOG "Step $NSTEP $LIBEL" 
AWK_I=${DFILT}/${NJOB}_30_${IB}_PRD_KO.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_PRDCOD_UPDATED.dat

awk -v nbfields="118" -v site="$PARM_BATCHUSER"  '
BEGIN{ FS="~";
       OFS="~";
     }
 {
   PRDACC="";
   PRDRET="";

   if (substr($6,1,1) == "2" || substr($6,1,1) == "4" )
        AR="R";
   else AR="A";

   typ="PC";
   if ( AR == "R" && ($46 == "30" || $46 == "31") )
      typ="LIFE";
   if ( AR == "A" && ($45 == "30" || $45 == "31") )
      typ="LIFE";
 		
  if ( site == "ubas" && nbfields == "118"  )
  {
    if (AR == "A" && typ == "PC" )
	PRDACC="PCACCAS000";
    if (AR == "R" && typ == "PC")
	PRDRET="PCRETAS000";
    if (AR == "A" && typ == "LIFE" )
    PRDACC="SGLACCAS00";
    if (AR == "R" && typ == "LIFE" )
    PRDRET="SGLRETAS00";
  }  
  else if ( site == "ubeu" && nbfields == "118"   )
  {
    if (AR == "A" && typ == "PC" )
	PRDACC="PCACCEU000";
    if (AR == "R" && typ == "PC")
	PRDRET="PCRETEU000";
    if (AR == "A" && typ == "LIFE" )
    PRDACC="SGLACCEU00";
    if (AR == "R" && typ == "LIFE" )
    PRDRET="SGLRETEU00"; 	
  }  
  else if ( site == "ubam" && nbfields == "118"  )
  {
    if (AR == "A" && typ == "PC" )
	PRDACC="PCACCAM000";
    if (AR == "R" && typ == "PC")
	PRDRET="PCRETAM000";
    if (AR == "A" && typ == "LIFE" )
    PRDACC="SGLACCAM00";
    if (AR == "R" && typ == "LIFE" )
    PRDRET="SGLRETAM00";		
  }  
  
  if ( nbfields == "71" && $65 == ""  )
  {
    if (AR == "A")
    $65=PRDACC;
    if (AR == "R")
    $65=PRDRET;
  }
  else if ( nbfields == "118" )
  {
    if (AR == "A")
    $112=PRDACC;
    if (AR == "R")
    $112=PRDRET;
  }  

  print $0;
 }
' $AWK_I > $AWK_O 
RC=$?
nb_ovr=`wc -l $AWK_O  | cut -d" " -f1  ` 
ECHO_LOG "Step $NSTEP : nb_ovr=$nb_ovr return code = $RC "
ls -ltr $AWK_O >> $FLOG


NSTEP=${NJOB}_50
#------------------------------------------------------------------------------------
LIBEL="RETRO : initialisation OVERRIDE files  "
EXECKSH_MODE=P
EXECKSH "echo init ESF_FCTRI17PRD_OVR=$ESF_FCTRI17PRD_OVR  "
> $ESF_FCTRI17PRD_OVR

EXECKSH_MODE=P
EXECKSH "echo init ESF_FI17PRODUCT_OVR=$ESF_FI17PRODUCT_OVR  "	
> $ESF_FI17PRODUCT_OVR



NSTEP=${NJOB}_60

if [[ $nb_ovr -gt 0 ]] 
then
	ECHO_LOG "STEP $NSTEP : override ${EST_OUT} $nb_ovr to update "
	date >> $FLOG 
	cat ${DFILT}/${NJOB}_40_${IB}_PRDCOD_UPDATED.dat ${DFILT}/${NJOB}_30_${IB}_OTHERS.dat > ${EST_OUT}	
	wc -l ${EST_OUT} >> $FLOG 
	ls -ltr ${EST_OUT} >> $FLOG 
	date >> $FLOG 

else
	ECHO_LOG "===> /!\ $NSTEP : nothing updated into $EST_OUT, nb_ovr=$nb_ovr  "
fi 
	
	
JOBEND


