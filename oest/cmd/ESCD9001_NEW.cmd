#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
# nom du script SHELL           : ESCD9001.cmd
# revision                      : $Revision: 1.44 $
# date de creation              : 26/05/1997
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description:
#  links between logical and physical names of permanent files
#-----------------------------------------------------------------------------
# historiques des modifications
#  <H. GUIHEUX> <2000/10/10> STA_EDIVIE_LSTCLS variable:
#   New Variable to define Permanent Estimates Life file of the last closing
#  J. RIBOT  28/05/2003 ajout ESID0070
#  J. RIBOT  15/09/2003 ajout DWUD0010 et DWUD0030 (extraction FCALEND ESID0060)
#  R. CASSIS 05/10/2003 Ajustements sur DWUD0010 et DWUD0030 (rajout conditions)
#  J. RIBOT  27/11/2003 ajout EST_LIFDANO shell  ESID2030
#  J. RIBOT  03/12/2003 modif TEST sur "${IsFilAllClo}" != ""
#
#  J. RIBOT  08/07/2004 ajout LIFEP ESCJ0060
#                       ajout ESID2020
#
#     12/08/04  Par M. DJELLOULI
#                            Modification Ventilation Non Prop Solution 1 ou 2
#                             JOB=ESID0060          EST_FTVENTNP= ESID0060 ${DFILP}
#                       (2)  JOB=ESID2560           EST_FTRSLNK   ESCJ0060 ${DFILI}
#                                                         EST_FTVENTNP ESID0060 ${DFILP}
#                                                         EST_FVENTNPANT ESID7000 ${DFILP}
#                                                         EST_IRDVPERICASE ESID0560 ${DFILP}
#                       (1)  JOB=ESID3800           EST_FTRSLNK   ESCJ0060 ${DFILI}
#                                                         EST_FTVENTNP ESID0060 ${DFILP}
#                                                         EST_IRDVPERICASE ESID0560 ${DFILP}
#                            Case of a file type {CHAINE}_MNEMO.dat : Ajout definition FVENTNPANT
#                       (2) JOB=ESID7000            EST_FVENTNPANT ESID7000 ${DFILP}
#                                                         EST_FTVENTNP ESID0060 ${DFILP}
#                       (2) JOB=ESID7500            EST_FVENTNPANT ESID7000 ${DFILP}
#                                                         EST_FTVENTNP ESID0060 ${DFILP}
#
#    26/08/2004 J. Ribot ajout fichier  LIFTHR ESCJ0060 ESID2030
#                                       LIFMOD LIFMOD2 LIFPEN ESID2030 ESID8030
#    22/11/2004 J. Ribot ajout fichier  DLTOTITGTAR ESID2060 et ESID2560
#    17/01/2005 J. Ribot ajout chain    ESID8060 et fichier FCTRGROHIST
#    21/01/2005 J. Ribot modif nom fichier LIFTRANSFR ET DLRLIFEP et cree en DFILP pour ESID1530
#    21/01/2005 J. Ribot modif nom fichier LIFMOD LIFMOD2 LIFPEN  traité par ESID1530 uniquement
#    07/02/2005 M.DJELLOULI - Integration Fichier EST_FTRSLNK7
#                                         Modification Nom du Fichier EST_FVENTNPANT
#    01/04/2005 J.Ribot  ajout STAD1500
#    18/05/2005 M.DJELLOULI - Integration Fichier EST_FTFAMCHG (FTFAMCHG)
#    26/05/2005 J.Ribot  ajout fichier LIFSTAREP_PLAN dans STAD1500
#    07/11/2005 J. Ribot ajout save fichier FPLATXCUM.dat par ESPT0000
#    17/03/2006 M.DJELLOULI - Integration Fichier EST_FCURCVSN (FCURCVSN) pour Daemon
#    20/02/2006 M.DJELLOULI - SPOT 12055 - V6.01 - Intégration Fichier EST_FTVENTNPHIS
#    04/05/2006 J.Ribot  ajout fichier FPLACEMT1 FVPLACEMT1 dans ESEH1100 ESID2030 ESID1530 (SPOT11167)
#    02/11/2006 J. Ribot ajout save fichier CRVPERICASE0.dat par ESPT0000
#                        ajout fichiers CRVPERICASE0    et GTRANO dans les traitements post_omega   # SPOT13321  JR 02/11/2006
#    05/03/2007 J. Ribot ajout fichier STA_LIFSTAREP_CBP_RETRO (STAD1500)
#    23/03/2007 J. Ribot ajout fichier EST_IADVPERICASE  (ESID2060) SPOT 13142
#-----------------
#   09/05/2008   D.GATIBELZA    MODIF: [024]
#                               ESTDOM15390 Specifications for the Omega to Visma interface
#                               ajout fichier EST_GTASW et EST_GTRSW
#    15/01/2009 J. Ribot ajout fichier EST_IFRSGTA EST_FTRSLNK (ESID2060) SPOT 16593
#    15/01/2009 J. Ribot ajout fichier EPO_IADVPERICASE EPO_FTRSLNK (ESPD1800) SPOT 16593
#    15/01/2009 J. Ribot ajout fichier EPO_IADVPERICASE             (ESPT0000) SPOT 16593
#    16/09/2009 JF.VDV SPOT17921 mettre le fichier IFRSGTA dans $DFILT et non plus sur $DFILP
#    19/10/2009 P. Le Gal Fiche SPOT n° 16778 Calcul des estimations de primes des traités non proportionnels liés à la saisonnalité
#    08/12/2009 P. Coppin :spot:18571 Ajout definition des fichiers EST_FTECLEDA et EST_FTECLEDR pour le DWUD9130.cmd
#    18/01/2010 P. Coppin :spot:18774 Ajout definition des fichiers EST_FTECLEDA et EST_FTECLEDR pour le DWUD0130.cmd
#    01/03/2010 P. Coppin :spot:19033 Ajout definition des fichiers EPO_FTECLEDASO et EPO_FTECLEDRSO pour les DWUD0130.cmd et DWUD9130.cmd
#_________________
#MODIFICATION    [032]
#Auteur:         D.GATIBELZA
#Date:           28/04/2010
#Version:        10.1
#Description:    ESTVIE18710 Alimentation du MGTAR lors de la comptabilisation de l'arrêté pour la réallocation asie
#_________________
#    17/06/2010 R. Cassis :spot:19204 Optimisation ESEH1100 et ESID0060 par parallélisation et découpage en x chaines
#                                     Ajout chaines ESID0070 ESEH1110
#_________________
#MODIFICATION    [034]
#Auteur:         T.RIPERT
#Date:           29/07/2010
#Version:        10.1
#Description:    19177 Alimentation du DAC : ajout EST_FFAMCNA dans la chaine ESID0060
#_________________
#MODIFICATION    [035]
#Auteur:         T.RIPERT
#Date:           29/07/2010
#Version:        10.1
#Description:    18235 SPOT 18235 Ajout definition EST_FLIFEST1 dans la chaine ESID0060
#_________________
#MODIFICATION    [036]
#Auteur:         D.GATIBELZA
#Date:           03/09/2010
#Version:        10.1
#Description:    ESTVIE19177 V10 Mettre en place un calcul spécial de DAC pour Koln automatic DAC calculation taking into account the fanancing commission, the technical result, the interest on deposit
#_________________
#MODIFICATION    [037]
#Auteur:         D.GATIBELZA
#Date:           09/09/2010
#Version:        10.1
#Description:    ESTDOM19070 V10 scheduler pour le lancement des inventaires
#_________________
#MODIFICATION    [038] [039]
#Auteur:         T.RIPERT
#Date:           16/11/2010
#Version:        10.1
#Description:    SPOT18235 V10 Sum at Risk dans SRV
#_________________
#MODIFICATION    [040]
#Auteur:         D.GATIBELZA
#Date:           17/01/2011
#Version:        10.2
#Description:    ESTDOM21224 Périmètre de l'interface pour Madrid ; ne pas filtrer par statut du contrat
#---------------
#MODIFICATION    [041]
#Auteur          D.GATIBELZA
#Date            09/02/2011
#Version         11.1
#Description     1GL
#---------------
#[042]  09/03/2011  R. Cassis       :spot:21408 Ajout chaine ESID7050 - ajout FTECLEDA dans ESID7000, CURGTACTL
#                                               Suppression EST_IGTAA car plus utilisé
#                                               FTECLEDA_MVT = Mouvements non comptabilises <= mois en cours de comptabilisation
#---------------
#MODIFICATION    [043]
#Auteur          D.Chetboul
#Date            02.08.2011
#Version         11.1
#Description     1GL
#SPOT            22422  : Correction de l'initialisation de la variable exportée EST_SORT_CONDITION utilisée par les autres prog.
#---------------
#---------------
#[044] -=Dch=-   19/08/2011 Version 11.1   :spot:22435 1GL remplacement de la variable DFILI en DFILP afin de conserver les fichiers après traitements, pour ESPD, DWUD9130, DWUD0130, DWPD0010
#[045] -=Dch=-   22/09/2011 Version 11.1   :spot:22655 Declaration de la variable EPO_FPLACEMT2
#[046] Florent   15/11/2011 :spot:22890    ajout de export EST_MVTPNAC pour le ESID2000
#[047] R. Cassis 02/12/2011 :spot:23000   Correction syntaxe du commentaire
#[048] JF VDV    09/12/2011 :spot:22569   Ajout export BILANPREC et CBP_RETRO  pour le job STPD1500
#[049] R. Cassis 09/03/2012 :spot:23541   Ajout du IGTR00 et STATGTR dans ESIJ7000 et ESID2030
#[050] 31/01/2012 R. Cassis :spot:23802   Ajout fichiers pour Solvency
#[051] 01/08/2012 L. Rakotozafy :spot:idem 24122   mise en commentaire
#[052] 14/08/2012 R. Cassis :spot:24122   Maj solvency II sur nom FCTRSTAT
#[053] 30/08/2012 R. Cassis :spot:24041   Maj solvency II
#[054] 25/10/2012 JF VDV    :[24041] - Modifications pour Solvency
#[055] 21/01/2013 R. Cassis :spot:24698 - gestion FSEGSTAT et FCTRSTAT
#[056] 30/01/2013 R. Cassis :spot:24775 - gestion Post-omega Solvency 2
#[057] 19/03/2013 R. Cassis :spot:24979 - gestion Post-omega Solvency 2
#[058] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
#[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
#[101] 28/03/2014 R. Cassis   :spot:25427  - Modifications pour omega2 -1b Ajout fonction EST_PATH_NAMEP2 pour cas ou fichier different de NCHAIN
#                                            suppression commentaire sans caractere "diese"
#[102] 28/04/2014 PPEZOUT :spot:26653 Echanges internes Solvency 
#[103] 28/04/2014 ABJ :spot:26653 Ajout du FACCPAR0 au ESID2040 et ESID1530 
#[104] 12/09/2014 R. Cassis :spot:25773 Add echo of EST_SORT_CONDITION to Log result
#[105] 22/09/2014 R. Cassis :spot:25773 Up to date with 1B
#[106] 18/12/2014 P. Coppin :spot:28117  - Add DWPD0020.cmd.
#[107] 06/02/2015 S.Behague :spot 28122 - EST48
#[108] 26/02/2015 P. Menant :spot 28306 - EST37 update STAD1540 block
#[109] 31/03/2015 S.Behague :spot 28585 - Ajout CPLIFDRIN
#[110] 13/04/2015 S.Behague :spot 28618 - Ajout VLIFEST195 dans le STAD1500
#[111] 13/04/2015 S.Behague :spot 28306 - EST37 - Ajout FLIFPLN3
#[112] 25/03/2015 R. Cassis :spot:28483 Generation of Estimates and retro account files to chain ESID0110 instead of ESID0060 for Vtom optimisation
#[113] 27/04/2015 R. cassis :spot 28660 - Ajout chaine ESID8050
#[114]  ???????????
#[115] 07/05/2015 JULIEN FONTANA spot28559: Ajout EST24BT
#[116] 09/02/2015 FMA :spot:28140 Pour la troisieme fois : Ajout export EST_FTHRHLDUWY fichier de parametrage FTHRHLDUWY
#[117] 12/06/2015 D. FILLINGER spot:28742 EST41 Automatic Calculation ajout EST_TACCPAR pour ESTC2045.c
#[118] 10/06/2015 SAS spot 28694: prise en compte des procs FVCTRGRO et FVSEGEST pour la segmentation, et Ajout FACCPAR de BREF dans 2030
#[119] 30/06/2015 DFI  SPOT:28947  filtre des analytiques dans la generation de l'interface 1GL
#[120] 25/06/2015 ABJ :spot:28974 Ajout des fichiers de parametrages au STPD
#[120] 22/06/2015 R. Cassis    spot:28941 EST49a2 Ajout fichiers Risk Margin et ULAE
#[121] 31/08/2015 DFI  spot:29273 Ajouts fichiers pour EST26 38 et 52 (Intra Day)
#[122] 15/09/2015 DFI  spot:29060 Ajout fichier manquant pour traitement post omega
#[123] 15/09/2015 R. Cassis  spot:29060 Ajout fichier manquant pour traitement post omega
#[124] 08/10/2015 R. Cassis  :spot:28140 Correction des affectations du fichier FTHRHLDUWY
#[125] 09/10/2015 R. Cassis  :spot:29162 Ajout fichier FTRANSCODE et FCTRNAT et autres
#[126] 16/10/2015 DFI        :spot:29514 Ajout fichier FLIFEST0 dans STAD7500
#[127] 26/10/2015 R. Cassis  :spot:29569 :spot:29572 gestion fichier FTHRHLDUWY
#[128] 02/11/2015 DFI        :spot:29273 utilisation du fichier ESIX7000_ARCSTATGTA par l'intraday
#[129] 03/11/2015 GBO        :spot:29273 correction TCALL et FLIFEST0 
#[126] 10/11/2015 R.BEN EZZINE :spot:29579 Ajout FTRANSCODEVRET et FTRSLNKVRET
#[127] 19/11/2015 N.ESSE     :spot:29579 Ajout FTRANSCODE FTRANSCODEVRET et FTRSLNKVRET dans ESDJ1010 suite plantage intraday
#[130] 23/11/2015 R. Cassis  :spot:29162 Ajout IADVPERICASE et FTRSLNK dans x chaines
#[131] 24/11/2015 Florent    :spot:29176 Comptabilité Rétro des PNA
#[132] 02/12/2015 Mariem - Roger :spot:29665 Ajout fichier LIFENDCPT
#[133] 01/12/2015 DFI        :spot:29273 Report fichier LIFENDCPT ajouté par pool retro dans le ESDJ7000
#[134] 02/11/2015 P PEZOUT  :spot:29615 EST45 gestion des doubles bouclettes RETRO
#[135] 16/12/2015 GBO        : spot 29095 Correction pour ajout du Subtrs au programme
#[136] 18/12/2015 R. Cassis  :spot:29903 Ajout chaine ESID8100 pour extractions NETEZZA projet RA
#[137] 11/02/2016 Mariem/Sébastien :spot:30176: New Business
#[138] 04/02/2016 -=Dch=-  :spot:29162 Impact Retro P&C
#[139] 10/03/2016 R. Cassis  :spot:29066 Ajout FTRANSCODE sur ESID2550
#[140] 21/03/2016 DFI      :spot:30195 Time shifted ajout IARVPERICASE4 dans ESID2040
#[141] 14/04/2016 -=Dch=-  :spot 30465 - Ajout chaine pour le  ESID8050
#[142] 26/05/2016 S.Behague :spot 30583: Spira 41148
#[143] 03/06/2016   MBO     spot30961:43333:quarterlization
#[144] 10/06/2016 R. Cassis  :spot:29629 Ajout fichiers EST_VENTNP_TRIMPREV et EST_VENTNP_TRIMCUR
#[145] 02/06/2016  SAS      :spot:30684 Dépots en doublon suite à reprise
#[146] 29/06/2016   MBO     :spot:30961:51645:quarterlization
#[147] 27/07/2016 R. Cassis :spot:30985 Affectation des fichiers a destination de RA
#[148] 16/08/2016 DFI       :spot:30939: spira 52445 differentiation des sorties ESID2040 PA et PC
#[149] 18/08/2016   MBO     :spot:30898:emploie du bon IARVPERICASE4
#[150] 18/08/2016   MBO     :spot:30898:correction ESDJ1010 fichier EST_FCTRNAT
#[151] 24/08/2016   MMA     :SPOT 31107: Affectation du fichier FCURQUOT pour l'ESDJ
#[152] 25/08/2016 DFI       :spot:30939: spira 52445 differentiation des sorties ESID2040 PA et PC (ajout CMPCALC)
#[153] 07/09/2016 MMA       :SPOT:31105: Spiras : 54809             : lié à la Spot 30898 : Génération du FACCPAR0 dans l'intraday
#[154] 07/09/2016 MMA       :SPOT:31105: Spiras : 53733 et 53727    : lié à la SPOT:31161 : Vérification des Postes analytique afin de les écarter
#[155] 30/09/2016 MMA       :SPOT:31105: NO Spira                   : Nettoyage des anciens PC/PA (avant [148])
#[156] 06/10/2016 R. Cassis :SPOT:31302: Ajout fichiers GTSII_RISKMARGINCO et GTSII_RISKMARGINSO
#[157] 18/10/2016 MMA       :SPOT:31378: Ajout des fichiers temporaire pour l'optimisation de l'EST41 dans l'ESID2030
#[158] 21/09/2016 R. Cassis :spot:31263  Ajout gestion CONSO EBS-IFRS ouvertures, autres - les fichiers du ESPD2900 sont sur DFILP pas DFILI
#[159] 14/12/2016 PGA       SPIRA: 50815-47759-47946 ajout DTSTATGTAA coté ESPD
#[160] 12/01/2017 Florent   :spira:48151- EBS - UPR cancel - correction pour le mix of internal and external retrocessionaire
#[161] 04/04/2017 R. Cassis :spira:60188 Gestion de la FULTIMATES pour EBS
#[162] 04/04/2017 R. Cassis :spira:60217 Ajout fichiers EST_DLRGTAA, EST_IAVPERICASE0 dans ESID8120 pour retirer les echanges internes en trop vers RA
#[163] 30/06/2017 S. Behague:spira:52504 Ajout fichier STAD1540
#[164] 03/08/2017 R. Cassis :spira:63164 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega.
#[165] 12/07/2017 R. Cassis :spira:61508 Ajout fichiers pour les chaines de gestion des ecritures locales ESL..
#[166] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nommés ESL_ sont maintenant générés dans le ESID7000
#[167] 08/02/2018 S.ROCH    :spira:64246  Ajout TSUBTRS sur ESID4000
#[168] 15/03/2018 HH Huynh  :spira:62073  Prise en compte des limites définies par les champs (BLCSHTSTR_D et BLCSHTEND_D) dans TCESSIONS pour grille Retro estimate
#[169] 04/04/2018 MZM       :spira:65651  Allocation NP EBS Ajout des fichiers EPO_VENTNPSIICO, EPO_VENTNPSIISO et EPO_FTRSLNK7, EPO_FTVENTNP
#[170] 03/05/2018 Y.Elout.  :spira:63970 Ajout de FCTREST0 pour ESID2000
#[171] 31/10/2018 C.Socie   :spira:67647 IFRS 17 REQ 10.3 Cash flow: Flexibility on patterns to be apply on grouping 3
#[172] 29/01/2019 S.Behague/R.Vieville :spira: Evolution quarterly
#[173] 06/02/2019 C.Socie   IFRS17 REQ 10.9 & 10.10 ajout FSEGPATTERNFWH et FCTRFWH
#[174] 29/01/2019 S.Behague/R.Vieville :REQ.L.02.05: Evolution quarterly
#[175] 01/03/2019 MZM       :spira:71670  FUTURE RETRO FOR NP CONTRACTS EBS Ajout des fichiers EPO_DLDGTR_E, FUTURE_RETRO_EBS, DLDGTR_CUMULS_PREC
#[176] 14/03/2019 JYP       :spira:69814 IFRS17 req 11.1 : add ESF_EXPENSES
#[177] 18/03/2019 JYP       :spira:073098: add EST_FCTRESTA for IBNR
#[178] 22/03/2019 JYP       :spira:073098: bugfix EST_FCLIENT_TXT 
#[179] 11/03/2019 R. Cassis :spira:76697 Les fichiers FDETTRS et FTRSLNK sont copies quotidiennement pour le Local dans ESCJ0060
#[180] 01/04/2019 JYP       :spira 073098: move EST_FCTRESTA in DFILI
#[181] 15/04/2019 JYP       :spira:69814 IFRS17 req 11.1: bugfix ESF_EXPENSES
#[182] 11/04/2019 R. cassis :spira:65656 Mise à jour de nommages des fichiers de type FCTREST et autres maj
#[183] 16/04/2019 MZM       :spira:70671: Prise en compte des fichiers FPLACEMENT22
#[184] 17/04/2019 RAF       :spira:70045: ajout quarterly dans le ESID8030
#[185] 26/04/2019 S.Behague/:spira:70045 Evolution quarterly
#[186] 24/05/2019 M.NAJI    : refonte ESCD9001_IFRS4.cmd, les mappings de fichiers sont stocké dans dans une table
#======================================================================================================================
#set -x

