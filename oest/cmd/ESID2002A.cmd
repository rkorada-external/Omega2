#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESID2002A.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 31/05/2012
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2210.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 18/04/2012 Roger Cassis  :spot:23802 - Modifications pour Solvency
#[002] 12/06/2012 JF VDV        : [23390]   - Modifications pour Solvency
#[003] 22/10/2012 Roger Cassis  :spot:24041 - Modifications pour Solvency
#[004] 25/10/2012 JF VDV        : [24041]   - Modifications pour Solvency
#[005] 25/10/2012 P. PEZOUT     :spot:24778 - Modifications pour Solvency
#[006] 23/05/2014 A. Ben Jeddou :spot 26838 - Corrections sur le batch solvency P&C : reprise de code suite au passage  de 2A à la 1B
#[007] 27/10/2014 G. Legay      :spot:27485 - Ajout d un fichier de Trace pour les IBNR
#[008] 19/11/2014 R. Cassis     :spot:27747 - OM2C Add 39 columns for multicurrency and future life needs
#[009] 05/01/2015 Florent       :spot:27485 - on tient compte de 2014 avec ancien programme
#[010] 04/02/2015 F Maragnes    :spot:28140 - Modification des steps 180 ,250 et 310 on passe en parametre le fichier EST_FTLDUWY  utilisé par la fonction calculExerciceSeuil
#                                             Ajout des steps 111 112 113 positionnement du champs sinistralite dans le fichier {NJOB}_${IB}_${PRG}_IADPERICASE_O2.dat
#[011] 09/04/2015 F Maragnes    :spot:28140 - Pour les inventaires Post-Omega EST_FTHRHLDUWY = ${EPO_ FTHRHLDUWY}
#[012] 24/04/2015 R. cassis     :spot:28660 - NPSAIS and IBNR log data file of ESTM1007 and ESTC0626 are intermediary files now
#[013] 09/10/2015 R. cassis     :spot:28140 - Correction de l'affectation du EPO_FTHRHLDUWY
#[014] 12/08/2015 E. CHATAIN    :spot:29066 - Formatage du fichier GLT
#[015] 15/02/2016 -=Dch=-       :spot:30167 - Modification des calculs de commissions: Ajout du prg ESTC1012 et modification du prog et de l'appel de ESTC1018
#[016] 02/05/2016 -=Dch=-       :spot:30465 - Ajout de la log Blanchiment
#[017] 05/12/2016   PGA         SPIRA 50815-47759-47946 change CURGTA for DTSTATGTAA
#[018] 11/01/2017   PGA         SPIRA 58601 - ajout Pericase dans l'ESTC1012 pour avoir le parametrage par defaut des contrat sans poste 113XXXX0
#[018] 30/01/2017 Florent      :spira:55835 - Loss Corridor calculé à l'identique en INV et POST OMEGA
#[019] 02/08/2017 Roger cassis :spira:61387 - Désactivation de la FAR estimée (surcom) si l'option estcomtyp_ct est en mode manuel (valeur = 3)
#[020] 07/02/2018 Roger cassis :spira:xxxxx - Suppression d'un record temporaire qui fait planter le programme
#[021] 08/02/2018 Roger Cassis :spira:67327 - Agrandissemnt du tableau NB_FAM_MAX et ajout controle de depassement de la taille maxi du tableau dans prog ESTC1019
#[022] 11/04/2018 S.Behague    :spira 65703 - FORCAGE IBNR : Ajouter l'obligation de renseigner un commentaire lorsque le mode de gestion est FORCE
#[023] 01/05/2018 Y.Eloutmani  :spira 63970 - FORCAGE IBNR : Conserver les lignes auto quand des lignes forced sont inserees
#[024] 20/07/2018 JYP          : REQ 1000.06 Spira 69871 : new script copied from ESID2002.cmd for VTOM context1
#[025] 05/10/2018 JYP          : IFRS17 req 10.6 : exclude new segtyps V W X from SEGEST file
#[026] 06/12/2018 Roger       : replace EST_DLDGTAACUM by EST_DLDGTAA
#[027] 10/04/2019 Roger        :spira:65656 - 68628 Gestion fichier FCTREST comme pour IFRS - renommage EST_ en EPO_ EST_DLDGTAA renomme en EST_DLDGTAA_CUMULS_COUR - relivraison
#[028] 03/07/2019 Rafael       :spira:77465 - loss corridor : mise en commentaire de ESTC1019 car deplacer dans ESID2003A plus cp des fichier necessaire dans DFILI
#[029] 29/08/2019 Roger        :spira:65656 - suite : Gestion PRS_CF pour IFRS4 ou EBS : ajout parametre PRS_CF dans divers programmes
#[030] 20/09/2019 NLD          :spira:67260 - Ajout input CURQUOT ESTC0623
#[031] 18/11/2019 Roger        :spira:65656 - suite : On force le CLOTYP_CT a P pour EBS - elaguage de l'ancien ESID2002 -> non plus necessaire
#[032] 26/02/2020 Roger        :spira:84424 - pour le mode 'F' force IBNR, on ajoute une colonne dans FCTREST
#[033] 28/04/2020 Roger        :spira:86536 - FCTRESTF remplace FCTREST
#[034] 17/06/2020 Roger        :spira:86536 - Revue gestion FCTREST (suppression partie faite dans ESPD8000)
#[035] 01/10/2020 MZM          :spira:88836 IFRS 17 - REQ 11.07 - Tax rate not applied when section >= 10 : Ajout du parametre CHAIN pour trie par No Section Numerique si CHAIN = ESFD2220
#[036] 11/03/2021 JYP          :spira:94556 - manage mode EBS when microAOC
#[037] 29/03/2021 JYP          :spira:94556 - manage mode EBS when microAOC 
#[038] 22/04/2021 MiS          :spira:90073 - Ajout AE et PNA IFRS17 pour le calcul de DAC IFRS17
#[039] 27/04/2021 Roger        :spira:92617 - Extract Segment Amount type AMORAT_Ct for pgm ESTC0626
#[040] 10/06/2021 JYP/Mehdi/Michael :spira:91532 - do not use VNORME that is for vtom
#[041] 28/06/2021 Roger        :spira:97314 - SEGTYP_CT is set with new normes : POS EBS + IFRS17 => T and W - POC IFRS + POC EBS => U and X - IBNR data from IFRS4 are used for INV EBS
#[042] 01/10/2021 MiS          :spira:97626 - Selection de l'input par rapport au ${TYPEINV}
#[043] 13/01/2021 JYP/Florian/Martin  :spira:101356 97314 : IBNR KO, revert double ratio types VWX
#[044] 19/10/2022 MZM          :spira:100697 - NRT - undue EBS accounts (Tri du fichier IADPERIFR)
#[045] 24/01/2022 HR           :spira 100679 - Aligner le tableau charge de l'ecran SCR-EST-PAC-30677 avec le GT
#[046] 09/11/2022 MZM          :spira:107676 - EBS taxes and PC discrepancies between IN2 and INT  (Tri des fichiesr IADPERIFCT et IADPERIFCI)
#[047] 02/07/2024 MZM          :spira:111818 - NRT July 2024 - Reinstatement Premium not calculated in IN2 (IADPERIFR ADD REILIN_NT et REIRNK_N ON THE KEY SORT)
#=====================================================================================================
#set -x

# ***************************************************************************************
# ***************************************************************************************
# ATTENTION : à faire 
# PHP ajouter colonne PRS_CF dans EST_FT EST_FLOARAT et ensuite forcer 710 ou 730 selon taux
# ***************************************************************************************
# ***************************************************************************************
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
CLOTYP_CT=$3
ICLODAT_D=$4
SSDs=$5
SSDVRS_LL=$6
LSTCLODAT_LL=$7
SSDDEL_LL=$8

PRS=730
COL_NUM323=24  
CLOTYP_CT=P

#[041]
# Default INV EBS but not used because IBNR deactived
segtyp_ct=A
segtyp_ct2=V

if [ "${TYPEINV}" = "POS" ]
then
  # POS EBS + IFRS17
  segtyp_ct=T
  segtyp_ct2=W
fi  
if [ "${TYPEINV}" = "POC" ]
then
  # POC IFRS + POC EBS
  segtyp_ct=U
  segtyp_ct2=X
