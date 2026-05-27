#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE POST-OMEGA
#                                 Load TCTREST data to TP server
# nom du script SHELL           : ESPD8001.cmd
# revision                      :
# date de creation              : 08/04/2019
# auteur                        : Roger Cassis
# references des specifications : :spira:65656
#-----------------------------------------------------------------------------
# description
#    Rechargement de la table BEST..TCTREST
#
# job launched by ESPD8000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[001] 12/02/2020 R. CASSIS  :spira:65656 Ajout test de chargement du fichier FTCTREST
#[002] 29/04/2020 R. CASSIS  :spira:86536 Gestion du chargement avec unicite de records et ancien CRE_D de ligne 'F' restauré - plus de test de chargement
#[003] 26/06/2020 R. CASSIS  :spira:86536 Maintenant, on ne recharge que les lignes A ou F demandees par l'utilisateur sauf le 1er jour du POSE - refonte entiere du job
#[004] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[005] 30/06/2022 R. CASSIS  :spira:105344 Le 1er jour du POS EBS trimestriel, on doit maintenant vider les lignes TCTREST chargees par le INV EBS.

#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

#Parameters

#norme EBS
PRS_CF=730

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME.........................: ${NORME}"
ECHO_LOG "#===> TYPEINV.......................: ${TYPEINV}"
ECHO_LOG "#===> PARM_CRE_D....................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_ICLODAT_D................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PRS_CF........................: ${PRS_CF}"
ECHO_LOG "#===> EPO_FCTREST0..................: ${EPO_FCTREST0}"
ECHO_LOG "#===> EPO_FCTREST1..................: ${EPO_FCTREST1}"
ECHO_LOG "#===> EPO_FCTRESTA..................: ${EPO_FCTRESTA}"
ECHO_LOG "#===> EPO_FCTRESTF..................: ${EPO_FCTRESTF}"
ECHO_LOG "#===> EPO_FCTRESTF0.................: ${EPO_FCTRESTF0}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_110
# FCTREST1 extract types 'A' and 'F' order by CRE_D DESC
#-----------------------------------------------------------------------------
LIBEL="FCTREST1 extract types 'A' and 'F' order by CRE_D DESC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FCTREST1} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTREST1F_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FCTREST1A_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:,
        LSTUPD_D  20:1 - 20:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      CRE_D DESC
/CONDITION ADMMODF ADMMOD_CT = "F" AND CLODAT_D = "${PARM_ICLODAT_D}"
/CONDITION ADMMODA ADMMOD_CT = "A" AND CLODAT_D = "${PARM_ICLODAT_D}"
/OUTFILE ${SORT_O}
/INCLUDE ADMMODF
/OUTFILE ${SORT_O2}
/INCLUDE ADMMODA
exit
EOF
SORT

