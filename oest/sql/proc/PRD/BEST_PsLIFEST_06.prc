Use BEST
go
if object_id('dbo.PsLIFEST_06') is not null
begin
  drop PROC dbo.PsLIFEST_06
  print '<<< DROPPED PROC dbo.PsLIFEST_06 >>>'
end
go
create procedure PsLIFEST_06
  (
  @p_END_NT       UEND_NT,
  @p_SEC_NF       USEC_NF,
  @p_UW_NT        UUW_NT,
  @p_UWY_NF       UUWY_NF,
  @p_SSD_CF       USSD_CF,
  @p_ESB_CF       UESB_CF,
  @p_DIR_CF       UDIR_CF,
  @p_DMN_CF       tinyint,
  @p_CTR_NF       UCTR_NF
  )
as
/***************************************************
Domaine                  : (ES) Estimation
Base principale          : BEST
Version                  : 1
Auteur                   : ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)
Date de creation         : 07 mai 1997
Description du programme : Sélection d'enregistrement dans RETRO et COMPTA : Info géné d'un traité Rétro dont on liste et maj
                           les estimations.
Conditions d'execution   :
Commentaires             :
_________________
MODIFICATIONS
1  L.DEBEVER 28/04/1998 Rajout "Rétro particulière O/N" et "somme des parts placées" dans select final
2  L.DEBEVER 19/04/1999 Deux select dans RETCTR / exc de souscription le plus récent 1 pour select 'état traité', un pour les autres info ????
                               => tout dans le même select.
3  G.BUISSON 04/02/2003 Recuperation du max de CRE_D dans LIFEST pour alimenter la date de dernier traitement (on ne prend pas
                         en compte les estimations creees par les arretes statistiques (heure de cre_d = 23:59:59)
4  G.BUISSON 24/02/2003 Pour determiner la retro particuliere on ne garde que RETCTRCAT_CF = '06', les autres etant destines aux facs
                         Recuperation du conretctr_b pour alimenter le champ "Mise a Jour Automatique" Recuperation du commentaire general sur TLIFDRI sur
                         contrat/exercice/section, bilan = 1900, mois = 01 AC = 1900 Recuperation du top presence de commentaires par AC
5  G.BUISSON 09/07/2003 Recherche dans BCTA..TBLCSHTD de la periode normale suivante pour deblocage de la saisie estimation en periode exceptionnelle
6  G.BUISSON 03/02/2004 Les as ne sont plus generes a 23:59:59 mais a 23:59:xx De ce fait on ne prend plus en compte les estimations dont l'heure est 23:59
7  Florent   03/09/2004 EST10260, gestion des grappes
8  G.BUISSON 25/05/2005 :spot:10305 La date de dernière mise à jour ne doit plus dépendre de l'exercice pour les traités de type 1 et 4
9  G.BUISSON 20/06/2005 :spot:11214 Permettre la saisie en période exceptionnelle si l'utilisateur a le profil TRT02 et que ce profil présente la mention 'EST OUI' dans PRFPAR1_LM
10 G.BUISSON 15/11/2007 :spot:14286 Ajout d'un poste "Primes liées au Sinistres" pour les traités NON PROP Récupération du PRG_NF sur l'exercice courant du traité (TCONTR)
11 G.BUISSON 16/11/2007 :spot:11245 Neutralisation des postes Echéance et Rachat pour la Lob 31 Récupération de la Lob (LOB_CF de TRETSEC)
12 T.RIPERT  24/09/2010 :spot:19247 Alimentation indicateur rétro interne (@SSDRTO_B)
13 D.OURMIAH 17/05/2011 :spot:21693 Si la devise au niveau de la section retro est renseignee, elle sera prise a la place de la devise de representation
14 Florent   05/09/2011 :spot:21784 Si au moins un placement du CTR est externe alors rétro interne = 0
15 Florent   08/09/2011 :spot:22315 ajout du type comptable de l'exercice
16 P.PEZOUT  28/03/2013 :spot:21693 ANNULATION DE LA SPOT 21693
*****************************************************/
declare
  @erreur               int,
  @timestamp_grappe     char(21),
  @ligne                int,
  @an                   UUWY_NF,       -- Année de la date d'effet du contrat (cad 1r exc de souscription
  @SEC_NF               USEC_NF,       -- n° de la section
  @RETCTR_NF            UCTR_NF,       -- zones table Contrat TRETCTR (base RETRO)
  @UWY_NF               UUWY_NF,
  @SSDRTO_B             bit,
  @RETPCPCUR_CF         UCUR_CF,
  @RETSPECUR_CF         UCUR_CF, -- MOD013
  @RETCTRCAT_CF         char(2),
  @CAN_DT               datetime,
  @RETACCTYP_CT         tinyint,
  @TERCTR_B             bit,
  @RETCTRSTS_CT         URETCTRSTS_CT,
  @GAR_CF               UGAR_CF,       -- zones table Section (base RETRO)
  @RETSIGSHA_R          USHA_R,        -- zones table Plaçements TPLACEMT (base RETRO)
  @CLMFUNINT_R          USHORAT_R,     -- zones table Dépôts TPINTWIT (base RETRO)
  @URRFUNINT_R          USHORAT_R,
  @SSD_CF               USSD_CF,       -- Zones table des Dates Bilan TBLCSHTD (base COMPTA)
  @ESB_CF               UESB_CF,
  @DIR_CF               UDIR_CF,
  @DMN_CF               Tinyint,
  @BLCSHTYEAN_NF        Smallint,      -- BLCSHTYEA_NF  normal
  @BLCSHTMTHN_NF        Tinyint,       -- BLCSHTMTH_NF  normal
  @BLCSHTYEAE_NF        Smallint,      -- BLCSHTYEA_NF  exceptionnel
  @BLCSHTMTHE_NF        Tinyint,       -- BLCSHTYEA_NF  exceptionnel
  @BLCSHTYEA_NF         Smallint,
  @BLCSHTMTH_NF         Tinyint,
  @SPCSTR_D             Datetime,
  @STR_D                Datetime,
  @END_D                Datetime,
  @TYPPER               Char(1),       -- type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable)
  @DATE                 Datetime,      -- date de recherche
  @SPCEND_D             Datetime,      -- date de fin de période exceptionnelle
  @ACCOUNT_D            Datetime,      -- date de comptabilisation ( fin service )
  @CLOSING_B            Bit,           -- top inventaire groupe
  @CUR_CFE              UCUR_CF,       -- zones table TLIFEST - monnaie estimation (base ESTIMATION)
  @CUR_CF               UCUR_CF,       -- monnaie estimation ou à défaut monnaie de représentation
  @bilan                Tinyint,       -- mois,année de bilan compris entre date de début
                                       -- et de fin période normale (valeur 1)
                                       -- ou exceptionnelle (valeur 2)
  @monnaie              Tinyint,       -- valeur 1 si la monnaie estimation existe et est différente
                                       -- de la monnaie de représentation, valeur 0 sinon
  @partic               Tinyint,       -- valeur 1 si contrat de rétro particulière
                                       -- valeur 0 sinon
  @dernier_trait        Datetime,      -- max de cre_d de lifest pour le contrat/section/bilan
                                       -- et pour exercice entre
  @conretctr_b          Bit,           -- Bit de mise a jour automatique
  @cmt_nt               UCMT_NT,       -- commentaire general
  @comac                Bit,           -- Top presence commentaire par AC
  @acy_sup              Smallint,      -- AC bilan + 2
  @acy_inf              Smallint,      -- AC bilan - 4
  @next_period          Tinyint,       -- mois de la periode normale suivante
  @habil_spec           Tinyint,       -- Profil TRT02 avec habilitation spéciale
  @prg_nf               Int,           -- Sert à déterminer s'il s'agit d'un traité non proportionnel  (> 0)
  @lob_char             ULOB_CF,       -- LOB de la section
  @lob_cf               Tinyint,       -- LOB convertie : 1 si LOB '31', 0 sinon
  @EXE_RETACCTYP_CT     UACCADMTYP_CT   -- type comptable de l'exercice --modif 15