fi  


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> NORME2 ....................: ${NORME2}"
ECHO_LOG "#===> segtyp_ct .................: ${segtyp_ct}"
ECHO_LOG "#===> segtyp_ct2 ................: ${segtyp_ct2}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CRE_D......................: $CRE_D "
ECHO_LOG "#===> BALSHTYEA_NF...............: $BALSHTYEA_NF "
ECHO_LOG "#===> CLOTYP_CT..................: $CLOTYP_CT    " 
ECHO_LOG "#===> ICLODAT_D..................: $ICLODAT_D    " 
ECHO_LOG "#===> SSDs.......................: $SSDs         " 
ECHO_LOG "#===> SSDVRS_LL..................: $SSDVRS_LL    " 
ECHO_LOG "#===> LSTCLODAT_LL...............: $LSTCLODAT_LL "
ECHO_LOG "#===> SSDDEL_LL..................: $SSDDEL_LL    "
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#===> EST_FTFAMCHG..............: ${EST_FTFAMCHG}"
ECHO_LOG "#===> EPO_FCTREST0..............: ${EPO_FCTREST0}"
ECHO_LOG "#===> EPO_FCTRESTF...............: ${EPO_FCTRESTF}"
ECHO_LOG "#===> EPO_FCTRESTA..............: ${EPO_FCTRESTA}"
ECHO_LOG "#===> EST_DLCGTAA...............: ${EST_DLCGTAA}"
ECHO_LOG "#===> EST_DLGTAAPA..............: ${EST_DLGTAAPA}"
ECHO_LOG "#===> EST_DCGTAALOA.............: ${EST_DCGTAALOA}"
ECHO_LOG "#===> EST_DLGTAAFPRE............: ${EST_DLGTAAFPRE}"
ECHO_LOG "#===> EST_DLCGTAAREC............: ${EST_DLCGTAAREC}"
ECHO_LOG "#===> EST_DLGTAARPPE............: ${EST_DLGTAARPPE}"
ECHO_LOG "#===> EST_DLGTAAPRE.............: ${EST_DLGTAAPRE}"
ECHO_LOG "#===> EST_DLGTAATFPNAE..........: ${EST_DLGTAATFPNAE}"
ECHO_LOG "#===> EST_DLCGTAAEPPE...........: ${EST_DLCGTAAEPPE}"
ECHO_LOG "#===> EST_FTFAC.................: ${EST_FTFAC}"
ECHO_LOG "#===> EST_FCTRGRO...............: ${EST_FCTRGRO}"
ECHO_LOG "#===> EST_FCTRGRO1..............: ${EST_FCTRGRO1}"
ECHO_LOG "#===> EST_LABOCY1...............: ${EST_LABOCY1}"
ECHO_LOG "#===> EST_FSEGEST...............: ${EST_FSEGEST}"
ECHO_LOG "#===> EST_DLDGTAA_IBNRIFRS......: ${EST_DLDGTAA_IBNRIFRS}"
ECHO_LOG "#===> EST_FCURQUOT..............: ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_IADPERIFR.............: ${EST_IADPERIFR}"
ECHO_LOG "#===> EST_IADPERICASE...........: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_DLCUMGTAAS............: ${EST_DLCUMGTAAS}"
ECHO_LOG "#===> EST_FTTR_PRM..............: ${EST_FTTR_PRM}"
ECHO_LOG "#===> EST_IADPERIFCT............: ${EST_IADPERIFCT}"
ECHO_LOG "#===> EST_IADPERIFCI............: ${EST_IADPERIFCI}"
ECHO_LOG "#===> EST_DLCUMGTAA.............: ${EST_DLCUMGTAA}"
ECHO_LOG "#===> EST_FTHRHLDUWY............: ${EST_FTHRHLDUWY}"
ECHO_LOG "#===> EST_DTSTATGTAA............: ${EST_DTSTATGTAA}"
ECHO_LOG "#===> EST_FCTRULT...............: ${EST_FCTRULT}"
ECHO_LOG "#===> EPO_FCTRULT...............: ${EPO_FCTRULT}"
ECHO_LOG "#===> EST_IADPERICASE22 ........: ${EST_IADPERICASE22}     "
ECHO_LOG "#===> EST_DLCUMGTAAR...............: ${EST_DLCUMGTAAR}"
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> EST_BLANCHIMENT_RPCC......: ${EST_BLANCHIMENT_RPCC}"
ECHO_LOG "#===> EST_DLDGTAACUM............: ${EST_DLDGTAACUM}"
ECHO_LOG "#===> EST_DLDGTAA_CUMULS_COUR...: ${EST_DLDGTAA_CUMULS_COUR}"
ECHO_LOG "#===> EST_IBNR..................: ${EST_IBNR}"
ECHO_LOG "#===> EPO_FCTREST1..............: ${EPO_FCTREST1}"
ECHO_LOG "#===> EST_FLOARAT...............: ${EST_FLOARAT}"
ECHO_LOG "#===> EST_FPRMLOA...............: ${EST_FPRMLOA}"
ECHO_LOG "#===> EST_FT....................: ${EST_FT}"

ECHO_LOG "#========================================================================="

                           

#########################
# Split of FCTREST file #
#########################
NSTEP=${NJOB}_10
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort by key section and CLODAT/ACMTRS/CRE_D"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FCTRESTF}
SORT_I2=${EPO_FCTRESTA}    #[027]
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CTREST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF	    9:1 -  9:EN,
        CTR_NF		 1:1 -  1:,
        END_NT		 2:1 -  2:,
        SEC_NF		 3:1 -  3:,
        UWY_NF		 4:1 -  4:,
        UW_NT		 5:1 -  5:,
        CLODAT_D	16:1 - 16:,
        PRS_CF	    7:1 -  7:,
        ACMTRS_NT	 8:1 -  8:,
        CRE_D		 6:1 -  6:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CLODAT_D, ACMTRS_NT, CRE_D
/CONDITION PRS PRS_CF EQ "${PRS}"
/OUTFILE ${SORT_O}
/INCLUDE PRS
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin programme C
#-----------------------------------------------------------------------------
LIBEL="Split of FCTREST file"
PRG=ESTC1022
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLOTYP_CT ${CLOTYP_CT}
CLODAT_D ${ICLODAT_D}
LSTCLODAT_LL ${LSTCLODAT_LL}
SSDDEL_LL ${SSDDEL_LL}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_CTREST_O.dat
export ${PRG}_O1=${EST_CTRESTLOSPBPAP}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRESTCV_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRESTCLM_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_CTREST_O4.dat
EXECPRG

#############################################################
# Calculation of losses and IBNR ( Set 6 encapsulation  )   #
#############################################################

NSTEP=${NJOB}_30
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Omet les mouvements de retro interne du Pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 1000 1"
#SORT_O=${DFILT}/${NCHAIN}_ESID2001_80_${IB}_ESTC1005_IADPERICASE_O2.dat # renomme selon les normes - RC
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O2.dat
EST_IADPERICASE22=${SORT_O}
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF             3:1 -  3:,
        END_NT             4:1 -  4:,
        SEC_NF             5:1 -  5:,
        UWY_NF             6:1 -  6:,
        UW_NT              7:1 -  7:,
        CTRRET_B          20:1 - 20:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION RETINT CTRRET_B = "0"
/INCLUDE RETINT
exit
EOF
SORT

NSTEP=${NJOB}_40
#Tri du fichier FCTRULT par contrat/avenant/section/exercice/numero d'ordre
#-----------------------------------------------------------------------------
LIBEL="FCTRULT file sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FCTRULT}
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CTRULT02_O1.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF	1:1 - 1:,
        END_NT	2:1 - 2:,
        SEC_NF	3:1 - 3:,
        UWY_NF	4:1 - 4:,
        UW_NT	5:1 - 5:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_50
#Accumulation of TL work file on occurence year
#-----------------------------------------------------------------------------
LIBEL="Accumulation of TL work file on occurence year in progress..."
PRG=ESTC0602
export ${PRG}_I1=${EST_DLCGTAA}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTCUMUL_O.dat
EXECPRG

#[029]
NSTEP=${NJOB}_60
#Amount grouping of FCTRULT and TL work file in the perimeter
#SEGTYP_CT ${SEGTYP_CT}
#-----------------------------------------------------------------------------
LIBEL="Generation of PERICASEACT1 file in progress..."
PRG=ESTC0623
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLOTYP_CT ${CLOTYP_CT}
CLODAT_D ${ICLODAT_D}
PRS_CF ${PRS}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_IADPERICASE_O2.dat
#export ${PRG}_I1=${EST_IADPERICASE22} 
export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_SORT_CTRULT02_O1.dat
export ${PRG}_I3=${DFILT}/${NJOB}_50_${IB}_ESTC0602_GTCUMUL_O.dat
export ${PRG}_I4=${EST_FCTRGRO1}
export ${PRG}_I5=${DFILT}/${NJOB}_20_${IB}_ESTC1022_CTRESTCLM_O3.dat
export ${PRG}_I6=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASEEST_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASESEG_O2.dat
EXECPRG


NSTEP=${NJOB}_70
#PERICASESEG file sort by Segment/UW Year/Currency
#-----------------------------------------------------------------------------
LIBEL="PERICASESEG file sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC0623_PERICASESEG_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASESEG_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEG_NF		80:1 - 80:,
        UWY_NF		 6:1 - 6:,
        EGPCUR_CF	23:1 - 23:,
        CTR_NF		 3:1 - 3:,
        END_NT		 4:1 - 4:,
        SEC_NF		 5:1 - 5:,
        UW_NT		 7:1 - 7:
/KEYS	SEG_NF,
      UWY_NF,
      EGPCUR_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_80
#Working file sort by Segment/UW Year/Currency/CTR/END/SEC/UW
#-----------------------------------------------------------------------------
LIBEL="sort ${NJOB}_60_${IB}_ESTC0623_PERICASEEST_O1.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_60_${IB}_ESTC0623_PERICASEEST_O1.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERICASEEST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF		1:1 - 1:,
        END_NT		2:1 - 2:,
        SEC_NF		3:1 - 3:,
        UWY_NF		4:1 - 4:,
        UW_NT		5:1 - 5:,
        EGPCUR_CF	6:1 - 6:,
        SEG_NF		9:1 - 9:
