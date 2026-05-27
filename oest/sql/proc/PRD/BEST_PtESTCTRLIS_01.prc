use BEST
go
if object_id('PtESTCTRLIS_01') is not null
begin
  drop PROC PtESTCTRLIS_01
  print '<<< DROPPED PROC PtESTCTRLIS_01 >>>'
end
go
create procedure PtESTCTRLIS_01
(
@p_updulttyp_ct char(1),  -- type de mise à jour des ultimes ( 'Q': quotidien ou 'R': reprise )
@p_clodat_d     datetime  -- libellé d'inventaire                                              
)
with execute as caller as
/***************************************************
Programme:                  PtESTCTRLIS_01
Fichier script associé :    ESTCTR01.PRC
Domaine :                   (ES) Estimation
Base principale :           BEST
Version:                    1
Auteur:                     M.HA-THUC avec Infotool version 2.0 (AUTO)
Date de creation:           17/06/97
Description du programme:   - Constitution de la liste des affaires à partir des listes
                              ( traités avec mouvement comptable, traités avec saisie d'assiette définitive, traités avec mise à jour des comptes complet )
                            - Enrichissement de la liste des affaires ( facultatives, proportionnels, non proportionnels )
                            - Mise à jour de la PMD dans la liste des affaires
                            - Conversion des montants devise assiette en devise aliment
_________________
MODIFICATION 1
Auteur:     HA-THUC
Date:       15/09/97
Description: ajout monnaie d'engagement
_________________
MODIFICATION 2
Auteur:     HA-THUC
Date:       09/10/98
Description: - en mode reprise ( @p_updulttyp_ct = 'R' ), on récupère maintenant des affaires dans la table BEST..TSBJPRM.
_________________
MODIFICATION 2
13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
_________________
MODIFICATION 3 (MOD03)
Auteur : Dominique Ourmiah
Date : 25/05/2009
Description :  SPOT 17432 plantage ESEJ1000 sur des traités Vie (lob 30 ou 31).
                  La suppression des lobs 30 et 31 (vie) existait déja mais était placée à la fin de la proc.
                  Elle est maintenant placée juste après les insert/update de la table BTRAV..TESTCTRLIS.
_________________
MODIFICATION    [004]
Auteur:         D.GATIBELZA
Date:           07/12/2009
Description:    ESTDOM15043 Ultimes  Revisions des regles de gestion et corrections de l'écran estimation des ultimes
                - Mise aux normes de la table BTRAV TESTCTRULT devient : BTRAV..EST_ULT_ESEJ1000_TCTRULT
[005] 08/02/2013 R. Cassis :spot:24833 Optimisation requete ctr/acy/mois comptable
_________________
Modification - Removed dbo and added ‘with execute as caller as’
_______________
MODIFICATION [005]
Auteur: KBagwe
Date: 11/10/2013
Description:  Phase1b: Removed LIKE from condition and modified with bfac..Tcontr.
[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
[101] 19/05/2014 R. Cassis   :spot:26775  - Autres modifs Omega2 - 1b gestion site - gestion Ultimes
8     20/11/2014 Florent     :spot:27747 - ajout multi-devise
*****************************************************/
declare @erreur      int
select @erreur = 0

/* ------------------------------------------------------------
   Création des tables temporaires
 -------------------------------------------------------------- */
create table #TCONTRAT (
    CTR_NF      UCTR_NF     NOT null
)

create table #TCOMPLET (
    CTR_NF      UCTR_NF     NOT null,
    UWY_NF      UUWY_NF     NOT null,
    UW_NT       UUW_NT      NOT null,
    END_NT      UEND_NT     NOT null,
    SEC_NF      USEC_NF     NOT null,
    EVTCOD_NF   tinyint     NOT null
)

create table #TCPLACC1 (
    CTR_NF      UCTR_NF     NOT null,
    ACY_NF      smallint        null,
    SCOENDMTH_NF tinyint        null
)

