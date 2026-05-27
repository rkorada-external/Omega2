#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                             Mise € jour des estimations apres prise en compte
#                             des AS
# nom du script SHELL		: ESID8031.cmd
# revision			: $Revision: 1.5 $
# date de creation		: 10/07/97
# auteur			: C.G.I. (C.Chavatte)
# references des specifications	: ESIIV01F.doc
#-----------------------------------------------------------------------------
# description
#   Inserts data (contained in the bcp files) in the temporary tables then
#   updates the ESTIMATES tables from these.
#
# Input files
#       EST_CPLIFDRI      DFILI
#       EST_CPLIFEST      DFILI
#       EST_FRATTACHEVOL  DFILI
#
#       EST_FLIFMOD       DFILI
#       EST_FLIFMOD2      DFILI
#       EST_FLIFPEN       DFILI
#
# Launch C program ESTC203B
#
# job launched by ESID8030.cmd
#
#-----------------------------------------------------------------------------
# historique des modifications
#    G. BUISSON     08/09/2003     Ajout du parametre BALSHTMTH_NF dans la suppression des
#                                  lignes de TLIFEST et TLIFDRI pour eviter de supprimer les
#                                  lignes posterieures au mois bilan traite suite au deblocage
#                                  des periodes exceptionnelles
#----------------------------------------------------------------------------------------------------------------
#    J RIBOT        24/08/2004     ajout insertion ligne dans TREQJOB pour date dernier traitement S/R
#----------------------------------------------------------------------------------------------------------------
#    J RIBOT        31/08/2004     ajout BCP in BTRAV..EST_ESID8030_PEN_1 TLIFMOD TLIFMOD2 TLIFPEN (SPOT 10260)
#----------------------------------------------------------------------------------------------------------------
#	 J. Ribot       09/11/05	   ajout test sur filiale 20
#----------------------------------------------------------------------------------------------------------------
#    J. Ribot       27/12/07       ajout test sur filiale 18 et 19
#----------------------------------------------------------------------------------------------------------------
#    G. BUISSON     30/10/2008     Spot 16286 : Ajout de la filiale 23 au step 35
#----------------------------------------------------------------------------------------------------------------
#    JF VDV         24/09/2010     [20198] - Sauvegarde des elements supprimes de la tabe best..TLIFEST
#                   04/10/2010     [20198] - ajout Sauvegarde dans fichier plat sur ${DFILI}
#                   13/10/2010     [20198] - normalisation du nom de fichier sauvegarde sur ${DFILI}
#
#----------------------------------------------------------------------------------------------------------------
#    T. RIPERT      11/02/2011     [21422] - Poste 1063 = 1503 + 1523 + 1533
#[008] 07/06/2012 Roger Cassis     :spot:23802 - Filtre TLIFDRI sur année bilan exclusivement
#[009] 13/11/2012 Roger Cassis     :spot:24469 - Distinct dans le tri de la Tlifdri pour éviter les doublons
#[010] 06/01/2014 R. BEN EZZINE    :spot:25427 - Extraction des derniers mouvements uniquement pour insertion en incremental dans la Tlifest
#[011] 24/06/2014 JBG              :spot:25773 - Query modified for CTR_NF selection
#[012] 22/07/2014 ABJ              :spot:25773 - suppression de la condition life=1 pour les filliales a metre a jour
#[013] 03/10/2014 Cyrille DESPRET  :spot:25773 - Supprimer les filiales du fichier FRATTACHEVOL de la table TRATTACHEVOL avant import du fichier, 
#                                                et non plus celles qui sont traitees par l'inventaire
#[014] 09/06/2016 S.Behague        :spot:30583 - EST39 
#[015] 16/04/2019 R.Vieville       :spot:70045 - Modification quarterly
#[016] 16/05/2019 S.Behague        :spira:78159: APOLO Closing Compte Complet quarterly incomplete
#================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT


# Parameters
BALSHTYEA_NF=$1
CRE_D=$2
BALSHTMTH_NF=$3

               
ECHO_LOG ""                                                                          
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> BALSHTYEA_NF..........: ${BALSHTYEA_NF}"                             
ECHO_LOG "#===> CRE_D.................: ${CRE_D}"                                    
ECHO_LOG "#===> BALSHTMTH_NF..........: ${BALSHTMTH_NF}"                             
ECHO_LOG "#....................INPUT.................."                              
ECHO_LOG "#===> EST_CPLIFEST_MVT......: ${EST_CPLIFEST_MVT}"                          
ECHO_LOG "#===> EST_CPLIFDRI..........: ${EST_CPLIFDRI}"                             
ECHO_LOG "#===> EST_FLIFMOD...........: ${EST_FLIFMOD}"                              
ECHO_LOG "#===> EST_FLIFMOD2..........: ${EST_FLIFMOD2}"                             
ECHO_LOG "#===> EST_FLIFPEN...........: ${EST_FLIFPEN}"                              
ECHO_LOG "#===> EST_FRATTACHEVOL......: ${EST_FRATTACHEVOL}"                         
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_01
# [015]
# split mvt yearly / quarterly
#-----------------------------------------------------------------------------
LIBEL="SORT CPLIFEST_MVT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CPLIFEST_MVTQ} 1000 1"
SORT_I2="${EST_CPLIFEST_MVT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CPLIFEST_MVTQ.dat 1000 1"
SORT_O1="${DFILT}/${NSTEP}_${IB}_CPLIFEST_MVTY.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	ACM_NF			12:1 - 12:EN

/CONDITION YEAR (ACM_NF = 13)

/OUTFILE ${SORT_O}
/OMIT YEAR

/OUTFILE ${SORT_O1}
/INCLUDE YEAR
exit
EOF
SORT              

###############################################################################
# [015] start
###############################################################################

NSTEP=${NJOB}_26
# Tri du fichier VLIFEST 
# Création du CPLIFEST_MVT pour recharger dans TLIFEST
#------------------------------------------------------------------------------
LIBEL="Tri du fichier VLIFEST Création du CPLIFEST_MVT pour recharger dans TLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_CPLIFEST_MVTQ} 1000 1"
SORT_I="${DFILT}/${NJOB}_01_${IB}_CPLIFEST_MVTQ.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CPLIFESTQ_MVT_O1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        1:1 - 1:,
        END_NT        2:1 - 2:,
        SEC_NF        3:1 - 3:,
        UWY_NF        4:1 - 4:,
        UW_NT         5:1 - 5:,
        CRE_D         6:1 - 6:,
        BALSHEY_NF    7:1 - 7:,
        BALSHTMTH_NF  8:1 - 8:,
        ACY_NF        9:1 - 9:,
        GAAP_NF      10:1 - 10:,
        DETTRNCOD_CF 11:1 - 11:,
        ESTMTH_NF    12:1 - 12:,
        PRS_CF       13:1 - 13:,
        ACMTRS_NT    14:1 - 14:,
        SSD_CF       15:1 - 15:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      GAAP_NF,
      ESTMTH_NF,
      DETTRNCOD_CF,
      PRS_CF,
      ACMTRS_NT,
      SSD_CF
/SUM
/STABLE
/OUTFILE   ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_28
# Begin C Program
# if QUARTER = 0 then yearly if QUARTER = 1 then quarterly
#------------------------------------------------------------------------------
LIBEL="Puts driving file into bcp format"
PRG=ESTC203B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
QUARTER  1
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_CPLIFDRIQ}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRIQ_O.dat
EXECPRG

NSTEP=${NJOB}_29
# Sort Last CPLIFDRI file
#------------------------------------------------------------------------------
LIBEL="Sort of CPLIFDRI binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_28_${IB}_ESTC203B_LIFDRIQ_O.dat"
SORT_O=${DFILT}/${NSTEP}_${IB}_LIFDRIQ_MVT_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF            1:1 - 1:,
        END_NT            2:1 - 2:,
        SEC_NF            3:1 -  3:,
        UWY_NF            4:1 -  4:,
        UW_NT             5:1 -  5:,
        CRE_D             6:1 -  6:,
        BALSHEY_NF        7:1 -  7:,
        BALSHTMTH_NF      8:1 -  8:,
        ACY_NF            9:1 -  9:,
        SSD_CF            10:1 - 10:,
        AUTUPD_B          11:1 - 11:,
        COMACC_B          12:1 - 12:,
        CMT_NT            13:1 - 13:,
        CREUSR_CF         14:1 - 14:,
        LSTUPD_D          15:1 - 15:,
        LSTUPDUSR_CF      16:1 - 16:,
        CRE_D2	          6:1 - 6:14
/KEYS CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF
/CONDITION NEWMVT ( CRE_D2 = "${CRE_D} 23:59" ) 
/OUTFILE   ${SORT_O}
/INCLUDE   NEWMVT
exit
EOF
SORT