/KEYS	SEG_NF,
      UWY_NF,
      EGPCUR_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UW_NT
exit
EOF
SORT


# [25] [041]

NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="FSEGEST file sort by Segment/UW Year/Currency"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FSEGEST}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SEGEST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEG_NF     2:1 - 2:,
        UWY_NF     3:1 - 3:,
        AMORAT_CT  8:1 - 8:,
        SEGTYP_CT  9:1 - 9:
/KEYS SEG_NF,
      UWY_NF
/CONDITION BOOK (AMORAT_CT = "R" OR AMORAT_CT = "S") AND ( SEGTYP_CT = "${segtyp_ct}" )
/INCLUDE BOOK
exit
EOF
SORT

NSTEP=${NJOB}_100
#Calculation of Ss_M from Loss Ratio by segment/UW year
#SEGTYP_CT ${SEGTYP_CT}
#-----------------------------------------------------------------------------
LIBEL="Calculation of Ss_M from Loss Ratio by segment/UW year in progress..."
# on cumule les CASEACT_PAi_M*taux sur les segments/exercice ou bien on y met le montant de segest
PRG=ESTC0624
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_PERICASEEST_O.dat # PHP vient du 2001 à mettre dans DFILI
#export ${PRG}_I1=${EST_IADPERICASE22} 
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_SORT_SEGEST_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SEGESTEST_O.dat
EXECPRG

NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="Calculation of losses by Segment/UW Year in progress..."
PRG=ESTC0625
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_PERICASEEST_O.dat  # PHP vient du 2001 à mettre dans DFILI
#export ${PRG}_I1=${EST_IADPERICASE22} 
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_ESTC0624_SEGESTEST_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SEGESTEST_O.dat
EXECPRG

NSTEP=${NJOB}_111
#-----------------------------------------------------------------------------
LIBEL="Sort ${NJOB}_70_${IB}_SORT_PERICASESEG_O.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_PERICASESEG_O.dat  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASEEST_O1.dat   1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  CTR_NF  3:1 -   3:
        ,END_NT  4:1 -   4:
        ,SEC_NF  5:1 -   5:
        ,UWY_NF  6:1 -   6:
/KEYS CTR_NF,
			END_NT,
			SEC_NF,
      UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_112
#-----------------------------------------------------------------------------
LIBEL="sort ${DFILT}/${NJOB}_30_${IB}_SORT_IADPERICASE_O2.dat by Contrat/End Contrat/Segment/UW Year"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_IADPERICASE_O2.dat 1000 1"
#SORT_I="${EST_IADPERICASE22} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O2.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	CTR_NF    3:1 -   3:
        ,END_NT  4:1 -   4:
        ,SEC_NF  5:1 -   5:
        ,UWY_NF  6:1 -   6:
/KEYS CTR_NF,
	END_NT,
	SEC_NF,
      UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_113
#-----------------------------------------------------------------------------
LIBEL="write sinistralite"
PRG=ESTC0627
export ${PRG}_I1=${DFILT}/${NJOB}_111_${IB}_SORT_PERICASEEST_O1.dat
export ${PRG}_I2=${DFILT}/${NJOB}_112_${IB}_SORT_IADPERICASE_O2.dat
export ${PRG}_I3=${DFILT}/${NJOB}_110_${IB}_ESTC0625_SEGESTEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE_O2.dat
EXECPRG


NSTEP=${NJOB}_120
#GTCUMUL file sort by Segment/UW Year/Occurence Year/CTR/END/SEC/UW
#-----------------------------------------------------------------------------
LIBEL="GTCUMUL file sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLCGTAA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTCUMUL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEG_NF   10:1 - 10:,
        UWY_NF    4:1 - 4:,
        ACMCUR_CF	9:1 - 9:,
        OCCYEA_NF	6:1 - 6:,
        CTR_NF    1:1 - 1:,
        END_NT    2:1 - 2:,
        SEC_NF    3:1 - 3:,
        UW_NT     5:1 - 5:
/KEYS SEG_NF,
      UWY_NF,
      ACMCUR_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UW_NT,
      OCCYEA_NF
exit
EOF
SORT

NSTEP=${NJOB}_125
#------------------------------------------------------------------------------
LIBEL="Join to find type and nature of contract"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_PERICASEEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASEEST_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        CASEACT_DATA1          1:1 - 22:,
        PER_SEG_NF             80:1 - 80:,
        PER_UWY_NF             6:1 - 6:,
        PER_EGPCUR_CF          23:1 - 23:,
        PER_CTR_NF             3:1 - 3:,
        PER_END_NT             4:1 - 4:,
        PER_SEC_NF             5:1 - 5:,
        PER_UW_NT              7:1 - 7:,
        PER_ACCADMTYP_CT       97:1 - 97:,
        PER_NAT_CF             49:1 - 49:,
        CASEACT_SEG_NF         9:1 - 9:,
        CASEACT_UWY_NF         4:1 - 4:,
        CASEACT_EGPCUR_CF      6:1 - 6:,
        CASEACT_CTR_NF         1:1 - 1:,
        CASEACT_END_NT         2:1 - 2:,
        CASEACT_SEC_NF         3:1 - 3:,
        CASEACT_UW_NT          5:1 - 5:

/JOINKEYS
        CASEACT_SEG_NF, CASEACT_UWY_NF, CASEACT_EGPCUR_CF, CASEACT_CTR_NF, CASEACT_END_NT, CASEACT_SEC_NF, CASEACT_UW_NT

/INFILE ${DFILT}/${NJOB}_70_${IB}_SORT_PERICASESEG_O.dat 1000 "~"
/JOINKEYS
        PER_SEG_NF, PER_UWY_NF, PER_EGPCUR_CF, PER_CTR_NF, PER_END_NT, PER_SEC_NF, PER_UW_NT

/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE: CASEACT_DATA1, RIGHTSIDE: PER_ACCADMTYP_CT, RIGHTSIDE: PER_NAT_CF
exit
EOF
SORT

#[039]
NSTEP=${NJOB}_126
#------------------------------------------------------------------------------
LIBEL="Join to extract segment Amount type"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC0625_SEGESTEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SEGESTEST_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS IN_SEG_NF      1:1 -  1:,
        IN_UWY_NF      2:1 -  2:,
        IN_ALLCOLS     1:1 - 12:,
        SEG_SEG_NF     2:1 -  2:,
        SEG_UWY_NF     3:1 -  3:,
        SEG_AMORAT_CT  8:1 -  8:

/JOINKEYS
        IN_SEG_NF, IN_UWY_NF

/INFILE ${DFILT}/${NJOB}_90_${IB}_SORT_SEGEST_O.dat 1000 "~"
/JOINKEYS
        SEG_SEG_NF, SEG_UWY_NF

/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE: IN_ALLCOLS,
          RIGHTSIDE: SEG_AMORAT_CT
exit
EOF
SORT
        
#[029] [039]
NSTEP=${NJOB}_130
# Calculation of losses and IBNR
#SEGTYP_CT ${SEGTYP_CT}
#-----------------------------------------------------------------------------
LIBEL="Calculation of losses and IBNR in progress..."
PRG=ESTC0626
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
SSDs ${SSDs}
SSDVRS_LL ${SSDVRS_LL}
CLOTYP_CT ${CLOTYP_CT}
CLODAT_D ${ICLODAT_D}
PRS_CF ${PRS}
exit
EOF
export ${PRG}_I1=${DFILT}/${NJOB}_125_${IB}_SORT_PERICASEEST_O.dat            # PHP vient du 2001 à mettre dans DFILI
#export ${PRG}_I2=${DFILT}/${NJOB}_110_${IB}_ESTC0625_SEGESTEST_O.dat         # [039]
export ${PRG}_I2=${DFILT}/${NJOB}_126_${IB}_SORT_SEGESTEST_O.dat 
export ${PRG}_I3=${DFILT}/${NJOB}_70_${IB}_SORT_PERICASESEG_O.dat            # PHP vient du 2001 à mettre dans DFILI
export ${PRG}_I4=${EST_LABOCY1}                                               # PHP vient du 2001 à mettre dans DFILI
export ${PRG}_I5=${DFILT}/${NJOB}_120_${IB}_SORT_GTCUMUL_O.dat
export ${PRG}_I6=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCTREST1_O1.dat              # PHP on récupère ici les montants IBNR1A et IBNR1B
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAAIBNR_O2.dat             # PHP on récupère ici les montants IBNR1A et IBNR1B, au format GT
export ${PRG}_O3=${EST_IBNR}                                                  # [007] GLE - ajout d un fichier de Trace pour les IBNR #[012]
export ${PRG}_O4=${EST_BLANCHIMENT_RPCC}									  # [016] Ajout de la log 
export ${PRG}_PRM=${FPRM}
#[041]
if [ "${TYPEINV}" != "INV" ]
then
	EXECPRG
else	
	NSTEP=${NJOB}_140
	#-----------------------------------------------------------------
	LIBEL="Take last IFRS IBNR data for INV EBS because no calculation must be done"
	EXECKSH_MODE=P
	EXECKSH "cp ${EST_DLDGTAA_IBNRIFRS} ${DFILT}/${NJOB}_130_${IB}_ESTC0626_DLGTAAIBNR_O2.dat"