if [ "${JOB_NOECHO}" != "YES" ]
then
    echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
    echo '# Begin of initialization job    : ' ${NJOB} " Date : " `date +"%Y/%m/%d %H:%M:%S"`  2>&1 | ${TEE}
    echo "# Main Working Directories :"   2>&1 | ${TEE}
    echo "#   DLOG : " ${DLOG}  2>&1 | ${TEE}
    echo "#   DUTI : " ${DUTI}  2>&1 | ${TEE}
    echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
fi

#Parameters
#SSDs=$2


#0[37]
tempsRETANT=-1


#[037]
function RecupereTempsRESTANT
{
    echo "RecupereTempsRESTANT : debut"

    if test -f $DFILP/EST_ESCD9001_TEMPS_BATCH.dat
    then
        SHORT_NCHAIN=`echo ${NCHAIN} | cut -d_ -f2-`
        if [ "${tps}" != "" ]
        then
            tempsRETANT=$tps
        fi
    else
        echo "-------------------------------------------------------"
        echo "- EST_ESCD9001_TEMPS_BATCH.dat non present dans DFILP -"
        echo "-------------------------------------------------------"
    fi

  echo "RecupereTempsRESTANT : ok"
  return 0
}


#------------------------------------------------------------------------------
# Preparation of screen condition on the subsidaries for the SORT
# with SSDs( = _F1_F2_F3_...)
#------------------------------------------------------------------------------
export EST_SORT_CONDITION=`echo ${SSDs} | awk 'BEGIN{FS="_";first="Y"}\
        {  printf("(");\
           for(i=1;i<=NF;i++)\
                if($i != "")\
                {       if(first=="N") printf(" OR ") ;\
                        printf(" SSD_CF=%s",$i);\
                        first="N"\
                } \
           printf(")");\
        }'`


