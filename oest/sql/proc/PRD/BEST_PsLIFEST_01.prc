use BEST
go
if object_id('dbo.PsLIFEST_01') is not null
begin
  drop PROC dbo.PsLIFEST_01
  print '<<< DROPPED PROC dbo.PsLIFEST_01 >>>'
end
go
create procedure PsLIFEST_01
(@p_END_NT       UEND_NT,
@p_SEC_NF       USEC_NF,
@p_UW_NT        UUW_NT,
@p_UWY_NF       UUWY_NF,
@p_SSD_CF       USSD_CF,
@p_ESB_CF       UESB_CF,
@p_DIR_CF       UDIR_CF,
@p_DMN_CF       tinyint,
@p_CTR_NF       UCTR_NF,
@p_LANGUE       char(1))
as
/***************************************************
Domaine                   : (ES) Estimation
Base principale           : BEST
Version                   : 1
Auteur                    : ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)
Date de creation          : 03 Avril 1997
Description du programme  : Sélection d'enregistrement dans TRAITE et COMPTA
                            Info géné d'un traité Acceptation dont on liste et maj les estimations.
Conditions d'execution    :
Commentaires              :
_________________
MODIFICATIONS
1  L.DEBEVER 29/09/1997 Recherche monnaire principale de la section @CUR_CFS
2  L.DEBEVER 07/10/1997 Etat de la section correspondant à l'exc de souscription
3  L.DEBEVER 19/04/1999 Description: Deux select dans TSECTION / exc de souscription le plus récent. 1 pour select 'état traité', un pour les autres info ????
                         => tout dans le même select. + select 'nature section' (TSECTION) + select 'caractérisation affaire' (TCONTR)
4  G.BUISSON 20/01/2003 Recuperation du max de CRE_D dans LIFEST pour alimenter la date de dernier traitement (on ne prend pas en compte les estimations
                        creees par les arretes statistiques (heure de cre_d = 23:59:59)
5  G.BUISSON 26/02/2003 Recuperation du commentaire general sur TLIFDRI sur contrat/exercice/section, bilan = 1900, mois = 01 AC = 1900 Recuperation du top presence de commentaires par AC
6  G.BUISSON 26/03/2003 Recuperation du type de calcul des CNA dans BRET..TCONTR
7  G.BUISSON 28/04/2003 Ajout argument langue pour recuperation libelle du type de calcul cna
8  G.BUISSON 09/07/2003 Recherche dans BCTA..TBLCSHTD de la periode normale suivante pour deblocage de la saisie estimation en periode exceptionnelle
9  G.BUISSON 03/02/2004 Les as ne sont plus generes a 23:59:59 mais a 23:59:xx. De ce fait on ne prend plus en compte les estimations dont l'heure est 23:59
10 Florent   19/07/2004 EST10260, gestion des grappes
11 DJELLOULI 02/08/2004 selection Min Periode Comptable
12 G.BUISSON 25/05/2005 :spot:10305 La date de dernière mise à jour ne doit plus dépendre de l'exercice pour les traités de type 1 et 4
13 G.BUISSON 20/06/2005 :spot:11214 Permettre la saisie en période exceptionnelle si l'utilisateur a le profil TRT02 et que ce profil présente la mention 'EST OUI' dans PRFPAR1_LM
14 G.BUISSON 20/06/2006 :spot:12865 Le message d'alerte de la période exceptionnelle ne doit apparaitre que s'il s'agit d'une clôture trimestrielle (CLOSING_B = 1)
                        et pas lors d'une clôture mensuelle (CLOSING_B = 0)
15 G.BUISSON 14/11/2007 :spot:14286 Ajout d'un poste "Primes liées au Sinistres" pour les traités NON PROP Récupération du PRG_NF sur l'exercice courant du traité (TCONTR)
16 G.BUISSON 16/11/2007 :spot:11245 Neutralisation des postes Echéance et Rachat pour la Lob 31 Récupération de la Lob (LOB_CF de TSECTION)
17 Florent   08/09/2011 :spot:22315 ajout du type comptable de l'exercice
*****************************************************/
declare @timestamp_grappe   Char(21),
        @erreur             Int,
        @ligne              Int,
        @CTR_NF             UCTR_NF,    -- zones table Contrat TCONTR (base TRAITE)
        @END_NT             UEND_NT,
        @UW_NT              UUW_NT,
        @UWY_NF             UUWY_NF,
        @CED_NF             UCLI_NF,
        @LIFTRTTYP_CF       Char(2),
        @CLISSD_CF          USSD_CF,    -- zones client
        @SEC_NF             USEC_NF,    -- zones table Section TSECTION (base TRAITE)
        @NAT_CF             UCTRNAT_CF,
        @ACCADMTYP_CT       UACCADMTYP_CT,
        @SECCAN_D           Datetime,
        @GAR_CF             UGAR_CF,
        @FRSUWY_NF          UUWY_NF,
        @SECACCSTS_CT       UACCSTS_CT,
        @SECSTS_CT          UCTRSTS_CT,
        @CUR_CFS            UCUR_CF,    -- zones table TSECTION - monnaie section (base Traité)
        @CLMFUNINT_R        USHORAT_R,  -- zones table Dépôts TFAMFUNW (base TRAITE)
        @URRFUNINT_R        USHORAT_R,
        @SSD_CF             USSD_CF,    -- Zones table des Dates Bilan TBLCSHTD (base COMPTA)
        @ESB_CF             UESB_CF,
        @DIR_CF             UDIR_CF,
        @DMN_CF             Tinyint,
        @BLCSHTYEAN_NF      Smallint,   -- BLCSHTYEA_NF  normal
        @BLCSHTMTHN_NF      Tinyint,    -- BLCSHTMTH_NF  normal
        @BLCSHTYEAE_NF      Smallint,   -- BLCSHTYEA_NF  exceptionnel
        @BLCSHTMTHE_NF      Tinyint,    -- BLCSHTYEA_NF   exceptionnel
        @BLCSHTYEA_NF       Smallint,
        @BLCSHTMTH_NF       Tinyint,
        @SPCSTR_D           Datetime,
        @STR_D              Datetime,
        @END_D              Datetime,
        @TYPPER             Char(1),    -- type de recherche 'E' : Exceptionnelle; 'C' : Service (comptable)
        @DATE               Datetime,   -- date de recherche
        @SPCEND_D           Datetime,
        @ACCOUNT_D          Datetime,   -- date de comptabilisation ( fin service )
        @CLOSING_B          Bit,        -- top inventaire groupe
        @CUR_CFE            UCUR_CF,    -- zones table TLIFEST - monnaie estimation (base ESTIMATION)
        @CUR_CF             UCUR_CF,    -- monnaie estimation ou à défaut monnaie section
        @bilan              Tinyint,    -- mois/année bilan entre début et fin pér. normale (1) ou except. (2)
        @retro              Tinyint,    -- retrocession interne O/N : Valeur 1 si Oui
        @monnaie            Tinyint,    -- 1 si monnaie estimation existe et différente monnaie aliment part scor
        @dernier_trait      Datetime,   -- max de cre_d de lifest pour le contrat/section/bilan/exercice
        @cmt_nt             UCMT_NT,    -- commentaire general
        @comac              Bit,        -- Top presence commentaire par AC
        @acy_sup            Smallint,   -- AC bilan + 2
        @acy_inf            Smallint,   -- AC bilan - 4
        @cnatyp_ct          Char(1),    -- type de calcul des CNA
        @cnatyp_ll          UL16,       -- Libelle du type de calcul CNA
        @lag_cf             Char(1),    -- Code langue
        @next_period        Tinyint,    -- Mois de la prochaine periode normale
        @habil_spec         Tinyint,    -- Profil TRT02 avec habilitation spéciale
        @prg_nf             Int,        -- Servira à déterminer s'il s'agit d'un traité non proportionnel
        @lob_char           ULOB_CF,    -- LOB de la section
        @lob_cf             Tinyint,    -- LOB convertie : 1 si Lob '31', 0 sinon
        @EXE_ACCADMTYP_CT   UACCADMTYP_CT  -- type comptable de l'exercice --modif 17

