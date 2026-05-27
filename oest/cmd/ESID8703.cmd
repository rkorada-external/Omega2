ISQL
#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Get ESB from Pericase for FTECLEDA"
# nom du script SHELL           : ESID8703.cmd
# revision                      : $Revision: 1.1.1.1 $
# date de creation              : 18/06/2021
# auteur                        : M.NAJI
# references des specifications : spot 5085
#-----------------------------------------------------------------------------
# description
#   Update estimates
#
# job launched by ESPD88300.cmd
#-----------------------------------------------------------------------------
# historique des modifications
# 18/06/2021   SPIRA 97241 	: Get ESB from Pericase for FTECLEDA from EST_OIADVPERICASE
# 30/06/2022   SPIRA 104337 : JYP/Flo : update ESB for retro in FTECLEDA 
# 21/11/2022   JYP/Flo/TD   :SPIRA 107843 do NOT update ESB for retro in FTECLEDA 
#_________________

#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# Job Initialisation
JOBINIT

#[25]
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Get ESB from Pericase for FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        all_cols1        1:1 - 118:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT 
/INFILE ${EST_OIADVPERICASE} 1000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT 
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
       ,rightside:PER_ESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Replace ESB from Pericase to FTECLEDASO Cumul"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA.dat 1000 1 "
SORT_O="${EST_FTECLEDA_EBS} 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -   1:,
        ESB_CF           2:1 -   2:,
        TRNCOD1_CF       6:1 -   6:1,
        CTR_NF           8:1 -   8:,
        END_NT           9:1 -   9:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        UW_NT           12:1 -  12:,
        all_cols1        3:1 - 118:,
        PER_ESB_CF     119:1 - 119:
/CONDITION blanc PER_ESB_CF = "" OR TRNCOD1_CF = "2" OR TRNCOD1_CF = "4"
/DERIVEDFIELD PER2_ESB_CF if blanc then ESB_CF else PER_ESB_CF
/OUTFILE   ${SORT_O}
/REFORMAT SSD_CF, PER2_ESB_CF, all_cols1
exit
EOF
SORT


JOBEND