#==-    [043]   D.Ch 02.08.2011 ==-

if [ "$EST_SORT_CONDITION" = "()" ]
then
    export EST_SORT_CONDITION="(1=1)"
fi

#[104]
echo "#"     >> ${FLOG}
echo "EST_SORT_CONDITION: ${EST_SORT_CONDITION}"     >> ${FLOG}
echo "#"     >> ${FLOG}



#---------------------------------------------------------------------------
# FUNCTION: EST_FCT_GONOGO
#
# 1 input parameter
#
# - Chain name file
#
# Subject: Elle permet de lancer lancer ou non la chaine ( parametre de la
#          fonction) en fonction d'un d'un plan genere par la chaine
#          ESCJ0000.cmd.
#          si la variable EST_${NCHAIN}_GONOGO n'est pas positinnee a "Y",
#          la chaine n'est pas lancee
#
#--------------------------------------------------------------------------
EST_FCT_GONOGO()
{
    CHAIN_NAME=`echo $1 | awk '{print substr($0,length($0)-7)}'`

    export GONOGO_VAR=`eval echo '$'EST_${CHAIN_NAME}_GONOGO`

    if [ "${GONOGO_VAR}" != "Y" ]
    then
        if [ "${JOB_NOECHO}" != "YES" ]
        then
            echo '#------------------------------------------'  2>&1 | ${TEE}
            echo "# ${CHAIN_NAME}: NO GO "  2>&1 | ${TEE}
            echo '#------------------------------------------'  2>&1 | ${TEE}
        fi

        return 1
    fi
}


