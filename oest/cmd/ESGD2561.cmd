#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Extract files to merge 
#				  Batch quotidien
# nom du script SHELL		: ESGD2561.cmd
# revision
# date de creation		: 16/07/2025
# auteur			: M.NAJI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#
# launched by ESGD2560.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# Job Initialisation
JOBINIT




#-------------------------------------------------------------------------------------------------------------------------
#----------------------------------------- EST_FCURCVSN
#-------------------------------------------------------------------------------------------------------------------------


NSTEP=${NJOB}_10
#Generation of FCURCVSN0 File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of FCURCVSN0 Perimeter File... ESCJ0661_210"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FCURCVSN}"
BCP_QRY="select distinct a.ssd_cf, a.retctr_nf, a.rty_nf, a.plc_nt
         from bret..tcurcvsn a, BREF..TBATCHSSD b
         where plc_nt > 0
         and a.SSD_CF=b.SSD_CF
         and b.BATCHUSER_CF='$DEFAULT_SQL_LOGIN'
         order by a.ssd_cf, a.retctr_nf, a.rty_nf, a.plc_nt"
BCP

NSTEP=${NJOB}_20
#---------------------------------------------------------------------------------------------
LIBEL="copy EST_FCURCVSN to EBS"   
EXECKSH "cp ${EST_FCURCVSN} ${EST_FCURCVSN_EBS}"



#===================================ESCJ0660/ESCJ0661 : NSTEP=${NJOB}_220
#[010]
NSTEP=${NJOB}_30
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of binary format Files ESCJ0661_195"
PRG=ESIX0061
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF  ${PARM_BALSHTYEA_NF}
BALSHTMTH_NF  ${PARM_BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_O1=${EST_FSEGPAR}
export ${PRG}_O2=${EST_FCTRFIC}
export ${PRG}_O3=${EST_FLIFDRI}
export ${PRG}_O4=${EST_FTRSLNK}
export ${PRG}_O5=${EST_FCURQUOT}
export ${PRG}_O6=${EST_FDETTRS}
export ${PRG}_O7=${EST_FRETTRF}
export ${PRG}_O9=${EST_FSUBSID}
export ${PRG}_O10=${EST_FACMTRSH}
export ${PRG}_O11=${EST_FBANTECL}
export ${PRG}_O12=${EST_FGRP}
export ${PRG}_O13=${EST_FCURCVSNI}
export ${PRG}_O14=${EST_FSOBBLOB}
export ${PRG}_O15=${EST_FSEGMENT}
export ${PRG}_O16=${EST_FLIFTHR}
export ${PRG}_O17=${EST_SUBTRS}
export ${PRG}_O18=${EST_SUBTRSBLOCKLIFEST}
export ${PRG}_O19=${EST_SUBTRSASSO}
export ${PRG}_O20=${EST_SUBTRSBASE}
export ${PRG}_O21=${EST_TACCPAR}
export ${PRG}_O22=${EST_SUBTRSESBPROP}
export ${PRG}_O23=${EST_FLIFDRI_ALL}
export ${PRG}_O24=${EST_FTRANSCODE}
export ${PRG}_O25=${EST_FTRANSCODEVRET}
export ${PRG}_O26=${EST_FTRSLNKVRET}
export ${PRG}_O27=${EST_FLIFDRIQ_ALL} # [011]
export ${PRG}_O28=${EST_FLIFDRIY_ALL} # [011]
EXECPRG


NSTEP=${NJOB}_40
#---------------------------------------------------------------------------------------------
LIBEL="copy EST_FCURQUOT to EBS"   
EXECKSH "cp ${EST_FCURQUOT} ${EST_FCURQUOT_60}"



NSTEP=${NJOB}_50
# Generation of EST_FSSDACTR  (text format)
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FSSDACTR (text format) ESCJ0062_65 "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FSSDACTR_TXT}
BCP_QRY="exec BEST..PsSSDACTR_01"
BCP


JOBEND 
