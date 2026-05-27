#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATION - INVENTAIRE
#                                 Extracting binary life tables
#                                 en fichiers binaires
# nom du script SHELL		: ESCJ0061.cmd
# revision			: $Revision:   1.4  $
# date de creation		: 17/10/97
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Extracting binary life tables.
#-----------------------------------------------------------------------------
# historique des modifications
#  G. BUISSON    08/09/2003    Ajout du parametre BALSHTMTH_NF dans le programme
#                              ESIX0061.c pour eviter de prendre les lignes posterieures
#                              au mois bilan a traiter suite au deblocage des periodes
#                              exceptionnelles
#
#  J.Ribot      26/08/2004    ajout extraction  EST_FLIFTHR
#  M. DJELLOULI  07/02/2005    Integration Ventilation Non Prop - MOD003
#                      Ajout des STEPS :  NSTEP=15       Extraction EST_FTRSLNK7
#  M. DJELLOULI  18/05/2005    Integration Ventilation Non Prop - MOD004
#                      Ajout des STEPS :  NSTEP=20       Extraction EST_FTFAMCHG
#  J. Ribot      05/10/2006    modif du step00 FTFAMCHG non pris en compte a cause des "  mal plac�es
#[006] 02/02/2012 Roger Cassis :spot:23329 - Ajout suppression des fichiers flags declencheurs de Onegl OSGL0010.
#[007] 16/10/2013 Roger Cassis :spot:25427 Closing batches adaptation for centralization, ajout jointure table filiales
#[008] 08/09/2015 Gwendal Bonnerue : correction de la step 00 pour l'evocard26
#[009] 04/02/2016 -=Dch=-  :spot:29162 - Impact Retro - P&C
#[010] 07/03/2016 R.BEN EZZINE  :spot:29579 Impact Retro EST
#[011] 13/2/2019 R.Vieville :spira:70045 REQ.L.02.05: Evolution quarterly
#[012] 11/03/2019 R. Cassis :spira:76697 Les fichiers FDETTRS et FTRSLNK sont copies quotidiennement pour le Local dans ESCJ0060 (condition ESCJ0060 perdue remise)
#[013] 30/12/2019 L.ELFAHIM :spira:83846 : Comment some RMFIL for compta teck
#[014] 26/02/2021 M.NAJI Spira 91531  commenter les suppression des fichier permanents  
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2

#NSTEP=${NJOB}_00
##Last version files of ESCJ0060 deletion                   #[008]
##-----------------------------------------------------------------
#RMFIL "  `dirname ${EST_FACMTRSH}`/${NCHAIN}_FACMTRSH*.dat 		
# `dirname ${EST_FBANTECL}`/${NCHAIN}_FBANTECL*.dat
# `dirname ${EST_FCTRFIC}`/${NCHAIN}_FCTRFIC*.dat
# `dirname ${EST_FCURCVSNI}`/${NCHAIN}_FCURCVSNI*.dat
# #`dirname ${EST_FCURQUOT}`/${NCHAIN}_FCURQUOT*.dat    	#[013]
# #`dirname ${EST_FDETTRS}`/${NCHAIN}_FDETTRS*.dat	#[013]
# `dirname ${EST_FGRP}`/${NCHAIN}_FGRP*.dat
# `dirname ${EST_FLIBEL1}`/${NCHAIN}_FLIBEL1*.dat
# `dirname ${EST_FLIBEL2}`/${NCHAIN}_FLIBEL2*.dat
# `dirname ${EST_FLIFDRI}`/${NCHAIN}_FLIFDRI*.dat
# `dirname ${EST_FRETPAR}`/${NCHAIN}_FRETPAR*.dat
# `dirname ${EST_FRETTRF}`/${NCHAIN}_FRETTRF*.dat
# `dirname ${EST_FSEGPAR}`/${NCHAIN}_FSEGPAR*.dat
# `dirname ${EST_FSSDACTR}`/${NCHAIN}_FSSDACTR*.dat
# `dirname ${EST_FSUBSID}`/${NCHAIN}_FSUBSID*.dat
# `dirname ${EST_FTRSLNK}`/${NCHAIN}_FTRSLNK*.dat
# `dirname ${EST_FTRSLNK7}`/${NCHAIN}_FTRSLNK7*.dat
# `dirname ${EST_FSOBBLOB}`/${NCHAIN}_FSOBBLOB*.dat
# `dirname ${EST_FSEGMENT}`/${NCHAIN}_FSEGMENT*.dat
# `dirname ${EST_FCLIENT}`/${NCHAIN}_FCLIENT*.dat
# #`dirname ${EST_FBOPRSLNK}`/${NCHAIN}_FBOPRSLNK*.dat #[013]
# `dirname ${EST_FCURCVSN}`/${NCHAIN}_FCURCVSN*.dat
# `dirname ${EST_FLIFTHR}`/${NCHAIN}_FLIFTHR*.dat
# `dirname ${EST_FTFAMCHG}`/${NCHAIN}_FTFAMCHG*.dat
# `dirname ${EST_FTRANSCODE}`/${NCHAIN}_FTRANSCODE*.dat
# `dirname ${EPO_FTRSLNK8}`/${NCHAIN}_FTRSLNK8*.dat" 