-- Modif 10, Appel de la procedure PSlocktab_01 : Ramène la tête de grappe
execute @erreur = BTEC..PsLOCKTAB_01 @p_CTR_NF, 'EST', @timestamp_grappe output
if @erreur!=0 or @@error!=0 return 1

-- 1 select dans TSECTION :
--   Exercice de souscription le plus récent où l'état de la section est :
--   Accepté (code 14), Définitif (code 16), Renouvelé (code 17), Résilié (code 19)

select @UWY_NF = max(UWY_NF)
from   BTRT..TSECTION
where  CTR_NF     = @p_CTR_NF
and    END_NT     = @p_END_NT
and    UW_NT      = @p_UW_NT
and    SEC_NF     = @p_SEC_NF
and    SECSTS_CT in (14,16,17,19)

select @erreur = @@error
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TCONTR"
        return 1
    end

-- 2 select dans TCONTR : N° de cédante (correspondant au dernier ex de souscription)
--   Modif 3 : Caractérisation Affaire (donnée VIE)

select @CED_NF = CED_NF, @LIFTRTTYP_CF = LIFTRTTYP_CF
from   BTRT..TCONTR
where  CTR_NF = @p_CTR_NF
and    END_NT = @p_END_NT
and    UW_NT  = @p_UW_NT
and    UWY_NF = @UWY_NF