-- -- modif 10, Appel de la procedure PSlocktab_01 : Ramène la tête de grappe
execute @erreur=BTEC..PsLOCKTAB_01 @p_CTR_NF, 'EST', @timestamp_grappe output

if @erreur != 0 or @@error != 0 return 1

/********************************************************************************************/
/* 1- select dans TRETCTR :                                                                 */
/*  Exercice de souscription le plus récent où l'état du contrat est ... :                  */
/*         - Valide (code 03)                                                               */
/*         - Résilié (code 19)                                                              */
/********************************************************************************************/
select @UWY_NF = max(RTY_NF)
from   BRET..TRETCTR
where  RETCTR_NF    = @p_CTR_NF
and   (RETCTRSTS_CT = 3 or RETCTRSTS_CT = 19)

select @erreur = @@error
if @erreur != 0
     begin
          Raiserror 20003 "APPLICATIF;TRETCTR"
          return 1
     end

/********************************************************************************************/
/* 2- select dans TRETCTR (correspondant au dernier ex de souscription) :                   */
/*  Modif 2 : Etat du contrat le plus récent                                                */
/*  Filiale rétrocessionnaire O/N (ie rétro interne O/N)                                    */
/*    Devise rétro de représentation                                                        */
/*    Rétrocession particulière (code 5,6,7,8)                                              */
/*    Date de résiliation                                                                   */
/*    Type de comptabilisation Retro suit Acceptation O/N                                   */
/*    Terminé comptablement O/N                                                             */
/********************************************************************************************/
-- MOD013
select @RETSPECUR_CF = RETSPECUR_CF
from BRET..TRETSEC
where  RETCTR_NF = @P_CTR_NF
and    RTY_NF    = @P_UWY_NF
and    RETSEC_NF = @P_SEC_NF

