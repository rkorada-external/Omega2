#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID2031.cmd
# revision                      : $Revision: 1.10 $
# date de creation              : 26/05/97
# auteur                        : C.G.I. (C.Chavatte)
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#   Predictions Update
#   Launch C programs ESTC2031,2032,2033,2034,2035,2036,2037,2037b,2038,2040,
#                              2147,2132,2133,2134,2135
#
#   Output file sort 	 ${DFILT}/${NSTEP}_${IB}_SORT_IRV_PERICASE_O.dat
#       	         ${DFILT}/${NSTEP}_${IB}_SORT_IAV_PERICASE_O.dat
#                	 ${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTR_O.dat
#		         ${DFILT}/${NSTEP}_${IB}_SORT_FLIFEST_O.dat
#		 	 ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat
#	                 ${DFILT}/${NSTEP}_${IB}_SORT_CPLACC_O.dat
#		         ${DFILT}/${NSTEP}_${IB}_SORT_LSTMTH_O.dat
#		         ${DFILT}/${NSTEP}_${IB}_SORT_GT_O1.dat
#		         ${DFILT}/${NSTEP}_${IB}_SORT_VVERS_O.dat
#		         ${DFILT}/${NSTEP}_${IB}_SORT_VPLACEMT_O.dat
#		         ${DFILT}/${NSTEP}_${IB}_SORT_FLIFEST_O.dat
#		         ${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
#  16/10/2008 JFVDV - ajout conditions supplementaires au tri step 38
#  20/10/2008 JFVDV - renommer le step 38 en 36
#                     ajout step 37  & 37A Extraction + inversion des montants pour cptes de Rejet
#                     changement du SORT par un MERGE au step 38 - ajout DELETE des nouveaux FIC au step 50
#  21/10/2008 JFVDV - mettre en commentaire le delete des fichiers ${NJOB}_36, ${NJOB}_37,${NJOB}_3A, ${NJOB}_38
#  22/10/2008 JFVDV - suppression des commentaires des delete et forcer le second prefixe TRNCOD_CF par 4 (Openning ES step 3A)
#  07/12/2009 JFVDV - [16260] - Modification de la condition des postes retrocesions step 35
#---------------
#MODIFICATION   : [006]
#Auteur         : T.RIPERT
#Date           : 21/05/2010
#Version        : 10.1
#Description    : ESTVIE19274 ( sauvegarde des fichiers pour TEST )
#---------------
#MODIFICATION   : [007]
#Auteur         : D.GATIBELZA
#Date           : 17/12/2010
#Version        : 10.1
#Description    : ESTVIE20627 estimation sur des traités de rattachement en 'terminé comptable'
#---------------
#MODIFICATION   : [008]
#Auteur         : D.GATIBELZA
#Date           : 07/02/2011
#Version        : 11.1
#Description    : 1GL
#[009]  14/03/2011  R. CASSIS     :spot:21408 - Reduction des fichiers au format GT 41 col.
#[010]  20/04/2011  Roger Cassis  :spot:21655 - tris pas en numerique sur la section.
#[011]  07/10/2011  JFVDV         :[22715]    - Ajout step 344 (copy file to save)
#[012]  21/12/2011  Roger Cassis  :spot:20257 - PLC_NT force a blanc dans tri - 05/01/2012 - On reprend les anciennes conditions de tri du STATGTR
#[013]  16/12/2012  Roger Cassis  :spot:23198 - Ajout fichier log en sortie pour mouvements sans sontrat renseigné prog ESTC2037.
#[014]  20/02/2012  Roger Cassis  :spot:23394 - Ajout traces de fichiers zippés pour controle
#[015]  09/03/2012  Roger Cassis  :spot:23541 - On prend maintenant le IGTR00 en entree
#[016]  29/06/2012  R. CASSIS     :spot:23802 - Gzip fichiers pour optimisation
#[017]  06/01/2014  R. BEN EZZINE :spot:25427 - Extraction des derniers mouvements uniquement pour insertion en incremental dans la Tlifest
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODAT_D=$3
CRE_D=$4

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_00
#Last version of ESID2030 files deletion
#-----------------------------------------------------------------
RMFIL " `dirname ${EST_CPLIFDRI}`/${PCH}ESID2030_CPLIFDRI*.dat
        `dirname ${EST_CPLIFEST}`/${PCH}ESID2030_CPLIFEST*.dat
        `dirname ${EST_CRIBLEANO}`/${PCH}ESID2030_CRIBLEANO*.dat
        `dirname ${EST_FRATTACHEVOL}`/${PCH}ESID2030_FRATTACHEVOL*.dat
        `dirname ${EST_FVPLACEMT}`/${PCH}ESID2030_FVPLACEMT*.dat
        `dirname ${EST_IARVPERICASE0}`/${PCH}ESID2030_IARVPERICASE0*.dat
        `dirname ${EST_SEGRATANO}`/${PCH}ESID2030_SEGRATANO*.dat
        `dirname ${EST_SRGTC}`/${PCH}ESID2030_SRGTC*.dat
        `dirname ${EST_SRGTCB1}`/${PCH}ESID2030_SRGTCB1*.dat
        `dirname ${EST_VACCPAR120}`/${PCH}ESID2030_VACCPAR120*.dat
        `dirname ${EST_LIFESTNOACC}`/${PCH}ESID2030_LIFESTNOACC*.dat
        `dirname ${EST_VLIFEST195}`/${PCH}ESID2030_VLIFEST195*.dat"

