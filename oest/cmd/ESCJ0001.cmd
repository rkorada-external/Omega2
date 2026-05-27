#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESCJ0001.cmd
# revision                      : $Revision: 1.3 $
# date de creation              : 22/09/1997
# auteur                        : CGI (M.NAJI)
# references des specifications : ESTPARAM.doc
#-----------------------------------------------------------------------------
# description
#   Preparing parametrs files and planning executions
#
# job launched by ESCJ0000.cmd
#-----------------------------------------------------------------------------
# Modification Records
# 20-04-2004   Roger Cassis   Ajout de steps en fin de job pour gerer les flags
#                             de d'ouverture / fermeture de l'Infocentre mondial
#
#   02/ 06 / 04 J. Ribot      ajout un parametre SSDPEOP_LL (SOPT 4935)
#                             (Filiales ayant comptabilisees dans PeopleSoft)
#
# 09/02/2005   Roger Cassis   Ajout gestion du BCA par creation d'un fichier flag
#                             lorsque l'ESID8800 sera traite.
#                             Step ajoutee dans le pave concernant
#                             l'ouverture / fermeture de l'Infocentre mondial
# 22/06/2005  J. Ribot        ajout 3 parametres BOOKING_D  PSTOMGEN_D ENCONSO_D
#                             SPOT 5085 ecritures post omega
#
# 20/07/2005  M.DJELLOULI     Ajout Code Erreur Retour Fonction PsREQJOB_04
#                                      SPOT 5085 ecritures post omega
#
# 28/10/2008  Roger Cassis    :spot:16322 - Diminution du nom de fichier flag du step OSW0xA
#---------------
#MODIFICATION   : [007]
#Auteur         : D.GATIBELZA
#Date           : 12/03/2010
#Version        : 10.0
#Description    : SRVIE16960 Adaptation de TLIFSTAREP création d'une version du plan vie à la demande + ES plan à intégrer
#---------------
#MODIFICATION   : [008]
#Auteur         : P.COPPIN
#Date           : 29/03/2011
#Version        : 11.0
#Description    : :spot:21408 - creation nouveau fichier ${DFILP}/${NCHAIN}_EST_LASTPOBOOKING.dat 
#                               contenant Y si post omega conso et N sinon.
#[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
#[101] 22/04/2014 R. Cassis   :spot:25427  - Modifications pour omega2 -1b Suppression appel aux procs OSW
#[102] 04/11/2015 R. Cassis   :spot:29654 Gestion plan2 pour le Post-omega.
#[103] 02/02/2016 R. Cassis   :spot:30085 Ajout listes valeurs parm dans .log
#[104] 30/09/2016 R. Cassis   :spot:30152 - Add possibility to book POSE or POCE while running IFRS closing
#[105] 17/11/2016 R. Cassis   :spot:31263 - Add possibility to book not quaterly IFRS while running POSE or POCE closing
#[106] 04/08/2017 R. Cassis   :spira:61508 Gestion plan3 pour le Post-omega des ES locales
#[107] 06/03/2019 M. Naji     :spira:73132  deplacement de la proc  BEST..PsIfrs17Plan_02 dans ESCJ0001.cmd
#[108] 25/04/2019 R. Cassis   :spira:76850  Suppression fichier PLAN_EPO et touch avant recreation
#[109] 25/04/2019 M. NAJI     :spira:92532  désactiver la création des fichier *EPO*
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT
# Parameters
CRE_D=$1
CLONUM_CT=0

#[102]
NSTEP=${NJOB}_01
# Begin isql
#---------------------------------------------------------------
LIBEL="Reset planned records if job launched again"
ISQL_BASE="BEST"
ISQL_QRY="update best..treqjobplan
  			   set launch_d  = null
  			where reqcod_ct = 'D'
  			and   launch_d  = '19001231'
  			and   dbclo_d  <= '${CRE_D}'
  			and   site_cf   = '${HOST_PRDSIT}'
"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log	          
ISQL

