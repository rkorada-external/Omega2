#!/bin/ksh
#=============================================================================
#set -x

#*****************************************************************************
#Description : IFRS req 10.6 : script pour regenerer le fichier perm/EST_IADPERICASE 
#Author      : JYP
#Date        : 19/02/2019
#*****************************************************************************/


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


CHAININIT CNLD0030 $DENV/CNLD0030.env


# Get the parameters
export EST_PARAM=${DFILP}/${ENV_PREFIX}_ESCJ0000_IFRS17_PARM2.dat
set `GETPRM ${EST_PARAM}`

SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
CLOTYP_CT=${10}
SEGTYP_CT=${11}
SSDDEL_LL=${12}
LSTCLODAT_LL=${13}
SSDVRS_LL=${14}
INVCONSO_D=${21}
CONSOYEA=${22}
CONSOMTH=${23}




NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031


export EST_IADPERICASE="${ENV_PREFIX}_ESPT0000_IADPERICASE.dat"
export EST_FCURQUOT="${ENV_PREFIX}_ESCJ0060_FCURQUOT.dat"



# Initialisation of the Job
JOB_LOG_OUTPUT=TEE
JOBINIT

# SSD_CF=00, used for all subsidiaries
SSD_CF=00


case ${LOGNAME} in
        ubas)
								export EST_SORT_CONDITION="( SSD_CF=20 OR  SSD_CF=22 OR  SSD_CF=24)"
                break
                ;;
        ubeu)
  						  export EST_SORT_CONDITION="( SSD_CF=1 OR  SSD_CF=2 OR  SSD_CF=3 OR  SSD_CF=4 OR  SSD_CF=5 OR  SSD_CF=6 OR  SSD_CF=7 OR  SSD_CF=12 OR  SSD_CF=15 OR  SSD_CF=16 OR  SSD_CF=17 OR  SSD_CF=18 OR  SSD_CF=19 OR  SSD_CF=23)"
                break
                ;;
        ubam)
  							export EST_SORT_CONDITION="( SSD_CF=10 OR  SSD_CF=11 OR  SSD_CF=13 OR  SSD_CF=14 OR  SSD_CF=25 OR  SSD_CF=26 OR  SSD_CF=27)"
                break
                ;;
       *)         
  				ECHO_LOG "ERROR user $LOGNAME not managed "
  				echo "ERROR user $LOGNAME not managed "
				  exit 1
       			;;
esac


ECHO_LOG "EST_SORT_CONDITION: $EST_SORT_CONDITION CRE_D=$CRE_D CLODAT_D=$CLODAT_D SEGTYP_CT=$SEGTYP_CT "
ECHO_LOG "EST_IADPERICASE=$EST_IADPERICASE EST_FCURQUOT=$EST_FCURQUOT  " 



#[004]
NSTEP=${NJOB}_00
#Last version of ESEH1100 files deletion [006]
#-----------------------------------------------------------------
#RMFIL "  `dirname ${EST_IADPERICASE0}`/${NCHAIN}_IADPERICASE0*.dat
#         `dirname ${EST_IAVPERICASE0}`/${NCHAIN}_IAVPERICASE0*.dat
#         `dirname ${EST_IADPERICASE_ENTIER0}`/${NCHAIN}_IADPERICASE_ENTIER0*.dat
#         `dirname ${EST_IADPERIFCT0}`/${NCHAIN}_IADPERIFCT0*.dat"

###################
# Tables Download #
###################

NSTEP=${NJOB}_00

# START CONCURRENT STEPS
# -------------------------
PARALLEL_INIT  3
#

NSTEP=${NJOB}_05
#Constituting treaty perimeter file with BTRT database fields
#In case of subsidary 00, all the subsidaries are taken into account
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Treaties perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASETRT_O.dat
BCP_QRY="execute BEST..PsPERITRT_02 '${SEGTYP_CT}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_10
#Download to the file, the fields necessary to the
#facultatives perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Facs Perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASEFAC_O.dat
BCP_QRY="execute BEST..PsPERIFAC_02 '${SEGTYP_CT}' with recompile"
PARALLEL BCP



# END CONCURRENT STEPS
# -------------------------
PARALLEL_END


# Processing for Treaties Perimeter

