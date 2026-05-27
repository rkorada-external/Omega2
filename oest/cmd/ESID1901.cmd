#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE      Annulations
# nom du script SHELL		: ESID1901.cmd
# revision			        : $Revision: 1.2 $
# date de creation		    : 05/09/97
# auteur			        : CGI
# references des specifications	: ESCOM2F.doc
#-----------------------------------------------------------------------------
# description   Reverse of entries generation
# job launched by ESID1900.cmd
# Launch the C Program ESTM7601
# Output file sort ${DFILT}/${NSTEP}_${IB}_SORT_IGTA_O.dat
#-----------------------------------------------------------------------------
# historique des modifications
# 30/06/00		ANB	Ajout tri sur etablissement pour pb Scor vie Montreal
#				Pb à revoir plus completement après 30/06
# 19/10/09		Bookings in Q4 on 20-11 : perte du code etablissement dans les ecritures de reverse
#               ajout des criteres de tri annee, mois bilan au step10 avant l'etablissement
#               ajout des criteres de tri annee, mois bilan et etablissement au step20 en dernier
# 22/10/09		Bookings in Q4 on 20-11 : perte du code etablissement dans les ecritures de reverse
#               ajout de l'etablissement au tri step10 avant le poste comptable
#               ajout de l'etablissement au tri step20 avant le poste comptable
#               ajout de l'etablissement au tri step30 avant le poste comptable
#               annule et remplace les modif du 19/10/2009
#---------------
#MODIFICATION   : [004]
#Auteur         : D.GATIBELZA
#Date           : 07/02/2011
#Version        : 11.1
#Description    : 1GL
#[05] 14/03/2011 R. CASSIS  :spot:21408 - modification des fichiers au format GT 41 col. + 14 vides
#[06] 03/12/2015 E. CHATAIN :spot:29066 formatage du fichier GT 
#[07] 25/05/2016 Florent    :spot:30646 vidage des champs SAP (step 26)
#[08] 19/01/2017 Florent    :spira:58733 lors de l’annulation des trimestres précédents tenir compte de RETARDRETINT_B et du TRN_NT dans la clé
#[09] 01/09/2020 R. cassis  :spira:88186 Archivage fichiers d'annulation trimestriels
#[10] 09/09/2020 R. cassis  :spira:66261 Add SSD_CF key in SORT process
#[11] 15/12/2021 R. cassis  :spira:101117-98240 On ne gere plus l'annulation des postes EBS dans les traitements IFRS4 - ajout I17PRDCOD_CT dans cle de tri
#[12] 26/06/2023 JYP        :spira:109764 update NEWCOLS1_NF=empty
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
CLODAT_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3


###########################
# Acceptance cancellation #
###########################

NSTEP=${NJOB}_00
#Last version of ESID1900 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_DLAGTAA0}`/${PCH}ESID1900_DLAGTAA0*${CLODAT_D}*.dat
 `dirname ${EST_DLAGTAR0}`/${PCH}ESID1900_DLAGTAR0*${CLODAT_D}*.dat
 `dirname ${EST_DLAGTR0}`/${PCH}ESID1900_DLAGTR0*${CLODAT_D}*.dat
 `dirname ${EST_IGTAA0}`/${PCH}ESID1900_IGTAA0*${CLODAT_D}*.dat
 `dirname ${EST_IGTAR0}`/${PCH}ESID1900_IGTAR0*${CLODAT_D}*.dat
 `dirname ${EST_IGTR0}`/${PCH}ESID1900_IGTR0*${CLODAT_D}*.dat"


#[11]
#[004] On utilise le fichier IGTAA00 à la place des CURGTA et GTA
NSTEP=${NJOB}_05
#Merge of CURGTA and GTA
#-----------------------------------------------------------------------------
LIBEL="Current merge of CURGTA of GTA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#[004] SORT_I=${EST_CURGTA}
#[004] SORT_I2=${EST_GTA}
SORT_I="${EST_IGTAA00} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IGTA_O.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY_NF       3:1 - 3: EN,
        BALSHRMTH_NF     4:1 - 4: EN,
        TRNCOD2_CF       6:2 - 6:2
/CONDITION LIGNECPT ( ${BALSHTYEA_NF} > BALSHEY_NF or ( ${BALSHTYEA_NF} EQ BALSHEY_NF and ${BALSHTMTH_NF} >= BALSHRMTH_NF ) )
                    AND ("AEJ" NC TRNCOD2_CF)
/INCLUDE LIGNECPT
/COPY
exit
EOF
SORT

#[10] [11]
NSTEP=${NJOB}_10
#Sort and screen of IGTA on pure Acceptance contracts
#-----------------------------------------------------------------------------
LIBEL="Current sort and screen of IGTA on pure Acceptance contracts ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_IGTA_O.dat 1000 1"
SORT_O="${EST_IGTAA0} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
	      CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRN_NT     56:1 - 56:,
        RETARDRETINT_B   62:1 - 62:,
	      GAAPCOD_NT 64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT	
