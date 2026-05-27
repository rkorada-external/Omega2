#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
# nom du script SHELL           : ESCD9001.cmd
# revision                      : $Revision: 1.44 $
# date de creation              : 26/05/1997
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description:
#  links between logical and physical names of permanent files
#-----------------------------------------------------------------------------
# historiques des modifications
#[01]  31/10/2019 M. NAJI :spot:81838 - adaptation pour mode split LIFE et PC
#[02]  28/11/2019 M. NAJI :spot:76850 - fusion ESCD9001_NEW et ESFD9001.cmd
#[03]  06/05/2020 M. NAJI :spot:76850 - Correction du test de nb_NoEBS
#[04]  12/05/2020 M. NAJI :spot:76850 - pour les chaines qui appelle le ESCD9001 forcer PARM_ISSDCLO_LL=$2 
#[05]  16/09/2020 M. NAJI :spot:87596 - Migration des planifications IFRS4 et EBS de PsPlan02 vers la table TREQCHN 
#[06]  21/10/2020 JYP     :spot:87596 - bugfix NOGO when IDF_CT=NORME*AAx
#[07]  10/11/2020 M.NAJI  :spot:91421 - fix NOGO when IDF_CT=EBS_*
#[08]  22/12/2020 : M.NAJI : . SPIRA 91531 
#							. génaration d'un fichier paramètre par norme 
#[09]  01/04/2021 : JYP/Mehdi : SPIRA 91531 : bugfix NORME2 
#[10]  14/05/2021 M.NAJI  : SPIRA 91531 force calcul du EST_SORT_CONDITIOn ppour les chaines IFRS4 non migrees
#[11]  25/06/2021 M.NAJI  : SPIRA 91532 Force recalcul des conditions a la fin, new mode pour le plan I4I
#[12]  25/06/2021 M.NAJI  : SPIRA 91532 migration du calcul du CLOPRD dans PsIfrs17_02
#[13]  04/07/2022 JBD     : SPIRA 104778 Build new closing for I17S norm
#[14]  22/05/2024 M.NAJI  : SPIRA 999999 Display in log IT variable (second parameter of chain)
#[15]  10/07/2025 M.NAJI  : US 5559 SERQS - RA/SAP interface -Phase 1
#[16]  02/12/2025 M.NAJI  : US 7933 SERQS - add variable NOT_USED
#======================================================================================================================



if [ "${JOB_NOECHO}" != "YES" ]
then
    echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
    echo '# Begin of initialization job    : ' ${NJOB} " Date : " `date +"%Y/%m/%d %H:%M:%S"`  2>&1 | ${TEE}
    echo "# Main Working Directories :"   2>&1 | ${TEE}
    echo "#   DLOG : " ${DLOG}  2>&1 | ${TEE}
    echo "#   DUTI : " ${DUTI}  2>&1 | ${TEE}
    echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
fi



function TRACE_EXPORTS {
   fexport=$1
   echo
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   echo "Trace  of export variables: $fexport "  2>&1 | ${TEE}
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   
	while  read -r line
	do
			expo=`echo $line| cut -d' ' -f1`
			f=`echo  $line| cut -d'=' -f1 | cut -d' ' -f2`
			val=`echo $line | cut -d'=' -f2-100`
			if [ "$expo" = "export" ]
			then
					printf '#---> %-30s = %s\n'  $f "$val"  2>&1 | ${TEE}
			fi
	done <"$fexport"
	
	echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   
}	

function TRACE_EXPORTS_EVAL {
   fexport=$1
   echo
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   echo "Trace  of export variables: $fexport "  2>&1 | ${TEE}
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
	while  read -r line
	do
			expo=`echo $line| cut -d' ' -f1`
			str=`echo $line | cut -d' ' -f2-1000`
			f=`echo $str | cut -d'=' -f1`
			value=`echo $str | cut -d'=' -f2-1000`
			if [ "$expo" = "export" ]
			then
					val=` eval echo  $value`
					if [ "$val" != "" ] 
					then
						infos=`[ -f "$val" ] &&  ls -l --time-style="+%Y-%m-%d_%H:%M:%S" "$val" | cut -d' ' -f5-6`
					fi	
					printf '#---> %-30s = %s %s %s\n'  $f $val $infos  2>&1 | ${TEE}
			fi
	done <"$fexport"
	echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   
}	