NSTEP=${NJOB}_30
#Treaties Perimeter File Sort by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Sort of Treaties perimeter file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_PERICASETRT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASETRT_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      UWY_NF,
      UW_NT,
      SEC_NF
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_35
#Temporary file deletion
LIBEL="PERICASETRT temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_BCP_PERICASETRT_O.dat


NSTEP=${NJOB}_40
#Download to the file of charges reiterated and used for the CTBCOM_B
#Field Calculation for treaties.
#-----------------------------------------------------------------------------
LIBEL="Current Generation of reiterated Charges file..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FAMCHG2_O.dat
BCP_QRY="execute BEST..PsSECTION_09 ${SSD_CF}, '${CRE_D}'"
BCP

NSTEP=${NJOB}_45
#Sort of reiterated charges file by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Reiterated charges file Sort..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_40_${IB}_BCP_FAMCHG2_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FAMCHG2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        CHGLIN_NT 6:1 - 6:
/KEYS CTR_NF,
      END_NT,
      UWY_NF,
      UW_NT,
      SEC_NF,
      CHGLIN_NT
exit
EOF
SORT


NSTEP=${NJOB}_50
#Temporary file deletion
LIBEL="FAMCHG2 temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_BCP_FAMCHG2_O.dat


NSTEP=${NJOB}_55
#Field CTBCOM_B first part Calculation for Treaties Perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Calculation of field CTBCOM_B 1/2 of Treaties perimeter..."
PRG=ESTC0104
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_PERICASETRT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_45_${IB}_SORT_FAMCHG2_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASETRT_O.dat
EXECPRG

NSTEP=${NJOB}_60
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_PERICASETRT_O.dat
RMFIL ${DFILT}/${NJOB}_45_${IB}_SORT_FAMCHG2_O.dat


NSTEP=${NJOB}_85
#Merge and Sort of perimeter files by Contract/Endorsement/UW Year
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_75_${IB}_ESTC0102_PERICASETRT_O.dat 1000 1"
SORT_I="${DFILT}/${NJOB}_55_${IB}_ESTC0104_PERICASETRT_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_BCP_PERICASEFAC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4: EN,
        SEC_NF 5:1 - 5: EN,
        UWY_NF 6:1 - 6: EN,
        UW_NT 7:1 - 7: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE  ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_90
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_75_${IB}_ESTC0102_PERICASETRT_O.dat


NSTEP=${NJOB}_90
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_75_${IB}_ESTC0102_PERICASETRT_O.dat


NSTEP=${NJOB}_95
#Perimeter Fields Update
#[001]${EST_IADPERICASE0} et ${EST_IAVPERICASE0} devient le perimetre complet.
#[003]
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters Fields Update..."
PRG=ESTC0103
export ${PRG}_I1=${DFILT}/${NJOB}_85_${IB}_SORT_PERICASE_O.dat
export ${PRG}_I2=${DFILP}/${EST_FCURQUOT}
#export ${PRG}_O1=${EST_IADPERICASE_ENTIER0}
export ${PRG}_O1=${DFILT}/TMP_EST_IADPERICASE_ENTIER0.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_SORT_IAVPERICASE0_O.dat
#export ${PRG}_O2=${EST_IAVPERICASE0}
EXECPRG



#[001] Le vrai fichier perimetre est cr▒▒ dans le ESID1001 en concat▒nant les EST_IAVPERICASE0 et EST_IADPERICASE0.
#[005]
NSTEP=${NJOB}_100
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Creation du fichier perimetre Non Vie : "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_IADPERICASE_ENTIER0} 1000 1"
#SORT_O=${EST_IADPERICASE0}
SORT_I="${DFILT}/TMP_EST_IADPERICASE_ENTIER0.dat 1000 1"
SORT_O="${DFILT}/TMP_EST_IADPERICASE0.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR1_NF      3:1 -  3:1,
        CTR3_NF      3:3 -  3:3,
        SECSTS_CT   79:1 - 79:,
        CTRSTS_CT   99:1 - 99:,
       LOB_CF      38:1 - 38:
/CONDITION ANCIEN_PERIMETRE ( ( ( CTR3_NF >= "A" and CTR3_NF <= "M" ) OR CTR1_NF = "F" )  or
                              ( ( ( CTR3_NF >= "N" and CTR3_NF <= "Z" ) OR CTR1_NF = "T" )  and
                                ( ( ( SECSTS_CT = "14" or SECSTS_CT = "16" or SECSTS_CT = "17" or SECSTS_CT = "19" ) or
                                    ( SECSTS_CT = "14" and ( LOB_CF = "30" or LOB_CF = "31" ) ) )    and
                                  ( ( CTRSTS_CT = "14" or CTRSTS_CT = "16" or CTRSTS_CT = "17" or CTRSTS_CT = "19" ) or
                                    ( CTRSTS_CT = "14" and ( LOB_CF = "30" or LOB_CF = "31" ) ) ) ) ) )
/OUTFILE ${SORT_O}
/INCLUDE ANCIEN_PERIMETRE
/COPY
exit
EOF
SORT


#[001] Le vrai fichier perimetre est cr▒▒ dans le ESID1001 en concat▒nant les EST_IAVPERICASE0 et EST_IADPERICASE0.
#[003]
NSTEP=${NJOB}_105
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Creation du fichier perimetre Vie : "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_IAVPERICASE0_O.dat 1000 1"
#SORT_O=${EST_IAVPERICASE0}
SORT_O=${DFILT}/TMP_EST_IAVPERICASE0.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR3_NF      3:3 -  3:3,
        SECSTS_CT   79:1 - 79:,
        CTRSTS_CT   99:1 - 99:,
       LOB_CF      38:1 - 38:
/CONDITION ANCIEN_PERIMETRE ( SECSTS_CT = "14" or SECSTS_CT = "16" or SECSTS_CT = "17" or SECSTS_CT = "19" or SECSTS_CT = "23" )
/OUTFILE ${SORT_O}
/INCLUDE ANCIEN_PERIMETRE
/COPY
exit
EOF
SORT







NSTEP=${NJOB}_110
#IADPERICASE perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IADPERICASE perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_I="${DFILT}/TMP_EST_IADPERICASE0.dat 1000 1"
#SORT_O="${EST_IADPERICASE} OVERWRITE 1000 1"
SORT_O="${DFILT}/TMP_EST_IADPERICASE.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        SSD_CF 1:1 - 1: EN,
        SECINC_D 78:1 - 78: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SECINC_D <= ${CLODAT_D}
/INCLUDE INVENTAIRE
exit
EOF
SORT




if [ -f  ${DFILT}/TMP_EST_IADPERICASE.dat  ]
then
	  #=== check result is OK
	  nbline=`cat  ${DFILT}/TMP_EST_IADPERICASE.dat  | wc -l`
	  
	  if [ $nbline -le 200000 ]
	  then
	  	ECHO_LOG "ERROR anormal size of IADPEDICASE nbline=$nbline "
	  	echo "ERROR anormal size of IADPEDICASE nbline=$nbline "
	    exit 99
	  else
	  	ECHO_LOG "size of IADPEDICASE is OK:  nbline=$nbline "
	  	echo "size of IADPEDICASE is OK:  nbline=$nbline "

     ECHO_LOG "save old PERICASE to : ${DFILT}/${EST_IADPERICASE}.sav.$$  "

     EXECKSH "cp -p ${DFILP}/${EST_IADPERICASE} ${DFILT}/${EST_IADPERICASE}.sav.$$ "

     ECHO_LOG "OVERWRITE IADPERICASE : cp -p ${DFILT}/TMP_EST_IADPERICASE.dat ${DFILP}/${EST_IADPERICASE}  "
    
     EXECKSH "cp -p ${DFILT}/TMP_EST_IADPERICASE.dat ${DFILP}/${EST_IADPERICASE} "


     ECHO_LOG "Script finished OK code $? , new ${DFILP}/${EST_IADPERICASE} copied  : "
     ls -ltr ${DFILP}/${EST_IADPERICASE} >> $FLOG 
     

	  fi

else
	  	ECHO_LOG "ERROR cannot find ${DFILT}/TMP_EST_IADPERICASE.dat "
	  	echo "ERROR cannot find ${DFILT}/TMP_EST_IADPERICASE.dat "
fi

JOBEND