# executed except with asynchrone jobs
#-------------------------------------------------------------------------
if [ "${LAUNCHER}" != "DAEMON" ]
then
    # Launch plannig
    #-----------------------------------------------------------------
    . ${DFILP}/${ENV_PREFIX}_ESCJ0000_PLAN_EPO.dat	
    . ${EST_PLAN}

    #ret de la chaine si elle ne figure pas dans le plan d'execution
    #-----------------------------------------------------------------
    EST_FCT_GONOGO ${NCHAIN}

    if [ $? != 0 ]
    then
        echo "chain end "
        CHAINEND
    fi
fi



if [ "${JOB_NOECHO}" != "YES" ]
then
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   echo '# End of initialization job    : ' ${NJOB} " Date : " `date +"%Y/%m/%d %H:%M:%S"`  2>&1 | ${TEE}
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
fi

function TRACE_EXPORTS {
   fexport=$1
   echo
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   echo "Trace  of export variables: $fexport "  2>&1 | ${TEE}
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   
	while  read -r line
	do
			expo=`echo $line| cut -d' ' -f1`
			f=`echo  $line| cut -d'=' -f1 | cut -d' ' -f2`
			val=`echo $line | cut -d'=' -f2-100`
			if [ "$expo" = "export" ]
			then
					printf '#---> %-30s = %s\n'  $f "$val"  2>&1 | ${TEE}
			fi
	done <"$fexport"
	
	echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   
}

