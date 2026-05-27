#!/bin/ksh
#=============================================================================
# nom de l'application : DIP/Omega
# nom du script SHELL  : ESEJ2081.cmd
# date de creation     : 01/09/2021
# auteur               : KBhimasen 
# references des specifications :
#-----------------------------------------------------------------------------
# description:
# Omega/DIP interface for pattern management 
#
# 
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
# set -x
 
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd

# Job Initialisation
JOBINIT

export USR_CF="DIP0"
export SSD_CF=99
export LAG_CF="E"
CUR_DATE=$(date +'%Y%m%d')

FILENAME=${DUSERS}/DIP_*.dat

#Interest and illiquidity rates
FILEDSC=${DUSERS}/DIP_DSC_*.dat
FILEDSC_EBS=${DUSERS}/DIP_DSC_EBS_*.dat
FILEDSC_I17G=${DUSERS}/DIP_DSC_I17G_*.dat
FILEDSC_I17P=${DUSERS}/DIP_DSC_I17P_*.dat
FILEDSC_I17L=${DUSERS}/DIP_DSC_I17L_*.dat

#Expenses ratio
FILERATIO=${DUSERS}/DIP_RATIO_*.dat
FILERATIO_I17G=${DUSERS}/DIP_RATIO_I17G_*.dat
FILERATIO_I17P=${DUSERS}/DIP_RATIO_I17P_*.dat
FILERATIO_I17L=${DUSERS}/DIP_RATIO_I17L_*.dat

#Risk Adjustment
FILERA=${DUSERS}/DIP_RA_*.dat
FILERA_I17G=${DUSERS}/DIP_RA_I17G_*.dat
FILERA_I17P=${DUSERS}/DIP_RA_I17P_*.dat
FILERA_I17L=${DUSERS}/DIP_RA_I17L_*.dat

#Fund Held Interest
FILEFHNI=${DUSERS}/DIP_FHNI_*.dat

#Unwind
FILEFWD=${DUSERS}/DIP_FWD_*.dat
FILEFWD_I17G=${DUSERS}/DIP_FWD_I17G_*.dat
FILEFWD_I17P=${DUSERS}/DIP_FWD_I17P_*.dat
FILEFWD_I17L=${DUSERS}/DIP_FWD_I17L_*.dat

#Lock In
FILELKR=${DUSERS}/DIP_LKR_*.dat
FILELKR_I17G=${DUSERS}/DIP_LKR_I17G_*.dat
FILELKR_I17P=${DUSERS}/DIP_LKR_I17P_*.dat
FILELKR_I17L=${DUSERS}/DIP_LKR_I17L_*.dat

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Check if some DIP file exists at FTP location"
if [ ! -e ${FILENAME} ]
then
echo "file not found at the location  ${FILENAME}" > ${DFILT}/${NSTEP}_${IB}_SQL_O1.dat
EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_SQL_O1.dat ${DUSERS}/output.dat"
JOBEND 99
fi

##NSTEP=${NJOB}_10
###------------------------------------------------------------------------------
##LIBEL="Check if some DIP Interest and illiquidity rates (DSC) file exists at FTP location"
##if [ -e ${FILEDSC} ]
##then
##DATA_TYPE=`ls ${FILEDSC}|cut -d "_" -f2`
##CLOS_TYPE=`ls ${FILEDSC}|cut -d "_" -f3`
##CLOS_DATE=`ls ${FILEDSC}|cut -d "_" -f4`
##CREATIONDATE=`ls ${FILEDSC}|cut -d "_" -f5| cut -d '.' -f1 `
##LIGNES=`cat ${FILEDSC} | tail -n +2 | wc -l`
##
##FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
##ECHO_LOG "#===> FILEDSC exists................: ${FILEDSC}"
##
##	NSTEP=${NJOB}_10_01
##	#------------------------------------------------------------------------------
##	LIBEL="Call ESEJ2082"
##	NSUBJOB=${NSTEP}_ESEJ2082
##	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEDSC}  2>&1 | ${TEE}
##	
##	NSTEP=${NJOB}_10_02
##	#------------------------------------------------------------------------------
##	LIBEL="Checking if file exists at DFILT location"		
##	if [ -e ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ]
##	then	
##		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##	else
##		NSTEP=${NJOB}_10_03
##		#------------------------------------------------------------------------------
##		LIBEL="Checking for anamolies"
##		ISQL_BASE="BEST"
##		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##		ISQL_QRY="select COUNT(*) from BEST..TPATSEGSII where CRE_D>='${CUR_DATE}' and CREUSR_CF='${USR_CF}' and CLODAT_D = '${CLOS_DATE}' "
##		ISQL
##		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
##		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed !~r~nPlease refer to the System Administrator. ' > ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat
##		NUMBER=`sed -n '3p' ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat`
##		if [ ${NUMBER} -ne 0 ]
##		then
##		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		else 
##		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		fi
##	fi
##fi