NSTEP=${NJOB}_05
# Merging of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IAVPERICASE0} 1000 1"
SORT_I2="${EST_IRVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARV_PERICASE_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF DESCENDING
/CONDITION NONVIE   ( SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_10
# Update underwriting data with the data of the last underwriting year
#[007] ajout log sur maj secaccsts des exercices précédents
#------------------------------------------------------------------------------
LIBEL="Update underwriting data"
PRG=ESTC2041
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_IARV_PERICASE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IARV_PERICASE_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_MAJ_SECACCSTS_UWY_PREC.log
EXECPRG

NSTEP=${NJOB}_15
# Merging and Filtering of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTC2041_IARV_PERICASE_O.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IAV_PERICASE_O.dat 1000 1 "
SORT_O1="${DFILT}/${NSTEP}_${IB}_SORT_IRV_PERICASE_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     3:1 -  3:,
        SEC_NF     5:1 -  5:,
        UWY_NF     6:1 -  6:,
        ESTCRB_CT 24:1 - 24:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
/CONDITION ACCEP ESTCRB_CT EQ "O"   OR
                 ESTCRB_CT EQ "R"   OR
                 ESTCRB_CT EQ "N"   OR
                 ESTCRB_CT EQ "S"
/OUTFILE ${SORT_O1}
/OMIT ACCEP
/OUTFILE ${SORT_O}
/INCLUDE ACCEP
exit
EOF
SORT


NSTEP=${NJOB}_20
# Refreshing Fictitious Treaties and Analysis segments
#------------------------------------------------------------------------------
LIBEL="Refreshing Fictitious Treaties and Analysis segments"
PRG=ESTC2032
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_SORT_IAV_PERICASE_O.dat
export ${PRG}_I2=${EST_FSEGPAR}
export ${PRG}_I3=${EST_FCTRFIC}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IAV_PERICASE_O1.dat
export ${PRG}_O2=${EST_FRATTACHEVOL}
export ${PRG}_O3=${EST_SEGRATANO}
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_RATTACHEMENT_O1.log
EXECPRG


# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_15_${IB}_SORT_IAV_PERICASE_O.dat        > ${DFILT}/SAUVEGARDE_ESID2030_I1_ESTC2032_IAV_PERICASE_O.zip
gzip -c ${EST_FSEGPAR}                                           > ${DFILT}/SAUVEGARDE_ESID2030_I2_ESTC2032_FSEGPAR.zip
gzip -c ${EST_FCTRFIC}                                           > ${DFILT}/SAUVEGARDE_ESID2030_I3_ESTC2032_FCTRFIC.zip
gzip -c ${DFILT}/${NJOB}_20_${IB}_${PRG}_IAV_PERICASE_O1.dat     > ${DFILT}/SAUVEGARDE_ESID2030_O1_ESTC2032_IAV_PERICASE_O1.zip
gzip -c ${EST_FRATTACHEVOL}                                      > ${DFILT}/SAUVEGARDE_ESID2030_O2_ESTC2032_FRATTACHEVOL.zip
gzip -c ${EST_SEGRATANO}                                         > ${DFILT}/SAUVEGARDE_ESID2030_O3_ESTC2032_SEGRATANO.zip
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------


NSTEP=${NJOB}_25
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_IARV_PERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_ESTC2041_IARV_PERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_IAV_PERICASE_O.dat


NSTEP=${NJOB}_30
#Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTC2032_IAV_PERICASE_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_15_${IB}_SORT_IRV_PERICASE_O.dat 1000 1"
SORT_O="${EST_IARVPERICASE0} OVERWRITE 1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
exit
EOF
SORT


#[007]
NSTEP=${NJOB}_31
# Merging and Filtering of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE0} 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_R_IAVPERICASE_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     3:1 -  3:,
        SEC_NF     5:1 -  5:,
        UWY_NF     6:1 -  6:,
        ESTCRB_CT 24:1 - 24:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
/CONDITION RATTACH ESTCRB_CT EQ "R"
/OUTFILE ${SORT_O}
/INCLUDE RATTACH
exit
EOF
SORT


NSTEP=${NJOB}_32
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_20_${IB}_ESTC2032_IAV_PERICASE_O1.dat
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_IRV_PERICASE_O.dat

#[012]
#[015]
NSTEP=${NJOB}_35
# Retrocession Amounts
#----------------------------------------------------------------------------
LIBEL="Retrocession Amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_ARCSTATGTR} 1000 1"
#SORT_I2="${EST_STATGTR} 1000 1"
#SORT_I3="${EST_GTR} 1000 1 "
SORT_I2="${EST_IGTR00} 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 - 3:EN,
        BALSHRMTH_NF     4:1 - 4:EN,
        BALSHRDAY_NF     5:1 - 5:EN,
        TRNCOD1_CF       6:1 - 6:1,
        TRNCOD8_CF       6:8 - 6:8
/COPY
/CONDITION MVTRET (TRNCOD8_CF = "0" OR ((TRNCOD8_CF = "2" OR TRNCOD8_CF = "4" OR TRNCOD8_CF = "6")
           AND BALSHEY_NF = `expr ${BALSHTYEA_NF} - 1` AND BALSHRMTH_NF = 12 AND BALSHRDAY_NF = 31))
/OUTFILE  ${SORT_O}
/INCLUDE MVTRET
exit
EOF
SORT


#[008] On utilise le fichier IGTAA00 à la place des CURGTA et GTA
#[009] Reduction au format 41 col
NSTEP=${NJOB}_36
# Estimates Acceptance Amounts Previous Balshey Year
#---------------------------------------------------------------------------
LIBEL="1GL: Estimates Acceptance Amounts Previous Balshey Year"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#[008]SORT_I="${EST_CURGTA} 1000 1"
#[008]SORT_I2="${EST_GTA} 1000 1"
SORT_I="${EST_IGTAA00} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
	     BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        BALSHRDAY_NF     5:1 -  5:EN,
	     TRNCOD1_CF       6:1 -  6:1,
	     TRNCOD2_CF       6:2 -  6:2,
	     TRNCOD8_CF       6:8 -  6:8,
	     AMOUNT_M        19:1 - 19:EN 18/3,
        FIELD_41         1:1 - 41:,
        FIELD_1          1:1 - 18:EN
/COPY
/CONDITION ESTACC
           ( BALSHEY_NF = ${BALSHTYEA_NF}               AND
             BALSHRMTH_NF = 1                           AND
             BALSHRDAY_NF = 1                           AND
             ( TRNCOD1_CF = "1" OR TRNCOD1_CF = "3")    AND
             TRNCOD2_CF ne "7"                          AND
             TRNCOD8_CF = "2" )     AND
           ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE ESTACC
/REFORMAT FIELD_41
exit
EOF
SORT


#[008] On utilise le fichier IGTAA00 à la place des CURGTA et GTA
#[009] Reduction au format 41 col
NSTEP=${NJOB}_37
# Estimates Acceptance Amounts current Balshey Year (Openning ES)
#---------------------------------------------------------------------------
LIBEL="1GL: Estimates Acceptance Amounts current Balshey Year (Openning ES)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#[008]SORT_I="${EST_CURGTA} 1000 1"
#[008]SORT_I2="${EST_GTA} 1000 1"
SORT_I="${EST_IGTAA00} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 - 1:EN,
        BALSHEY_NF       3:1 - 3:EN,
        BALSHRMTH_NF     4:1 - 4:EN,
        BALSHRDAY_NF     5:1 - 5:EN,
        TRNCOD1_CF       6:1 - 6:1,
        TRNCOD2_CF       6:2 - 6:2,
        TRNCOD8_CF       6:8 - 6:8,
        FIELD_41         1:1 - 41:
/COPY
/CONDITION ESTACC
           ( BALSHEY_NF = ${BALSHTYEA_NF}               AND
             BALSHRMTH_NF ne 1                          AND
             ( TRNCOD1_CF = "1" OR TRNCOD1_CF = "3" )   AND
             TRNCOD2_CF = "7" )     AND
           ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE ESTACC
/REFORMAT FIELD_41
exit
EOF
SORT


NSTEP=${NJOB}_3A
# Inversion of amounts before merge
#-----------------------------------------------------------------------------
LIBEL="Inversion of amounts before merge"
AWK_I=${DFILT}/${NJOB}_37_${IB}_SORT_CURGTA_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
     { if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
       if (substr(\$6,2,1) == "7")
            \$6= substr(\$6,1,1) "4" substr(\$6,3,6);
            print \$0 }
exit
EOF
AWK


NSTEP=${NJOB}_38
# Merge of Estimates Acceptance Amounts
#----------------------------------------------------------------------------
LIBEL="Merge of Estimates Acceptance Amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_36_${IB}_SORT_CURGTA_O.dat"
SORT_I2="${DFILT}/${NJOB}_3A_${IB}_SORT_CURGTA_O.dat"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE  ${SORT_O}
exit
EOF
SORT


#[008] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  A VOIR !!
NSTEP=${NJOB}_39
# Cession Amounts
#----------------------------------------------------------------------------
LIBEL="Cession Amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VTSTATGTA0} 1000"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VTSTATGTA0_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1:EN,
        TRNCOD1_CF   6:1 - 6:1,
		TRNCOD8_CF   6:8 - 6:8
/COPY
/CONDITION CEDACC ( ( TRNCOD1_CF EQ "1" OR TRNCOD1_CF EQ "3")   AND
                    TRNCOD8_CF = "0" )
/INCLUDE CEDACC
exit
EOF
SORT


NSTEP=${NJOB}_40
# Merge of cession and retrocession amounts
#----------------------------------------------------------------------------
LIBEL="Merge of cession and retrocession amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_39_${IB}_SORT_VTSTATGTA0_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_35_${IB}_SORT_ARCSTATGTR_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_38_${IB}_SORT_CURGTA_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_STATGTAR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN
/COPY
/CONDITION NONVIE ( SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_42
#Retrocession and Acceptance Data Exchange
#------------------------------------------------------------------------------
LIBEL="Retrocession and Acceptance Data Exchange"
PRG=ESTC2033
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_STATGTAR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O.dat
EXECPRG


NSTEP=${NJOB}_45
# Sort of TL, merged by Contrat, Section and U/W Year
#------------------------------------------------------------------------------
LIBEL="Sort of TL, merged by Contrat, Section and U/W Year"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_42_${IB}_ESTC2033_GT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        TRNCOD_CF    6:1 -  6:,
	    CTR_NF       8:1 -  8:,
        SEC_NF      10:1 - 10:,
        UWY_NF      11:1 - 11:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_50
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_35_${IB}_SORT_ARCSTATGTR_O.dat
RMFIL ${DFILT}/${NJOB}_36_${IB}_SORT_CURGTA_O.dat
RMFIL ${DFILT}/${NJOB}_37_${IB}_SORT_CURGTA_O.dat
RMFIL ${DFILT}/${NJOB}_3A_${IB}_SORT_CURGTA_O.dat
RMFIL ${DFILT}/${NJOB}_38_${IB}_SORT_CURGTA_O.dat
RMFIL ${DFILT}/${NJOB}_39_${IB}_SORT_VTSTATGTA0_O.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_STATGTAR_O.dat
RMFIL ${DFILT}/${NJOB}_42_${IB}_ESTC2033_GT_O.dat


NSTEP=${NJOB}_55
#Introduction of Conversion and Accumulated Transaction Codes
# [007] Ajout I5 et O3
#------------------------------------------------------------------------------
LIBEL="Introduction of Conversion and Accumulated Transaction Codes"
PRG=ESTC2034
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IARVPERICASE0}
export ${PRG}_I2=${DFILT}/${NJOB}_45_${IB}_SORT_GT_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${DFILT}/${NJOB}_31_${IB}_SORT_R_IAVPERICASE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_TERMINE_ERR.log
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_45_${IB}_SORT_GT_O.dat            > ${DFILT}/SAVE_${NJOB}_45_SORT_GT_O.gz
gzip -c ${DFILT}/${NJOB}_31_${IB}_SORT_R_IAVPERICASE_O.dat > ${DFILT}/SAVE_${NJOB}_31_SORT_R_IAVPERICASE_O.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O.dat            > ${DFILT}/SAVE_${NSTEP}_${PRG}_GT_O.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O.dat          > ${DFILT}/SAVE_${NSTEP}_${PRG}_GTB1_O.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT_TERMINE_ERR.log  > ${DFILT}/SAVE_${NSTEP}_${PRG}_GT_TERMINE_ERR.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------


NSTEP=${NJOB}_60
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_45_${IB}_SORT_GT_O.dat


NSTEP=${NJOB}_65
# Grouping Accounting Transactions by SyncSort
#------------------------------------------------------------------------------
LIBEL="Grouping Accounting Transactions by SyncSort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_ESTC2034_GT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        CED_ESTCUR      20:1 - 42:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:EN 15/3,
        ESTCRB_CT       50:1 - 50:,
        ESTCRB_UWGRP    50:1 - 67:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      BALSHEY_NF
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_DBLTRNCOD, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTR_CUR, AMT_MC,
          CED_ESTCUR, ESTAMT_MC, NAT_CF, ACMTRS_NT, ESTCTR_NF, ESTSEC_NF, LOB_CF, SCOEGP_MC, ESTCRB_UWGRP
exit
EOF
SORT


NSTEP=${NJOB}_68
# Inversion of estimates retrocession amounts before using
#-----------------------------------------------------------------------------
LIBEL="Inversion of estimates retrocession amounts before using"
AWK_I=${EST_FLIFEST0}
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_LIFEST_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
        { if( \$10 < "2000" ) { print \$0 }}
		{ if( \$10 > "2000" ) { \$14 = sprintf("%-.3lf",-\$14) ; print \$0 }}
exit
EOF
AWK


NSTEP=${NJOB}_70
# Estimates Sort and Screening
#------------------------------------------------------------------------------
LIBEL="Estimates Sort and Screening"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_68_${IB}_AWK_LIFEST_O.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        PRS_CF       9:1 -  9:,
        ACMTRS_NT   10:1 - 10:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT
/CONDITION ESTOK PRS_CF EQ "500" AND ( SSD_CF ne 5 AND SSD_CF ne 6)
/INCLUDE ESTOK
exit
EOF
SORT


NSTEP=${NJOB}_75
# Annual Estimates Actualization
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Actualization"
PRG=ESTC2035
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_70_${IB}_SORT_LIFEST_O.dat
export ${PRG}_I2=${EST_IARVPERICASE0}
export ${PRG}_I3=${EST_FLIFDRI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRI_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ACCOUNT_LIFEST_O2.dat
export ${PRG}_O3=${EST_CRIBLEANO}
export ${PRG}_O4=${EST_LIFESTNOACC}
export ${PRG}_O5=${DFILT}/${NSTEP}_${IB}_${PRG}_END_LIFEST_O5.dat
export ${PRG}_O6=${DFILT}/${NSTEP}_${IB}_${PRG}_NON_CRIBLE_O6.dat   #[017]
export ${PRG}_O7=${DFILT}/${NSTEP}_${IB}_${PRG}_NON_SYNCHRO_O7.dat  #[017]
EXECPRG


NSTEP=${NJOB}_80
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_70_${IB}_SORT_LIFEST_O.dat             > ${DFILT}/${NJOB}_70_SORT_LIFEST_O.dat.gz
gzip -c ${DFILT}/${NJOB}_75_${IB}_${PRG}_LIFDRI_O1.dat          > ${DFILT}/${NJOB}_75_ESTC2035_LIFDRI_O1.dat.gz
gzip -c ${DFILT}/${NJOB}_75_${IB}_${PRG}_ACCOUNT_LIFEST_O2.dat  > ${DFILT}/${NJOB}_75_ESTC2035_ACCOUNT_LIFEST_O2.dat.gz
gzip -c ${DFILT}/${NJOB}_75_${IB}_${PRG}_END_LIFEST_O5.dat      > ${DFILT}/${NJOB}_75_ESTC2035_END_LIFEST_O5.dat.gz


RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC2034_GT_O.dat
RMFIL ${DFILT}/${NJOB}_68_${IB}_AWK_LIFEST_O.dat
RMFIL ${DFILT}/${NJOB}_70_${IB}_SORT_LIFEST_O.dat


NSTEP=${NJOB}_85
# Complete Accounts Screen and Sort
#------------------------------------------------------------------------------
LIBEL="Complete Accounts Screen and Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCPLACC0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CPLACC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        ACY_NF 3:1 - 3:,
        SCOENDMTH_NF 5:1 - 5:
/KEYS CTR_NF,
      ACY_NF DESCENDING
/CONDITION DECEMBRE SCOENDMTH_NF EQ "12"
/INCLUDE DECEMBRE
exit
EOF
SORT


NSTEP=${NJOB}_87
# Complete Accounts Screen and Sort
#------------------------------------------------------------------------------
LIBEL="Complete Accounts Screen and Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_85_${IB}_SORT_CPLACC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CPLACC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 2:1 - 2:,
        ACY_NF 3:1 - 3:
/KEYS CTR_NF,
      ACY_NF DESCENDING
/CONDITION NONVIE   ( SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE  ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_90
# Complete Account Screen
#------------------------------------------------------------------------------
LIBEL="Complete Account Screen"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_87_${IB}_SORT_CPLACC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CPLACC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:
/KEYS CTR_NF
/STABLE
/SUM
exit
EOF
SORT


NSTEP=${NJOB}_95
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_85_${IB}_SORT_CPLACC_O.dat
RMFIL ${DFILT}/${NJOB}_87_${IB}_SORT_CPLACC_O.dat



NSTEP=${NJOB}_100
# Sort FLSTMTH file
#------------------------------------------------------------------------------
LIBEL="Sort FLSTMTH file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FLSTMTH}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LSTMTH_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 - 1:,
        SCOENDMTH_NF 2:1 - 2:EN,
        RETACCYER_NF 3:1 - 3:
/KEYS CTR_NF,
      RETACCYER_NF
/CONDITION LSTMTH SCOENDMTH_NF = 12
/INCLUDE LSTMTH
exit
EOF
SORT


NSTEP=${NJOB}_105
# Taking into Account Accounting Transactions Statistical Expiries
#------------------------------------------------------------------------------
LIBEL="Taking into Account Accounting Transactions Statistical Expiries"
PRG=ESTC2036
export ${PRG}_I1=${DFILT}/${NJOB}_65_${IB}_SORT_GT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_SORT_CPLACC_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_100_${IB}_SORT_LSTMTH_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O3.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_65_${IB}_SORT_GT_O.dat       > ${DFILT}/SAVE_${NJOB}_65_SORT_GT_O.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_SORT_CPLACC_O.dat   > ${DFILT}/SAVE_${NJOB}_90_SORT_CPLACC_O.gz
gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_LSTMTH_O.dat  > ${DFILT}/SAVE_${NJOB}_100_SORT_LSTMTH_O.gz
gzip -c ${DFILT}/${NJOB}_105_${IB}_ESTC2036_GT_O1.dat > ${DFILT}/SAVE_${NJOB}_105_ESTC2036_GT_O1.gz
gzip -c ${DFILT}/${NJOB}_105_${IB}_ESTC2036_GT_O2.dat > ${DFILT}/SAVE_${NJOB}_105_ESTC2036_GT_O2.gz
gzip -c ${DFILT}/${NJOB}_105_${IB}_ESTC2036_GT_O3.dat > ${DFILT}/SAVE_${NJOB}_105_ESTC2036_GT_O3.gz
# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------

NSTEP=${NJOB}_110
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_65_${IB}_SORT_GT_O.dat


NSTEP=${NJOB}_115
# Treaties Sort
#------------------------------------------------------------------------------
#[007] Ajout SCOEND et OCCYEA dans le tri pour générer dans le ESCT2037 toujours la dernière période/exercice de survenance., et ajout de EN sur les champs numériques
LIBEL="Treaties Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_105_${IB}_ESTC2036_GT_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACY_NF          14:1 - 14:EN,
        ACMTRS_NT       45:1 - 45:EN,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:EN,
        SCOENDMTH_NF    16:1 - 16:EN,
        OCCYEA_NF       13:1 - 13:EN
/KEYS ESTCTR_NF, ESTSEC_NF, ACY_NF, ACMTRS_NT, SCOENDMTH_NF, OCCYEA_NF
exit
EOF
SORT


NSTEP=${NJOB}_120
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_105_${IB}_ESTC2036_GT_O1.dat

NSTEP=${NJOB}_125
# Attachment Treaties Sort
#------------------------------------------------------------------------------
LIBEL="Attachment Treaties Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_105_${IB}_ESTC2036_GT_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF  8:1 - 8:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_132
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_105_${IB}_ESTC2036_GT_O2.dat

NSTEP=${NJOB}_135
# Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARVPERICASE0_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS UWY_NF       6:1 -  6:,
        ESTCTR_NF   25:1 - 25:,
        ESTSEC_NF   27:1 - 27:
/KEYS ESTCTR_NF,
      ESTSEC_NF,
      UWY_NF
/SUM
exit
EOF
SORT


NSTEP=${NJOB}_137
#Syncro Attachment treaties / A-R perimeter
#------------------------------------------------------------------------------
LIBEL="Syncro Attachment treaties / A-R perimeter"
PRG=ESTC2042
export ${PRG}_I1=${DFILT}/${NJOB}_135_${IB}_SORT_IARVPERICASE0_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_125_${IB}_SORT_GT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O.dat
EXECPRG


NSTEP=${NJOB}_139
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_135_${IB}_SORT_IARVPERICASE0_O.dat


NSTEP=${NJOB}_140
# Accounting Update and Fictitious Treaties Statistical Expiries Indicator
#------------------------------------------------------------------------------
LIBEL="Accounting Update and Fictitious Treaties Statistical Expiries Indicator"
PRG=ESTC2037
export ${PRG}_I1=${DFILT}/${NJOB}_115_${IB}_SORT_GT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_137_${IB}_ESTC2042_GT_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O3.log  #[013]
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_115_${IB}_SORT_GT_O.dat     > ${DFILT}/SAVE_${PRG}_${NJOB}_115_SORT_GT_O.gz
gzip -c ${DFILT}/${NJOB}_137_${IB}_ESTC2042_GT_O.dat > ${DFILT}/SAVE_${PRG}_${NJOB}_137_ESTC2042_GT_O.gz
gzip -c ${EST_FCURQUOT}                              > ${DFILT}/SAVE_${PRG}_EST_FCURQUOT.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O1.dat     > ${DFILT}/SAVE_${NSTEP}_${PRG}_GT_O1.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O2.dat     > ${DFILT}/SAVE_${NSTEP}_${PRG}_GT_O2.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O3.log     > ${DFILT}/SAVE_${NSTEP}_${PRG}_GT_O3.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------


NSTEP=${NJOB}_142
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_115_${IB}_SORT_GT_O.dat
RMFIL ${DFILT}/${NJOB}_137_${IB}_ESTC2042_GT_O.dat


NSTEP=${NJOB}_145
# Sort of TL filled in by Contrat, Accounting Year, Indicator
#------------------------------------------------------------------------------
LIBEL="Sort of TL filled in by Contrat, Accounting Year, Indicator"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_ESTC2037_GT_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    8:1 - 8:,
        ACY_NF   14:1 - 14:,
        COMACC_B 56:1 - 56:
/KEYS CTR_NF,
      ACY_NF,
      COMACC_B
exit
EOF
SORT


NSTEP=${NJOB}_150
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_140_${IB}_ESTC2037_GT_O2.dat


NSTEP=${NJOB}_155
# Calculation of COMACC_B by CTR_NF, ACY_NF
#------------------------------------------------------------------------------
# Calculation of COMACC_B by CTR_NF, ACY_NF
PRG=ESTC2037b
export ${PRG}_I1=${DFILT}/${NJOB}_145_${IB}_SORT_GT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_145_${IB}_SORT_GT_O.dat > ${DFILT}/SAVE_${PRG}_${NJOB}_145_SORT_GT_O.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O.dat  > ${DFILT}/SAVE_${NSTEP}_${PRG}_GT_O.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------


NSTEP=${NJOB}_160
# Grouping All Treaties Transactions except non-sorted ones
#------------------------------------------------------------------------------
LIBEL="Grouping All Treaties Transactions except non-sorted ones"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_155_${IB}_ESTC2037b_GT_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_105_${IB}_ESTC2036_GT_O3.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_ESTCUR      20:1 - 42:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:,
        ESTCRB_CT       50:1 - 50:,
        ESTCRB_UWGRP    50:1 - 67:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_DBLTRNCOD, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTR_CUR, AMT_MC,
          CED_ESTCUR, ESTAMT_MC, NAT_CF, ACMTRS_NT, ESTCTR_NF, ESTSEC_NF, LOB_CF, SCOEGP_MC, ESTCRB_UWGRP
exit
EOF
SORT

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_155_${IB}_ESTC2037b_GT_O.dat > ${DFILT}/SAVE_${NJOB}_155_ESTC2037b_GT_O.gz
# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------

NSTEP=${NJOB}_165
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_155_${IB}_ESTC2037b_GT_O.dat
RMFIL ${DFILT}/${NJOB}_105_${IB}_ESTC2036_GT_O3.dat


NSTEP=${NJOB}_170
# Annual Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_ESTC2035_ACCOUNT_LIFEST_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        CRE_D        8:1 -  8:,
        ACMTRS_NT   10:1 - 10:,
        BALSHEY_NF  11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
/CONDITION NONVIE   ( SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE  ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_175
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_75_${IB}_ESTC2035_ACCOUNT_LIFEST_O2.dat


NSTEP=${NJOB}_180
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_170_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFEST_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_OLD_LIFEST_O2.dat
EXECPRG


NSTEP=${NJOB}_185
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_170_${IB}_SORT_LIFEST_O.dat


NSTEP=${NJOB}_190
# Taking into Account Annual Estimates Statistical Expiries
#------------------------------------------------------------------------------
LIBEL="Taking into Account Annual Estimates Statistical Expiries"
PRG=ESTC2038
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
BALSHTMTH_NF  ${BALSHTMTH_NF}
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_160_${IB}_SORT_GT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_75_${IB}_ESTC2035_LIFDRI_O1.dat
export ${PRG}_I3=${DFILT}/${NJOB}_180_${IB}_ESTC2040_LAST_LIFEST_O1.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRI_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O2.dat
export ${PRG}_O3=${EST_CPLIFDRIASC}
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_GT_O.dat > ${DFILT}/SAVE_${NJOB}_160_SORT_GT_O.gz
gzip -c ${DFILT}/${NJOB}_75_${IB}_ESTC2035_LIFDRI_O1.dat > ${DFILT}/SAVE_${NJOB}_75_ESTC2035_LIFDRI_O1.gz
gzip -c ${DFILT}/${NJOB}_180_${IB}_ESTC2040_LAST_LIFEST_O1.dat > ${DFILT}/SAVE_${NJOB}_180_ESTC2040_LAST_LIFEST_O1.gz
gzip -c ${DFILT}/${NJOB}_190_${IB}_ESTC2038_LIFEST_O2.dat > ${DFILT}/SAVE_${NJOB}_190_ESTC2038_LIFEST_O2.gz
gzip -c ${DFILT}/${NJOB}_190_${IB}_ESTC2038_LIFDRI_O1.dat > ${DFILT}/SAVE_${NJOB}_190_ESTC2038_LIFDRI_O1.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------


NSTEP=${NJOB}_191
# Sort CPLIFDRI binary file
#[007] changement dans le tri pour pointer sur les bons champs
#------------------------------------------------------------------------------
LIBEL="Sort of CPLIFDRI binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_ESTC2038_LIFDRI_O1.dat fixed 108"
SORT_O=${EST_CPLIFDRI}
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF           1 CHAR 10,
        END_NT	        10 UINTEGER 1,
        SEC_NF	        12 UINTEGER 1,
        UWY_NF          14 INT 2,
        UW_NT           16 UINTEGER 1,
        ACY_NF          17 INT 2,
        SSD_CF          19 UINTEGER 1,
        BALSHEY_NF      21 INT 2,
        BALSHTMTH_NF    23 UINTEGER 1,
        AUTUPD_B        24 UINTEGER 1,
        COMACC_B        25 UINTEGER 1,
        CRE_D	        26 CHAR 17
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      CRE_D DESCENDING
exit
EOF
SORT
#S2L fin



NSTEP=${NJOB}_195
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_75_${IB}_ESTC2035_LIFDRI_O1.dat
RMFIL ${DFILT}/${NJOB}_180_${IB}_ESTC2040_LAST_LIFEST_O1.dat
#S2L
RMFIL ${DFILT}/${NJOB}_190_${IB}_ESTC2038_LIFDRI_O1.dat


NSTEP=${NJOB}_200
# Annual Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_ESTC2038_LIFEST_O2.dat 1000 1"
SORT_I2=${EST_LIFESTNOACC}
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       2:1 -  2:,
        SEC_NF       4:1 -  4:,
        UWY_NF       5:1 -  5:,
        ACY_NF       7:1 -  7:,
        CRE_D        8:1 -  8:,
        ACMTRS_NT   10:1 - 10:,
        BALSHEY_NF  11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
exit
EOF
SORT


NSTEP=${NJOB}_205
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_200_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFEST_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_OLD_LIFEST_O2.dat
EXECPRG


NSTEP=${NJOB}_210
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary files"
RMFIL ${DFILT}/${NJOB}_190_${IB}_ESTC2038_LIFEST_O2.dat
RMFIL ${DFILT}/${NJOB}_200_${IB}_SORT_LIFEST_O.dat


NSTEP=${NJOB}_212
# Grouping All Non-sorted Treaties Transactions
#------------------------------------------------------------------------------
LIBEL="Grouping All Non-sorted Treaties Transactions"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_ESTC2037_GT_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_ESTCUR      20:1 - 42:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:,
        ESTCRB_CT       50:1 - 50:,
        ESTCRB_UWGRP    50:1 - 67:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_DBLTRNCOD, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTR_CUR, AMT_MC,
          CED_ESTCUR, ESTAMT_MC, NAT_CF, ACMTRS_NT, ESTCTR_NF, ESTSEC_NF, LOB_CF, SCOEGP_MC, ESTCRB_UWGRP
exit
EOF
SORT


NSTEP=${NJOB}_215
# Merged TL file Sort
#------------------------------------------------------------------------------
LIBEL="Merged TL file Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_160_${IB}_SORT_GT_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_212_${IB}_SORT_GT_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACMTRS_NT 45:1 - 45:
/KEYS ACMTRS_NT
exit
EOF
SORT

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_GT_O.dat          > ${DFILT}/SAVE_${NJOB}_160_SORT_GT_O.gz
gzip -c ${DFILT}/${NJOB}_212_${IB}_SORT_GT_O1.dat      > ${DFILT}/SAVE_${NJOB}_212_SORT_GT_O1.gz
# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------


NSTEP=${NJOB}_220
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_145_${IB}_SORT_GT_O.dat
RMFIL ${DFILT}/${NJOB}_160_${IB}_SORT_GT_O.dat


NSTEP=${NJOB}_225
# Grouped Transaction Codes Sort
#------------------------------------------------------------------------------
LIBEL="Grouped Transaction Codes Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCPAR0} 1000 1"
SORT_O="${EST_VACCPAR120} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACMTRS_NT 1:1 - 1:
/KEYS ACMTRS_NT
exit
EOF
SORT

NSTEP=${NJOB}_230
# Annual Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_205_${IB}_ESTC2040_LAST_LIFEST_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACMTRS_NT 10:1 - 10:
/KEYS ACMTRS_NT
exit
EOF
SORT


NSTEP=${NJOB}_235
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_205_${IB}_ESTC2040_LAST_LIFEST_O1.dat


NSTEP=${NJOB}_240
# Parameters Actualization
#------------------------------------------------------------------------------
LIBEL="Parameters Actualization"
PRG=ESTC2130
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_215_${IB}_SORT_GT_O.dat
export ${PRG}_I2=${EST_VACCPAR120}
export ${PRG}_I3=${DFILT}/${NJOB}_230_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTC.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O2.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_215_${IB}_SORT_GT_O.dat          > ${DFILT}/SAVE_${NJOB}_215_SORT_GT_O.gz
gzip -c ${DFILT}/${NJOB}_230_${IB}_SORT_LIFEST_O.dat      > ${DFILT}/SAVE_${NJOB}_230_SORT_LIFEST_O.gz
gzip -c ${DFILT}/${NJOB}_240_${IB}_ESTC2130_SRGTC.dat     > ${DFILT}/SAVE_${NJOB}_240_ESTC2130_SRGTC.gz
gzip -c ${DFILT}/${NJOB}_240_${IB}_ESTC2130_LIFEST_O2.dat > ${DFILT}/SAVE_${NJOB}_240__ESTC2130_LIFEST_O2.gz
# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------

#[012]
NSTEP=${NJOB}_242
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT SRGTC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_240_${IB}_ESTC2130_SRGTC.dat 1000 1"
SORT_O="${EST_SRGTC}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1      1:1 - 35:,
        FILLER1B    37:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER2     42:1 - 67:
/COPY
/OUTFILE ${SORT_O}
/DERIVEDFIELD PLC_NT "~"
/REFORMAT FILLER1, FILLER1B, PLC_NT, FILLER2
exit
EOF
SORT


NSTEP=${NJOB}_245
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_215_${IB}_SORT_GT_O.dat
RMFIL ${DFILT}/${NJOB}_240_${IB}_ESTC2130_SRGTC.dat


NSTEP=${NJOB}_250
# Annual Estimates Merge for Retrocession Generation
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Merge for Retrocession Generation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_240_${IB}_ESTC2130_LIFEST_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF  2:1 - 2:,
        SEC_NF  4:1 - 4:,
        UWY_NF  5:1 - 5:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_255
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_240_${IB}_ESTC2130_LIFEST_O2.dat


NSTEP=${NJOB}_260
#Retro Generation, Placements File Sort
#------------------------------------------------------------------------------
LIBEL="Retro Generation, Placements File Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT0} 1000 1"
SORT_O="${EST_FVPLACEMT} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS LOB_CF      17:1 - 17:,
        RETCTR_NF    3:1 -  3:,
        RETSEC_NF    5:1 -  5:,
        RTY_NF       6:1 -  6:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF
/CONDITION LOB_25_OU_31 ( (LOB_CF = "30") OR (LOB_CF = "31") )
/INCLUDE LOB_25_OU_31
exit
EOF
SORT

NSTEP=${NJOB}_344
# Begin EXECKSH
#------------------------------------------------------------------------------
LIBEL="copy file SORT_LIFEST_O"
EXECKSH "cp ${DFILT}/${NJOB}_250_${IB}_SORT_LIFEST_O.dat ${DFILT}/${NJOB}_250_${IB}_SORT_LIFEST_O.log"

NSTEP=${NJOB}_345
# Merging Annual Estimates for Sybase Insertion
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_SORT_LIFEST_O.dat"
SORT_O="${EST_VLIFEST195} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        CRE_D            8:1 -  8:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        ESTMNT_M        14:1 - 14:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT
/SUMMARIZE TOTAL ESTMNT_M
exit
EOF
SORT


NSTEP=${NJOB}_350
# Merging Annual Estimates for Sybase Insertion
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_ESTC2040_OLD_LIFEST_O2.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_75_${IB}_ESTC2035_END_LIFEST_O5.dat 1000 1"
SORT_I3="${EST_VLIFEST195} 1000 1"
SORT_I4="${DFILT}/${NJOB}_205_${IB}_ESTC2040_OLD_LIFEST_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1: EN,
        CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        CRE_D            8:1 -  8:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        CUR_CF          13:1 - 13:,
        ESTMNT_M        14:1 - 14:EN 15/3,
        INDSUP_B        30:1 - 30:,
        ORICOD_LS       31:1 - 31:,
        CREUSR_CF       32:1 - 32:,
        LSTUPD_D        33:1 - 33:,
        LSTUPDUSR_CF    34:1 - 34:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT
/SUM TOTAL ESTMNT_M
/DERIVEDFIELD PRS_CF "500~"
/CONDITION NONVIE   ( SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE ${SORT_O}
/REFORMAT CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, PRS_CF, ACMTRS_NT,
          SSD_CF, CUR_CF, ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
exit
EOF
SORT

NSTEP=${NJOB}_352
# Inversion of estimates retrocession amounts before loading
#-----------------------------------------------------------------------------
LIBEL="Inversion of estimates retrocession amounts before loading"
AWK_I=${DFILT}/${NJOB}_350_${IB}_SORT_FLIFEST_O.dat
AWK_O=${EST_CPLIFEST}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
        { if( \$11 < "2000" ) { print \$0 }}
		{ if( \$11 > "2000" ) { \$14 = sprintf("%-.3lf",-\$14) ; print \$0 }}
exit
EOF
AWK


NSTEP=${NJOB}_353
# Merging and Filtering of Previous Balshey Year file
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of Previous Balshey Year file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_ESTC2034_GTB1_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O1.dat 1000 1 "
SORT_O1="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O2.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ESTCRB_CT 50:1 - 50:
/COPY
/CONDITION RATT ESTCRB_CT EQ "R"
/OUTFILE  ${SORT_O}
/OMIT RATT
/OUTFILE  ${SORT_O1}
/INCLUDE RATT
exit
EOF
SORT


NSTEP=${NJOB}_355
# Grouping Accounting Transactions by SyncSort
#------------------------------------------------------------------------------
LIBEL="Grouping Accounting Transactions by SyncSort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_ESTCUR      20:1 - 42:,
        PLC_NT          36:1 - 36:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:,
        ESTCRB_CT       50:1 - 50:,
        ESTCRB_UWGRP    50:1 - 67:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
	  PLC_NT,
      ACMTRS_NT,
      BALSHEY_NF
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_DBLTRNCOD, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTR_CUR, AMT_MC,
          CED_ESTCUR, ESTAMT_MC, NAT_CF, ACMTRS_NT, ESTCTR_NF, ESTSEC_NF, LOB_CF, SCOEGP_MC, ESTCRB_UWGRP
exit
EOF
SORT


NSTEP=${NJOB}_360
# Taking into Account Accounting Transactions Statistical Expiries
#------------------------------------------------------------------------------
LIBEL="Taking into Account Accounting Transactions Statistical Expiries"
PRG=ESTC2036
export ${PRG}_I1=${DFILT}/${NJOB}_355_${IB}_SORT_GTB1_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_SORT_CPLACC_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_100_${IB}_SORT_LSTMTH_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O3.dat
EXECPRG


NSTEP=${NJOB}_365
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_CPLACC_O.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_LSTMTH_O.dat
RMFIL ${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O1.dat
RMFIL ${DFILT}/${NJOB}_355_${IB}_SORT_GTB1_O.dat
RMFIL ${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O2.dat


NSTEP=${NJOB}_370
# Treaties Sort
#------------------------------------------------------------------------------
LIBEL="Treaties Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACY_NF      14:1 - 14:,
        ACMTRS_NT   45:1 - 45:,
        ESTCTR_NF   46:1 - 46:,
        ESTSEC_NF   47:1 - 47:
/KEYS ESTCTR_NF,
      ESTSEC_NF,
      ACY_NF,
      ACMTRS_NT
exit
EOF
SORT


NSTEP=${NJOB}_375
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O1.dat


NSTEP=${NJOB}_385
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O2.dat


NSTEP=${NJOB}_390
# Accounting Update and Fictitious Treaties Statistical Expiries Indicator
#------------------------------------------------------------------------------
LIBEL="Accounting Update and Fictitious Treaties Statistical Expiries Indicator"
PRG=ESTC2037
export ${PRG}_I1=${DFILT}/${NJOB}_370_${IB}_SORT_GTB1_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_125_${IB}_SORT_GT_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O3.log  #[013]
EXECPRG


NSTEP=${NJOB}_395
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_370_${IB}_SORT_GTB1_O.dat
RMFIL ${DFILT}/${NJOB}_125_${IB}_SORT_GT_O.dat


NSTEP=${NJOB}_400
# Sort of TL filled in by Contrat, Accounting Year, Indicator
#------------------------------------------------------------------------------
LIBEL="Sort of TL filled in by Contrat, Accounting Year, Indicator"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_390_${IB}_ESTC2037_GTB1_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       8:1 -  8:,
        ACY_NF      14:1 - 14:,
        COMACC_B    56:1 - 56:
/KEYS CTR_NF,
      ACY_NF,
      COMACC_B
exit
EOF
SORT


NSTEP=${NJOB}_405
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_390_${IB}_ESTC2037_GTB1_O2.dat


NSTEP=${NJOB}_410
# Calculation of COMACC_B by CTR_NF, ACY_NF
#------------------------------------------------------------------------------
# Calculation of COMACC_B by CTR_NF, ACY_NF
PRG=ESTC2037b
export ${PRG}_I1=${DFILT}/${NJOB}_400_${IB}_SORT_GTB1_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_400_${IB}_SORT_GTB1_O.dat      > ${DFILT}/SAVE_${NJOB}_400_SORT_GTB1_O.gz
gzip -c ${DFILT}/${NJOB}_410_${IB}_ESTC2037b_GTB1_O.dat > ${DFILT}/SAVE_${NJOB}_410_ESTC2037b_GTB1_O.gz
gzip -c ${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O3.dat > ${DFILT}/SAVE_${NJOB}_360_ESTC2036_GTB1_O3.gz
gzip -c ${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O2.dat     > ${DFILT}/SAVE_${NJOB}_353_SORT_GTB1_O2.gz
# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------

NSTEP=${NJOB}_415
# Grouping All Treaties Transactions except non-sorted ones
#------------------------------------------------------------------------------
LIBEL="Grouping All Treaties Transactions except non-sorted ones"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_410_${IB}_ESTC2037b_GTB1_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O3.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_ESTCUR      20:1 - 42:,
	    	PLC_NT      36:1 - 36:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:,
        ESTCRB_CT       50:1 - 50:,
        ESTCRB_UWGRP    50:1 - 67:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
	  PLC_NT,
      ACMTRS_NT
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_DBLTRNCOD, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTR_CUR, AMT_MC,
          CED_ESTCUR, ESTAMT_MC, NAT_CF, ACMTRS_NT, ESTCTR_NF, ESTSEC_NF, LOB_CF, SCOEGP_MC, ESTCRB_UWGRP
exit
EOF
SORT


NSTEP=${NJOB}_420
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_410_${IB}_ESTC2037b_GTB1_O.dat
RMFIL ${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O3.dat
RMFIL ${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O2.dat


NSTEP=${NJOB}_425
# Grouping All Non-sorted Treaties Transactions
#------------------------------------------------------------------------------
LIBEL="Grouping All Non-sorted Treaties Transactions"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_390_${IB}_ESTC2037_GTB1_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_ESTCUR      20:1 - 42:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:,
        ESTCRB_CT       50:1 - 50:,
        ESTCRB_UWGRP    50:1 - 67:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_DBLTRNCOD, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTR_CUR, AMT_MC,
          CED_ESTCUR, ESTAMT_MC, NAT_CF, ACMTRS_NT, ESTCTR_NF, ESTSEC_NF, LOB_CF, SCOEGP_MC, ESTCRB_UWGRP
exit
EOF
SORT


NSTEP=${NJOB}_430
# Merged TL file Sort
#------------------------------------------------------------------------------
LIBEL="Merged TL file Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_415_${IB}_SORT_GTB1_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_425_${IB}_SORT_GTB1_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACMTRS_NT 45:1 - 45:
/KEYS ACMTRS_NT
exit
EOF
SORT


NSTEP=${NJOB}_435
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_400_${IB}_SORT_GTB1_O.dat
RMFIL ${DFILT}/${NJOB}_415_${IB}_SORT_GTB1_O.dat


NSTEP=${NJOB}_440
# Parameters Actualization
#------------------------------------------------------------------------------
LIBEL="Parameters Actualization"
PRG=ESTC2130
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_430_${IB}_SORT_GTB1_O.dat
export ${PRG}_I2=${EST_VACCPAR120}
export ${PRG}_I3=${DFILT}/${NJOB}_230_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTCB1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O2.dat
EXECPRG

#[012]
NSTEP=${NJOB}_442
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT SRGTCB1"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_440_${IB}_ESTC2130_SRGTCB1.dat 1000 1"
SORT_O="${EST_SRGTCB1}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1      1:1 - 35:,
        FILLER1B    37:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER2     42:1 - 67:
/COPY
/OUTFILE ${SORT_O}
/DERIVEDFIELD PLC_NT "~"
/REFORMAT FILLER1, FILLER1B, PLC_NT, FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_445
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_430_${IB}_SORT_GTB1_O.dat
RMFIL ${DFILT}/${NJOB}_230_${IB}_SORT_LIFEST_O.dat
RMFIL ${DFILT}/${NJOB}_440_${IB}_ESTC2130_LIFEST_O2.dat
RMFIL ${DFILT}/${NJOB}_440_${IB}_ESTC2130_SRGTCB1.dat

#[016]
NSTEP=${NJOB}_455
# gzip du fichier pour optimisation
#------------------------------------------------------------------------------
LIBEL="gzip fichiers pour optimisation"
EXECKSH_MODE=P
RMFIL "${EST_FLIFEST0}.gz"
EXECKSH "gzip ${EST_FLIFEST0}"

NSTEP=${NJOB}_460
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND


