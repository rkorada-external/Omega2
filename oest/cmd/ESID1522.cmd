#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Comptabilisation des ecritures de services
# nom du script SHELL		: ESID1522.cmd
# revision			: $Revision:   1.8  $
# date de creation		: 03/09/2003
# auteur			: J. Ribot
# references des specifications	:     SPOT EST6481.doc
#-----------------------------------------------------------------------------
# description
#   Special entries booking
#
# Input files
#       EST_FACCSUP       DFILI
#       EST_FCES                  DFILP
#       EST_FCURCVSNI     DFILI
#       EST_FCURQUOT              DFILP
#       EST_FDETTRS       DFILI
#       EST_FPLC                  DFILP
#       EST_FRETTRF       DFILI
#
# Output files
#	     EST_ECRSRVAPC    DFILI
#	     EST_ECRSRVRPC    DFILI
#	     EST_ECRSRVACBP   DFILI
#	     EST_ECRSRVRCBP   DFILI
#
# Job launched by ESID1800.cmd
#
# Launch C programs ESTM7620 ESTM7621 ESTC2303 ESTC2304
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#   02/ 06 / 04 J. Ribot ajout step 00 02 03 05 (conditionné sur COND1 = 'Y' variante 4)
#                           pour garder les enregistrements des filiales non presentes dans l'inventaire (SOPT 4935)
#[001] 03/04/2013 Philippe Pezout :spot:25057 - Modifications des tris modification des longueurs d'enregistrements step 01 à 95
#[002] 24/04/2013 roger Cassis    :spot:25239 - Changement taille work d'un tri de 1000 a 512 pour eviter plantages
#[003] 27/01/2015 S.Behague       :spot 28122 - EST48
#[004] 11/03/2015 P. Menant       :spot 28122 - EST48, ajout du parametre CLODAT_D a ESTM7621
#[005] 05/10/2015 -=Dch=-  		  :spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
#[006] 18/03/2021  B.Lagha        :spot:81531 - Remplacer les noms des fichiers perm par des varibales step 010 et 07
#[007] 11/07/2021  S.Behague      :spira:105573 ESID1520 job in error
#[008] 23/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0  
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#Get input parameters

#===============================================================================

CLODAT_D=$1
BALSHEY_NF=$2
LIF_ACY_MIN=4
LIF_ACY_MAX=4
echo ${CLODAT_D}
################################################
export CLODAT_YEAR=`echo ${CLODAT_D} | cut -c1-4`
export CLODAT_MTH=`echo ${CLODAT_D} | cut -c5-6`
export CLODAT_DAY=`echo ${CLODAT_D} | cut -c7-8`
################################################

#===============================================================================


# Job Initialisation
JOBINIT

