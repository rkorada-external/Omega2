#!/bin/ksh
#=============================================================================
# nom de l'application	: ESTIMATIONS - INVENTAIRE
#                       	Inventaire vie
# nom du script SHELL	: ESID2030.cmd => ESID3021_testori.cmd
# revision				: $Revision:   1.8  $
# date de creation		: 
# auteur				: 
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Life
#   Launch applicative jobs ESCD9001 and ESID2031
#-----------------------------------------------------------------------------
# historique des modifications
# [001] 14/10/2014 JBG :spot:25773 Ajout du mois bilan pour le ESID3028
# [002] 23/03/2015 J.FONTANA : Spot#28559 -> EST24BT
# [003] 13/08/2015 D.FILLINGER : SPOT # 29221 -> EST41
# [004] 07/03/2016 R.BEN EZZINE :spot:29579 ajout ${CLODAT_D} a l'entree du ESID3027
# [005] 03/06/2016 S.Behague :spot:30300 EST39 
# [006] 14/06/2016 S.ASKRI   spot:30741 traite automatiques
# [007] 22/02/2017 DFI spira 59440 desactivation des calculs automatiques et segmentes
# [008] 12/02/2019 S.Behague    :REQ.L.02.05: Evolution quarterly
# [010] 30/09/2021 B.Lagha   93277:Ajout des anciennes lignes LIFEST dans CPLIFEST pour le calcul de la fichie mouvement
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

IDF_CT=$2
export IT=`echo $2 | awk -F"_" '{ print $2 }'`

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

# Passage
PASS1=1
PASS2=2

echo "MODE LANCEMENT <$IT>"

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Files interm
export EST_CPLIFEST_INTERM=${DFILT}/`basename ${EST_CPLIFEST} | sed "s/CPLIFEST${IT}/${IB}_OLD_CPLIFEST${IT}_TEMP/"`
#. $DFILP/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat


# Launch applicative job ESID3021 -> PLACEMNT + PERICASE
#NJOB="ESID3021${IT}"
#${DCMD}/ESID3021.cmd  ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${CLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESID3023 -> VLIFEST
#NJOB="ESID3023${IT}"
#${DCMD}/ESID3023.cmd ${CLODAT_D} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID3022 -> GT
NJOB="ESID3022${IT}"
#${DCMD}/ESID3022.cmd ${BALSHTYEA_NF}  2>&1 | ${TEE}

# Launch applicative job ESFD3024 -> COMPTES COMPLETS
NJOB="ESFD3024${IT}"
${DCMD}/ESFD3024.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}


# Launch applicative job ESFD3025 -> SRGTC + SRGTCB1
NJOB="ESFD3025${IT}"
${DCMD}/ESFD3025.cmd ${BALSHTYEA_NF} 2>&1 | ${TEE}


# Launch applicative job ESFD3026 -> Calcul de DAC
NJOB="ESFD3026${IT}"
${DCMD}/ESFD3026.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${CLODAT_D} 2>&1 | ${TEE}


# Launch applicative jobs only in yearly mode
#if [ "${IT}" = "Y" ]
#then
    # Launch applicative job ESID3026A -> TRAITES AUTO
    #NJOB="ESID3026A_1${IT}"    
    #${DCMD}/ESID3026A.cmd ${BALSHTYEA_NF} ${CRE_D} ${PASS1} ${BALSHTMTH_NF} 2>&1 | ${TEE}

    ##Test existing segmentation
    #if [[ -r ${EST_FVSEGEST} && -r ${EST_FVCTRGRO} ]]
    #then
    #    #Launch applicative job ESID3026E -> SEGMENTATION
    #    NJOB="ESID3026E${IT}"
    #    ${DCMD}/ESID3026E.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}
    #fi

    # Launch applicative job ESID3026A -> TRAITES AUTO
    #NJOB="ESID3026A_2${IT}"
    #${DCMD}/ESID3026A.cmd ${BALSHTYEA_NF} ${CRE_D} ${PASS2} ${BALSHTMTH_NF} 2>&1 | ${TEE}
#fi

#Launch applicative job ESFD3027I -> FUSION ACCEPT + LIFEP
NJOB="ESFD3027I_1${IT}"
${DCMD}/ESFD3027I.cmd ${CRE_D} ${PASS1} ${BALSHTYEA_NF} 2>&1 | ${TEE}

# Launch applicative job ESFD3029 -> ANALYTICS ACCEPT
NJOB="ESFD3029_1${IT}"
${DCMD}/ESFD3029.cmd ${CRE_D} ${BALSHTYEA_NF} ${PASS1} 2>&1 | ${TEE}

