#!/bin/ksh
#===============================================================================
# application name               : Compare data to send to TTECLECDA
# source name                    : ESDC0012.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 05/07/2021
# author                         : S.Behague
# specifications reference       :
#                                :
#-------------------------------------------------------------------------------
# description                    : 
#
# parameters                     :
#
#
#-------------------------------------------------------------------------------
# modifications chronology       :
# [001] - 05/07/2021 S.Behague :spira:96760 - RA and SAP interface data checks
# [002] - 16/03/2023 JYP:spira:104893 - rework all checks
# [003] - 20/03/2023 JYP:spira:104893 - new field for default products
# [004] - 22/03/2023 JYP:spira:104893 - remove field partial defaulting 
# [005] - 24/03/2023 JYP:spira:104893 - rework some checks, add lob checks, add attributes checks 
# [006] - 28/03/2023 JYP:spira:109361 - more checks on product attributes  
#===============================================================================

# call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd


# Job Initialization variables
#----------------------------------------------------------------------------

# Job Initialisation
#-------------------
JOBINIT

FileName=$1
ShortFileName=$2
AcceptRetro=$3
Norme=$4

#============================================================================================================
#==== Fonction CHECK_FILE_data ( ) ==========================================================================
#============================================================================================================
CHECK_FILE_data ( )
{
##########################################################################################################################
# $1 - Fichier à comparer
# $2 - Nom court fichier à comparer

File_To_Check=$1
File_Short_Name=$2
AcceptRetro=$3

if [ "$AcceptRetro" == "A" ]
then
    nbfields=118
	PRDCOD_field=112
	Keys="SSD_CF	1:1 - 1:,ESB_CF 2:1 - 2:,TRNCOD_CF1 6:1 - 6:1 , TRNCOD_CF 6:1 - 6:,DBLTRNCOD_CF 7:1 - 7:,CTR_NF 8:1 - 8:,END_NT 9:1 - 9:,SEC_NF 10:1 - 10:,UWY_NF 11:1 - 11:,UW_NT 12:1 - 12:,GAAPCOD_NT 111:1 - 111:,I17PRDCOD_NT 112:1 - 112:,I17PRDCOD_12 112:1 - 112:2,RETCTR 24:1 - 24:,RETEND 25:1 - 25:, RETSEC 26:1 - 26:,RETRTY 27:1 - 27:,RETUW 28:1 - 28:,GRPSEG 119:1 - 119:,LOBACC_CF 45:1 - 45:,LOBRET_CF 46:1 - 46: "
else
    nbfields=71
	PRDCOD_field=51
  Keys="SSD_CF	1:1 - 1:,ESB_CF 2:1 - 2:,TRNCOD_CF1 6:1 - 6:1,TRNCOD_CF 6:1 - 6:,DBLTRNCOD_CF 7:1 - 7:,CTR_NF 24:1 - 24:,END_NT 25:1 - 25:,SEC_NF 26:1 - 26:,UWY_NF 27:1 - 27:,UW_NT 12:1 - 12:,GAAPCOD_NT 64:1 - 64:,I17PRDCOD_NT 65:1 - 65:,I17PRDCOD_12 65:1 - 65:2,RETCTR 24:1 - 24:,RETEND 25:1 - 25:, RETSEC 26:1 - 26:,RETRTY 27:1 - 27:,RETUW 28:1 - 28:,LOBACC_CF 45:1 - 45:, LOBRET_CF 45:1 - 45:"
fi


		
		
# Verification si fichier vide
if [ ! -s ${File_To_Check} ]
then
	echo -e "\n\nThe input file <<${File_To_Check}>> is empty !!!! \n\n "
else

    LIBEL="detect wrong data for file $File_To_Check  "
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${File_To_Check} 2000 1"
	SORT_O="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_SSD.dat "
	SORT_O2="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_ESB.dat "
	SORT_O3="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_TRNCOD.dat "
	SORT_O4="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_DBLTRNCOD.dat "
	SORT_O5="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_GAAPCOD.dat "
	SORT_O6="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_I17PRDCOD.dat "
	SORT_O7="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_DEFAULTING.dat "
	SORT_O8="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_CSUOE_ASSUMED.dat "
	SORT_O9="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_CSUOE_AR.dat "
	SORT_10="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_CSUOE_RETRO.dat "
	SORT_11="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_LOBACC.dat "
	SORT_12="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_LOBRET.dat "
	INPUT_TEXT $SORT_CMD <<EOF
	/FIELDS 
				$Keys

	/KEYS CTR_NF
	/CONDITION SSD_ERROR SSD_CF = ""
	/CONDITION ESB_ERROR ESB_CF = ""
	/CONDITION TRNCOD_ERROR TRNCOD_CF = ""
	/CONDITION DBLTRNCOD_ERROR DBLTRNCOD_CF = ""
	/CONDITION GAAPCOD_ERROR GAAPCOD_NT = ""
	/CONDITION I17PRDCOD_ERROR I17PRDCOD_NT = ""
	/CONDITION FULL_DEFAULTING (I17PRDCOD_12 = "PC" OR I17PRDCOD_12 = "SG" )
	/CONDITION ALL_CSUOE_A  ((TRNCOD_CF1 = "1" OR TRNCOD_CF1 = "3" ) AND "$AcceptRetro" = "A" )
	/CONDITION ALL_CSUOE_AR ((TRNCOD_CF1 = "2" OR TRNCOD_CF1 = "4" ) AND "$AcceptRetro" = "A" )
	/CONDITION ALL_CSUOE_R  ((TRNCOD_CF1 = "2" OR TRNCOD_CF1 = "4" ) AND "$AcceptRetro" = "R" )
	/CONDITION LOBACC_COND  ((TRNCOD_CF1 = "1" OR TRNCOD_CF1 = "3" ) AND LOBACC_CF = "" AND "$AcceptRetro" = "A" )
	/CONDITION LOBRET_COND  ((TRNCOD_CF1 = "2" OR TRNCOD_CF1 = "4" ) AND LOBRET_CF = "" )
	/DERIVEDFIELD SSD_ERROR "${SSD_ERR}"
	/DERIVEDFIELD ESB_ERROR "${ESB_ERR}"
	/DERIVEDFIELD TRNCOD_ERROR "${TRNCOD_ERR}"
	/DERIVEDFIELD DBLTRNCOD_ERROR "${DBLTRNCOD_ERR}"
	/DERIVEDFIELD GAAPCOD_ERROR "${GAAPCOD_ERR}"
	/DERIVEDFIELD I17PRDCOD_ERROR "${I17PRDCOD_ERR}"
	/DERIVEDFIELD FULL_DEFAULTING_ERROR "${FULL_DEFAULTING_ERROR}"
	/DERIVEDFIELD LOBACC_ERROR "${LOBACC_ERROR}"
	/DERIVEDFIELD LOBRET_ERROR "${LOBRET_ERROR}"
	/DERIVEDFIELD TYPE_A "A~"
	/DERIVEDFIELD TYPE_R "R~"
	/OUTFILE ${SORT_O}
	/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,RETCTR , RETSEC ,RETRTY ,TRNCOD_CF,I17PRDCOD_NT,SSD_ERROR
	/INCLUDE SSD_ERROR

	/OUTFILE ${SORT_O2}
	/INCLUDE ESB_ERROR
	/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,RETCTR , RETSEC ,RETRTY , TRNCOD_CF,I17PRDCOD_NT,ESB_ERROR

	/OUTFILE ${SORT_O3}
	/INCLUDE TRNCOD_ERROR
	/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,RETCTR , RETSEC ,RETRTY,TRNCOD_CF,I17PRDCOD_NT,TRNCOD_ERROR

	/OUTFILE ${SORT_O4}
	/INCLUDE DBLTRNCOD_ERROR
	/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,RETCTR , RETSEC ,RETRTY , TRNCOD_CF,I17PRDCOD_NT,DBLTRNCOD_ERROR

	/OUTFILE ${SORT_O5}
	/INCLUDE GAAPCOD_ERROR
	/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,RETCTR ,RETSEC ,RETRTY,TRNCOD_CF,I17PRDCOD_NT,GAAPCOD_ERROR

	/OUTFILE ${SORT_O6}
	/INCLUDE I17PRDCOD_ERROR
	/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,RETCTR , RETSEC ,RETRTY ,TRNCOD_CF,I17PRDCOD_NT,I17PRDCOD_ERROR
	
	/OUTFILE ${SORT_O7}
	/INCLUDE FULL_DEFAULTING
	/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,RETCTR , RETSEC ,RETRTY ,TRNCOD_CF,I17PRDCOD_NT,FULL_DEFAULTING_ERROR	

	/OUTFILE ${SORT_O8}
	/INCLUDE ALL_CSUOE_A
	/REFORMAT SSD_CF,ESB_CF,CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,TYPE_A,I17PRDCOD_NT

	/OUTFILE ${SORT_O9}
	/INCLUDE ALL_CSUOE_AR
	/REFORMAT SSD_CF,ESB_CF,RETCTR ,RETSEC, RETEND ,RETRTY ,RETUW ,TYPE_R, I17PRDCOD_NT	

	/OUTFILE ${SORT_10}
	/INCLUDE ALL_CSUOE_R
	/REFORMAT SSD_CF,ESB_CF,RETCTR ,RETSEC, RETEND ,RETRTY ,RETUW ,TYPE_R , I17PRDCOD_NT	

	/OUTFILE ${SORT_11}
	/INCLUDE LOBACC_COND
	/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,RETCTR , RETSEC ,RETRTY ,TRNCOD_CF,I17PRDCOD_NT,LOBACC_ERROR	

	/OUTFILE ${SORT_12}
	/INCLUDE LOBRET_COND
	/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT,RETCTR , RETSEC ,RETRTY ,TRNCOD_CF,I17PRDCOD_NT,LOBRET_ERROR	

	
	exit
EOF
	SORT
fi


}


