#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Save fichiers EST pour les traitements ecritures post omega
# nom du script SHELL           : ESPT0001.cmd
# revision                      :
# date de creation              : 24/06/2005
# auteur                        : J. Ribot
# references des specifications : SPOT 5085
#-----------------------------------------------------------------------------
# description
#   Save
#${EST_FDETTRS}             perm
#${EST_FRETTRF}             perm
#${EST_FCURCVSNI}           perm
#${EST_FCURQUOT}            perm
#${EST_FCURCVSN}            perm
#${EPO_IADPERICASE}         perm
#${EPO_FTRSLNK}             perm
#${EPO_FBOPRSLNK}           perm
#${EPO_FPRSMAP}             perm
#${EPO_FCTRFWH}             perm
#${EPO_FSEGPATTERNFWH}      perm
#${EPO_FCTRSTAT}            perm
#${EPO_FSEGSTAT}            perm
#${EPO_OIADVPERICASE}       perm
#${EPO_OIRDVPERICASE}       perm
#${EPO_FCTRGRO}             perm
#${EPO_FCPLACC}             perm
#${EPO_FSOBBLOB}            perm
#${EPO_FPLC}                perm
#${EPO_FPLCCOM}             perm
#${EPO_FSSDACTR}            perm
#${EPO_TTECLEDA}            perm
#${EPO_TTECLEDR}            perm
#${EPO_FPLATXCUM}           perm
#${EPO_CRVPERICASE0)        perm
#
# job launched by ESPT0000.cmd
#
#-----------------------------------------------------------------------------
# historique des modifications
#=============================================================================
#
# J. Ribot 07/11/2005  ajout save fichier FPLATXCUM
# J. Ribot 02/11/2006  ajout save fichier CRVPERICASE0 (SPOT13321)
# 15/01/2009 J. Ribot ajout fichier EPO_IADVPERICASE SPOT 16593
#[004] 22/09/2011 -=Dch=-    :spot:22655 Ajout de la variable EPO_FPLACEMT2
#[005] 05/12/2011 R. Cassis  :spot:22859 Suppression d'un delete en double sur EST_FCTRGRO
#[006] 25/01/2012 R. Cassis  :spot:aaaaa Suppression copie fichier EDIVIE -> a activer
#[007] 20/06/2012 JF VDV     :[23390] - Amenagements SOLVENCY II archivage & suppresion de fichiers sur DFILP
#[008] 06/07/2012 JF VDV     :[23390] - Amenagements SOLVENCY II Ajout de copies de fichiers EST_xxxxx en EPO_xxxxx
#[009] 12/07/2012 R. Cassis  :spot:23802 SOLVENCY - Correction commandes copy et gzip
#[010] 20/09/2012 R. Cassis  :spot:24041 SOLVENCY - Ajout sauvegardes
#[011] 19/03/2013 R. Cassis  :spot:24979 SOLVENCY - Ajout sauvegardes
#[012] 03/06/2013 R. Cassis  :spot:25249 - Gestion fichiers Solvency
#[013] 08/08/2013 R. CASSIS  :spot:25427 - Ajout jointure table tbatchssd pour Omega2
#[015] 24/10/2013 Cyrille    :spot:26391 - Ajout des fichiers Funds WithHeld 
#[016] 27/03/2014 R. CASSIS  :spot:25427 - Suppression des fichiers Funds WithHeld en attendant mise au point et renomage apres
#[017] 27/03/2014 R. CASSIS  :spot:27924 - Update gzip archivage method
#[018] 19/06/2015 R. CASSIS  :spot:26391 - Reactive les fichiers Funds WithHeld 
#[019] 09/07/2015 ABJ        :sprt:29060 - Ajout de fichier de parametrage.
#[020] 08/10/2015 R. Cassis  :spot:28140 - Ajout gestion du fichier FTHRHLDUWY
#[021] 16/10/2015 R. Cassis  :spot:29514 - correction syntaxe commande sql et date INVSERV_D
#[022] 09/10/2015 R. Cassis  :spot:29162 - Ajout gestion du fichier FTRANSCODE
#[023] 13/01/2016 R. Cassis  :spot:30029 - test allocation de fichiers avant utilisation pour Mutré ou autres
#[024] 06/06/2016 S.Behague  :spot 30583: Spira 41148
#[025] 11/08/2016 R. Cassis  :spot:30152 - DLRLGTAA renomme en DLRIGTAA
#[026] 21/09/2016 R. Cassis  :spot:31263  Modifications pour traitement du CONSO EBS
#[027] 14/12/2016 PGA        SPIRA: 50815-47759-47946 ajout DTSTATGTAA coté ESPD
#[028] 04/04/2017 R. Cassis  SPIRA:60188 - Sauvegarde de la FULTIMATES IFRS pour generation FULTIMATES EBS
#[029] 24/02/2017 R. Cassis  :spira:59429 Les fichiers CONSO IFRS et EBS ne sont plus geres ici
#[030] 03/08/2017 R. Cassis :spira:63164 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega.
#[031] 24/04/2017 MZA :spira:65651 Creation de fichier EBS pour allocation trimestrielle des NP.
#[032] 03/05/2018 Y.Eloutmani  :spira 63970 - Ajout copie du FCTREST0 (non retiré 07/12/2018) + corrections Roger 
#[031] 31/10/2018 C.Socie   :spira:67647 IFRS 17 REQ 10.3 Cash flow: Flexibility on patterns to be apply on grouping 3
#[032] 06/02/2019 C.Socie   IFRS17 REQ 10.9 & 10.10	 add FSEGPATTERNFWH & FCTRFWH
#[033] 12/04/2019 R. cassis :spira:65656 Plus de copie de FCTREST car il extrait dans ESPD0060
#[034] 13/05/2019 R. Cassis :spira:65656 Correction sur FSEGPATTERNFWH & FCTRFWH NON ils ne doivent pas etre copies, c' est de l'EBS
#[035] 15/10/2019 R. Cassis :spira:81934 Ajout copie de fichiers _TXT
#[036] 22/04/2020 R. Cassis :spira:81496 EPO_FPLCCOM inutilise en Post omega -> suppression de la copie
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INVSERV_D=$1

