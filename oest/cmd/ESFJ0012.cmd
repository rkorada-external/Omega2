#!/bin/ksh
#=============================================================================
# nom de l'application	       : ESTIMATIONS - PREREQUIS OPTIMISATION ESFD2220.cmd
#                                Convert BInary to TEXT
# nom du script SHELL          : ESFJ0012.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 12/07/2019
# auteur                       : M.NAJI
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#    Convert BInary to TET
#
# Job launched by ESFJ0010.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 27/04/2016  Roger  :spot:81934 Ajout nouveaux fichiers _TXT : FCLIENT - FSSDACTR - FSUBTRS - FSUBTRSESBPROP
#=============================================================================
#set -x
# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

file=$1
nb_splits=$2

DFILP2=$DFILP
ENV_PREFIX2=${ENV_PREFIX}

####################################################
# ATTENTION Pour DEV  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#DFILP2=/scordata_dcvintobbatch/ubeu/perm
#ENV_PREFIX2=T
####################################################

PARM_ICLODAT_D=`grep PARM_ICLODAT_D ${DFILP2}/${ENV_PREFIX2}_ESFJ0000_PARM.dat | cut -d"=" -f2`
BALSHTYEA_NF=`echo $PARM_ICLODAT_D | cut -c1-4`
BALSHTMTH_NF=`echo $PARM_ICLODAT_D | cut -c5-6`

# omega server
export SRV=${PRD_SRV}
# infocenter server
export SRV_2=${INF_SRV}
export BASE="BEST"
export BASE2="BSTA"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> PARM_ICLODAT_D.........: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> BALSHTYEA_NF...........: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF...........: ${BALSHTMTH_NF}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_04
#----------------------------------------------------------------------------
export BASE=${BASE}
SWITCH_SRV ${SRV}

#[010]
NSTEP=${NJOB}_05
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of binary format Files"
PRG=ESIX0061
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
BALSHTMTH_NF  ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_O1=${DFILT}/ESFJ0010_FSEGPAR.dat
export ${PRG}_O2=${DFILT}/ESFJ0010_FCTRFIC.dat
export ${PRG}_O3=${DFILT}/ESFJ0010_FLIFDRI.dat
export ${PRG}_O4=${DFILP}/${ENV_PREFIX}_ESPT0000_FTRSLNK.dat
export ${PRG}_O5=${DFILT}/ESFJ0010_FCURQUOT.dat
export ${PRG}_O6=${DFILT}/ESFJ0010_FDETTRS.dat
export ${PRG}_O7=${DFILT}/ESFJ0010_FRETTRF.dat
export ${PRG}_O9=${DFILT}/ESFJ0010_FSUBSID.dat
export ${PRG}_O10=${DFILT}/ESFJ0010_FACMTRSH.dat
export ${PRG}_O11=${DFILT}/ESFJ0010_FBANTECL.dat
export ${PRG}_O12=${DFILT}/ESFJ0010_FGRP.dat
export ${PRG}_O13=${DFILT}/ESFJ0010_FCURCVSNI.dat
export ${PRG}_O14=${DFILT}/ESFJ0010_FSOBBLOB.dat
export ${PRG}_O15=${DFILT}/ESFJ0010_FSEGMENT.dat
export ${PRG}_O16=${DFILT}/ESFJ0010_FLIFTHR.dat
export ${PRG}_O17=${DFILT}/ESFJ0010_SUBTRS.dat
export ${PRG}_O18=${DFILT}/ESFJ0010_SUBTRSBLOCKLIFEST.dat
export ${PRG}_O19=${DFILT}/ESFJ0010_SUBTRSASSO.dat
export ${PRG}_O20=${DFILT}/ESFJ0010_SUBTRSBASE.dat
export ${PRG}_O21=${DFILT}/ESFJ0010_TACCPAR.dat
export ${PRG}_O22=${DFILT}/ESFJ0010_SUBTRSESBPROP.dat
export ${PRG}_O23=${DFILT}/ESFJ0010_FLIFDRI_ALL.dat
export ${PRG}_O24=${DFILT}/ESFJ0010_FTRANSCODE.dat
export ${PRG}_O25=${DFILT}/ESFJ0010_FTRANSCODEVRET.dat
export ${PRG}_O26=${DFILT}/ESFJ0010_FTRSLNKVRET.dat
export ${PRG}_O27=${DFILT}/ESFJ0010_FLIFDRIQ_ALL.dat # [011]
export ${PRG}_O28=${DFILT}/ESFJ0010_FLIFDRIY_ALL.dat # [011]
EXECPRG

NSTEP=${NJOB}_10
# Bin to text FTRSLNK file
#--------------------------------------------------------------------------
LIBEL="Bin to texte FTRSLNK file"

FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TYPE_NAME T_TRSLNK
exit
EOF

DESC=$DFILT/${NSTEP}_${IB}_FTRSLNK_TXT.dat
INPUT_TEXT ${DESC} << EOF
short;PRS_CF;1
short;ACMTRS_NT;1
char;DETTRS_CF;9
exit
EOF