NSTEP=${NJOB}_12
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Interest and illiquidity rates (DSC) file exists for EBS at FTP location"
if [ -e ${FILEDSC_EBS} ]
then
DATA_TYPE=`ls ${FILEDSC_EBS}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILEDSC_EBS}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILEDSC_EBS}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILEDSC_EBS}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILEDSC_EBS} | tail -n +2 | wc -l`

FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILEDSC_EBS exists................: ${FILEDSC_EBS}"

	NSTEP=${NJOB}_12_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEDSC_EBS}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_12_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_12_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select COUNT(*) from BEST..TPATSEGSII where CRE_D>='${CUR_DATE}' and CREUSR_CF='${USR_CF}' and CLODAT_D = '${CLOS_DATE}' "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed !~r~nPlease refer to the System Administrator. ' > ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat
		NUMBER=`sed -n '3p' ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat`
		if [ ${NUMBER} -ne 0 ]
		then
		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_14
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Interest and illiquidity rates (DSC) file exists for I17G at FTP location"
if [ -e ${FILEDSC_I17G} ]
then
DATA_TYPE=`ls ${FILEDSC_I17G}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILEDSC_I17G}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILEDSC_I17G}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILEDSC_I17G}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILEDSC_I17G} | tail -n +2 | wc -l`

FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILEDSC_I17G exists................: ${FILEDSC_I17G}"

	NSTEP=${NJOB}_14_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEDSC_I17G}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_14_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_14_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select COUNT(*) from BEST..TPATSEGSII where CRE_D>='${CUR_DATE}' and CREUSR_CF='${USR_CF}' and CLODAT_D = '${CLOS_DATE}' "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed !~r~nPlease refer to the System Administrator. ' > ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat
		NUMBER=`sed -n '3p' ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat`
		if [ ${NUMBER} -ne 0 ]
		then
		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_16
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Interest and illiquidity rates (DSC) file exists for I17P at FTP location"
if [ -e ${FILEDSC_I17P} ]
then
DATA_TYPE=`ls ${FILEDSC_I17P}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILEDSC_I17P}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILEDSC_I17P}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILEDSC_I17P}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILEDSC_I17P} | tail -n +2 | wc -l`

FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILEDSC_I17P exists................: ${FILEDSC_I17P}"

	NSTEP=${NJOB}_16_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEDSC_I17P}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_16_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_16_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select COUNT(*) from BEST..TPATSEGSII where CRE_D>='${CUR_DATE}' and CREUSR_CF='${USR_CF}' and CLODAT_D = '${CLOS_DATE}' "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed !~r~nPlease refer to the System Administrator. ' > ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat
		NUMBER=`sed -n '3p' ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat`
		if [ ${NUMBER} -ne 0 ]
		then
		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_18
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Interest and illiquidity rates (DSC) file exists for I17L at FTP location"
if [ -e ${FILEDSC_I17L} ]
then
DATA_TYPE=`ls ${FILEDSC_I17L}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILEDSC_I17L}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILEDSC_I17L}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILEDSC_I17L}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILEDSC_I17L} | tail -n +2 | wc -l`

FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILEDSC_I17L exists................: ${FILEDSC_I17L}"

	NSTEP=${NJOB}_18_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEDSC_I17L}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_18_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_18_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select COUNT(*) from BEST..TPATSEGSII where CRE_D>='${CUR_DATE}' and CREUSR_CF='${USR_CF}' and CLODAT_D = '${CLOS_DATE}' "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed !~r~nPlease refer to the System Administrator. ' > ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat
		NUMBER=`sed -n '3p' ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat`
		if [ ${NUMBER} -ne 0 ]
		then
		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
		EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUT_DSC.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