create table #TCPLACC2 (
    CTR_NF      UCTR_NF     NOT null,
    ACY_NF      smallint        null,
    SCOENDMTH_NF tinyint        null
)

create table #TCONVERSION1 (
    CTR_NF      UCTR_NF     NOT null,
    UWY_NF      UUWY_NF     NOT null,
    UW_NT       UUW_NT      NOT null,
    END_NT      UEND_NT     NOT null,
    SEC_NF      USEC_NF     NOT null,
    SSD_CF      USSD_CF     NOT null,
    EGPCUR_CF   UCUR_CF     NOT null,
    EXCEGP_R    ULNGDEC         null,
    SBJPRMCUR_CF UCUR_CF    NOT null,
    EXCSBJ_R    ULNGDEC         null
)

create table #TCONVERSION2 (
    CTR_NF      UCTR_NF     NOT null,
    UWY_NF      UUWY_NF     NOT null,
    UW_NT       UUW_NT      NOT null,
    END_NT      UEND_NT     NOT null,
    SEC_NF      USEC_NF     NOT null,
    SSD_CF      USSD_CF     NOT null,
    EGPCUR_CF   UCUR_CF     NOT null,
    EXCEGP_R    ULNGDEC         null,
    LIACUR_CF   UCUR_CF     NOT null,
    EXCLIA_R    ULNGDEC         null
)

--[101]
declare @site_cf        varchar(10)
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()

execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output


if @erreur != 0
  begin
      raiserror 20005 "APPLICATIF;PsSITE_01" /* erreur de lecture */
      return @erreur
  end


/* ------------------------------------------------------------
   Reinitialisation des tables de travail
 -------------------------------------------------------------- */
truncate table BTRAV..TESTCTRLIS
truncate table BTRAV..TESTPMDCTR
truncate table BTRAV..TESTRECPAR
truncate table BTRAV..EST_ULT_ESEJ1000_TCTRULT  --[004] BTRAV..TESTCTRULT
truncate table BTRAV..TESTTRSLNK
truncate table BTRAV..TESTUW
truncate table BTRAV..TESTCPLAMT
truncate table BTRAV..TESTRMD


/* ------------------------------------------------------------
   Constitution de la liste des affaires avec mouvement comptable
 -------------------------------------------------------------- */
insert into BTRAV..TESTCTRLIS (CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, EVTCOD_NF)
select CTR_NF,
       UWY_NF,
       UW_NT,
       END_NT,
       SEC_NF,
       1
from BEST..TCTRACC acc
where exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where acc.CTR_NF   = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)
and   not exists ( select CTR_NF
                  from BTRAV..TESTCTRLIS D
                  where acc.CTR_NF = D.CTR_NF
                    and acc.UWY_NF = D.UWY_NF
                    and acc.UW_NT  = D.UW_NT
                    and acc.END_NT = D.END_NT
                    and acc.SEC_NF = D.SEC_NF )

select @erreur = @@error
if @erreur != 0
    goto fin


/* ------------------------------------------------------------
   Liste des traites avec saisie d'assiette definitive
--------------------------------------------------------------- */
insert into BTRAV..TESTCTRLIS (CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, EVTCOD_NF)
select A.CTR_NF,
       A.UWY_NF,
       A.UW_NT,
       A.END_NT,
       A.SEC_NF,
       2
from BEST..TSBJPRM A, BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr
where ctr.SSD_CF  = batchssd.SSD_CF
and   BATCHUSER_CF = @suser_Name
and   A.CTR_NF    = ctr.CTR_NF
and   not exists ( select CTR_NF
                   from BTRAV..TESTCTRLIS B
                   where A.CTR_NF = B.CTR_NF
                     and A.UWY_NF = B.UWY_NF
                     and A.UW_NT = B.UW_NT
                     and A.END_NT = B.END_NT
                     and A.SEC_NF = B.SEC_NF )

select @erreur = @@error
if @erreur != 0
    goto fin


