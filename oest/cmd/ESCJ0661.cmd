#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESCJ0661.cmd
# revision                      : 
# date de creation              : 06/09/2021
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Extraction quatidienne des  fichiers
#
# job launched by ESCJ0660.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : 
#Auteur         : M.NAJI
#Date           : 06/09/2021
#Version        : 1.0
#Description    :Extraction quatidienne des  fichiers
#===============================================================================
#[001] 06/09/2021  :spira:91532 Création
#[002] 14/02/2022 Dad spira : 94569 add Condition on contract recognition date and inception dates in pericase extractions
#[003] 14/04/2022 Dad spira : 103830 fix PARALLEL_INIT parameter
#[004] 04/20/2022 JBD  spira : 102774 Update cessh_r to 0
#[005] 25/04/2022 DaD  spira : 94569 add parameter Quarter End
#[006] 31/05/2022 RC  :spira:104409 Gestion de la mise à jour de BEST..TCTRGRO pour EBS/POS
#[007] 07/10/2022 MZM :Spira 105560 LO FACTOR Table update process : Generation du Fichier LOFACTOR en EBV INV dans ce JOB (copie du Bloc contenu dans ESPJ0091 dans ce JOB)
#[008] 12/06/2023 DaD :Spira 109579 New file FCES type to be created including the RETRO link that will include the historical links
#[009] 08/02/2024 FCI :Spira 101193 EBS / I17 - Fac Accepted
#[009] 15/03/2024 HR  :Spira 111062 I17 - No retro link for LC assumed cession on onerous Q+1 
#[010] 20/03/2024 DAD :Spira 110913 - Add new extract ESF_FTUWSEC
#[011] 10/06/2024 HR  :Spira 110855 PRD - POC- Issue with FX round2 final
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#====================================INPUT FILES====================="
ECHO_LOG "#===> DIP_CSM_BU..........................................................: ${DIP_CSM_BU}"
ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================INPUT PARAMETERS====================="
ECHO_LOG "#===> PARM_ICLODAT_D.....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> NORME_CF...........................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV............................................................: ${TYPEINV}"
ECHO_LOG "#===> X_DAYS.............................................................: ${X_DAYS}"
ECHO_LOG "#===> QUARTER_END_FOUND..................................................: ${QUARTER_END_FOUND}"
ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================OUTPUT FILES====================="
ECHO_LOG "#===> ESF_FLORETFACTOR_ALL...............................................: ${ESF_FLORETFACTOR_ALL}"

# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
ICLODAT_D=$4
CLODAT_D=$5
OPTION=Q
SSD_CF=00
SEGTYP_CT=A

if [ "$VSERQS_I4I" = "YES" ]
then

        PARALLEL_INIT 48
else
        PARALLEL_INIT 51
fi 

NSTEP=${NJOB}_015
# Generation of EST_FSSDACTR  (text format)
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FSSDACTR (text format) "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FSSDACTR_TXT}
BCP_QRY="exec BEST..PsSSDACTR_01"
if [ "$VSERQS_I4I" != "YES" ]
then
        PARALLEL BCP
fi 

#[006] Steps deplacees dans ESCJ0663
#NSTEP=${NJOB}_020
## Begin BCP
##-----------------------------------------------------------------------------
#LIBEL="Download of BEST..TCTRGRO table"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${EST_FCTRGRO0}
#BCP_QRY="execute BEST..PsSECTION_10 '${OPTION}', '${SEGTYP_CT}'"
#PARALLEL BCP

NSTEP=${NJOB}_025
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMT0}
BCP_QRY="execute BEST..PsPLACEMT_01"
PARALLEL BCP

NSTEP=${NJOB}_030
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMT1}
BCP_QRY="execute BEST..PsPLACEMT_03"
PARALLEL BCP

#[003]
NSTEP=${NJOB}_035
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMT2}
BCP_QRY="execute BEST..PsPLACEMT_05"
PARALLEL BCP