##NSTEP=${NJOB}_20
###------------------------------------------------------------------------------
##LIBEL="Check if some DIP Expenses ratio (RATIO) file exists at FTP location"
##if [ -e ${FILERATIO} ]
##then
##DATA_TYPE=`ls ${FILERATIO}|cut -d "_" -f2`
##CLOS_TYPE=`ls ${FILERATIO}|cut -d "_" -f3`
##CLOS_DATE=`ls ${FILERATIO}|cut -d "_" -f4`
##CREATIONDATE=`ls ${FILERATIO}|cut -d "_" -f5| cut -d '.' -f1 `
##LIGNES=`cat ${FILERATIO} | tail -n +2 | wc -l`
##FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
##ECHO_LOG "#===> FILERATIO exists................: ${FILERATIO}"
##
##	NSTEP=${NJOB}_20_01
##	#------------------------------------------------------------------------------
##	LIBEL="Call ESEJ2082"
##	NSUBJOB=${NSTEP}_ESEJ2082
##	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILERATIO}  2>&1 | ${TEE}
##	
##	NSTEP=${NJOB}_20_02
##	#------------------------------------------------------------------------------
##	LIBEL="Checking if file exists at DFILT location"		
##	if [ -e ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ]
##	then	
##		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##	else
##		NSTEP=${NJOB}_20_03
##		#------------------------------------------------------------------------------
##		LIBEL="Checking for anamolies"
##		ISQL_BASE="BEST"
##		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
##		ISQL
##		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
##		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
##		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
##		NUMBER=0
##		while IFS= read -r line
##		do
##		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
##		NUMBER=$(echo "${line//[!0-9]/}")
##		break
##		fi
##		done < "$FILE"
##		if [ ${NUMBER} -ne 0 ]
##		then
##			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		else 
##			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		fi
##	fi
##fi

