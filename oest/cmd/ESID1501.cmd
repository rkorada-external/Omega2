#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Fusion perimetre retrocession
# nom du script SHELL		: ESID1501.cmd
# revision			: $Revision:   1.6  $
# date de creation		: 08/09/97
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description 
#   Mix retrocession perimeters
#
# job launched by ESID1500.cmd
#   Output file sort  ${EST_IRDVPERICASE0} 1000 1 
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 17/11/2014 R. Cassis   :spot:27747 Multi currency on Flat premium and Deposit premium - Reformat Pericases
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT


NSTEP=${NJOB}_00
#Last version of ESID1500 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_IRDVPERICASE0}`/${PCH}ESID1500_IRDVPERICASE0*.dat"
RMFIL "  `dirname ${EST_ORDVPERICASE0}`/${PCH}ESID1500_ORDVPERICASE0*.dat"

####################################################
# Mix of retrocession life and non-life perimeters #
####################################################

#[[001]
NSTEP=${NJOB}_05
# Mix of retrocession life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IRDPERICASE0 and IRVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 1000 1"
SORT_I2="${EST_IRVPERICASE0} 1000 1"
SORT_O="${EST_IRDVPERICASE0} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
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

#[[001]
NSTEP=${NJOB}_10
# Mix of retrocession life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of ORDPERICASE0 and ORVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_ORDPERICASE0} 1000 1"
SORT_I2="${EST_ORVPERICASE0} 1000 1"
SORT_O="${EST_ORDVPERICASE0} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
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



JOBEND