#[102][104][105][106]
NSTEP=${NJOB}_02
# Begin isql
#---------------------------------------------------------------
LIBEL="Test if Post-omega planned to process only D demand"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_PLANCTL.dat
BCP_QRY="if exists (select 1 from best..treqjobplan
          where reqcod_ct in ('T','Y')
          and   launch_d is null
          and   dbclo_d  <= '${CRE_D}'
          and   site_cf = '${HOST_PRDSIT}')
          and   (exists (select 1 from best..treqjobplan
                        where reqcod_ct = 'D'
                        and   launch_d is null
                        and   dbclo_d  <= '${CRE_D}'
                        and   site_cf = '${HOST_PRDSIT}')
                 or
                 exists (select 1 from best..treqjobplan
                         where reqcod_ct = 'C'
                         and   launch_d is null
                         and   dbclo_d  = '${CRE_D}'
                         and   balshtmth_nf not in (3,6,9,12)
                         and   site_cf = '${HOST_PRDSIT}')
               )
                 
          begin
             select distinct 'POST'+reqcod_ct from best..treqjobplan
             where reqcod_ct = 'T'
             and   launch_d is null
             and   dbclo_d  <= '${CRE_D}'
             and   site_cf = '${HOST_PRDSIT}'
             Union
             select distinct 'POST'+reqcod_ct from best..treqjobplan
             where reqcod_ct = 'Y'
             and   launch_d is null
             and   dbclo_d  <= '${CRE_D}'
             and   site_cf = '${HOST_PRDSIT}'
             update best..treqjobplan
                set launch_d  = '19001231'
             where reqcod_ct in ('F','T','Y')
             and   launch_d is null
             and   dbclo_d  <= '${CRE_D}'
             and   site_cf = '${HOST_PRDSIT}'
             update best..treqjob
                set launch_d  = '19001231'
             where reqcod_ct in ('F','T','Y')
             and   launch_d is null
             and   dbclo_d  <= '${CRE_D}'
             and   site_cf = '${HOST_PRDSIT}'
          end
         else
          begin
             if exists (select 1 from best..treqjobplan
             where reqcod_ct in ('T','Y')
             and   launch_d is null
             and   dbclo_d  <= '${CRE_D}'
             and   site_cf = '${HOST_PRDSIT}')
             begin
                select distinct 'POST'+reqcod_ct from best..treqjobplan
                where reqcod_ct = 'T'
                and   launch_d is null
                and   dbclo_d  <= '${CRE_D}'
                and   site_cf = '${HOST_PRDSIT}'
                Union
                select distinct 'POST'+reqcod_ct from best..treqjobplan
                where reqcod_ct = 'Y'
                and   launch_d is null
                and   dbclo_d  <= '${CRE_D}'
                and   site_cf = '${HOST_PRDSIT}'
             end
             else
                select 'POSTNO'
          end
"          
BCP

NSTEP=${NJOB}_03
# Begin isql
#---------------------------------------------------------------
LIBEL="create autom. closing period demand"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PtREQJOB_02 '${CRE_D}' with recompile"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

NSTEP=${NJOB}_05
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Extraction of common parameters for ${CRE_D} - Parm ${CLONUM_CT} ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_PARM0.dat
BCP_LOG=${DFILT}/${NSTEP}_${IB}_BCPOUT.log
BCP_QRY="execute BEST..PsREQJOB_04 '${CRE_D}', ${CLONUM_CT} "
BCP

# Reading output files parameters which have been previously introduced
set `GETPRM ${DFILP}/${NCHAIN}_PARM0.dat`
BLCSHTYEA_NF=$2
BLCSHTMTH_NF=$3
SPCEND_D=$7
ACCOUNT_D=${10}
CLODAT_D=$6
PERTYP_CT=$9
CLOTYP_CT='_'
CLOEXIST=${21}
BOOKING_D=${30}
PSTOMGEN_D=${31}
ENCONSO_D=${32}
INVCONSO_D=${33}
CONSOYEA=${34}
CONSOMTH=${35}
INVSERV_D=${36}
SERVYEA=${37}
SERVMTH=${38}
SUFFTABLE=${39}
SSDPLAN_LL="---"    #[007]
SSDACC_LL=${60}
SSDPEOP_LL=${70}

