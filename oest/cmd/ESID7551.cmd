#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
# nom du script SHELL		: ESID7551.cmd
# revision			: $Revision: 1.3 $
# date de creation		: 10/1997
# auteur			: CGI (BOURDAILLET LE 14/09/1998)
# references des specifications	:
#-----------------------------------------------------------------------------
# description : Accumulation of facultative premium
#
# job launched by ESID7550.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#---------------------------------------------------------------
#modifications chronology:
#   <jj/mm/aaaa>   <author>    <description de la modification>
#
#   <29/07/2002>   <O. ARIK>   <prise en compte d'1 nouveau poste :
#                               TRNCOD_CF = "11107200">
#---------------
#MODIFICATION   : [002]
#Auteur         : D.GATIBELZA
#Date           : 02/04/2010
#Version        : 10.1
#Description    : ESTDOM18961 French Cat Nat Levy  the use of the code Fac Reinstatement premiums to record our Cat Nat Premiums in order that we can pay the Levy properly
#[002] 29/09/2010 Roger Cassis :spot:20225 - Ajout etape de Mise à jour de l'établissement pour les contrats transférés qui ont l'ancien etablissement
#[003] 08/08/2013 R. CASSIS    :spot:25427 - Ajout jointure table tbatchssd pour Omega2
#[004] 12/09/2013 Florent      :spot:25427 Closing batches adaptation for centralization, maj step 15
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# INPUT FILES
# EST_ARCSTATGTA

NSTEP=${NJOB}_05
#Simple part TL file sort and accumulation before printing
#[009] Ajout "11104100" pour le fichier *DLGTAFACPRE_O3.dat
#-----------------------------------------------------------------------------
LIBEL="Sort and accumulation "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_ARCSTATGTA} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        CUR_CF 18:1 - 18:,
        TRNCOD_CF 6:1 - 6:,
        AMT_M 19:1 - 19: EN 20/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      CUR_CF
/CONDITION TRNCOD TRNCOD_CF EQ "11104000" OR TRNCOD_CF EQ "11108000" OR TRNCOD_CF EQ "11107200" OR TRNCOD_CF EQ "11107000" OR TRNCOD_CF EQ "11104100"
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat
/INCLUDE  TRNCOD
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          CUR_CF,
          TRNCOD_CF,
          AMT_MC
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_15
# filling TACCSTAT table
#--------------------------------
LIBEL="filling TACCSTAT table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_05_${IB}_SORT_GT_O.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BEST..TACCSTAT"
BCP

NSTEP=${NJOB}_20 #[003]
#-----------------------------------------------------------------------------
LIBEL="Update establishment for transfered contracts which have the old one"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_TACCSTAT.log
ISQL_QRY="update best..taccstat
             set a.esb_cf = b.destaccesb_cf
          from best..taccstat a, bfac..trfcrossref b, BREF..TBATCHSSD c
          where a.ctr_nf = b.ctr_nf
          and   b.ctr_nf = b.destctr_nf
          and   b.ssd_cf = b.destssd_cf
          and   a.esb_cf = b.accesb_cf
          and   a.SSD_CF = c.SSD_CF
          and   c.BATCHUSER_CF = suser_name()
"
ISQL

########################
# Erase temporary files #
########################
NSTEP=${NJOB}_25
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