/* -------------------------------------------------------------------
   Liste des traités avec mise à jour des comptes complets
---------------------------------------------------------------------*/
if ( @p_updulttyp_ct = 'Q' )
begin

    declare @datemodif datetime

    /* recherche de la derniere date de mise a jour des ultimes */
    select @datemodif = LAUNCH_D
    from BEST..TREQJOB
    where REQCOD_CT = 'U'
    and   SITE_CF   = @site_cf

    /* si pas de ligne ( chaîne non lancee ) @datemodif positionnee a 1997/10/29 */
    if @@rowcount = 0
        select @datemodif = "19971029"


    insert into #TCONTRAT
    select distinct CTR_NF
    from BCTA..TCPLACC tplacc, BREF..TBATCHSSD batchssd
    where tplacc.SSD_CF    = batchssd.SSD_CF
    and   LSTUPD_D         > @datemodif
    and   batchssd.BATCHUSER_CF = @suser_Name

    select @erreur = @@error
    if @erreur != 0
        goto fin


    insert into #TCOMPLET
    select A.CTR_NF,
           A.UWY_NF,
           A.UW_NT,
           A.END_NT,
           A.SEC_NF,
           EVTCOD_NF = 3
    from BTRT..TSECTION A, #TCONTRAT B
    where SECSTS_CT in (14, 16, 17, 19)
      and lob_cf not in ('30','31')
      and A.CTR_NF = B.CTR_NF

    select @erreur = @@error
    if @erreur != 0
        goto fin


    insert into BTRAV..TESTCTRLIS (CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, EVTCOD_NF)
    select CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, EVTCOD_NF
    from #TCOMPLET C
    where not exists ( select CTR_NF
                       from BTRAV..TESTCTRLIS D
                       where C.CTR_NF = D.CTR_NF
                         and C.UWY_NF = D.UWY_NF
                         and C.UW_NT  = D.UW_NT
                         and C.END_NT = D.END_NT
                         and C.SEC_NF = D.SEC_NF )

    select @erreur = @@error
    if @erreur != 0
        goto fin
end


/* -------------------------------------------------------------------
   Enrichissement de la liste des affaires avec les traites Facultatifs
---------------------------------------------------------------------*/
/* Ne pas mettre a jour pour les facs  --[101]
update BTRAV..TESTCTRLIS
  set A.DIV_NT = C.DIV_NT,
      A.SECLAB_LM = C.SECLAB_LM,
      A.SSD_CF = C.SSD_CF,
      A.CTRNAT_CT = "F",
      A.ESTUPDTYP_CT = C.ESTUPDTYP_CT,
      A.SECACCSTS_CT = C.SECACCSTS_CT,
      A.LOB_CF = C.LOB_CF,
      A.SOB_CF = C.SOB_CF,
      A.PCPRSKTRY_CF = C.PCPRSKTRY_CF,
      A.ACCADMTYP_CT = C.ACCADMTYP_CT
from BTRAV..TESTCTRLIS A, BFAC..TSECTION C
where C.CTR_NF = A.CTR_NF
  and C.UWY_NF = A.UWY_NF
  and C.UW_NT = A.UW_NT
  and C.END_NT = A.END_NT
  and C.SEC_NF = A.SEC_NF

select @erreur = @@error
if @erreur != 0
    goto fin


update BTRAV..TESTCTRLIS
   set A.SCOGLOEGP_M = D.SCOGLOEGP_M,
       A.EGPCUR_CF = D.EGPCUR_CF
from BTRAV..TESTCTRLIS A, BFAC..TFAMLIA D
where D.CTR_NF = A.CTR_NF
  and D.UWY_NF = A.UWY_NF
  and D.UW_NT = A.UW_NT
  and D.END_NT = A.END_NT
  and D.SEC_NF = A.SEC_NF

select @erreur = @@error
if @erreur != 0
    goto fin


update BTRAV..TESTCTRLIS
   set A.UWRSPUSR_CF = B.UWRSPUSR_CF,
       A.ADMUSR_CF = B.ADMUSR_CF,
       A.EXP_D = B.CTREXP_D
from BTRAV..TESTCTRLIS A, BFAC..TCONTR B
where B.CTR_NF = A.CTR_NF
  and B.UWY_NF = A.UWY_NF
  and B.UW_NT  = A.UW_NT
  and B.END_NT = A.END_NT

select @erreur = @@error
if @erreur != 0
    goto fin
*/

