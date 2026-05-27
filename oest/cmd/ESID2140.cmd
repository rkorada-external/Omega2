all generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1 

# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8


# Job Initialisation
JOBINIT

NJOB="ESID2140"




NSTEP=${NJOB}_01
#--------------------------------------------------------------------------
LIBEL="SELECT from BEST..TLIFEST"
BCP_WAY="OUT";
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_VLIFEST_O1.dat
BCP_QRY="SELECT * from BEST..TLIFEST where balshey_nf=2014 "
BCP

gzip -c ${DFILT}/${NSTEP}_${IB}_BCP_VLIFEST_O1.dat   > ${DFILT}/${NSTEP}_${IB}_BCP_VLIFEST_O1.dat.gz
 
NSTEP=${NJOB}_05
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Estimates File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_VLIFEST_O1.dat
BCP_QRY="execute BEST..PsLIFEST_12 2014"
BCP

gzip -c ${DFILT}/${NSTEP}_${IB}_BCP_VLIFEST_O1.dat   > ${DFILT}/${NSTEP}_${IB}_BCP_VLIFEST_O1.dat.gz


NSTEP=${NJOB}_10
## Tri du LIFESTLIB
##------------------------------------------------------------------------------
LIBEL="Tri du LIFESTLIB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_VLIFEST_O1.dat 1000 1"
#SORT_I="${DFILT}/ESID2140_05_dcvdevobbatch_20140811154535_47127_BCP_VLIFEST_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFESTLIB2009_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_LIFESTCONST_O.dat 1000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_LIFESTAUTRE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:EN,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:EN,
        CRE_D            8:1 -  8:,
        ACMTRS_NT       10:1 - 10:,
        ACMTRS4_NT      10:4 - 10:4,
        BALSHEY_NF      11:1 - 11:,
        BALSHMTH_NF     12:1 - 12:EN,
        CUR_CF          13:1 - 13:,
        ESTMNT_M        14:1 - 14:EN 15/3,
        ORICOD_LS       16:1 - 16:,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:
/KEYS CTR_NF,
			END_NT,
			SEC_NF,
			ACY_NF,
			UWY_NF,
			UW_NT,
			BALSHEY_NF,
			CRE_D,
			ACMTRS_NT,
			DETTRNCOD_CF,
			GAAP_NF,
			CUR_CF,
			ORICOD_LS			
/CONDITION AUTRE ( ACMTRS4_NT NE "3" and  ACMTRS4_NT NE "4" )
/CONDITION CONSTIT (ACMTRS4_NT EQ "3")
/CONDITION LIB2009 (ACMTRS4_NT EQ "4" and  (ACY_NF = 2009))
/OUTFILE  ${SORT_O}
/INCLUDE LIB2009
/OUTFILE  ${SORT_O2}
/INCLUDE CONSTIT		
/OUTFILE ${SORT_O3}
/INCLUDE AUTRE
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFESTLIB2009_O.dat   > ${DFILT}/${NSTEP}_${IB}_SORT_LIFESTLIB2009_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFESTCONST_O.dat     > ${DFILT}/${NSTEP}_${IB}_SORT_LIFESTCONST_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFESTAUTRE_O.dat    > ${DFILT}/${NSTEP}_${IB}_SORT_LIFESTAUTRE_O.dat.gz
#
#
#echo $CRE_D
#echo $BALSHTYEA
#
NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
# Calcul des nouvelles liberations et ajout des liberations 2009
#------------------------------------------------------------------------------
PRG=ESTC2165
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D 20140821
BALSHTYEA 2014
ACY_MIN 5
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_LIFESTCONST_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_LIFESTLIB2009_O.dat
export ${PRG}_I3=${DFILI}/T_ESCJ0060_FSUBTRS_20140930_201409_20140821_20140821.dat
export ${PRG}_I4=${DFILI}/T_ESCJ0060_FSUBTRSASSO_20140930_201409_20140821_20140821.dat
export ${PRG}_I5=${DFILI}/T_ESID2030_IARVPERICASE4_20140930_201409_20140821_20140821.dat
export ${PRG}_O=${DFILT}/${NSTEP}_${IB}_${PRG}_NEW_LIFESTLib_O1.dat
EXECPRG

#cd $DEXE
##Pour lancer DBX
#debugV2 ${PRG}


gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_NEW_LIFESTLib_O1.dat   > ${DFILT}/${NSTEP}_${IB}_${PRG}_NEW_LIFESTLib_O1.dat.gz

NSTEP=${NJOB}_20
# Tri du fichier VLIFEST 
# Créion du CPLIFEST_MVT pour recharger dans TLIFEST
#------------------------------------------------------------------------------
LIBEL="Tri du fichier VLIFEST Créion du CPLIFEST_MVT pour recharger dans TLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC2165_NEW_LIFESTLib_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CPLIFEST_MVT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:EN,
        CRE_D            8:1 -  8:,
        PRS_CF           9:1 -  9:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        CUR_CF          13:1 - 13:,
        ESTMNT_M        14:1 - 14:EN 15/3,
        INDSUP_B        15:1 - 15:,
        ORICOD_LS       16:1 - 16:,
        CREUSR_CF       17:1 - 17:,
        LSTUPD_D        18:1 - 18:,
        LSTUPDUSR_CF    19:1 - 19:,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:,
        CRE_D2           8:1 -  8:14,
        GAAPDIFF_M       23:1 - 23:EN 15/3,
        PROPAGATION_B   24:1 - 24:,
        ESTMTH_NF       25:1 - 25:,
        ORICTR_NF       26:1 - 26:,
        ORISEC_NF       27:1 - 27:,
        ORIUWY_NF       28:1 - 28:,
        BATCH_B         52:1 - 52:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT DESCENDING,
      DETTRNCOD_CF DESCENDING,
      GAAP_NF DESCENDING,
      CRE_D     DESCENDING