select @erreur = @@error
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TCONTR"
        return 1
    end

-- 3 select dans TCLIENT : Position hiérarchique du client

select @CLISSD_CF = CLISSD_CF
from   BCLI..TCLIENT
where  CLI_NF = @CED_NF

select @erreur = @@error
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TCLIENT"
        return 1
    end

if @CLISSD_CF != null
   select @retro = 1
else
   select @retro = 0

-- 4 select dans TSECTION  (correspondant au dernier ex de souscription)
--   Modif 3 : Etat de la section, Type comptable, Date de résiliation, Garantie,
--             Premier exercice de souscription, Monnaie section

select  @NAT_CF       = NAT_CF,
        @SECSTS_CT    = SECSTS_CT,
        @CTR_NF       = CTR_NF,
        @END_NT       = END_NT,
        @SEC_NF       = SEC_NF,
        @UW_NT        = UW_NT,
        @SEC_NF       = SEC_NF,
        @ACCADMTYP_CT = ACCADMTYP_CT,
        @SECCAN_D     = SECCAN_D,
        @GAR_CF       = GAR_CF,
        @FRSUWY_NF    = FRSUWY_NF,
        @SECACCSTS_CT = SECACCSTS_CT,
        @CUR_CFS      = PCPCUR_CF,      -- zones table TSECTION - monnaie section (base Traité)
        @lob_char     = LOB_CF
from    BTRT..TSECTION
where   CTR_NF = @p_CTR_NF
and     END_NT = @p_END_NT
and     SEC_NF = @p_SEC_NF
and     UW_NT  = @p_UW_NT
and     UWY_NF = @UWY_NF

select @erreur = @@error
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TSECTION"
        return 1
    end

-- Conversion de la LOB
if @lob_char = '31'
    select @lob_cf = 1
else
    select @lob_cf = 0

-- Si type comptable = 1 ou 4, l'état comptable est celui de la section courante

if @ACCADMTYP_CT = 1 or @ACCADMTYP_CT = 4
    begin
        select @SECACCSTS_CT = SECACCSTS_CT
        from   BTRT..TSECTION
        where  CTR_NF = @p_CTR_NF
        and    END_NT = @p_END_NT
        and    SEC_NF = @p_SEC_NF
        and    UW_NT  = @p_UW_NT
        and    UWY_NF = @p_UWY_NF

        select @erreur = @@error
        if @erreur != 0
            begin
                Raiserror 20003 "APPLICATIF;TSECTION"
                return 1
            end
    end

-- 5 select dans TFAMFUNW, Taux d'intêrêt dépôt espèces primes + Taux d'intêrêt dépôt
-- espèces sinistre (correspondant au dernier ex de souscription)

select @CLMFUNINT_R = CLMFUNINT_R,
       @URRFUNINT_R = URRFUNINT_R
from   BTRT..TFAMFUNW
where  CTR_NF = @p_CTR_NF
and    END_NT = @p_END_NT
and    SEC_NF = @p_SEC_NF
and    UW_NT  = @p_UW_NT
and    UWY_NF = @UWY_NF

select @erreur = @@error
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TFAMFUNW"
        return 1
    end

-- 6 select dans BREF..TCALEND, Recherche de la période 'année' et 'mois' en cours
--   (execptionnelle à la date du jour)

select @DATE = getdate(), @TYPPER = 'E'
execute @erreur = BREF..PsCALEND_02 @DATE,@TYPPER,@BLCSHTYEA_NF output,@BLCSHTMTH_NF output,@SPCEND_D output,@ACCOUNT_D output,@CLOSING_B output

if @erreur != 0
    begin
        Raiserror 20005 "APPLICATIF;TACCSUP/TCALEND"
        return @erreur
    end

