#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - INVENTAIRE
#                                  Extraction des tables acceptation dommages et
#                                  retrocession
# nom du script SHELL            : ESID0062.cmd
# revision                       : $Revision:   1.10  $
# date de creation               : 26/09/97
# auteur                         : CGI
# references des specifications  :
#-----------------------------------------------------------------------------
# Description
#   Extracting tables
#-----------------------------------------------------------------------------
# historique des modifications
#   06/01/2000  O.GIRAUX: step 80 Generation du fichier FACCTRAI0
#   12/08/2004  Par M. DJELLOULI  Modification Ventilation Non Prop
#                                              Ajout du STEP_85 (Procédure d'extraction BRET..PsTVENTNP_01)
#   21/02/2006  M. DJELLOULI  SPOT 12055 - Version 6.1 - Modification Ventilation Non Prop
#                             Ajout du STEP_90 (Procédure d'extraction BRET..PsTVENTNP_07)
#[004] 07/05/2012 R. Cassis   :spot:23802  Ajout extraction de fichiers pour Solvency
#[005] 20/01/2015 Franck Maragnes:spot:28140 - Generation du fichier FTHRHLDUWY necessaire à la fonction calculExerciceSeuil
#[006] 25/01/2015 R. Cassis   :spot:28483  Move generation of retro account file (step 65) to job ESID0110
#[007] 12/06/2015 SAS, spot: 28694 ajout du step 15A pour charger la table TSEGEST pour la vie
#[008] 24/06/2015 R. Cassis   :spot:28694 - La creation de FVSEGEST se fait dans le ESID0065 pas le ESID0062
#[009] 12/06/2015 SAS, spot: 28694 ajout du step 15A et 15B pour charger la table TSEGEST pour la vie
#[010] 28/08/2018 JYP : IFRS17 req 10.6 : Upgrade Loss Ratio : now 2 segtyps can be extracted, new parameter is added calling PsSECTION_13 (V for IFRS) 
#[011] 08/04/2019 R. Cassis   :spira:65656 Ajout parametre PRS_CF a 710 pour filtrer sur les postes IFRS4 et le ICLODAT_D qui est utilise qu'en EBS
#[011] 03/03/2021 R. Cassis   :spira:92356 Extraction dans TFAMPRMD des contrats avec echeances de paiement < la fin de periode cedante du mois bilan en cours
#[012] 29/06/2021 R. Cassis   :spira:97398: Suppression extraction SEGEST_SOLVENCY car extrait dans ESPD0061
#[012] 22/11/2021 R. Cassis   :spira:100493 Remplacement PERTYP_CT par PARM_PERTYP_CT
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters
SEGTYP_CT=$1
CRE_D=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CLODAT_D=$5
SEGTYP_CT=$6
#PERTYP_CT=$7

#Fixed parameter
OPTION=I


NSTEP=${NJOB}_15
#Download of TSEGEST table with screen on the subsidary and the segment type
#-----------------------------------------------------------------------------
LIBEL="Download of TSEGEST in progress ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FSEGEST0}
BCP_QRY="execute BEST..PsSECTION_13 '${OPTION}', '${SEGTYP_CT}' , 'V' "
BCP


#[007]
NSTEP=${NJOB}_15A
#Download of TSEGEST table with screen on the subsidary and the segment type
#-----------------------------------------------------------------------------
LIBEL="Download of TSEGESTlife in progress ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FVSEGEST0}
BCP_QRY="execute BEST..PsFVSEGEST_01 '${OPTION}', '${SEGTYP_CT}'"
BCP

NSTEP=${NJOB}_15B
# EST_FVSEGEST0
#-----------------------------------------------------------------------------
LIBEL="EST_FVSEGEST0 ==> EST_FVSEGEST ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FVSEGEST0} 1000 1"
SORT_O="${EST_FVSEGEST} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
      SSD_CF    1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

##[004] [012] Pas utilisé en mode IFRS4
#NSTEP=${NJOB}_16
##Download of TSEGEST table with screen on the subsidary and the segment type
##-----------------------------------------------------------------------------
#LIBEL="Download of TSEGEST for Solvency in progress ..."
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${EST_FSEGEST_SOLVENCY0}
#BCP_QRY="execute BEST..PsSECTION_13 '${OPTION}', 'S' "
#BCP