#[008] [009]
NSTEP=${NJOB}_30
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Get actual BALSHEY_NF only on TLIFDRI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_29_${IB}_LIFDRIQ_MVT_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFDRIQ_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 -  1:
       ,END_NT       2:1 -  2:
       ,SEC_NF       3:1 -  3:
       ,UWY_NF       4:1 -  4:
       ,UW_NT        5:1 -  5:
       ,CRE_D        6:1 -  6:
       ,BALSHEY_NF   7:1 -  7:EN
       ,BALSHTMTH_NF 8:1 -  8:
       ,ACY_NF       9:1 -  9:
       ,ACM_NF      10:1 - 10:
/KEYS   CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF, ACM_NF
/SUM
/CONDITION BILAN BALSHEY_NF = ${BALSHTYEA_NF}
/INCLUDE BILAN
exit
EOF
SORT

NSTEP=${NJOB}_31
# Sort LIFDRI for PRG ESTC2168
#------------------------------------------------------------------------------
LIBEL="Sort LIFDRI for PRG ESTC2168"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_LIFDRIQ_O.dat 1000"
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFDRID_SORT.dat 1000"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	CTR_NF			1:1 - 1:,
	SEC_NF			3:1 - 3:,
	UWY_NF			4:1 - 4:EN,
	BALSHMTH_NF		10:1 - 10:EN

/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	BALSHMTH_NF

/OUTFILE ${SORT_O}

exit
EOF
SORT

NSTEP=${NJOB}_32
# Aggregate LIFDRID
#------------------------------------------------------------------------------
LIBEL="Aggregate LIFDRID"
PRG=ESTC2168
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_31_${IB}_LIFDRID_SORT.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_LIFDRID_AGRE.dat
EXECPRG

NSTEP=${NJOB}_32b
# Reformat file LIFDRID to LIFDRI (delete fields ACM_NF)
#------------------------------------------------------------------------------
LIBEL="Reformat file LIFDRID to LIFDRI (delete fields ACM_NF)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_32_${IB}_LIFDRID_AGRE.dat 1000"
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFDRID_AGRE_REFORMAT.dat 1000"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	PART1		1:1 - 9:,
	PART2		11:1 - 19:

/OUTFILE ${SORT_O}
/REFORMAT
	PART1,
	PART2

exit
EOF
SORT


#################################################################################
# [015] end
#################################################################################


#[010]
NSTEP=${NJOB}_05
# Deletion of Table best..LIFEST, best..TLIFDRI
#-----------------------------------------------------------------------------
LIBEL="Loading Last previsions in BEST..LIFEST, Delete and Load BEST..TLIFDRI"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PtLIFEST_02 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

NSTEP=${NJOB}_27
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading predictions file into TLIFEST table"
BCP_WAY="IN"
BCP_VER=""
#BCP_I=${EST_CPLIFEST_MVTQ}
BCP_I=${DFILT}/${NJOB}_26_${IB}_SORT_CPLIFESTQ_MVT_O1.dat
BCP_TABLE="BEST..TLIFESTD"
BCP

NSTEP=${NJOB}_33
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading driving file into TLIFDRI table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_30_${IB}_SORT_LIFDRIQ_O.dat
BCP_TABLE="BEST..TLIFDRID"
BCP

NSTEP=${NJOB}_05b
# Tri du fichier VLIFEST 
# Création du CPLIFEST_MVT pour recharger dans TLIFEST
#------------------------------------------------------------------------------
LIBEL="Tri du fichier VLIFEST Création du CPLIFEST_MVT pour recharger dans TLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_CPLIFEST_MVT} 1000 1"
SORT_I="${DFILT}/${NJOB}_01_${IB}_CPLIFEST_MVTY.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CPLIFEST_MVT_O1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        1:1 - 1:,
        END_NT        2:1 - 2:,
        SEC_NF        3:1 - 3:,
        UWY_NF        4:1 - 4:,
        UW_NT         5:1 - 5:,
        CRE_D         6:1 - 6:,
        BALSHEY_NF    7:1 - 7:,
        BALSHTMTH_NF  8:1 - 8:,
        ACY_NF        9:1 - 9:,
        GAAP_NF      10:1 - 10:,
        DETTRNCOD_CF 11:1 - 11:,
        ESTMTH_NF    12:1 - 12:,
        PRS_CF       13:1 - 13:,
        ACMTRS_NT    14:1 - 14:,
        SSD_CF       15:1 - 15:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      GAAP_NF,
      ESTMTH_NF,
      DETTRNCOD_CF,
      PRS_CF,
      ACMTRS_NT,
      SSD_CF
/SUM
/STABLE
/OUTFILE   ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading predictions file into TLIFEST table"
BCP_WAY="IN"
BCP_VER=""
#BCP_I=${EST_CPLIFEST_MVT}
BCP_I=${DFILT}/${NJOB}_05b_${IB}_SORT_CPLIFEST_MVT_O1.dat
BCP_TABLE="BEST..TLIFEST"
BCP

