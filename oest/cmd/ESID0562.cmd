#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - INVENTAIRE
#                                  Filtre de tous les fichiers
# nom du script SHELL            : ESID0562.cmd
# revision                       : $Revision: 1.2 $
# date de creation               : 05/09/97
# auteur                         : CGI
# references des specifications  : 
#
#-----------------------------------------------------------------------------
# description
#   Filtering files
#
#
#   Output file sort	${EST_FCTRGRO}
#			${EST_FCTRGROBO}
#			${EST_FCTRULT}
#			${EST_FSEGEST}
#			${EST_FLABOCY}
#			${EST_FCTREST}
#			${EST_FCTRESTA}
#			${EST_FOUTTRAA}
#			${EST_FOUTTRAI}
#			${EST_FCMUSPLI}
#			${EST_MVTPNA}
#			${EST_DTSTATGTAA}
#			${EST_IGTAA}
#			${EST_IGTAR}
#			${EST_DLAGTAA}
#			${EST_DLAGTAR}
#			${EST_IGTR}
#			${EST_IADVPERICASE}
#			${EST_FSNEMHIST}
#			${EST_OADVPERICASE}
#
# job launched by ESID0560.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#---------------
#MODIFICATION   : [001]
#Auteur         : D.GATIBELZA
#Date           : 19/01/2010
#Version        : 9.1
#Description    : ESTDOM15043 Ultimes  Revisions des regles de gestion et corrections de l'�cran estimation des ultimes
#---------------
#MODIFICATION   : [002]
#Auteur         : D.GATIBELZA
#Date           : 29/04/2010
#Version        : 10.1
#Description    : ESTVIE18710 Alimentation du MGTAR lors de la comptabilisation de l'arr�t� pour la r�allocation asie
#---------------
#MODIFICATION   : [003]
#Auteur         : D.GATIBELZA
#Date           : 07/02/2011
#Version        : 11.1
#Description    : 1GL
#[004]  11/03/2011  R. CASSIS     :spot:21408 - Modifications sur creation du EST_IGTAAF
#[005]  03/05/2012  R. CASSIS     :spot:23802 - Gzip fichiers pour optimisation
#[006]  26/11/2012  R. CASSIS     :spot:24521 - Solvency 2 - Ajout taille records dans tris
#[007]  04/02/2015  F. MARAGNES   :spot:28140 - Ajout des step 140 � 143 on recupere les tuples (filiale/etablissement/LOB/nature) dans le fichier IAD_PERICASE 
#                                               fusion  avec le fichier FTTHRLDUWY  et dedoublonnage avant de mettre � jour la table TTHRLDUWY 
#[008] 02/02/2016 E. CHATAIN :spot:29066 formatage du fichier GT 71 colonnes
#[009] 23/01/2018       MZA  :Spira 52869 Exclusion des contrats Retro en �tat "Clos" du Closing CTRSTS_CT = "18" 
#[010] 20/06/2018       MZA  :Spira:69785 Ajout de la taille dans le Tri du fichier ${EST_IGTAA0} du step _72
#[011] 20/06/2018       MZA  :Spira:52869 La clture comptable est concern�e par : TERCTR_B <> "1"
#[006] 10/09/2018    M.NAJI  :spira 57605 - add UWY_NF in TCTRGRO 
#[012] 18/03/2019       JYP  :spira:073098: add EST_FCTRESTA for IBNR
#[013] 10/04/2019       JYP  :spira:073098: EST_FCTRESTA IBNR : ignore data from dbo user
#[014] 30/10/2019 M. NAJI    :spot:81838 - Commenter les gzip de EST_IADVPERICASE_ENTIER0
#[015] 21/04/2020 R. Cassis  :spira:86503: Create file FCTRESTF and FCTRESTA with the last records F and A only - remake FCTREST managing
#[016] 12/06/2020 R. Cassis  :spira:86536: Revue de la gestion de FCTREST
#[017] 18/01/2021 R. Cassis  :spira:93390: Suppression de filtres sur dates user
#[018] 29/06/2021 R. Cassis  :spira:97398: Suppression tri SEGEST_SOLVENCY car d�ja extrait dans ESPD0061
#[019] 20/01/2026 M.NAJI     :US7359 SERQS  Impact estimation IFRS17  Closing
#[020] 23/01/2026 M.NAJI     :US 8384 SERQS > Impact Estimation - IFRS4 - Copie 4H
#=============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters

CLODAT_D=$1


#####################
# Perimeters screen #
#####################


NSTEP=${NJOB}_05
#EST_FCTRGRO0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCTRGRO0 ==> EST_FCTRGRO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO0} 1000 1"
SORT_O="${EST_FCTRGRO} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 5:1 - 5: EN,
        CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 21:1 - 21:,
        SEGTYP_CT 6:1 - 6:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
  	UWY_NF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SEGTYP_CT = "A"
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_10
#EST_FCTRGRO0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCTRGRO0 ==> EST_FCTRGROBO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO0} 1000 1"
SORT_O="${EST_FCTRGROBO} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 5:1 - 5: EN,
        CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3: EN,
        UWY_NF 21:1 - 21:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
	  UWY_NF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_15
#FCTRULT0 screen
#[001] On ne met en sortie que les champs de TCTRULT d'avant la fiche SPOT      => #[001]/COPY remplac� par un REFORMAT /OUTFILE ${SORT_O} /REFORMAT TCTRULT_FORMAT
#-----------------------------------------------------------------------------
LIBEL="FCTRULT0 ==> FCTRULT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRULT0} 1000 1"
SORT_O="${EST_FCTRULT} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 7:1 - 7: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} 
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

#NSTEP=${NJOB}_15
##FCTRULT0 screen
##[001] On ne met en sortie que les champs de TCTRULT d'avant la fiche SPOT      => #[001]/COPY remplac� par un REFORMAT /OUTFILE ${SORT_O} /REFORMAT TCTRULT_FORMAT
##-----------------------------------------------------------------------------
#LIBEL="FCTRULT0 ==> FCTRULT..."
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_FCTRULT0} 1000 1"
#SORT_O="${EST_FCTRULT} 1000 1 OVERWRITE"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF          7:1 - 7: EN,
#        TCTRULT_FORMAT  1:1 - 23
#/CONDITION INVENTAIRE ${EST_SORT_CONDITION} 
#/INCLUDE INVENTAIRE
#/COPY
#exit
#EOF
#SORT

NSTEP=${NJOB}_20
#EST_FSEGEST0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FSEGEST0 ==> EST_FSEGEST ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FSEGEST0} 1000 1"
SORT_O="${EST_FSEGEST} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_25
#EST_FLABOCY0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FLABOCY0 ==> EST_FLABOCY..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FLABOCY0} 1000 1"
SORT_O="${EST_FLABOCY} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 2:1 - 2: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_35
#EST_FOUTTRAA0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FOUTTRAA0 ==> EST_FOUTTRAA..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FOUTTRAA0} 1000 1"
SORT_O="${EST_FOUTTRAA} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 4:1 - 4: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_40
#EST_FOUTTRAI0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FOUTTRAI0 ==> EST_FOUTTRAI..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FOUTTRAI0} 1000 1"
SORT_O="${EST_FOUTTRAI} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_45
#EST_FACCTRAA0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FACCTRAA0 ==> EST_FACCTRAA..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCTRAA0} 1000 1"
SORT_O="${EST_FACCTRAA} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 4:1 - 4: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_50
#EST_FCMUSPLI0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCMUSPLI0 ==> EST_FCMUSPLI..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCMUSPLI0} 1000 1"
SORT_O="${EST_FCMUSPLI} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_55
#EST_FCMUSPLIT0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCMUSPLIT0 ==> EST_FCMUSPLIT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCMUSPLIT0} 1000 1"
SORT_O="${EST_FCMUSPLIT} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_60
# EST_MVTPNA screen on the subsidary
#-----------------------------------------------------------------------------
LIBEL="EST_MVTPNA0 ==> EST_MVTPNA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_MVTPNA0} 1000 1"
SORT_O="${EST_MVTPNA} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} AND
        BALSHEY_NF   EQ ${ICLODAT_YEA} AND
        BALSHRMTH_NF EQ ${ICLODAT_MTH} AND
        BALSHRDAY_NF EQ ${ICLODAT_DAY}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

