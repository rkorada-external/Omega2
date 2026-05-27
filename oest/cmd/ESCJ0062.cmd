#!/bin/ksh
#===========================================================================================
# nom de l'application		: ESTIMATION - INVENTAIRE
#                                 Extracting binary non life tables
# nom du script SHELL		: ESCJ0062.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 17/10/97
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Extracting binary non life tables.
#-----------------------------------------------------------------------------
# historique des modifications:
#[01] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.03 add step 31
#[02] 06/02/2019 JYP : IFRS17 req 11.1 : extract 2 new files EST_CLIENT_TXT EST_FBOPRSLNK_TXT
#[03] 13/06/2019 M.NAJI : add extraction files to replace binary files
#[04] 04/11/2019 R. Cassis  :spira:81934 Le fichier EST_FCURQUOT_TXT est cr�� a partir du fichier binaire pas de la procedure
#[05] 03/09/2021 L.DOAN spira 91998 : O2/SAP interface management - EBS common transaction in dedicated file : ajout file EST_FDETTRS_640_TXT
#==========================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd


# Job Initialisation
JOBINIT


NSTEP=${NJOB}_10
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_LIBEL1"
PRG=ESTX0004
export ${PRG}_O1=${EST_FLIBEL1}
EXECPRG

NSTEP=${NJOB}_15
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_LIBEL2"
PRG=ESTX0006
export ${PRG}_O1=${EST_FLIBEL2}
EXECPRG

NSTEP=${NJOB}_20
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FRETPAR"
PRG=ESTX0003
export ${PRG}_O1=${EST_FRETPAR}
EXECPRG

NSTEP=${NJOB}_25
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FSSDACTR"
PRG=ESTX0005
export ${PRG}_O1=${EST_FSSDACTR}
if [ "$VSERQS_I4I" != "YES" ]
then
        EXECPRG
fi


NSTEP=${NJOB}_30
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FCLIENT"
PRG=ESTX0007
export ${PRG}_O1=${EST_FCLIENT}
EXECPRG


NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Read date in T_TMAPPING table"
PRG=ESTX0009
export ${PRG}_O1=${EST_FPRSMAP}
EXECPRG


NSTEP=${NJOB}_40
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="extraction of  EST_FCLIENT_TXT in TXT mode : $EST_CLIENT_TXT"
#extraction of  EST_FCLIENT_TXT in TXT mode
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FCLIENT_TXT}"
BCP_QRY="execute BCLI..PsCLIENT_110"
BCP

NSTEP=${NJOB}_45
# Extraction des Postes Comtpables TRSLNK ( en text ) 
#------------------------------------------------------------------------------
LIBEL="Extraction des Postes Comtpables TRSLNK ( en text )"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_TXT.dat"
BCP_QRY="exec BEST..PsTRSLNK_02"
BCP


NSTEP=${NJOB}_46
#------------------------------------------------------------------------------
LIBEL="Split ${EST_FTRSLNK_TXT} and ${EST_FTRSLNK_640_TXT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_FTRSLNK_TXT.dat 2000 1"
SORT_O="${EST_FTRSLNK_TXT} 2000 1 "
SORT_O2="${EST_FTRSLNK_640_TXT} 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PRS_CF       1:1 -  1:,
        ACMTRS_NT        2:1 -  2:,
        DETTRS_CF        3:1 -  3:
/KEYS
        PRS_CF,
        ACMTRS_NT,
        DETTRS_CF
/CONDITION IS_640 ( PRS_CF = "640" OR PRS_CF = "900" )
/OUTFILE ${SORT_O} OVERWRITE 
/OMIT IS_640
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE IS_640
exit
EOF
SORT



#NSTEP=${NJOB}_50
## Extraction des devises ( en text )
##------------------------------------------------------------------------------
#LIBEL="Extraction des devises ( en text )"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${EST_FCURQUOT_TXT}
#BCP_QRY="exec BREF..PsCURQUOT_09"
#BCP

NSTEP=${NJOB}_50
# Bin to text FCURQUOT file
#--------------------------------------------------------------------------
LIBEL="Bin to texte FCURQUOT file"

FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TYPE_NAME T_TCURQUOT
exit
EOF

DESC=$DFILT/${NSTEP}_${IB}_FCURQUOT_TXT.dat
INPUT_TEXT ${DESC} << EOF
char;c_ssd;1
char;sz_cur;4
short;s_uwy;1
double;d_quot;1
exit
EOF

PRG=BINTOTXT
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DESC}
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${EST_FCURQUOT_TXT}
EXECPRG

NSTEP=${NJOB}_55
# Extraction des Postes Comtpables TDETTRS ( en text )
#------------------------------------------------------------------------------
LIBEL="Extraction des Postes Comtpables TDETTRS ( en text )"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FDETTRS_TXT}
BCP_QRY="exec BEST..PsDETTRS_11"
BCP

NSTEP=${NJOB}_60
# Extraction  date in T_TMAPPING table  (text format)
#------------------------------------------------------------------------------
LIBEL="Extraction  date in T_TMAPPING table (text format) "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPRSMAP_TXT}
BCP_QRY="exec BREF..PsTMAPPING_01"
BCP

NSTEP=${NJOB}_65
# Generation of EST_FSSDACTR  (text format)
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FSSDACTR (text format) "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FSSDACTR_TXT}
BCP_QRY="exec BEST..PsSSDACTR_01"
BCP


NSTEP=${NJOB}_70
# Generation of EST_FCLIENTt format)
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FLIENT"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCLIENT_TXT}
BCP_QRY="exec BCLI..PsCLIENT_110"
BCP

NSTEP=${NJOB}_75
#----------------------------------------------------------------------------
export BASE=${BASE2}
SWITCH_SRV ${SRV_2}


NSTEP=${NJOB}_80
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FBOPRSLNK"
PRG=ESTX0008
export ${PRG}_O1=${EST_FBOPRSLNK}
EXECPRG


NSTEP=${NJOB}_85
#extraction of TBOPRSLNK in TXT mode
#-----------------------------------------------------------------------------
LIBEL="extraction of TBOPRSLNK in TXT mode"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FBOPRSLNK_TXT}
BCP_QRY="execute BSAR..PsTBOPRSLNK_01"
BCP



NSTEP=${NJOB}_95
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FBOPRSLNK"
PRG=ESTX0008
export ${PRG}_O1=${EST_FBOPRSLNK}
EXECPRG


NSTEP=${NJOB}_95
#----------------------------------------------------------------------------
export BASE=${BASE}
SWITCH_SRV ${SRV_DEFAULT}

NSTEP=${NJOB}_105
#extraction of TSUBTRS in TXT mode
#-----------------------------------------------------------------------------
LIBEL="extraction of TSUBTRS in TXT mode"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_SUBTRS_TXT}
BCP_QRY="BEST..PsSUBTRS_01"
BCP


NSTEP=${NJOB}_110
#extraction of TSUBTRSESBPROP in TXT mode
#-----------------------------------------------------------------------------
LIBEL="extraction of TSUBTRSESBPROP in TXT mode"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_SUBTRSESBPROP_TXT}
BCP_QRY="BEST..PsSUBTRSESBPROP_01"
BCP


JOBEND