/CONDITION TRNCOD TRNCOD1_CF eq "1" or TRNCOD1_CF EQ "3"
/INCLUDE TRNCOD
exit
EOF
SORT

NSTEP=${NJOB}_15
#Cancellation of the previous closing period in IGTAa
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in IGTAa..."
PRG=ESTM7601
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IGTAA0}
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_DLAGTAA0.dat"
EXECPRG

#[005] Reduction au format 41
#[006] Formatage du fichier GT
NSTEP=${NJOB}_16
#Reduction of CURGTA
#-----------------------------------------------------------------------------
LIBEL="reset to blanc 15 cols from SAP/ONEGL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTM7601_DLAGTAA0.dat 1000 1"
SORT_O="${EST_DLAGTAA0}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS FORMAT_41     1:1 - 41:,
        FILLER56to62 56:1 - 62:,
		COLS_END    64:1 - 71:  
/DERIVEDFIELD BLANK_14_CHAMPS 14"~"
/DERIVEDFIELD NEWCOLS1_NF "~"
/OUTFILE ${SORT_O}
/REFORMAT FORMAT_41,BLANK_14_CHAMPS,FILLER56to62,NEWCOLS1_NF,COLS_END
exit
EOF
SORT

#[10] [11]
NSTEP=${NJOB}_20
#Sort and screen on IGTA on Retrocession contracts by Acceptance
#-----------------------------------------------------------------------------
LIBEL="Current sort and screen on IGTA on Retrocession contracts by Acceptance ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_IGTA_O.dat 1000 1"
SORT_O="${EST_IGTAR0} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRNCOD2_CF 6:2 - 6:2,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRN_NT 56:1 - 56:,
        RETARDRETINT_B   62:1 - 62:,
        GAAPCOD_NT 64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/CONDITION TRNCOD TRNCOD1_CF EQ "2" or TRNCOD1_CF EQ "4"
                  AND ("AEJ" NC TRNCOD2_CF)
/INCLUDE TRNCOD
exit
EOF
SORT

NSTEP=${NJOB}_25
#Cancellation of the previous closinf period in IGTAr
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closinf period in IGTAr ..."
PRG=ESTM7601
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IGTAR0}
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_DLAGTAR0.dat"
EXECPRG

NSTEP=${NJOB}_26
#-----------------------------------------------------------------------------
LIBEL="reset to blanc 15 cols from SAP/ONEGL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_ESTM7601_DLAGTAR0.dat 1000 1"
SORT_O="${EST_DLAGTAR0}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS FORMAT_41     1:1 - 41:,
        FILLER56to62 56:1 - 62:,
		COLS_END    64:1 - 71: 		
/DERIVEDFIELD BLANK_14_CHAMPS 14"~"
/DERIVEDFIELD NEWCOLS1_NF "~"
/OUTFILE ${SORT_O}
/REFORMAT FORMAT_41,BLANK_14_CHAMPS,FILLER56to62,NEWCOLS1_NF,COLS_END
exit
EOF
SORT


#############################
# Retrocession cancellation #
#############################

#[10] [11]
NSTEP=${NJOB}_30
#Merge of of CURGTR and GTR
#-----------------------------------------------------------------------------
LIBEL="Current merge of CURGTR and GTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CURGTR} 1000 1"
SORT_I2="${EST_GTR} 1000 1"
SORT_O="${EST_IGTR0} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRNCOD2_CF 6:2 - 6:2,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRN_NT 56:1 - 56:,
        RETARDRETINT_B   62:1 - 62:,
        GAAPCOD_NT 64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:

/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT	
/CONDITION TRNCOD (TRNCOD1_CF EQ "2" or TRNCOD1_CF EQ "4") and ( ${BALSHTYEA_NF} > BALSHEY_NF or ( ${BALSHTYEA_NF} EQ BALSHEY_NF and ${BALSHTMTH_NF} >= BALSHRMTH_NF ) )
                  AND ("AEJ" NC TRNCOD2_CF)
/INCLUDE TRNCOD
exit
EOF
SORT

NSTEP=${NJOB}_35
#Cancellation of the previous closing period in IGTR
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in IGTR ..."
PRG=ESTM7601
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IGTR0}
export ${PRG}_O1="${EST_DLAGTR0}"
EXECPRG

#[09]
mois=`echo ${CLODAT_D} | cut -c5,6`
if [ "${mois}" = "03" -o "${mois}" = "06" -o "${mois}" = "09" -o "${mois}" = "12" ]
then
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> Archiving quaterly files"
	gzip -c ${EST_DLAGTAA0}  > ${DARCH}/${ENV_PREFIX}_ESID1900_DLAGTAA0_${CLODAT_D}.dat.gz
	gzip -c ${EST_DLAGTAR0}  > ${DARCH}/${ENV_PREFIX}_ESID1900_DLAGTAR0_${CLODAT_D}.dat.gz
	gzip -c ${EST_DLAGTR0}   > ${DARCH}/${ENV_PREFIX}_ESID1900_DLAGTR0_${CLODAT_D}.dat.gz
	ECHO_LOG "#========================================================================="
fi

JOBEND