#cat ${DFILP}/${NCHAIN}_PARM0.dat

NSTEP=${NJOB}_10
# Begin bcp
# [007] Ajout SSDPLAN_LL
#------------------------------------------------------------------------------
LIBEL="Extraction of common execution planning for plan ${CLONUM_CT}..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_PLAN0.dat
BCP_QRY="execute BEST..PsPlan_02 '${CRE_D}', ${CLONUM_CT}, ${BLCSHTYEA_NF}, ${BLCSHTMTH_NF}, '${SPCEND_D}', '${ACCOUNT_D}', '${CLODAT_D}', '${PERTYP_CT}', '${CLOTYP_CT}', ${CLOEXIST}, ${CONSOMTH}, ${CONSOYEA}, '${SSDACC_LL}', '${SSDPLAN_LL}'"
BCP

NSTEP=${NJOB}_11
# Save plans and parms
#---------------------------------------------------------------
LIBEL="Save plan and parm"
EXECKSH_MODE=P
EXECKSH "cp ${DFILP}/${NCHAIN}_PARM0.dat ${DSAV}/${SVG}_${NCHAIN}_PARM0.dat"
EXECKSH "cp ${DFILP}/${NCHAIN}_PLAN0.dat ${DSAV}/${SVG}_${NCHAIN}_PLAN0.dat"

grep "EST_LASTPOBOOKING=Y"  $DFILP/${NCHAIN}_PLAN0.dat > $DFILT/${NCHAIN}_EST_LASTPOBOOKING.dat


NSTEP=${NJOB}_15
# Delete old last post omega conso files
#---------------------------------------------------------------
LIBEL="Delete ${DFILP}/${NCHAIN}_EST_LASTPOBOOKING.dat"
RMFIL "${DFILP}/${NCHAIN}_EST_LASTPOBOOKING.dat"

if [ -s $DFILT/${NCHAIN}_EST_LASTPOBOOKING.dat ]
then
	echo "Y" > ${DFILP}/${NCHAIN}_EST_LASTPOBOOKING.dat
else
	echo "N" > ${DFILP}/${NCHAIN}_EST_LASTPOBOOKING.dat
fi

# Lock on the 4 Parameters files and the 4 plans to generate.
#------------------------------------------------------------------
#------ Begin while --------------
EST_STEP=15
while [ ${CLONUM_CT} -lt  4 ]
do
	CLONUM_CT=`expr ${CLONUM_CT} + 1`
	
	EST_STEP=`expr ${EST_STEP} + 5 `
	NSTEP=${NJOB}_${EST_STEP}
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Extraction of the parameters for the period closing process number ${CLONUM_CT} ..."
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILP}/${NCHAIN}_PARM${CLONUM_CT}.dat
	BCP_LOG=${DFILT}/${NSTEP}_${IB}_BCPOUT.log
	BCP_QRY="execute BEST..PsREQJOB_04 '${CRE_D}', ${CLONUM_CT} "
	BCP
	
	# Reading output files parameters which have been previously introduced
	set `GETPRM ${DFILP}/${NCHAIN}_PARM${CLONUM_CT}.dat`
	ICLODAT_D=$7
	PERTYP_CT=${16}
	CLOTYP_CT=${10}
	SSDPLAN_LL=${28}    #[007]
	
	EST_STEP=`expr ${EST_STEP} + 5 `
	NSTEP=${NJOB}_${EST_STEP}
	# Begin bcp
	# [007] Ajout SSDPLAN_LL
	#------------------------------------------------------------------------------
	LIBEL="Extraction of the planning for the period closing process number ${CLONUM_CT} ..."
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILP}/${NCHAIN}_PLAN${CLONUM_CT}.dat
	BCP_QRY="execute BEST..PsPlan_02 '${CRE_D}', ${CLONUM_CT}, ${BLCSHTYEA_NF}, ${BLCSHTMTH_NF}, '${SPCEND_D}', '${ACCOUNT_D}', '${ICLODAT_D}','${PERTYP_CT}', '${CLOTYP_CT}', ${CLOEXIST}, ${CONSOMTH}, ${CONSOYEA}, '${SSDACC_LL}', '${SSDPLAN_LL}'"
	BCP

	EST_STEP=`expr ${EST_STEP} + 5 `
	NSTEP=${NJOB}_${EST_STEP}
	# Save plans and parms
	#---------------------------------------------------------------
	LIBEL="Save plan and parm process number ${CLONUM_CT} ..."
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILP}/${NCHAIN}_PARM${CLONUM_CT}.dat ${DSAV}/${SVG}_${NCHAIN}_PARM${CLONUM_CT}.dat"
	EXECKSH "cp ${DFILP}/${NCHAIN}_PLAN${CLONUM_CT}.dat ${DSAV}/${SVG}_${NCHAIN}_PLAN${CLONUM_CT}.dat"