/* -------------------------------------------------------------------
 Enrichissement de la liste des affaires avec les traites proportionnels
---------------------------------------------------------------------*/
update BTRAV..TESTCTRLIS
   set A.SECLAB_LM = B.SECLAB_LM,
       A.SSD_CF = B.SSD_CF,
       A.CTRNAT_CT = "P",
       A.ESTUPDTYP_CT = B.ESTUPDTYP_CT,
       A.SECACCSTS_CT = B.SECACCSTS_CT,
       A.ESTEND_B = B.ESTEND_B,
       A.LOB_CF = B.LOB_CF,
       A.SOB_CF = B.SOB_CF,
       A.PCPRSKTRY_CF = B.PCPRSKTRY_CF,
       A.ACCADMTYP_CT = B.ACCADMTYP_CT
from BTRAV..TESTCTRLIS A, BTRT..TSECTION B
where B.CTR_NF = A.CTR_NF
  and B.UWY_NF = A.UWY_NF
  and B.UW_NT = A.UW_NT
  and B.END_NT = A.END_NT
  and B.SEC_NF = A.SEC_NF
  and B.NAT_CF < "30"
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

select @erreur = @@error
if @erreur != 0
    goto fin


update BTRAV..TESTCTRLIS
  set A.SCOORGEGP_M = C.SCOORGEGP_M,
      A.SCOGLOEGP_M = C.SCOGLOEGP_M,
      A.PMLRAT_R = C.PMLRAT_R,
      A.EGPCUR_CF = C.EGPCUR_CF,
      A.CUTSHA_R = C.CUTSHA_R,
      A.RIDSHA_R = C.RIDSHA_R,
      A.LIARIDSHA_B = C.LIARIDSHA_B,
      A.SCOEGPCAL_B = C.SCOEGPCAL_B,
      A.EGPLESSCO_M = C.EGPLESSCO_M
from BTRAV..TESTCTRLIS A, BTRT..TFAMLIA C
where C.CTR_NF = A.CTR_NF
  and C.UWY_NF = A.UWY_NF
  and C.UW_NT = A.UW_NT
  and C.END_NT = A.END_NT
  and C.SEC_NF = A.SEC_NF
  and A.CTRNAT_CT = "P"
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

select @erreur = @@error
if @erreur != 0
    goto fin


update BTRAV..TESTCTRLIS
   set A.UWRSPUSR_CF = D.UWRSPUSR_CF,
       A.ADMUSR_CF = D.ADMUSR_CF
from BTRAV..TESTCTRLIS A, BTRT..TCONTR D
where D.CTR_NF = A.CTR_NF
  and D.UWY_NF = A.UWY_NF
  and D.UW_NT  = A.UW_NT
  and D.END_NT = A.END_NT
  and A.CTRNAT_CT = "P"
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

select @erreur = @@error
if @erreur != 0
    goto fin


/* -------------------------------------------------------------------
 Enrichissement de la liste des affaires avec les traites non proportionnels
---------------------------------------------------------------------*/
update BTRAV..TESTCTRLIS
   set A.SECLAB_LM = B.SECLAB_LM,
       A.SSD_CF = B.SSD_CF,
       A.CTRNAT_CT = "N",
       A.ESTUPDTYP_CT = B.ESTUPDTYP_CT,
       A.SECACCSTS_CT = B.SECACCSTS_CT,
       A.LOB_CF = B.LOB_CF,
       A.SOB_CF = B.SOB_CF,
       A.PCPRSKTRY_CF = B.PCPRSKTRY_CF,
       A.ACCADMTYP_CT = B.ACCADMTYP_CT
