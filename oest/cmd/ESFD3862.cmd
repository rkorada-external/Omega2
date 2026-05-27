#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 NIGHT CLOSING
# nom du script SHELL           : ESFD3862.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 04\06\2020
# auteur                        : Cyril AVINENS
#---------------------------------------------------------------------------------
# Description
#	Spira #85996
#	IFRS17 REQ05 : Profitability Interface SAS > O2
#---------------------------------------------------------------------------------
# Mod01-Karri Bhimasen-22/01/2021-Step4-Spira #91509: I17-Profitabily: Management of files in the server
# FCI#spira 111052 SAS/Omega profitability- AE management
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ICLODAT_D........................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> NORME_CF.........................................: ${NORME_CF}"
ECHO_LOG "#===> BATCHUSER........................................: ${PARM_BATCHUSER}"

export ESF_PI_REPORT_TMP="${DFILT}/${ENV_PREFIX}_ESFD3860_${NORME_CF}_PRO_INT_STD_PI_REPORT_TMP_${TYPEINV}_${PARM_CRE_D}.dat"
export ESF_PI_REPORT_SAVE="${ESF_PI_REPORT}_SAVE.dat"

ECHO_LOG "#===> PARM_CRE_D.......................................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARAM_CUR_PSTOMGEND17_D..........................: ${PARAM_CUR_PSTOMGEND17_D}"
ECHO_LOG "#===> ESF_PI_REPORT_TMP................................: ${ESF_PI_REPORT_TMP}"
ECHO_LOG "#===> ESF_PI_REPORT_SAVE................................: ${ESF_PI_REPORT_SAVE}"

ECHO_LOG "#===> ............ INPUT ......................................"
ECHO_LOG "#===> ESF_PI_ASSUM_EXTRACT.............................: ${ESF_PI_ASSUM_EXTRACT}"
ECHO_LOG "#===> ESF_FI17CLOPER...................................: ${ESF_FI17CLOPER}"
ECHO_LOG "#===> ESF_EMPTY........................................: ${ESF_EMPTY}"

ECHO_LOG "#===> ............ OUTPUT ....................................."
ECHO_LOG "#===> ESF_PI_UPDATE_TSECIFRS...........................: ${ESF_PI_UPDATE_TSECIFRS}"
ECHO_LOG "#===> ESF_PI_REPORT....................................: ${ESF_PI_REPORT}"
ECHO_LOG "#========================================================================="

cd ${DTRANSFER}/LifeReserving/from

if [ ! -f *ESFD3860*PA${NORME_CF}*.dat ]; then

NSTEP=${NJOB}_0
#------------------------------------------------------------------------------
LIBEL="touch ${DFILT}/${NJOB}_1_${IB}_CSM_ENGINE_PERICASE.dat"
EXECKSH "touch ${DFILT}/${NJOB}_1_${IB}_CSM_ENGINE_PERICASE.dat"