# Job Initialisation
JOBINIT

ECHO_LOG "--> INVSERV_D = ${INVSERV_D}"

# Cree fichier vide
RMFIL "${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat"
touch ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat

NSTEP=${NJOB}_02
#Suppression fichier EDIVIE_* traitement post omega precedent
#----------------------------------------------------------------------------
#Suppression fichier EDIVIE_* traitement post omega precedent
RMFIL "${DFILP}/${PCH}ESPT0000_EDIVIE_*"

NSTEP=${NJOB}_05
#copy fichier ESTIMATION pour traitement post omega
#----------------------------------------------------------------------------
#LIBEL="copy fichier ESTIMATION pour traitement post omega"
EXECKSH_MODE=P
#EXECKSH "cp ${EES_FTECLEDSII}     ${EPO_FTECLEDSII}"                          # [008]
#EXECKSH "cp ${EST_DLDGTAA_E_TRNCODBEST} ${EPO_DLDGTAA_E_TRNCODBEST}"          # [008]
#EXECKSH "cp ${EST_EDIVIE}          ${EPO_EDIVIE}"                              # [010]
#EXECKSH "cp ${EST_FSEGPATTERN_CSF} ${EPO_FSEGPATTERN_CSF}"   # [010]
EXECKSH "cp ${EST_CPLIFDRI}        ${EPO_CPLIFDRI}"
EXECKSH "cp ${EST_CRVPERICASE0}    ${EPO_CRVPERICASE0}"
EXECKSH "cp ${EST_CTRULT02}        ${EPO_CTRULT02}"                            # [010]
EXECKSH "cp ${EST_DCGTAALOA}       ${EPO_DCGTAALOA}"                           # [008]
EXECKSH "cp ${EST_DLCGTAAEPPE}     ${EPO_DLCGTAAEPPE}"                         # [008]
EXECKSH "cp ${EST_DLCGTAAREC}      ${EPO_DLCGTAAREC}"                          # [008]
EXECKSH "cp ${EST_DLCGTAA}         ${EPO_DLCGTAA}"                             # [008]
EXECKSH "cp ${EST_DLCUMGTAAS}      ${EPO_DLCUMGTAAS}"                          # [010]
EXECKSH "cp ${EST_DLCUMGTAA}       ${EPO_DLCUMGTAA}"                           # [010]
EXECKSH "cp ${EST_FCURSII}         ${EPO_FCURSII}"                             # [011]
EXECKSH "cp ${EST_FRATINGRTO}      ${EPO_FRATINGRTO}"                          # [011]
EXECKSH "cp ${EST_FT}              ${EPO_FT_EBS}"                              # [011]
#EXECKSH "cp ${EST_FCTREST1}        ${EPO_FCTREST1_EBS}"                        # [011] [032] Non car il est créé dans le cas d'option EBS dans closing IFRS - Roger

