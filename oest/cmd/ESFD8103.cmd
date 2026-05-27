#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Formatage des fichiers GLT, ULTIMATES pour chargement dans Netezza
# nom du script SHELL           : ESFD8103.cmd
# revision                      : 
# date de creation              : 11/12/2015
# auteur                        : Roger Cassis
# references des specifications : :spot:29903
#-----------------------------------------------------------------------------
# description
#  Formatage des fichiers Estimation : GLT, Ultimates pour chargement dans Netezza
#
# Launch applicative job ESFD8101
#
#-----------------------------------------------------------------------------
# historiques des modifications:
#[001] 21/10/2020 L.DOAN : spira 84655  - Send file AOC to RA
#[002] 29/10/2020 L.DOAN : spira 84655  - fix double run bug
#[003] 08/07/2021 L.DOAN : spira 97560  - ParallelRun- Envoie à RA INV EBS
#[004] 08/07/2021 L.DOAN : spira 97594  - Remove extra date in filename
#[005] 27/09/2021 L.DOAN : spira 97560  - ParallelRun- Envoie a RA INV EBS : INV to POS for cashflow
#[006] 04/10/2021 L.DOAN : spira 95603  - IFRS17 - AOC metadata
#[007] 22/11/2021 JYP    : spira 95603  - IFRS17 - AOC metadata new variables
#[008] 23/11/2021 JYP/Mariem: spira 95603  - IFRS17 - AOC metadata PARM_CRE_D
#[009] 05/08/2025 Mr JYP : US 5559 : SERQS split files by site  , SII part  
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters


CRE_D=${PARM_CRE_D}
BALSHTYEA_NF=${PARM_BLCSHTYEA_NF}
BALSHTMTH_NF=${PARM_BLCSHTMTH_NF}
#PER_CF=${TYPEINV}

CLODAT_D=${PARM_ICLODAT_D}
INVCONSO_D=${PARM_INVCONSO_D}
CLODATMAX_D=${PARM0_INVCONSO_D}
SUFFTABLE=${PARM_SUFFTABLE}

################################################################
#Les différentes valeurs possibles pour SPEENTNAT_CT sont : 
#1             Ecriture Service
#2             Social Ec. Serv
#3             Conso Ec. Serv.
#4             Écriture service EBS -> rien dans TACCSUP
#5             Écriture Serv. Social EBS
#6             Écriture Serv. Conso EBS

#9	       I17G INV
#10	       I17G POS
#11	       I17G POC
################################################################
# Format du Fichier CLS_Type
#Norme données~type inv~année/mois du trimestre
#IFRS~INV~YYYYMM    -> contains IFRS std
#IFRS~POS~YYYYMM    -> contains IFRS std + POS
#IFRS~POC~YYYYMM    -> contains IFRS POC
#EBS~POS~YYYYMM     -> contains EBS POS
#EBS~POC~YYYYMM     -> contains EBS POC
#I17*~INV~YYYYMM    -> contains IFRS17 std
#I17*~POS~YYYYMM    -> contains IFRS17 std + pos 
#I17*~POC~YYYYMM    -> contains IFRS17 poc
################################################################

if [ "${DNZFILP}" = "" ]
then
	DNZFILP=${DFILP}
fi

	
TRIM=${CLODATMAX_QTR}
BALSHTYEA_NFTRIM=${CLODATMAX_YEA}


BALSHTMTH_NFDEB=`echo ${CLODATMAX_D} | awk '{mth = substr($0,5,2) - 2; print mth}'`
BALSHTMTH_NFFIN=`echo ${CLODATMAX_D} | cut -c5-6` 



#TODO : add $NORM in filepath

#ESF_FILE_LIST=${NCHAIN}_${IDF_CT}_FILE_LIST_${HOST_PRDSIT}.dat

# ne pas déclarer cett variable dans SQL ARCHI 

#ESF_CLS=${NCHAIN}_${IDF_CT}_CLSTYPE_${HOST_PRDSIT}.dat

# Job Initialisation
JOBINIT

#----------------------
SPEENTNAT_CTDEFAUT=10
#----------------------

#[005]

if [ "${NORME_CF}" = "I17*" ]
then       
	if [ "${TYPEINV}" = "POS" ]
        then
		SPEENTNAT_CTDEFAUT=10
				   
        else 
		if [ "${TYPEINV}" = "POC" ]
			then
				SPEENTNAT_CTDEFAUT=11
				                
			else
				SPEENTNAT_CTDEFAUT=9
				
		fi

       fi
fi

#TODO : condition "I17L" and "I17P"



if [ ! -f ${ESF_FTECLEDSII_LOCAL} ]
   then
        ECHO_LOG "ESF_FTECLEDSII_LOCAL =${ESF_FTECLEDSII_LOCAL}  does not exist, take an empty file"            >> $FLOG
        ESF_FTECLEDSII_LOCAL="${DFILP}/empty.dat"
fi