NSTEP=${NJOB}_040
#Generation of CADVPERIESB0 File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of CADVPERIESB0 Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_CADVPERIESB0}"
BCP_QRY="select ctr_nf,end_nt,uwy_nf,uw_nt,accesb_cf
 from BFAC..TCONTR a, BREF..TBATCHSSD c
  where a.SSD_CF=c.SSD_CF
    and c.BATCHUSER_CF=suser_name()
union
select a.ctr_nf,a.end_nt,a.uwy_nf,a.uw_nt,a.accesb_cf
 from BFAC..TSECTION_DEL a, BREF..TBATCHSSD c
  where not exists(select 1 from BFAC..TCONTR b where b.ctr_nf=a.ctr_nf and b.end_nt=a.end_nt and b.uwy_nf=a.uwy_nf and b.uw_nt=a.uw_nt)
    and a.SSD_CF=c.SSD_CF
    and c.BATCHUSER_CF=suser_name()
union 
select ctr_nf,end_nt,uwy_nf,uw_nt,accesb_cf
 from btrt..tcontr a, BREF..TBATCHSSD c
  where a.SSD_CF=c.SSD_CF
    and c.BATCHUSER_CF=suser_name()
order by 1 ,2,3,4"
PARALLEL BCP

NSTEP=${NJOB}_045
#Generation of CRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRVPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_CRVPERICASE0_O.dat
BCP_QRY="execute BEST..PsSECTION_26 "
PARALLEL  BCP

NSTEP=${NJOB}_050
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of FTVENTNP"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FTVENTNP} #copy of EST_FVENTNPANT
BCP_QRY="execute BRET..PsTVENTNP_01"
PARALLEL  BCP

NSTEP=${NJOB}_060
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Selection of the last ultimates by contract"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCTRULT}
BCP_QRY="execute BEST..PsCTRULT_01 '${OPTION}'"
PARALLEL BCP

NSTEP=${NJOB}_070
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="cumul placements"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FPLATXCUM0}"
BCP_QRY="execute BRET..PsPLACEMT_35"
PARALLEL BCP

NSTEP=${NJOB}_075
#Download to the XADPERIFCI Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCI Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_IADPERIFCI}
BCP_QRY="execute BEST..PsSECTION_04 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
PARALLEL BCP

NSTEP=${NJOB}_085
#Download to the XADPERIFCT Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCT perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_IADPERIFCT0} 
BCP_QRY="execute BEST..PsSECTION_05 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_090
#Download to the XADPERIFR Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFR Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_IADPERIFR} 
BCP_QRY="execute BEST..PsSECTION_03 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}'"
PARALLEL BCP

NSTEP=${NJOB}_095
#Constituting treaty perimeter file with BTRT database fields
#In case of subsidary 00, all the subsidaries are taken into account
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Treaties perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASETRT_O.dat
# [005]
if [ ${TYPEINV} = "POS"	]
then
#[009]
  BCP_QRY="execute BEST..PsPERITRT_02 '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
else
  BCP_QRY="execute BEST..PsPERITRT_02 '${SEGTYP_CT}' with recompile"
fi
PARALLEL BCP

#[009] change for INV
NSTEP=${NJOB}_100
#Generation of IRDPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRDPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_IRDPERICASE0}
# [005]
if [ ${TYPEINV} = "POS"	]
then
  BCP_QRY="execute BEST..PsSECTION_08 '${SEGTYP_CT}', ${SSD_CF}, '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}'"
else
  BCP_QRY="execute BEST..PsSECTION_08 '${SEGTYP_CT}', ${SSD_CF}, '${PARM_ICLODAT_D}'"
fi
PARALLEL BCP

NSTEP=${NJOB}_110
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="cumul placements"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FPLATXCUMALL0}"
BCP_QRY="execute BRET..PsPLACEMT_35 'ALL'"
PARALLEL BCP