function TRACE_EXPORTS_EVAL {
   fexport=$1
   echo
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   echo "Trace  of export variables: $fexport "  2>&1 | ${TEE}
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}

        while  read -r line
        do
                        expo=`echo $line| cut -d' ' -f1`
                        str=`echo $line | cut -d' ' -f2-1000`
                        f=`echo $str | cut -d'=' -f1`
                        value=`echo $str | cut -d'=' -f2-1000`
                        if [ "$expo" = "export" ]
                        then
                                        val=` eval echo  $value`
                                        printf '#---> %-30s = %s\n'  $f $val  2>&1 | ${TEE}
                        fi
        done <"$fexport"

        echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}

}

. ${DFILP}/${PCH}ESFJ0000_PARM.dat
TRACE_EXPORTS  ${DFILP}/${PCH}ESFJ0000_PARM.dat

#export SSDs0=$PARM_SSDCLO_LL  
#export SSDs=$PARM_ISSDCLO_LL 
#export CRE_D=$PARM0_CRE_D
#export DBCLO=$PARM_DBCLO_D
#export CLODAT=$PARM_CLODAT_D
#export ICLODAT=$PARM_ICLODAT_D
#export ICLODAT2=$PARM_ICLODAT_D
#export BALSHTMTH=$PARM_BLCSHTMTH_NF
#export BALSHTYEA=$PARM_BLCSHTYEA_NF