#---------------------------------------------------------------------------
# FUNCTION: EST_FCT_GONOGO
#
# 1 input parameter
#
# - Chain name file
#
# Subject: Elle permet de lancer lancer ou non la chaine ( parametre de la
#          fonction) en fonction d'un d'un plan genere par la chaine
#          ESCJ0000.cmd.
#          si la variable EST_${HAIN}
#          la chaine n'est pas lancee
#
#--------------------------------------------------------------------------
EST_FCT_GONOGO()
{
#set -x
	echo '#------------------------------------------'  2>&1 | ${TEE}
    #CHAIN_NAME=`echo $1 | awk '{print substr($0,length($0)-7)}'`
    CHAIN_NAME=`echo $1 | cut -d"_" -f2- `
    CHAIN_WO_EXT=`echo $1 | cut -d"_" -f2- `
	
	
	#case IFRS17 chain
	#if [[ "${ARG2_CHN_1}" != I17* && "${ARG2_CHN_1}" != AA* &&  "${ARG2_CHN_1}" != EBS* && "${ARG2_CHN_1}" != I4I* ]]  
	if [[ "${ARG2_CHN_1}" =~ ^(I17|EBS|I4I|AA)  ]]
	then
		CHAIN_NAME=${CHAIN_NAME}_${IDF_CT}
		#echo "# update CHAIN_NAME: ${CHAIN_NAME} "  2>&1 | ${TEE} 
	fi 
	   
	export GONOGO_VAR=`eval echo '$'EST_${CHAIN_NAME}_GONOGO`
	export GONOGO_VAR2=`eval echo '$'EST_${CHAIN_WO_EXT}_${CHAIN_WO_EXT}_GONOGO`

	echo "# CHAIN_NAME: ${CHAIN_NAME} "  2>&1 | ${TEE}
	echo "# GONOGO_VAR: EST_${CHAIN_NAME}_GONOGO = ${GONOGO_VAR} "  2>&1 | ${TEE}
	echo "# GONOGO_VAR2: EST_${CHAIN_WO_EXT}_${CHAIN_WO_EXT}_GONOGO = ${GONOGO_VAR2} "  2>&1 | ${TEE}
	echo '#------------------------------------------'  2>&1 | ${TEE}

	if [ "${EST_PLAN}" != "" ] 
	then
		export gonogo=`grep EST_${CHAIN_NAME}_GONOGO ${EST_PLAN}| cut -d'"' -f2`
		[ "$gonogo" = "Y" ] && echo "# Old mode ${CHAIN_NAME}: GO"   2>&1 | ${TEE}
		[ "$gonogo" = "N" ] && echo "# Old mode ${CHAIN_NAME}: NO GO "   2>&1 | ${TEE}
	fi
	
    if [ "${GONOGO_VAR}" != "Y"  -a "${GONOGO_VAR2}" != "Y" ]
    then
        if [ "${JOB_NOECHO}" != "YES" ]
        then
            echo '#------------------------------------------'  2>&1 | ${TEE}
            echo "# ${CHAIN_NAME}: NO GO "  2>&1 | ${TEE}
            echo '#------------------------------------------'  2>&1 | ${TEE}
        fi

        return 1
    fi
	echo '#------------------------------------------'  2>&1 | ${TEE}
	echo "# ${CHAIN_NAME}: GO "  2>&1 | ${TEE}
	echo '#------------------------------------------'  2>&1 | ${TEE}

}

ESCJ0000_PLAN()
{
#set -x
	##if [ "$LOGNAME" = "ubam"  -a "`hostname`" = "AEnDevO2Batch" ]
	#if [[ "${ARG2_CHN_1}" =~ ^(I17|EBS|I4I|AA)  ]]
	#then
		echo  "#----> Planified with ................: $DFILP/${PCH}ESFJ0000_PLAN.dat"       2>&1 | ${TEE}
		. $DFILP/${PCH}ESFJ0000_PLAN.dat
	#else
	#    echo  "#---->Planified with ................: ${EST_PLAN}"                           2>&1 | ${TEE}
    #    . ${EST_PLAN}
	#fi
set +x
}