if [ "${EST_ESID1520_COND1}" = "Y" ]
then
	if [ "${EST_ECRSRVAPC}" = "" ]
	then
		NSTEP=${NJOB}_010
		#------------------------------------------------------------------------------
		       LIBEL="touch DFILT _WRK_ECRSRVAPC.dat"
		       EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_WRK_ECRSRVAPC.dat"
	else
		NSTEP=${NJOB}_010
		#------------------------------------------------------------------------------
		        LIBEL="move EST_ECRSRVAPC ==> DFILT _WRK_ECRSRVAPC.dat"
		        EXECKSH "cp ${EST_ECRSRVAPC} ${DFILT}/${NSTEP}_${IB}_WRK_ECRSRVAPC.dat"
	fi	        
  if [ "${EST_ECRSRVRPC}" = "" ]
	then
		NSTEP=${NJOB}_011
		#------------------------------------------------------------------------------
		    LIBEL="touch DFILT _WRK_ECRSRVRPC.dat"
		    EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_WRK_ECRSRVRPC.dat"
	else
		NSTEP=${NJOB}_011
		#------------------------------------------------------------------------------
		    LIBEL="move EST_ECRSRVRPC ==> DFILT _WRK_ECRSRVRPC.dat"
        EXECKSH "cp ${EST_ECRSRVRPC} ${DFILT}/${NSTEP}_${IB}_WRK_ECRSRVRPC.dat"
	fi	 
 if [ "${EST_ECRSRVACBP}" = "" ]
	then
		NSTEP=${NJOB}_012
		#------------------------------------------------------------------------------
		    LIBEL="touch DFILT _WRK_ECRSRVACBP.dat"
		    EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_WRK_ECRSRVACBP.dat"
	else
		NSTEP=${NJOB}_012
		#------------------------------------------------------------------------------
		    LIBEL="move EST_ECRSRVACBP ==> DFILT _WRK_ECRSRVACBP.dat"
        EXECKSH "cp ${EST_ECRSRVACBP} ${DFILT}/${NSTEP}_${IB}_WRK_ECRSRVACBP.dat"
	fi	 
 if [ "${EST_ECRSRVRCBP}" = "" ]
	then
		NSTEP=${NJOB}_013
		#------------------------------------------------------------------------------
		    LIBEL="touch DFILT _WRK_ECRSRVRCBP.dat"
		    EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_WRK_ECRSRVRCBP.dat"
	else
		NSTEP=${NJOB}_013
		#------------------------------------------------------------------------------
		    LIBEL="move EST_ECRSRVRCBP ==> DFILT _WRK_ECRSRVRCBP.dat"
        EXECKSH "cp ${EST_ECRSRVRCBP} ${DFILT}/${NSTEP}_${IB}_WRK_ECRSRVRCBP.dat"
	fi	 


# ajout step pour garder les enregistrements des filiales non presentes dans l'inventaire
#  JR 01/06/2004
NSTEP=${NJOB}_02
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${EST_ECRSRVAPC}
SORT_I="${DFILT}/${NJOB}_010_${IB}_WRK_ECRSRVAPC.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVAPC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        FILLER1 1:1 - 57:,
        FILLER2 59:1 - 67:
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/DERIVEDFIELD PC_FIELD "PCECR~"
/OMIT INVENTAIRE
/OUTFILE ${SORT_O}
/REFORMAT
           FILLER1,
           PC_FIELD,
           FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_03
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${EST_ECRSRVRPC}
SORT_I="${DFILT}/${NJOB}_011_${IB}_WRK_ECRSRVRPC.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVRPC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        FILLER1 1:1 - 57:,
        FILLER2 59:1 - 67:
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/DERIVEDFIELD PC_FIELD "PCECR~"
/OMIT INVENTAIRE
/OUTFILE ${SORT_O}
/REFORMAT
           FILLER1,
           PC_FIELD,
           FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${EST_ECRSRVACBP}
SORT_I="${DFILT}/${NJOB}_012_${IB}_WRK_ECRSRVACBP.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVACBP_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        FILLER1 1:1 - 57:,
        FILLER2 59:1 - 67:
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/DERIVEDFIELD CBP_FIELD "CBPECR~"
/OMIT INVENTAIRE
/OUTFILE ${SORT_O}
/REFORMAT
           FILLER1,
           CBP_FIELD,
           FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_06
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${EST_ECRSRVRCBP}
SORT_I="${DFILT}/${NJOB}_013_${IB}_WRK_ECRSRVRCBP.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVRCBP_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        FILLER1 1:1 - 57:,
        FILLER2 59:1 - 67:
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/DERIVEDFIELD CBP_FIELD "CBPECR~"
/OMIT INVENTAIRE
/OUTFILE ${SORT_O}
/REFORMAT
           FILLER1,
           CBP_FIELD,
           FILLER2
exit
EOF
SORT

fi

NSTEP=${NJOB}_07
#Last version of ESID1520 files deletion
#-----------------------------------------------------------------
RMFIL "  ${EST_ECRSRVAPC}
         ${EST_ECRSRVRPC}
         ${EST_ECRSRVACBP}
         ${EST_ECRSRVRCBP} "

echo CLODAT_D

if [ "${CLODAT_MTH}" != "12"   ]
then

    NSTEP=${NJOB}_08