NSTEP=${NJOB}_120F
# We keep only the most recent CRE_D record for type 'F'
#-----------------------------------------------------------------------------
LIBEL="We keep only the most recent CRE_D record for type 'F'"
SORT_I=${DFILT}/${NJOB}_110_${IB}_SORT_FCTREST1F_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTFLast_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT
/STABLE
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_130F
# Replace original CRE_D and users info on record type 'F' to generate data to be loaded
#------------------------------------------------------------------------------
LIBEL="Replace original CRE_D and users info on record type 'F' to generate data to be loaded"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120F_${IB}_SORT_FCTRESTFLast_O.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTFLast1_O.dat OVERWRITE 500 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           1:1 -  1:,
        END_NT           2:1 -  2:,
        SEC_NF           3:1 -  3:,
        UWY_NF           4:1 -  4:,
        UW_NT            5:1 -  5:,
        CRE_D            6:1 -  6:,
        PRS_CF           7:1 -  7:,
        ACMTRS_NT        8:1 -  8:,
        SSD_CF           9:1 -  9:,
        ENTAMT_M        13:1 - 13:,
        ADMMOD_CT       15:1 - 15:,
        CLODAT_D        16:1 - 16:,
        F_CTR_NF         1:1 -  1:,       
        F_END_NT         2:1 -  2:,       
        F_SEC_NF         3:1 -  3:,       
        F_UWY_NF         4:1 -  4:,       
        F_UW_NT          5:1 -  5:,       
        F_CRE_D          6:1 -  6:,       
        F_PRS_CF         7:1 -  7:,       
        F_ACMTRS_NT      8:1 -  8:,       
        F_SSD_CF         9:1 -  9:,
        F_CALAMT_M      12:1 - 12:,
        F_RETAMT_M      14:1 - 14:,
        F_ADMMOD_CT     15:1 - 15:,       
        F_CLODAT_D      16:1 - 16:,
        F_ORICOD_LS     17:1 - 17:,
        F_UPDUSR_CF     18:1 - 18:,
        F_CREUSR_CF     19:1 - 19:,
        F_LSTUPD_D      20:1 - 20:,
        F_LSTUPDUSR_CF  21:1 - 21:,
        F_CMT_NT        22:1 - 22:,
        F_INCURREDCI_M  23:1 - 23:,
        COLS1            1:1 -  5:,
        COLS2            7:1 - 11:,
        COLS3           13:1 - 13:,
        COLS4           15:1 - 16:,
        COLS5           18:1 - 18:,
        COLS6           20:1 - 20:,
        COLS7           23:1 - 23:
/joinkeys
         CTR_NF   
        ,END_NT   
        ,SEC_NF   
        ,UWY_NF   
        ,UW_NT    
        ,PRS_CF   
        ,ACMTRS_NT
        ,SSD_CF
        ,ADMMOD_CT
        ,CLODAT_D
/INFILE ${EPO_FCTRESTF} 500 1 "~"
/joinkeys
         F_CTR_NF   
        ,F_END_NT   
        ,F_SEC_NF   
        ,F_UWY_NF   
        ,F_UW_NT    
        ,F_PRS_CF   
        ,F_ACMTRS_NT
        ,F_SSD_CF
        ,F_ADMMOD_CT
        ,F_CLODAT_D
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:COLS1
       ,rightside:F_CRE_D
       ,leftside:COLS2
       ,rightside:F_CALAMT_M
       ,leftside:COLS3
       ,rightside:F_RETAMT_M
       ,leftside:COLS4
       ,rightside:F_ORICOD_LS
       ,leftside:COLS5
       ,rightside:F_CREUSR_CF
       ,leftside:COLS6
       ,rightside:F_LSTUPDUSR_CF
       ,rightside:F_CMT_NT
       ,leftside:COLS7
exit
EOF
SORT

NSTEP=${NJOB}_140F
# Sort on lstupd_d desc for type 'F'
#-----------------------------------------------------------------------------
LIBEL="Sort on lstupd_d desc for type 'F'"
SORT_I=${DFILT}/${NJOB}_130F_${IB}_SORT_FCTRESTFLast1_O.dat
SORT_I2=${EPO_FCTRESTF0}
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTFLast2_O.dat OVERWRITE 500 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:,
        LSTUPD_D  20:1 - 20:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      CRE_D,
      LSTUPD_D DESC
exit
EOF
SORT

NSTEP=${NJOB}_150F
# We keep all history CRE_D distinct record for type 'F'
#-----------------------------------------------------------------------------
LIBEL="We keep all history CRE_D distinct record for type 'F'"
SORT_I=${DFILT}/${NJOB}_140F_${IB}_SORT_FCTRESTFLast2_O.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTFNew_O.dat OVERWRITE 500 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      CRE_D
/STABLE
/SUM
exit
EOF
SORT