NSTEP=${NJOB}_115
#Download to the file of charges reiterated and used for the CTBCOM_B
#Field Calculation for treaties.
#-----------------------------------------------------------------------------
LIBEL="Current Generation of reiterated Charges file..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FAMCHG2_O.dat
BCP_QRY="execute BEST..PsSECTION_09 ${SSD_CF}, '${CRE_D}'"
PARALLEL BCP

NSTEP=${NJOB}_125
#Constituting treaty perimeter file with BTRT database fields
#In case of subsidary 00, all the subsidaries are taken into account
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Treaties perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASETRT_O.dat
BCP_QRY="execute BEST..PsPERITRT_03 '${SEGTYP_CT}'"
PARALLEL BCP

NSTEP=${NJOB}_130
#Download to the file, the fields necessary to the
#facultatives perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Facs Perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASEFAC_O.dat
BCP_QRY="execute BEST..PsPERIFAC_03 '${SEGTYP_CT}'"
PARALLEL BCP

NSTEP=${NJOB}_135
#Generation of IRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRVPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_21 '${SEGTYP_CT}', ${SSD_CF}"
PARALLEL BCP

NSTEP=${NJOB}_150
#Generation of ORDPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRDPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_46 '${SEGTYP_CT}'"
PARALLEL BCP

NSTEP=${NJOB}_155
#Generation of IRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of ORVPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_47 '${SEGTYP_CT}'"
PARALLEL BCP

NSTEP=${NJOB}_160
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BEST..TCTRGROlife table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FVCTRGRO0}
BCP_QRY="execute BEST..PsFVCTRGRO_01 '${OPTION}', '${SEGTYP_CT}'"
PARALLEL BCP

NSTEP=${NJOB}_165
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession commuted placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMTCOM} #=EST_FPLACEMTCOM0
BCP_QRY="execute BEST..PsPLACEMT_10"
PARALLEL BCP

NSTEP=${NJOB}_170
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of binary format Files"
PRG=ESTX3602
export ${PRG}_O1=${EST_FBSEGEST}
PARALLEL EXECPRG

NSTEP=${NJOB}_180
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BCTA..TAPR table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FAPR0}
BCP_QRY="execute BEST..PsAPR_01 '${OPTION}'"
PARALLEL BCP

NSTEP=${NJOB}_185
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BFAC..TFAMPROT table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FAMPROT0}
BCP_QRY="execute BEST..PsFAMPROT_01"
PARALLEL BCP

NSTEP=${NJOB}_190
#Download to the file, the fields necessary to the
#facultatives perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Facs Perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASEFAC_O.dat
# [005]
if [ ${TYPEINV} = "POS"	]
then
  BCP_QRY="execute BEST..PsPERIFAC_02 '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
else
  BCP_QRY="execute BEST..PsPERIFAC_02 '${SEGTYP_CT}' with recompile"
fi
PARALLEL BCP

#[010]
NSTEP=${NJOB}_195
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
PARALLEL EXECPRG

NSTEP=${NJOB}_200
#Generation of IRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRVPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_IRVPERICASE0}  
BCP_QRY="execute BEST..PsSECTION_21 '${SEGTYP_CT}', ${SSD_CF}"
PARALLEL BCP

NSTEP=${NJOB}_205
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession Cessions File"
BCP_WAY="OUT"
BCP_VER="+"
if [ "X${PARM_ICLODAT_QTR}" = "X4" ] & [ "X${PARM_ICLODAT_YEA}" = "X2021" ]
then
    BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_EST_FCESSION0.dat
else
    BCP_O=${EST_FCESSION0}
fi
BCP_QRY="execute BEST..PsCESSION_01"
PARALLEL BCP


# [008]
NSTEP=${NJOB}_206
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession Cessions File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCESSION1}
BCP_QRY="execute BEST..PsCESSION_04"
PARALLEL BCP

# END CONCURRENT STEPS
# -------------------------