SSDs0=$1
SSDs=$2
BALSHTYEA=$3
BALSHTMTH=$4
CRE_D=$5
DBCLO=$6
CLODAT=$7
ICLODAT=$8

export ICLODAT2=$8

#------------------------------------------------------------------------------
# Preparation of screen condition on the subsidaries for the SORT
# with SSDs( = _F1_F2_F3_...)
#------------------------------------------------------------------------------
export EST_SORT_CONDITION=`echo ${SSDs} | awk 'BEGIN{FS="_";first="Y"}\
        {  printf("(");\
           for(i=1;i<=NF;i++)\
                if($i != "")\
                {       if(first=="N") printf(" OR ") ;\
                        printf(" SSD_CF=%s",$i);\
                        first="N"\
                } \
           printf(")");\
        }'`


#==-    [043]   D.Ch 02.08.2011 ==-

if [ "$EST_SORT_CONDITION" = "()" ]
then
    export EST_SORT_CONDITION="(1=1)"
fi

#[104]
echo "#"     >> ${FLOG}
echo "EST_SORT_CONDITION: ${EST_SORT_CONDITION}"     >> ${FLOG}
echo "#"     >> ${FLOG}

#export EST_VARIANTE=3  #TO DO
#export EST_ESID0560_COND1="N" #TO DO
export BALSHTMTH=`printf "%02d" ${BALSHTMTH}`