NSTEP=${NJOB}_20
# Begin C Program
# if QUARTER = 0 then yearly if QUARTER = 1 then quarterly
#------------------------------------------------------------------------------
LIBEL="Puts driving file into bcp format"
PRG=ESTC203B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
QUARTER  0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_CPLIFDRI}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRI_O.dat
EXECPRG

NSTEP=${NJOB}_201
# merge file LIFDRI and LIFDRID
#------------------------------------------------------------------------------
LIBEL="Merge file LIFDRI and LIFDRID"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTC203B_LIFDRI_O.dat 1000"
SORT_I2="${DFILT}/${NJOB}_32b_${IB}_LIFDRID_AGRE_REFORMAT.dat 1000"
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFDRI_MERGE.dat 1000"
INPUT_TEXT ${SORT_CMD} << EOF

/OUTFILE ${SORT_O}

exit
EOF
SORT

NSTEP=${NJOB}_202
# Sort Last CPLIFDRI file
#------------------------------------------------------------------------------
LIBEL="Sort of CPLIFDRI binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_201_${IB}_LIFDRI_MERGE.dat"
SORT_O=${DFILT}/${NSTEP}_${IB}_LIFDRI_MVT_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF            1:1 - 1:,
        END_NT            2:1 - 2:,
        SEC_NF            3:1 -  3:,
        UWY_NF            4:1 -  4:,
        UW_NT             5:1 -  5:,
        CRE_D             6:1 -  6:,
        BALSHEY_NF        7:1 -  7:,
        BALSHTMTH_NF      8:1 -  8:,
        ACY_NF            9:1 -  9:,
        SSD_CF            10:1 - 10:,
        AUTUPD_B          11:1 - 11:,
        COMACC_B          12:1 - 12:,
        CMT_NT            13:1 - 13:,
        CREUSR_CF         14:1 - 14:,
        LSTUPD_D          15:1 - 15:,
        LSTUPDUSR_CF      16:1 - 16:,
        CRE_D2	          6:1 - 6:14
/KEYS CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF
/CONDITION NEWMVT ( CRE_D2 = "${CRE_D} 23:59" ) 
/OUTFILE   ${SORT_O}
/INCLUDE   NEWMVT
exit
EOF
SORT


#[008] [009]
NSTEP=${NJOB}_21
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Get actual BALSHEY_NF only on TLIFDRI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_202_${IB}_LIFDRI_MVT_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFDRI_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 -  1:
       ,END_NT       2:1 -  2:
       ,SEC_NF       3:1 -  3:
       ,UWY_NF       4:1 -  4:
       ,UW_NT        5:1 -  5:
       ,CRE_D        6:1 -  6:
       ,BALSHEY_NF   7:1 -  7:EN
       ,BALSHTMTH_NF 8:1 -  8:
       ,ACY_NF       9:1 -  9:      
/KEYS   CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF
/SUM
/CONDITION BILAN BALSHEY_NF = ${BALSHTYEA_NF}
/INCLUDE BILAN
exit
EOF
SORT


NSTEP=${NJOB}_25
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading driving file into TLIFDRI table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_21_${IB}_SORT_LIFDRI_O.dat
BCP_TABLE="BEST..TLIFDRI"
BCP



# ajout JR 24/08/2004

NSTEP=${NJOB}_35
# Begin  isql
#[011]
#[012]
#--------------------------------------------------------------------------
LIBEL="SSD_CF not in BTRAV..TSSD determination"
BCP_WAY="OUT";
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1.dat
BCP_QRY="select distinct a.ssd_cf from bref..tesb a, btrav..testssd b where a.ssd_cf=b.ssd_cf and a.ssd_cf<>7"
BCP

LIST_SSD_CF=`cat ${DFILT}/${NJOB}_35_${IB}_BCP_O1.dat 2>/dev/null`

ECHO_LOG "#------------------------------------------"
ECHO_LOG "#===> LIST_SSD_CF..........: ${LIST_SSD_CF}"
ECHO_LOG "#------------------------------------------"

for SSD_CF in `echo $LIST_SSD_CF`
do

NSTEP=${NJOB}_40_${SSD_CF}
# Begin  isql
#--------------------------------------------------------------------------
LIBEL="Insert date of the last S/R in the BEST..TREQJOB table"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PiREQJOB_03 ${SSD_CF}, '${CRE_D}' "
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL

done

