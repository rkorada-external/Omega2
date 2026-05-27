#! /bin/ksh
#===============================================================================
# application name               : AE and Profitability rapport
# source name                    : ESDC0022.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 10/11/2025
# author                         : S.Behague
# specifications reference       :
#                                :
#-------------------------------------------------------------------------------
# modifications chronology       :
# [001] - 10/11/2025 S.Behague :US5609: PROD Report- job that generates closing report should be migrated in PRD - Spira 111994
# [002] - 22/11/2025 S.Behague :US7785: SAS/Omega interface - Improvement
#===============================================================================

# call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd


# Job Initialization variables
#----------------------------------------------------------------------------

# Job Initialisation
#-------------------
JOBINIT

if [ "X${PAI_FICHIER_CR_I17G}" != "X" ]
then
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="PAI_FICHIER_CR_I17G file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PAI_FICHIER_CR_I17G} 2000 1"
SORT_O="${DFILI}/PAI_FICHIER_CR_I17G.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF         1:1 -  1:EN,
        ESB_CF         2:1 -  2:EN,
        NOMFIC         4:1 -  4:,
        OKKO           3:1 -  3:,
        TOTAL_LINES    6:1 -  6:,
        KO_LINES       7:1 -  7:,
        OK_LINES       8:1 -  8:
/KEYS SSD_CF, ESB_CF, NOMFIC, OKKO, TOTAL_LINES, KO_LINES, OK_LINES
/SUM /STABLE
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, OKKO, NOMFIC, TOTAL_LINES, KO_LINES, OK_LINES
exit
EOF
SORT
fi

if [ "X${PAI_FICHIER_CR_I17P}" != "X" ]
then
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="PAI_FICHIER_CR_I17P file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PAI_FICHIER_CR_I17P} 2000 1"
SORT_O="${DFILI}/PAI_FICHIER_CR_I17P.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF         1:1 -  1:EN,
        ESB_CF         2:1 -  2:EN,
        NOMFIC         4:1 -  4:,
        OKKO           3:1 -  3:,
        TOTAL_LINES    6:1 -  6:,
        KO_LINES       7:1 -  7:,
        OK_LINES       8:1 -  8:
/KEYS SSD_CF, ESB_CF, NOMFIC, OKKO, TOTAL_LINES, KO_LINES, OK_LINES
/SUM /STABLE
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, OKKO, NOMFIC, TOTAL_LINES, KO_LINES, OK_LINES
exit
EOF
SORT
fi

if [ "X${PAI_FICHIER_CR_I17L}" != "X" ]
then
NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="PAI_FICHIER_CR_I17L file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${PAI_FICHIER_CR_I17L} 2000 1"
SORT_O="${DFILI}/PAI_FICHIER_CR_I17L.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF         1:1 -  1:EN,
        ESB_CF         2:1 -  2:EN,
        NOMFIC         4:1 -  4:,
        OKKO           3:1 -  3:,
        TOTAL_LINES    6:1 -  6:,
        KO_LINES       7:1 -  7:,
        OK_LINES       8:1 -  8:
/KEYS SSD_CF, ESB_CF, NOMFIC, OKKO, TOTAL_LINES, KO_LINES, OK_LINES
/SUM /STABLE
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, OKKO, NOMFIC, TOTAL_LINES, KO_LINES, OK_LINES
exit
EOF
SORT
fi


# END Of Job
#------------------------------------------------------------------------------
JOBEND

