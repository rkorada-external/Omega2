#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESID2001D.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 25/08/1997 - 26/01/2012
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 ) 
#
# Job launched by ESID2000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#      23/05/2005  M.DJELLOULI SPOT 11172-11175
#                              Ajout STEP 67 : ReFormatage du PERICASE avec nouveaux Champs Attendus par ESTC1015
#                                                    (Constitué avec Nouveaux Champs de TFAMCHG)
#                              Ajout STEP 68 : Tri Fichier Temporaire STEP 67
#                              Ajout STEP 69 : PGM ESTM7003.c - Liaison PERICASE Reformaté et EST_TFAMCHG
#                              Modif STEP 70 : Suppression IADPERICASE Temporaire STEP 67 & STEP 68
#                              Modif STEP 320 : Nouveau PERICASE Etendu en Entrée. (STEP 69)
#                              Modif STEP 325 : Suppression Fichier ESTM7003_IADPERICASE_O2 du STEP 69
#      28/07/2005  M.DJELLOULI SPOT 11171 - Calcul Burning Cost - Minimum Premium
#                              Modif STEP 320 : Intégration de FCURQUOT dans le Calcul Burning Cost - Minimum Premium
#      06/04/2006 J Ribot      SPOT 12670  Ajout step115 omit affaires decennales hors France sur le perimetre pour ESTC1010.c
#      07/04/2006 J Ribot      SPOT 11507  Ajout step62 et step156  Fichier GT des mvts comptables pour calcul pb traités terminés
#      18/05/2006 J Ribot      SPOT 11175  Ajout step315 tri Fichier Perimetre etendu
#      19/05/2006 J Ribot      suite SPOT 12670  Ajout I2 step115
#                                            Ajout step122 123 124
#      03/05/2007 J Ribot      SPOT 13142 Modif criteres de selection du sort step115 suppression du test sur PCPRSKTRY_CF = 'FRA'
#      07/01/2010 JF VDV       [16778] - Ajout d'un tri STEP92 sur le fichier SAISPERICASE I7 du step95
#[009] 02/04/2010 D.GATIBELZA  ESTDOM18961 French Cat Nat Levy  the use of the code Fac Reinstatement premiums to record our Cat Nat Premiums in order that we can pay the Levy properly
#[010] 21/05/2010 D.GATIBELZA  ESTDOM19486 Mauvaise imputation des charges sur les Non prop type=3 en cas de PNA
#[011] 27/09/2010 D.GATIBELZA  ESTDOM17226 V10 Bug Commission Estimates
#                              le fichier *NPSAIS_O4.dat passe à *NPSAIS_O4.log pour éviter qu'il ne soit effacé en fin de job
#[006] 17/01/2011 D.GATIBELZA  ESTDOM16142 V10 CALCUL ESTIMATION PNA/ FAR ; correction sur les années de compte inférieures à l'exercice
#[007] 07/02/2011 D.GATIBELZA  1GL
#[008] 16/03/2011 R. Cassis    :spot:21408 pas de zip du fichier EST_IGTAA
#[009] 15/11/2011 Florent      :spot:22890 utilisation de EST_MVTPNAC au step 50
#[010] 18/04/2012 Roger Cassis :spot:23802 - Modifications pour Solvency
#[011] 03/09/2012 Roger Cassis :spot:24041 - Modifications pour Solvency 2 - ajout 14 colonnes
#[012] 04/02/2015 F   Maragnes *spot28140   - Modification des steps 150 et  200 on passe en parametre le fichier EST_FTHRHLDUWY  utilisé par la fonction calculExerciceSeuil
#[013] 19/11/2014 R. Cassis    :spot:27747 - OM2C Add 39 columns for multicurrency and future life needs
#[014] 24/04/2015 R. cassis    :spot:28660 - NPSAIS and IBNR log data file of ESTM1007 and ESTC0626 are intermediary files now
#[015] 21/04/2015 R. Cassis    :spot:28305 - Omit FAC RPCC code 11417002 from PNA calcul
#[016] 08/03/2016 Florent      :spot:29066 - formatage du fichier GLT
#[017] 14/08/2019 S.Behague    :REQ_9.2: REQ.P.9.2 - Change in UPR calculation rules
#[018] 30/10/2019 M. NAJI      :spot:81838 - Commenter les gzip de EST_SAISPERICASE, EST_IADPERIPRMD et EST_FLABOCY
#[019] 11/12/2019 S.Behague    :spira:83211: REQ9.2- Do not remove seasonality
#[020] 30/10/2019 M. NAJI      :spira:91531- Ajout Overwrite dans le SORT du step 20
#===========================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
CLOTYP_CT=$3
SEGTYP_CT=$4
ICLODAT_D=$5
SSDs=$6
SSDVRS_LL=$7
LSTCLODAT_LL=$8
SSDDEL_LL=$9

############################################
# Recovering premium estimates and Fac UPR #
############################################

#[007] suppression génération fichier PNA FAC
NSTEP=${NJOB}_20
# Split of EST_MVTPNA on accounting transaction code
#[009] Ajout "11104102" pour le fichier *DLGTAFACPRE_O3.dat
#[015]
#-----------------------------------------------------------------------------
LIBEL="Split of EST_MVTPNA on accounting transaction code"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_MVTPNA}"
SORT_O="${EST_DLGTAFACPNAE} OVERWRITE"
SORT_O2="${EST_DLGTAAFPRE} OVERWRITE"
SORT_O3="${EST_DLGTAFACPNAERPCC} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF   6:1 - 6:,
        CTR_NF      8:1 - 8:,
        END_NT      9:1 - 9:,
        SEC_NF     10:1 - 10:,
        UWY_NF     11:1 - 11:,
        UW_NT      12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION PNAE TRNCOD_CF EQ "11410002"
/CONDITION PNAERPCC TRNCOD_CF EQ "11417002"
/CONDITION PRE TRNCOD_CF EQ "11104002" OR TRNCOD_CF EQ "11107002" OR TRNCOD_CF EQ "11104102" OR TRNCOD_CF EQ "11104102"
/OUTFILE ${SORT_O}
/INCLUDE PNAE
/OUTFILE ${SORT_O2}
/INCLUDE PRE
/OUTFILE ${SORT_O3}
/INCLUDE PNAERPCC
exit
EOF
SORT




NSTEP=${NJOB}_70
#Amount accumulations by contract/endorsement/section/UW year/sequence number/
#transaction code
#-----------------------------------------------------------------------------
LIBEL="Accumulation of acceptation amount by contract"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DSUMGTAA_TERM}
SORT_O=${EST_DLCUMGTAA_TERM}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        BALSHEY_NF       3:1 -  3:,
        BALSHRMTH_NF     4:1 -  4:,
        BALSHRDAY_NF     5:1 -  5:,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:,
        ACMTRS_NT       42:1 - 42:,
        ACMAMT_M        43:1 - 43: EN 15/3,
        ACMCUR_CF       44:1 - 44:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACMTRS_NT
/SUMMARIZE  TOTAL ACMAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
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
          AMT_M,
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
          ACMTRS_NT,
          ACMAMT_MC,
          ACMCUR_CF
exit
EOF
SORT


JOBEND