-- MOD016
--
--if @RETSPECUR_CF = null or @RETSPECUR_CF = ""
--begin
    select @RETCTRSTS_CT = RETCTRSTS_CT,
       @RETPCPCUR_CF = RETPCPCUR_CF,
       @RETCTRCAT_CF = RETCTRCAT_CF,
       @CAN_DT       = CAN_DT,
       @RETACCTYP_CT = RETACCTYP_CT,
       @TERCTR_B     = TERCTR_B,
       @an           = datepart(yy,ctrinc_d)
    from   BRET..TRETCTR
    where  RETCTR_NF = @p_CTR_NF
    and    RTY_NF    = @UWY_NF
--end
--else
--begin
--    select @RETCTRSTS_CT = RETCTRSTS_CT,
--       @RETPCPCUR_CF = @RETSPECUR_CF,
--       @RETCTRCAT_CF = RETCTRCAT_CF,
--       @CAN_DT       = CAN_DT,
--       @RETACCTYP_CT = RETACCTYP_CT,
--       @TERCTR_B     = TERCTR_B,
--       @an           = datepart(yy,ctrinc_d)
--    from   BRET..TRETCTR
--    where  RETCTR_NF = @p_CTR_NF
--    and    RTY_NF    = @UWY_NF
--
--end
-- FIN MOD013

select @erreur = @@error
if @erreur != 0
begin
    Raiserror 20003 "APPLICATIF;TRETCTR"
    return 1
end

/* Si @RETCTRCAT_CF = 5 ou 6 ou 7 ou 8, il s'agit d'une rétro particulière */
-- if @RETCTRCAT_CF in ('5', '6', '7', '8')

if @RETCTRCAT_CF = '06'
     begin
          select @partic = 1
     end
else
     begin
          select @partic = 0
     end

/* Recherche du top mise a jour auto sur contrat et exercice parametre */
select @CONRETCTR_B = CONRETCTR_B
from   BRET..TRETCTR
where  RETCTR_NF = @p_CTR_NF
and    RTY_NF    = @p_UWY_NF
select @erreur = @@error
if @erreur != 0
begin
    Raiserror 20003 "APPLICATIF;TRETCTR"
    return 1
end

/********************************************************************************************/
/* 3- select dans TRETSEC (correspondant au dernier ex de souscription) :                   */
/* Garantie                                                                                 */
/********************************************************************************************/
select @GAR_CF    = GAR_CF,
       @lob_char  = LOB_CF
from   BRET..TRETSEC
where  RETCTR_NF = @p_CTR_NF
and    RTY_NF    = @UWY_NF
and    RETSEC_NF = @p_SEC_NF
select @erreur = @@error
if @erreur != 0
begin
    Raiserror 20003 "APPLICATIF;TRETCTR"
    return 1
end

-- Conversion de la LOB
if @lob_char = '31'
    select @lob_cf = 1
else
    select @lob_cf = 0

/********************************************************************************************/
/* 4- N° contrat, N° section                                                                */
/********************************************************************************************/
select @RETCTR_NF = @p_CTR_NF
select @SEC_NF    = @p_SEC_NF