#if [ "${EST_ESPT0000_COND1}" = "Y" ]     # option EBS                           [011]
#then
#	EXECKSH "cp ${EST_DLDGTAA_EBS}          ${EPO_DLDGTAA_EBS}"                  # [008] [011]
#	EXECKSH "cp ${EST_DLDSIIGTAA}           ${EPO_DLDSIIGTAA}"                   # [010]
#	EXECKSH "cp ${EST_DLDSIIGTAR}           ${EPO_DLDSIIGTAR}"                   # [010]
#	EXECKSH "cp ${EST_DLDSIIGTR}            ${EPO_DLDSIIGTR}"                    # [010]
#	EXECKSH "cp ${EST_FLOARAT_EBS}          ${EPO_FLOARAT_EBS}"                  # [008] [011]
#	EXECKSH "cp ${EST_FPRMLOA_EBS}          ${EPO_FPRMLOA_EBS}"                  # [008] [011]
#	EXECKSH "cp ${EST_FTECLEDSII}           ${EPO_FTECLEDSII}"                   # [010] [011]
#	EXECKSH "cp ${EST_FT_EBS}               ${EPO_FT_EBS}"                       # [010]
#	EXECKSH "cp ${EST_DLDGTAA_E_TRNCODEBS}  ${EPO_DLDGTAA_E_TRNCODEBS}"          # [008]  [011]
#fi
EXECKSH "cp ${EST_DLDGTAA_IFRS}    ${EPO_DLDGTAA_IFRS}"                        # [008]
EXECKSH "cp ${EST_DLGTAAFPRE}      ${EPO_DLGTAAFPRE}"                          # [008]
EXECKSH "cp ${EST_DLGTAAPA}        ${EPO_DLGTAAPA}"                            # [008]
EXECKSH "cp ${EST_DLGTAAPNAE}      ${EPO_DLGTAAPNAE}"                          # [008]
EXECKSH "cp ${EST_DLGTAAPRE}       ${EPO_DLGTAAPRE}"                           # [008]
EXECKSH "cp ${EST_DLGTAARPPE}      ${EPO_DLGTAARPPE}"                          # [008]
EXECKSH "cp ${EST_DLGTAATFPNAE}    ${EPO_DLGTAATFPNAE}"                        # [008]
EXECKSH "cp ${EST_FCES}            ${EPO_FCES}"
EXECKSH "cp ${EST_FCPLACC}         ${EPO_FCPLACC}"
#EXECKSH "cp ${EST_FCTREST}         ${EPO_FCTREST}"                             # [008] [033]
#EXECKSH "cp ${EST_FCTREST0}        ${EPO_FCTREST0}"                            # [032]  Non car il est créé dans le le POS EBS (ESPD0060) Roger
EXECKSH "cp ${EST_FCTRGRO1}        ${EPO_FCTRGRO1}"                            # [008]
EXECKSH "cp ${EST_FCTRGRO}         ${EPO_FCTRGRO}"
EXECKSH "cp ${EST_FCTRSTAT}        ${EPO_FCTRSTAT}"
EXECKSH "cp ${EST_FCTRULT}         ${EPO_FCTRULT}"                             # [008]
EXECKSH "cp ${EST_FCURCVSNI}       ${EPO_FCURCVSNI}"
EXECKSH "cp ${EST_FCURCVSN}        ${EPO_FCURCVSN}"
EXECKSH "cp ${EST_FCURQUOT}        ${EPO_FCURQUOT}"
EXECKSH "cp ${EST_FDETTRS}         ${EPO_FDETTRS}"
#EXECKSH "cp ${EST_FLOARAT}         ${EPO_FLOARAT}"                             # [010]
EXECKSH "cp ${EST_FPLACEMT0}       ${EPO_FPLACEMT0}"   # [004] SPOT 22655 -=Dch=-  22/09/2011 [005]
EXECKSH "cp ${EST_FPLACEMT2}       ${EPO_FPLACEMT2}"   # [004] SPOT 22655 -=Dch=-  22/09/2011 [005]
EXECKSH "cp ${EST_FPLATXCUM}       ${EPO_FPLATXCUM}"
#EXECKSH "cp ${EST_FPLCCOM}         ${EPO_FPLCCOM}"   #[036]
EXECKSH "cp ${EST_FPLC}            ${EPO_FPLC}"
#EXECKSH "cp ${EST_FPRMLOA}         ${EPO_FPRMLOA}"                             # [010]
EXECKSH "cp ${EST_FRETTRF}         ${EPO_FRETTRF}"
#EXECKSH "cp ${EST_FSEGEST}         ${EPO_FSEGEST}"                             # [010]
EXECKSH "cp ${EST_FSOBBLOB}        ${EPO_FSOBBLOB}"
EXECKSH "cp ${EST_FSSDACTR}        ${EPO_FSSDACTR}"
EXECKSH "cp ${EST_FTECLEDA}        ${EPO_FTECLEDA}"
EXECKSH "cp ${EST_FTECLEDR}        ${EPO_FTECLEDR}"
EXECKSH "cp ${EST_FTFAC}           ${EPO_FTFAC}"                               # [008]
EXECKSH "cp ${EST_FTFAMCHG}        ${EPO_FTFAMCHG}"                            # [008]
EXECKSH "cp ${EST_FTRSLNK}         ${EPO_FTRSLNK}"
EXECKSH "cp ${EST_FBOPRSLNK}       ${EPO_FBOPRSLNK}"                           #[024]
EXECKSH "cp ${EST_FPRSMAP}         ${EPO_FPRSMAP}" 							   #[031]
#EXECKSH "cp ${EST_FCTRFWH}         ${EPO_FCTRFWH}" 							   #[032] [034] NON NON NON
#EXECKSH "cp ${EST_FSEGPATTERNFWH}  ${EPO_FSEGPATTERNFWH}" 					   #[032] [034] NON NON NON
EXECKSH "cp ${EST_FTTR_PRM}        ${EPO_FTTR_PRM}"                            # [010]
#EXECKSH "cp ${EST_FT}              ${EPO_FT}"                                  # [010]
EXECKSH "cp ${EST_FVPLACEMT}       ${EPO_FVPLACEMT}"
EXECKSH "cp ${EST_IADPERICASE}     ${EPO_IADPERICASE}"
EXECKSH "cp ${EST_IADPERIFCI}      ${EPO_IADPERIFCI}"                          # [010]
EXECKSH "cp ${EST_IADPERIFCT}      ${EPO_IADPERIFCT}"                          # [010]
EXECKSH "cp ${EST_IADPERIFR}       ${EPO_IADPERIFR}"                           # [010]
EXECKSH "cp ${EST_IADVPERICASE}    ${EPO_IADVPERICASE}"        # SPOT16593  JR 25/02/2009
EXECKSH "cp ${EST_IARVPERICASE0}   ${EPO_IARVPERICASE0}"
EXECKSH "cp ${EST_LABOCY1}         ${EPO_LABOCY1}"                             # [008]
#EXECKSH "cp ${EST_MVTPNA0}         ${EPO_MVTPNA0}"                             # [010]
EXECKSH "cp ${EST_OIADVPERICASE}   ${EPO_OIADVPERICASE}"
EXECKSH "cp ${EST_OIRDVPERICASE}   ${EPO_OIRDVPERICASE}"
EXECKSH "cp ${STA_LIFSTAREP_AS}    ${EPO_LIFSTAREP_AS}"
EXECKSH "cp ${STA_LIFSTAREP}       ${EPO_LIFSTAREP}"