NSTEP=${NJOB}_210
#Generation of FCURCVSN0 File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of FCURCVSN0 Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FCURCVSN}"
BCP_QRY="select distinct a.ssd_cf, a.retctr_nf, a.rty_nf, a.plc_nt
         from bret..tcurcvsn a, BREF..TBATCHSSD b
         where plc_nt > 0
         and a.SSD_CF=b.SSD_CF
         and b.BATCHUSER_CF=suser_name()
         order by a.ssd_cf, a.retctr_nf, a.rty_nf, a.plc_nt"
if [ "$VSERQS_I4I" != "YES" ]
then
        PARALLEL BCP
fi


NSTEP=${NJOB}_215
# Extraction des Postes Comtpables TRSLNK ( en text )
#------------------------------------------------------------------------------
LIBEL="Extraction des Postes Comtpables TRSLNK ( en text )"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_TXT.dat"
BCP_QRY="exec BEST..PsTRSLNK_02"
PARALLEL BCP

NSTEP=${NJOB}_225
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FSSDACTR"
PRG=ESTX0005
export ${PRG}_O1=${EST_FSSDACTR}
if [ "$VSERQS_I4I" != "YES" ]
then
        PARALLEL EXECPRG
fi

NSTEP=${NJOB}_230
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FCLIENT"
PRG=ESTX0007
export ${PRG}_O1=${EST_FCLIENT}
PARALLEL EXECPRG

NSTEP=${NJOB}_240
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="extraction of  EST_FCLIENT_TXT in TXT mode : $EST_CLIENT_TXT"
#extraction of  EST_FCLIENT_TXT in TXT mode
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FCLIENT_TXT}"
BCP_QRY="execute BCLI..PsCLIENT_110"
PARALLEL BCP

NSTEP=${NJOB}_245
#------------------------------------------------------------------------------
LIBEL="Read date in T_TMAPPING table"
PRG=ESTX0009
export ${PRG}_O1=${EST_FPRSMAP}
PARALLEL EXECPRG

NSTEP=${NJOB}_250
# Extraction  date in T_TMAPPING table  (text format)
#------------------------------------------------------------------------------
LIBEL="Extraction  date in T_TMAPPING table (text format) "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPRSMAP_TXT}
BCP_QRY="exec BREF..PsTMAPPING_01"
PARALLEL BCP

NSTEP=${NJOB}_255
# Extraction des Postes Comtpables TDETTRS ( en text )
#------------------------------------------------------------------------------
LIBEL="Extraction des Postes Comtpables TDETTRS ( en text )"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FDETTRS_TXT}
BCP_QRY="exec BEST..PsDETTRS_11"
PARALLEL BCP

NSTEP=${NJOB}_260
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Complete Accounts Files"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCPLACC}
BCP_QRY="execute BEST..PsCPLACC_02 '${CLODAT_D}'"
PARALLEL BCP

NSTEP=${NJOB}_265
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="SOLVENCY Generation of FRATINGSII File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FRATINGRTO}
BCP_QRY="exec BEST..PsFRATINGRTO_01"
PARALLEL BCP

NSTEP=${NJOB}_270
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="SOLVENCY Generation of FCURSII File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCURSII}
BCP_QRY="exec BEST..PsFCURSII_01 '${ICLODAT_D}'"  # remplace par'${CLODATMAX_D}'
PARALLEL BCP

NSTEP=${NJOB}_275
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of FTHRHLDUWY"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${EST_FTHRHLDUWY}
BCP_QRY="BEST..PsTHRHLDUWY_01"
PARALLEL  BCP

NSTEP=${NJOB}_280
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Selection of service writings and update of service writings table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FACCSUP0}
BCP_QRY="exec BEST..PiESTACCSUP_02 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CLODAT_D}','N'" 
PARALLEL  BCP

NSTEP=${NJOB}_285
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Acceptation Funds Held..."
CP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FWHGTA}
BCP_QRY="exec BEST..PsACCTRN_FWH_01 '${ICLODAT_D}'"
PARALLEL  BCP