done
#------ End of while --------------

##[108]
#NSTEP=${NJOB}_99
## Begin rm
##------------------------------------------------------------------------------
#LIBEL="Remove temporary files"
#RMFIL "${DFILP}/${NCHAIN}_PLAN_EPO.dat"
#EXECKSH_MODE=P
#EXECKSH "touch ${DFILP}/${NCHAIN}_PLAN_EPO.dat"

#[102]------ Manage 2nd plan for EBS Post-omega processing --------------[104][105][106]
if [ `grep -c "POSTT" ${DFILP}/${NCHAIN}_PLANCTL.dat` -gt 0 ]
then
	CLONUM_CT=2

	NSTEP=${NJOB}_100
	# Begin isql
	#---------------------------------------------------------------
	LIBEL="Process Post-omega planned T demand"
	ISQL_BASE="BEST"
	ISQL_QRY="update best..treqjobplan
   			   set launch_d  = null
   			where reqcod_ct in ('F','T')
   			and   launch_d  = '19001231'
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
				update best..treqjob
   			   set launch_d  = null
   			where reqcod_ct in ('F','T')
   			and   launch_d  = '19001231'
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjobplan
   			   set launch_d  = '19001231'
   			where reqcod_ct in ('D','Y')
   			and   launch_d is null
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjob
   			   set launch_d  = '19001231'
   			where reqcod_ct in ('D','Y')
   			and   launch_d is null
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjobplan
   			   set launch_d  = '19001231'
   			where reqcod_ct = 'C'
   			and   launch_d is null
   			and   dbclo_d   = '${CRE_D}'
				and   balshtmth_nf not in (3,6,9,12)
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjob
   			   set launch_d  = '19001231'
   			where reqcod_ct = 'C'
   			and   launch_d is null
   			and   dbclo_d   = '${CRE_D}'
				and   balshtmth_nf not in (3,6,9,12)
   			and   site_cf   = '${HOST_PRDSIT}'
	"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log	          
	ISQL

	NSTEP=${NJOB}_105
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Extraction of common parameters  ..."
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILP}/${NCHAIN}_PARM2.dat
	BCP_LOG=${DFILT}/${NSTEP}_${IB}_BCPOUT.log
	BCP_QRY="execute BEST..PsREQJOB_04 '${CRE_D}', ${CLONUM_CT} "
	BCP

	# Reading output files parameters which have been previously introduced
	set `GETPRM ${DFILP}/${NCHAIN}_PARM2.dat`
	BLCSHTYEA_NF=$3
	BLCSHTMTH_NF=$4
	SPCEND_D=$9
	#ACCOUNT_D=${10}
	CLODAT_D=$8
	PERTYP_CT=${16}
	CLOTYP_CT=${10}
	#CLOEXIST=${21}
	BOOKING_D=${18}
	PSTOMGEN_D=${19}
	ENCONSO_D=${20}
	INVCONSO_D=${21}
	CONSOYEA=${22}
	CONSOMTH=${23}
	INVSERV_D=${24}
	SERVYEA=${25}
	SERVMTH=${26}
	SUFFTABLE=${27}
	SSDPLAN_LL="---"    #[007]
	#SSDACC_LL=${60}
	#SSDPEOP_LL=${70}

	NSTEP=${NJOB}_110
	# Begin bcp
	# [007] Ajout SSDPLAN_LL
	#------------------------------------------------------------------------------
	LIBEL="Extraction of Plan2 execution planning ..."
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILP}/${NCHAIN}_PLAN2.dat
	BCP_QRY="execute BEST..PsPlan_02 '${CRE_D}', ${CLONUM_CT}, ${BLCSHTYEA_NF}, ${BLCSHTMTH_NF}, '${SPCEND_D}', '${ACCOUNT_D}', '${CLODAT_D}', '${PERTYP_CT}', '${CLOTYP_CT}', ${CLOEXIST}, ${CONSOMTH}, ${CONSOYEA}, '${SSDACC_LL}', '${SSDPLAN_LL}'"
	BCP

	##[107]
	#NSTEP=${NJOB}_112
	## Begin bcp
	## [007] Ajout SSDPLAN_LL
	##------------------------------------------------------------------------------
	#LIBEL="Extraction of Plan post omega execution planning New Archi..."
	#BCP_WAY="OUT"
	#BCP_VER="+"
	#BCP_O=${DFILP}/${NCHAIN}_PLAN_EPO.dat
	#BCP_QRY="execute BEST..PsPlanEPO_01 '${CRE_D}', ${CLONUM_CT}, ${BLCSHTYEA_NF}, ${BLCSHTMTH_NF}, '${SPCEND_D}', '${ACCOUNT_D}', '${CLODAT_D}', '${PERTYP_CT}', '${CLOTYP_CT}', ${CLOEXIST}, ${CONSOMTH}, ${CONSOYEA}, '${SSDACC_LL}', '${SSDPLAN_LL}'"
	#BCP

	#NSTEP=${NJOB}_113
	## Set environments variable create by BEST..PsPlanEBS_01
	##---------------------------------------------------------------
	#LIBEL="Set environments variable create by BEST..PsPlanEBS_01 ..."
	#EXECKSH_MODE=P
	#EXECKSH ". ${DFILP}/${NCHAIN}_PLAN_EPO.dat"
	##EXECKSH "cp ${DFILP}/${NCHAIN}_PARM2.dat ${DFILP}/${NCHAIN}_PARM_EPO.dat "
	
	NSTEP=${NJOB}_115
	# Save plans and parms
	#---------------------------------------------------------------
	LIBEL="Save plans and parms"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILP}/${NCHAIN}_PARM2.dat ${DSAV}/${SVG}_${NCHAIN}_PARM2.dat"
	EXECKSH "cp ${DFILP}/${NCHAIN}_PLAN2.dat ${DSAV}/${SVG}_${NCHAIN}_PLAN2.dat"
	#EXECKSH "cp ${DFILP}/${NCHAIN}_PLAN_EPO.dat ${DSAV}/${SVG}_${NCHAIN}_IFRS17_EPO.dat"
	
	
	#[105]	
	NSTEP=${NJOB}_120
	# Begin isql
	#---------------------------------------------------------------
	LIBEL="Reset all planned record"
	ISQL_BASE="BEST"
	ISQL_QRY="update best..treqjobplan
   			   set launch_d  = null
   			where reqcod_ct in ('D','Y')
   			and   launch_d  = '19001231'
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjob
   			   set launch_d  = null
   			where reqcod_ct in ('D','Y')
   			and   launch_d  = '19001231'
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjobplan
   			   set launch_d  = null
   			where reqcod_ct = 'C'
   			and   launch_d  = '19001231'
   			and   dbclo_d   = '${CRE_D}'
				and   balshtmth_nf not in (3,6,9,12)
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjob
   			   set launch_d  = null
   			where reqcod_ct = 'C'
   			and   launch_d  = '19001231'
   			and   dbclo_d   = '${CRE_D}'
				and   balshtmth_nf not in (3,6,9,12)
   			and   site_cf   = '${HOST_PRDSIT}'
	"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log	          
	ISQL
	
