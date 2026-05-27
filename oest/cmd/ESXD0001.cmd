#!/bin/ksh
#      C'EST EN FRANÇAIS CAR C'EST POUR PARIS UNIQUEMENT !!!!!!!!!!
#=============================================================================
# nom de l'application          :
# nom du script SHELL           : ESXD0001.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 30/10/97
# auteur                        : Florent (SCOR)
# references des specifications :
#-----------------------------------------------------------------------------
# description :
# JOB SET: Extraction d'information pour le batch MVS de Jean François Van De Velde
# IMPORTANT : 
#             Avant le batch MVS POMID05
#       Variables used by the job set (defined in ESXD0000.env) :
#        ${EST_JFVDV_TCLMDET}
#        ${EST_JFVDV_TSECTION}
#        ${EST_JFTCPLACC}
#-----------------------------------------------------------------------------
# Update history :
#   <dd/mm/yyyy>   <author>    <update description>
#    28/05/1998     Florent     Changer step_25 pour mettre ssd et esb devant et date en 8 chiffres
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
#-----------------------------------------------------------------
LIBEL="Extraction de BCTA..TCLMDET, filiale 2,3,4,12"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_JFVDV_TCLMDET}
BCP_QRY="select CLM_NF,SSD_CF,CLMOCC_D=convert(char(10),CLMOCC_D,102) from BCTA..TCLMDET where SSD_CF in (2,3,4,12)"
BCP

NSTEP=${NJOB}_10
#-----------------------------------------------------------------
LIBEL="Extraction de BTRT..TSECTION, filiale 2,3,4,12"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_JFVDV_TSECTION}
BCP_QRY="select CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,ACCADMTYP_CT,SECCAN_D=convert(char(6), SECCAN_D,12) from BTRT..TSECTION where SSD_CF in (2,3,4,12)"
BCP

NSTEP=${NJOB}_15
#-----------------------------------------------------------------
LIBEL="Extraction de BCTA..TCPLACC, filiale 2,3,4,12 pas user DBC"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_JFTCPLACC}
BCP_QRY="select SSD_CF,ESB_CF,CTR_NF,ACY_NF,BLCSHT_D=convert(char(8), blcsht_d,112) FROM BCTA..TCPLACC where ssd_cf in (2,3,4,12) and lstupdusr_cf!='DBC'"
BCP

NSTEP=${NJOB}_25
#-----------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