NSTEP=${NJOB}_290
#Begin isql
#-----------------------------------------------------------------------------
IBEL="Retrocession Funds Held..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FWHGTR}
BCP_QRY="exec BEST..PsRACCTRN_FWH_01 '${ICLODAT_D}'"
PARALLEL  BCP

NSTEP=${NJOB}_295
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of statistic amounts table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_SORT_FUNDSTA0_O.dat 
BCP_QRY="execute BEST..PsUNDSTA_01"
PARALLEL  BCP

#######################################################################################################################
#Switch on INFO CENTER server defined in the environment file
#----------------------------------------------------------------
SWITCH_SRV ${SRV_DW}

#[006] Steps deplacees dans ESCJ0663
#NSTEP=${NJOB}_300
##Generation of FCTRGROLESII File
##-----------------------------------------------------------------------------
#LIBEL="FCTRGROLESII Segment File Generation from TUWSEC..."
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O="${EST_FCTRGROLESII}"
#BCP_QRY="execute BSAR..PsRISKMARGIN_SEG '${ICLODAT_D}', 'POS'  with recompile"
#PARALLEL BCP

NSTEP=${NJOB}_320
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of EST_FBOPRSLNK"
PRG=ESTX0008
export ${PRG}_O1=${EST_FBOPRSLNK}
PARALLEL EXECPRG

NSTEP=${NJOB}_325
#extraction of TBOPRSLNK in TXT mode
#-----------------------------------------------------------------------------
LIBEL="extraction of TBOPRSLNK in TXT mode"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FBOPRSLNK_TXT}
BCP_QRY="execute BSAR..PsTBOPRSLNK_01"
PARALLEL BCP

NSTEP=${NJOB}_330
# Extracting TESB for Intraday
#------------------------------------------------------------------------------
LIBEL="Extracting TESB for Intraday"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FESB}
BCP_QRY="execute BREF..PsTESB_01"
PARALLEL BCP

#[010]
NSTEP=${NJOB}_331
LIBEL="Extracting of TUWSEC"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${ESF_FTUWSEC}"
BCP_QRY="select distinct CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, GRPGRP22_NT from BSBO..TUWSEC"
PARALLEL BCP

#Switch on INFO CENTER server defined in the environment file
#----------------------------------------------------------------
SWITCH_SRV ${SRV_TP}
#######################################################################################################################

PARALLEL_END

#[011]
if [ "${NORME_CF}" = "EBS" ] && [ "${TYPEINV}" = "POS" ]
then
 if [ "${ICLODAT_MTH}" = "03" ] || [ "${ICLODAT_MTH}" = "06" ] || [ "${ICLODAT_MTH}" = "09" ] || [ "${ICLODAT_MTH}" = "12" ]
 then 
    NSTEP=${NJOB}_332

    LIBEL="copy ${EST_FCURQUOT} to ${ENV_PREFIX}_ESCJ0660_FCURQUOT_POC_${PARM_ICLODAT_D}.dat file"

    EXECKSH "cp ${EST_FCURQUOT} ${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_POC_${PARM_ICLODAT_D}.dat"
 fi
fi

if [ "${NORME_CF}" = "EBS" ] && [ "${TYPEINV}" = "POC" ]
then
 if [ "${ICLODAT_MTH}" = "03" ] || [ "${ICLODAT_MTH}" = "06" ] || [ "${ICLODAT_MTH}" = "09" ] || [ "${ICLODAT_MTH}" = "12" ]
 then
    NSTEP=${NJOB}_332

    LIBEL="copy ${ENV_PREFIX}_ESCJ0660_FCURQUOT_POC_${PARM_ICLODAT_D}.dat to ${EST_FCURQUOT} file"

    EXECKSH "cp ${DFILP}/${ENV_PREFIX}_ESCJ0660_FCURQUOT_POC_${PARM_ICLODAT_D}.dat ${EST_FCURQUOT}"
 fi
fi