#set +x
if [ "$IS_ESCD9001" = "Y" ] 
then
	export IDF_CT=""
else
	export IDF_CT="$1"
fi



#split $IDF_CT
export ARG2_CHN_1=`echo "${IDF_CT}" | cut -d"_" -f1`
export ARG2_CHN_2=`echo "${IDF_CT}" | cut -d"_" -f2`
export ARG2_CHN_3=`echo "${IDF_CT}" | cut -d"_" -f3`
export ARG2_CHN_4=`echo "${IDF_CT}" | cut -d"_" -f4`
export ARG2_CHN_5=`echo "${IDF_CT}" | cut -d"_" -f5`

#export parametrs, all  suffix I17* will replaced by I17
#each norme have his parameters
#set -x
. ${DFILP}/${PCH}ESFJ0000_PARM_GLOBAL.dat
TRACE_EXPORTS ${DFILP}/${PCH}ESFJ0000_PARM_GLOBAL.dat
if [[ "${ARG2_CHN_1}" =~ ^(I17|EBS|I4I|AA)  ]]
then	
	export PARAM_FILE=${DFILP}/${PCH}ESFJ0000_PARM_`echo ${ARG2_CHN_1} #| sed s'/I17./I17/'`.dat 
	touch  ${PARAM_FILE}
	. ${PARAM_FILE}
	TRACE_EXPORTS ${PARAM_FILE} 
	if [ "$ARG2_CHN_1" = "EBS" ]
	then
		export param_Context_id=${TYPEINV}E
	fi
	if [ "$ARG2_CHN_1" = "I4I" ]		
	then
		export param_Context_id=${TYPEINV}I
	fi

	if [ "$ARG2_CHN_1" = "I17G" ]
	then
		export param_Context_id=${TYPEINV}G
	fi
	
	if [ "$ARG2_CHN_1" = "I17S" ]
	then
		export param_Context_id=${TYPEINV}S
	fi
	
	`grep "${PARM_ICLODAT_D}~${PARM_BALSHEYEA_NF}~.*${PARM_BALSHTMTH_NF}~" $DFILP/${PCH}ESFJ0000_SUFFTABLE.dat | cut -d~ -f4`

	if [[ "${ARG2_CHN_5}" =~ ^(AA)  ]]
	then	
		export NORME2=EBS
	fi
else
	if [ "$VNORME" != "" ]
	then
		export PARAM_FILE=${DFILP}/${PCH}ESFJ0000_PARM_`echo ${VNORME}  #| sed s'/I17./I17/'`.dat 
		touch  ${PARAM_FILE}
		. ${PARAM_FILE}
		TRACE_EXPORTS ${PARAM_FILE} 
	fi
fi

if [ "$IS_ESCD9001" = "Y" ]
then
        export SSDs0=$1
        export SSDs=$2
        export BALSHTYEA=$3
        export BALSHTMTH=$4
        export CRE_D=$5
        export DBCLO=$6
        export CLODAT=$7
        export ICLODAT=$8
        export ICLODAT2=$8
        export IDF_CT=""
	end_ICLODAT=`echo "$ICLODAT" | cut -c 5-8`
	if [ "$ICLODAT" != "" ]
	then
        	export PARM_ISSDCLO_LL=$SSDs #[04]
	fi
	if [ "${EST_PARAM}" != "" ]
	then
		if [ "${PARM_ICLODAT_D}"  = "" ]
        	then
			export PARM_ICLODAT_D=`grep ICLODAT_D ${EST_PARAM}|awk -F" " '{print $2}'`
		fi
		if  [ "${end_ICLODAT}" = "1231" ]
		then
			export PARM_ICLODAT2_D="$ICLODAT"
		else
			export PARM_ICLODAT2_D="$PARM_ICLODAT_D"
		fi
	fi
else
        export CRE_D=$PARM_CRE_D
        export DBCLO=${PARM_DBCLO_D}
        export BALSHTYEA=$PARM_BLCSHTYEA_NF
        export BALSHTMTH=$PARM_BLCSHTMTH_NF
        export CLODAT=$PARM_CLODAT_D
        export ICLODAT=$PARM_ICLODAT_D
        export IDF_CT="$1"