# Deconcatenation of closing period date
#------------------------------------------------------------------------------
export ICLODAT_YEA=`echo ${ICLODAT} | cut -c1-4`
export ICLODAT_MTH=`echo ${ICLODAT} | cut -c5-6`
export ICLODAT_DAY=`echo ${ICLODAT} | cut -c7-8`
set +x 
# Fichiers avec date bilan = date bilan mois, pas trimestre
#[036] ajout FFAMCNA
#[052] ajout FCURSII FRATINGRTO FSEGPATTERN_BDT FSEGPATTERN_CSF FSEGPATTERN_DSC [144]
#[171] ajout FPRSMAP
#[173] ajout FSEGPATTERNFWH et FCTRFWH
export FIL_ALLCLO=FACMTRSH_FBANTECL_FCTRFIC_FCURCVSNI_FCURQUOT_FDETTRS_FGRP_FINTWIT_FLIBEL1_FLIBEL2_FLIFDRI_FLSTMTH_FRETPAR_FRETTRF_FSEGPAR_FSSDACTR_FSUBSID_FTRSLNK_FURRDAC_FSOBBLOB_FSEGMENT_CPLIFDRI${IT}_CPLIFDRIN${IT}_CRIBLEANO${IT}_FVPLACEMT${IT}_SEGRATANO_SRGTC${IT}_SRGTCB1${IT}_VLIFEST195${IT}_IARVPERICASE0${IT}_IARVPERICASE4${IT}_LIFESTNOACC${IT}_LIFESTANA_CPLIFEST_FRATTACHEVOL_FUNDSTA0_FBSEGEST_FCLIENT_FBOPRSLNK_FPRSMAP_FCTRFWH_FSEGPATTERNFWH_FTVENTNP_FVENTNPANT_LIFTRANSFR${IT}_DLRLIFEP_FLIFPEN_FLIFTHR_FLIFMOD_FLIFMOD2_FTRSLNK7_FTFAMCHG_FCURCVSN_FTVENTNPHIS_SAISPERICASE_FFAMCNA_FLIFEST1_FCURSII_FRATINGRTO_FSEGPATTERN_BDT_FSEGPATTERN_CSF_FSEGPATTERN_DSC_FTRANSCODE_LIFENDCPT${IT}_VENTNP_TRIMPREV_VENTNP_TRIMCUR_FVPLACEMT2


# Closing period
#------------------------------------------------------------------------------
export CLOPRD=`printf "%04d%02d" ${BALSHTYEA} ${BALSHTMTH}`