/********************************************************************************************/
/* 5- select dans TPLACEMT :                                                                */
/*  Somme des plaçements                                   */
/********************************************************************************************/
select @RETSIGSHA_R = sum(RETSIGSHA_R)
from   BRET..TPLACEMT
where  RETCTR_NF = @p_CTR_NF
and    RTY_NF    = @UWY_NF
and    HIS_B     = 0
select @erreur = @@error
if @erreur != 0
begin
    Raiserror 20003 "APPLICATIF;TRETCTR"
    return 1
end

/********************************************************************************************/
/* 6- select dans TPINTWIT                                                                  */
/*     Taux d'intérêt dépôt primes                                                          */
/*     Taux d'intérêt dépôt sinistres                                                       */
/*        où devise = devise de représentation                                              */
/********************************************************************************************/
select @CLMFUNINT_R = a.CLMFUNINT_R,
       @URRFUNINT_R = a.URRFUNINT_R
from   BRET..TPINTWIT a, BRET..TPLACEMT b
where  a.RETCTR_NF    = @p_CTR_NF
and    a.RTY_NF       = @UWY_NF
and    a.RETTRTCUR_CF = @RETPCPCUR_CF
and    a.RETCTR_NF    = b.RETCTR_NF
and    a.RTY_NF       = b.RTY_NF
and    a.PLC_NT       = b.PLC_NT
and    a.PLCVER_NT    = b.PLCVER_NT
and    b.HIS_B        = 0
select @erreur = @@error
if @erreur != 0
begin
    Raiserror 20003 "APPLICATIF;TRETCTR"
    return 1
end

/**********************************************************************************************/
/* 7- select dans BREF..TCALEND                                                               */
/* Recherche de la période 'année' et 'mois' en cours  ( execptionnelle à la date du jour )   */
/**********************************************************************************************/
select @DATE   = getdate()
select @TYPPER = 'E'

execute @erreur = BREF..PsCALEND_02 @DATE ,
                                    @TYPPER ,
                                    @BLCSHTYEA_NF output,
                                    @BLCSHTMTH_NF output,
                                    @SPCEND_D     output,
                                    @ACCOUNT_D    output,
                                    @CLOSING_B    output
if @erreur != 0
begin
    Raiserror 20005 "APPLICATIF;TACCSUP/TCALEND" /* erreur de lecture */
    return @erreur
end

/********************************************************************************************/
/* 8- select dans TBLCSHTD :                                                                */
/*  Date de fin de période normale                                                        */
/********************************************************************************************/
select @END_D = END_D
from   BCTA..TBLCSHTD
where  SSD_CF       = @p_SSD_CF
and    ESB_CF       = @p_ESB_CF
and    DIR_CF       = @p_DIR_CF
and    DMN_CF       = @p_DMN_CF
and    BLCSHTYEA_NF = @BLCSHTYEA_NF
and    BLCSHTMTH_NF = @BLCSHTMTH_NF
select @erreur = @@error
if @erreur != 0
begin
    Raiserror 20003 "APPLICATIF;TRETCTR"
    return 1
end

/********************************************************************************************/
/*  9- Si date du jour <= Date de fin de période normale                                */
/*          @bilan = 1 (normal) , sinon @bilan = 2  (exceptionnel)             */
/********************************************************************************************/
if @DATE <= @END_D
  select @bilan = 1
else
  select @bilan = 2

/********************************************************************************************/
/* 9 bis : Si on est en période exceptionnelle, il faut rechercher si le                    */
/*         user a une habilitation spéciale (profil TRT02 avec mention 'EST OUI' )          */
/********************************************************************************************/
select @habil_spec = 0

select @habil_spec = 1
from   BREF..TROLES a, BREF..TPROFIL b
where  a.USR_CF   = user
and    a.APP_CF   = 'EST'
and    a.PRF_CF   = 'TRT02'
and    a.APP_CF   = b.APP_CF
and    a.PRF_CF   = b.PRF_CF
and    PRFPAR1_LM = 'EST OUI'

/****************************************************************/
/* 10- Recherche dans BCTA..TBLCSHTD du mois correspondant a la */
/*     prochaine periode normale                                */
/****************************************************************/
select @next_period = 0

