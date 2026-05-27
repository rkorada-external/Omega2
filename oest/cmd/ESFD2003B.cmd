#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESID2003A.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 31/05/2012
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2220.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 18/04/2012 Roger Cassis :spot:23802 - Modifications pour Solvency
#[002] 31/07/2012 Lalatiana Rakotozafy  :spot:24041  - Modifications pour Solvency
#[003] 02/08/2012 -=Dch=-  :spot:24041 - Modifs techniques Solvency
#[004] 31/08/2012 R. Cassis meme spot  - Modifs techniques Solvency
#[005] 02/08/2012 -=Dch=-  :spot:24041 - Modifs techniques Solvency Ajout du paramètre ICLODAT_D pour ESTC1054
#                                        Autres modifs
#[006] 25/10/2012 JF VDV : [24041] - Modifications pour Solvency
#[008] 20/01/2013 -=PhP=-   :spot:24698 -   corrections pour la conso
#[009] 13/02/2013 -=PHP=-   :spot:24836  Corrections solvency 2
#[010] 30/09/2015 -=PHP=-   :spot:28941  Corrections postes Solvency créés à tort
#[011] 22/03/2016 Florent   :spot:29066  Formatage du fichier GLT
#[012] 14/04/2016 -=Dch=-   :spot:30465  Ajout pour le ESID8050 (Futures EBS)
#[013] 04/05/2016  SAS      :spot:30534  EBS - Futures Premiums (42511) & Charges(42512)
#[014] 26/05/2016 S.Behague :spot 30583: Spira 41148
#[015] 14/06/2016 S.ASKRI   :spot 30534: Spira 42512 Futures charges
#[016] 21/06/2016 -=Dch=-   :spot:30534  Modification des conditions du step 90
#[017] 07/07/2016 Florent   :spot:30890  EBS - Correction sur le calcul des futures pour traités NP
#[018] 07/04/2016 Florent   :spira:38697 ajustement pour écart entre IFRS et EBS programme ESTC1054
#[019] 23/07/2018 JYP       :spira:69871 migration to IFRS17 context2 , ESID2000 and ESPD2000 revamped in 3 new batch chains 
#[020] 11/09/2018 JYP       :IFRS17 req 10.6 req 10.1 : rename ESTC1064 by ESTC1065 
#[021] 19/10/2018 MZM       Spira:67650:IFRS17 REQ 10.4 REQ 10.5 : Future Fixed, Variables Premium, Future Brokerage, Future Claims
#[022] 20/02/2019 JYP : spira:69871  : IFRS17 req 10.6 req 10.1: new UPR_DAC file 
#[023] 26/02/2019 JYP : spira:69871  : IFRS17 req 10.6 req 10.1: bugfix UPR_DAC file 
#[024] 13/03/2019 MZM : spira:67650  : Future Variables Premium et Charges, Future Brokerage : Prise en compte des nouveaux TRNCODS "1A120022" ; "1A120032" ; "1A100022"
#[025] 10/04/2019 MZM : spira:74456  : Future Brokerage - Amount calculated incorrect  : Ajout du STEP 165, TRI du FICHIER FLOARAT
#[026] 17/05/2019 MZM : spira:77696  : REQ 10.4 - missing or incorrect future fixed commission ; Seul le poste ACMTRS_NT 10100 est utilisée pour les CHARGES
#=============================================================================
#set -x

# ***************************************************************************************
# ***************************************************************************************
#
# PHP rajouter fusion des EBS et IFRS pour fichiers FPRMLOA, FLOARAT et FT
#
# ESPT0000_DLDGTAA_IFRS  EN SORTIE DU ESID2000/ESID2002I   EST_DLDGTAA taux 'A'
# ESPT0000_DLDGTAA_EBS   EN SORTIE DU ESID2000/ESID2002E
#
# ESPD2000_DLDGTAA_EBS  EN SORTIE DU ESPD2000/ESID2002E    EST_DLDGTAA_EBSSO
# ESPD2000_DLDGTAA      EN SORTIE DU ESPD2000/ESID2003     EST_DLDGTAASO
#
# ***************************************************************************************
# ***************************************************************************************

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# Parameters
TYPEINV=$1
ICLODAT_D=$2
num=$3

ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`

UWY_MIN=2

MIN_ICLODAT_A=`expr ${ICLODAT_A} - ${UWY_MIN}`




NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : calculation of fstat avec arcstatgta"
PRG=ESTC3604
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${ICLODAT_A}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${EST_ARCSTATGTA}$num
export ${PRG}_I3=${DFILP}/empty.dat
export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_I5=${EST_FCURQUOT}
export ${PRG}_I6=${EST_FCPLACC}
export ${PRG}_I7=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSTAT_O_${num}.dat
EXECPRG


JOBEND