#============================================================================================================
#==== Fin Fonction CHECK_FILE_data ( ) ======================================================================
#============================================================================================================




NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
# DATA Check file
#------------------------------------------------------------------------------
LIBEL="DATA Check file : $FileName $ShortFileName $AcceptRetro $Norme "
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "# Begin of step:  $NSTEP "
ECHO_LOG "# Subject: $LIBEL "

CHECK_FILE_data $FileName $ShortFileName $AcceptRetro

permfile=`basename $File_To_Check `
filetyp1=`echo $permfile | cut -d"_" -f2 `
filetyp2=`echo $permfile | cut -d"_" -f3 `
norme13=`echo $Norme | cut -c1-3 `

if [ "$norme13" = "I17" ]
then 
  normedesc="I17X"
else
  normedesc=$Norme
fi  
  
  

case "${filetyp1}" in
        "ESFD3930") 
		        if [ "$filetyp2" = "FTECLEDA" ] 
                then 
                    filedesc="I4I DELTA"
                else					
				    filedesc="$filetyp2 DELTA"
                fi	;;	
        "ESFD8100"|"ESPD8200"|"ESID8100") filedesc="$filetyp1 RA" ;;	
        "ESLD3800") filedesc="$filetyp1 LOCAL" ;;			
        *) filedesc="$filetyp1 $Norme" ;;  