from BTRAV..TESTCTRLIS A, BTRT..TSECTION B
where B.CTR_NF = A.CTR_NF
  and B.UWY_NF = A.UWY_NF
  and B.UW_NT  = A.UW_NT
  and B.END_NT = A.END_NT
  and B.SEC_NF = A.SEC_NF
  and B.NAT_CF >= "30"
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

select @erreur = @@error
if @erreur != 0  goto fin


update BTRAV..TESTCTRLIS
   set A.SCOORGEGP_M = C.SCOORGEGP_M,
       A.SCOGLOEGP_M = C.SCOGLOEGP_M,
       A.PMLRAT_R = C.PMLRAT_R,
       A.EGPCUR_CF = C.EGPCUR_CF,
       A.CUTSHA_R = C.CUTSHA_R,
       A.RIDSHA_R = C.RIDSHA_R,
       A.LIARIDSHA_B = C.LIARIDSHA_B,
       A.SCOEGPCAL_B = C.SCOEGPCAL_B,
       A.EGPLESSCO_M = C.EGPLESSCO_M,
       A.REIEXI_B = C.REIEXI_B,
       A.REIUNL_B = C.REIUNL_B,
       A.REIFRE_B = C.REIFRE_B,
       A.REINBR_N = C.REINBR_N,
       A.LAYCAP_M = C.LAYCAP_M,
       A.LIACUR_CF = C.LIACUR_CF
from BTRAV..TESTCTRLIS A, BTRT..TFAMLIA C
where C.CTR_NF = A.CTR_NF
  and C.UWY_NF = A.UWY_NF
  and C.UW_NT = A.UW_NT
  and C.END_NT = A.END_NT
  and C.SEC_NF = A.SEC_NF
  and A.CTRNAT_CT = "N"
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

select @erreur = @@error
if @erreur != 0
    goto fin


update BTRAV..TESTCTRLIS
   set A.UWRSPUSR_CF = D.UWRSPUSR_CF,
       A.ADMUSR_CF = D.ADMUSR_CF
from BTRAV..TESTCTRLIS A, BTRT..TCONTR D
where D.CTR_NF = A.CTR_NF
  and D.UWY_NF = A.UWY_NF
  and D.UW_NT = A.UW_NT
  and D.END_NT = A.END_NT
  and A.CTRNAT_CT = "N"
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

select @erreur = @@error
if @erreur != 0
    goto fin


update BTRAV..TESTCTRLIS
   set A.PRMFLCRAT_B = E.PRMFLCRAT_B,
       A.PRMFIXEFF_R = E.PRMFIXEFF_R,
       A.PRMMINEFF_R = E.PRMMINEFF_R,
       A.PRMMAXEFF_R = E.PRMMAXEFF_R,
       A.SUPLOATYP_CT = E.SUPLOATYP_CT,
       A.PRMEFFLOA_M = E.PRMEFFLOA_M,
       A.PRMEFFLOA_R = E.PRMEFFLOA_R,
       A.SBJPRMCUR_CF = E.SBJPRMCUR_CF,
       A.ESTSBJPRM_M = E.ESTSBJPRM_M,
       A.DEFSBJPRM_M = E.DEFSBJPRM_M,
       A.SBJPRMCPT_M = E.SBJPRMCPT_M,
       A.FLAPRM_B = E.FLAPRM_B,
       A.SBJCPTDEF_B = E.SBJCPTDEF_B
from BTRAV..TESTCTRLIS A, BTRT..TFAMCOTP E
where E.CTR_NF = A.CTR_NF
  and E.UWY_NF = A.UWY_NF
  and E.UW_NT  = A.UW_NT
  and E.END_NT = A.END_NT
  and E.SEC_NF = A.SEC_NF
  and A.CTRNAT_CT = "N"
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

select @erreur = @@error
if @erreur != 0
    goto fin


/* MOD03 */
/* -------------------------------------------------------------------
   Suppression des lignes de la liste avec les Lob 30 et 31
---------------------------------------------------------------------*/
delete BTRAV..TESTCTRLIS
where LOB_CF = "30"
   or LOB_CF = "31"