select @next_period = isnull(BLCSHTMTH_NF, 0)
from   BCTA..TBLCSHTD
where  SSD_CF       = @p_SSD_CF
and    ESB_CF       = @p_ESB_CF
and    DIR_CF       = @p_DIR_CF
and    DMN_CF       = @p_DMN_CF
and    BLCSHTYEA_NF = @BLCSHTYEA_NF
and    STR_D       !> getdate()
and    END_D       !< getdate()

select @erreur = @@error
if @erreur != 0
begin
  Raiserror 20003 "APPLICATIF;TRETCTR"
  return 1
end

/********************************************************************************************/
/* 11- select dans TLIFEST                                                                  */
/*  Monnaie des estimations                                                               */
/* Maj @monnaie : valeur 1 si la monnaie estimation existe et est différente                */
/* de la devise rétro de représentation, valeur 0 sinon                                     */
/********************************************************************************************/
select @CUR_CFE = CUR_CF
from   BEST..TLIFEST
where  CTR_NF     = @p_CTR_NF
and    END_NT     = @p_END_NT
and    SEC_NF     = @p_SEC_NF
and    UW_NT      = @p_UW_NT
and    BALSHEY_NF = @BLCSHTYEA_NF
select @erreur = @@error, @ligne = @@rowcount
if @erreur != 0
begin
  Raiserror 20003 "APPLICATIF;TRETCTR"
  return 1
end
if @ligne != 0 and @CUR_CFE != @RETPCPCUR_CF
begin
    select @CUR_CF  = @CUR_CFE
    select @monnaie = 1
end
else
begin
    select @CUR_CF  = @RETPCPCUR_CF
    select @monnaie = 0
end

/*********************************************************************************************/
/* 12- select dans TLIFEST                                                                   */
/*    date de dernier traitement                                                             */
/*    max de cre_d dans TLIFEST pour le contrat, la section passés en parametre le bilan     */
/*    calcule et exercice passe en parametre (pas le dernier exercice)                       */
/*    on retire de la selection les estimations crees par les arretes statistiques           */
/*    (heure de cre_d = 23:59:59)                                                            */
/*                                                                                           */
/*    L'heure des as a change donc on retire toutes les estimations dont l'heure est 23:59   */
/*                                                                                           */
/*********************************************************************************************/

if @RETACCTYP_CT = 1 or @RETACCTYP_CT = 4
     begin
          select @dernier_trait = max(CRE_D)
          from   BEST..TLIFEST
          where  CTR_NF                      = @p_CTR_NF
          and    END_NT                      = @p_END_NT
          and    SEC_NF                      = @p_SEC_NF
          and    UW_NT                       = @p_UW_NT
          and    BALSHEY_NF                  = @BLCSHTYEA_NF
          and    convert(Char(5), CRE_D, 8) != '23:59'
     end
else
     begin
          select @dernier_trait = max(CRE_D)
          from   BEST..TLIFEST
          where  CTR_NF                      = @p_CTR_NF
          and    END_NT                      = @p_END_NT
          and    SEC_NF                      = @p_SEC_NF
          and    UW_NT                       = @p_UW_NT
          and    UWY_NF                      = @p_UWY_NF
          and    BALSHEY_NF                  = @BLCSHTYEA_NF
          and    convert(Char(5), CRE_D, 8) != '23:59'
     end

select @erreur = @@error, @ligne = @@rowcount
if @erreur != 0
     begin
          Raiserror 20003 "APPLICATIF;TLIFEST"
          return 1
     end

/*********************************************************************************************/
/* 13- select dans TLIFDRI                                                                   */
/*    Commentaire general                                                             */
/*********************************************************************************************/

select @cmt_nt = a.CMT_NT
from   BEST..TLIFDRI a
where  a.CTR_NF       = @p_CTR_NF
and    a.END_NT       = @p_END_NT
and    a.SEC_NF       = @p_SEC_NF
and    a.UW_NT        = @p_UW_NT
and    a.UWY_NF       = @p_UWY_NF
and    a.BALSHEY_NF   = 1900
and    a.BALSHTMTH_NF = 1
and    a.ACY_NF       = 1900
and    a.CRE_D        = (select max(b.CRE_D)
                         from   BEST..TLIFDRI b
                         where a.CTR_NF       = b.CTR_NF
                         and   a.END_NT       = b.END_NT
                         and   a.SEC_NF       = b.SEC_NF
                         and   a.UW_NT        = b.UW_NT
                         and   a.UWY_NF       = b.UWY_NF
                         and   b.BALSHEY_NF   = 1900
                         and   b.BALSHTMTH_NF = 1
                         and   b.ACY_NF       = 1900)