fi

# Get entry parameters
set `GETPRM ${DPRM}/ESGD255V${DEV_TEST}.prm`
export VSERQS_I4I=${1}
export VSERQS_EBS=${2}
export VSERQS_I17G=${3}
export VSERQS_I17P=${4}
export VSERQS_I17L=${5}
if [ "$VSERQS_I4I" = "YES" ]; then 
	export NOT_USED="_NOT_USED"
fi

#calcul de NORME0
export NORME0='SII'
if [[ "$ARG2_CHN_1" = "EBS" ||  "$VNORME" = "EBS" ]]
then
        export NORME0='SII'
		if [ "${TYPEINV}" = "INV" ]
		then
			TYPEINV0='SO'
		fi
fi

#calcul de TYPEINV0
if [ "${TYPEINV}" = "POS" ]
then
        TYPEINV0='SO'
fi

if [ "${TYPEINV}" = "POC" ]
then
        TYPEINV0='CO'
fi
if [ "${TypePOST}" = "ESLOCAL" ]
then
        TYPEINV=ESLOCAL
fi

export TYPEINV0


export CLODATMAX_QTR=`echo ${PARM_INVCONSO_D} | awk '{trim = substr($0,5,2)/3; print trim;}'`
export CLODATMAX_YEA=`echo ${PARM_INVCONSO_D} | cut -c1-4`


#extraction du nom de la chaine , sans le prefix
CHAIN_NAME=`echo "$NCHAIN" | cut -d"_" -f2- `


# [15] =================================== 

export PARAM_DFILPAS="${DSCORDATA}/ubas/perm"
export PARAM_DFILPEU="${DSCORDATA}/ubeu/perm"
export PARAM_DFILPAM="${DSCORDATA}/ubam/perm"

case "$DEFAULT_SQL_LOGIN" in
     "ubas" ) SITE="SGP1" ;;
     "ubeu" ) SITE="FRA1" ;;
     "ubam" ) SITE="USA1" ;;
      *)      SITE="OTH1" ;; #--- ubgl or future users

esac


export PARAM_LOCALSIT="${SITE}_${SITE}"       # example on AS: "SGP1_SGP1"
export PARAM_LOCALTOAM="${SITE}_USA1"       # example on AS: "SGP1_USA1"
export PARAM_LOCALTOEU="${SITE}_FRA1"        # example on AS: "SGP1_FRA1"
export PARAM_LOCALTOAS="${SITE}_SGP1"        # example on EU: "FRA1_SGP1"
export PARAM_ASTOLOCAL="SGP1_${SITE}"        # example on AM: "SGP1_USA1"
export PARAM_EUTOLOCAL="FRA1_${SITE}"        # example on AS: "FRA1_SGP1"
export PARAM_AMTOLOCAL="USA1_${SITE}"        # example on EU: "USA1_FRA1"
#===================================



# --- ESCD9001 ------------------------------------------------------------------------------------------------------------------------------------
export NORME_CF=$VNORME
#set -x 
if [ "${IS_ESCD9001}" = "Y" ]  
then
		VERSION_9001="ESCD9001"
		
		grep "^${CHAIN_NAME}~"  ${DFILP}/${PCH}ESFJ0000_TI17PERMFIL.dat | awk 'BEGIN{FS="~"; } { print "export " $2"="$3 }' | sort > $DFILT/${NCHAIN}_${IB}_PERM.dat
		. $DFILT/${NCHAIN}_${IB}_PERM.dat
		TRACE_EXPORTS_EVAL  $DFILT/${NCHAIN}_${IB}_PERM.dat
  
        #        echo  "#---->Planified with ................: ${EST_PLAN}"                           2>&1 | ${TEE}
        #        . ${EST_PLAN}
		ESCJ0000_PLAN

