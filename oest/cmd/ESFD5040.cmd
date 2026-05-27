#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD5040.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 05\10\2022
# auteur                        : Florian CULIOLI
#---------------------------------------------------------------------------------
# description
# Onerous Q+1
#  Merge files for Pericase Future (from ESFD030.cmd) & Pericase (from ESFD5010.cmd)
#
#---------------------------------------------------------------------------------
# [01] 13/02/2024 FCI 	SPIRA 111100 : Actuarial segment missing when future contract is finalized
# [02] 14/10/2024 MZM   SPIRA 112294 : Retro Plan N+1 is not executed : Execution du ESFD5042 si fichier existe (option -f )
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

ECHO_LOG "BEGINNING OF ESFD5040"
ECHO_LOG "#===> ............INPUT............................................................."
ECHO_LOG "#===> EST_IADPERICASE_5010.........................................................: ${EST_IADPERICASE_5010}"
ECHO_LOG "#===> EST_IADPERICASE_5030.........................................................: ${EST_IADPERICASE_5030}"
ECHO_LOG "#===> EST_IADPERICASE0_5010........................................................: ${EST_IADPERICASE0_5010}"
ECHO_LOG "#===> EST_IADPERICASE0_5030........................................................: ${EST_IADPERICASE0_5030}"
ECHO_LOG "#===> EST_FCES_5010................................................................: ${EST_FCES_5010}"
ECHO_LOG "#===> ESF_FCES_5030................................................................: ${EST_FCES_5030}"
ECHO_LOG "#===> EST_IADPERIFCI_5010..........................................................: ${EST_IADPERIFCI_5010}"
ECHO_LOG "#===> EST_IADPERIFCI_5030..........................................................: ${EST_IADPERIFCI_5030}"
ECHO_LOG "#===> EST_IADPERIFCT_5010..........................................................: ${EST_IADPERIFCT_5010}"
ECHO_LOG "#===> EST_IADPERIFCT_5030..........................................................: ${EST_IADPERIFCT_5030}"
ECHO_LOG "#===> EST_IADPERIFR_5010...........................................................: ${EST_IADPERIFR_5010}"
ECHO_LOG "#===> EST_IADPERIFR_5030...........................................................: ${EST_IADPERIFR_5030}"
ECHO_LOG "#===> ....EBS......................................................................."
ECHO_LOG "#===> EST_IADVPERICASE_5010........................................................: ${EST_IADVPERICASE_5010}"
ECHO_LOG "#===> EST_IADPERICASE_STD_EBS_5030.................................................: ${EST_IADPERICASE_STD_EBS_5030}"

ECHO_LOG "#===> ............OUTPUT............................................................"
ECHO_LOG "#===> ....INI......................................................................."
ECHO_LOG "#===> EST_IADPERICASE..............................................................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_IADPERICASE0.............................................................: ${EST_IADPERICASE0}"
ECHO_LOG "#===> EST_FCES.....................................................................: ${EST_FCES}"
ECHO_LOG "#===> EST_IADPERIFCI...............................................................: ${EST_IADPERIFCI}"
ECHO_LOG "#===> EST_IADPERIFCT...............................................................: ${EST_IADPERIFCT}"
ECHO_LOG "#===> EST_IADPERIFR................................................................: ${EST_IADPERIFR}"
ECHO_LOG "#===> ....EBS......................................................................."
ECHO_LOG "#===> EST_IADPERICASE_STD..........................................................: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EST_IADVPERICASE_STD.........................................................: ${EST_IADVPERICASE_STD}"



if [ ${TYPEINV} = "INV" -o ${TYPEINV} = "POS" -o ${TYPEINV} = "POC" -o ${TYPEINV} = "POCB" ] 
then


ECHO_LOG "#============================================================================"
ECHO_LOG "#===> CONTEXT_CT.............................................................: ${CONTEXT_CT}"
ECHO_LOG "#===> NORME_CF.............................................................: ${NORME_CF}"
ECHO_LOG "#============================================================================"

# Extracting the number of days to substract on the pos booking date
set `GETPRM ${DPRM}/ESFD5000.prm`
export X_DAYS=$1