fi

#[102]------ Manage 3rd plan for Post-omega Local processing --------------[104][105][106]
if [ `grep -c "POSTY" ${DFILP}/${NCHAIN}_PLANCTL.dat` -gt 0 ]
then
	CLONUM_CT=3

	NSTEP=${NJOB}_125
	# Begin isql
	#---------------------------------------------------------------
	LIBEL="Process Post-omega planned Y demand"
	ISQL_BASE="BEST"
	ISQL_QRY="update best..treqjobplan
   			   set launch_d  = null
   			where reqcod_ct in ('Y')
   			and   launch_d  = '19001231'
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
				update best..treqjob
   			   set launch_d  = null
   			where reqcod_ct in ('Y')
   			and   launch_d  = '19001231'
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjobplan
   			   set launch_d  = '19001231'
   			where reqcod_ct in ('D','T','F')
   			and   launch_d is null
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjob
   			   set launch_d  = '19001231'
   			where reqcod_ct in ('D','T','F')
   			and   launch_d is null
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjobplan
   			   set launch_d  = '19001231'
   			where reqcod_ct = 'C'
   			and   launch_d is null
   			and   dbclo_d   = '${CRE_D}'
				and   balshtmth_nf not in (3,6,9,12)
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjob
   			   set launch_d  = '19001231'
   			where reqcod_ct = 'C'
   			and   launch_d is null
   			and   dbclo_d   = '${CRE_D}'
				and   balshtmth_nf not in (3,6,9,12)
   			and   site_cf   = '${HOST_PRDSIT}'
	"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log	          
	ISQL

	NSTEP=${NJOB}_130
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Extraction of common parameters  ..."
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILP}/${NCHAIN}_PARM3.dat
	BCP_LOG=${DFILT}/${NSTEP}_${IB}_BCPOUT.log