# --- ESFD9001 ------------------------------------------------------------------------------------------------------------------------------------
else  
	# --- IFRS17 ------------------------------------------------------------------------------------------------------------------------------------
	if [[ "${ARG2_CHN_1}" =~ ^(I17|EBS|I4I|AA)  ]]
	then
		VERSION_9001="ESFD9001 IFRS17"
		export NORME_CF=${ARG2_CHN_1}
		export PATCAT_CT=${ARG2_CHN_2}
		export PATTYP_CT=${ARG2_CHN_3}
		export CONTEXT_CT=${ARG2_CHN_4}
		export TYPEAOC_CT=${ARG2_CHN_5}
		export VNORME=${NORME_CF}

	        echo  "#----> Planified with ................: $DFILP/${PCH}ESFJ0000_PLAN.dat"       2>&1 | ${TEE}
           	. $DFILP/${PCH}ESFJ0000_PLAN.dat

        	grep "^${IDF_CT}~"  ${DFILP}/${PCH}ESFJ0000_TI17PERMFIL.dat | awk 'BEGIN{FS="~"; } { print "export " $2"="$3 }' | sort > $DFILT/${NCHAIN}_${IDF_CT}_${IB}_PERM.dat
        	. $DFILT/${NCHAIN}_${IDF_CT}_${IB}_PERM.dat
        	TRACE_EXPORTS_EVAL  $DFILT/${NCHAIN}_${IDF_CT}_${IB}_PERM.dat
	
	else 
		
			VERSION_9001="ESFD9001 IFRS4"

			ESCJ0000_PLAN

			grep "^${CHAIN_NAME}_${IDF_CT}~"  ${DFILP}/${PCH}ESFJ0000_TI17PERMFIL.dat | awk 'BEGIN{FS="~"; } { print "export " $2"="$3 }' | sort > $DFILT/${NCHAIN}_${IDF_CT}_${IB}_PERM.dat
			. $DFILT/${NCHAIN}_${IDF_CT}_${IB}_PERM.dat
			TRACE_EXPORTS_EVAL  $DFILT/${NCHAIN}_${IDF_CT}_${IB}_PERM.dat
		#fi

	fi
fi
#set +x

# TYPEINV chaque norme a son CLOTYP_CT dans le nouveau mode -------------------

#`grep TYPEINV_${VNORME} ${DFILP}/${PCH}ESFJ0000_PARM.dat | sed s"/PARM_//" | sed s"/_${VNORME}//"|  sed s'/#.*//'` 
#

#[011]	 
#export des conditions 
. ${DFILP}/${PCH}ESFJ0000_COND.dat
TRACE_EXPORTS ${DFILP}/${PCH}ESFJ0000_COND.dat

 
# Closing period
#------------------------------------------------------------------------------
#export CLOPRD=`printf "%04d%02d" ${BALSHTYEA} ${BALSHTMTH}`


# Deconcatenation of closing period date
#------------------------------------------------------------------------------
export ICLODAT_YEA=`echo ${PARM_ICLODAT_D} | cut -c1-4`
export ICLODAT_MTH=`echo ${PARM_ICLODAT_D} | cut -c5-6`
export ICLODAT_DAY=`echo ${PARM_ICLODAT_D} | cut -c7-8`
export CLODATMAX_D=${PARM_ICLODAT_D}

export FIL_ALLCLO=FACMTRSH_FBANTECL_FCTRFIC_FCURCVSNI_FCURQUOT_FDETTRS_FGRP_FINTWIT_FLIBEL1_FLIBEL2_FLIFDRI_FLSTMTH_FRETPAR_FRETTRF_FSEGPAR_FSSDACTR_FSUBSID_FTRSLNK_FURRDAC_FSOBBLOB_FSEGMENT_CPLIFDRI_CPLIFDRIN_CRIBLEANO_FVPLACEMT_SEGRATANO_SRGTC_SRGTCB1_VLIFEST195_IARVPERICASE0_LIFESTNOACC_LIFESTANA_CPLIFEST_FRATTACHEVOL_FUNDSTA0_FBSEGEST_FCLIENT_FBOPRSLNK_FTVENTNP_FVENTNPANT_LIFTRANSFR_DLRLIFEP_FLIFPEN_FLIFTHR_FLIFMOD_FLIFMOD2_FTRSLNK7_FTFAMCHG_FCURCVSN_FTVENTNPHIS_SAISPERICASE_FFAMCNA_FLIFEST1_FCURSII_FRATINGRTO_FSEGPATTERN_BDT_FSEGPATTERN_CSF_FSEGPATTERN_DSC_FTRANSCODE_LIFENDCPT_VENTNP_TRIMPREV_VENTNP_TRIMCUR_FVPLACEMT2




