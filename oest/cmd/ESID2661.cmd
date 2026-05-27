#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                               Fusion des GT acceptation
#                               Ajout du poste de contrepartie
# nom du script SHELL		: ESID2061.cmd
# revision			        : $Revision: 1.5 $
# date de creation		    : 08/09/1997
# auteur			        : CGI
# references des specifications	: ESCOM02F.doc
#-----------------------------------------------------------------------------
# description       Merge of acceptance TL
#                   Double entry transaction code addition
#
# Input files
#	EST_DLDVGTR_LIFE 
#	EST_DLEIGTAA_LIFE
#	EST_DLRGTAA_LIFE
#	EST_DLREGTR_LIFE
#	EST_DLREMAJGTAR_LIFE
#	EST_DLREGTAR_LIFE
#	EST_DLREMAJGTR_LIFE
#	EST_DLDVGTR_PC 
#	EST_DLEIGTAA_PC
#	EST_DLRGTAA_PC
#	EST_DLREGTR_PC
#	EST_DLREMAJGTAR_PC
#	EST_DLREGTAR_PC
#	EST_DLREMAJGTR_PC
#
# Output files
#	EST_DLDVGTR 
#	EST_DLEIGTAA
#	EST_DLRIGTAANOS
#	EST_DLRGTAA
#	EST_DLREGTR
#	EST_DLREMAJGTAR
#	EST_DLREGTAR
#	EST_DLREMAJGTR
#
# Launch C program ESTM2061 ESTM7603
#
# job launched by ESID2060.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#MODIFICATION   : [007]
#Auteur         : D.GATIBELZA
#Date           : 07/02/2011
#Version        : 11.1
#Description    : SPIRA 81838 split LIFE and P&C
#[008]  30/01/2020  M. NAJI     :SPIRA 81838 merge ouput files of ESID2550 LIFE and P&C
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="merge EST_DLDVGTR_LIFE EST_DLDVGTR_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDVGTR_LIFE} 1000 1"
SORT_I2="${EST_DLDVGTR_PC} 1000 1"
SORT_O="${EST_DLDVGTR} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE ${SORT_O}
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="merge EST_DLEIGTAA_LIFE EST_DLEIGTAA_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLEIGTAA_LIFE} 1000 1"
SORT_I2="${EST_DLEIGTAA_PC} 1000 1"
SORT_O="${EST_DLEIGTAA} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE ${SORT_O}
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="merge EST_DLRGTAA_LIFE EST_DLRGTAA_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLRGTAA_LIFE} 1000 1"
SORT_I2="${EST_DLRGTAA_PC} 1000 1"
SORT_O="${EST_DLRGTAA} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE ${SORT_O}
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="merge EST_DLREGTR_LIFE EST_DLREGTR_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTR_LIFE} 1000 1"
SORT_I2="${EST_DLREGTR_PC} 1000 1"
SORT_O="${EST_DLREGTR} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE ${SORT_O}
/COPY
exit
EOF
SORT

#NSTEP=${NJOB}_50
##-----------------------------------------------------------------------------
#LIBEL="merge EST_DLREMAJGTAR_LIFE EST_DLREMAJGTAR_PC"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_DLREMAJGTAR_LIFE} 1000 1"
#SORT_I2="${EST_DLREMAJGTAR_PC} 1000 1"
#SORT_O="${EST_DLREMAJGTAR} 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/OUTFILE ${SORT_O}
#/COPY
#exit
#EOF
#SORT

NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="merge EST_DLREGTAR_LIFE EST_DLREGTAR_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTAR_LIFE} 1000 1"
SORT_I2="${EST_DLREGTAR_PC} 1000 1"
SORT_O="${EST_DLREGTAR} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE ${SORT_O}
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="merge EST_DLREMAJGTR_LIFE EST_DLREMAJGTR_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREMAJGTR_LIFE} 1000 1"
SORT_I2="${EST_DLREMAJGTR_PC} 1000 1"
SORT_O="${EST_DLREMAJGTR} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE ${SORT_O}
/COPY
exit
EOF
SORT




JOBEND