#	BCP_QRY="execute BEST..PsREQJOB_04 '${CRE_D}', ${CLONUM_CT} "
	BCP_QRY="execute BEST..PsREQJOB_04 '${CRE_D}', 2"
	BCP

	# Reading output files parameters which have been previously introduced
	set `GETPRM ${DFILP}/${NCHAIN}_PARM3.dat`
	BLCSHTYEA_NF=$3
	BLCSHTMTH_NF=$4
	SPCEND_D=$9
	#ACCOUNT_D=${10}
	CLODAT_D=$8
	PERTYP_CT=${16}
	CLOTYP_CT=${10}
	#CLOEXIST=${21}
	BOOKING_D=${18}
	PSTOMGEN_D=${19}
	ENCONSO_D=${20}
	INVCONSO_D=${21}
	CONSOYEA=${22}
	CONSOMTH=${23}
	INVSERV_D=${24}
	SERVYEA=${25}
	SERVMTH=${26}
	SUFFTABLE=${27}
	SSDPLAN_LL="---"    #[007]
	#SSDACC_LL=${60}
	#SSDPEOP_LL=${70}

	NSTEP=${NJOB}_135
	# Begin bcp
	# [007] Ajout SSDPLAN_LL
	#------------------------------------------------------------------------------
	LIBEL="Extraction of Plan3 execution planning ..."
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILP}/${NCHAIN}_PLAN3.dat
	BCP_QRY="execute BEST..PsPlan_02 '${CRE_D}', ${CLONUM_CT}, ${BLCSHTYEA_NF}, ${BLCSHTMTH_NF}, '${SPCEND_D}', '${ACCOUNT_D}', '${CLODAT_D}', '${PERTYP_CT}', '${CLOTYP_CT}', ${CLOEXIST}, ${CONSOMTH}, ${CONSOYEA}, '${SSDACC_LL}', '${SSDPLAN_LL}'"
	BCP
	
	NSTEP=${NJOB}_140
	# Save plans and parms
	#---------------------------------------------------------------
	LIBEL="Save plans and parms"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILP}/${NCHAIN}_PARM3.dat ${DSAV}/${SVG}_${NCHAIN}_PARM3.dat"
	EXECKSH "cp ${DFILP}/${NCHAIN}_PLAN3.dat ${DSAV}/${SVG}_${NCHAIN}_PLAN3.dat"
	
	#[105]	
	NSTEP=${NJOB}_145
	# Begin isql
	#---------------------------------------------------------------
	LIBEL="Reset All planned records"
	ISQL_BASE="BEST"
	ISQL_QRY="update best..treqjobplan
   			   set launch_d  = null
   			where reqcod_ct in ('D','T','F','Y')
   			and   launch_d  = '19001231'
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjob
   			   set launch_d  = null
   			where reqcod_ct in ('D','T','F','Y')
   			and   launch_d  = '19001231'
   			and   dbclo_d  <= '${CRE_D}'
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjobplan
   			   set launch_d  = null
   			where reqcod_ct = 'C'
   			and   launch_d  = '19001231'
   			and   dbclo_d   = '${CRE_D}'
				and   balshtmth_nf not in (3,6,9,12)
   			and   site_cf   = '${HOST_PRDSIT}'
   			update best..treqjob
   			   set launch_d  = null
   			where reqcod_ct = 'C'
   			and   launch_d  = '19001231'
   			and   dbclo_d   = '${CRE_D}'
				and   balshtmth_nf not in (3,6,9,12)
   			and   site_cf   = '${HOST_PRDSIT}'
	"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log	          
	ISQL
	