#------------------------------------------------------------------------------
        LIBEL="move EST_FACCSUP ==> DFILT _WRK_FACCSUP.dat"
        EXECKSH "cp ${EST_FACCSUP} ${DFILT}/${NSTEP}_${IB}_WRK_FACCSUP.dat"
else
    NSTEP=${NJOB}_08
#------------------------------------------------------------------------------
        LIBEL="move EST_FACCSUPF ==> DFILT _WRK_FACCSUP.dat"
        EXECKSH "cp ${EST_FACCSUPF} ${DFILT}/${NSTEP}_${IB}_WRK_FACCSUP.dat"
fi

NSTEP=${NJOB}_10
# Begin sort  ACCEPT
#-----------------------------------------------------------------------------
LIBEL="Sort of FACCSUP file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_08_${IB}_WRK_FACCSUP.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_SOUS_PREFIX 6:2 - 6:2,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        GEMPRMPAY_NF 22:1 - 22:,
        GANPAYORD_NT 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 -40:,
        RETAUTGEN_B 41:1 - 41:,
        ACCTYP_NF 42:1 - 42:EN
/CONDITION SERV ACCTYP_NF = 1 AND ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE SERV
/DERIVEDFIELD CLODAT_YEAR ${CLODAT_YEAR}
/DERIVEDFIELD CLODAT_MTH ${CLODAT_MTH}
/DERIVEDFIELD CLODAT_DAY ${CLODAT_DAY}
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
/REFORMAT SSD_CF,
          ESB_CF,
          CLODAT_YEAR,
          SEPARATEUR,
          CLODAT_MTH,
          SEPARATEUR,
          CLODAT_DAY,
          SEPARATEUR,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_M,
          CED_NF,
          BRK_NF,
          GEMPRMPAY_NF,
          GANPAYORD_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          ZERO,
          SEPARATEUR,
          RETAUTGEN_B,
          ACCTYP_NF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_13
# Begin sort  RETRO
#-----------------------------------------------------------------------------
LIBEL="Sort of FACCSUP file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_08_${IB}_WRK_FACCSUP.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:  EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_SOUS_PREFIX 6:2 - 6:2,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        GEMPRMPAY_NF 22:1 - 22:,
        GANPAYORD_NT 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 -40:,
        RETAUTGEN_B 41:1 - 41:,
        ACCTYP_NF 42:1 - 42:EN
/CONDITION SERV ((ACCTYP_NF = 2 or ACCTYP_NF = 3
                  or ACCTYP_NF = 4 or ACCTYP_NF = 5) AND ${EST_SORT_CONDITION} )
/OUTFILE ${SORT_O}
/INCLUDE SERV
/DERIVEDFIELD CLODAT_YEAR ${CLODAT_YEAR}
/DERIVEDFIELD CLODAT_MTH ${CLODAT_MTH}
/DERIVEDFIELD CLODAT_DAY ${CLODAT_DAY}
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
/REFORMAT SSD_CF,
          ESB_CF,
          CLODAT_YEAR,
          SEPARATEUR,
          CLODAT_MTH,
          SEPARATEUR,
          CLODAT_DAY,
          SEPARATEUR,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_M,
          CED_NF,
          BRK_NF,
          GEMPRMPAY_NF,
          GANPAYORD_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          ZERO,
          SEPARATEUR,
          RETAUTGEN_B,
          ACCTYP_NF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_15
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_010_${IB}_WRK_ECRSRVAPC.dat
RMFIL ${DFILT}/${NJOB}_011_${IB}_WRK_ECRSRVRPC.dat
RMFIL ${DFILT}/${NJOB}_012_${IB}_WRK_ECRSRVACBP.dat
RMFIL ${DFILT}/${NJOB}_013_${IB}_WRK_ECRSRVRCBP.dat
RMFIL ${DFILT}/${NJOB}_08_${IB}_WRK_FACCSUP.dat