-- 7 select dans TBLCSHTD : Date de fin de période normale

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
        Raiserror 20003 "APPLICATIF;TBLCSHTD"
        return 1
    end

-- 8 Si date du jour <= Date de fin de période normale @bilan = 1(normal), sinon
--   @bilan = 2(exceptionnel)

if @DATE <= @END_D
    select @bilan = 1
else
    select @bilan = 2

-- 8 bis : Si on est en période exceptionnelle, il faut rechercher si le
--         user a une habilitation spéciale (profil TRT02 avec mention 'EST OUI' )

select @habil_spec = 0

select @habil_spec = 1
from   BREF..TROLES a, BREF..TPROFIL b
where  a.USR_CF   = user
and    a.APP_CF   = 'EST'
and    a.PRF_CF   = 'TRT02'
and    a.APP_CF   = b.APP_CF
and    a.PRF_CF   = b.PRF_CF
and    PRFPAR1_LM = 'EST OUI'

-- 8 ter : Si le paramètre CLOSING_B = 0, il s'agit d'une clôture mensuelle et non
--         trimestrielle. Il n'y a donc pas lieu de bloquer

if @CLOSING_B = 0
    begin
        select @habil_spec = 1
    end

-- 9 Recherche dans BCTA..TBLCSHTD du mois correspondant a la prochaine periode normale
--   La prochaine periode normale est celle qui commence apres la fin de la periode
--   comptable en cours dans TBLCSHTD

select @next_period = 0

select @next_period = isnull(Min(BLCSHTMTH_NF), 0)   -- MOD011 isnull(BLCSHTMTH_NF, 0)
from   BCTA..TBLCSHTD
where  SSD_CF        = @p_SSD_CF
and    ESB_CF        = @p_ESB_CF
and    DIR_CF        = @p_DIR_CF
and    DMN_CF        = @p_DMN_CF
and    BLCSHTYEA_NF  = @BLCSHTYEA_NF
and    STR_D        !< @END_D

select @erreur = @@error
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TBLCSHTD"
        return 1
    end

-- 10 select dans TLIFEST : Monnaie des estimations
--    Maj @monnaie : valeur 1 si la monnaie estimation existe et est différente de
--    la monnaie de la section, valeur 0 sinon                                              */

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
        Raiserror 20003 "APPLICATIF;TLIFEST"
        return 1
    end

if @ligne != 0 and @CUR_CFE != @CUR_CFS
    begin
        select @CUR_CF  = @CUR_CFE,
               @monnaie = 1
    end
else
    begin
        select @CUR_CF  = @CUR_CFS,
               @monnaie = 0
    end

-- 11 select dans TLIFEST, date de dernier traitement, max de cre_d dans TLIFEST pour
--    le contrat, la section passés en parametre le bilan calcule et exercice passe en
--    parametre (pas le dernier exercice)
--    on retire de la selection les estimations crees par les arretes statistiques
--    (heure de cre_d = 23:59:59)                                                            */
--    Modif GIBU le 03/02/2004 : on ne garde que les estimations passees avant 23:59
--    Modif GIBU le 25/05/2005 : Fiche Spot 10305, il n'y aplus de relation
--                               sur l'exercice pour les types 1 et 4

if @ACCADMTYP_CT = 1 or @ACCADMTYP_CT = 4
    begin
        select @dernier_trait = max(CRE_D)
        from   BEST..TLIFEST
        where  CTR_NF                      = @p_CTR_NF
        and    END_NT                      = @p_END_NT
        and    SEC_NF                      = @p_SEC_NF
        and    UW_NT                       = @p_UW_NT
        and    BALSHEY_NF                  = @BLCSHTYEA_NF
        and    convert(char(5), CRE_D, 8) != '23:59'
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
        and    convert(char(5), CRE_D, 8) != '23:59'
    end

select @erreur = @@error, @ligne = @@rowcount
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TLIFEST"
        return 1
    end

-- 12 select dans TLIFDRI, Commentaire general

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
                         where  a.CTR_NF     = b.CTR_NF
                         and    a.END_NT       = b.END_NT
                         and    a.SEC_NF       = b.SEC_NF
                         and    a.UW_NT        = b.UW_NT
                         and    a.UWY_NF       = b.UWY_NF
                         and    b.BALSHEY_NF   = 1900
                         and    b.BALSHTMTH_NF = 1
                         and    b.ACY_NF       = 1900)

select @erreur = @@error, @ligne = @@rowcount
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TLIFDRI"
        return 1
    end