else
fullempty=1
	NSTEP=${NJOB}_0
	#------------------------------------------------------------------------------
	LIBEL="Prepare SORT_I"
	arrayIndex=1
	pattern="${ENV_PREFIX}_(.*)_(PAI17G|PAI17P|PAI17L)_(\d+)_(\d+)_(\d{8})_(\d{8})_(\d{6})_CSMENGINE\.dat$"
	
	for file in *ESFD3860*PA${NORME_CF}*.dat
	do
		ECHO_LOG "${arrayIndex}: Analysis of ${file}..."
		nblines=$(wc -l < ${file})
		now=$(date "+%Y%m%d%T")
		if [[ $file =~ $pattern ]]; then
			cp ${file} ${DTRANSFER}/LifeReserving/fromsave/${file}
			value="${file} 2000 1"
			value_empty="${ESF_EMPTY} 2000 1"
			empty=0
			sorti=${value}
				
			norm=$(echo ${.sh.match[2]} | cut -c3-6)
			ssd=${.sh.match[3]}
			esb=${.sh.match[4]}
			clodat=${.sh.match[5]}
			
			#R01-06 Controls on the SSD/EBS (TI17CLOPER)
			if grep -q ${ssd}~${esb}~ ${ESF_FI17CLOPER}; 
			then
				#R01-07 && 08 Controls on the SSD/EBS (TI17CLOPER)
				if [[ ${clodat} = ${PARM_ICLODAT_D} && ${PARM_CRE_D} < ${PARAM_CUR_PSTOMGEND17_D} ]]; 
				then
					sorti=${value}
					empty=0
					fullempty=0
					ECHO_LOG "All good for ${file}"				
				else
					sorti=${value_empty}
					empty=1
					ECHO_LOG "Fraud to R01-07 && 08 Quarter already closed for the entity / empty = ${empty}"
					ECHO_LOG "SORT_I${arrayIndex} ${value_empty} R01-07 && 08 prevents ${file} from being treated:  ${clodat}"
					echo "${ssd}~${esb}~KO~${file}~LifeReserving/from~${nblines}~${nblines}~${nblines}~${clodat}~${now}~0~Quarter already closed for the entity" >> ${ESF_PI_REPORT_TMP}
				fi
			else
				sorti=${value_empty}
				empty=1
				ECHO_LOG "Fraud to R01-06 Entity not eligible / empty = ${empty}"
				ECHO_LOG "R01-06 ${ESF_FI17CLOPER} prevents ${file} from being treated"
				echo "${ssd}~${esb}~KO~${file}~LifeReserving/from~${nblines}~${nblines}~${nblines}~${clodat}~${now}~0~Entity not eligible" >> ${ESF_PI_REPORT_TMP}
			fi
			
					
		else
			sorti=${value_empty}
			empty=1
			length=${#file}
			((l=length-4))
			ECHO_LOG "Incorrect Format for file ${file}."
			newbasename=$(echo ${file} | cut -c -${l})
			echo "~~KO~${file}~LifeReserving/from~${nblines}~${nblines}~${nblines}~~${now}~0~Incorrect format" >> ${ESF_PI_REPORT_TMP}
			newname="${newbasename}_INCORRECT_FORMAT.dat"
			ECHO_LOG "Moved to ${DTRANSFER}/LifeReserving/fromsave/${newname}"
			cp ${file} ${DTRANSFER}/LifeReserving/fromsave/${newname}
			rm ${file}
		fi
		
		if [[ ${arrayIndex} -eq 1 ]]; 
		then
			eval "SORT_I=\${sorti}"
			if [ ${empty} = 0 ]; then
				ECHO_LOG "First file to process: ${file}"
				fileList="${file}"
			else
				ECHO_LOG "No first file ${file} to process."
			fi
		else
			eval "SORT_I${arrayIndex}=\${sorti}"
			if [ ${empty} = 0 ]; then
				ECHO_LOG "Add new file ${file} to the process."
				fileList="${fileList}~${file}"
			else
				ECHO_LOG "No new file ${file} added to the process."
			fi
		fi	
		arrayIndex=$((arrayIndex+1))
		
	done

ECHO_LOG "List of Java SB input files: ${fileList}"

	if [ ${fullempty} = 0 ]; then
NSTEP=${NJOB}_1
#------------------------------------------------------------------------------
LIBEL="Merge files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${SORT_I}"
SORT_O="${DFILT}/${NJOB}_1_${IB}_CSM_ENGINE_PERICASE.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF

/OUTFILE ${SORT_O}
/COPY

exit
EOF
SORT

EXECKSH "touch ${ESF_PI_REPORT_TMP}"
	else
		NSTEP=${NJOB}_1
		#------------------------------------------------------------------------------
		LIBEL="No files suitable, so touch ${DFILT}/${NJOB}_1_${IB}_CSM_ENGINE_PERICASE.dat for JSB phase."
		EXECKSH "touch ${DFILT}/${NJOB}_1_${IB}_CSM_ENGINE_PERICASE.dat"
	fi

	NSTEP=${NJOB}_2
	#------------------------------------------------------------------------------
	LIBEL="Zip files in fromsave directory"
	cd ${DTRANSFER}/LifeReserving/fromsave

	for file in *ESFD3860*${NORME_CF}*.dat
	do
		name=$(echo "$file" | cut -f 1 -d '.')
		zip  "$name".zip "$name".dat
		rm   "$name".dat
	done

fi

if [ -f ${ESF_PI_REPORT} ]; then
NSTEP=${NJOB}_3
#------------------------------------------------------------------------------
LIBEL="Save of ESF_PI_REPORT "
ECHO_LOG "Save of ESF_PI_REPORT"
cp ${ESF_PI_REPORT} ${ESF_PI_REPORT_SAVE}
fi

if [ -z "${fileList}" ]; then
ECHO_LOG "No file for JSB process. Clean report because java wont."
EXECKSH "rm -f ${ESF_PI_REPORT}"
EXECKSH "touch ${ESF_PI_REPORT}"
fi

NSTEP=${NJOB}_4
#------------------------------------------------------------------------------

# inputs files
export ESTJ0009_ASSUM_EXTRACT="${ESF_PI_ASSUM_EXTRACT}"
export ESTJ0009_CSM_ENGINE_PERICASE="${DFILT}/${NJOB}_1_${IB}_CSM_ENGINE_PERICASE.dat"

# tmp files
export ESTJ0009_SORTED_ASSUM_EXTRACT_CSE="${DFILT}/${NJOB}_3_${IB}_SORTED_ASSUM_EXTRACT_CSE.dat"
export ESTJ0009_SORTED_ASSUM_EXTRACT_CSUOE="${DFILT}/${NJOB}_3_${IB}_SORTED_ASSUM_EXTRACT_CSUOE.dat"
export ESTJ0009_SORTED_CSM_ENGINE_PERICASE="${DFILT}/${NJOB}_3_${IB}_CSM_ENGINE_PERICASE.dat"
export ESTJ0009_UPDATE_TSECIFRS_TMP="${DFILT}/${NJOB}_3_${IB}_UPDATE_TSECIFRS_TMP.dat"
export ESTJ0009_SORTED_UPDATE_TSECIFRS_TMP="${DFILT}/${NJOB}_3_${IB}_SORTED_UPDATE_TSECIFRS_TMP.dat"

# outputs files
export ESTJ0009_UPDATE_TSECIFRS="${ESF_PI_UPDATE_TSECIFRS}"
export ESTJ0009_PI_REPORT="${ESF_PI_REPORT}"

# CMD variable
export SYNCSORT_CMD_ESTJ0009_SORT_CSM_ENGINE_PERICASE=${DCMD}/ESTS0028.cmd
export SYNCSORT_CMD_ESTJ0009_SORT_ASSUM_EXTRACT_CSE=${DCMD}/ESTS0029.cmd
export SYNCSORT_CMD_ESTJ0009_SORT_ASSUM_EXTRACT_CSUOE=${DCMD}/ESTS0030.cmd
export SYNCSORT_CMD_ESTJ0009_SORT_TSECIFRS=${DCMD}/ESTS0055.cmd

# Other variable
export ESTJ0009_INPUT_FILES_LIST="${fileList}"
export ESTJ0009_INPUT_FILES_PATH="${DTRANSFER}/LifeReserving/from"

# Jar execution
JSB_CHAIN="estj0009"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D} normcf=${NORME_CF} cloUser=${PARM_BATCHUSER}"
EXECJSB