NSTEP=${NJOB}_18
# EST_GTEP screen on the subsidary and closing process date
#-----------------------------------------------------------------------------
LIBEL="EST_GTEP ==> SORT GTEP  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTEP} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTEP_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1 1:1 - 40:,
        SSD_CF 1:1 - 1: EN,
	      BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_SOUS_PREFIX 6:2 - 6:2,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION INVENTAIRE TRNCOD_SOUS_PREFIX = "4" AND ${EST_SORT_CONDITION}
/DERIVEDFIELD ZERO "0.000" CHAR 5
/INCLUDE INVENTAIRE
/OUTFILE ${SORT_O}
/REFORMAT  FILLER1,
           ZERO
exit
EOF
SORT

if [ "${CLODAT_MTH}" = "12" ]
then
NSTEP=${NJOB}_19
# Fichier Pericase contenant tous les exercices jusqu'a Année de bilan + 4
#----------------------------------------------------------------------------
LIBEL="Fichier Pericase contenant tous les exercices jusqu'a Année de bilan + 4"
PRG=STAM1550
export ${PRG}_I1=${EST_IARVPERICASE0}
export ${PRG}_O1=${EST_IARVPERICASE4}
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHEY_NF}
exit
EOF
EXECPRG
fi

NSTEP=${NJOB}_20
# Sort of acceptance life perimeters
#-----------------------------------
LIBEL="SORT of IAVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE4} 1000"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERI_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_25
# NB : it is assumed that the perimeter file is already sorted according to
# contract/endorsement number/section/underwriting year/underwriting order
#-----------------------------------------------------------------------------
LIBEL="Current adding establishment code in TL ..."
PRG=ESTM7620
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_PERI_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_18_${IB}_SORT_GTEP_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTEP_O1.dat
EXECPRG

NSTEP=${NJOB}_28
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_18_${IB}_SORT_GTEP_O.dat

NSTEP=${NJOB}_30
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FACCSUP_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_25_${IB}_ESTM7620_GTEP_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAT1_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_40
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of cession operator"
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_GTAT1_O.dat
export ${PRG}_I2=${EST_FCES}
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}

export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

NSTEP=${NJOB}_45
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_GTAT1_O.dat

NSTEP=${NJOB}_50
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTC2303_GTAR100_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      CUR_CF,
      RETOCCYEA_NF,
      RCL_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      CLM_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF
exit
EOF
SORT

NSTEP=${NJOB}_55
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC2303_GTAR100_O.dat

NSTEP=${NJOB}_60
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 1
BALSHEY_NF ${BALSHEY_NF}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG N
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1MAJ_O4.dat
EXECPRG


NSTEP=${NJOB}_65
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_GTAR100_O.dat

#############
# Entries 2 #
#############

NSTEP=${NJOB}_70
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_13_${IB}_SORT_FACCSUP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAT2_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        ACCTYP_NF 43:1 - 43:EN
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      CUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF
/CONDITION RET23 ACCTYP_NF = 2 or ACCTYP_NF = 3
/OUTFILE ${SORT_O}
/INCLUDE RET23
exit
EOF
SORT

NSTEP=${NJOB}_80
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 1
BALSHEY_NF ${BALSHEY_NF}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG N
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_70_${IB}_SORT_GTAT2_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2MAJ_O4.dat
EXECPRG

NSTEP=${NJOB}_85
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_70_${IB}_SORT_GTAT2_O.dat

#############
# Entries 3#
#############


NSTEP=${NJOB}_90
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_13_${IB}_SORT_FACCSUP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRT3_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        ACCTYP_NF 43:1 - 43:EN
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      RETCUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF
/CONDITION RET45 ACCTYP_NF = 4 or ACCTYP_NF = 5
/OUTFILE ${SORT_O}
/INCLUDE RET45
exit
EOF
SORT

NSTEP=${NJOB}_92
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_13_${IB}_SORT_FACCSUP_O.dat


#############
# Entries 4#
#############

#[002]
NSTEP=${NJOB}_95
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CURGTR} 512 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTR_O.dat 512 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_SOUS_PREFIX 6:2 - 6:2,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        ACCTYP_NF 43:1 - 43:EN
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      RETCUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF
/CONDITION OUVERT  TRNCOD_SOUS_PREFIX = "7"  AND ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE OUVERT
exit
EOF
SORT


