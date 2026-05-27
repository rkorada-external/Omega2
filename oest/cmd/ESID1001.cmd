#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Fusion des perimetres acceptation
# nom du script SHELL		: ESID1001.cmd
# revision			: $Revision: 1.2 $
# date de creation		: 05/09/97
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Mix acceptance perimeters
#
# job launched by ESID1000.cmd
# Output file sort ${EST_IADVPERICASE0} OVERWRITE 1000 1  
#-----------------------------------------------------------------------------
# historique des modifications
#_________________
#MODIFICATION    [001]
#Auteur:         D.GATIBELZA
#Date:           23/04/2010
#Version:        10.1
#Description:    ESTVIE18710 Alimentation du MGTAR lors de la comptabilisation de l'arrêté pour la réallocation asie
#[002] 07/05/2012 Roger CASSIS   :spot:23802 - Gzip fichier pour optimisation Solvency
#[003] 17/11/2014 R. Cassis   :spot:27747 Multi currency on Flat premium and Deposit premium - Reformat Pericases
#[003] 30/10/2019 M. NAJI       :spot:81838 - Commenter le zip de EST_IADPERICASE_ENTIER0
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters



NSTEP=${NJOB}_00
#Last version of ESID1000 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_IADVPERICASE0}`/${PCH}ESID1000_IADVPERICASE0*.dat"
RMFIL "  `dirname ${EST_OADVPERICASE0}`/${PCH}ESID1000_OADVPERICASE0*.dat"

#[003]
NSTEP=${NJOB}_05
# Mix of acceptance life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IADPERICASE0 and IAVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_I2="${EST_IAVPERICASE0} 1000 1"
SORT_O="${EST_IADVPERICASE0} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_10
# Mix of acceptance life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IADPERICASE0 and IAVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OADPERICASE0} 1000 1"
SORT_I2="${EST_OAVPERICASE0} 1000 1"
SORT_O="${EST_OADVPERICASE0} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

#[001] [003]
NSTEP=${NJOB}_20
# Perimetre entier
#-----------------------------------------------------------------------------
LIBEL="Current mix of IADPERICASE_ENTIER0 and IAVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_ENTIER0} 1000 1"
SORT_I2="${EST_IAVPERICASE0} 1000 1"
SORT_O="${EST_IADVPERICASE_ENTIER0} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


#[002]
NSTEP=${NJOB}_21
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${EST_IADPERICASE_ENTIER0}.gz"

#[002]
#[003]
NSTEP=${NJOB}_22
# gzip du fichier pour optimisation
#------------------------------------------------------------------------------
LIBEL="gzip du fichier ${EST_IADPERICASE_ENTIER0} pour optimisation"
EXECKSH_MODE=P
#EXECKSH "gzip ${EST_IADPERICASE_ENTIER0}"

JOBEND
