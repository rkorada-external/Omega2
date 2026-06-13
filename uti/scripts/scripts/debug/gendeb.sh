#! /bin/bash
. /scor/scoromega/runnable/uti/functions/fctgen/GETV

CMD=$1
STEP=$2
ENV=$3
SITE=$4
LOG=""


spin()
{
	spinner=(\\ \| / -)
	while :
	do
		for i in "${spinner[@]}"
		do
			echo -ne "\r# Generation of debug script :  ${i}  "
			sleep 0.4
		done
	done
}

spin &
spin_pid=$!

if [ -f ${CMD} ]; then 
	ext=`echo ${CMD} | rev | cut -d. -f1 | rev`
	if [ ${ext} == "log" ]; then 
		LOG=${CMD}
	fi
fi


if [ "${LOG}" == "" ]; then
	RENV=`GETV ${DUTI}/scripts/debug/env.lst  ${ENV}`
	if [[ "${CMD}" =~ .*_$ ]]; then
		LOG=`ls -rt ${RENV}/ub${SITE}/temporaire/*${CMD}*${STEP}_*log 2>/dev/null | tail -n1` 
	else
		LOG=`ls -rt ${RENV}/ub${SITE}/temporaire/*${CMD}*_${STEP}_*log 2>/dev/null | tail -n1` 
	fi
fi

echo ""
if [ "${LOG}" != "" ] && [ -f ${LOG} ]; then
	CMD=`echo "${CMD}" | sed 's/.*/_/g'`
echo "CMD >>> "$CMD
	/scor/scoromega/runnable/uti/scripts/debug/genDebug.py ${LOG} > debug_${CMD}_${STEP}_${ENV}.sh
	chmod u+x debug_${CMD}_${STEP}_${ENV}.sh
	echo "# Done : run this script 'debug_${CMD}_${STEP}_${ENV}.sh'"
else 
	echo "# Log file not found : '${RENV}/ub${SITE}/temporaire/*${CMD}*${STEP}*log' "
fi

kill -9 ${spin_pid} 2>1&>/dev/null