select @erreur = @@error
if @erreur != 0
    goto fin


/* ----------------------------------------------------------------------------
    Extraction des affaires dont Prime provisionnelle? = 1
   ---------------------------------------------------------------------------- */
insert into BTRAV..TESTPMDCTR ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, SSD_CF, EGPCUR_CF,
                                MINPRVPR1_M, PRVPRMCU1_CF, MINPRVPR2_M, PRVPRMCU2_CF,MINPRVPR3_M, PRVPRMCU3_CF,MINPRVPR4_M, PRVPRMCU4_CF,MINPRVPR5_M, PRVPRMCU5_CF )
select A.CTR_NF,
       A.UWY_NF,
       A.UW_NT,
       A.END_NT,
       A.SEC_NF,
       A.SSD_CF,
       A.EGPCUR_CF,
       E.MINPRVPR1_M,
       E.PRVPRMCU1_CF,
       E.MINPRVPR2_M,
       E.PRVPRMCU2_CF,
       E.MINPRVPR3_M,
       E.PRVPRMCU3_CF,
       E.MINPRVPR4_M,
       E.PRVPRMCU4_CF,
       E.MINPRVPR5_M,
       E.PRVPRMCU5_CF
from BTRAV..TESTCTRLIS A, BTRT..TFAMCOTP E
where E.CTR_NF = A.CTR_NF
  and E.UWY_NF = A.UWY_NF
  and E.UW_NT = A.UW_NT
  and E.END_NT = A.END_NT
  and E.SEC_NF = A.SEC_NF
  and A.CTRNAT_CT = "N"
  and E.PRVPRM_B = 1
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

select @erreur = @@error
if @erreur != 0
    goto fin


/* ---------------------------------------------------------------------------------
   Alimentation de la table des paramètres de reconstitution
   ---------------------------------------------------------------------------------*/
insert into BTRAV..TESTRECPAR
select A.CTR_NF,
       A.UWY_NF,
       A.UW_NT,
       A.END_NT,
       A.SEC_NF,
       F.REILIN_NT,
       F.REIRNK_N,
       F.REIPRMBAS_R,
       REIPRM_M,
       REIPRM_R,
       REIPROTMP_B
from BTRAV..TESTCTRLIS A, BTRT..TFAMREI F
where F.CTR_NF = A.CTR_NF
  and F.UWY_NF = A.UWY_NF
  and F.UW_NT  = A.UW_NT
  and F.END_NT = A.END_NT
  and F.SEC_NF = A.SEC_NF
  and A.CTRNAT_CT = "N"
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

select @erreur = @@error
if @erreur != 0
    goto fin


/* -------------------------------------------------------------------
   Mise à jour de la PMD dans la liste des affaires
---------------------------------------------------------------------*/
update  BTRAV..TESTPMDCTR
   set A.EXCEGP_R = B.EXC_R
from BTRAV..TESTPMDCTR A, BTRAV..TSTASTAQUOT B
where A.SSD_CF = B.SSD_CF
  and A.EGPCUR_CF = B.CUR_CF
  and A.UWY_NF - 1 = B.EXC_y

select @erreur = @@error
if @erreur != 0
    goto fin


update BTRAV..TESTPMDCTR
   set A.EXCPR1_R = B.EXC_R
from BTRAV..TESTPMDCTR A, BTRAV..TSTASTAQUOT B
where A.SSD_CF = B.SSD_CF
  and A.PRVPRMCU1_CF = B.CUR_CF
  and A.UWY_NF - 1 = B.EXC_y

select @erreur = @@error
if @erreur != 0
    goto fin


update  BTRAV..TESTPMDCTR
   set A.EXCPR2_R = B.EXC_R
from BTRAV..TESTPMDCTR A, BTRAV..TSTASTAQUOT B
where A.SSD_CF = B.SSD_CF
  and A.PRVPRMCU2_CF = B.CUR_CF
  and A.UWY_NF - 1 = B.EXC_y