ECHO_LOG "-----------------------CLODAT    = ${CLODAT}    ---------------------------------------------"
ECHO_LOG "-----------------------ICLODAT   = ${ICLODAT}   ---------------------------------------------"
ECHO_LOG "-----------------------CRE_D     = ${CRE_D}     ---------------------------------------------"
ECHO_LOG "-----------------------CLOPRD    = ${CLOPRD}    ---------------------------------------------"
ECHO_LOG "-----------------------BALSHTMTH = ${BALSHTMTH} ---------------------------------------------"
ECHO_LOG "-----------------------BALSHTYEA = ${BALSHTYEA}---------------------------------------------"
ECHO_LOG "-----------------------BALSHTYEA = ${BALSHTYEA}---------------------------------------------"
ECHO_LOG "-----------------------IsEpo = ${IsEpo}---------------------------------------------"

#------------------------------------------------------------------------------
# [  ] remplacement de l'ancien bloc de mapping des fichier en dur
#------------------------------------------------------------------------------

CHAIN_NAME=`echo $NCHAIN | cut -d"_" -f2- `
if [ "${IDF_CT}" != "" ]
then
   CHAIN_NAME=${CHAIN_NAME}_${IDF_CT}
fi


if [ "${CHAIN_NAME}" != "ESID2080" -o  "${MODE}" != "PA" ]
then 
	grep "${CHAIN_NAME}~"  ${DFILP}/${PCH}ESFJ0000_TI17PERMFIL.dat | awk 'BEGIN{FS="~"; } { print "export " $2"="$3 }' | sort  > $DFILT/${NCHAIN}_${IB}_PERM.dat
	. $DFILT/${NCHAIN}_${IB}_PERM.dat
	TRACE_EXPORTS_EVAL  $DFILT/${NCHAIN}_${IB}_PERM.dat
fi 

#if [[ "${CHAIN_NAME}" = ESL* ]] ; 
#then
#	if [ "${IsEpo}" = "Y" ] 
#	then
#		. ${DFILP}/${PCH}ESFJ0000_PERM_EPO.dat
#		TRACE_EXPORTS_EVAL  ${DFILP}/${PCH}ESFJ0000_PERM_EPO.dat
#	else
#		if [ "${CHAIN_NAME}" != "ESID2080" -o  "${MODE}" != "PA" ]
#		then
#			grep "${CHAIN_NAME}~"  ${DFILP}/${PCH}ESFJ0000_TI17PERMFIL.dat | awk 'BEGIN{FS="~"; } { print "export " $2"="$3 }' | sort  > $DFILT/${NCHAIN}_${IB}_PERM.dat
#			. $DFILT/${NCHAIN}_${IB}_PERM.dat
#			TRACE_EXPORTS_EVAL  $DFILT/${NCHAIN}_${IB}_PERM.dat
#		fi
#	fi
#fi

#------------------------------------------------------------------------------
# [037] Trace de la chaine en cours
#------------------------------------------------------------------------------
function EST_TRACE {

    echo "${NCHAIN}  Debut : " `date +"%Y/%m/%d %H:%M:%S"`  >> $DFILI/LOG_CHAINE_ESTIMATION.dat

    return 0
}


#------------------------------------------------------------------------------
# [037] Mise à jour de la date de fin prévue dans TREQJOBPLAN
#------------------------------------------------------------------------------
function EST_TREQJOBPLAN_END {
#set -x
echo "EST_TREQJOBPLAN_END : debut"
    if [ "${tempsRETANT}" != "-1" ]
    then
    NSTEP=${NJOB}_10
    # Begin isql
    #---------------------------------------------------------------
    LIBEL="Mise à jour du temps restant dans TREQJOB"
    ISQL_BASE="BEST"
    ISQL_QRY="
              declare @cre_d  datetime
              declare @site_cf        varchar(10)
                            declare @suser_Name     varchar(20)
                            select  @suser_Name = suser_Name()
                            Execute BEST..PsSITE_01 @suser_Name,'0',@site_cf output
              select @cre_d = '${CRE_D}'

              select @cre_d = dateadd(HH, ${tempsRETANT}, convert(datetime, convert(char(8), getdate(), 112)))

              update BEST..TREQJOBPLAN
                 set END_D=@cre_d
              where LAUNCH_D is null
                and START_D is not null
                and DBCLO_D <= '${CRE_D}'
                and SITE_CF  = @site_cf
                and REQCOD_CT in ('D', 'I', 'J', 'A', 'L' )
             "
    ISQL_O=${DFILT}/${NCHAIN}_${NSTEP}_${IB}_SQL_O1.log
    ISQL
    fi

echo "EST_TREQJOBPLAN_END : ok"
    return 0
}


EST_TRACE
EST_TREQJOBPLAN_END