/DERIVEDFIELD  CALCULATED_B "0~" 
/DERIVEDFIELD  ESTMTH_N "13~"
/DERIVEDFIELD INDSUP_B0 "0~"
/CONDITION ACY (ACY_NF <= 2018)
/OUTFILE   ${SORT_O}
/REFORMAT CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF,GAAP_NF,DETTRNCOD_CF,
          ESTMTH_N,PRS_CF,ACMTRS_NT,SSD_CF,CUR_CF,ESTMNT_M,INDSUP_B0,ORICOD_LS,CREUSR_CF,LSTUPD_D,LSTUPDUSR_CF,
          ORICTR_NF,ORISEC_NF,ORIUWY_NF,GAAPDIFF_M,PROPAGATION_B,CALCULATED_B,BATCH_B
exit
EOF
SORT


gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_CPLIFEST_MVT_O.dat   > ${DFILT}/${NSTEP}_${IB}_SORT_CPLIFEST_MVT_O.dat.gz

NSTEP=${NJOB}_25
# Begin  isql
#--------------------------------------------------------------------------
LIBEL="DELETE BEST..TLIFEST"
ISQL_BASE="BEST"
ISQL_QRY="DELETE from BEST..TLIFEST where balshey_nf=2014 and SSD_CF in (1,2,3,4,5,6,7,12,15,16,17,18,19,23) and acmtrs_nt%10 = 4 and acy_nf >= 2009" 
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

#NSTEP=${NJOB}_05
## Delete internal retro for dbclo periode for CPLIFEST
##[002]
##------------------------------------------------------------------------------
#LIBEL="Delete internal retro for dbclo periode for CPLIFEST"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/ESID2140_01_dcvuatobbatch_20140812171258_35433_BCP_VLIFEST_O1.dat"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_BCP_VLIFEST_O1.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF 1:1 - 1:,
#        END_NT 2:1 - 2:,
#        SEC_NF 3:1 - 3:,
#        UWY_NF 4:1 - 4:,
#        UW_NT  5:1 - 5:,
#        CRE_D   6:1 - 6:,
#        BALSHEY_NF  7:1 - 7:,
#        BALSHTMTH_NF 8:1 - 8:EN,
#        ACY_NF 9:1 - 9:EN,
#        PRS_CF 13:1 - 13:,
#        ACMTRS_NT 14:1 - 14:,
#        ACMTRS4_NT      14:4 - 14:4,
#        SSD_CF           15:1 -  15:EN,
#        DETTRNCOD_CF	11:1 - 11:,
#        GAAP_NF      10:1 - 10:,
#        LSTUPD_D     21:1 - 21:
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      CRE_D DESCENDING,
#      BALSHEY_NF,
#      BALSHTMTH_NF,
#      ACY_NF,
#      PRS_CF,
#      ACMTRS_NT,
#      GAAP_NF,	
#      DETTRNCOD_CF,
#      LSTUPD_D  DESCENDING
#/CONDITION CONSTIT (ACMTRS4_NT EQ "4" and  ( SSD_CF =20 or SSD_CF=22 or SSD_CF= 24)  and acy_nf > 2009) 
#/OUTFILE ${SORT_O}
#/INCLUDE CONSTIT
#exit
#EOF
#SORT
#
#NSTEP=${NJOB}_10
## Delete internal retro for dbclo periode for CPLIFEST
##[002]
##------------------------------------------------------------------------------
#LIBEL="Delete internal retro for dbclo periode for CPLIFEST"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_BCP_VLIFEST_O1.dat"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_BCP_VLIFEST_O1.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF 1:1 - 1:,
#        END_NT 2:1 - 2:,
#        SEC_NF 3:1 - 3:,
#        UWY_NF 4:1 - 4:,
#        UW_NT  5:1 - 5:,
#        CRE_D   6:1 - 6:,
#        BALSHEY_NF  7:1 - 7:,
#        BALSHTMTH_NF 8:1 - 8:EN,
#        ACY_NF 9:1 - 9:EN,
#        PRS_CF 13:1 - 13:,
#        ACMTRS_NT 14:1 - 14:,
#        DETTRNCOD_CF	11:1 - 11:,
#        GAAP_NF      10:1 - 10:,
#        LSTUPD_D     21:1 - 21:
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      CRE_D DESCENDING,
#      BALSHEY_NF,
#      BALSHTMTH_NF,
#      ACY_NF,
#      PRS_CF,
#      ACMTRS_NT,
#      GAAP_NF,	
#      DETTRNCOD_CF   
#/SUM 
#/STABLE
#/OUTFILE ${SORT_O}
#exit
#EOF
#SORT

NSTEP=${NJOB}_30
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading predictions file into TLIFEST table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_20_${IB}_SORT_CPLIFEST_MVT_O.dat
#BCP_I=${DFILT}/ESID2140_05_dcvuatobbatch_20140730123705_17201_BCP_VLIFEST_O1.dat
BCP_TABLE="BEST..TLIFEST"
BCP

#
#NSTEP=${NJOB}_35
### Deletion of Temporary Files
###------------------------------------------------------------------------------
#LIBEL="Deletion of Temporary Files"
##RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"
#

JOBEND

CHAINEND