PRG=BINTOTXT
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DESC}
export ${PRG}_I2=${DFILP}/${ENV_PREFIX}_ESPT0000_FTRSLNK.dat
export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_FTRSLNK_TXT_${PARM_ICLODAT_D}.dat
EXECPRG

NSTEP=${NJOB}_20
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
export ${PRG}_I2=${DFILP2}/${ENV_PREFIX2}_ESPT0000_FCURQUOT.dat
export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_FCURQUOT_TXT_${PARM_ICLODAT_D}.dat
EXECPRG

NSTEP=${NJOB}_30
# Bin to text FDETTRS file
#--------------------------------------------------------------------------
LIBEL="Bin to texte FDETTRS file"

FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TYPE_NAME T_TDETTRS
exit
EOF

DESC=$DFILT/${NSTEP}_${IB}_FDETTRS_TXT.dat
INPUT_TEXT ${DESC} << EOF
char;DETTRS_CF;9
char;CTRSCOD_CF;9
unsigned char;TRSTYP_CT
char;RETTRSCOD_CF;9
unsigned char;RET_B
unsigned char;COMP_B
exit
EOF

PRG=BINTOTXT
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DESC}
export ${PRG}_I2=${DFILP2}/${ENV_PREFIX2}_ESPT0000_FDETTRS.dat
export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_FDETTRS_TXT_${PARM_ICLODAT_D}.dat
EXECPRG

NSTEP=${NJOB}_44
#----------------------------------------------------------------------------
export BASE=${BASE2}
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_45
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FBOPRSLNK"
PRG=ESTX0008
export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_FBOPRSLNK.dat
EXECPRG

NSTEP=${NJOB}_46
#----------------------------------------------------------------------------
export BASE=${BASE}
SWITCH_SRV ${SRV}

NSTEP=${NJOB}_40
# Bin to text FBOPRSLNK file
#--------------------------------------------------------------------------
LIBEL="Bin to texte FBOPRSLNK file"

FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TYPE_NAME T_FBOPRSLNK
exit
EOF

DESC=$DFILT/${NSTEP}_${IB}_FDETTRS_TXT.dat
INPUT_TEXT ${DESC} << EOF
char;TRSPFX_CF;1
short;ACMTRSL0_NT;1
short;ACMTRSL1_NT;1
short;ACMTRSL2_NT;1
short;ACMTRSL3_NT;1
short;ACMTRSLL1_NT;1
short;ACMTRSLL2_NT;1
short;TRSTYP_NT;1
char;DETTRS_CF;9
char;PCPTRS_CF;3
char;TRS_CF;1
char;SUBTRS_CF;3
short;ESTIM_NT;1
short;TRNTYP_CT;1
exit
EOF

PRG=BINTOTXT
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DESC}
export ${PRG}_I2=${DFILP}/${ENV_PREFIX}_ESPT0000_FBOPRSLNK.dat
export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_FBOPRSLNK_TXT_${PARM_ICLODAT_D}.dat
EXECPRG

NSTEP=${NJOB}_50
# Bin to text FPRSMAP file
#--------------------------------------------------------------------------
LIBEL="Bin to texte FPRSMAP file"

FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TYPE_NAME T_FPRSMAP
exit
EOF

DESC=$DFILT/${NSTEP}_${IB}_FPRSMAP_TXT.dat
INPUT_TEXT ${DESC} << EOF
short;PRS_CF;
short;ACMTRS_NT;1
char;PARM1;32
char;PARM2;32
char;PARM3;32
char;PARM4;32
char;PARM5;32
char;PARM6;32
char;PARM7;32
char;PARM8;31
char;PARM9;32
char;PARM10;32
exit
EOF

PRG=BINTOTXT
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DESC}
export ${PRG}_I2=${DFILP2}/${ENV_PREFIX2}_ESPT0000_FPRSMAP.dat
export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_FPRSMAP_TXT_${PARM_ICLODAT_D}.dat
EXECPRG

NSTEP=${NJOB}_60
# Bin to text FCLIENT file
#--------------------------------------------------------------------------
LIBEL="Bin to texte FCLIENT file"

FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TYPE_NAME T_FCLIENT
exit
EOF

DESC=$DFILT/${NSTEP}_${IB}_FCLIENT_TXT.dat
INPUT_TEXT ${DESC} << EOF
int;CLI_NF;1
int;CLISSD_NF;1
exit
EOF

PRG=BINTOTXT
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DESC}
export ${PRG}_I2=${DFILP2}/${ENV_PREFIX2}_ESPT0000_FCLIENT.dat
export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_FCLIENT_TXT_${PARM_ICLODAT_D}.dat
EXECPRG

NSTEP=${NJOB}_70
# Bin to text FSSDACTR file
#--------------------------------------------------------------------------
LIBEL="Bin to texte FSSDACTR file"

FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TYPE_NAME T_FSSDACTR
exit
EOF