EXECKSH "cp ${EST_FVENTNPANT}       ${EPO_FVENTNPANT}"												#[031]
EXECKSH "cp ${EST_FTVENTNP}       ${EPO_FTVENTNP}"														#[031]
EXECKSH "cp ${EST_IRDVPERICASE}   ${EPO_IRDVPERICASE}"												#[031]
EXECKSH "cp ${EST_FLIBEL2}   ${EPO_FLIBEL2}"												          #[031]
EXECKSH "cp ${EST_FLIBEL1}   ${EPO_FLIBEL1}"												          #[031]


# Funds WithHeld GT [016] [018]
EXECKSH "cp ${EST_FWHGTA}        ${EPO_FWHGTA}"                              # [015]
EXECKSH "cp ${EST_FWHGTR}        ${EPO_FWHGTR}"                              # [015]

EXECKSH "cp ${EST_SUBTRS}              ${EPO_SUBTRS}"                              # [019]
EXECKSH "cp ${EST_SUBTRSESBPROP}       ${EPO_SUBTRSESBPROP}" 
EXECKSH "cp ${EST_SUBTRSBLOCKLIFEST}   ${EPO_SUBTRSBLOCKLIFEST}"
EXECKSH "cp ${EST_SUBTRSASSO}          ${EPO_SUBTRSASSO}"
EXECKSH "cp ${EST_SUBTRSBASE}          ${EPO_SUBTRSBASE}"
EXECKSH "cp ${EST_FCLIENT}             ${EPO_FCLIENT}"
EXECKSH "cp ${EST_FTHRHLDUWY}          ${EPO_FTHRHLDUWY}"                 #[020]
EXECKSH "cp ${EST_DTSTATGTAA}          ${EPO_DTSTATGTAA}"                 #[027]
#[023]
if [ "${EST_FTRANSCODE}" != "" -a "${EPO_FTRANSCODE}" != "" ]
then
	EXECKSH "cp ${EST_FTRANSCODE}          ${EPO_FTRANSCODE}"                 #[022]