# MOD[004]
if [ "X${PARM_ICLODAT_QTR}" = "X4" ] & [ "X${PARM_ICLODAT_YEA}" = "X2021" ]								
then

NSTEP=${NJOB}_335
# Begin Sort
#------------------------------------------------------------------------------
LIBEL="Update CESSH_R to 0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_205_${IB}_BCP_EST_FCESSION0.dat 2000 1"
SORT_O="${EST_FCESSION0} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 	6:1 -  6:3,
				CESSH_R			13:1 - 13:,
				ZONE_1			1: - 12:,
				ZONE_2			14: - 25:
/CONDITION COND_UPDATE(RETCTR_NF = "RPH" OR RETCTR_NF = "RNA")
/DERIVEDFIELD NEW_CESSH_R IF COND_UPDATE then "0.00000000" ELSE CESSH_R
/COPY
/OUTFILE ${SORT_O}
/REFORMAT ZONE_1, NEW_CESSH_R, ZONE_2
exit
EOF
SORT

fi


########## Extraction journaliere des Fichiers LOFACTOR STD


if [ "${IDF_CT}" = "EBS_ESCJ0660" ]
then

# [007] Deb Generated LOFACTOR STD 


NSTEP=${NJOB}_350
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retro Loss Occuring File ESF_FLORETFACTOR STANDARD"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_STD_O.dat
BCP_QRY="execute BEST..PsLORETFACTOR_02  '${PARM_ICLODAT_D}', '${TYPEINV}'"
BCP

#[017]

### [016]  STEP POUR FORMAT COLONNE LOFACTOR VIA awk
#BCP_O=${ESF_FLORETFACTOR_ALL} 

NSTEP=${NJOB}_355
#------------------------------------------------------------------------------
#LIBEL="FORMAT LOFACTOR" --> ""
#-----------------------------------------------------------------------------
LIBEL="FORMAT LOFACTOR "
AWK_I="${DFILT}/${NJOB}_350_${IB}_BCP_FLORETFACTOR_STD_O.dat"
#AWK_O=${ESF_FLORETFACTOR_ALL}
AWK_O="${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_STD_O.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
		\$30 = sprintf("%-.5f",\$30);
		print \$0;
	}
exit
EOF
AWK

if [ "${DIP_CSM_BU}" != "" ] && [ -s "${DIP_CSM_BU}" ]
then

NSTEP=${NJOB}_360
#------------------------------------------------------------------------------
LIBEL=" Move file from FTP location to temporary location(DFILT)"
EXECKSH "cp ${DIP_CSM_BU} ${DFILT}/${NSTEP}_${IB}_BU.dat"

NSTEP=${NJOB}_365
#------------------------------------------------------------------------------
LIBEL="Convert carriage-returns to Unix"
EXECKSH "dos2unix ${DFILT}/${NJOB}_360_${IB}_BU.dat"

NSTEP=${NJOB}_370
#------------------------------------------------------------------------------
LIBEL="Change sep and remove headers"
awk -F "\t" 'OFS="~"  {if (NR != 1 ) print $1,$5,$2,$3,$4,$6,$10,$7,$8,$9,$11,$12,$13,$14,$15,$16,$17,$18}' ${DFILT}/${NJOB}_360_${IB}_BU.dat > ${DFILT}/${NSTEP}_${IB}_BU_AWK.dat


NSTEP=${NJOB}_375
LIBEL="JOIN FLORETFACTOR WITH BU FILE"
SORT_WDIR=${SORTWORK}S
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_355_${IB}_BCP_FLORETFACTOR_STD_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_STD_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF           1:1     - 1:,
        END_NT           2:1     - 2:,
        SEC_NF           3:1     - 3:,
        UWY_NF           4:1     - 4:,
        UW_NT            5:1     - 5:,
        RETCTR_NF        6:1     - 6:,
        RETEND_NT        7:1     - 7:,
        RETSEC_NF        8:1     - 8:,
        RETRTY_NF        9:1     - 9:,
        RETUW_NT        10:1     - 10:,
        FILLER1          1:1     - 30:,
        FILLER2         31:1     - 31:,
        RCTR_NF         1:1      - 1:,
        REND_NT         2:1      - 2:,
        RSEC_NF         3:1      - 3:,
        RUWY_NF         4:1      - 4:,
        RUW_NT          5:1      - 5:,
        RRETCTR_NF      6:1      - 6:,
        RRETEND_NT      7:1      - 7:,
        RRETSEC_NF      8:1      - 8:,
        RRETRTY_NF      9:1      - 9:,
        RRETUW_NT      10:1      - 10:,
        LOFACTORSTD_R  11:1      - 11:
/JOINKEYS
        CTR_NF,
		END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
		RETEND_NT,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT
/INFILE ${DFILT}/${NJOB}_370_${IB}_BU_AWK.dat 2000 1 "~"
/JOINKEYS
        RCTR_NF,
		REND_NT,
        RSEC_NF,
        RUWY_NF,
        RUW_NT,
        RRETCTR_NF,
		RRETEND_NT,
        RRETSEC_NF,
        RRETRTY_NF,
        RRETUW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        LEFTSIDE:FILLER1, RIGHTSIDE:LOFACTORSTD_R, LEFTSIDE:FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_380
LIBEL="Reformat FLORETFACTOR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_375_${IB}_BCP_FLORETFACTOR_STD_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_STD_NOMATCH_O.dat OVERWRITE 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_STD_O.dat OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF           1:1     - 1:,
        END_NT           2:1     - 2:,
        SEC_NF           3:1     - 3:,
        UWY_NF           4:1     - 4:,
        UW_NT            5:1     - 5:,
        RETCTR_NF        6:1     - 6:,
        RETEND_NT        7:1     - 7:,
        RETSEC_NF        8:1     - 8:,
        RETRTY_NF        9:1     - 9:,
        RETUW_NT        10:1     - 10:,
        FILLER1          1:1     - 29:,
        LOFACTORSTD_R   30:1     - 30:,
        BULOFACTORSTD_R 31:1     - 31:,
        FILLER2         32:1     - 32:
/DERIVEDFIELD
        COMMENT "LOFACTORSTD_R"
/KEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT
/CONDITION BUPROVIDED ( BULOFACTORSTD_R = "" )
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, LOFACTORSTD_R, FILLER2
/INCLUDE BUPROVIDED
/OUTFILE ${SORT_O2}
/REFORMAT FILLER1, BULOFACTORSTD_R, FILLER2
/OMIT BUPROVIDED

exit
EOF
SORT


NSTEP=${NJOB}_385
LIBEL="merge FLORETFACTOR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_380_${IB}_BCP_FLORETFACTOR_STD_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_380_${IB}_BCP_FLORETFACTOR_STD_NOMATCH_O.dat 2000 1"
SORT_O="${ESF_FLORETFACTOR_ALL} OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF           1:1     - 1:,
        END_NT           2:1     - 2:,
        SEC_NF           3:1     - 3:,
        UWY_NF           4:1     - 4:,
        UW_NT            5:1     - 5:,
        RETCTR_NF        6:1     - 6:,
        RETEND_NT        7:1     - 7:,
        RETSEC_NF        8:1     - 8:,
        RETRTY_NF        9:1     - 9:,
        RETUW_NT        10:1     - 10:
/KEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT

exit
EOF
SORT

else

NSTEP=${NJOB}_360
# cp ESF_FLORETFACTOR_ALL 
#------------------------------------------------------------------------------
LIBEL="copy ${DFILT}/${NJOB}_355_${IB}_BCP_FLORETFACTOR_STD_O.dat"
EXECKSH "cp ${DFILT}/${NJOB}_355_${IB}_BCP_FLORETFACTOR_STD_O.dat ${ESF_FLORETFACTOR_ALL}"

fi


fi


#################################### Fin Generation LOFACTOR STD Journaliere



# End of Job
JOBEND