ECHO_LOG "#===> GREP ON...............................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> GREP IN...............................................................: ${DPRM}/ESFD5000.prm"
export QUARTER_END_FOUND=`grep ${PARM_ICLODAT_D} ${DPRM}/ESFD5000.prm | cut -d' ' -f 2` 
ECHO_LOG "#===> QUARTER_END_FOUND.....................................................: ${QUARTER_END_FOUND}"
ECHO_LOG "#===> PARAM_CUR_PSTOMGEND17_D....................................................: ${PARAM_CUR_PSTOMGEND17_D}"
ECHO_LOG "#===> X_DAYS................................................................: ${X_DAYS}"


pattern="(\d{2})\/(\d{2})\/(\d{4})"
if [ -z "$QUARTER_END_FOUND" -o "$QUARTER_END_FOUND" -eq "NONE" ];
then
	if [[ $QUARTER_END_FOUND =~ $pattern ]]; then
	export LIMIT_DATE=$(date --date="${.sh.match[3]}${.sh.match[2]}${.sh.match[1]}" +%Y%m%d)
	ECHO_LOG "#===>  LIMIT IS PRM QUARTER_END_FOUND .................................: $LIMIT_DATE"
	else
	export v_pos_booking_minus_days=$(date --date="${PARAM_CUR_PSTOMGEND17_D} -${X_DAYS} day" +%Y%m%d)
	ECHO_LOG "#===> OVERWRITE OF LIMIT WITH (PARAM_CUR_PSTOMGEND17_D - X_DAYS)  .................................: $v_pos_booking_minus_days"
	export LIMIT_DATE=$(date --date="${v_pos_booking_minus_days}" +%Y%m%d)
	fi
fi

## greater than or equal # [02] Ne plus prendre en compte cette condition 
## # [02] if [ $PARM_CRE_D -ge $LIMIT_DATE ];
## # [02]then 
## # [02]	ECHO_LOG "#===> NO EXECUTION OF ESFD5041 or ESFD5042 or ESFD5043 or ESFD5044 or ESFD5045 because PARM_CRE_D exceeds LIMIT_DATE.....................................................: $PARM_CRE_D >= $LIMIT_DATE"
## # [02]else

	if [ ${CONTEXT_CT} = "INI" ] 
	then

		if [ -s ${EST_IADPERICASE_5030} ]
		then
			# Launch applicative job ESFD5041
			NJOB="ESFD5041${TYPEINV}"
			${DCMD}/ESFD5041.cmd ${EST_IADPERICASE_5030} ${EST_IADPERICASE_5010} ${EST_IADPERICASE}| ${TEE}
		else
			ECHO_LOG "${EST_IADPERICASE_5030} doesnt exist or is empty."
			ECHO_LOG "Copy of ${EST_IADPERICASE_5010} into ${EST_IADPERICASE}"
			cp ${EST_IADPERICASE_5010} ${EST_IADPERICASE}
		fi

#[02]
		if [ ! -f ${EST_FCES_5030} ]
		then
			ECHO_LOG "CReate ${EST_FCES_5030} as empty  ."		
    	EXECKSH "touch ${EST_FCES_5030}"	
		fi
	
		
			# Launch applicative job ESFD5042
			NJOB="ESFD5042${TYPEINV}"
			${DCMD}/ESFD5042.cmd ${EST_FCES_5030} ${EST_FCES_5010} ${EST_FCES} | ${TEE}

		
