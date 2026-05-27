#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESARCH21.cmd
# revision                      : 
# date de creation              : 20/03/2026
# auteur                        : G.GRUDZINSKI
# references des specifications : US8835
#-----------------------------------------------------------------------------
# description
#   Automatic closing data files archiving
#
# job launched by ESARCH20.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : 
#Auteur         : G.GRUDZINSKI
#Date           : 20/03/2026
#Version        : 1.0
#Description    : 20/03/2026 :G.GRUDZINSKI US8835 : Automatic closing data files archiving
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DCMD}/ESARCLIB.cmd

# PARM_ICLODAT_D : date de cloture du trimestre J
# PARM_ICLODAT_1_D : date de cloture du trimestre J-1
# PARM_ICLODAT_2_D : date de cloture du trimestre J-2
# PARM_ICLODAT_3_D : date de cloture du trimestre J-3
# PARM_ICLODAT_4_D : date de cloture du trimestre J-4
# PARM_ICLODAT_5_D : date de cloture du trimestre J-5
# PARM_ICLODAT_6_D : date de cloture du trimestre J-6
# PARM_ICLODAT_7_D : date de cloture du trimestre J-7
# PARM_ICLODAT_8_D : date de cloture du trimestre J-8

# The names of the variables above are put in the list of files by the SQL query below, based on the
# configuration in the database. The values of the variables (end dates of particular quarters) are defined
# in environment by the script ESFD9001.cmd used when starting the processing chain, and are consumed
# within the ZIP_FILES function (defined in ESARCLIB.cmd) where the variable names will be replaced
# by the values from the environment.

# Job Initialisation
JOBINIT

# The archiving trigger (for now 'INVB' or 'POSB') are indicated by the REQCOD_CT column in TI17REQFNC table
# filled in MAPPING_ESARCH20.sql file, so no separate column for the archiving trigger is needed in TI17PERMRUL2
# table.

# The configuration is stored in the database table BEST.dbo.TI17PERMRUL2, with the following definition:
#
#CREATE TABLE BEST.dbo.TI17PERMRUL2 (
#	IDF_CT varchar(30) NOT NULL,
#	PATHPATTRN_LL varchar(512) NOT NULL,
#	NQUATER_NT int NOT NULL,
#	PERM_LL varchar(64) NULL,
#   TRIGGER_CT char(10) NOT NULL,
#	CONSTRAINT TI17PERMRUL2_PK PRIMARY KEY (IDF_CT,PATHPATTRN_LL,NQUATER_NT,TRIGGER_CT)
#);

NSTEP=${NJOB}_10
#all PATHPATTRN_LL 
#-----------------------------------------------------------------------------
LIBEL=" all PATHPATTRN_LL ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_FILES_TO_ZIP.dat
# BCP_QRY="
#     SELECT  
#     CASE
#        WHEN NQUATER_NT = 0 THEN     str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_D}')
#        WHEN NQUATER_NT = 1 THEN     str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_1_D}')
#        WHEN NQUATER_NT = 2 THEN     str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_2_D}')
#        WHEN NQUATER_NT = 3 THEN     str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_3_D}')
#        WHEN NQUATER_NT = 4 THEN     str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_4_D}')
#        WHEN NQUATER_NT = 5 THEN     str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_5_D}')
#        WHEN NQUATER_NT = 6 THEN     str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_6_D}')
#        WHEN NQUATER_NT = 7 THEN     str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_7_D}')
#        WHEN NQUATER_NT = 8 THEN     str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_8_D}')
#        ELSE str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{NOT_USED}')
#     END
# 
#     FROM BEST.dbo.TI17PERMRUL2
#     WHERE IDF_CT = '${IDF_CT}'
#     and TRIGGER_CT = substring('${PARM_REQCOD_CT}', 6, 4)
# "
BCP_QRY="EXEC BEST.dbo.PiGetFilesESARCH_01 @p_idf_ct = '${IDF_CT}', @p_parm_reqcod_ct = '${PARM_REQCOD_CT}'"
BCP

NSTEP=${NJOB}_20
#files  archive  
#-----------------------------------------------------------------------------
LIBEL="files  archive  "
export ZIP_FILES_IN=${DFILT}/${NJOB}_10_${IB}_FILES_TO_ZIP.dat
export ZIP_FILES_ODIR="$DARCH"
export ZIP_FILES_OPT=''
export ZIP_FILES_MODE='Z'
export ZIP_FILES_PREFIX='ARCH_'
ZIP_FILES

# End of Job
JOBEND