if [ -s ${EPO_FCTRESTA} ]
then
	NSTEP=${NJOB}_160A
	# We keep only the most recent CRE_D record for type 'A'
	#-----------------------------------------------------------------------------
	LIBEL="We keep only the most recent CRE_D record for type 'A'"
	SORT_I=${DFILT}/${NJOB}_110_${IB}_SORT_FCTREST1A_O.dat
	SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTALast_O.dat
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT
/STABLE
/SUM
exit
EOF
	SORT

	NSTEP=${NJOB}_170A
	# Replace original CRE_D and users info on record type 'A' to generate data to be loaded
	#------------------------------------------------------------------------------
	LIBEL="Replace original CRE_D and users info on record type 'A' to generate data to be loaded"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_160A_${IB}_SORT_FCTRESTALast_O.dat 500 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTANew_O.dat OVERWRITE 500 1 "
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           1:1 -  1:,
        END_NT           2:1 -  2:,
        SEC_NF           3:1 -  3:,
        UWY_NF           4:1 -  4:,
        UW_NT            5:1 -  5:,
        CRE_D            6:1 -  6:,
        PRS_CF           7:1 -  7:,
        ACMTRS_NT        8:1 -  8:,
        SSD_CF           9:1 -  9:,
        ENTAMT_M        13:1 - 13:,
        ADMMOD_CT       15:1 - 15:,
        CLODAT_D        16:1 - 16:,
        F_CTR_NF         1:1 -  1:,       
        F_END_NT         2:1 -  2:,       
        F_SEC_NF         3:1 -  3:,       
        F_UWY_NF         4:1 -  4:,       
        F_UW_NT          5:1 -  5:,       
        F_CRE_D          6:1 -  6:,       
        F_PRS_CF         7:1 -  7:,       
        F_ACMTRS_NT      8:1 -  8:,       
        F_SSD_CF         9:1 -  9:,
        F_ADMMOD_CT     15:1 - 15:,       
        F_CLODAT_D      16:1 - 16:,
        F_ORICOD_LS     17:1 - 17:,
        F_UPDUSR_CF     18:1 - 18:,
        F_CREUSR_CF     19:1 - 19:,
        F_LSTUPD_D      20:1 - 20:,
        F_CMT_NT        22:1 - 22:,
        F_INCURREDCI_M  23:1 - 23:,
        COLS1            1:1 - 23:
/joinkeys
         CTR_NF   
        ,END_NT   
        ,SEC_NF   
        ,UWY_NF   
        ,UW_NT    
        ,PRS_CF   
        ,ACMTRS_NT
        ,SSD_CF
        ,ADMMOD_CT
        ,CLODAT_D
/INFILE ${EPO_FCTRESTA} 500 1 "~"
/joinkeys
         F_CTR_NF   
        ,F_END_NT   
        ,F_SEC_NF   
        ,F_UWY_NF   
        ,F_UW_NT    
        ,F_PRS_CF   
        ,F_ACMTRS_NT
        ,F_SSD_CF
        ,F_ADMMOD_CT
        ,F_CLODAT_D
/JOIN UNPAIRED rightside
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:COLS1
exit
EOF
	SORT

else

	NSTEP=${NJOB}_180A
	# touch ${DFILT}/${NJOB}_170A_${IB}_SORT_FCTRESTANew_O.dat
	#---------------------------------------------------------------
	LIBEL="touch ${DFILT}/${NJOB}_170A_${IB}_SORT_FCTRESTANew_O.dat"
	EXECKSH_MODE=P
	EXECKSH "touch ${DFILT}/${NJOB}_170A_${IB}_SORT_FCTRESTANew_O.dat"

fi	

NSTEP=${NJOB}_190
# Cumulate types 'A' and 'F' to be loaded
#-----------------------------------------------------------------------------
LIBEL="Cumulate types 'A' and 'F' to be loaded"
SORT_I=${DFILT}/${NJOB}_150F_${IB}_SORT_FCTRESTFNew_O.dat
SORT_I2=${DFILT}/${NJOB}_170A_${IB}_SORT_FCTRESTANew_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTREST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

#[005] Case EBS
if [  ${NORME_CF} = "EBS" ]
then