##	if [ ! -s ${EST_FCES_5030} ]
##	then
##		ECHO_LOG "${EST_FCES_5030}  is empty ."
##		ECHO_LOG "Copy of ${EST_FCES_5010} into ${EST_FCES}"
##		cp ${EST_FCES_5010} ${EST_FCES}
##	fi	

		if [ -s ${EST_IADPERIFCI_5030} ] 
		then
			# Launch applicative job ESFD5043
			NJOB="ESFD5043${TYPEINV}"
			${DCMD}/ESFD5043.cmd ${EST_IADPERIFCI_5030} ${EST_IADPERIFCI_5010} ${EST_IADPERIFCI}| ${TEE}
		else
			ECHO_LOG "${EST_IADPERIFCI_5030} doesnt exist or is empty."
			ECHO_LOG "Copy of ${EST_IADPERIFCI_5010} into ${EST_IADPERIFCI}"
			cp ${EST_IADPERIFCI_5010} ${EST_IADPERIFCI}
		fi

		if [ -s ${EST_IADPERIFCT_5030} ]
		then	
			# Launch applicative job ESFD5044
			NJOB="ESFD5044${TYPEINV}"
			${DCMD}/ESFD5044.cmd ${EST_IADPERIFCT_5030} ${EST_IADPERIFCT_5010} ${EST_IADPERIFCT}| ${TEE}
		else
			ECHO_LOG "${EST_IADPERIFCT_5030} doesnt exist or is empty."
			ECHO_LOG "Copy of ${EST_IADPERIFCT_5010} into ${EST_IADPERIFCT}"
			cp ${EST_IADPERIFCT_5010} ${EST_IADPERIFCT}
		fi

		if [ -s ${EST_IADPERIFR_5030} ]
		then			
			# Launch applicative job ESFD5045
			NJOB="ESFD5045${TYPEINV}"
			${DCMD}/ESFD5045.cmd ${EST_IADPERIFR_5030} ${EST_IADPERIFR_5010} ${EST_IADPERIFR}| ${TEE}
		else
			ECHO_LOG "${EST_IADPERIFR_5030} doesnt exist or is empty."
			ECHO_LOG "Copy of ${EST_IADPERIFR_5010} into ${EST_IADPERIFR}"
			cp ${EST_IADPERIFR_5010} ${EST_IADPERIFR}
		fi

		if [ -s ${EST_IADPERICASE0_5030} ]
		then			
			# Launch applicative job ESFD5045
			NJOB="ESFD5041${TYPEINV}"
			${DCMD}/ESFD5041.cmd ${EST_IADPERICASE0_5030} ${EST_IADPERICASE0_5010} ${EST_IADPERICASE0}| ${TEE}
		else
			ECHO_LOG "${EST_IADPERICASE0_5030} doesnt exist or is empty."
			ECHO_LOG "Copy of ${EST_IADPERICASE0_5010} into ${EST_IADPERICASE0}"
			cp ${EST_IADPERICASE0_5010} ${EST_IADPERICASE0}
		fi

	else 
		if [ ${NORME_CF} = "EBS"  ] 
		then
			if [ -s ${EST_IADPERICASE_STD_EBS_5030} ]
			then			
				# Launch applicative job ESFD5041
				NJOB="ESFD5041${TYPEINV}"
				${DCMD}/ESFD5041.cmd ${EST_IADPERICASE_STD_EBS_5030} ${EST_IADPERICASE_5010} ${EST_IADPERICASE_STD}| ${TEE}
			else
				ECHO_LOG "${EST_IADPERICASE_STD_EBS_5030} doesnt exist or is empty."
				ECHO_LOG "Copy of ${EST_IADPERICASE_5010} into ${EST_IADPERICASE_STD}"
				cp ${EST_IADPERICASE_5010} ${EST_IADPERICASE_STD}
			fi
			if [ -s ${EST_IADPERICASE_STD_EBS_5030} ]
			then			
				# Launch applicative job ESFD5041
				NJOB="ESFD5041${TYPEINV}"
				${DCMD}/ESFD5041.cmd ${EST_IADPERICASE_STD_EBS_5030} ${EST_IADVPERICASE_5010} ${EST_IADVPERICASE_STD}| ${TEE}
			else
				ECHO_LOG "${EST_IADPERICASE_STD_EBS_5030} doesnt exist or is empty."
				ECHO_LOG "Copy of ${EST_IADVPERICASE_5010} into ${EST_IADVPERICASE_STD}"
				cp ${EST_IADVPERICASE_5010} ${EST_IADVPERICASE_STD}
			fi
#[02]

		if [ ! -f ${EST_FCES_5030} ]
		then
			ECHO_LOG "CReate ${EST_FCES_5030} as empty  ."		
    	EXECKSH "touch ${EST_FCES_5030}"	
		fi
					
		# Launch applicative job ESFD5042
		NJOB="ESFD5042${TYPEINV}"
		${DCMD}/ESFD5042.cmd ${EST_FCES_5030} ${EST_FCES_5010} ${EST_FCES} | ${TEE}

			
			if [ ! -s ${EST_FCES_5030} ]
			then
				ECHO_LOG "${EST_FCES_5030}  is empty : Copy of ${EST_FCES_5010} into ${EST_FCES}."
				cp ${EST_FCES_5010} ${EST_FCES}
			fi	
		fi
fi
else

	ECHO_LOG ""
	ECHO_LOG "#============================================================================"
	ECHO_LOG "# Batch run only when TYPEINV = INV or POS or POC or POCB"
	ECHO_LOG "# TYPEINV = ${TYPEINV} "
	ECHO_LOG "#============================================================================"
	ECHO_LOG ""

fi

CHAINEND