if [ ! -f ${ESF_PI_REPORT} ]; then
NSTEP=${NJOB}_5
#------------------------------------------------------------------------------
LIBEL="touch ${ESF_PI_REPORT}"
ECHO_LOG "${NSTEP}: touch ${ESF_PI_REPORT}"
EXECKSH "touch ${ESF_PI_REPORT}"
fi

NSTEP=${NJOB}_6
#------------------------------------------------------------------------------
LIBEL="Move files KO from ${ESF_PI_REPORT} to LifeReserving/fromsave directory"
ECHO_LOG "${NSTEP}: Move files KO from ${ESF_PI_REPORT} to LifeReserving/fromsave directory"
pattern="(\d+)~(\d+)~(\w{2})~(.*)~([\w|\W]*)LifeReserving/from~(\d+)~(\d+)~(\d+)~(.*)~(.*)~([\w|\s]*)$"
while IFS= read -r line
do
  if [[ $line =~ $pattern ]]; then
	fileKo=${.sh.match[4]}
	ECHO_LOG "${.sh.match[4]} is ${.sh.match[3]} (see: ${.sh.match[0]})"
	if [[ ${.sh.match[3]} = "KO" ]]; then
		ECHO_LOG "Move ${.sh.match[4]} into LifeReserving/fromsave"
		cp ${fileKo} ${DTRANSFER}/LifeReserving/fromsave/${fileKo}
		rm ${fileKo}
	fi
  else
	ECHO_LOG "$line doesnt match expected pattern"
  fi
done < "$ESF_PI_REPORT"

NSTEP=${NJOB}_7
#------------------------------------------------------------------------------
LIBEL="Concat errors detected in step 1 into ${ESF_PI_REPORT}"
ECHO_LOG "${NSTEP}: Concat previous lines from Report & Concat new errors detected in step 1 into ${ESF_PI_REPORT}"
cat ${ESF_PI_REPORT_SAVE} >> ${ESF_PI_REPORT}
cat ${ESF_PI_REPORT_TMP} >> ${ESF_PI_REPORT}

NSTEP=${NJOB}_8
#------------------------------------------------------------------------------
LIBEL="Copy output in right directory"
ECHO_LOG "${NSTEP}: Copy output in right directory"
cp ${ESF_PI_REPORT} ${DTRANSFER}/LifeReserving/to

NSTEP=${NJOB}_9
#------------------------------------------------------------------------------
LIBEL="Erase ${ESF_PI_REPORT_TMP} & ${ESF_PI_REPORT_SAVE}"
ECHO_LOG "${NSTEP}: Erase ${ESF_PI_REPORT_TMP} & ${ESF_PI_REPORT_SAVE}"
EXECKSH "rm -f ${ESF_PI_REPORT_TMP}"
EXECKSH "rm -f ${ESF_PI_REPORT_SAVE}"


NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Erase temporary files & from lifeReserving/from"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "
RMFIL "${DTRANSFER}/LifeReserving/from/*ESFD3860*${NORME_CF}*.dat"

JOBEND