NSTEP=${NJOB}_200
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Test if first POSE"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
BCP_QRY="if Exists (
            select 1 from BEST..TI17reqjobplan
            where LAUNCH_D is null
            and  CLOTYP_CT = 'POS'
            and  NORME_CF = 'EBSE'
            and  BALSHEYEA_NF = ${PARM_BALSHEYEA_NF}
            and  BALSHTMTH_NF = ${PARM_BALSHTMTH_NF}
            and  DBCLO_D = '${PARM_CRE_D}'
			and  SITE_CF = '${param_site_cf}'
            and not Exists (
				select 1 from BEST..TI17reqjobplan
				where LAUNCH_D is not null
				and  CLOTYP_CT = 'POS'
				and  NORME_CF = 'EBSE'
				and  BALSHEYEA_NF = ${PARM_BALSHEYEA_NF}
				and  BALSHTMTH_NF = ${PARM_BALSHTMTH_NF}
				and  DBCLO_D < '${PARM_CRE_D}'
				and  SITE_CF = '${param_site_cf}'
				)
			)
          	select 'loadNotDone'  -- Fonctionnement en mode delete and load QTR
         else if  Exists (
			select 1 from BEST..TCTREST a,  BREF..TBATCHSSD b
			where a.SSD_CF = b.SSD_CF
			and   b.BATCHUSER_CF = suser_name()
			and   a.PRS_CF = ${PRS_CF}
			and   a.CLODAT_D = '${PARM_ICLODAT_D}'
			)
          	select 'loadDone'      -- Fonctionnement en mode update QTR
         else
            select 'loadNotDone'   -- Fonctionnement en mode delete and load QTR
        "
BCP

else #case IFRS4 POSI

NSTEP=${NJOB}_200
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Test if records exist into TCTREST for PRS_CF ${PRS_CF} QTR ${PARM_ICLODAT_D}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
BCP_QRY="if Exists (
	        select 1 from BEST..TCTREST a,  BREF..TBATCHSSD b
          where a.SSD_CF = b.SSD_CF
          and   b.BATCHUSER_CF = suser_name()
          and   a.PRS_CF = ${PRS_CF}
          and   a.CLODAT_D = '${PARM_ICLODAT_D}')
          	select 'loadDone'      -- Fonctionnement en mode update QTR
          else
            select 'loadNotDone'   -- Fonctionnement en mode delete and load QTR
		"
BCP

fi

echo "#"
echo "#####"
cat ${DFILT}/${NJOB}_200_${IB}_SQL_O1.log
echo "#####"

if [ `grep -c "loadDone" ${DFILT}/${NJOB}_200_${IB}_SQL_O1.log` -gt 0 ]
then

	# Il y a des lignes à charger par update

	NSTEP=${NJOB}_210
	# Create Table BTRAV..EST_ESPD8000_TCTREST
	#------------------------------------------------------------------------------
	LIBEL='Create Table BTRAV..EST_ESPD8000_TCTREST'
	ISQL_BASE=BTRAV
	ISQL_O=${DFILT}/${NSTEP}_${IB}_TAB_EST_ESPD8000_TCTREST.log
	ISQL_QRY=${DDDL}/BTRAV_EST_ESPD8000_TCTREST.tab
	ISQL
	
	NSTEP=${NJOB}_220
	# BCP in table BTRAV..EST_ESPD8000_TCTREST
	#------------------------------------------------------------------------------
	LIBEL="BCP in table BTRAV..EST_ESPD8000_TCTREST"
	BCP_WAY="IN"
	BCP_VER=""
	BCP_I=${DFILT}/${NJOB}_190_${IB}_SORT_FCTREST_O.dat
	BCP_TABLE="BTRAV..EST_ESPD8000_TCTREST"
	BCP

	NSTEP=${NJOB}_230
	# Delete and Insert into TCTREST for PRS_CF ${PRS_CF}
	#------------------------------------------------------------------------------
	LIBEL="Delete and Insert into TCTREST for PRS_CF ${PRS_CF}"
	ISQL_BASE="BEST"
	ISQL_QRY="delete BEST..TCTREST 
	          from BEST..TCTREST a, BTRAV..EST_ESPD8000_TCTREST b
	          where a.CTR_NF = b.CTR_NF
	          and   a.END_NT = b.END_NT
	          and   a.SEC_NF = b.SEC_NF
	          and   a.UWY_NF = b.UWY_Nf
	          and   a.UW_NT  = b.UW_NT
	          and   a.PRS_CF = b.PRS_CF
	          and   a.ACMTRS_NT = b.ACMTRS_NT
	          and   a.SSD_CF = b.SSD_CF
	          and   a.CLODAT_D = b.CLODAT_D
	          and   a.ADMMOD_CT = b.ADMMOD_CT
	          and   convert(varchar, a.CRE_D, 21) = case When b.ADMMOD_CT = 'F' then convert(varchar, b.CRE_D, 21) else convert(varchar, a.CRE_D, 21) end
	          insert BEST..TCTREST
	          select * from BTRAV..EST_ESPD8000_TCTREST"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log          
	ISQL

	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> Save FCTREST Updated"
	gzip -c ${DFILT}/${NJOB}_190_${IB}_SORT_FCTREST_O.dat > ${DARCH}/${NCHAIN}_FCTREST_${PARM_CRE_D}_updated.dat.gz
	ECHO_LOG "#========================================================================="