NSTEP=${NJOB}_22
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Expenses ratio (RATIO) file exists for I17G at FTP location"
if [ -e ${FILERATIO_I17G} ]
then
DATA_TYPE=`ls ${FILERATIO_I17G}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILERATIO_I17G}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILERATIO_I17G}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILERATIO_I17G}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILERATIO_I17G} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILERATIO_I17G exists................: ${FILERATIO_I17G}"

	NSTEP=${NJOB}_22_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILERATIO_I17G}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_22_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_22_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_24
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Expenses ratio (RATIO) file exists for I17P at FTP location"
if [ -e ${FILERATIO_I17P} ]
then
DATA_TYPE=`ls ${FILERATIO_I17P}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILERATIO_I17P}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILERATIO_I17P}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILERATIO_I17P}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILERATIO_I17P} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILERATIO_I17P exists................: ${FILERATIO_I17P}"

	NSTEP=${NJOB}_24_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILERATIO_I17P}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_24_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_24_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_26
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Expenses ratio (RATIO) file exists for I17L at FTP location"
if [ -e ${FILERATIO_I17L} ]
then
DATA_TYPE=`ls ${FILERATIO_I17L}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILERATIO_I17L}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILERATIO_I17L}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILERATIO_I17L}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILERATIO_I17L} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILERATIO_I17L exists................: ${FILERATIO_I17L}"

	NSTEP=${NJOB}_26_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILERATIO_I17L}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_26_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_26_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

##NSTEP=${NJOB}_30
###------------------------------------------------------------------------------
##LIBEL="Check if some DIP Risk Adjustment (RA) file exists at FTP location"
##if [ -e ${FILERA} ]
##then
##DATA_TYPE=`ls ${FILERA}|cut -d "_" -f2`
##CLOS_TYPE=`ls ${FILERA}|cut -d "_" -f3`
##CLOS_DATE=`ls ${FILERA}|cut -d "_" -f4`
##CREATIONDATE=`ls ${FILERA}|cut -d "_" -f5| cut -d '.' -f1 `
##LIGNES=`cat ${FILERA} | tail -n +2 | wc -l`
##FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
##ECHO_LOG "#===> FILERA exists................: ${FILERA}"
##
##	NSTEP=${NJOB}_30_01
##	#------------------------------------------------------------------------------
##	LIBEL="Call ESEJ2082"
##	NSUBJOB=${NSTEP}_ESEJ2082
##	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILERA}  2>&1 | ${TEE}
##	
##	NSTEP=${NJOB}_30_02
##	#------------------------------------------------------------------------------
##	LIBEL="Checking if file exists at DFILT location"		
##	if [ -e ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ]
##	then	
##		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##	else
##		NSTEP=${NJOB}_30_03
##		#------------------------------------------------------------------------------
##		LIBEL="Checking for anamolies"
##		ISQL_BASE="BEST"
##		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
##		ISQL
##		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
##		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
##		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
##		NUMBER=0
##		while IFS= read -r line
##		do
##		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
##		NUMBER=$(echo "${line//[!0-9]/}")
##		break
##		fi
##		done < "$FILE"
##		if [ ${NUMBER} -ne 0 ]
##		then
##			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		else 
##			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		fi
##	fi
##fi

NSTEP=${NJOB}_32
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Risk Adjustment (RA) file exists for I17G at FTP location"
if [ -e ${FILERA_I17G} ]
then
DATA_TYPE=`ls ${FILERA_I17G}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILERA_I17G}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILERA_I17G}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILERA_I17G}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILERA_I17G} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILERA_I17G exists................: ${FILERA_I17G}"

	NSTEP=${NJOB}_32_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILERA_I17G}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_32_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_32_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_34
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Risk Adjustment (RA) file exists for I17P at FTP location"
if [ -e ${FILERA_I17P} ]
then
DATA_TYPE=`ls ${FILERA_I17P}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILERA_I17P}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILERA_I17P}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILERA_I17P}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILERA_I17P} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILERA_I17P exists................: ${FILERA_I17P}"

	NSTEP=${NJOB}_34_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILERA_I17P}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_34_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_34_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_36
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Risk Adjustment (RA) file exists for I17L at FTP location"
if [ -e ${FILERA_I17L} ]
then
DATA_TYPE=`ls ${FILERA_I17L}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILERA_I17L}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILERA_I17L}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILERA_I17L}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILERA_I17L} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILERA_I17L exists................: ${FILERA_I17L}"

	NSTEP=${NJOB}_36_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILERA_I17L}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_36_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_36_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Fund Held Interest (FHNI) file exists at FTP location"
if [ -e ${FILEFHNI} ]
then
DATA_TYPE=`ls ${FILEFHNI}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILEFHNI}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILEFHNI}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILEFHNI}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILEFHNI} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILEFHNI exists................: ${FILEFHNI}"

	NSTEP=${NJOB}_40_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEFHNI}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_40_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}.dat"
	else
		NSTEP=${NJOB}_40_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}.dat"
		fi
	fi
fi

##NSTEP=${NJOB}_50
###------------------------------------------------------------------------------
##LIBEL="Check if some DIP Unwind (FWD) file exists at FTP location"
##if [ -e ${FILEFWD} ]
##then
##DATA_TYPE=`ls ${FILEFWD}|cut -d "_" -f2`
##CLOS_TYPE=`ls ${FILEFWD}|cut -d "_" -f3`
##CLOS_DATE=`ls ${FILEFWD}|cut -d "_" -f4`
##CREATIONDATE=`ls ${FILEFWD}|cut -d "_" -f5| cut -d '.' -f1 `
##LIGNES=`cat ${FILEFWD} | tail -n +2 | wc -l`
##FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
##ECHO_LOG "#===> FILEFWD exists................: ${FILEFWD}"
##
##	NSTEP=${NJOB}_50_01
##	#------------------------------------------------------------------------------
##	LIBEL="Call ESEJ2082"
##	NSUBJOB=${NSTEP}_ESEJ2082
##	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEFWD}  2>&1 | ${TEE}
##	
##	NSTEP=${NJOB}_50_02
##	#------------------------------------------------------------------------------
##	LIBEL="Checking if file exists at DFILT location"		
##	if [ -e ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ]
##	then	
##		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##	else
##		NSTEP=${NJOB}_50_03
##		#------------------------------------------------------------------------------
##		LIBEL="Checking for anamolies"
##		ISQL_BASE="BEST"
##		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
##		ISQL
##		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
##		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
##		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
##		NUMBER=0
##		while IFS= read -r line
##		do
##		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
##		NUMBER=$(echo "${line//[!0-9]/}")
##		break
##		fi
##		done < "$FILE"
##		if [ ${NUMBER} -ne 0 ]
##		then
##			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		else 
##			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		fi
##	fi
##fi

NSTEP=${NJOB}_52
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Unwind (FWD) file exists for I17G at FTP location"
if [ -e ${FILEFWD_I17G} ]
then
DATA_TYPE=`ls ${FILEFWD_I17G}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILEFWD_I17G}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILEFWD_I17G}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILEFWD_I17G}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILEFWD_I17G} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILEFWD_I17G exists................: ${FILEFWD_I17G}"

	NSTEP=${NJOB}_52_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEFWD_I17G}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_52_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_52_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_54
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Unwind (FWD) file exists for I17P at FTP location"
if [ -e ${FILEFWD_I17P} ]
then
DATA_TYPE=`ls ${FILEFWD_I17P}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILEFWD_I17P}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILEFWD_I17P}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILEFWD_I17P}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILEFWD_I17P} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILEFWD_I17P exists................: ${FILEFWD_I17P}"

	NSTEP=${NJOB}_54_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEFWD_I17P}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_54_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_54_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_56
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Unwind (FWD) file exists for I17L at FTP location"
if [ -e ${FILEFWD_I17L} ]
then
DATA_TYPE=`ls ${FILEFWD_I17L}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILEFWD_I17L}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILEFWD_I17L}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILEFWD_I17L}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILEFWD_I17L} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILEFWD_I17L exists................: ${FILEFWD_I17L}"

	NSTEP=${NJOB}_56_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILEFWD_I17L}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_56_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_56_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

##NSTEP=${NJOB}_60
###------------------------------------------------------------------------------
##LIBEL="Check if some DIP Lock In (LKR) file exists at FTP location"
##if [ -e ${FILELKR} ]
##then
##DATA_TYPE=`ls ${FILELKR}|cut -d "_" -f2`
##CLOS_TYPE=`ls ${FILELKR}|cut -d "_" -f3`
##CLOS_DATE=`ls ${FILELKR}|cut -d "_" -f4`
##CREATIONDATE=`ls ${FILELKR}|cut -d "_" -f5| cut -d '.' -f1 `
##LIGNES=`cat ${FILELKR} | tail -n +2 | wc -l`
##FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
##ECHO_LOG "#===> FILELKR exists................: ${FILELKR}"
##
##	NSTEP=${NJOB}_60_01
##	#------------------------------------------------------------------------------
##	LIBEL="Call ESEJ2082"
##	NSUBJOB=${NSTEP}_ESEJ2082
##	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILELKR}  2>&1 | ${TEE}
##	
##	NSTEP=${NJOB}_60_02
##	#------------------------------------------------------------------------------
##	LIBEL="Checking if file exists at DFILT location"		
##	if [ -e ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ]
##	then	
##		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##	else
##		NSTEP=${NJOB}_60_03
##		#------------------------------------------------------------------------------
##		LIBEL="Checking for anamolies"
##		ISQL_BASE="BEST"
##		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
##		ISQL
##		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
##		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
##		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
##		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
##		NUMBER=0
##		while IFS= read -r line
##		do
##		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
##		NUMBER=$(echo "${line//[!0-9]/}")
##		break
##		fi
##		done < "$FILE"
##		if [ ${NUMBER} -ne 0 ]
##		then
##			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		else 
##			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}.dat"
##		fi
##	fi
##fi

