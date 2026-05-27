#!/bin/ksh
#=============================================================================
# nom de l'application          : Illiquidity : Extract ILL Bucket by CSUOE
# nom du script SHELL           : ESFD2050.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 21/09/2021
# auteur                        : JYP - PERSEE
# references des specifications : Illiquidity
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 21/09/2021 : SPIRA 97283: JYP : Illiquidity - Extract ILL Bucket by CSUOE
#[002] 02/05/2022 : SPIRA 103999: JYP : Illiquidity , use previous extraction
#[003] 19/10/2022 : SPIRA 102482: MZM : IFRS17 Onerous Q+1 - additional scope
#===============================================================================
# set -x


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Switch Server Infomega"
SWITCH_SRV ${SRV_2}



NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Extract Segmenttation Information"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_$$_SEG_RESULT_O.dat
BCP_QRY="exec BSEG..PsILLBucketExtract '${TYPEINV}'"
BCP


# old archi, this chain is NOT in the closing part, files NOT managed into table TI17PERMFIL 
ESF_ILL_BUCKET_I17G=$DFILP/${ENV_PREFIX}_ESFD2050_ILL_BUCKET_I17G.dat 
ESF_ILL_BUCKET_I17P=$DFILP/${ENV_PREFIX}_ESFD2050_ILL_BUCKET_I17P.dat 
ESF_ILL_BUCKET_I17L=$DFILP/${ENV_PREFIX}_ESFD2050_ILL_BUCKET_I17L.dat 
ESF_ILL_BUCKET_PREV=$DFILP/${ENV_PREFIX}_ESFD2050_ILL_BUCKET_PREVIOUS.dat 

#cp -p $ESF_ILL_BUCKET_PREV  ${DFILT}/${NSTEP}_${IB}_$$_SEG_RESULT_O.dat


NSTEP=${NJOB}_12
#-----------------------------------------------------------------------------
LIBEL="touch ESF_ILL_BUCKET output files  "
EXECKSH_MODE=P
EXECKSH "touch $ESF_ILL_BUCKET_I17G "
EXECKSH_MODE=P
EXECKSH "touch $ESF_ILL_BUCKET_I17P "
EXECKSH_MODE=P
EXECKSH "touch $ESF_ILL_BUCKET_I17L "
if [ ! -f $ESF_ILL_BUCKET_PREV ]  # first run only
then
	EXECKSH_MODE=P
	EXECKSH "touch $ESF_ILL_BUCKET_PREV "
fi



NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="stats of extraction file  "
EXECKSH_MODE=P
EXECKSH "cut -d~ -f1,11  ${DFILT}/${NJOB}_10_${IB}_$$_SEG_RESULT_O.dat | sort | uniq -c > ${DFILT}/${NJOB}_15_${IB}_$$_RESULT_STATS.dat  "
cat ${DFILT}/${NJOB}_15_${IB}_$$_RESULT_STATS.dat


NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="additionnal data from previous file  "
EXECKSH_MODE=P
EXECKSH "touch ${DFILT}/${NJOB}_20_${IB}_$$_ADDITIONNAL.dat "

for norme in `echo I17G I17P I17L`
do 
  for typ in `echo 1 2 3`
  do 
      if [ "$typ" = "3" ]
	  then 
	      key="${norme}~ "
		  TYP=" "
	  else
	      key="${norme}~${typ}"	  
		  TYP="$typ"
	  fi
	  found=`grep "${key}$" ${DFILT}/${NJOB}_15_${IB}_$$_RESULT_STATS.dat | wc -l ` 
	  echo "key (${key}) => flag data found : $found "


	if [ $found -eq 0 ]
	then
NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="re-use previous data for key ${key} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$ESF_ILL_BUCKET_PREV 2000 1"
SORT_O="${DFILT}/${NJOB}_30_${IB}_$$_PREV_DATA_${norme}${typ}.dat  2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	NORME_CF 		1:1 - 1:,
	CTR_NF 			2:1 - 2:,
	END_NT 			3:1 - 3:,
	SEC_NF 			4:1 - 4:,
	UWY_NF 			5:1 - 5:,
	UW_NT 			6:1 - 6:,
	CTRTYP_CT 		7:1 - 7:,
	SGMT_NF 		8:1 - 8:,
	SGTLVL_NT 		9:1 - 9:,
	SGTTYP_NT 		10:1 - 10:,
	SEGCTRTYP_CT	11:1 - 11:,
	SGTVER_NT 		12:1 - 12:,
	SGT_NT			13:1 - 13:,
	SGMT_LS 		14:1 - 14:,
	SGMT_LL 		15:1 - 15:,
	GRPINISTS_CT	16:1 - 16:,
	PARINISTS_CT	17:1 - 17:,
	LOCINISTS_CT	18:1 - 18:
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/CONDITION COND_I17   (NORME_CF = "${norme}" AND SEGCTRTYP_CT = "$TYP" )
/INCLUDE COND_I17
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

		cat ${DFILT}/${NJOB}_30_${IB}_$$_PREV_DATA_${norme}${typ}.dat  >> ${DFILT}/${NJOB}_20_${IB}_$$_ADDITIONNAL.dat
	fi

  done