echo ""


echo  "#----> VNORME .........................: ${VNORME}"                           2>&1 | ${TEE}
echo  "#----> EST_PLAN .......................: ${EST_PLAN}"                         2>&1 | ${TEE}
echo  "#----> EST_PARAM ......................: ${EST_PARAM}"                        2>&1 | ${TEE}
echo  "#----> VERSION_9001 ...................: ${VERSION_9001}"                     2>&1 | ${TEE}
echo  "#----> NCHAIN .........................: ${NCHAIN}"                           2>&1 | ${TEE}
echo  "#----> CHAIN ..........................: ${CHAIN_NAME}"                       2>&1 | ${TEE}
echo  "#----> CLOPRD .........................: ${CLOPRD}"                           2>&1 | ${TEE}
echo  "#----> CLODAT .........................: ${CLODAT}"                           2>&1 | ${TEE}
echo  "#----> ICLODAT ........................: ${ICLODAT}"                          2>&1 | ${TEE}
echo  "#----> CLODATMAX_D ....................: ${CLODATMAX_D}"                      2>&1 | ${TEE}
echo  "#----> ICLODAT_YEA ....................: ${ICLODAT_YEA}"                      2>&1 | ${TEE}
echo  "#----> ICLODAT_MTH ....................: ${ICLODAT_MTH}"                      2>&1 | ${TEE}
echo  "#----> ICLODAT_DAY ....................: ${ICLODAT_DAY}"                      2>&1 | ${TEE}
echo  "#----> IDF_CT .........................: ${IDF_CT}"                           2>&1 | ${TEE}
echo  "#----> TYPEINV ........................: ${TYPEINV}"                          2>&1 | ${TEE}
echo  "#----> TYPEINV0 .......................: ${TYPEINV0}"                         2>&1 | ${TEE}
echo  "#----> NORME0..........................: ${NORME0}"                           2>&1 | ${TEE}
echo  "#----> NORME2..........................: ${NORME2}"                           2>&1 | ${TEE}

echo  "#----> EST_SORT_CONDITION .............: ${EST_SORT_CONDITION}"               2>&1 | ${TEE}
echo  "#----> BALSHTYEA ......................: ${BALSHTYEA}"                        2>&1 | ${TEE}
echo  "#----> BALSHTMTH ......................: ${BALSHTMTH}"                        2>&1 | ${TEE}
echo  "#----> CRE_D ..........................: ${CRE_D}"                            2>&1 | ${TEE}
echo  "#----> DBCLO ..........................: ${DBCLO}"                            2>&1 | ${TEE}


echo  "#----> ARG2_CHN_1 .....................: ${ARG2_CHN_1}"                       2>&1 | ${TEE}
echo  "#----> ARG2_CHN_2 ...................... ${ARG2_CHN_2}"                       2>&1 | ${TEE}
echo  "#----> ARG2_CHN_3 .....................: ${ARG2_CHN_3}"                       2>&1 | ${TEE}
echo  "#----> ARG2_CHN_4 .....................: ${ARG2_CHN_4}"                       2>&1 | ${TEE}
echo  "#----> ARG2_CHN_5 .....................: ${ARG2_CHN_5}"                       2>&1 | ${TEE}
echo  "#----> NORME ..........................: ${NORME}"                            2>&1 | ${TEE}
echo  "#----> NORME_CF .......................: ${NORME_CF}"                         2>&1 | ${TEE}
echo  "#----> PATCAT_CT ......................: ${PATCAT_CT}"                        2>&1 | ${TEE}
echo  "#----> PATTYP_CT ......................: ${PATTYP_CT}"                        2>&1 | ${TEE}
echo  "#----> CONTEXT_CT .....................: ${CONTEXT_CT}"                       2>&1 | ${TEE}
echo  "#----> PARM_SUFFTABLE .................: ${PARM_SUFFTABLE}"                   2>&1 | ${TEE}
echo  "#----> PARM_ICLODAT_D .................: ${PARM_ICLODAT_D}"                   2>&1 | ${TEE}


