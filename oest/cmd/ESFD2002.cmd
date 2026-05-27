#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESID2002.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 31/05/2012
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2000.cmd
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
#[024] 29/06/2018 R. Cassis    :spira 65656 - EBS FORCED IBNR : Nommage fichier pour EBS
#[025] 09/10/2018 JYP          :IFRS17 req 10.6 : exclude new segtyps V W X from SEGEST file
#[026] 12/04/2019 R. Cassis    :cpira:65656 - Suppression de l'option EBS lors d'un inventaire IFRS
#[027] 20/09/2019 R. Vieville  :spira:77465 - Ajout param IFRS4 ESTC1019
#[028] 19/08/2019 Roger        :spira:65656 - Gestion PRS_CF pour IFRS4(710) ou EBS(730)
#[029] 20/09/2019 NLD  		     :spira:67260 - Ajout input CURQUOT ESTC0623
#[030] 02/01/2020 Roger        :spira:84424 - remplacement fichiers EPO_ par EST_ pour PERICASE et CTRULT2 - suppression partie POSE et gzip
#[031] 24/02/2020 Roger        :spira:84424 - pour les modes 'F' force IBNR, on soustrait le montant de la ligne mode 'A' 
#[032] 22/04/2020 Roger        :spira:86503 - Ajustement des noms de fichiers FCTRESTF et FCTRESTA - on ne soustrait plus le montant IFRS ligne A de la ligne F
#[033] 14/07/2020 KBAGWE       :spira:81022 - NDIC floarat file genration step:_190
#[034] 13/07/2020 Roger        :spira:86536 - Gestion FCTREST - Suppression de code inutile (car gere maintenant dans ESID8000)
#[035] 01/10/2020 MZM          :spira:88836 IFRS 17 - REQ 11.07 - Tax rate not applied when section >= 10 : Ajout du parametre CHAIN pour trie par No Section Numerique si CHAIN = ESFD2220
#[036] 22/04/2021 MiS          :spira:86214 - ajout DLCUMGTAAR pour calcul de Recieved minimum variable commission dans ESTC1017
#[037] 22/04/2021 MiS          :spira:90073 - ajout des AE pour calcul de DAC IFRS17
#[038] 27/04/2021 Roger        :spira:92617 - Extract Segment Amount type AMORAT_Ct for pgm ESTC0626
#[039] 30/06/2021 Roger        :spira:97314 - Save IBNR data into a file for next INV EBS
#[040] 10/11/2022 MZM          :spira:107676 - discrepancies between IN2 and INT  (Tri des fichiesr  IADPERIFCI step 305)
#[041] 02/02/2023 HR           :spira:108129 - Aligner le tableau charge de l'ecran SCR-EST-PAC-30677 avec le GT - Copy - Copy
#===========================================================
#set -x

# ***************************************************************************************
# ***************************************************************************************
# ATTENTION : à faire 
# PHP ajouter colonne PRS_CF dans EST_FT EST_FLOARAT et ensuite forcer 710 ou 730 selon taux
# ***************************************************************************************
# ***************************************************************************************

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


# NORME TAUX = R (Book:IFRS) / T (Best:EBS)
NORME=$9
TYPEINV=${10}

#[001] Affestation nom des fichiers selon la valeur du taux
# PHP faire pareil avec les fichiers

PRS=710
EST_FT=${EST_FT_IFRS}
EST_DLDGTAA=${EST_DLDGTAA_IFRS}
EST_FLOARAT=${EST_FLOARAT_IFRS}
EST_FPRMLOA=${EST_FPRMLOA_IFRS}
EST_FSEGEST=${EST_FSEGEST}	
EST_IBNR=${EST_IBNR_IFRS}        # [012]
EST_DTSTATGTAA=${EST_DTSTATGTAA} # [017]
# le nombre de colonne de FCTREST est different en fonction de l'inventaire
COL_NUM323=24


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV...................= ${TYPEINV}"
ECHO_LOG "#===> NORME.....................= ${NORME}"
ECHO_LOG "#===> COL_NUM323................= ${COL_NUM323}"
ECHO_LOG "#===> EST_FTFAMCHG..............= ${EST_FTFAMCHG}"
ECHO_LOG "#===> EST_FT....................= ${EST_FT}"
ECHO_LOG "#===> EST_FCTREST0..............= ${EST_FCTREST0}"
ECHO_LOG "#===> EST_FCTREST1..............= ${EST_FCTREST1}"
ECHO_LOG "#===> EST_FCTRESTA..............= ${EST_FCTRESTA}"
ECHO_LOG "#===> EST_FCTRESTF..............= ${EST_FCTRESTF}"
ECHO_LOG "#===> EST_FLOARAT...............= ${EST_FLOARAT}"
ECHO_LOG "#===> EST_FPRMLOA...............= ${EST_FPRMLOA}"
ECHO_LOG "#===> EST_DLCGTAA...............= ${EST_DLCGTAA}"
ECHO_LOG "#===> EST_DLGTAAPA..............= ${EST_DLGTAAPA}"
ECHO_LOG "#===> EST_DCGTAALOA.............= ${EST_DCGTAALOA}"
ECHO_LOG "#===> EST_DLGTAAFPRE............= ${EST_DLGTAAFPRE}"
ECHO_LOG "#===> EST_DLCGTAAREC............= ${EST_DLCGTAAREC}"
ECHO_LOG "#===> EST_DLGTAARPPE............= ${EST_DLGTAARPPE}"
ECHO_LOG "#===> EST_DLGTAAPRE.............= ${EST_DLGTAAPRE}"
ECHO_LOG "#===> EST_DLGTAATFPNAE..........= ${EST_DLGTAATFPNAE}"
ECHO_LOG "#===> EST_DLCGTAAEPPE...........= ${EST_DLCGTAAEPPE}"
ECHO_LOG "#===> EST_FTFAC.................= ${EST_FTFAC}"
ECHO_LOG "#===> EST_FCTRGRO...............= ${EST_FCTRGRO}"
ECHO_LOG "#===> EST_FCTRGRO1..............= ${EST_FCTRGRO1}"
ECHO_LOG "#===> EST_LABOCY1...............= ${EST_LABOCY1}"
ECHO_LOG "#===> EST_FSEGEST...............= ${EST_FSEGEST}"
ECHO_LOG "#===> EST_DLDGTAA...............= ${EST_DLDGTAA}"
ECHO_LOG "#===> EST_FCURQUOT..............= ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_IADPERIFR.............= ${EST_IADPERIFR}"
ECHO_LOG "#===> EST_IADPERICASE...........= ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_DLCUMGTAAS............= ${EST_DLCUMGTAAS}"
ECHO_LOG "#===> EST_CTRULT02..............= ${EST_CTRULT02}"
ECHO_LOG "#===> EST_FTTR_PRM..............= ${EST_FTTR_PRM}"
ECHO_LOG "#===> EST_IADPERIFCT............= ${EST_IADPERIFCT}"
ECHO_LOG "#===> EST_IADPERIFCI............= ${EST_IADPERIFCI}"
ECHO_LOG "#===> EST_IBNR..................= ${EST_IBNR}"
ECHO_LOG "#===> EST_DLCUMGTAA.............= ${EST_DLCUMGTAA}"
ECHO_LOG "#===> EST_FTHRHLDUWY............= ${EST_FTHRHLDUWY}"
ECHO_LOG "#===> EST_BLANCHIMENT_RPCC......= ${EST_BLANCHIMENT_RPCC}"
ECHO_LOG "#===> EST_DTSTATGTAA............= ${EPO_DTSTATGTAA}"
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
SORT_I=${EST_FCTRESTF}
SORT_I2=${EST_FCTRESTA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CTREST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       9:1 -  9:EN,
        CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:,
        SEC_NF       3:1 -  3:,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:,
        CLODAT_D    16:1 - 16:,
        PRS_CF       7:1 -  7:,
        ACMTRS_NT    8:1 -  8:,
        CRE_D        6:1 -  6:
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
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRESTLOSPBPAP_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRESTCV_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRESTCLM_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_CTREST_O4.dat
EXECPRG

#############################################################
# Calculation of losses and IBNR ( Set 6 encapsulation  )   #
#############################################################

if [ "${TYPEINV}" != "INV" ]
then
	NSTEP=${NJOB}_30
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Omet les mouvements de retro interne du Pericase"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_IADPERICASE} 1000 1"
	SORT_O=${EST_IADPERICASE_NON_TERM}
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
	SORT_I=${EST_FCTRULT}
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

	EST_CTRULT02=${DFILT}/${NJOB}_40_${IB}_SORT_CTRULT02_O1.dat

fi

NSTEP=${NJOB}_50
#Accumulation of TL work file on occurence year
#-----------------------------------------------------------------------------
LIBEL="Accumulation of TL work file on occurence year in progress..."
PRG=ESTC0602
export ${PRG}_I1=${EST_DLCGTAA}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTCUMUL_O.dat
EXECPRG

#[028]
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
export ${PRG}_I1=${EST_IADPERICASE_NON_TERM}
export ${PRG}_I2=${EST_CTRULT02}
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
/CONDITION BOOK ( AMORAT_CT = "R" OR AMORAT_CT = "S" ) AND ( SEGTYP_CT != "V" AND SEGTYP_CT != "W" AND SEGTYP_CT != "X" ) 
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
LIBEL="sort ${EST_IADPERICASE_TERM} by Contrat/End Contrat/Segment/UW Year"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_NON_TERM} 1000 1"
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

#[038]
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

#[028]
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
#export ${PRG}_I2=${DFILT}/${NJOB}_110_${IB}_ESTC0625_SEGESTEST_O.dat         # [038]
export ${PRG}_I2=${DFILT}/${NJOB}_126_${IB}_SORT_SEGESTEST_O.dat 
export ${PRG}_I3=${DFILT}/${NJOB}_70_${IB}_SORT_PERICASESEG_O.dat            # PHP vient du 2001 à mettre dans DFILI
export ${PRG}_I4=${EST_LABOCY1}                                               # PHP vient du 2001 à mettre dans DFILI
export ${PRG}_I5=${DFILT}/${NJOB}_120_${IB}_SORT_GTCUMUL_O.dat
export ${PRG}_I6=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCTREST1_O1.dat              # PHP on récupère ici les montants IBNR1A et IBNR1B
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAAIBNR_O2.dat             # PHP on récupère ici les montants IBNR1A et IBNR1B, au format GT
export ${PRG}_O3=${EST_IBNR}                                                  # [007] GLE - ajout d un fichier de Trace pour les IBNR #[012]
export ${PRG}_O4=${EST_BLANCHIMENT_RPCC}									  # [016] Ajout de la log 
if [ "${BALSHTYEA_NF}" = "2014" ]  
then 
	PRG=ESTC0626_OLD
else
	PRG=ESTC0626
fi
export ${PRG}_PRM=${FPRM}
EXECPRG

#[039]
NSTEP=${NJOB}_140
#-----------------------------------------------------------------
LIBEL="Save IBNR data for next INV EBS"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_130_${IB}_ESTC0626_DLGTAAIBNR_O2.dat ${EST_DLDGTAA_IBNRIFRS}"

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
export ${PRG}_I2=${EST_IADPERIFR}
export ${PRG}_I3=${DFILT}/${NJOB}_150_${IB}_SORT_DLCUMGTAAIBNR_O.dat
export ${PRG}_I4=${EST_DLCUMGTAAS}
export ${PRG}_I5=${EST_FTTR_PRM}
export ${PRG}_I6=${EST_CTRULT02}
export ${PRG}_I7=${EST_FCURQUOT}
export ${PRG}_I8=${EST_FTHRHLDUWY}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAABCREC_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTTR_O2.dat
EXECPRG

#####################################
# Calculation of loading estimates  #
#####################################

#[028] #[035]
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
export ${PRG}_I1=${EST_IADPERICASE_NON_TERM}	# PHP mettre ici un fichier dans DFILI
export ${PRG}_I2=${EST_IADPERIFCT}
export ${PRG}_I3=${EST_IADPERIFCI}
export ${PRG}_I4=${EST_DLCUMGTAAS}
export ${PRG}_I5=${EST_DLGTAAPA}
export ${PRG}_I6=${DFILT}/${NJOB}_20_${IB}_ESTC1022_CTRESTCV_O2.dat	# PHP commissions variables existantes
export ${PRG}_I7=${DFILT}/${NJOB}_150_${IB}_SORT_DLCUMGTAAIBNR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCTREST2_O1.dat				# PHP calcul des commissions variables en sortie
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FLOARAT_O2.dat				# PHP calcul des commissions variables en sortie
EXECPRG

# cumul des 2 taux mais pas bon -> a revoir
NSTEP=${NJOB}_200
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Merge  and Sort of Treaty and Fac working Files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_ESTC1015_FTTR_O2.dat 1000 1"
# PHP attention, ici tu as mis en dur le temoin R et non pâs {NORME}
#SORT_I2="${DFILT}/${NJOB}_180_${IB}_ESTC1015_FTTR_O2_T.dat 1000 1"
SORT_I3="${EST_FTFAC} 1000 1"        # PHP faire un fichier dans DFILI
SORT_I4="${EST_FTPNA17} 1000 1"
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
    ( WFCOD_NT EQ "10000" or WFCOD_NT EQ "8000" or WFCOD_NT EQ "99999" ) and
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

#[037]
NSTEP=${NJOB}_215
#------------------------------------------------------------------------------
# sort and Merge of the ${EST_EPOSOCI} ${EST_FACCSUP0} file
#------------------------------------------------------------------------------
LIBEL="Sort of $ESF_FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_EPOSOCI} 2000 1"
SORT_I2="${EST_FACCSUP0} 2000 1"
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

if [ ! -f ${EST_DLCUMGTAAR} ]
then
    touch ${EST_DLCUMGTAAR}
fi

#[036]
NSTEP=${NJOB}_218
#------------------------------------------------------------------------------
# sort of the ${EST_DLCUMGTAAR} file
#------------------------------------------------------------------------------
LIBEL="Sort of $EST_DLCUMGTAAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLCUMGTAAR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_SORT.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF    8:1  -  8:,
        END_NT    9:1  -  9:,
        SEC_NF    10:1 -  10:,
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

#[028]
NSTEP=${NJOB}_220
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Loading Compute"
PRG=ESTC1017
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
PRS_CF ${PRS}
CLODAT_D ${ICLODAT_D}
NORME ${VNORME}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_210_${IB}_SORT_FTCUM_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_190_${IB}_ESTC1016_FLOARAT_O2.dat
export ${PRG}_I3=${EST_DCGTAALOA}
export ${PRG}_I4=${EST_IADPERICASE_NON_TERM}
export ${PRG}_I5=${EST_DLGTAAFPRE}
export ${PRG}_I6=${EST_DLCGTAAREC}
export ${PRG}_I7=${DFILT}/${NJOB}_215_${IB}_GTAE.dat
export ${PRG}_I8=${EST_FBOPRSLNK}
export ${PRG}_I9=${DFILT}/${NJOB}_218_${IB}_DLCUMGTAAR_SORT.dat
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


#[041]
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

#[041]
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


#[041]
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

#[041]
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

#[041]
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

#[041]
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

#[041]
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



#[041]
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

#[041]
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
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAATOT_O.dat  # DFILI
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

NSTEP=${NJOB}_290
#-----------------------------------------------------------------------------
LIBEL="sort ${EST_IADPERICASE_TERM} by Contrat/End Contrat/Segment/UW Year"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_TERM} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_TERM_O.dat 1000 1"
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
	
NSTEP=${NJOB}_292
#-----------------------------------------------------------------------------
LIBEL="maj sinistralite pour ${TYPEINV} du IADPERICASE des terminé comptable du 2001"
PRG=ESTC0627
export ${PRG}_I1=${DFILT}/${NJOB}_111_${IB}_SORT_PERICASEEST_O1.dat
export ${PRG}_I2=${DFILT}/${NJOB}_290_${IB}_SORT_IADPERICASE_TERM_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_110_${IB}_ESTC0625_SEGESTEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IADPERICASE_TERM_O.dat
EXECPRG

NSTEP=${NJOB}_300
#[006]
#Merge and Sort of perimeter files by Contract/Endorsement/UW Year
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_113_${IB}_ESTC0627_IADPERICASE_O2.dat 1000 1"
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


#[046] Tri du fichier EST_IADPERIFCI 
NSTEP=${NJOB}_305
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


#[027][028]
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
NORME IFRS4
PRS_CF ${PRS}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_300_${IB}_SORT_IADPERICASE_O.dat  #[020]
#export ${PRG}_I2=${EST_IADPERIFCI}
export ${PRG}_I2=${DFILT}/${NJOB}_305_${IB}_SORT_IADPERIFCI_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_280_${IB}_SORT_DLCUMGTAATOT_O.dat
export ${PRG}_I4=${EST_DLGTAAPA}
export ${PRG}_I5=${EST_DLCUMGTAA}
export ${PRG}_I6=${DFILT}/${NJOB}_20_${IB}_ESTC1022_CTRESTLOSPBPAP_O1.dat
export ${PRG}_I7=${EST_FCURQUOT}
export ${PRG}_I8=${EST_FTHRHLDUWY}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAAPBPAPLOS_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCTREST3_O2.dat
EXECPRG

##########################
# Merge of FCTREST files #
##########################

touch ${DFILT}/${NJOB}_320_${IB}_SORT_CTREST_O.dat

# PHP si taux = R regroupement 710, sinon, mettre 730 dans PRS_CF pour EBS
# PHP remplacer tous les PRS_CF 710 par 730
# [023]
NSTEP=${NJOB}_320
# Merge FCTREST and FCTREST
#-----------------------------------------------------------------------------
LIBEL="Merge of estimates files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE=YES
SORT_I=${DFILT}/${NJOB}_130_${IB}_ESTC0626_DLCTREST1_O1.dat
SORT_I2=${DFILT}/${NJOB}_190_${IB}_ESTC1016_DLCTREST2_O1.dat
SORT_I3=${DFILT}/${NJOB}_310_${IB}_ESTC1019_DLCTREST3_O2.dat
SORT_I4=${DFILT}/${NJOB}_20_${IB}_ESTC1022_CTREST_O4.dat
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CTREST_O.dat OVERWRITE"    #[034]
SORT_O="${EST_FCTREST1} OVERWRITE "
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

#[031]
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
SORT_O="${EST_DLDGTAA} OVERWRITE"
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
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD PLUS_30_CHAMPS 29"~"
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
          PLUS_30_CHAMPS
exit
EOF
SORT

JOBEND