done 

wc -l ${DFILT}/${NJOB}_20_${IB}_$$_ADDITIONNAL.dat
cat ${DFILT}/${NJOB}_20_${IB}_$$_ADDITIONNAL.dat ${DFILT}/${NJOB}_10_${IB}_$$_SEG_RESULT_O.dat >> ${DFILT}/${NJOB}_30_${IB}_$$_SEG_ALL.dat



NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="reformat file NORME I17G "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_$$_SEG_ALL.dat 2000 1"
SORT_O="$ESF_ILL_BUCKET_I17G 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	NORME_CF 		1:1 - 1:,
	CTR_NF 			2:1 - 2:,
	END_NT 			3:1 - 3:,
	SEC_NF 			4:1 - 4:,
	UWY_NF 			5:1 - 5:,
	UW_NT 			6:1 - 6:,
	CTRTYP_CT 		7:1 - 7:,
	SGMT_NF 		8:1 - 8:,
	SGTLVL_NT 		9:1 - 9:,
	SGTTYP_NT 		10:1 - 10:,
	SEGCTRTYP_CT	11:1 - 11:,
	SGTVER_NT 		12:1 - 12:,
	SGT_NT			13:1 - 13:,
	SGMT_LS 		14:1 - 14:,
	SGMT_LL 		15:1 - 15:,
	GRPINISTS_CT	16:1 - 16:,
	PARINISTS_CT	17:1 - 17:,
	LOCINISTS_CT	18:1 - 18:
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/CONDITION COND_I17   (NORME_CF = "I17G" )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_I17
/REFORMAT
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	SGTTYP_NT,
	SGMT_NF,
	SGMT_LS,
	SGMT_LL,
	SGTVER_NT
exit
EOF
SORT

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="reformat file NORME I17P "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_$$_SEG_ALL.dat 2000 1"
SORT_O="$ESF_ILL_BUCKET_I17P 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	NORME_CF 		1:1 - 1:,
	CTR_NF 			2:1 - 2:,
	END_NT 			3:1 - 3:,
	SEC_NF 			4:1 - 4:,
	UWY_NF 			5:1 - 5:,
	UW_NT 			6:1 - 6:,
	SGMT_NF 		8:1 - 8:,
	SGTTYP_NT 		10:1 - 10:,
	SGTVER_NT 		12:1 - 12:,
	SGMT_LS 		14:1 - 14:,
	SGMT_LL 		15:1 - 15:
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/CONDITION COND_I17   (NORME_CF = "I17P" )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_I17
/REFORMAT
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	SGTTYP_NT,
	SGMT_NF,
	SGMT_LS,
	SGMT_LL,
	SGTVER_NT
exit
EOF
SORT


NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="reformat file NORME I17L "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_$$_SEG_ALL.dat 2000 1"
SORT_O="$ESF_ILL_BUCKET_I17L 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	NORME_CF 		1:1 - 1:,
	CTR_NF 			2:1 - 2:,
	END_NT 			3:1 - 3:,
	SEC_NF 			4:1 - 4:,
	UWY_NF 			5:1 - 5:,
	UW_NT 			6:1 - 6:,
	SGMT_NF 		8:1 - 8:,
	SGTTYP_NT 		10:1 - 10:,
	SGTVER_NT 		12:1 - 12:,
	SGMT_LS 		14:1 - 14:,
	SGMT_LL 		15:1 - 15:
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/CONDITION COND_I17   (NORME_CF = "I17L" )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_I17
/REFORMAT
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	SGTTYP_NT,
	SGMT_NF,
	SGMT_LS,
	SGMT_LL,
	SGTVER_NT
exit
EOF
SORT



NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="overwrite PREVIOUS ESF_ILL_BUCKET  "
EXECKSH_MODE=P
EXECKSH "cp -p ${DFILT}/${NJOB}_30_${IB}_$$_SEG_ALL.dat $ESF_ILL_BUCKET_PREV "


JOBEND



