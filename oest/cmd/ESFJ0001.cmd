#!/bin/ksh
#=============================================================================
# nom de l'application          :  SET Closing plans and parameters
# nom du script SHELL           : ESFJ0002.cmd
# revision                      : 
# date de creation              : 28/02/2019
# auteur                        : ASCOTT(M.NAJI)
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Preparing parametrs files and planning executions
#
# job launched by ESFJ0000.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : 
#Auteur         : M.NAJI
#Date           : 28/02/2019
#Version        : 1.0
#Description    : extraction des ficers Plan, Paramètres et permanents
#===============================================================================
#[001] 04/11/2019 RC  :spira:81934 Ajout sauvegarde des fichiers PLAN-PARM
#[002] 09/04/2019 M.NAJI 85707  suppression des anciens fichiers 
#[003] 16/09/2020 M.NAJI 87596  migration des planification IFRS4 et EBS 
#[004] 22/12/2020 : M.NAJI :. SPIRA 91531 
#					       . Calcul des paramètre par norme
#					       . export des conditions dans un fichier à part 
#						   . add gzip of PLAN_EPO
#[005] 18/03/2021 : M.NAJI :. SPIRA  92023 check Requests
#[006] 18/06/2021  :M.NAJI SPIRA 97241 ajoute temporairement de la table TI17PERMFIL_3K pour tester le //Run
#[007] 27/06/2022 :M.NAJI SPIRA 105281  update TACCSUP temporaire pour la prod
#[008] 30/08/2022 :M.NAJI SPIRA 105283 : DryRun- EBS AE management, update TACCSUP temporaire pour la prod 
#[008] 12/11/2025 : M.NAJI US7376 Remove TACCSUP update in ESFJ0001

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
CRE_D=$1

set `GETPRM ${DPRM}/ESFJ0000.prm` 
export TI17PERMFIL=$1
export DATE_DEB=$2
export DATE_FIN=$3

ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D .................: ${CRE_D}"
ECHO_LOG "-> TI17PERMFIL ...........: ${TI17PERMFIL}"
ECHO_LOG "-> DATE_DEB ..............: ${DATE_DEB}"
ECHO_LOG "-> DATE_FIN ..............: ${DATE_FIN}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_05
#---------------------------------------------------------------
LIBEL="clean permanent files  "
RMFIL "$DFILP/${NCHAIN}_*"


NSTEP=${NJOB}_15
#---------------------------------------------------------------
LIBEL="Extract conditions file  "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_COND.dat
BCP_QRY="exec BEST..PsIfrs17Cond_01 '$CRE_D'" 
BCP


NSTEP=${NJOB}_20
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_25
#---------------------------------------------------------------
LIBEL="Extract conditions file  "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_SUFFTABLE.dat
BCP_QRY="select FIELD2_CF ICLODAT_CF,
	substring(FIELD1_CF,1,4) BALSHTYEA_NF , 
	substring(FIELD1_CF,5,2) BALSHTMTH_NF, 
	'export PARM_SUFFTABLE='+substring(reverse(TABCIBLE_CF),1,1)
	from BSAR..TBOPAR 
	where DMN_CF='EST' 
	and TAB_CF='TTECLEDA' 
	and (PAR_D=NULL or PAR_D='')  
	and ARCH_B=0" 
BCP

NSTEP=${NJOB}_30
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in server"
SWITCH_SRV ${SRV_DEFAULT}

NSTEP=${NJOB}_35
#---------------------------------------------------------------
LIBEL="Extract all parametrs   "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_PARM.dat
BCP_QRY="exec BEST..PsIfrs17Param_02 '$CRE_D' "
BCP

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL=LIBEL="split parameters by norme    "
AWK_I=${DFILP}/${NCHAIN}_PARM.dat
AWK_O=${DFILP}/${NCHAIN}_PARM_O.dat
AWK_CMD=`CFTMP`
AWK_PARAM="-v fil=${DFILP}/${PCH}ESFJ0000_PARM_"
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
	norme=\$1;
	outF=sprintf("%s%s.dat",fil,norme);
	print "export "\$2"=\"\$3\"" > outF  ; 
}
exit
EOF
AWK


NSTEP=${NJOB}_45
#---------------------------------------------------------------
LIBEL="extract plan file  "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_PLAN_IFRS17.dat
BCP_QRY="exec BEST..PsPlan_03  '$CRE_D'"
BCP

#[006]
NSTEP=${NJOB}_50
#---------------------------------------------------------------
LIBEL="extract  BEST..TIFRS17PERM table  "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_TI17PERMFIL.dat
BCP_QRY="  
	declare @mode varchar(20) 
	select @mode = '${TI17PERMFIL}'
	declare @erreur int

	declare @PARM_BATCHUSER varchar(20)
	select @PARM_BATCHUSER = suser_Name()


	select p.* from BEST..TI17PERMFIL p
	LEFT OUTER JOIN BEST..TI17TRAPERMFIL tr on    p.IDF_CT = tr.IDF_CT and 
												p.PERMFIL_CT = tr.PERMFIL_CT  and 
												'TI17TRAPERMFIL' = @mode
	where tr.IDF_CT = NULL
	UNION
	select *  from BEST..TI17TRAPERMFIL  
	WHERE 'TI17TRAPERMFIL' = @mode
	order by 1 , 2
	
"  
BCP


NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
LIBEL=LIBEL="split plan by norme    "
AWK_I=${DFILP}/${PCH}ESFJ0000_PLAN_IFRS17.dat
AWK_O=${DFILP}/${PCH}ESFJ0000_PLAN.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{

        norme=\$5;
        per_cf=$1;
        print "export EST_"\$3"_"\$4"_GONOGO=Y" 

}
exit
EOF
AWK

NSTEP=${NJOB}_95
# Gzip plans and parms
#---------------------------------------------------------------
LIBEL="Gzip plan and parm"
EXECKSH_MODE=P
for fic in `ls ${DFILP}/${NCHAIN}*.dat`
do
	fic2=`echo ${fic} | cut -d"_" -f2-10`
	ECHO_LOG "gzip -c ${fic} > ${DSAV}/${SVG}_${ENV_PREFIX}_${fic2}.gz"
	gzip -c ${fic} > ${DSAV}/${SVG}_${ENV_PREFIX}_${fic2}.gz
done


# End of Job
JOBEND