#[006]
NSTEP=${NJOB}_01
# Begin Sort
#-----------------------------------------------------------------
LIBEL="RM of the flag files that manage OneGL launching"
RMFIL "${DTMP}/${PCH}OTGL0010I.OK"
RMFIL "${DTMP}/${PCH}OTGL0010P.OK"
RMFIL "${DTMP}/${PCH}OSGL0010.OK"

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

#[007]
NSTEP=${NJOB}_10
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
	BCP
fi


if [ "${NCHAIN}" = "${ENV_PREFIX}_ESCJ0060" ]
then
	#[012]
	NSTEP=${NJOB}_11
	# copy files
	#----------------------------------------------------------------------------
	LIBEL="cp ${EST_FDETTRS} and ${EST_FTRSLNK} for Local"
	EXECKSH_MODE=P
	EXECKSH "cp ${EST_FDETTRS} ${ESL_FDETTRS}"
	EXECKSH "cp ${EST_FTRSLNK} ${ESL_FTRSLNK}"
fi

NSTEP=${NJOB}_15
# Extraction des Postes Comtpables TRSLNK Regroupement 720
#------------------------------------------------------------------------------
LIBEL="Extraction des Postes Comtpables TRSLNK  Regroupement 720"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FTRSLNK7}
BCP_QRY="exec BEST..PsTRSLNK_03"
BCP

NSTEP=${NJOB}_20
# Extraction des Flags pour Postes a Risques des Traites TFAMCFG, TFAMCOTP, TFAMLIA
#------------------------------------------------------------------------------
LIBEL="Extraction des Flags pour Postes a Risques des Traites TFAMCFG, TFAMCOTP, TFAMLIA"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FTFAMCHG}
BCP_QRY="exec BTRT..PsTFAMCHG_01"
BCP

NSTEP=${NJOB}_25
#Generation of Ctr/Nat File
#-----------------------------------------------------------------------------
LIBEL="Contrat / Nature de contrat"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FCTRNAT}" # MWMWMWMW   A REVOIR PAR ROGER !! MWMWMWMWM
BCP_QRY="select t.CTR_NF , t.NAT_CF from BTRT..TSECTION t inner join BREF..TBATCHSSD b on t.SSD_CF = b.SSD_CF and b.BATCHUSER_CF = suser_name()
union 
select f.CTR_NF , f.NAT_CF from BFAC..TSECTION f inner join BREF..TBATCHSSD b on f.SSD_CF = b.SSD_CF and b.BATCHUSER_CF = suser_name() order by 1"
BCP

JOBEND