NSTEP=${NJOB}_20
#Download of TLABOCY table with screen on the subsidary and on the segment type
#-----------------------------------------------------------------------------
LIBEL="Download of TLABOCY table in progress ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FLABOCY0}
BCP_QRY="execute BEST..PsSECTION_14 '${SEGTYP_CT}'"
BCP

NSTEP=${NJOB}_25
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Transfer of the table TCTREST in file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCTREST0}
BCP_QRY="execute BEST..PsSECTION_16 710, '${CLODAT_D}'"   # [011]
BCP

NSTEP=${NJOB}_35
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Deposit Conditions"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FDEPOSIT0}
BCP_QRY="execute BEST..PsDEPOSIT_01"
BCP

NSTEP=${NJOB}_40
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Interest Rate on Deposits"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FINTWIT}
BCP_QRY="execute BEST..PsINTWIT_01"
BCP

NSTEP=${NJOB}_45
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Placement Deposit Conditions"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPFUNWIT0}
BCP_QRY="execute BEST..PsPFUNWIT_01"
BCP

NSTEP=${NJOB}_50
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Placement Deposit Interest Rates"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPINTWIT0}
BCP_QRY="execute BEST..PsPINTWIT_01"
BCP

NSTEP=${NJOB}_55
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of retro outsdanding 100% transactions"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FOUTTRAA0}
BCP_QRY="execute BEST..PsOUTTRAA_01 '${CLODAT_D}'"
BCP

NSTEP=${NJOB}_60
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of retro outsdanding computed and input transactions"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FOUTTRAI0}
BCP_QRY="execute BEST..PsOUTTRAI_01 '${CLODAT_D}'"
BCP

#[006]
#NSTEP=${NJOB}_65
## Begin bcp
##------------------------------------------------------------------------------
#LIBEL="Current Generation of retro accounted 100% transactions"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${EST_FACCTRAA0}
#BCP_QRY="execute BEST..PsACCTRAA_01 ${BALSHTYEA_NF}"
#BCP

NSTEP=${NJOB}_70
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of commuted transactions splitted"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCMUSPLI0}
BCP_QRY="execute BEST..PsCMUSPLI_01"
BCP

NSTEP=${NJOB}_75
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of temporary commuted transactions splitted"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCMUSPLIT0}
BCP_QRY="execute BEST..PsCMUSPLIT_01"
BCP

NSTEP=${NJOB}_77
# Begin bcp
#------------------------------------------------------------------------------
LIBEL=""
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FACCPAR0}
BCP_QRY="execute BEST..PsACCPAR_02"
BCP

NSTEP=${NJOB}_80
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of FACCTRAI0"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FACCTRAI0}
BCP_QRY="execute BEST..PsACCTRAI_02 ${BALSHTYEA_NF}"
BCP

# MDJ 12/08/2004
NSTEP=${NJOB}_85
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of FTVENTNP"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FTVENTNP}
BCP_QRY="execute BRET..PsTVENTNP_01"
BCP

# MDJ - 21/02/2006 - SPOT 12055
NSTEP=${NJOB}_90
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of FTVENTNPHIST"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FTVENTNPHIS}
BCP_QRY="execute BRET..PsTVENTNP_07"
BCP

# FMA - 20/01/2015 SPOT 28140 [005]
NSTEP=${NJOB}_95
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of FTHRHLDUWY"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${EST_FTHRHLDUWY}
BCP_QRY="BEST..PsTHRHLDUWY_01"
BCP

if [ "${PARM_PERTYP_CT}" = "H" ]
then

	#[011]
	NSTEP=${NJOB}_100
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Current Generation of FTFAMPRMDDUES"
	BCP_WAY="OUT"; BCP_VER="+"
	BCP_O=${EST_FTFAMPRMDDUES}
	BCP_QRY="BFAC..PsFAMPRMD_10 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
	BCP

fi

JOBEND
                     