#[006]
NSTEP=${NJOB}_65
#EST_DTSTATGTAA0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_DTSTATGTAA0 ==> EST_DTSTATGTAA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DTSTATGTAA0} 1000 1"
SORT_O="${EST_DTSTATGTAA} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_71
# Split of EST_MVTPNA on accounting transaction code
#[009] Ajout "11104102" pour le fichier *DLGTAFACPRE_O3.dat
#[004]
#-----------------------------------------------------------------------------
LIBEL="Split of EST_MVTPNA on accounting transaction code"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_MVTPNA} 1000 1"
SORT_O="${EST_MVTPNAC}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF   6:1 - 6:,
        CTR_NF      8:1 - 8:,
        END_NT      9:1 - 9:,
        SEC_NF     10:1 - 10:,
        UWY_NF     11:1 - 11:,
        UW_NT      12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION PNAC TRNCOD_CF EQ "11410000" OR TRNCOD_CF EQ "11430000" OR TRNCOD_CF EQ "11436000"
/OUTFILE ${SORT_O}
/INCLUDE PNAC

exit
EOF
SORT

#[003] [010]
NSTEP=${NJOB}_72
# 1GL, G�n�ration IGTAAF
#-----------------------------------------------------------------------------
LIBEL="1GL, G�n�ration IGTAAF � partir de EST_MVTPNA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_MVTPNAC} 1000 1"
SORT_I2="${EST_IGTAA0} 1000 1"
SORT_O="${EST_IGTAAF} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 - 1: EN,
        TRNCOD_CF        6:1 - 6:,
        FORMAT_STANDARD  1:1 - 41:
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_75
#EST_IGTAR0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IGTAR0 ==> EST_IGTAR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IGTAR0} 1000 1"
SORT_O="${EST_IGTAR} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_80
#EST_DLAGTAA0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_DLAGTAA0 ==> EST_DLAGTAA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLAGTAA0} 1000 1"
SORT_O="${EST_DLAGTAA} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/COPY
exit
EOF
SORT

#[019] /INCLUDE INVENTAIRE
#[019] /CONDITION INVENTAIRE ${EST_SORT_CONDITION}

NSTEP=${NJOB}_85
#EST_DLAGTAR0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_DLAGTAR0 ==> EST_DLAGTAR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLAGTAR0} 1000 1"
SORT_O="${EST_DLAGTAR} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/COPY
exit
EOF
SORT

#[020] /INCLUDE INVENTAIRE
#[020] /CONDITION INVENTAIRE ${EST_SORT_CONDITION}

NSTEP=${NJOB}_90
#EST_IGTR0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IGTR0 ==> EST_IGTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IGTR0} 1000 1"
SORT_O="${EST_IGTR} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_95
#EST_DLAGTR0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_DLAGTR0 ==> EST_DLAGTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLAGTR0} 1000 1"
SORT_O="${EST_DLAGTR} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/COPY
exit
EOF
SORT

#/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#/INCLUDE INVENTAIRE

NSTEP=${NJOB}_100
#EST_IADVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IADVPERICASE0 ==> EST_IADVPERICASE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE0} 1000 1"
SORT_O="${EST_IADVPERICASE} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/COPY
exit
EOF
SORT

#/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#/INCLUDE INVENTAIRE


#[002]
NSTEP=${NJOB}_101
#EST_IADVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IADVPERICASE_ENTIER0 ==> EST_IADVPERICASE_ENTIER ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE_ENTIER0} 1000 1"
SORT_O="${EST_IADVPERICASE_ENTIER} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

# [009] [011] DEB Exclusion des contrats Retro Clos 
# NSTEP=${NJOB}_105
# #EST_IRDVPERICASE0 screen
# #-----------------------------------------------------------------------------
# LIBEL="EST_IRDVPERICASE0 ==> EST_IRDVPERICASE ..."
# SORT_WDIR=${SORTWORK}
# SORT_CMD=`CFTMP`
# SORT_I="${EST_IRDVPERICASE0} 1000 1"
# SORT_O="${EST_IRDVPERICASE} OVERWRITE"
# INPUT_TEXT ${SORT_CMD} <<EOF
# /FIELDS SSD_CF 1:1 - 1: EN		
# /CONDITION INVENTAIRE ${EST_SORT_CONDITION}
# /INCLUDE INVENTAIRE
# /COPY
# exit
# EOF
# SORT