select @erreur = @@error
if @erreur != 0
    goto fin

update BTRAV..TESTPMDCTR
 set A.EXCPR3_R = B.EXC_R
  from BTRAV..TESTPMDCTR A, BTRAV..TSTASTAQUOT B
   where A.SSD_CF = B.SSD_CF
     and A.PRVPRMCU3_CF = B.CUR_CF
     and A.UWY_NF - 1 = B.EXC_y
select @erreur = @@error
if @erreur != 0 goto fin

update BTRAV..TESTPMDCTR
 set A.EXCPR4_R = B.EXC_R
  from BTRAV..TESTPMDCTR A, BTRAV..TSTASTAQUOT B
   where A.SSD_CF = B.SSD_CF
     and A.PRVPRMCU4_CF = B.CUR_CF
     and A.UWY_NF - 1 = B.EXC_y
select @erreur = @@error
if @erreur != 0 goto fin

update BTRAV..TESTPMDCTR
 set A.EXCPR5_R = B.EXC_R
  from BTRAV..TESTPMDCTR A, BTRAV..TSTASTAQUOT B
   where A.SSD_CF = B.SSD_CF
     and A.PRVPRMCU5_CF = B.CUR_CF
     and A.UWY_NF - 1 = B.EXC_y
select @erreur = @@error
if @erreur != 0 goto fin

/* appelle de la procédure stockée PtESTCTRLIS_05 */
exec BEST..PtESTCTRLIS_05


/* -------------------------------------------------------------------
   Recherche de la dernière période de compte complet par affaire
---------------------------------------------------------------------*/
--[005] Ajout distinct
insert into #TCPLACC2
select distinct B.CTR_NF, B.ACY_NF, B.SCOENDMTH_NF
from BTRAV..TESTCTRLIS A, BCTA..TCPLACC B
where A.CTR_NF = B.CTR_NF
  and A.CTRNAT_CT <> "F"
  and B.BLCSHT_D <= @p_clodat_d
  and exists (select 1 from BREF..TBATCHSSD batchssd, BTRT..TCONTR ctr  --(101]
              where A.CTR_NF     = ctr.CTR_NF
              and   ctr.SSD_CF   = batchssd.SSD_CF
              and   BATCHUSER_CF = @suser_Name)

insert into #TCPLACC1
select CTR_NF, ACY_NF, SCOENDMTH_NF
from #TCPLACC2
group by CTR_NF
having ACY_NF*100 + SCOENDMTH_NF = max( ACY_NF*100 + SCOENDMTH_NF )
order by CTR_NF

select @erreur = @@error
if @erreur != 0
    goto fin


/* creation d'un index sur la table temporaire #TCPLACC1 */
create index ICPLACC1 on #TCPLACC1 ( CTR_NF )


/* appelle de la procédure stockée PtESTCTRLIS_02 */
exec BEST..PtESTCTRLIS_02


/* -------------------------------------------------------------------
   Conversion montant devise assiette en devise aliment
---------------------------------------------------------------------*/
insert into #TCONVERSION1 ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, SSD_CF, EGPCUR_CF, SBJPRMCUR_CF )
select CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, SSD_CF, EGPCUR_CF, SBJPRMCUR_CF
from BTRAV..TESTCTRLIS
where CTRNAT_CT = "N"
/*    and EGPCUR_CF <> SBJPRMCUR_CF FCharles le 29/01/2001 */

select @erreur = @@error
if @erreur != 0
    goto fin


update #TCONVERSION1
   set A.EXCEGP_R = B.EXC_R
from #TCONVERSION1 A, BTRAV..TSTASTAQUOT B
where A.SSD_CF = B.SSD_CF
  and A.EGPCUR_CF = B.CUR_CF
  and A.UWY_NF - 1 = B.EXC_y

select @erreur = @@error
if @erreur != 0
    goto fin


update #TCONVERSION1
   set A. EXCSBJ_R = B.EXC_R
