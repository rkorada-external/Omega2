#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Filtre de tous les fichiers
# nom du script SHELL		: ESID0562.cmd
# revision			: $Revision:   1.8  $
# date de creation		: 05/09/97
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Filtering files
#
#
#   Output file sort   ${EST_OIADVPERICASE}
#	               ${EST_OIRDVPERICASE} 	       	
#
#
#
# job launched by ESID0560.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 29/06/2012 R. CASSIS     :spot:23802 - Gzip fichiers pour optimisation
#[002] 30/10/2019 M. NAJI       :spot:81838 - Commenter le zip de EST_FACCTRAA0
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters

CLODAT_D=$1


#####################
# Perimeters screen #
#####################

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Merge of OADVPERICASE and IADVPERICASE Files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_I2="${EST_OADVPERICASE} OVERWRITE 1000 1"
SORT_O="${EST_OIADVPERICASE} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
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

NSTEP=${NJOB}_17
#-----------------------------------------------------------------------------
LIBEL="Merge of ORDVPERICASE0 and IRDVPERICASE0 Files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE} 1000 1"
SORT_I2="${EST_ORDVPERICASE} OVERWRITE 1000 1"
SORT_O="${EST_OIRDVPERICASE} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
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

#[001]
#[002]
NSTEP=${NJOB}_20
# gzip du fichier pour optimisation
#------------------------------------------------------------------------------
LIBEL="gzip fichiers pour optimisation"
EXECKSH_MODE=P
RMFIL "${EST_DTSTATGTAA0}.gz"
RMFIL "${EST_FACCTRAA0}.gz"
RMFIL "${EST_FCMUSPLI0}.gz"
#
#EXECKSH "gzip ${EST_DTSTATGTAA0}"
#EXECKSH "gzip ${EST_FACCTRAA0}"
#EXECKSH "gzip ${EST_FCMUSPLI0}"

JOBEND
