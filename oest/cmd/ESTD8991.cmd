#=============================================================================
# nom de l'application          : ESTIMATIONS
#
# nom du script SHELL           : ESTD8991.cmd
# revision                      : $Revision:   1.0  $
# date de creation              :
# auteur                        : CGI
# reference des specifications  :
#-----------------------------------------------------------------------------
# Description :
#      RM des fichiers regeneres par l inventaire suivant
#
# Job launched by ESTD8990.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
# M.DJELLOULI       10/02/2005      Suppression Demandes Fichiers Ano Généré par ESID2560
# M. DJELLOULI      03-10-2005      Mise en Place de Suppression sauf si PériodeExceptionnelle <= Cre_D <= Account_d de TCALEND
#[03]  24/06/2010   Roger Cassis    :spot:19204 - Fichier ESEH1100 renommé en ESEH1110
#[04]  08/10/2010   Roger Cassis    :spot:20658 - Suppression du fichier *ESEH1110_SAISPERICASE_*
#[05]  19/05/2011   Roger Cassis    :spot:21408 - Modification de ESID0060 vers ESID0070 pour fichier MVTPNA0
#[06]  01/12/2011   Roger Cassis    :spot:22859 - Ajout fichier flag pour declencher le process OneGl
#[07]  02/02/2012   Roger Cassis    :spot:23329 - la suppression des fichiers flags est faite dans le ESCJ0061 maintenant
#[08]  16/07/2014 R. Cassis :spot:27172 Only files ${DFILI}/${PCH}ES[C,E,I]* are deleted not ESP...
#[09]  11/03/2016 R. Cassis :spot:29162 Les fichiers _FCES et _FPLC sont pas supprimés car ils sont utilisés par le ESIJ0090
#[10]  18/07/2017 Roger     :spira:63027 Modification de la requete de déclenchement du nettoyage des fichiers estimation journaliers
#[11]  26/02/2021 M.NAJI Spira 91531  commenter les suppression des fichier permanents  
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
CRE_D=$1

# Initialization of the Job
JOBINIT

#[10]
NSTEP=${NJOB}_02
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination de la Suppression si on est en type d'inventaire IFRS en période non comptable"
ISQL_BASE="BEST"
ISQL_QRY="if EXISTS (select 1 from best..treqjobplan
                     where dbclo_d <= '${CRE_D}'
                     and reqcod_ct = 'D'
                     and launch_d is null
                     and site_cf = '${HOST_PRDSIT}')
          and NOT EXISTS (select 1 from bref..Tcalend
                          where account_d = '${CRE_D}')
  select 0
else
  select 1
"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

# Retour DATECHECK
#              DATECHECK = 1 : Suppression NON Autorisée
#              DATECHECK = 0 : Suppression Autorisée
DATECHECK=`cat ${ISQL_FRES} | sed -e s/\ //g`

if [ ${DATECHECK} = 1 ]
then
    echo "Suppression NON Autorisée"
    JOBEND
fi


NSTEP=${NJOB}_05
# Begin Sort
#-----------------------------------------------------------------
LIBEL="RM of the permanent files"
#[08]
RMFIL "${DFILI}/${PCH}ES[C,E,I]*"      #S. Llorente 22/01/2001 RMFIL "${DFILI}/${PCH}ES*"
RMFIL "${DFILI}/${PCH}DWED0010*"
#RMFIL "${DFILP}/${PCH}ESCJ0060_FCURCVSNI[_,\.]*"
#[11]RMFIL "${DFILP}/${PCH}ESCJ0060_FDETTRS[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESCJ0060_FRETTRF[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0060_OADPERICASE0[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0060_OADPERICASE0[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0060_OAVPERICASE0[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0060_ORDPERICASE0[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0060_ORVPERICASE0[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_DLAGTAA[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_DLAGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_DLAGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2000_DLDGTAA[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLREGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLREGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2900_DLREJGTAA[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2900_DLREJGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2900_DLREJGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLREMAJGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2900_DLREJGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLREMAJGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLREMAJGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_DLRIGTAA[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID1530_DLVGTAA[_,\.]*"      # JR - 29/10/2004
RMFIL "${DFILP}/${PCH}ESID1530_DLVGTAR[_,\.]*"      #  "
RMFIL "${DFILP}/${PCH}ESID1530_DLVGTR[_,\.]*"       #  "
RMFIL "${DFILP}/${PCH}ESID1550_DLRNPGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID1550_DLRNPGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLRPGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLRPGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLRTCGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLRTCGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLRTFGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLRTFGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLRTGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2500_DLRTGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2060_DLTOTGTAA[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2560_DLTOTGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2560_DLTOTGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2040_DLVGTAA[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2040_DLVGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2040_DLVGTR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2000_DSUMGTAASNEM[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_FACCTRAA[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID2500_FCES[_,\.]*"      #[09]
RMFIL "${DFILP}/${PCH}ESID0560_FCMUSPLI[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_FCMUSPLIT[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID0560_FCPLACC[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID0560_FCTRGRO[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2000_FLOARATSNEM[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_FOUTTRAA[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID2500_FPLC[_,\.]*"     #[09]
RMFIL "${DFILP}/${PCH}ESID1600_FSEGACTBILANT[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_FSNEMHIST[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID8800_FTECLEDASNEM[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID8800_FTECLEDRSNEM[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID8800_FTECLEDRSNEM[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID0560_IADPERICASE[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID0560_IADVPERICASE[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2000_IGTAAF[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_IGTAR[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_IGTR[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID0560_IRDVPERICASE[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID1500_IRDVPERICASE0[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0070_MVTPNA0[_,\.]*"          # [004]
RMFIL "${DFILP}/${PCH}ESID2000_PERICASESNEM[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID2000_PERICASESNEM[_,\.]*"
RMFIL "${DFILP}/${PCH}ESEH1110_FBSEGEST[_,\.]*"         # [03]
RMFIL "${DFILP}/${PCH}ESID0060_MVTPNA0[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_FAMPROT[_,\.]*"
RMFIL "${DFILP}/${PCH}ESID0560_FAPR[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID0560_IADVPERICASE[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID0560_IRDVPERICASE[_,\.]*"
#RMFIL "${DFILP}/${PCH}ESID0560_OIADVPERICASE[_,\.]*" #FCharles 11/04/2000
#RMFIL "${DFILP}/${PCH}ESID0560_OIRDVPERICASE[_,\.]*" #FCharles 11/04/2000
#RMFIL "${DFILP}/${PCH}ESID0060_FTVENTNP[_,\.]*"         # MDJ - 12/08/2004
#RMFIL "${DFILT}/${PCH}ESID2560_*GTAR[_,\.]*.ano"        # MDJ - 10/02/2005
RMFIL "${DFILP}/${PCH}ESEH1110_SAISPERICASE[_,\.]*"     # [04]
#RMFIL "${DTMP}/${PCH}OTGL0010I.OK"     # [06] [07]
#RMFIL "${DTMP}/${PCH}OTGL0010P.OK"     # [06] [07]

JOBEND
