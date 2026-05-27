#!/bin/ksh
#=============================================================================
# nom de l'application : ESTIMATION
# nom du script SHELL  : ESID0105.cmd
# date de creation     : 05/06/2012
# auteur               : Florent
# references des specifications	: :spot:23390 SOLVENCY II
#-----------------------------------------------------------------------------
# description
#   chargement en table des nouvelles courbes de taux
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
# [01] Florent 23/10/2012 :spot:24041 Solvency II
# [02] Florent 11/06/2015 Florent :spot:28941 gestion des patterns inflated
# [03] Florent 09/05/2016 :spot:30535 ajout du traitement des exceptions
# [04] Charles Socie 01/03/2019 spira 076356 ajout step 18 et 19 pour nouvelle colone RATEINDEX
# [05] KBagwe  02/11/2020 : Spira: 89097- REQ 53.3 - Impact on discount pattern load. Step 9, 18
#===============================================================================
. ${DUTI}/fctgen.cmd

#set -x

#- Entry parameters
USR_CF=$1
TYPE_FICHIER=$2
CRE_D="$3"
PER_CF=$4
ICLODAT_D=$5
NORME_CF=$6

# Custumised Error handling
STEPEND_DISPLAY_ANO=YES
EXCEPTION () {
  EXCEPTION_INIT
  if [[ ${STEP_ERR} -ne 0 ]] && [[ ${STEP_STOP} =~ (_10|_20|_25)$ ]]
  then
    #------------------------------------------------------------------------------
    LIBEL="Rollback on imported patterns in error"
    ISQL_QRY="delete TPATTERNSII where CRE_D='${CRE_D}' and CREUSR_CF='${USR_CF}' delete TPATSEGSII where CLODAT_D='${CRE_D}' and PER_CF in('NEW','DUPLI')"
    ISQL_BASE=BEST
    ISQL
  fi
  EXCEPTION_END
}

#Job Initialization
JOBINIT

#Chargement en base des fichiers PATTERNS
EST_FPATTERNSII_BCP_IN=${EST_FPATTERNSII_OUT_1}
if [ "${EST_FPATTERNSII_OUT_2}" != "" ]
then
  if [ ! -s ${EST_FPATTERNSII_OUT_2} -a -s ${EST_FPATTERNSII_OUT_1} ]
  then
    ECHO_LOG "# Fichier ${EST_FPATTERNSII_OUT_2} vide !\n Et Fichier ${EST_FPATTERNSII_OUT_1} plein, anormal !!!"
    STEPEND 1
    JOBEND
  fi

  #ce fichier n'existera pas si il n'y a que des doublons
  if [ -f "${EST_FPATTERNSII_OUT_2}" ]
  then
    NSTEP=${NJOB}_05
    #------------------------------------------------------------------------------
    LIBEL="Ajout de ${EST_FPATTERNSII_OUT_1} \n et ${EST_FPATTERNSII_OUT_2}"
    EXECKSH_MODE=P
    EXECKSH "cat ${EST_FPATTERNSII_OUT_1} ${EST_FPATTERNSII_OUT_2} | sort -u  > ${DFILT}/${NSTEP}_${IB}_PATTERNSII_BCP_IN.dat"
    EST_FPATTERNSII_BCP_IN=${DFILT}/${NSTEP}_${IB}_PATTERNSII_BCP_IN.dat
  fi
fi

if [ -f "${EST_FPATSEGSII_NEW}" ]
then
  NSTEP=${NJOB}_06
  #------------------------------------------------------------------------------
  LIBEL="Ajout de EST_FPATSEGSII_NEW"
  EST_FPATSEGSII_BCP_IN=${DFILT}/${NSTEP}_${IB}_PATSEGSII_BCP_IN.dat
  EXECKSH_MODE=P
  EXECKSH "cat ${EST_FPATSEGSII_NEW} ${EST_FPATSEGSII_DUPLI} > ${EST_FPATSEGSII_BCP_IN}"