-- 13 select dans TLIFDRI, Top presence commentaires par AC

select @acy_sup = @blcshtyea_nf + 2, @acy_inf = @blcshtyea_nf - 4

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
    select @comac = 1
else
    select @comac = 0

-- 14 select dans TCONTR (exercice parametre) du type de calcul des CNA et de son
-- libelle dans BREF..TBANTECL

select @lag_cf = @p_LANGUE

select @cnatyp_ct = a.CNATYP_CT,
       @cnatyp_ll = b.COLVAL_LS
from   BTRT..TCONTR a, BREF..TBANTECL b
where  a.CTR_NF    = @p_CTR_NF
and    a.END_NT    = @p_END_NT
and    a.UW_NT     = @p_UW_NT
and    a.UWY_NF    = @p_UWY_NF
and    a.CNATYP_CT = b.colval_ct
and    b.COL_LS    = 'CNATYP_CT'
and    b.LAG_CF    = @lag_cf

select @erreur = @@error
if @erreur != 0
    begin
        Raiserror 20003 "APPLICATIF;TCONTR/TBANTECL"
        return 1
    end

-- Temporairement on initialise le mode de calcul en fonction de la filiale
if @p_SSD_CF = 14
    begin
        select @cnatyp_ct = '3',
               @cnatyp_ll = 'Manuel 2'
    end

-- Recherche du programme pour déterminer s'il s'agit d'un traité non proportionnel
select @prg_nf=isnull(Len(Rtrim(Ltrim(PRG_NF))), 0)
 from BTRT..TCONTR
  where CTR_NF=@p_CTR_NF
    and END_NT=@p_END_NT
    and UW_NT=@p_UW_NT
    and UWY_NF=@UWY_NF -- modif 15
select @erreur = @@error
if @erreur != 0
begin
  Raiserror 20003 "APPLICATIF;TCONTR/TBANTECL"
  return 1
end

--modif 15
select @EXE_ACCADMTYP_CT=ACCADMTYP_CT from BTRT..TSECTION where CTR_NF=@P_CTR_NF and UWY_NF=@P_UWY_NF and SEC_NF=@p_SEC_NF
if @EXE_ACCADMTYP_CT=null select @EXE_ACCADMTYP_CT=@ACCADMTYP_CT

-- 15 select final
select  CTR_NF           = @CTR_NF,
        END_NT           = @END_NT,
        SEC_NF           = @SEC_NF,
        UW_NT            = @UW_NT,
        UWY_NF           = @UWY_NF,
        ACCADMTYP_CT     = @ACCADMTYP_CT,
        SECCAN_D         = @SECCAN_D,
        GAR_CF           = @GAR_CF,
        FRSUWY_CF        = @FRSUWY_NF,
        SECACCSTS_CT     = @SECACCSTS_CT,
        CLMFUNINT_R      = @CLMFUNINT_R * 100,
        URRFUNINT_R      = @URRFUNINT_R * 100,
        BLCSHTYEA_NF     = @BLCSHTYEA_NF,
        BLCSHTMTH_NF     = @BLCSHTMTH_NF,
        CUR_CF           = @CUR_CF,
        SECSTS_CT        = @SECSTS_CT,
        NAT_CF           = @NAT_CF,
        LIFTRTTYP_CF     = @LIFTRTTYP_CF,
        BILAN            = @bilan,
        RETRO            = @retro,
        MONNAIE          = @monnaie,
        VISU_YEA         = 0,
        VISU_MTH         = 0,
        EXERCICE         = 0,
        VAL_EXERCICE     = 0,
        DERNIER_TRAIT    = @dernier_trait,
        CMT_NT           = @cmt_nt,
        COMAC            = @comac,
        CNATYP_CT        = @cnatyp_ct,
        CNATYP_LL        = @cnatyp_ll,
        NEXT_PERIOD      = @next_period,
        TIMESTAMP_GRAPPE = @timestamp_grappe,
        HABIL_SPEC       = @habil_spec,
        PRG_NF           = @prg_nf,
        LOB_CF           = @lob_cf,
        EXE_ACCADMTYP_CT = @EXE_ACCADMTYP_CT

return 0
go

if object_id('dbo.PsLIFEST_01') is not null
  print '<<< CREATED PROC dbo.PsLIFEST_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsLIFEST_01 >>>'
go

grant execute on dbo.PsLIFEST_01 TO GOMEGA
go