NSTEP=${NJOB}_104
#EST_IRDVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IRDVPERICASE0 ==> EST_IRDVPERICASE ..."
# [009] Exclusion des contrats Retro Clos 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDVPERICASE0 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        TERCTR_B 192:1 - 192:
/CONDITION CONTRATCLOS (TERCTR_B != "1")
/INCLUDE CONTRATCLOS
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_105
#EST_IRDVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IRDVPERICASE0 ==> EST_IRDVPERICASE ..."
# [009] [011] Exclusion des contrats Retro Clos 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_104_${IB}_SORT_IRDVPERICASE0 1000 1"
SORT_O="${EST_IRDVPERICASE} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT
# [009] [011] FIN Exclusion des contrats Retro Clos 

NSTEP=${NJOB}_110
#EST_FSNEMHIST0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FSNEMHIST0 ==> EST_FSNEMHIST ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FSNEMHIST0} 1000 1"
SORT_O="${EST_FSNEMHIST} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_115
#EST_ORDVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_ORDVPERICASE0 ==> EST_ORDVPERICASE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_ORDVPERICASE0} 1000 1"
SORT_O="${EST_ORDVPERICASE} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_120
#EST_OADVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_OADVPERICASE0 ==> EST_OADVPERICASE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OADVPERICASE0} 1000 1"
SORT_O="${EST_OADVPERICASE} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_125
#EST_FACCTRAI0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FACCTRAI0 ==> EST_FACCTRAI..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCTRAI0} 1000 1"
SORT_O="${EST_FACCTRAI} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 4:1 - 4: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT

##[005] [018]
#NSTEP=${NJOB}_130
##EST_FSEGEST_SOLVENCY0 screen
##-----------------------------------------------------------------------------
#LIBEL="EST_FSEGEST_SOLVENCY0 ==> EST_FSEGEST_SOLVENCY..."
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_FSEGEST_SOLVENCY0} 1000 1"
#SORT_O="${EST_FSEGEST_SOLVENCY} OVERWRITE"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF 1:1 - 1: EN
#/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#/INCLUDE INVENTAIRE
#/COPY
#exit
#EOF
#SORT

NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
LIBEL="Completion du ficher FTTHRHLDUWY avec les donnes de l'IADPERICASE "
DATE_T=`date +"%Y%m%d %H:%M:%S"`
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
echo " Date {$DATE_T} "
SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_FTHRHLDUWYBIS.dat	
INPUT_TEXT ${SORT_CMD} <<EOF

/FIELDS SSD_CF 1:1 - 1: EN , ACCESB_CF  8:1 -  8:, LOB_CF  38:1 -  38:, NAT_CF  49:1 -  49: EN ,CTRNAT_CT 85:1 - 85:
/KEYS  SSD_CF ,ACCESB_CF ,LOB_CF,NAT_CF , CTRNAT_CT
/CONDITION COND_NATURE (CTRNAT_CT  != "F")
/CONDITION COND_NATURE1 (CTRNAT_CT  eq "P")
/DERIVEDFIELD NATURE IF  COND_NATURE  THEN  IF COND_NATURE1 THEN "1~" ELSE "2~" ELSE "3~"
/DERIVEDFIELD UWY "2003~"
/DERIVEDFIELD DATE1  "${DATE_T}~" 
/DERIVEDFIELD DBO "dbo~"
/DERIVEDFIELD DATE2 "${DATE_T}~" 
/DERIVEDFIELD DBO1 "dbo"
/OUTFILE   ${SORT_O}
/INCLUDE COND_NATURE
/REFORMAT SSD_CF,ACCESB_CF,LOB_CF,NATURE,UWY,DATE1,DBO,DATE2,DBO1
exit
EOF
SORT
NSTEP=${NJOB}_141
#-----------------------------------------------------------------------------
LIBEL="Merge des fichiers FTHRHLDUWY  et  FTHRHLDUWYBIS.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FTHRHLDUWY}
SORT_I2="${DFILT}/${NJOB}_140_${IB}_FTHRHLDUWYBIS.dat"
SORT_O=${DFILT}/${NSTEP}_${IB}_FTHRHLDUWYTEMP.dat	
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN , ACCESB_CF 2:1 - 2: ,LOB_CF 3:1 - 3: ,NAT_CF 4:1 - 4: ,PARAM1 5:1 - 5:   ,DATE1 6:1 - 6: ,DBO 7:1 - 7: ,DATE2 8:1 - 8: ,DBO1 9:1 - 9:
/OUTFILE ${SORT_O}
/COPY 
exit
EOF
SORT