fi

#[035]
EXECKSH "cp ${EST_FTRSLNK_TXT}        ${EPO_FTRSLNK_TXT}"             #[035]
EXECKSH "cp ${EST_FBOPRSLNK_TXT}      ${EPO_FBOPRSLNK_TXT}"           #[035]
EXECKSH "cp ${EST_FPRSMAP_TXT}        ${EPO_FPRSMAP_TXT}" 						#[035]
EXECKSH "cp ${EST_FCURQUOT_TXT}       ${EPO_FCURQUOT_TXT}" 						#[035]
EXECKSH "cp ${EST_FSSDACTR_TXT}       ${EPO_FSSDACTR_TXT}" 						#[035]
EXECKSH "cp ${EST_SUBTRS_TXT}         ${EPO_SUBTRS_TXT}" 						  #[035]
EXECKSH "cp ${EST_SUBTRSESBPROP_TXT}  ${EPO_SUBTRSESBPROP_TXT}" 			#[035]
EXECKSH "cp ${EST_FCLIENT_TXT}        ${EPO_FCLIENT_TXT}" 						#[035]
EXECKSH "cp ${EST_FDETTRS_TXT}        ${EPO_FDETTRS_TXT}" 						#[035]

#[010]
#[014]
NSTEP=${NJOB}_06 # [008]
# Begin execksh
#-----------------------------------------------------------------
LIBEL="Vide les fichiers ..SO"
# Vide les fichiers
#[023] [030]
if [ "${EPO_GTEPCO}" != "" -a "${EPO_GTEPSO}" != "" -a "${EPO_GTEPSIICO}" != "" -a "${EPO_GTEPSIISO}" != "" ]
then
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_GTEPCO}"
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_GTEPSO}"
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_GTEPSIICO}"
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_GTEPSIISO}"
fi
#[016]
if [ "${EPO_DLEIGTAA}" != "" ]
then
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_DLEIGTAA}"
fi
if [ "${EPO_DLRIGTAA}" != "" ]
then
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_DLRIGTAA}"
fi
if [ "${EPO_DLRGTAA}" != "" ]
then
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_DLRGTAA}"
fi