NSTEP=${NJOB}_105
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FACCSUP_O.dat 1000 1"
SORT_I2=${DFILT}/${NJOB}_25_${IB}_ESTM7620_GTEP_O1.dat
SORT_I3=${DFILT}/${NJOB}_60_${IB}_ESTC2304_GTRRT1_O3.dat
SORT_I4=${DFILT}/${NJOB}_80_${IB}_ESTC2304_GTRRT2_O3.dat
SORT_I5=${DFILT}/${NJOB}_90_${IB}_SORT_GTRT3_O.dat
SORT_I6=${DFILT}/${NJOB}_95_${IB}_SORT_CURGTR_O.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVGT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_108
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_FACCSUP_O.dat
RMFIL ${DFILT}/${NJOB}_25_${IB}_ESTM7620_GTEP_O1.dat
RMFIL ${DFILT}/${NJOB}_60_${IB}_ESTC2304_GTRRT1_O3.dat
RMFIL ${DFILT}/${NJOB}_80_${IB}_ESTC2304_GTRRT2_O3.dat
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_GTRT3_O.dat
RMFIL ${DFILT}/${NJOB}_95_${IB}_SORT_CURGTR_O.dat

NSTEP=${NJOB}_110
#Retrocession and Acceptance Data Exchange
#------------------------------------------------------------------------------
LIBEL="Retrocession and Acceptance Data Exchange"
PRG=ESTC2033
export ${PRG}_I1=${DFILT}/${NJOB}_105_${IB}_SORT_ECRSRVGT.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSRVGT_O.dat
EXECPRG

NSTEP=${NJOB}_112
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_105_${IB}_SORT_ECRSRVGT.dat

NSTEP=${NJOB}_115
# Sort of TL, merged by Contrat, Section and U/W Year
#------------------------------------------------------------------------------
LIBEL="Sort of TL, merged by Contrat, Section and U/W Year"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC2033_ECRSRVGT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVGT_O1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 -  1: EN,
        CTR_NF 8:1 - 8:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_118
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_110_${IB}_ESTC2033_ECRSRVGT_O.dat

