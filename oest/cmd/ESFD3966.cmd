#!/bin/ksh
#=============================================================================
# nom de l'application     : ESTIMATIONS - close recover mode
# nom du script SHELL      : ESFD3966.cmd
# auteur                   : JYP+TD
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001]	23/05/2023 JYP/TD  :spira:109816: recover mode 
#[002]	25/04/2023 JYP/TD  :spira:111359: bugfix filename 
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctftp.cmd


# Job Initialisation
JOBINIT



ECHO_LOG "#========================================================================="
ECHO_LOG "-> ESF_FTECLEDA_MVT_TMP .......: ${ESF_FTECLEDA_MVT_TMP}"
ECHO_LOG "-> ESF_FTECLEDA_MVT ...........: ${ESF_FTECLEDA_MVT}"
ECHO_LOG "-> RECOVERY_MODE       ........: ${RECOVERY_MODE}"
ECHO_LOG "#========================================================================="


#================ close recover mode		
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="set RECOVERY_MODE from Y to N into ESFD3460_RECOVERY_${NORME_CF}.prm  "
AWK_I=${DPRM}/ESFD3460_RECOVERY_${NORME_CF}.prm
AWK_O=${DFILT}/${NSTEP}_${IB}_CLOSE_RECOVERY_${NORME_CF}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
{ 
if (substr(\$1,1,13) != "RECOVERY_MODE" ) 
	{print \$0;}
}
END { print "RECOVERY_MODE N";}
exit
EOF
AWK
cp -p ${DFILT}/${NJOB}_10_${IB}_CLOSE_RECOVERY_${NORME_CF}.dat ${DPRM}/ESFD3460_RECOVERY_${NORME_CF}.prm
					
	

JOBEND