from #TCONVERSION1 A, BTRAV..TSTASTAQUOT B
where A.SSD_CF = B.SSD_CF
  and A.SBJPRMCUR_CF = B.CUR_CF
  and A.UWY_NF - 1 = B.EXC_y

select @erreur = @@error
if @erreur != 0
    goto fin


/* creation d'un index sur la table temporaire #TCONVERSION1 */
create index ICONVERSION1 on #TCONVERSION1
    ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF )


/* appelle de la procédure stockée PtESTCTRLIS_03 */
exec BEST..PtESTCTRLIS_03


/* -------------------------------------------------------------------
   Conversion montant portée en devise aliment
---------------------------------------------------------------------*/
insert into #TCONVERSION2 ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF, SSD_CF, EGPCUR_CF, LIACUR_CF )
select CTR_NF,
       UWY_NF,
       UW_NT,
       END_NT,
       SEC_NF,
       SSD_CF,
       EGPCUR_CF,
       LIACUR_CF
from BTRAV..TESTCTRLIS
where CTRNAT_CT = "N"
/*    and EGPCUR_CF <> LIACUR_CF  FCharles le 29/01/2001 */

select @erreur = @@error
if @erreur != 0
    goto fin


update #TCONVERSION2
   set A.EXCEGP_R = B.EXC_R
from #TCONVERSION2 A, BTRAV..TSTASTAQUOT B
where A.SSD_CF = B.SSD_CF
  and A.EGPCUR_CF = B.CUR_CF
  and A.UWY_NF - 1 = B.EXC_y

select @erreur = @@error
if @erreur != 0
    goto fin


update #TCONVERSION2
   set A. EXCLIA_R = B.EXC_R
from #TCONVERSION2 A, BTRAV..TSTASTAQUOT B
where A.SSD_CF = B.SSD_CF
  and A.LIACUR_CF = B.CUR_CF
  and A.UWY_NF - 1 = B.EXC_y

select @erreur = @@error
if @erreur != 0
    goto fin


/* creation d'un index sur la table temporaire #TCONVERSION2 */
create index ICONVERSION2 on #TCONVERSION2
    ( CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF )


/* appelle de la procédure stockée PtESTCTRLIS_04 */
exec BEST..PtESTCTRLIS_04


/********************************************************/
/* Modification provisoire du 27/08/98 - M.HA-THUC      */
/* Les affaires de la filiale 10 (New-York) sont        */
/* provisoirement supprimées du traitement.             */
/* Elles seront réinjectées après la reprise complète   */
/* des GT pour cette filiales                           */
/********************************************************/

/* Mise en prod a new-york 03/05/1999 */
/*
delete  BTRAV..TESTCTRLIS
where   SSD_CF = 10
*/

/* FCharles le 19/02/2001 */
delete BTRAV..TESTCTRLIS
where Exists(select 1 from bfac..Tcontr tcon where tcon.Ctr_Nf = BTRAV..TESTCTRLIS.ctr_nf and
 tcon.UWY_NF = BTRAV..TESTCTRLIS.UWY_NF and tcon.UW_NT = BTRAV..TESTCTRLIS.UW_NT and tcon.END_NT = BTRAV..TESTCTRLIS.END_NT)      --MOD005
select @erreur = @@error
if @erreur != 0
    goto fin
/**********************************************************************************/
/* ------------------------------------------------------------
   Suppression des tables temporaires
 -------------------------------------------------------------- */
drop table #TCONTRAT
drop table #TCPLACC1
drop table #TCOMPLET
drop table #TCONVERSION1
drop table #TCONVERSION2
return 0

fin:
return 1
go
if object_id('dbo.PtESTCTRLIS_01') is not null
  print '<<< CREATED procedure dbo.PtESTCTRLIS_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PtESTCTRLIS_01 >>>'
go
grant execute on dbo.PtESTCTRLIS_01 TO GOMEGA
go
grant execute on dbo.PtESTCTRLIS_01 TO GDBBATCH
go