#[028]
if [ "${EST_FULTIMATES}" != "" ]
then
	EXECKSH "cp ${EST_FULTIMATES} ${EPO_FULTIMATES}"
fi

EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_CMGTAASO}"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_CMGTARSO}"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_CMGTRSO}"

EXECKSH "cp ${EST_IRDPERICASE0}   ${EPO_IRDPERICASE0}"
EXECKSH "cp ${EST_FPLATXCUMALL}   ${EPO_FPLATXCUMALL}"
#EXECKSH "cp ${EST_FCESSION}       ${EPO_FCESSION}"

#[013]
NSTEP=${NJOB}_10
#Generation of CADVPERIESB0 File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of CADVPERIESB0 Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="$DFILT/${NSTEP}_${IB}_CADVPERIESB0_O.dat"
BCP_QRY="select ctr_nf, end_nt,  uwy_nf, uw_nt, accesb_cf from bfac..tcontr a, BREF..TBATCHSSD b
         where ctrsts_ct in ( 14, 16, 17, 19)
         and   a.SSD_CF=b.SSD_CF
         and   b.BATCHUSER_CF = suser_name()
         select ctr_nf, end_nt,  uwy_nf, uw_nt, accesb_cf from btrt..tcontr a, BREF..TBATCHSSD b
         where ctrsts_ct in ( 14, 16, 17, 19)
         and   a.SSD_CF=b.SSD_CF
         and   b.BATCHUSER_CF = suser_name()"
BCP

NSTEP=${NJOB}_15
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of CADVPERIESB0 -> EST_CADVPERIESB0 perimeter file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_CADVPERIESB0_O.dat"
SORT_O="${EPO_CADVPERIESB0}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF 1:1 - 1:,
 END_NT 2:1 - 2:,
 UWY_NF 3:1 - 3:,
 UW_NT  4:1 - 4:
/KEYS CTR_NF,
 END_NT,
 UWY_NF,
 UW_NT
exit
EOF
SORT

#[012]

gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat    > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDACO_${INVSERV_D}.dat.gz
gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO.dat    > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO_${INVSERV_D}.dat.gz
gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat    > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_${INVSERV_D}.dat.gz
gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat    > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO_${INVSERV_D}.dat.gz
gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO_${INVSERV_D}.dat.gz
gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO_${INVSERV_D}.dat.gz
gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO_${INVSERV_D}.dat.gz
gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_${INVSERV_D}.dat.gz

NSTEP=${NJOB}_20
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Empty files"
EXECKSH_MODE=P
# Vide les fichiers
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRCO.dat"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIICO.dat"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIICO.dat"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO.dat"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat"

NSTEP=${NJOB}_25
#-----------------------------------------------------------------
LIBEL="delete of files CADVPERIESB0"
RMFIL "${DFILT}/${NJOB}_10_${IB}_CADVPERIESB0_O.dat"
RMFIL "${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat"

JOBEND