NSTEP=${NJOB}_45
#Deletion of Table BTRAV..TESTSECTION
#-----------------------------------------------------------------------------
LIBEL="Deletion of Table..."
ISQL_QRY="TRUNCATE TABLE BTRAV..TESTSECTION"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_50
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading driving file into FLIFMOD table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FLIFMOD}
BCP_TABLE="BEST..TLIFMOD"
BCP

NSTEP=${NJOB}_55
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading driving file into FLIFMOD2 table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FLIFMOD2}
BCP_TABLE="BEST..TLIFMOD2"
BCP

NSTEP=${NJOB}_60
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading driving file into BTRAV..EST_ESID8030_PEN_1 table"
BCP_WAY="IN"
BCP_VER=""
BCP_TRUNCATE=YES
BCP_I=${EST_FLIFPEN}
BCP_TABLE="BTRAV..EST_ESID8030_PEN_1"
BCP


NSTEP=${NJOB}_65
# This step is launched only outside service period
#------------------------------------------------------------------------------
LIBEL="Update UWGRP_CF in the BTRAV..EST_ESID8030_PEN_1 table AND BCP_OUT"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_LIFPEN_O1.dat
BCP_QRY="exec BEST..PuLIFPEN_02"
BCP


NSTEP=${NJOB}_70
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading driving file into TLIFPEN table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_65_${IB}_BCP_LIFPEN_O1.dat
BCP_TABLE="BEST..TLIFPEN"
BCP

# [013] Suppression des filiales du fichier a importer
NSTEP=${NJOB}_75
#---------------------------------------------------------------------------
# Get the SubSiDiaries list that are going to be treated from internal exchanges
# SSD is the first column of the file
# Extract first column from file and get unique values
#---------------------------------------------------------------------------
LIBEL="Get subsidiaries to be treated"
SORT_I=${EST_FRATTACHEVOL}
SORT_O=${DFILT}/${NSTEP}_${IB}_SSDLST_O.dat

ECHO_LOG ""                                                                          
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> STEP..................: ${NSTEP}"                             
ECHO_LOG "#===> SORT_I SSD COND.......: ${SORT_I}"                             
ECHO_LOG "#===> SORT_O SSD COND.......: ${SORT_O}"                             

cut -d~ -f1 ${SORT_I} | sort | uniq > $SORT_O

#---------------------------------------------------------------------------
# Set subsidiaries that are going to be treated on 1 line 
# and create a condition statement to be used in a SORT command
#---------------------------------------------------------------------------
LIBEL="SSD Condition creation"
COND_SSD=`cat "${DFILT}/${NJOB}_75_${IB}_SSDLST_O.dat" | awk 'BEGIN {FS="~"; l=0}\
      { 
      	 T[l] = $0; 
      	 l++; 
      }
      END {
      			for(i=0;;)
      			{
      				if(i >= l-1)
      				{
      					printf("SSD_CF=%d\n", T[i]);
      					break;
      				}
      				else
      				{
      					printf("SSD_CF=%d OR ", T[i]);
      				}
      				i++; 
      			}
      		}'`

ECHO_LOG "#===> COND_SSD..............: ${COND_SSD}"                                    
ECHO_LOG "#========================================================================="

RMFIL "${DFILT}/${NJOB}_75_${IB}_SSDLST_O.dat"

#[013] Delete SSD from file
#for SSD_CF in `echo $LIST_SSD_CF`
#do

#NSTEP=${NJOB}_80
# Begin  isql
#--------------------------------------------------------------------------
#LIBEL="DELETE BEST..TRATTACHEVOL"
#ISQL_BASE="BEST"
#ISQL_QRY="DELETE from BEST..TRATTACHEVOL where ssd_cf =$SSD_CF"
#ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1_${SSD_CF}.log
# ISQL
#
#done

NSTEP=${NJOB}_80
# Begin  isql
#--------------------------------------------------------------------------
LIBEL="DELETE BEST..TRATTACHEVOL FOR ${COND_SSD}"
ISQL_BASE="BEST"
ISQL_QRY="DELETE from BEST..TRATTACHEVOL where ${COND_SSD}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1_${SSD_CF}.log
ISQL



NSTEP=${NJOB}_85
# Begin bcp
#-------------------------------------------------------------------------------
LIBEL="Loading evolutions files into temporary table"
BCP_VER=""
BCP_WAY="IN"
BCP_I=${EST_FRATTACHEVOL}
BCP_TABLE="BEST..TRATTACHEVOL"                                           
BCP

NSTEP=${NJOB}_90
#-------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*${IB}_*.dat"

JOBEND