select @erreur = @@error
if @erreur != 0
     begin
          Raiserror 20003 "APPLICATIF;TRETCTR"
          return 1
     end

/*********************************************************************************************/
/* 14- select dans TLIFDRI                                                                   */
/*    Top presence commentaires par AC                                                             */
/*********************************************************************************************/

select @acy_sup = @blcshtyea_nf + 2
select @acy_inf = @blcshtyea_nf - 4

if Exists (select 1
           from   BEST..TLIFDRI
           where  CTR_NF        = @p_CTR_NF
           and    END_NT        = @p_END_NT
           and    SEC_NF        = @p_SEC_NF
           and    UW_NT         = @p_UW_NT
           and    BALSHEY_NF    = @BLCSHTYEA_NF
           and    BALSHTMTH_NF <= @BLCSHTMTH_NF
           and    ACY_NF       <= @acy_sup
           and    ACY_NF       >= @acy_inf
           and    CMT_NT       != 0)
     begin
          select @comac = 1
     end
else
     begin
          select @comac = 0
    end

/*********************************************************************************************/
/* 14 Bis- select dans TRETCTR                                                               */
/*    Recherche du programme pour déterminer s'il s'agit d'un traité non proportionnel       */
/*********************************************************************************************/
select @prg_nf = case when nat_cf in (select CTRNAT_CF from BREF..TCTRNAT where CTRNATPRP_B=0) then 7 else 0 end
 from BRET..TRETSEC
  where RETCTR_NF=@p_CTR_NF
    and RTY_NF=@UWY_NF
    and RETSEC_NF=@p_SEC_NF

--modif 15
select @EXE_RETACCTYP_CT=RETACCTYP_CT from BRET..TRETCTR where RETCTR_NF=@P_CTR_NF and RTY_NF=@P_UWY_NF
if @EXE_RETACCTYP_CT=null select @EXE_RETACCTYP_CT=@RETACCTYP_CT

-- modif 12 -- modif 14
if exists(select 1 from bret..tplacemt where retctr_nf=@p_CTR_NF and his_b=0 and plcsts_ct in(16,19) and ssdrto_b=0)
  select @SSDRTO_B=0
else
  select @SSDRTO_B=1
-- Fin 012

/********************************************************************************************/
/* 15- OUF! : select final                                                                  */
/********************************************************************************************/

select  @RETCTR_NF                                CTR_NF,
        @SEC_NF                                   SEC_NF,
        @UWY_NF                                   UWY_NF,
        @RETACCTYP_CT                             ACCADMTYP_CT,
        @CAN_DT                                   CAN_DT,
        @GAR_CF                                   GAR_CF,
        @an                                       AN,
        @TERCTR_B                                 TERCTR_B,
        @CLMFUNINT_R                              CLMFUNINT_R,
        @URRFUNINT_R                              URRFUNINT_R,
        @BLCSHTYEA_NF                             BLCSHTYEA_NF,
        @BLCSHTMTH_NF                             BLCSHTMTH_NF,
        @CUR_CF                                   CUR_CF,
        @RETCTRSTS_CT                             RETCTRSTS_CT,
        @bilan                                    bilan,
        @SSDRTO_B                                 SSDRTO_B,
        @monnaie                                  monnaie,
        @RETSIGSHA_R                              RETSIGSHA_R,
        @partic                                   partic,
        null,
        null,
        null,
        null,
        @dernier_trait                            dernier_trait,
        @CONRETCTR_B                              CONRETCTR_B,
        @cmt_nt                                   cmt_nt,
        @comac                                    comac,
        @next_period                              next_period,
        TIMESTAMP_GRAPPE = @timestamp_grappe,
        HABIL_SPEC       = @habil_spec,
        PRG_NF           = @prg_nf,
        LOB_CF           = @lob_cf,
        EXE_ACCADMTYP_CT = @EXE_RETACCTYP_CT
return 0
go
if object_id('dbo.PsLIFEST_06') is not null
  print '<<< CREATED PROC dbo.PsLIFEST_06 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsLIFEST_06 >>>'
go
grant execute on dbo.PsLIFEST_06 To GOMEGA
go