fi

#################################################
# Calculation of reinstalment and burning cost  #
#################################################

NSTEP=${NJOB}_150
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount by contract, accounting periods undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_130_${IB}_ESTC0626_DLGTAAIBNR_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAIBNR_O.dat
# PHP pas utilise de mettre le taux ici dans le fichier temporaire, sauf si cela pose pb entre les deux passages
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        BALSHEY_NF         3:1 - 3:,
        BALSHRMTH_NF       4:1 - 4:,
        BALSHRDAY_NF       5:1 - 5:,
        TRNCOD_CF          6:1 - 6:,
        DBLTRNCOD_CF       7:1 - 7:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:,
        OCCYEA_NF         13:1 - 13:,
        ACY_NF            14:1 - 14:,
        SCOSTRMTH_NF      15:1 - 15:,
        SCOENDMTH_NF      16:1 - 16:,
        CLM_NF            17:1 - 17:,
        CUR_CF            18:1 - 18:,
        AMT_M             19:1 - 19:EN 15/3,
        CED_NF            20:1 - 20:,
        BRK_NF            21:1 - 21:,
        PAY_NF            22:1 - 22:,
        KEY_NF            23:1 - 23:,
        RETCTR_NF         24:1 - 24:,
        RETEND_NT         25:1 - 25:,
        RETSEC_NF         26:1 - 26:,
        RTY_NF            27:1 - 27:,
        RETUW_NT          28:1 - 28:,
        RETOCCYEA_NF      29:1 - 29:,
        RETACY_NF         30:1 - 30:,
        RETSCOSTRMTH_NF   31:1 - 31:,
        RETSCOENDMTH_NF   32:1 - 32:,
        RCL_NF            33:1 - 33:,
        RETCUR_CF         34:1 - 34:,
        RETAMT_M          35:1 - 35:EN 15/3,
        PLC_NT            36:1 - 36:,
        RTO_NF            37:1 - 37:,
        INT_NF            38:1 - 38:,
        RETPAY_NF         39:1 - 39:,
        RETKEY_CF         40:1 - 40:,
        RETINTAMT_M       41:1 - 41:EN 15/3
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_M
exit
EOF
SORT

#[008]
NSTEP=${NJOB}_160
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat ESTC1005_PERICASE Extended with TFAMCHG_O"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_113_${IB}_ESTC0627_IADPERICASE_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O2.dat 1000 1"

INPUT_TEXT $SORT_CMD <<EOF
/FIELDS	CTR_NF  3:1 -   3:
        ,END_NT  4:1 -   4:
        ,SEC_NF  5:1 -   5:
        ,UWY_NF  6:1 -   6:
        ,UW_NT   7:1 -   7:
        ,FILLER1 1:1 - 206:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/DERIVEDFIELD SEPARATEUR13  13"~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,
          SEPARATEUR13
exit
EOF
SORT

NSTEP=${NJOB}_170
#------------------------------------------------------------------------------
LIBEL="Liaison Extended_Pericase avec TFAMCHG"
PRG=ESTM7003
export ${PRG}_I1=${EST_FTFAMCHG}
export ${PRG}_I2=${DFILT}/${NJOB}_160_${IB}_SORT_IADPERICASE_O2.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE_O2.dat
EXECPRG


#[043] Tri du fichier EST_IADPERIFR
#[047] Tri du fichier EST_IADPERIFR Ajout des colonnes  REILIN_NT et REIRNK_N dans la clé de TRI

NSTEP=${NJOB}_175
#-----------------------------------------------------------------------------
LIBEL="EST_IADPERIFR file sort in progress...  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:,
        SEC_NF       3:1 -  3:,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:,
        REILIN_NT    6:1 -  6:,
        REIRNK_N     10:1 -  10:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        REILIN_NT,
        REIRNK_N
exit
EOF
SORT

NSTEP=${NJOB}_180
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Compute of Burning Cost and reinstall estimates"
PRG=ESTC1015
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_170_${IB}_ESTM7003_IADPERICASE_O2.dat
#export ${PRG}_I2=${EST_IADPERIFR}
export ${PRG}_I2=${DFILT}/${NJOB}_175_${IB}_SORT_IADPERIFR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_150_${IB}_SORT_DLCUMGTAAIBNR_O.dat
export ${PRG}_I4=${EST_DLCUMGTAAS}
export ${PRG}_I5=${EST_FTTR_PRM}
export ${PRG}_I6=${DFILT}/${NJOB}_40_${IB}_SORT_CTRULT02_O1.dat
export ${PRG}_I7=${EST_FCURQUOT}
export ${PRG}_I8=${EST_FTHRHLDUWY}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAABCREC_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTTR_O2.dat
EXECPRG

#####################################
# Calculation of loading estimates  #
#####################################


#[046] Tri du fichier EST_IADPERIFCT 
NSTEP=${NJOB}_185
#-----------------------------------------------------------------------------
LIBEL="EST_IADPERIFCT file sort in progress...  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFCT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:,
        SEC_NF       3:1 -  3:,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

#[046] Tri du fichier EST_IADPERIFCI 
NSTEP=${NJOB}_187
#-----------------------------------------------------------------------------
LIBEL="EST_IADPERIFCI file sort in progress...  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCI} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFCI_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:,
        SEC_NF       3:1 -  3:,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

#[029] #[035] #[046]
NSTEP=${NJOB}_190
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Compute of loading rates"
PRG=ESTC1016
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
CLODAT_D ${ICLODAT_D}
CLOTYP_CT ${CLOTYP_CT}
PRS_CF ${PRS}
NDICFLG F
CHAIN ${NCHAIN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_IADPERICASE_O2.dat	# PHP mettre ici un fichier dans DFILI
#export ${PRG}_I1=${EST_IADPERICASE22} 
#export ${PRG}_I2=${EST_IADPERIFCT}
export ${PRG}_I2=${DFILT}/${NJOB}_185_${IB}_SORT_IADPERIFCT_O.dat
#export ${PRG}_I3=${EST_IADPERIFCI}
export ${PRG}_I3=${DFILT}/${NJOB}_187_${IB}_SORT_IADPERIFCI_O.dat
export ${PRG}_I4=${EST_DLCUMGTAAS}
export ${PRG}_I5=${EST_DLGTAAPA}
export ${PRG}_I6=${DFILT}/${NJOB}_20_${IB}_ESTC1022_CTRESTCV_O2.dat	# PHP commissions variables existantes
export ${PRG}_I7=${DFILT}/${NJOB}_150_${IB}_SORT_DLCUMGTAAIBNR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCTREST2_O1.dat				# PHP calcul des commissions variables en sortie
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FLOARAT_O2.dat				# PHP calcul des commissions variables en sortie
EXECPRG

if [ -f "${EST_FT_IFRS}" ]; then
    echo ""
else
    touch ${EST_FT_IFRS}
fi

#[038]
NSTEP=${NJOB}_195
#------------------------------------------------------------------------------
# extrat PNA17 of the FTCUM file
#------------------------------------------------------------------------------
LIBEL="Sort of $ESF_FEXPRAT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FT_IFRS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FT_PNA17.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          2:1  -  2:,
        END_NT          3:1  -  3:,
        SEC_NF          4:1  -  4:,
        UWY_NF          5:1  -  5:,
        UW_NT           6:1  -  6:,
        UWYDIS_NF       10:1 -  10:,
        WFCOD_NT        12:1 -  12:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWYDIS_NF,
        UW_NT
/CONDITION POSTEPRM
        WFCOD_NT EQ "99999"
/OUTFILE ${SORT_O}
/INCLUDE POSTEPRM
exit
EOF
SORT

NSTEP=${NJOB}_198
#------------------------------------------------------------------------------
# filter of the ESTC1015_FTTR_O2 file
#------------------------------------------------------------------------------
LIBEL="filter of ESTC1015_FTTR_O2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_ESTC1015_FTTR_O2.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC1015_FTTR_O2.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF          2:1  -  2:,
        END_NT          3:1  -  3:,
        SEC_NF          4:1  -  4:,
        UWY_NF          5:1  -  5:,
        UW_NT           6:1  -  6:,
        UWYDIS_NF       10:1 -  10:,
        WFCOD_NT        12:1 -  12:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
		UWYDIS_NF,
        UW_NT
/CONDITION POSTEPRM
        WFCOD_NT NE "99999"
/OUTFILE ${SORT_O}
/INCLUDE POSTEPRM
exit
EOF
SORT


# cumul des 2 taux mais pas bon -> a revoir
NSTEP=${NJOB}_200
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Merge  and Sort of Treaty and Fac working Files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_198_${IB}_ESTC1015_FTTR_O2.dat 1000 1"
# PHP attention, ici tu as mis en dur le temoin R et non pâs {NORME}
#SORT_I2="${DFILT}/${NJOB}_180_${IB}_ESTC1015_FTTR_O2_T.dat 1000 1"
SORT_I3="${EST_FTFAC} 1000 1"        # PHP faire un fichier dans DFILI
SORT_I4="${DFILT}/${NJOB}_195_${IB}_SORT_FT_PNA17.dat 1000 1"
SORT_O="${EST_FT} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     2:1 -  2:,
        END_NT     3:1 -  3:,
        SEC_NF     4:1 -  4:,
        UW_NT      6:1 -  6:,
        UWYDIS_NF 10:1 - 10:,
        WFCOD_NT  12:1 - 12:,
        PRM_M     15:1 - 15:EN,
        PPNAC_M   16:1 - 16:EN,
        PPNAEA_M  17:1 - 17:EN,
        RPPC_M    18:1 - 18:EN,
        RPPEA_M   19:1 - 19:EN,
        LPPNAC_M  20:1 - 20:EN,
        EPPC_M    21:1 - 21:EN,
        EPPEA_M   22:1 - 22:EN,
        RECC_M    23:1 - 23:EN,
        RECE_M    24:1 - 24:EN,
        BCC_M     25:1 - 25:EN,
        BCE_M     26:1 - 26:EN,
        DATA1      1:1 - 28:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWYDIS_NF,
      UW_NT
/DERIVEDFIELD PRS "${PRS}"
/CONDITION POSTEPRM
    ( WFCOD_NT EQ "10000" or WFCOD_NT EQ "8000" or WFCOD_NT EQ "99999") and
    ( PRM_M NE 0 or PPNAC_M NE 0 or PPNAEA_M NE 0 or RPPC_M NE 0 or
      RPPEA_M NE 0 or LPPNAC_M NE 0 or EPPC_M NE 0 or EPPEA_M NE 0 or
      RECC_M NE 0 or RECE_M NE 0 or BCC_M NE 0 or BCE_M NE 0 )
/OUTFILE ${SORT_O}
/INCLUDE POSTEPRM
/REFORMAT DATA1,PRS
exit
EOF
SORT

NSTEP=${NJOB}_210
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount by contract and writing type, accounting periods \
undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FT}
# PHP mettre un des deux {EST_FT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTCUM_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CLODAT_D	1:1 - 1:,
        CTR_NF         2:1 - 2:,
        END_NT         3:1 - 3:,
        SEC_NF         4:1 - 4:,
        UWY_NF         5:1 - 5:,
        UW_NT          6:1 - 6:,
        ACY_NF         7:1 - 7:,
        SCOSTRMTH_NF   8:1 - 8:,
        SCOENDMTH_NF   9:1 - 9:,
        UWYDIS_NF      10:1 - 10:,
        SSD_CF         11:1 - 11:,
        WFCOD_NT       12:1 - 12:,
        WFTYP_CF       13:1 - 13:,
        EGPCUR_CF      14:1 - 14:,
        PRM_M          15:1 - 15:EN 15/3,
        PPNAC_M        16:1 - 16:EN 15/3,
        PPNAEA_M       17:1 - 17:EN 15/3,
        RPPC_M         18:1 - 18:EN 15/3,
        RPPEA_M        19:1 - 19:EN 15/3,
        LPPNAC_M       20:1 - 20:EN 15/3,
        EPPC_M         21:1 - 21:EN 15/3,
        EPPEA_M        22:1 - 22:EN 15/3,
        RECC_M         23:1 - 23:EN 15/3,
        RECE_M         24:1 - 24:EN 15/3,
        BCC_M          25:1 - 25:EN 15/3,
        BCE_M          26:1 - 26:EN 15/3,
        SHR_R          27:1 - 27:,
        ACCADMTYP_CT   28:1 - 28:,
        PRS_CF         29:1 - 29:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWYDIS_NF,
      UW_NT,
      WFCOD_NT,
      WFTYP_CF
