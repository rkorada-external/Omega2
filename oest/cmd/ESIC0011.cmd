
#!/bin/ksh
#==========================================================================
#nom de l'application          : Job chargement table TLIFSTAREP
#nom du source                 : ESIC0011.cmd
#revision                      : $Revision:   1.7  $
#date de creation              : 02/12/1997
#auteur                        : C.G.I. ()
#references des specifications :
#--------------------------------------------------------------------------
#description :
# Cette chaine execute les steps suivants
#
# Arguments d'entree du job :
#    CLODAT_D     trimestre a extraire
#    CLODAT1_D    31/12     a extraire
#
#--------------------------------------------------------------------------
#historique des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#
#--------------------------------------------------------------------------

#set -x
# Call generic functions
. ${DUTI}/fctgen.cmd

# Recupere arguments d'entree
CLODAT_D=${1}
CLODAT1_D=${2}

# Initialise JOB
JOBINIT

echo ${CLODAT_D}
echo ${CLODAT1_D}



NSTEP=${NJOB}_05
# This step is launched only outside service period
#------------------------------------------------------------------------------
LIBEL="extract TLIFPRNO and format TLIFSTAREP"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_LIFSTAREP_O1.dat
BCP_QRY="exec BSAR..PsLIFSTAREP_01 '${CLODAT_D}', '${CLODAT1_D}'"
BCP

NSTEP=${NJOB}_10
# CUMUL DES MONTANTS CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M
#----------------------------------------------------------------------------
LIBEL="CUMUL DES MONTANTS CBNMNT_M, CBPMNT_M, PCMNT_M, PAMNT_M, PRMNT_M"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_LIFSTAREP_O1.dat 1000 "
SORT_O=${DFILT}/${NCHAIN}_TLIFPRNO_LIFSTAREP_${CLODAT_D}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELD	FILLER1   1:1 - 12: ,
        FILLER2  18:1 - 33: ,
      	CLODAT_D 1: -  1: ,
	      SSD_CF		 2: -  2: EN,
	      CTR_NF		 3: -  3: ,
	      END_NT		 4: -  4: EN 2/0,
       	SEC_NF		 5: -  5: EN 3/0,
	      UWY_NF		 6: -  6: EN 4/0,
	      UW_NT	  	 7: -  7: EN 2/0,
      	PLC_NT		 8: - 8: ,
	      ACCRET_CF	 9: - 9: ,
      	ACY_NF		10: - 10: EN 4/0,
	      ACMTRS_NT 11: - 11: ,
	      PCPCUR_CF 12: - 12: ,
        CBNMNT_M  13:1 - 13:EN 15/3,
        CBPMNT_M   14:1 - 14:EN 15/3,
        PCMNT_M   15:1 - 15:EN 15/3,
        PAMNT_M   16:1 - 16:EN 15/3,
        PRMNT_M   17:1 - 17:EN 15/3
/KEYS CLODAT_D, SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, PLC_NT, ACCRET_CF, ACY_NF, ACMTRS_NT
/SUMMARIZE  TOTAL CBNMNT_M, TOTAL CBPMNT_M, TOTAL PCMNT_M, TOTAL PAMNT_M, TOTAL PRMNT_M
/DERIVEDFIELD CBNMNT_MC CBNMNT_M COMPRESS
/DERIVEDFIELD CBPMNT_MC CBPMNT_M COMPRESS
/DERIVEDFIELD PCMNT_MC PCMNT_M COMPRESS
/DERIVEDFIELD PAMNT_MC PAMNT_M COMPRESS
/DERIVEDFIELD PRMNT_MC PRMNT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, CBNMNT_MC, CBPMNT_MC, PCMNT_MC, PAMNT_MC, PRMNT_MC, FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_30
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*${IB}_*.dat"


JOBEND