# Launch applicative job ESFD3027 -> RETRO AUTO
NJOB="ESFD3027_1${IT}"
${DCMD}/ESFD3027.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${PASS1} ${CLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESFD2021 -> AI INTRA + INTRASERVEUR
NJOB="ESFD2021${IT}"
${DCMD}/ESFD2021.cmd ${DBCLO_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESFD3027I -> FUSION ACCEPT + AI INTRA
NJOB="ESFD3027I_2${IT}"
${DCMD}/ESFD3027I.cmd ${CRE_D} ${PASS2} ${BALSHTYEA_NF} 2>&1 | ${TEE}

# Launch applicative job ESFD3027 -> RETRO AUTO
NJOB="ESFD3027_2${IT}"
${DCMD}/ESFD3027.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${PASS2} ${CLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESFD3029 -> ANALYTICS RETRO
NJOB="ESFD3029_2${IT}"
${DCMD}/ESFD3029.cmd ${CRE_D} ${BALSHTYEA_NF} ${PASS2} 2>&1 | ${TEE}

# Launch applicative job ESFD3028 -> VLIFEST + CPLIFEST + CPLIFEST_MVT + LIFESTNOACC
NJOB="ESFD3028${IT}"
${DCMD}/ESFD3028.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}

# Ajout des anciennes lignes dans EST_CPLIFEST pour le traitement des fichies mouvement
cat ${EST_CPLIFEST_INTERM} >> ${EST_CPLIFEST}
RMFIL ${EST_CPLIFEST_INTERM}


#--- Renommage de fichiers 
#--- Etape temporaire pour faire tourner les chaines suivantes
#--- A supprimer au fur et a mesure de l'avancee des devs
#--- Les cp en commentaires sont les fichiers non encore générés par la 2030, en fonction de l'avancement des devs

if [ "${IT}" = "Y" ]
then
EST_CPLIFDRID=`echo ${EST_CPLIFDRI} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_CPLIFDRI $EST_CPLIFDRID
EST_CRIBLEANOD=`echo ${EST_CRIBLEANO} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_CRIBLEANO $EST_CRIBLEANOD
EST_FVPLACEMTD=`echo ${EST_FVPLACEMT} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_FVPLACEMT $EST_FVPLACEMTD
EST_SEGRATANOD=`echo ${EST_SEGRATANO} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_SEGRATANO $EST_SEGRATANOD
EST_SRGTCD=`echo ${EST_SRGTC} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_SRGTC $EST_SRGTCD
EST_VLIFEST195D=`echo ${EST_VLIFEST195} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_VLIFEST195 $EST_VLIFEST195D
EST_IARVPERICASE0D=`echo ${EST_IARVPERICASE0} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_IARVPERICASE0 $EST_IARVPERICASE0D
EST_IARVPERICASE4D=`echo ${EST_IARVPERICASE4} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_IARVPERICASE4 $EST_IARVPERICASE4D
EST_LIFTRANSFRD=`echo ${EST_LIFTRANSFR} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_LIFTRANSFR $EST_LIFTRANSFRD
EST_LIFENDCPTD=`echo ${EST_LIFENDCPT} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_LIFENDCPT $EST_LIFENDCPTD
EST_LIFESTNOACCD=`echo ${EST_LIFESTNOACC} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_LIFESTNOACC $EST_LIFESTNOACCD
EST_SRGTCB1D=`echo ${EST_SRGTCB1} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_SRGTCB1 $EST_SRGTCB1D
EST_CPLIFDRIND=`echo ${EST_CPLIFDRIN} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_CPLIFDRIN $EST_CPLIFDRIND
EST_LIFESTANAD=`echo ${EST_LIFESTANA} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_LIFESTANA $EST_LIFESTANAD
EST_FVPLACEMT2D=`echo ${EST_FVPLACEMT2} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_FVPLACEMT2 $EST_FVPLACEMT2D
EST_CPLIFESTD=`echo ${EST_CPLIFEST} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_CPLIFEST $EST_CPLIFESTD
EST_CPLIFEST_MVTD=`echo ${EST_CPLIFEST_MVT} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_CPLIFEST_MVT $EST_CPLIFEST_MVTD
EST_LIFESTLIBD=`echo ${EST_LIFESTLIB} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_LIFESTLIB $EST_LIFESTLIBD
EST_DLRLIFEID=`echo ${EST_DLRLIFEI} | sed "s/${IT}_/_/" | sed "s/ESFD2070/ESFD2030/"`
cp -v $EST_DLRLIFEI $EST_DLRLIFEID
fi

CHAINEND