DESC=$DFILT/${NSTEP}_${IB}_FSSDACTR_TXT.dat
INPUT_TEXT ${DESC} << EOF
char;RETCTR_NF;10
short;RTY_NF;1
int;PLC_NT;1
unsigned char;RETSEC_NF
unsigned char;SSD_CF
char;CTR_NF;10
short;UWY_NF ;1
unsigned char;UW_NT
unsigned char;SEC_NF
unsigned char;END_NT
int;CLISSD_NF;1
unsigned char;RTOSSD_CF
exit
EOF

PRG=BINTOTXT
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DESC}
export ${PRG}_I2=${DFILP2}/${ENV_PREFIX2}_ESPT0000_FSSDACTR.dat
export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_FSSDACTR_TXT_${PARM_ICLODAT_D}.dat
EXECPRG

#NSTEP=${NJOB}_80
## Bin to text FSUBTRS file
##--------------------------------------------------------------------------
#LIBEL="Bin to texte FSUBTRS file"
#
#FPRM=`CFTMP`
#INPUT_TEXT ${FPRM} << EOF
#TYPE_NAME T_SUBTRS
#exit
#EOF
#
#DESC=$DFILT/${NSTEP}_${IB}_FSUBTRS_TXT.dat
#INPUT_TEXT ${DESC} << EOF
#char;DETTRNCOD_CF;6
#char;SUBTRS_GL;65
#char;SUBTRS_GS;17
#char;SUBTRSEXP_D;18
#char;SUBTRSINC_D;18
#int;CMT_NT;1
#unsigned char;TRSINPUTTYPE_CT
#unsigned char;TRSNATURE_CT
#char;LOGSIG_CT;2
#char;LOB_CF;3
#short;TRSTYPE_CT;1
#unsigned char;TRSPURERETRO_B
#unsigned char;DACTYPE_B
#unsigned char;COMPLEMENT_B
#unsigned char;NEWBALSHEETPROPAG_B
#unsigned char;CELLPROTECEXC_B
#exit
#EOF
#
#PRG=BINTOTXT
#export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1=${DESC}
#export ${PRG}_I2=${DFILP2}/${ENV_PREFIX2}_ESPT0000_FSUBTRS.dat
#export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_SUBTRS_TXT_${PARM_ICLODAT_D}.dat
#EXECPRG

NSTEP=${NJOB}_80
#extraction of TSUBTRS in TXT mode
#-----------------------------------------------------------------------------
LIBEL="extraction of TSUBTRS in TXT mode"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${ENV_PREFIX}_ESPT0000_SUBTRS_TXT_${PARM_ICLODAT_D}.dat
BCP_QRY="BEST..PsSUBTRS_01"
BCP

#NSTEP=${NJOB}_90
## Bin to text FSUBTRSESBPROP file
##--------------------------------------------------------------------------
#LIBEL="Bin to texte FSUBTRSESBPROP file"
#
#FPRM=`CFTMP`
#INPUT_TEXT ${FPRM} << EOF
#TYPE_NAME T_SUBTRSESBPROP
#exit
#EOF
#
#DESC=$DFILT/${NSTEP}_${IB}_FSUBTRSESBPROP_TXT.dat
#INPUT_TEXT ${DESC} << EOF
#char;DETTRNCOD_CF;6
#unsigned char;SSD_CF
#unsigned char;ESB_CF
#unsigned char;GLTFEEDING_B
#unsigned char;INTERNRETRO_B
#unsigned char;SRVFEEDING_B
#unsigned char;PREMIUMPNPEGPI_B
#unsigned char;RETROAUTO_B
#unsigned char;COMACIMPACT_B
#unsigned char;CASHFLOWPOS_CT
#unsigned char;GAAP1TRS_CT
#unsigned char;GAAP2TRS_CT
#unsigned char;GAAP3TRS_CT
#unsigned char;GAAP4TRS_CT
#unsigned char;GAAP5TRS_CT
#char;CRE_D;18
#char;CREUSR_CF;5
#char;LSTUPD_D;50
#char;LSTUPDUSR_CF;5
#exit
#EOF
#
#PRG=BINTOTXT
#export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1=${DESC}
#export ${PRG}_I2=${DFILP2}/${ENV_PREFIX2}_ESPT0000_FSUBTRSESBPROP.dat
#export ${PRG}_O1=${DFILP}/${ENV_PREFIX}_ESPT0000_SUBTRSESBPROP_TXT_${PARM_ICLODAT_D}.dat
#EXECPRG

NSTEP=${NJOB}_90
#extraction of TSUBTRSESBPROP in TXT mode
#-----------------------------------------------------------------------------
LIBEL="extraction of TSUBTRSESBPROP in TXT mode"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${ENV_PREFIX}_ESPT0000_SUBTRSESBPROP_TXT_${PARM_ICLODAT_D}.dat
BCP_QRY="BEST..PsSUBTRSESBPROP_01"
BCP

JOBEND