else
  EST_FPATSEGSII_BCP_IN=${EST_FPATSEGSII_DUPLI}
fi

if [ ! -s ${EST_FPATTERNSII_BCP_IN} -a ! -s ${EST_FPATSEGSII_BCP_IN} ]
then
  ECHO_LOG "# Fichier ${EST_FPATTERNSII_BCP_IN} \n#      et ${EST_FPATSEGSII_BCP_IN} vide !"
  STEPEND 1
  JOBEND
fi

if [ -s ${EST_FPATTERNSII_BCP_IN} ]
then

if [ "${TYPE_FICHIER}" != "DSC" -o "${NORME_CF}" == "EBS" ]
then	
    NSTEP=${NJOB}_9
    #------------------------------------------------------------------------------
    LIBEL="Add line new NULL columns for RATEINDEX and ESB_CF - TPATTERNSII"
    AWK_I=${EST_FPATTERNSII_BCP_IN}
    AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_ADDNEW_EST_FPATTERNSII_BCP_IN.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN { FS="\~" ; OFS="\~" }
{
if (NF==81){
print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10,\$11,\$12,\$13,\$14,\$15,\$16,\$17,\$18,\$19,\$20,\$21,\$22,\$23,\$24,\$25,\$26,\$27,\$28,\$29,\$30,\$31,\$32,\$33,\$34,\$35,\$36,\$37,\$38,\$39,\$40,\$41,\$42,\$43,\$44,\$45,\$46,\$47,\$48,\$49,\$50,\$51,\$52,\$53,\$54,\$55,\$56,\$57,\$58,\$59,\$60,\$61,\$62,\$63,\$64,\$65,\$66,\$67,\$68,\$69,\$70,\$71,\$72,\$73,\$74,\$75,\$76,\$77,\$78,\$79,\$80,"",\$81
}else{
print \$0,"",""
}
}
exit
EOF
  AWK 	
		
		NSTEP=${NJOB}_9A
		#------------------------------------------------------------------------------
		LIBEL=" Move file from FTP location to temporary location(DFILT)"
		EXECKSH "cp ${DFILT}/${NJOB}_9_${IB}_AWK_ADDNEW_EST_FPATTERNSII_BCP_IN.dat  ${EST_FPATTERNSII_BCP_IN}"
		
else

	NSTEP=${NJOB}_9B
    #------------------------------------------------------------------------------
    LIBEL="Add line new columns for RATEINDEX and I17G - TPATTERNSII"
    AWK_I=${EST_FPATTERNSII_BCP_IN}
    AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_ADDNEW_EST_FPATTERNSII_BCP_IN.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN { FS="\~" ; OFS="\~" }
{
if (NF==81){
print \$1,\$2,\$3,\$4,\$5,\$6,"",\$8,\$9,\$10,\$11,\$12,\$13,\$14,\$15,\$16,\$17,\$18,\$19,\$20,\$21,\$22,\$23,\$24,\$25,\$26,\$27,\$28,\$29,\$30,\$31,\$32,\$33,\$34,\$35,\$36,\$37,\$38,\$39,\$40,\$41,\$42,\$43,\$44,\$45,\$46,\$47,\$48,\$49,\$50,\$51,\$52,\$53,\$54,\$55,\$56,\$57,\$58,\$59,\$60,\$61,\$62,\$63,\$64,\$65,\$66,\$67,\$68,\$69,\$70,\$71,\$72,\$73,\$74,\$75,\$76,\$77,\$78,\$79,\$80,\$7,\$81
}else{
print \$0,"",""
}
}
exit
EOF
  AWK 
		
		NSTEP=${NJOB}_9C
		#------------------------------------------------------------------------------
		LIBEL=" Move file from FTP location to temporary location(DFILT)"
		EXECKSH "cp ${DFILT}/${NJOB}_9B_${IB}_AWK_ADDNEW_EST_FPATTERNSII_BCP_IN.dat  ${EST_FPATTERNSII_BCP_IN}"
	fi

  NSTEP=${NJOB}_10
  #--------------------------------
  LIBEL="BCP des nouvelles courbes de taux ${EST_FPATTERNSII_BCP_IN}"
  BCP_WAY="IN"
  BCP_VER=""
  BCP_I=${EST_FPATTERNSII_BCP_IN}
  BCP_TABLE="BEST..TPATTERNSII"
  BCP