NSTEP=${NJOB}_62
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Lock In (LKR) file exists for I17G at FTP location"
if [ -e ${FILELKR_I17G} ]
then
ECHO_LOG "#===> FILELKR_I17G exists................: ${FILELKR_I17G}"
DATA_TYPE=`ls ${FILELKR_I17G}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILELKR_I17G}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILELKR_I17G}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILELKR_I17G}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILELKR_I17G} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat

	NSTEP=${NJOB}_62_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILELKR_I17G}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_62_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_62_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_64
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Lock In (LKR) file exists for I17P at FTP location"
if [ -e ${FILELKR_I17P} ]
then
DATA_TYPE=`ls ${FILELKR_I17P}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILELKR_I17P}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILELKR_I17P}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILELKR_I17P}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILELKR_I17P} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILELKR_I17P exists................: ${FILELKR_I17P}"

	NSTEP=${NJOB}_64_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILELKR_I17P}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_64_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_64_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_66
#------------------------------------------------------------------------------
LIBEL="Check if some DIP Lock In (LKR) file exists for I17L at FTP location"
if [ -e ${FILELKR_I17L} ]
then
DATA_TYPE=`ls ${FILELKR_I17L}|cut -d "_" -f2`
CLOS_TYPE=`ls ${FILELKR_I17L}|cut -d "_" -f3`
CLOS_DATE=`ls ${FILELKR_I17L}|cut -d "_" -f4`
CREATIONDATE=`ls ${FILELKR_I17L}|cut -d "_" -f5| cut -d '.' -f1 `
LIGNES=`cat ${FILELKR_I17L} | tail -n +2 | wc -l`
FULLFILENAME=DIP_${DATA_TYPE}_${CLOS_TYPE}_${CLOS_DATE}_${CUR_DATE}.dat
ECHO_LOG "#===> FILELKR_I17L exists................: ${FILELKR_I17L}"

	NSTEP=${NJOB}_66_01
	#------------------------------------------------------------------------------
	LIBEL="Call ESEJ2082"
	NSUBJOB=${NSTEP}_ESEJ2082
	${DCMD}/ESEJ2082.cmd ${USR_CF} ${SSD_CF} ${DATA_TYPE} ${CLOS_TYPE} ${CLOS_DATE} ${LIGNES} ${LAG_CF} ${CUR_DATE} ${FILELKR_I17L}  2>&1 | ${TEE}
	
	NSTEP=${NJOB}_66_02
	#------------------------------------------------------------------------------
	LIBEL="Checking if file exists at DFILT location"		
	if [ -e ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ]
	then	
		EXECKSH "mv ${DFILT}/output_${DATA_TYPE}_${CLOS_TYPE}_${CUR_DATE}.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
	else
		NSTEP=${NJOB}_66_03
		#------------------------------------------------------------------------------
		LIBEL="Checking for anamolies"
		ISQL_BASE="BEST"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		ISQL_QRY="select PATCAT_CT = '',PATCAT_LS= '',LIGNE=a.NUMLINE_NT,COLONNE= '',ANOMALIE= b.MESS_L,CRE_D=${CUR_DATE} from BEST..TCTRANO a, BREF..TMESSAGE b where a.SSD_CF=${SSD_CF} and a.SEGTYP_CT='S' and a.SEG_NF='${USR_CF}' and b.LANG_C='E' and b.messthm_c = 'ESTIMATION' and a.ANO_CT=b.mess_n "
		ISQL
		echo ${FULLFILENAME} 'processed with Success' > ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat		
		echo ${FULLFILENAME} 'is not processed due to the job launch has Failed' > ${DFILT}/${NSTEP}_${IB}_OUT.dat
		cat ${DFILT}/${NSTEP}_${IB}_OUT.dat >> ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
		FILE="${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat"
		NUMBER=0
		while IFS= read -r line
		do
		if [[ $line =~ "rows affected" || $line =~ "row affected" ]]; then
		NUMBER=$(echo "${line//[!0-9]/}")
		break
		fi
		done < "$FILE"
		if [ ${NUMBER} -ne 0 ]
		then
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		else 
			EXECKSH "mv ${DFILT}/${NSTEP}_${IB}_OUTPUT.dat ${DUSERS}/output_${DATA_TYPE}_${CLOS_TYPE}.dat"
		fi
	fi
fi

NSTEP=${NJOB}_70
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
JOBEND