/SUMMARIZE TOTAL PRM_M,
           TOTAL PPNAC_M,
           TOTAL PPNAEA_M,
           TOTAL RPPC_M,
           TOTAL RPPEA_M,
           TOTAL LPPNAC_M,
           TOTAL EPPC_M,
           TOTAL EPPEA_M,
           TOTAL RECC_M,
           TOTAL RECE_M,
           TOTAL BCC_M,
           TOTAL BCE_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M  COMPRESS
/DERIVEDFIELD PRM_MC    PRM_M     COMPRESS
/DERIVEDFIELD PPNAC_MC  PPNAC_M   COMPRESS
/DERIVEDFIELD PPNAEA_MC PPNAEA_M  COMPRESS
/DERIVEDFIELD RPPC_MC   RPPC_M    COMPRESS
/DERIVEDFIELD RPPEA_MC  RPPEA_M   COMPRESS
/DERIVEDFIELD LPPNAC_MC LPPNAC_M  COMPRESS
/DERIVEDFIELD EPPC_MC   EPPC_M    COMPRESS
/DERIVEDFIELD EPPEA_MC  EPPEA_M   COMPRESS
/DERIVEDFIELD RECC_MC   RECC_M    COMPRESS
/DERIVEDFIELD RECE_MC   RECE_M    COMPRESS
/DERIVEDFIELD BCC_MC    BCC_M     COMPRESS
/DERIVEDFIELD BCE_MC    BCE_M     COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT CLODAT_D,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACY_NF,
	SCOSTRMTH_NF,
	SCOENDMTH_NF,
	UWYDIS_NF,
	SSD_CF,
	WFCOD_NT,
	WFTYP_CF,
	EGPCUR_CF,
	PRM_MC,
	PPNAC_MC,
	PPNAEA_MC,
	RPPC_MC,
	RPPEA_MC,
	LPPNAC_MC,
	EPPC_MC,
	EPPEA_MC,
	RECC_MC,
	RECE_MC,
	BCC_MC,
	BCE_MC,
	SHR_R,
	ACCADMTYP_CT,
	PRS_CF
exit
EOF
SORT

#[038]
NSTEP=${NJOB}_215
#------------------------------------------------------------------------------
# sort and Merge of the ${EST_EPOSOCI} ${EST_FACCSUP0} file
#------------------------------------------------------------------------------
LIBEL="Sort of $ESF_FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_EPOSOCI} 2000 1"

#(042]
if  [ "${TYPEINV}" = "INV" ]
then
SORT_I2="${EST_FACCSUP0} 2000 1"

else if  [ "${TYPEINV}" = "POS" ]
then
SORT_I2="${EST_DLSGTAA} 2000 1"
fi
fi
 
SORT_O="${DFILT}/${NSTEP}_${IB}_GTAE.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF    8:1  -  8:,
        END_NT    9:1  -  9:,
        SEC_NF    10:1 -  10:EN,
        UWY_NF    11:1 -  11:,
        UW_NT     12:1 -  12:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

if [ "$NORME2" != "" ]  
then
   CLOSING_MODE="$NORME2"   # new case for microAOC
else
   CLOSING_MODE="$NORME_CF"
fi

#[029]
NSTEP=${NJOB}_220
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Loading Compute"
PRG=ESTC1017
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
PRS_CF ${PRS}
CLODAT_D ${ICLODAT_D}
NORME ${CLOSING_MODE}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_210_${IB}_SORT_FTCUM_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_190_${IB}_ESTC1016_FLOARAT_O2.dat
export ${PRG}_I3=${EST_DCGTAALOA}
export ${PRG}_I4=${DFILT}/${NJOB}_30_${IB}_SORT_IADPERICASE_O2.dat
#export ${PRG}_I4=${EST_IADPERICASE22} 
export ${PRG}_I5=${EST_DLGTAAFPRE}
export ${PRG}_I6=${EST_DLCGTAAREC}
export ${PRG}_I7=${DFILT}/${NJOB}_215_${IB}_GTAE.dat
export ${PRG}_I8=${EST_FBOPRSLNK}
export ${PRG}_I9=${EST_DLCUMGTAAR}
export ${PRG}_I10=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FPRMLOA_O1.dat
EXECPRG


NSTEP=${NJOB}_230
# Force PRS_CF value
#-----------------------------------------------------------------------------
LIBEL="Force PRS_CF value"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_190_${IB}_ESTC1016_FLOARAT_O2.dat
SORT_O="${EST_FLOARAT} OVERWRITE "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  DATA1      1:1 -  10:
/DERIVEDFIELD PRS "${PRS}"
/OUTFILE ${SORT_O}
/REFORMAT DATA1,PRS
exit
EOF
SORT

NSTEP=${NJOB}_240
# PHP ce step ne devrait pas etre là, mais dans le ESID2001
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount by contract and accounting period"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLGTAARPPE}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTACUMARPPE_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:,
        SCOENDMTH_NF     16:1 - 16:,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:,
        RETSCOENDMTH_NF  32:1 - 32:,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      TRNCOD_CF
/SUMMARIZE  TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_242
# Begin sort
# [017] change CURGTA for DTSTATGTAA
#-----------------------------------------------------------------------------
LIBEL="Sort of DTSTATGTAA file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DTSTATGTAA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAA.dat"
SORT_O2="${DFILT}/${NSTEP}_${IB}_DLCUMGTAA_rejet.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        CUR_CF 18:1 - 18:,
        TRNCOD3 6:1 - 6:3,
        TRNCOD7 6:8 - 6:8
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      CUR_CF
/CONDITION POSTE_113XXXX0 (TRNCOD3 EQ "113" AND TRNCOD7 EQ "0")
/OUTFILE ${SORT_O}
/INCLUDE POSTE_113XXXX0
/OUTFILE ${SORT_O2}
/OMIT POSTE_113XXXX0
exit
EOF
SORT 


NSTEP=${NJOB}_245
# Begin C program
# [018] ajout Pericase
#-----------------------------------------------------------------------------
LIBEL="Loading condition on commission "
PRG=ESTC1012
export ${PRG}_I1=${DFILT}/${NJOB}_242_${IB}_DLCUMGTAA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_113_${IB}_ESTC0627_IADPERICASE_O2.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICONDAT_O.dat                         # -=Dch=-  sortie des conditions par contrat/section/exercice
EXECPRG


NSTEP=${NJOB}_246
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sum  amounts by contract and accounting period, following cond."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_245_${IB}_ESTC1012_PERICONDAT_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERICONDAT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 			 1:1 -  1:,
		END_NT 			 2:1 -  2:,
		SEC_NF 			 3:1 -  3:,
		UWY_NF 			 4:1 -  4:,
		UW_NT 			 5:1 -  5:,
		COND_EPP 		 6:1 -  6:,
		COND_RPP 		 7:1 -  7:,
		AMT_EPP 		 8:1 -  8:EN 15/3,
		AMT_RPP 		 9:1 -  9:EN 15/3,
		COM_EPP 		10:1 - 10:EN 15/3,
		COM_RPP 		11:1 - 11:EN 15/3,
		CUR_CF 			12:1 - 12:

/KEYS 	CTR_NF,
      	SEC_NF,
      	UWY_NF
/SUMMARIZE	TOTAL AMT_EPP,
			TOTAL AMT_RPP,
			TOTAL COM_EPP,
			TOTAL COM_RPP
/OUTFILE ${SORT_O}

exit
EOF
SORT #-=Dch=-  provisoire supprimÃ©en vue de tests ( dedoublonnage fait dans ESTC1012

#[019]
NSTEP=${NJOB}_250
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Loading ventilation"
PRG=ESTC1018
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1=${DFILT}/${NJOB}_113_${IB}_ESTC0627_IADPERICASE_O2.dat
export ${PRG}_I1=${DFILT}/${NJOB}_170_${IB}_ESTM7003_IADPERICASE_O2.dat                #On prend le fichier perimetre etendu [019]
export ${PRG}_I2=${EST_DLGTAAPRE}                                                       #le fichier GT des complements de primes
export ${PRG}_I3=${DFILT}/${NJOB}_180_${IB}_ESTC1015_DLGTAABCREC_O1.dat       			#le fichier GT des montants de reconstitution et burning cost
export ${PRG}_I4=${EST_DLGTAATFPNAE}                                                    #le fichier GT des PNA
export ${PRG}_I5=${DFILT}/${NJOB}_220_${IB}_ESTC1017_FPRMLOA_O1.dat                     #le fichier des montants de primes et charges
export ${PRG}_I6=${EST_DLCGTAAEPPE}                                                     #le fichier GT des EPP
export ${PRG}_I7=${DFILT}/${NJOB}_240_${IB}_SORT_DLGTACUMARPPE_O.dat                    #le fichier GT des RPP
export ${PRG}_I8=${EST_FTHRHLDUWY}
export ${PRG}_I9=${DFILT}/${NJOB}_246_${IB}_SORT_PERICONDAT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAALOA_O.dat                         # PHP VENTILATION DES CHARGES AU DETAIL POSTE COMPTABLE/ ANNEE DE COMPTE
EXECPRG

#[045]
NSTEP=${NJOB}_254A
#------------------------------------------------------------------------------
#Sort-Summarize DLGTAAPRE
#-----------------------------------------------------------------------------
LIBEL="Sort-ummarize DLGTAAPRE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLGTAAPRE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLGTAAPRE_O1.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF         8:1 -   8:,
        END_NT         9:1 -   9:,
        SEC_NF        10:1 -  10:,
        UWY_NF        11:1 -  11:,
        UW_NT         12:1 -  12:,
        CTR_COLS       8:1 -  12:
/KEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/SUMMARIZE
/OUTFILE ${SORT_O}
/REFORMAT CTR_COLS
exit
EOF
SORT

#[045]
NSTEP=${NJOB}_254B
#------------------------------------------------------------------------------
#Sort-Summarize DLCGTAAEPPE
#-----------------------------------------------------------------------------
LIBEL="Sort-join and filter of FPRMLOA on DLGTAAPRE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLCGTAAEPPE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCGTAAEPPE_O1.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF         8:1 -   8:,
        END_NT         9:1 -   9:,
        SEC_NF        10:1 -  10:,
        UWY_NF        11:1 -  11:,
        UW_NT         12:1 -  12:,
        CTR_COLS       8:1 -  12:
/KEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/SUMMARIZE
/OUTFILE ${SORT_O}
/REFORMAT CTR_COLS
exit
EOF
SORT


#[045]
NSTEP=${NJOB}_255A
#------------------------------------------------------------------------------
#Sort-join and filter FPRMLOA on DLGTAAPRE
#-----------------------------------------------------------------------------
LIBEL="Sort-join and filter of FPRMLOA on DLGTAAPRE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_220_${IB}_ESTC1017_FPRMLOA_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FPRMLOA_O1.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           1:1 -   1:,
        END_NT           2:1 -   2:,
        SEC_NF           3:1 -   3:,
        UWY_NF           4:1 -   4:,
        UW_NT            5:1 -   5:,
        F_CTR_NF         1:1 -   1:,
        F_END_NT         2:1 -   2:,
        F_SEC_NF         3:1 -   3:,
        F_UWY_NF         4:1 -   4:,
        F_UW_NT          5:1 -   5:,
        ALL_COLS         1:1 -  12:
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${DFILT}/${NJOB}_254A_${IB}_DLGTAAPRE_O1.dat 1000 1 "~"
/joinkeys
         F_CTR_NF,
         F_END_NT,
         F_SEC_NF,
         F_UWY_NF,
         F_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_COLS, RIGHTSIDE: F_CTR_NF
exit
EOF
SORT

#[045]
NSTEP=${NJOB}_255B
#------------------------------------------------------------------------------
#Sort-filter of FPRMLOA
#-----------------------------------------------------------------------------
LIBEL="Filter of FPRMLOA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_255A_${IB}_FPRMLOA_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FPRMLOA_O2.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS ALL_COLS         1:1  -   12:,
        COLS1TO10        1:1  -   10:,
        ACMTRS_NT        7:1  -   7:,
        RESERV_M         11:1 -   11:,
        COLS12TO13       12:1 -   13:,
        TAG              13:1 -   13:
/DERIVEDFIELD ZERO "0.000~"
/CONDITION COND_ACMTRS_NT TAG EQ ""
/OUTFILE ${SORT_O}
/INCLUDE COND_ACMTRS_NT
/REFORMAT COLS1TO10, ZERO, COLS12TO13
exit
EOF
SORT

#[045]
NSTEP=${NJOB}_255C
#------------------------------------------------------------------------------
#Sort-filter of FPRMLOA
#-----------------------------------------------------------------------------
LIBEL="Filter of FPRMLOA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_255A_${IB}_FPRMLOA_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FPRMLOA_O3.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS ALL_COLS         1:1  -   12:,
        COLS1TO10        1:1  -   10:,
        ACMTRS_NT        7:1  -   7:,
        RESERV_M         11:1 -   11:,
        COLS12TO13       12:1 -   13:,
        TAG              13:1 -   13:
/CONDITION COND_ACMTRS_NT TAG NE ""
/OUTFILE ${SORT_O}
/INCLUDE COND_ACMTRS_NT
/REFORMAT ALL_COLS
exit
EOF
SORT

#[045]
NSTEP=${NJOB}_255D
#------------------------------------------------------------------------------
#Sort-join of FPRMLOA on DLCGTAAEPPE
#-----------------------------------------------------------------------------
LIBEL="Sort-join and filter of FPRMLOA on DLGTAAPRE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_255C_${IB}_FPRMLOA_O3.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FPRMLOA_O4.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           1:1 -   1:,
        END_NT           2:1 -   2:,
        SEC_NF           3:1 -   3:,
        UWY_NF           4:1 -   4:,
        UW_NT            5:1 -   5:,
        F_CTR_NF         1:1 -   1:,
        F_END_NT         2:1 -   2:,
        F_SEC_NF         3:1 -   3:,
        F_UWY_NF         4:1 -   4:,
        F_UW_NT          5:1 -   5:,
        ALL_COLS         1:1 -  12:
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${DFILT}/${NJOB}_254B_${IB}_DLCGTAAEPPE_O1.dat 1000 1 "~"
/joinkeys
         F_CTR_NF,
         F_END_NT,
         F_SEC_NF,
         F_UWY_NF,
         F_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_COLS, RIGHTSIDE: F_CTR_NF
exit
EOF
SORT

NSTEP=${NJOB}_255E
#------------------------------------------------------------------------------
#Sort-filter of FPRMLOA on 10020 10120 10420
#-----------------------------------------------------------------------------
LIBEL="Filter of FPRMLOA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_255D_${IB}_FPRMLOA_O4.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FPRMLOA_O5.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS ALL_COLS         1:1  -   12:,
        COLS1TO10        1:1  -   10:,
        ACMTRS_NT        7:1  -   7:,
        RESERV_M         11:1 -   11:,
        COLS12TO13       12:1 -   13:,
        TAG              13:1 -   13:
/DERIVEDFIELD ZERO "0.000~"
/CONDITION COND_ACMTRS_NT (TAG EQ "" AND (ACMTRS_NT EQ "10020" OR ACMTRS_NT EQ "10120" OR ACMTRS_NT EQ "10420"))
/OUTFILE ${SORT_O}
/INCLUDE COND_ACMTRS_NT
/REFORMAT COLS1TO10, ZERO, COLS12TO13
exit
EOF
SORT



#[045]
NSTEP=${NJOB}_255F
#------------------------------------------------------------------------------
#Sort-filter of FPRMLOA on 10020 10120 10420
#-----------------------------------------------------------------------------
LIBEL="Filter of FPRMLOA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_255D_${IB}_FPRMLOA_O4.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FPRMLOA_O6.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS ALL_COLS         1:1  -   12:,
        COLS1TO10        1:1  -   10:,
        ACMTRS_NT        7:1  -   7:,
        RESERV_M         11:1 -   11:,
        COLS12TO13       12:1 -   13:,
        TAG              13:1 -   13:
/CONDITION COND_ACMTRS_NT (TAG NE "" OR (ACMTRS_NT NE "10020" AND ACMTRS_NT NE "10120" AND ACMTRS_NT NE "10420"))
/OUTFILE ${SORT_O}
/INCLUDE COND_ACMTRS_NT
/REFORMAT ALL_COLS, TAG
exit
EOF
SORT

#[045]
NSTEP=${NJOB}_255G
#------------------------------------------------------------------------------
#Sort-merge all FPRMLOA
#-----------------------------------------------------------------------------
LIBEL="Filter of FPRMLOA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_255B_${IB}_FPRMLOA_O2.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_255E_${IB}_FPRMLOA_O5.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_255F_${IB}_FPRMLOA_O6.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FPRMLOA_O1.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS ALL_COLS_EXLAST  1:1  -  12:,
        CTR_NF           1:1  -   1:,
        END_NT           2:1  -   2:,
        SEC_NF           3:1  -   3:,
        UWY_NF           4:1  -   4:,
        UW_NT            5:1  -   5:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/OUTFILE ${SORT_O}
/REFORMAT ALL_COLS_EXLAST
exit
EOF
SORT


#####################################
# Calculation of loading estimates  #
#####################################

#[045]
NSTEP=${NJOB}_260
# Force PRS_CF value
#-----------------------------------------------------------------------------
LIBEL="Force PRS_CF value"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${DFILT}/${NJOB}_220_${IB}_ESTC1017_FPRMLOA_O1.dat
SORT_I=${DFILT}/${NJOB}_255G_${IB}_FPRMLOA_O1.dat
SORT_O="${EST_FPRMLOA} OVERWRITE "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DATA1      1:1 -  5:,
        PRS_CF	    6:1 -  6:,
        DATA2      7:1 - 12:
/DERIVEDFIELD PRS "${PRS}~"
/OUTFILE ${SORT_O}
/REFORMAT DATA1,PRS,DATA2
exit
EOF
SORT

NSTEP=${NJOB}_270
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_ESTC1018_DLGTAALOA_O.dat"
SORT_I2=${DFILT}/${NJOB}_130_${IB}_ESTC0626_DLGTAAIBNR_O2.dat
SORT_I3="${EST_DLGTAAPRE}"
SORT_I4="${DFILT}/${NJOB}_180_${IB}_ESTC1015_DLGTAABCREC_O1.dat"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAATOTP_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	TRNCOD_CF       6:1 -  6:,
         CTR_NF          8:1 -  8:,
         END_NT          9:1 -  9:,
         SEC_NF         10:1 - 10:,
         UWY_NF         11:1 - 11:,
         UW_NT          12:1 - 12:,
         OCCYEA_NF      13:1 - 13:,
         ACY_NF         14:1 - 14:,
         SCOSTRMTH_NF   15:1 - 15:,
         SCOENDMTH_NF   16:1 - 16:,
         CLM_NF         17:1 - 17:,
         CUR_CF         18:1 - 18:,
         DEBUT           1:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/DERIVEDFIELD PLUS_30_CHAMPS 30"~"
/OUTFILE ${SORT_O}
/REFORMAT DEBUT,PLUS_30_CHAMPS
exit
EOF
SORT

NSTEP=${NJOB}_280
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount by contract and transaction code, \
 accounting periods and occurence year undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_270_${IB}_SORT_DLGTAATOTP_O.dat
SORT_O=${EST_DLCUMGTAATOT}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:,
        SCOENDMTH_NF     16:1 - 16:,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:,
        RETSCOENDMTH_NF  32:1 - 32:,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FIN              42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF
/SUMMARIZE  TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_M,
          FIN
exit
EOF
SORT

##############################################################
# Calculation of Profit & loss Commission, and Loss Corridor #
##############################################################
if [ "${TYPEINV}" = "INV" ]
then

	# filte EST_IADPERICASE COND_UWORG != 253, 255 and 13
	NSTEP=${NJOB}_290
	#-----------------------------------------------------------------------------
	LIBEL="filte EST_IADPERICASE COND_UWORG != 253, 255 and 13"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_IADPERICASE} 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_TERM_O.dat 1000 1"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
				
		PER_CTR_NF                              3:1 - 3:,
		PER_END_NT                              4:1 - 4:,
		PER_SEC_NF                              5:1 - 5:,
		PER_UWY_NF                              6:1 - 6:,
		PER_CED_NF                              12:1 - 12:,
		PER_SECACCSTS_CT                        77:1 - 77:,
		PER_UWORG_CF                            119:1 - 119: ,
		BEFORE_PER_LOSCOREXI_B                  1:1 -  38:,
		PER_LOSCOREXI_B                         39:1 -  39:,
		AFTER_PER_LOSCOREXI_B                   40:1 -  209:,
		all_cols                                                1:1  - 209:
/CONDITION COND_PERM_TERM  ( ( PER_UWORG_CF != "253" AND PER_UWORG_CF != "255" AND PER_UWORG_CF != "13") OR
												( PER_UWORG_CF = "253" AND PER_CED_NF = "38466" )
										  ) AND
										  PER_SECACCSTS_CT = "9"
/DERIVEDFIELD PER_LOSCOREXI_B_NEW if COND_PERM_TERM then "0" else PER_LOSCOREXI_B
/OUTFILE ${SORT_O}
/INCLUDE COND_PERM_TERM
/REFORMAT
		BEFORE_PER_LOSCOREXI_B
		,PER_LOSCOREXI_B_NEW
		,AFTER_PER_LOSCOREXI_B
/KEYS PER_CTR_NF,
	PER_END_NT,
	PER_SEC_NF,
	PER_UWY_NF
exit
EOF
	SORT

#  NSTEP=${NJOB}_290
#  #-----------------------------------------------------------------------------
#  LIBEL="sort ${DFILT}/${NCHAIN}_ESID2001_30_${IB}_ESTM1002_IADPERICASE_TERM_O.dat by Contrat/End Contrat/Segment/UW Year"
#  SORT_WDIR=${SORTWORK}
#  SORT_CMD=`CFTMP`
#  SORT_I="${DFILT}/${NCHAIN}_ESID2001_30_${IB}_ESTM1002_IADPERICASE_TERM_O.dat 1000 1"
#  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_TERM_O.dat 1000 1"
#  INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS	CTR_NF    3:1 -   3:
#        ,END_NT  4:1 -   4:
#        ,SEC_NF  5:1 -   5:
#        ,UWY_NF  6:1 -   6:
#/KEYS CTR_NF,
#	END_NT,
#	SEC_NF,
#  UWY_NF
#exit
#EOF
#SORT
	
	NSTEP=${NJOB}_292
	#-----------------------------------------------------------------------------
	LIBEL="maj sinistralite pour ${TYPEINV} du IADPERICASE des terminé comptable du 2001"
	PRG=ESTC0627
	export ${PRG}_I1=${DFILT}/${NJOB}_111_${IB}_SORT_PERICASEEST_O1.dat
	export ${PRG}_I2=${DFILT}/${NJOB}_290_${IB}_SORT_IADPERICASE_TERM_O.dat
	export ${PRG}_I3=${DFILT}/${NJOB}_110_${IB}_ESTC0625_SEGESTEST_O.dat
	export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IADPERICASE_TERM_O.dat
	EXECPRG
	
  NSTEP=${NJOB}_293
  #-----------------------------------------------------------------
  LIBEL="Renomme le IADPERICASE du step 113 en step 292 pour la fusion du step 300: même nom de fichier pour INV et POST OMEGA"
  EXECKSH_MODE=P
  EXECKSH "mv ${DFILT}/${NJOB}_113_${IB}_ESTC0627_IADPERICASE_O2.dat ${DFILT}/${NJOB}_292_${IB}_IADPERICASE_O.dat"
	
else
  NSTEP=${NJOB}_292
  #-----------------------------------------------------------------------------
  LIBEL="IADPERICASE pour ${TYPEINV} filtre origines portefeuille et sépare les terminé comptable(maj du LOSCOREXI_B à 0) et les autres"
  PRG=ESTM1002
  export ${PRG}_I1=${DFILT}/${NJOB}_113_${IB}_ESTC0627_IADPERICASE_O2.dat
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IADPERICASE_O.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_IADPERICASE_TERM_O.dat
  EXECPRG
	
fi




NSTEP=${NJOB}_300
#[006] #[046]
#Merge and Sort of perimeter files by Contract/Endorsement/UW Year
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_292_${IB}_IADPERICASE_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_292_${IB}_IADPERICASE_TERM_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE  ${SORT_O}
exit
EOF
SORT


if [ "$NORME2" != "" ]  # mode double norme
then
   CLOSING_MODE="$NORME2"    # new case for microAOC
else
   CLOSING_MODE="$NORME_CF"
fi

#[028][029]
#PHP
NSTEP=${NJOB}_310
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Compute of profit and loss commission and Loss corridor"
PRG=ESTC1019
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
CLODAT_D ${ICLODAT_D}
CLOTYP_CT ${CLOTYP_CT}
NORME ${CLOSING_MODE}
PRS_CF ${PRS}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_300_${IB}_SORT_IADPERICASE_O.dat  #[020]
#export ${PRG}_I2=${EST_IADPERIFCI}
export ${PRG}_I2=${DFILT}/${NJOB}_187_${IB}_SORT_IADPERIFCI_O.dat
export ${PRG}_I3=${EST_DLCUMGTAATOT}
export ${PRG}_I4=${EST_DLGTAAPA}
export ${PRG}_I5=${EST_DLCUMGTAA}
export ${PRG}_I6=${EST_CTRESTLOSPBPAP}
export ${PRG}_I7=${EST_FCURQUOT}
export ${PRG}_I8=${EST_FTHRHLDUWY}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAAPBPAPLOS_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCTREST3_O2.dat
EXECPRG

##########################
# Merge of FCTREST files #
##########################

# PHP si taux = R regroupement 710, sinon, mettre 730 dans PRS_CF pour EBS
# PHP remplacer tous les PRS_CF 710 par 730
# [023]
NSTEP=${NJOB}_320
# Merge FCTREST and FCTREST
#[028] [032]
#-----------------------------------------------------------------------------
LIBEL="Merge of estimates files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE=YES
SORT_I=${DFILT}/${NJOB}_130_${IB}_ESTC0626_DLCTREST1_O1.dat
SORT_I2=${DFILT}/${NJOB}_190_${IB}_ESTC1016_DLCTREST2_O1.dat
SORT_I3=${DFILT}/${NJOB}_310_${IB}_ESTC1019_DLCTREST3_O2.dat
SORT_I4=${DFILT}/${NJOB}_20_${IB}_ESTC1022_CTREST_O4.dat
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CTREST_O.dat OVERWRITE"  #[034]
SORT_O="${EPO_FCTREST1} OVERWRITE "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DATA1      1:1 -  6:,
        PRS_CF     7:1 -  7:,
        DATA2      8:1 - 23:
/DERIVEDFIELD PRS "${PRS}~"
/OUTFILE ${SORT_O}
/REFORMAT DATA1,PRS,DATA2
exit
EOF
SORT

#[034 debut]
#NSTEP=${NJOB}_321
##EPO_FCTREST0 screen
##
##-----------------------------------------------------------------------------
#LIBEL="EPO_FCTREST0 ==> EPO_FCTREST..."
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EPO_FCTREST0} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CTRESTA_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF 9:1 - 9: EN,
#        PRS_CF 7:1 - 7:,
#        ADMMOD_CT 15:1 - 15:
#/CONDITION INVENTAIRE PRS_CF = "${PRS}" and ADMMOD_CT = "A"
#/INCLUDE INVENTAIRE
#/COPY
#exit
#EOF
#SORT
#
#NSTEP=${NJOB}_322
## Prepare files to filter entries
##-----------------------------------------------------------------------------
#LIBEL="Add a working value at the end of each line"
#SED_EXPR='s/$/~1/'
#SED_I1=${DFILT}/${NJOB}_321_${IB}_SORT_CTRESTA_O.dat
#SED_I2=${EPO_FCTRESTF}
#SED_O1=${DFILT}/${NSTEP}_${IB}_SED_CTRESTA_O1.dat
#SED_O2=${DFILT}/${NSTEP}_${IB}_SED_CTRESTF_O2.dat
#sed $SED_EXPR $SED_I1 > $SED_O1
#sed $SED_EXPR $SED_I2 > $SED_O2
#
#NSTEP=${NJOB}_323
## Merge with original file to get old forced entries
##-----------------------------------------------------------------------------
#LIBEL="Merge files to get old entries"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_322_${IB}_SED_CTRESTA_O1.dat 1000 1"
#SORT_I2="${DFILT}/${NJOB}_322_${IB}_SED_CTRESTF_O2.dat 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CTREST_O.dat 1000 1"
#
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF     1:1 - 1:,
#        END_NT     2:1 - 2:,
#        SEC_NF     3:1 - 3:,
#        UWY_NF     4:1 - 4:,
#        UW_NT      5:1 - 5:,
#        PRS_CF     7:1 - 7:,
#        ACMTRS_NT  8:1 - 8:,
#        CLODAT_D  16:1 - 16:,
#        TMP_VAL   ${COL_NUM323}:1 - ${COL_NUM323}:EN
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      PRS_CF,
#      ACMTRS_NT,
#      CLODAT_D,
#      TMP_VAL
#/SUMMARIZE TOTAL TMP_VAL
#exit
#EOF
#SORT
#
#NSTEP=${NJOB}_324
## Filter entries
##-----------------------------------------------------------------------------
#LIBEL="Filter entries"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_323_${IB}_SORT_CTREST_O.dat 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CTREST_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF 9:1 - 9: EN,
#        PRS_CF 7:1 - 7:,
#        TMP_VAL ${COL_NUM323}:1 - ${COL_NUM323}:
#/CONDITION INVENTAIRE TMP_VAL != "1"
#/INCLUDE INVENTAIRE
#/COPY
#exit
#EOF
#SORT
#
#NSTEP=${NJOB}_325
## Remove working value
##-----------------------------------------------------------------------------
#LIBEL="Remove working value"
#SED_I=${DFILT}/${NJOB}_324_${IB}_SORT_CTREST_O.dat
#SED_O=${DFILT}/${NSTEP}_${IB}_SED_CTREST_O.dat
#sed -E 's/\~[0-9]+$//g' $SED_I > $SED_O
#
#NSTEP=${NJOB}_326
## Merge with original file to get old forced entries
##-----------------------------------------------------------------------------
#LIBEL="Merge with FCTREST FILE"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_NOINFILE=YES
#SORT_I="${DFILT}/${NJOB}_320_${IB}_SORT_CTREST_O.dat 1000 1"
#SORT_I2="${EPO_FCTRESTF} 1000 1"
##SORT_I3="${DFILT}/${NJOB}_325_${IB}_SED_CTREST_O.dat 1000 1"
#SORT_O="${EPO_FCTREST1} OVERWRITE"
#
#echo SORT_I=$SORT_I
#echo SORT_I2=$SORT_I2
#echo SORT_O=$SORT_O
#
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF     1:1 - 1:,
#        END_NT     2:1 - 2:,
#        SEC_NF     3:1 - 3:,
#        UWY_NF     4:1 - 4:,
#        UW_NT      5:1 - 5:,
#        CRE_D      6:1 - 6:,
#        PRS_CF     7:1 - 7:,
#        ACMTRS_NT  8:1 - 8:,
#        ADMMOD_CT  15:1 - 15:
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      CRE_D,
#      PRS_CF,
#      ACMTRS_NT,
#      ADMMOD_CT
#/SUMMARIZE
#exit
#EOF
#SORT

#[034 fin]
#[027]
#[028]
NSTEP=${NJOB}_330
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_ESTC1018_DLGTAALOA_O.dat 500 1"
SORT_I2=${DFILT}/${NJOB}_130_${IB}_ESTC0626_DLGTAAIBNR_O2.dat
SORT_I3=${DFILT}/${NJOB}_180_${IB}_ESTC1015_DLGTAABCREC_O1.dat
SORT_I4=${DFILT}/${NJOB}_310_${IB}_ESTC1019_DLGTAAPBPAPLOS_O1.dat
SORT_O="${EST_DLDGTAA_CUMULS_COUR} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:,
        SCOENDMTH_NF     16:1 - 16:,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:,
        RETSCOENDMTH_NF  32:1 - 32:,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/CONDITION EBS TRNCOD_CF = "1A200712"
/CONDITION I17 TRNCOD_CF = "1120071I" OR TRNCOD_CF = "1120071K" OR TRNCOD_CF = "1120071M"
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD ACMTRS_NT IF EBS THEN "3202~" ELSE IF I17 THEN "3202~" ELSE "~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD ACMTRS ACMTRS_NT COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD EMPTY "~"
/DERIVEDFIELD PLUS_30_CHAMPS 26"~"
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
		      EMPTY,
		      EMPTY,
		      ACMTRS,
          PLUS_30_CHAMPS
exit
EOF
SORT


JOBEND