fi

NSTEP=${NJOB}_17
#--------------------------------
LIBEL="delete duplicate ${EST_FPATSEGSII_BCP_IN}"
  EXECKSH_MODE=P
  EXECKSH "sort -u ${EST_FPATSEGSII_BCP_IN} > ${DFILT}/${NSTEP}_${IB}_DELETE_DUPLICATE.dat"

if [ -s ${EST_FPATSEGSII_BCP_IN} ]
then
	if [ "${TYPE_FICHIER}" != "DSC" -o "${NORME_CF}" = "EBS" ]
	then
	NSTEP=${NJOB}_18
	#------------------------------------------------------------------------------
	LIBEL="Add line new NULL columns for RATEINDEX and ESB_CF - TPATSEGSII"
	AWK_I=${DFILT}/${NJOB}_17_${IB}_DELETE_DUPLICATE.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_ADDNEW_RATEINDEX.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN { FS="\~" ; OFS="\~" }
{
if (NF==17){
print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\$8,\$9,\$10,\$11,\$12,\$13,\$14,\$15,\$16,"",\$17
}else{
print \$0,"",""
}
}
exit
EOF
  AWK
		
		NSTEP=${NJOB}_19
		#------------------------------------------------------------------------------
		LIBEL=" Move file from FTP location to temporary location(DFILT)"
		EXECKSH "cp ${DFILT}/${NJOB}_18_${IB}_AWK_ADDNEW_RATEINDEX.dat  ${EST_FPATSEGSII_BCP_IN}"
			
	else
	
NSTEP=${NJOB}_18B
#------------------------------------------------------------------------------
LIBEL="Add line new columns for RATEINDEX and I17 - TPATSEGSII"
AWK_I=${DFILT}/${NJOB}_17_${IB}_DELETE_DUPLICATE.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_ADDNEW_RATEINDEX.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN { FS="\~" ; OFS="\~" }
{
if (NF==17){
print \$1,\$2,\$3,\$4,"",\$6,\$7,\$8,\$9,\$10,\$11,\$12,\$13,\$14,\$15,\$16,\$5,\$17
}else{
print \$0,"",""
}
}
exit
EOF
  AWK
		
		NSTEP=${NJOB}_19
		#------------------------------------------------------------------------------
		LIBEL=" Move file from FTP location to temporary location(DFILT)"
		EXECKSH "cp ${DFILT}/${NJOB}_18B_${IB}_AWK_ADDNEW_RATEINDEX.dat  ${EST_FPATSEGSII_BCP_IN}"
		
	fi


  NSTEP=${NJOB}_20
  #--------------------------------
  LIBEL="BCP des nouvelles trace des courbes de taux ${EST_FPATSEGSII_BCP_IN}"
  BCP_WAY="IN"
  BCP_VER=""
  BCP_I=${EST_FPATSEGSII_BCP_IN}
  BCP_TABLE="BEST..TPATSEGSII"
  BCP
fi

# pas de trace pour le BDT mais par contre la proc en met !
if [ -s ${EST_FPATSEGSII_BCP_IN} -o "${TYPE_FICHIER}" = "BDT" ]
then
  NSTEP=${NJOB}_25
  #--------------------------------
  LIBEL="Maj nouvelles trace des courbes de taux"
  ISQL_BASE="BEST"
  ISQL_O=${DFILT}/${NSTEP}_${IB}_PATSEGSII_ISQL.log
  ISQL_QRY="execute BEST..PtPATSEGSII_01 '${CRE_D}','${USR_CF}','${ICLODAT_D}','${PER_CF}','${TYPE_FICHIER}'"
  ISQL
fi

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NCHAIN}*${IB}_*.dat"

JOBEND