NSTEP=${NJOB}_120
#Introduction of Conversion and Accumulated Transaction Codes
#[004] ajout de CLODAT_D
#------------------------------------------------------------------------------
LIBEL="Introduction of Conversion and Accumulated Transaction Codes"
PRG=ESTM7621
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CLODAT_D  ${CLODAT_D}
BALSHTYEA_NF  ${BALSHEY_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1=${EST_IARVPERICASE0}
export ${PRG}_I1=${EST_IARVPERICASE4}
export ${PRG}_I2=${DFILT}/${NJOB}_115_${IB}_SORT_ECRSRVGT_O1.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSRVGT_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSRVGTB1_O2.dat
EXECPRG

NSTEP=${NJOB}_122
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_115_${IB}_SORT_ECRSRVGT_O1.dat

NSTEP=${NJOB}_125
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT gt"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTM7621_ECRSRVGT_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVGT_O1.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVGT_O2.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1 1:1 - 57:,
        FILLER2 59:1 - 67:,
        ACY_NF 14:1 - 14: EN,
        ACMTRS4_NT 43:4 - 43:,
        TRNCOD1_CF 6:1 - 6:1
/COPY
/DERIVEDFIELD PC_FIELD "PCECR~"
/DERIVEDFIELD CBN_FIELD "CBN~"
/CONDITION ACY_CBN (( ACY_NF < `expr ${BALSHEY_NF} - ${LIF_ACY_MIN}`) OR ((TRNCOD1_CF = '2' OR TRNCOD1_CF = '4') AND (ACY_NF = `expr ${BALSHEY_NF} - 5` AND ACMTRS4_NT = "3" ))) 
/CONDITION ACY_PC (( ACY_NF <= `expr ${BALSHEY_NF} + ${LIF_ACY_MAX}`  AND ACY_NF >= `expr ${BALSHEY_NF} - ${LIF_ACY_MIN}` )
                  OR((TRNCOD1_CF = '2' OR TRNCOD1_CF = '4') AND ( ACY_NF = `expr ${BALSHEY_NF} - 5`   AND ACMTRS4_NT = "3" )))
/OUTFILE ${SORT_O}
/INCLUDE ACY_CBN
/REFORMAT
           FILLER1,
           CBN_FIELD,
           FILLER2
           
/OUTFILE ${SORT_O2}
/INCLUDE ACY_PC
/REFORMAT
           FILLER1,
           PC_FIELD,
           FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_126
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT gt"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_125_${IB}_SORT_ECRSRVGT_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_125_${IB}_SORT_ECRSRVGT_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVGT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF      8:1 -  8: ,
        SEC_NF     10:1 - 10: EN ,
        UWY_NF     11:1 - 11: EN ,
        ACY_NF     14:1 - 14: EN 
/KEY CTR_NF,SEC_NF,UWY_NF,ACY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_128
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_120_${IB}_ESTM7621_ECRSRVGT_O1.dat

NSTEP=${NJOB}_130
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT gt"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTM7621_ECRSRVGTB1_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVGTB1_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1 1:1 - 57:,
        FILLER2 59:1 - 67:
/COPY
/DERIVEDFIELD CBP_FIELD "CBPECR~"
/OUTFILE ${SORT_O}
/REFORMAT
           FILLER1,
           CBP_FIELD,
           FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_132
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_120_${IB}_ESTM7621_ECRSRVGTB1_O2.dat

NSTEP=${NJOB}_135
#  Accounting acceptation and cession data separation
#----------------------------------------------------------------------------
LIBEL="Accounting acceptation and cession data separation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_126_${IB}_SORT_ECRSRVGT_O.dat 1000 1"
if [ "${EST_ESID1520_COND1}" = "Y" ]
then
  SORT_I2="${DFILT}/${NJOB}_02_${IB}_SORT_ECRSRVAPC_O.dat 1000 1"
  SORT_I3="${DFILT}/${NJOB}_03_${IB}_SORT_ECRSRVRPC_O.dat 1000 1"
fi
SORT_O=${EST_ECRSRVAPC}
SORT_O2=${EST_ECRSRVRPC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELD	TRNCOD1_CF 6:1 - 6:1
/CONDITION ACCEPT (TRNCOD1_CF = '1' OR TRNCOD1_CF = '3')
/COPY
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE ACCEPT
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT ACCEPT
exit
EOF
SORT

NSTEP=${NJOB}_140
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_125_${IB}_SORT_ECRSRVGT_O1.dat
RMFIL ${DFILT}/${NJOB}_125_${IB}_SORT_ECRSRVGT_O2.dat
RMFIL ${DFILT}/${NJOB}_126_${IB}_SORT_ECRSRVGT_O.dat

NSTEP=${NJOB}_145
#  Accounting acceptation and cession data separation
#----------------------------------------------------------------------------
LIBEL="Accounting acceptation and cession data separation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_SORT_ECRSRVGTB1_O.dat 1000 1"
if [ "${EST_ESID1520_COND1}" = "Y" ]
then
  SORT_I2="${DFILT}/${NJOB}_05_${IB}_SORT_ECRSRVACBP_O.dat 1000 1"
  SORT_I3="${DFILT}/${NJOB}_06_${IB}_SORT_ECRSRVRCBP_O.dat 1000 1"
fi
SORT_O=${EST_ECRSRVACBP}
SORT_O2=${EST_ECRSRVRCBP}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELD	TRNCOD1_CF 6:1 - 6:1
/CONDITION ACCEPT (TRNCOD1_CF = '1' OR TRNCOD1_CF = '3')
/COPY
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE ACCEPT
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT ACCEPT
exit
EOF
SORT


NSTEP=${NJOB}_175
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_130_${IB}_SORT_ECRSRVGTB1_O.dat
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_PERI_O.dat

NSTEP=${NJOB}_155
# Begin rm
#----------------------------------------------------------------------------
LIBEL="Delete temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