NSTEP=${NJOB}_142
#-----------------------------------------------------------------------------
LIBEL="dedoublonnage du fichier FTHRHLDUWYBIS.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_141_${IB}_FTHRHLDUWYTEMP.dat
SORT_O=${EST_FTHRHLDUWY}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:, ACCESB_CF  2:1 -  2:, LOB_CF  3:1 -  3:, NAT_CF  4:1 -  4:
/KEYS  SSD_CF ,ACCESB_CF ,LOB_CF,NAT_CF
/SUM
/STABLE
/OUTFILE ${SORT_O}
exit
EOF
SORT

###########################################################################
# [015] Now process FCTREST 
###########################################################################

###########################################################################
#[015] [016] start [017]

NSTEP=${NJOB}_200
# FCTREST0 filter on type 'F' records
#-----------------------------------------------------------------------------
LIBEL="FCTREST0 filter on type 'F' and 'A' records DESCENDING on CRE_D"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTREST0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTREST0F_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FCTREST0A_O.dat 1000 1"
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
        ORICOD_LS 17:1 - 17:,
        CREUSR_CF 19:1 - 19:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      ADMMOD_CT,
      CRE_D DESC
/CONDITION TYPEF ADMMOD_CT = "F" AND CLODAT_D = "${PARM0_ICLODAT_D}"
/CONDITION TYPEA ADMMOD_CT = "A" AND CLODAT_D = "${PARM0_ICLODAT_D}" and ORICOD_LS != "CloP" 
/OUTFILE ${SORT_O}
/INCLUDE TYPEF
/OUTFILE ${SORT_O2}
/INCLUDE TYPEA
exit
EOF
SORT

NSTEP=${NJOB}_210
# We keep only the last versus of each key for a quarter for type 'F' based on CRE_D
#-----------------------------------------------------------------------------
LIBEL="We keep only the last versus of each key for a quarter for type 'F' based on CRE_D"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_SORT_FCTREST0F_O.dat 1000 1"
SORT_O="${EST_FCTRESTF} 1000 1 OVERWRITE"
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

NSTEP=${NJOB}_220
# We keep only the last versus of each key for a quarter for type 'A' based on CRE_D
#-----------------------------------------------------------------------------
LIBEL="We keep only the last versus of each key for a quarter for type 'A' based on CRE_D"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_SORT_FCTREST0A_O.dat 1000 1"
SORT_O="${EST_FCTRESTA} 1000 1 OVERWRITE"
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

NSTEP=${NJOB}_230
# execksh
#------------------------------------------------------------------------------
LIBEL="cp ${EST_FCTRESTF} keep original file on ${EST_FCTRESTF0}"
EXECKSH_MODE=P
EXECKSH "cp ${EST_FCTRESTF} ${EST_FCTRESTF0}"

if [ ! -s ${EST_FCTRESTA} ]
then
	JOBEND
fi

#############################################################################
# The following process is done to omit records F that are processed 
# because for same key we can have a record type A that replace previous record type F
#############################################################################

NSTEP=${NJOB}_240
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort by key section and CLODAT/ACMTRS/CRE_D DESC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCTRESTF}
SORT_I2=${EST_FCTRESTA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTREST_O.dat
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
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CLODAT_D, ACMTRS_NT, CRE_D DESC
exit
EOF
SORT

NSTEP=${NJOB}_250
# We keep only the last versus of each key for a quarter
#-----------------------------------------------------------------------------
LIBEL="We keep only the last versus of each key for a quarter F or A"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_240_${IB}_SORT_FCTREST_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTREST1AF_O.dat
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
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CLODAT_D, ACMTRS_NT
/STABLE
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_260
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Keep only records mode F"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_SORT_FCTREST1AF_O.dat 500 1"
SORT_O="${EST_FCTRESTF} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       9:1 -  9:EN,
        CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:,
        SEC_NF       3:1 -  3:,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:,
        CRE_D        6:1 -  6:,
        PRS_CF       7:1 -  7:,
        ACMTRS_NT    8:1 -  8:,
        ADMMOD_CT   15:1 -  15:,
        CLODAT_D    16:1 - 16:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CLODAT_D, ACMTRS_NT, CRE_D
/CONDITION ADMMODF ADMMOD_CT = "F"
/OUTFILE ${SORT_O}
/INCLUDE ADMMODF
exit
EOF
SORT

#[015] [016] End
###########################################################################

JOBEND