else

	# 1er jour du POSE, on charge tout le fichier qui contient le nouveau trimestre

	NSTEP=${NJOB}_240
	# Sort on CRE_D Descending
	#-----------------------------------------------------------------------------
	LIBEL="Sort on CRE_D Descending"
	SORT_I=${EPO_FCTREST1}
	SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTREST_O.dat
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        ADMMOD_CT 15:1 - 15:,
        CLODAT_D  16:1 - 16:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      ADMMOD_CT,
      CLODAT_D,
      CRE_D DESC
/CONDITION bilan CLODAT_D = "${PARM_ICLODAT_D}"
/INCLUDE bilan
exit
EOF
	SORT

	NSTEP=${NJOB}_250
	# We keep only the last versus of each key for a quarter based on CRE_D
	#-----------------------------------------------------------------------------
	LIBEL="We keep only the last versus of each key for a quarter based on CRE_D"
	SORT_I=${DFILT}/${NJOB}_240_${IB}_SORT_FCTREST_O.dat
	SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTREST_O.dat
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        ADMMOD_CT 15:1 - 15:,
        CLODAT_D  16:1 - 16:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      ADMMOD_CT,
      CLODAT_D
/STABLE
/SUM
exit
EOF
	SORT

	NSTEP=${NJOB}_260
	# Delete into TCTREST for PRS_CF ${PRS_CF}
	#------------------------------------------------------------------------------
	LIBEL="Delete into TCTREST for PRS_CF ${PRS_CF}"
	ISQL_BASE="BEST"
	ISQL_QRY="delete BEST..TCTREST 
	          from BEST..TCTREST a,  BREF..TBATCHSSD b
	          where a.SSD_CF = b.SSD_CF
	          and   b.BATCHUSER_CF = suser_name()
	          and   a.PRS_CF = ${PRS_CF}
	          and   a.CLODAT_D = '${PARM_ICLODAT_D}'"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log          
	ISQL
	
	#[002]
	NSTEP=${NJOB}_270
	# BCP in table BEST..TCTREST
	#------------------------------------------------------------------------------
	LIBEL="BCP in table BEST..TCTREST"
	BCP_WAY="IN"
	BCP_VER=""
	BCP_I=${DFILT}/${NJOB}_250_${IB}_SORT_FCTREST_O.dat
	BCP_UPDATE_INDEX_STAT=YES
	BCP_TABLE="BEST..TCTREST"
	BCPIN_SPECIAL_OPT="-b50000"
	BCP

	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> Save FCTREST Loaded"
	gzip -c ${DFILT}/${NJOB}_250_${IB}_SORT_FCTREST_O.dat > ${DARCH}/${NCHAIN}_FCTREST_${PARM_ICLODAT_D}_loaded.dat.gz
	ECHO_LOG "#========================================================================="
	
fi

JOBEND