fi

NSTEP=${NJOB}_150
# Gzip plans and parms
#---------------------------------------------------------------
LIBEL="Gzip plan and parm"
EXECKSH_MODE=P
EXECKSH "gzip ${DSAV}/*${NCHAIN}_P*.dat"

ECHO_LOG "===>> --------------------"
ECHO_LOG "===>> List PLAN0 variables"
ECHO_LOG "===>> --------------------"
head -5 ${DFILP}/${NCHAIN}_PLAN0.dat
tail -9 ${DFILP}/${NCHAIN}_PLAN0.dat
ECHO_LOG "===>> --------------------"
ECHO_LOG "===>> List PARM0 variables"
ECHO_LOG "===>> --------------------"
head -10 ${DFILP}/${NCHAIN}_PARM0.dat
ECHO_LOG "===>> --------------------"
ECHO_LOG "===>> List PLAN1 variables"
ECHO_LOG "===>> --------------------"
head -5 ${DFILP}/${NCHAIN}_PLAN1.dat
tail -9 ${DFILP}/${NCHAIN}_PLAN1.dat
ECHO_LOG "===>> --------------------"
ECHO_LOG "===>> List PARM1 variables"
ECHO_LOG "===>> --------------------"
head -10 ${DFILP}/${NCHAIN}_PARM1.dat
ECHO_LOG "===>> --------------------"
ECHO_LOG "===>> List PLAN2 variables"
ECHO_LOG "===>> --------------------"
head -5 ${DFILP}/${NCHAIN}_PLAN2.dat
tail -9 ${DFILP}/${NCHAIN}_PLAN2.dat
ECHO_LOG "===>> --------------------"
ECHO_LOG "===>> List PARM2 variables"
ECHO_LOG "===>> --------------------"
head -50 ${DFILP}/${NCHAIN}_PARM2.dat
ECHO_LOG "===>> --------------------"
ECHO_LOG "===>> List PLAN3 variables"
ECHO_LOG "===>> --------------------"
head -5 ${DFILP}/${NCHAIN}_PLAN3.dat
tail -9 ${DFILP}/${NCHAIN}_PLAN3.dat
ECHO_LOG "===>> --------------------"
ECHO_LOG "===>> List PARM3 variables"
ECHO_LOG "===>> --------------------"
head -50 ${DFILP}/${NCHAIN}_PARM3.dat


# End of Job
JOBEND