esac



if [ -s ${File_To_Check} ]
then
	NSTEP=${NJOB}_20
    LIBEL="count stats by file : $permfile  "

	#------------------------------------------------------------------------------
	# Concatenate Error files
	#------------------------------------------------------------------------------
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_SSD.dat 2000 1"
	SORT_I2="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_ESB.dat 2000 1"
	SORT_I3="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_TRNCOD.dat 2000 1"
	SORT_I4="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_DBLTRNCOD.dat 2000 1"
	SORT_I5="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_GAAPCOD.dat 2000 1"
	SORT_I6="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_I17PRDCOD.dat 2000 1"
	SORT_I7="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_DEFAULTING.dat 2000 1"
	SORT_I8="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_LOBACC.dat 2000 1"
	SORT_I9="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_LOBRET.dat 2000 1"
	SORT_O="${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ALL_EMPTY.dat"
	SORT

	NSTEP=${NJOB}_30
    LIBEL="count stats by file : $permfile  "
    ECHO_LOG ""
    ECHO_LOG "#========================================================================="
    ECHO_LOG "# Begin of step:  $NSTEP "
    ECHO_LOG "# Subject: $LIBEL "

	nbssd=`wc -l      ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_SSD.dat      | cut -d" " -f1 `
	nbesb=`wc -l      ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_ESB.dat      | cut -d" " -f1 `
	nbtrncd=`wc -l    ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_TRNCOD.dat   | cut -d" " -f1 `
	nbdbltrncd=`wc -l ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_DBLTRNCOD.dat | cut -d" " -f1 `
	nbgaapcd=`wc -l   ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_GAAPCOD.dat  | cut -d" " -f1 `
	nbprdcd=`wc -l    ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_I17PRDCOD.dat | cut -d" " -f1 `	
	nbdefault=`wc -l   ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_DEFAULTING.dat | cut -d" " -f1 `	
	nblobacc=`wc -l   ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_LOBACC.dat | cut -d" " -f1 `	
	nblobret=`wc -l   ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ERROR_LOBRET.dat | cut -d" " -f1 `	
	nbtotal=`wc -l $File_To_Check | cut -d" " -f1 `	

	echo "$normedesc:${Norme}:$filedesc:$File_Short_Name:$nbssd:$nbesb:$nbtrncd:$nbdbltrncd:$nbgaapcd:$nbprdcd:${nbdefault}:$nbtotal:$permfile:$nblobacc:$nblobret" > ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_STATS.dat

else 


	NSTEP=${NJOB}_35
    LIBEL="init empty stats for : $permfile  "
    ECHO_LOG ""
    ECHO_LOG "#========================================================================="
    ECHO_LOG "# Begin of step:  $NSTEP "
    ECHO_LOG "# Subject: $LIBEL "
	
	nbssd=0
	nbesb=0
	nbtrncd=0
	nbdbltrncd=0
	nbgaapcd=0
	nbprdcd=0	
	nbdefault=0
    nblobacc=0
	nblobret=0
	nbtotal=0	

	echo "$normedesc:${Norme}:$filedesc:$File_Short_Name:$nbssd:$nbesb:$nbtrncd:$nbdbltrncd:$nbgaapcd:$nbprdcd:${nbdefault}:$nbtotal:$permfile:$nblobacc:$nblobret" > ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_STATS.dat
    > ${DFILT}/${ENV_PREFIX}_ESDC0010_${Norme}_${File_Short_Name}_${IB}_ALL_EMPTY.dat
fi


# END Of Job
#------------------------------------------------------------------------------
JOBEND