echo  "#----> param_Demande ..................: ${param_Demande}"                    2>&1 | ${TEE}
echo  "#----> param_Closing_B ................: ${param_Closing_B}"                  2>&1 | ${TEE}
echo  "#----> param_nb_NoLife ................: ${param_nb_NoLife}"                  2>&1 | ${TEE}
echo  "#----> EST_VARIANTE ...................: ${EST_VARIANTE}"                     2>&1 | ${TEE}
echo  "#----> param_nb_Life ..................: ${param_nb_Life}"                    2>&1 | ${TEE}
echo  "#----> IsEpo ..........................: ${IsEpo}"                            2>&1 | ${TEE}
echo  "#----> nb_NoEBS .......................: ${nb_NoEBS}"                         2>&1 | ${TEE}
echo  "#----> param_Context_id ...............: ${param_Context_id}"                 2>&1 | ${TEE}
echo  "#----> end_ICLODAT ....................: ${end_ICLODAT}"                      2>&1 | ${TEE}
echo  "#----> IT ........ ....................: ${IT}"                               2>&1 | ${TEE}

echo  "#----> PARAM_DFILPAS ..................: ${PARAM_DFILPAS}"                               2>&1 | ${TEE}
echo  "#----> PARAM_DFILPEU ..................: ${PARAM_DFILPEU}"                               2>&1 | ${TEE}
echo  "#----> PARAM_DFILPAM ..................: ${PARAM_DFILPAM}"                               2>&1 | ${TEE}
echo  "#----> PARAM_LOCALSIT .................: ${PARAM_LOCALSIT}"                               2>&1 | ${TEE}
echo  "#----> PARAM_LOCALTOAM ................: ${PARAM_LOCALTOAM}"                               2>&1 | ${TEE}
echo  "#----> PARAM_LOCALTOEU ................: ${PARAM_LOCALTOEU}"                               2>&1 | ${TEE}
echo  "#----> PARAM_LOCALTOAS ................: ${PARAM_LOCALTOAS}"                               2>&1 | ${TEE}
echo  "#----> PARAM_ASTOLOCAL ................: ${PARAM_ASTOLOCAL}"                               2>&1 | ${TEE}
echo  "#----> PARAM_EUTOLOCAL ................: ${PARAM_EUTOLOCAL}"                               2>&1 | ${TEE}
echo  "#----> PARAM_AMTOLOCAL ................: ${PARAM_AMTOLOCAL}"                               2>&1 | ${TEE}






echo  "#----> VSERQS_I4I  ................: ${VSERQS_I4I}"                               2>&1 | ${TEE}
echo  "#----> VSERQS_EBS  ................: ${VSERQS_EBS}"                               2>&1 | ${TEE}
echo  "#----> VSERQS_I17G ................: ${VSERQS_I17G}"                               2>&1 | ${TEE}
echo  "#----> VSERQS_I17P ................: ${VSERQS_I17P}"                               2>&1 | ${TEE}
echo  "#----> VSERQS_I17L ................: ${VSERQS_I17L}"                               2>&1 | ${TEE}
echo  "#----> NOT_USED ...................: ${NOT_USED}"                               2>&1 | ${TEE}





# executed except with asynchrone jobs
#-------------------------------------------------------------------------
if [ "${LAUNCHER}" != "DAEMON" ]
then


    #ret de la chaine si elle ne figure pas dans le plan d'execution
    #-----------------------------------------------------------------
    EST_FCT_GONOGO ${NCHAIN}

    if [ $? != 0 ]
    then
        echo "chain end "
        CHAINEND
    fi
	set `GETPRM ${DPRM}/ESCJ0000.prm`
	IS_SIMU=$2

    if [ "$IS_SIMU" = "Y" ]
    then
	   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
	   echo '#----> Mode Simu'  2>&1 | ${TEE}
	   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
        echo "Mode Simu"
        CHAINEND
    fi

fi


if [ "${JOB_NOECHO}" != "YES" ]
then
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   echo '# End of initialization job    : ' ${NJOB} " Date : " `date +"%Y/%m/%d %H:%M:%S"`  2>&1 | ${TEE}
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
fi