#EST_FTECLEDSIIRA="`basename "${ESF_FTECLEDSIIRA%.*}"`_${PARM_ICLODAT_D}${TYPEINV}${PARM_CRE_D}.dat"


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESF_FTECLEDSII_LOCAL ..........: ${ESF_FTECLEDSII_LOCAL}"
ECHO_LOG "#===> ESF_FTECLEDSIIRA........: ${ESF_FTECLEDSIIRA}"
ECHO_LOG "#===> ESF_FILE_LIST...........: ${DNZFILP}/${ESF_FILE_LIST}"
ECHO_LOG "#===> ESF_CLS.................: ${DNZFILP}/${ESF_CLS}"
ECHO_LOG "#===> CRE_D...................: ${CRE_D}"
ECHO_LOG "#===> BALSHTYEA_NF............: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF............: ${BALSHTMTH_NF}"
ECHO_LOG "#===> BALSHTYEA_NFTRIM........: ${BALSHTYEA_NFTRIM}"
ECHO_LOG "#===> BALSHTMTH_NFDEB.........: ${BALSHTMTH_NFDEB}"
ECHO_LOG "#===> BALSHTMTH_NFFIN.........: ${BALSHTMTH_NFFIN}"
ECHO_LOG "#===> CLODAT_D................: ${CLODAT_D}"
ECHO_LOG "#===> CLODATMAX_D.............: ${CLODATMAX_D}"
ECHO_LOG "#===> TRIM....................: ${TRIM}"
ECHO_LOG "#===> NORME...................: ${NORME}"
ECHO_LOG "#===> TYPEINV.................: ${TYPEINV}"
ECHO_LOG "#===> ESF_FTECLEDSIIRA........: ${DNZFILP}/${ESF_FTECLEDSIIRA}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_01
LIBEL="Erase Last Permanent files"
RMFIL "${DNZFILP}/${NCHAIN}_*${IDF_CT}*.dat"



NSTEP=${NJOB}_45
# #[043] Creation d'un fichier AT INI avec TRNCOD INI
#-----------------------------------------------------------------------------
LIBEL="Transforme INV en POS "
AWK_I=${ESF_FTECLEDSII_LOCAL}
AWK_O=${DFILT}/${NSTEP}_${IB}_FTECLEDSII.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if (substr(\$4,1,3) == "INV") { \$4 = "POS";}
        print \$0;
        fi
  }
exit
EOF
AWK


#[005]
NSTEP=${NJOB}_50
# Copie fichiers SII
#------------------------------------------------------------------------------
LIBEL="Copy file (SO / CO) ${ESF_FTECLEDSII_LOCAL} on ${DNZFILP}/${ESF_FTECLEDSIIRA}"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_45_${IB}_FTECLEDSII.dat ${DNZFILP}/${ESF_FTECLEDSIIRA}"

NEW_TYPEINV=${TYPEINV}
if  [ "${TYPEINV}" = INV ]  && [[ "${NORME_CF}" =~ ^(EBS|I17) ]]
then
        NEW_TYPEINV="POS"
        ECHO_LOG "#===> Inventaire AOC : Force TYPEINV to  ${NEW_TYPEINV}"
fi


ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Creation fichier descriptif dans ${ESF_CLS}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
echo "${NORME_CF}~${NEW_TYPEINV}~${BALSHTYEA_NFTRIM}${BALSHTMTH_NFFIN}" > ${DNZFILP}/${ESF_CLS}
cat ${DNZFILP}/${ESF_CLS}

echo "${NORME_CF}~${NEW_TYPEINV}~${BALSHTYEA_NFTRIM}${BALSHTMTH_NFFIN}~${PARM_DBCLO_MAX_D}~${PARM_CRE_D}~${PARM_ID_NF_AOC}~${PARM_VRS_NF_AOC}" > ${DNZFILP}/${ESF_FMETADATA}
cat ${DNZFILP}/${ESF_FMETADATA}

ECHO_LOG "#"
ECHO_LOG "#===> Creation liste des fichiers dans ${ESF_FILE_LIST}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
wc -l ${DNZFILP}/${NCHAIN}_*${IDF_CT}*${HOST_PRDSIT}*.dat |  grep -v "total" | grep -v "FILE_LIST" | awk '{split($0,tab1," "); i=split(tab1[2],tab2,"/"); print tab2[i] "~" tab1[1]}' > ${DNZFILP}/${ESF_FILE_LIST}
cat ${DNZFILP}/${ESF_FILE_LIST}

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Sauvegarde des fichiers"
ECHO_LOG "#"
#------------------------------------------------------------------------------
gzip -c ${DNZFILP}/${ESF_FTECLEDSIIRA} > ${DSAVE}/${SVG}_${ESF_FTECLEDSIIRA}.gz
gzip -c ${DNZFILP}/${ESF_CLS}         > ${DSAVE}/${SVG}_${ESF_CLS}.gz
gzip -c ${DNZFILP}/${ESF_FILE_LIST}   > ${DSAVE}/${SVG}_${ESF_FILE_LIST}.gz



JOBEND
 


