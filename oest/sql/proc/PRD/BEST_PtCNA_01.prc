use BEST
go

IF OBJECT_ID('PtCNA_01') IS NOT NULL
BEGIN
    DROP PROCEDURE PtCNA_01
    IF OBJECT_ID('PtCNA_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE PtCNA_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE PtCNA_01 >>>'
END
go
create procedure PtCNA_01
     (
       @p_CLODAT_D    Datetime,
       @p_CRE_D       Datetime,
       @p_MONTH       int

     )
with execute as caller as

/***************************************************

Programme: PtCNA_01

Fichier script associé : BEST_PtCNA_01.prc


Domaine : (est) Estimation

Base principale : BEST

Version: 1

Auteur: ME57

Date de creation:

Description du programme: Calcul des CNA (Commissions non amorties)

Parametres:

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur:  ME57

Date:    12/05/2003

Version:

Description: Pour les prévisions entrées sur des exercices qui n'existent
             pas encore en soucription il faut prendre les taux de CNA
             correspondant à l'exercice max pour la section et le contrat
             qui a un status comptabilisable (max uwy_nf de btrt..tsection
             avec secsts_ct in (14,16,17,19)).
_________________
MODIFICATION 2

Auteur:  ME57

Date:    13/06/2003

Version:

Description:   Ajout du test si exercice introuvable dans la TFAMCNA.
_________________
MODIFICATION 3

Auteur:  ME57

Date:    01/07/2003

Version:

Description: Ajout de 2 colonnes dans la tble des cna1,
             ajout du set arithabot, modification du select final..
_________________
MODIFICATION 4

Auteur:  GIBU

Date:    08/07/2003

Version:

Description:  Mise au point. Corection de certaines erreurs
              Les champs ADJCOD, ADJSIG, RETCOD et DETTRS doivent
              etre pris dans la TACCPAR

_________________
MODIFICATION 5

Auteur:  GIBU

Date:    27/10/2003

Version:

Description:  La recherche du CNATYP_CT sur l'exercice courant ou
              sur le dernier exercice de TCONTR si l'exercice
              courant n'existe pas est fait maintenant dans la proc.

_________________
MODIFICATION 6

Auteur:  JACKY

Date:    11/02/2004

Version:

Description:  MODIFICATION DU CALCUL DE LA TRIMESTRIALISATION
           et MODIFICATION DES SELECTS FINAUX

_________________
MODIFICATION 7

Auteur:  JACKY

Date:    17/10/2006

Version:

Description: SPOT13243 correction devises a blanc

_________________
MODIFICATION 8
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs

MODIFICATION "Removed dbo and added 'with execute as caller as'"
*****************************************************/

create table #CNA (
    SSD_CF          USSD_CF         NOT NULL,
    CTR_NF          UCTR_NF         NOT NULL,
    END_NT          UEND_NT         NOT NULL,
    SEC_NF          USEC_NF         NOT NULL,
    UWY_NF          UUWY_NF         NOT NULL,
    UW_NT           int             NOT NULL,
    ACY_NF          smallint        NOT NULL,
    ESTMNT_M        UAMT_M              NULL,
    AGE             int             NOT NULL,
    TAUX_CONSO      numeric (9,8)       NULL,
    TAUX_SOCIAL     numeric (9,8)       NULL,
    TAUX_CONSO1     numeric (9,8)       NULL, --Pour la trimestrialisation
    TAUX_SOCIAL1    numeric (9,8)       NULL, --Pour la trimestrialisation
    CONSO_M         UAMT_M              NULL,
    SOCIAL_M        UAMT_M              NULL,
    LSTEX           UUWY_NF             NULL,
    EXUTIL          UUWY_NF             NULL,
    UWGRP_CF        UGRP_CF             NULL,
    CNATYP_CT       char(1)             NULL)

CREATE TABLE #PERIODE (
    P_YEAR          int             not null)

CREATE TABLE #CONTRAT (
    SSD_CF          USSD_CF         NOT NULL,
    CTR_NF          uctr_nf         NOT NULL,
    END_NT          UEND_NT         NOT NULL,
    SEC_NF          usec_nf         NOT NULL,
    UWY_NF          uuwy_nf         NOT NULL,
    UW_NT           int             NOT NULL,
--    CNATYP_CT       char(1)             NULL)   debut SPOT13243
    CNATYP_CT       char(1)             NULL,


    CUR_CF          UCUR_CF             NULL,
    LOB_CF          ULOB_CF             NULL,
    ACCADMTYP_CT    UACCADMTYP_CT       NULL,
    ESTCRB_CT       char(1)             NULL,
    CED_NF          UCLI_NF             NULL,
    BRK_NF          UCLI_NF             NULL,
    PAY_NF          UCLI_NF             NULL,
    GANPAYORD_NT    UPAYORD_NT          NULL,
    ESB_CF          UESB_CF             NULL,
    LIFTRTTYP_CF    char(2)             NULL,
    NAT_CF          UCTRNAT_CF          NULL)       -- fin SPOT13243

CREATE TABLE #FINALE (
    SSD_CF          USSD_CF         NOT NULL,
    CTR_NF          UCTR_NF         NOT NULL,
    END_NT          UEND_NT         NOT NULL,
    SEC_NF          USEC_NF         NOT NULL,
    UWY_NF          UUWY_NF         NOT NULL,
    UW_NT           int             NOT NULL,
    ACY_NF          smallint        NOT NULL,
    CRE_D           datetime            NULL,
    PRS_CF          smallint        NOT NULL,
    ACMTRS_NT       smallint        NOT NULL,
    BALSHEY_NF      smallint            NULL,
    BALSHTMTH_NF    tinyint             NULL,
    CUR_CF          UCUR_CF             NULL,
    ESTMNT_M        UAMT_M              NULL,
    UPD_NF          char(1)             NULL,
    LOB_CF          ULOB_CF             NULL,
    ACCSTS_CT       UACCSTS_CT      NOT NULL,
    ACCADMTYP_CT    UACCADMTYP_CT       NULL,
    ESTCRB_CT       char(1)             NULL,
    CED_NF          UCLI_NF             NULL,
    BRK_NF          UCLI_NF             NULL,
    PAY_NF          UCLI_NF             NULL,
    GANPAYORD_NT    UPAYORD_NT          NULL,
    ADJCOD_CT       tinyint             NULL,
    RETCOD_CT       tinyint             NULL,
    DETTRS_CF       UDETTRS_CF          NULL,
    ADJSIG_B        bit             NOT NULL,
    ESB_CF          UESB_CF             NULL,
    LIFTRTTYP_CF    char(2)             NULL,
    INDSUP_B        bit             NOT NULL,
    ORICOD_LS       UL16                NULL,
    CREUSR_CF       UUPDUSR_CF          NULL,
    LSTUPD_D        UUPD_D              NULL,
    LSTUPDUSR_CF    UUPDUSR_CF          NULL,
    SPIMOD_CT       tinyint             NULL,
    NAT_CF          UCTRNAT_CF          NULL,
    UWGRP_CF        UGRP_CF             NULL,
    CNATYP_CT       char(1)             NULL)

CREATE TABLE #MAXI (
    CTR_NF          UCTR_NF         NOT NULL,
    UWY_NF          UUWY_NF         NOT NULL)

declare @erreur             int,
        @tran_imbr	        bit,
        @clodat_year        int,
        @clodat_month       int,
        @trimestre          numeric (3,2)

select @clodat_year  = convert (int, DatePart (yy, @p_CLODAT_D))
select @clodat_month = convert (int, DatePart (MM, @p_CLODAT_D))

--On insere les périodes dans la #periode
INSERT INTO #PERIODE (P_YEAR) values (@clodat_year - 4)
INSERT INTO #PERIODE (P_YEAR) values (@clodat_year - 3)
INSERT INTO #PERIODE (P_YEAR) values (@clodat_year - 2)
INSERT INTO #PERIODE (P_YEAR) values (@clodat_year - 1)
INSERT INTO #PERIODE (P_YEAR) values (@clodat_year)
INSERT INTO #PERIODE (P_YEAR) values (@clodat_year + 1)
INSERT INTO #PERIODE (P_YEAR) values (@clodat_year + 2)

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

-- Modif 005 : Mise en commentaire du delete de BTRAV

/* Commencer par supprimer de la btrav les contrats qui ne sont pas */
/* en mode de calcul automatique (CNATYP_CT <> '1' sur BTRT..TCONTR */
/*
delete BTRAV..EST_ESID2030_CNA_1
from   BTRAV..EST_ESID2030_CNA_1 a, BTRT..TCONTR b
where  a.CTR_NF     = b.CTR_NF
and    a.UWY_NF     = b.UWY_NF
and    a.END_NT     = b.END_NT
and    a.UW_NT      = b.UW_NT
and    (b.CNATYP_CT = NULL or b.CNATYP_CT != '1')
*/

-- Debut modif 005
/*  On insere tous les contrats de BTRAV dans #CNA */

/*insert into #CONTRAT
select distinct SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, NULL
from   BTRAV..EST_ESID2030_CNA_1                          SPOT13243
*/
insert into #CONTRAT
select distinct SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, NULL, CUR_CF, LOB_CF, ACCADMTYP_CT, ESTCRB_CT, CED_NF, BRK_NF,
               PAY_NF, GANPAYORD_NT, ESB_CF, LIFTRTTYP_CF, NAT_CF
                    from   BTRAV..EST_ESID2030_CNA_1

/* On recherche exercice maxi par contrat */

insert into #maxi
select a.ctr_nf, max(b.uwy_nf)
from   #contrat a, btrt..tcontr b
where  a.ctr_nf = b.ctr_nf
group by a.ctr_nf
order by a.ctr_nf

/* Puis on va recherche le type de calcul sur BTRT */
/* On prend d'abord celui de l'exercice            */

update #CONTRAT
set    a.CNATYP_CT = b.CNATYP_CT
from   #CONTRAT a, BTRT..TCONTR b
where  a.ctr_nf = b.ctr_nf
and    a.end_nt = b.end_nt
and    a.uw_nt  = b.uw_nt
and    a.uwy_nf = b.uwy_nf

/* Pour les cnatyp a NULL on va le rechercher sur le dernier ex */

update #CONTRAT
set    a.CNATYP_CT = c.CNATYP_CT
from   #CONTRAT a, #maxi b, BTRT..TCONTR c
where  a.cnatyp_ct is null
and    a.ctr_nf = b.ctr_nf
and    a.ctr_nf = c.ctr_nf
and    b.uwy_nf = c.uwy_nf

/* On supprime les contrats dont cnatyp_ct est different de 1 */

delete BTRAV..EST_ESID2030_CNA_1
from   BTRAV..EST_ESID2030_CNA_1 a, #CONTRAT b
where  a.CTR_NF     = b.CTR_NF
and    a.UWY_NF     = b.UWY_NF
and    a.END_NT     = b.END_NT
and    a.UW_NT      = b.UW_NT
and    (b.CNATYP_CT = NULL or b.CNATYP_CT != '1')

delete #CONTRAT
where  CNATYP_CT is NULL or CNATYP_CT != '1'

-- Fin modif 005

/* Chargement table de calcul */

insert into #CNA
select a.SSD_CF, a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT,
       b.P_YEAR, 0, 0, 0, 0, 0, 0, 0, 0, null, a.UWY_NF, null, null
from   #CONTRAT a, #PERIODE b
where  a.UWY_NF <= b.P_YEAR

Set arithabort numeric_truncation off

--mise à jour des ages.
update #CNA
set    AGE = ACY_NF - UWY_NF

--modif 2 debut
UPDATE #CNA
SET    LSTEX = (select max (a.UWY_NF)
                from   BTRT..TFAMCNA a
                WHERE  a.CTR_NF = b.CTR_NF
                and    a.SEC_NF = b.SEC_NF)
--              and    a.acy_nf = b.age )   surtout pas GB le 07/07/2003
FROM   #CNA b

UPDATE #CNA
SET    EXUTIL = LSTEX
WHERE  LSTEX < UWY_NF

--modif 2 fin

--Mise à jour des taux
Update #CNA
set    a.TAUX_CONSO  = b.CNACONSO_R,
       a.TAUX_SOCIAL = b.CNASOCI_R
from   #CNA a, BTRT..TFAMCNA b
where  a.CTR_NF = b.CTR_NF
and    a.EXUTIL = b.UWY_NF      --modif 0002
and    a.SEC_NF = b.SEC_NF
and    a.AGE    = b.ACY_NF

--trimestrialisation.
IF @p_MONTH <> 12
    BEGIN
    --Mise à jour de la base de calcul
        update BTRAV..EST_ESID2030_CNA_1
        set    cna_1.ESTMNT_M = cna_2.GT_AMT_M
        from   BTRAV..EST_ESID2030_CNA_1 cna_1, BTRAV..EST_ESID2030_CNA_2 cna_2
        where  cna_1.CTR_NF    = cna_2.GT_CTR_NF
        and    cna_1.END_NT    = cna_2.GT_END_NT
        and    cna_1.SEC_NF    = cna_2.GT_SEC_NF
        and    cna_1.UWY_NF    = cna_2.GT_UWY_NF
        and    cna_1.UW_NT     = cna_2.GT_UW_NT
        and    cna_1.ACY_NF    = cna_2.GT_ACY_NF
        and    cna_1.ACMTRS_NT = cna_2.GT_ACMTRS_NT
        and    cna_1.CUR_CF    = cna_2.GT_CUR_CF
        and    cna_1.ESTMNT_M  < cna_2.GT_AMT_M
    END

update #CNA
set    a.ESTMNT_M = (select sum(b.ESTMNT_M)
                     from   BTRAV..EST_ESID2030_CNA_1 b
                     where  a.CTR_NF  = b.CTR_NF
                     and    a.SEC_NF  = b.SEC_NF
                     and    a.UWY_NF  = b.UWY_NF
                     and    a.ACY_NF !< b.ACY_NF)
from #CNA a

update #CNA
set    TAUX_CONSO = 0
where  TAUX_CONSO is null

update #CNA
set    TAUX_SOCIAL = 0
where  TAUX_SOCIAL is null

--update des taux
update #CNA
set    CONSO_M  = TAUX_CONSO  * ESTMNT_M * -1,
       SOCIAL_M = TAUX_SOCIAL * ESTMNT_M * -1

--0003
update #CNA
set    a.UWGRP_CF  = b.UWGRP_CF,
       a.CNATYP_CT = b.CNATYP_CT
from   #CNA a, BTRT..TCONTR b
where  a.CTR_NF  = b.CTR_NF
and    a.UWY_NF  = b.UWY_NF

IF @p_MONTH <> 12
    BEGIN
    --on recherche les  taux pour acy + 1

    -- JR 11/02/2004
         update #CNA
         set    TAUX_SOCIAL1 = 0,
                TAUX_CONSO1  = 0
         FROM #CNA


        update #CNA
        set    a.TAUX_CONSO1 = (select b.TAUX_CONSO
                                from   #CNA b
                                where  a.CTR_NF = b.CTR_NF
                                and    a.SEC_NF = b.SEC_NF
                                and    a.UWY_NF = b.UWY_NF
                                and    a.AGE    = b.AGE + 1
                                and    a.ACY_NF = @clodat_year )
             -- JR 11/02/2004   and    a.AGE    = b.AGE - 1)
        FROM #CNA a

        update #CNA
        set    a.TAUX_SOCIAL1 = (select b.TAUX_SOCIAL
                                 from   #CNA b
                                 where  a.CTR_NF = b.CTR_NF
                                 and    a.SEC_NF = b.SEC_NF
                                 and    a.UWY_NF = b.UWY_NF
                                 and    a.AGE    = b.AGE + 1
                                 and    a.ACY_NF = @clodat_year )
             -- JR 11/02/2004    and    a.AGE    = b.AGE - 1)
        FROM #CNA a

-- JR 04/05/2004
      update #CNA
      set    TAUX_CONSO1 = 1
       where  TAUX_CONSO1 is null
          and TAUX_CONSO <> 0
          and AGE = 0
          and ACY_NF = @clodat_year

      update #CNA
      set    TAUX_SOCIAL1 = 1
       where  TAUX_SOCIAL1 is null
         and TAUX_SOCIAL <> 0
         and AGE = 0
         and ACY_NF = @clodat_year

-- FIN 04/05/2004


         --TRIMESTRIALISATION.

         IF @p_MONTH between 1 and 3 --1 TRIMESTRE
         select  @trimestre = 0.25

         IF @p_MONTH between 4 and 6 --2 TRIMESTRE
         select  @trimestre = 0.5

          IF @p_MONTH between 7 and 9 --3 TRIMESTRE
          select  @trimestre = 0.75

          IF @p_MONTH between 10 and 11 --4 TRIMESTRE
          select  @trimestre = 1

        update #CNA
        set    CONSO_M  = ESTMNT_M * (TAUX_CONSO1  + (TAUX_CONSO  - TAUX_CONSO1)  * @trimestre)  * -1,
               SOCIAL_M = ESTMNT_M * (TAUX_SOCIAL1 + (TAUX_SOCIAL - TAUX_SOCIAL1) * @trimestre)  * -1
            from   #CNA
              where  ACY_NF = @clodat_year


/* JR 11/02/2004
        update #CNA
        set    CONSO_M  = CONSO_M  * (TAUX_CONSO  + (TAUX_CONSO1  - TAUX_CONSO)  * @trimestre), -- * -1,
               SOCIAL_M = SOCIAL_M * (TAUX_SOCIAL + (TAUX_SOCIAL1 - TAUX_SOCIAL) * @trimestre)  -- * -1

 fin JR 11/02/2004  */

END

/*    mis en commentaires le 11/02/2004  JR */

--- jr 19 08 03    END

/* Insertion dans la table finale

-- en premier les 1183
insert into #FINALE
select SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF,
       convert(char(8),@p_CRE_D, 112)+ " 23:59:50", 500, 1183,
       @clodat_year, @clodat_month, NULL, SOCIAL_M, NULL,
       NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       0, NULL, NULL, 0, 'CNA AUTO', 'dbo', getdate(), 'dbo', NULL,
       NULL, UWGRP_CF, CNATYP_CT
from   #CNA
where  ACY_NF = @clodat_year   -- jr 19082003

-- ensuite les 1184
insert into #FINALE
select SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF + 1,
       convert(char(8),@p_CRE_D, 112)+ " 23:59:50", 500, 1184,
       @clodat_year, @clodat_month, NULL, SOCIAL_M * -1, NULL,
       NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       0, NULL, NULL, 0, 'CNA AUTO', 'dbo', getdate(), 'dbo', NULL,
       NULL, UWGRP_CF, CNATYP_CT
from   #CNA
where  ACY_NF = @clodat_year  -- jr 19082003  where  ACY_NF < @clodat_year + 2

-- ensuite les 1193
insert into #FINALE
select SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF,
       convert(char(8),@p_CRE_D, 112)+ " 23:59:50", 500, 1193,
       @clodat_year, @clodat_month, NULL, CONSO_M, NULL,
       NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       0, NULL, NULL, 0, 'CNA AUTO', 'dbo', getdate(), 'dbo', NULL,
       NULL, UWGRP_CF, CNATYP_CT
from   #CNA
where  ACY_NF = @clodat_year   -- jr 19082003

-- enfin les 1194
insert into #FINALE
select SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF + 1,
       convert(char(8),@p_CRE_D, 112)+ " 23:59:50", 500, 1194,
       @clodat_year, @clodat_month, NULL, CONSO_M * -1, NULL,
       NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       0, NULL, NULL, 0, 'CNA AUTO', 'dbo', getdate(), 'dbo', NULL,
       NULL, UWGRP_CF, CNATYP_CT
from   #CNA
where  ACY_NF = @clodat_year   -- jr 19082003  where  ACY_NF < @clodat_year + 2

--- ajout jr 19 08 2003

    END
IF @p_MONTH = 12
    BEGIN


  FIN MISE EN COMMENTAIRE JR 11/02/2004 */


/* Insertion dans la table finale */

-- en premier les 1183
insert into #FINALE
select SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF,
       convert(char(8),@p_CRE_D, 112)+ " 23:59:50",500, 1183,
       @clodat_year, @clodat_month, NULL, SOCIAL_M, NULL,
       NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       0, NULL, NULL, 0, 'CNA AUTO', 'dbo', getdate(), 'dbo', NULL,
       NULL, UWGRP_CF, CNATYP_CT
from   #CNA

-- ensuite les 1184

insert into #FINALE
select SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF + 1,
       convert(char(8),@p_CRE_D, 112)+ " 23:59:50", 500, 1184,
       @clodat_year, @clodat_month, NULL, SOCIAL_M * -1, NULL,
       NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       0, NULL, NULL, 0, 'CNA AUTO', 'dbo', getdate(), 'dbo', NULL,
       NULL, UWGRP_CF, CNATYP_CT
from   #CNA
where  ACY_NF < @clodat_year + 2

-- ensuite les 1193
insert into #FINALE
select SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF,
       convert(char(8),@p_CRE_D, 112)+ " 23:59:50", 500, 1193,
       @clodat_year, @clodat_month, NULL, CONSO_M, NULL,
       NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       0, NULL, NULL, 0, 'CNA AUTO', 'dbo', getdate(), 'dbo', NULL,
       NULL, UWGRP_CF, CNATYP_CT
from   #CNA


-- enfin les 1194
insert into #FINALE
select SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF + 1,
       convert(char(8),@p_CRE_D, 112)+ " 23:59:50", 500, 1194,
       @clodat_year, @clodat_month, NULL, CONSO_M * -1, NULL,
       NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       0, NULL, NULL, 0, 'CNA AUTO', 'dbo', getdate(), 'dbo', NULL,
       NULL, UWGRP_CF, CNATYP_CT
from   #CNA
where  ACY_NF < @clodat_year + 2

--END
--- fin ajout jr

/* Mise a jour des champs a NULL */       --      SPOT13243
update #FINALE
set    a.CUR_CF       = b.CUR_CF,
       a.LOB_CF       = b.LOB_CF,
       a.ACCADMTYP_CT = b.ACCADMTYP_CT,
       a.ESTCRB_CT    = b.ESTCRB_CT,
       a.CED_NF       = b.CED_NF,
       a.BRK_NF       = b.BRK_NF,
       a.PAY_NF       = b.PAY_NF,
       a.GANPAYORD_NT = b.GANPAYORD_NT,
       a.ESB_CF       = b.ESB_CF,
       a.LIFTRTTYP_CF = b.LIFTRTTYP_CF,
       a.NAT_CF       = b.NAT_CF
from   #FINALE a, #CONTRAT b
where  a.SSD_CF    = b.SSD_CF
and    a.CTR_NF    = b.CTR_NF
and    a.END_NT    = b.END_NT
and    a.SEC_NF    = b.SEC_NF
and    a.UWY_NF    = b.UWY_NF
and    a.UW_NT     = b.UW_NT

/*  Mis en commentaire 13/10/2006             SPOT13243
update #FINALE
set    a.CUR_CF       = b.CUR_CF,
       a.LOB_CF       = b.LOB_CF,
       a.ACCADMTYP_CT = b.ACCADMTYP_CT,
       a.ESTCRB_CT    = b.ESTCRB_CT,
       a.CED_NF       = b.CED_NF,
       a.BRK_NF       = b.BRK_NF,
       a.PAY_NF       = b.PAY_NF,
       a.GANPAYORD_NT = b.GANPAYORD_NT,
       a.ESB_CF       = b.ESB_CF,
       a.LIFTRTTYP_CF = b.LIFTRTTYP_CF,
       a.NAT_CF       = b.NAT_CF
from   #FINALE a, BTRAV..EST_ESID2030_CNA_1 b
where  a.SSD_CF    = b.SSD_CF
and    a.CTR_NF    = b.CTR_NF
and    a.END_NT    = b.END_NT
and    a.SEC_NF    = b.SEC_NF
and    a.UWY_NF    = b.UWY_NF
and    a.UW_NT     = b.UW_NT
and    b.ACY_NF    = (select min(c.ACY_NF)
                      from   BTRAV..EST_ESID2030_CNA_1 c
                      where  a.CTR_NF = c.CTR_NF
                      and    a.SEC_NF = c.SEC_NF
                      and    a.UWY_NF = c.UWY_NF)
and    b.ACMTRS_NT = (select min(d.ACMTRS_NT)
                      from   BTRAV..EST_ESID2030_CNA_1 d
                      where  a.CTR_NF = d.CTR_NF
                      and    a.SEC_NF = d.SEC_NF
                      and    a.UWY_NF = d.UWY_NF)
*/
update #FINALE
set    a.RETCOD_CT = b.RETCOD_CT,
       a.ADJSIG_B  = b.ADJSIG_B,
       a.SPIMOD_CT = b.SPIMOD_CT
from   #FINALE a, BEST..TACCPAR b
where  a.PRS_CF    = b.PRS_CF
and    a.ACMTRS_NT = b.ACMTRS_NT

update #FINALE
set    a.ADJCOD_CT = b.ADJCOD_CT,
       a.DETTRS_CF = b.DETTRS_CF
from   #FINALE a, BEST..TACCPAR b
where  a.PRS_CF    = b.PRS_CF
and    a.ACMTRS_NT = b.ACMTRS_NT
and    a.ACY_NF   !> a.BALSHEY_NF

--construction des select final

select  SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF,
        convert(char(8),@p_CRE_D, 112)+ " 23:59:50",
        PRS_CF, ACMTRS_NT, BALSHEY_NF, BALSHTMTH_NF, CUR_CF,
        ESTMNT_M, UPD_NF, LOB_CF, ACCSTS_CT, ACCADMTYP_CT,
        ESTCRB_CT, CED_NF, BRK_NF, PAY_NF, GANPAYORD_NT, ADJCOD_CT,
        RETCOD_CT, DETTRS_CF, ADJSIG_B, ESB_CF, LIFTRTTYP_CF,
        INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF,
        SPIMOD_CT, NAT_CF, UWGRP_CF, CNATYP_CT
from   #FINALE WHERE ESTMNT_M != NULL
order by SSD_CF, CTR_NF, SEC_NF, UWY_NF, ACY_NF, ACMTRS_NT

--modif 0003
Set arithabort numeric_truncation on

if @tran_imbr = 0
	COMMIT TRAN

drop table #CNA
return @erreur

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go
GRANT EXECUTE ON PtCNA_01 TO GOMEGA
go
IF OBJECT_ID('PtCNA_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PtCNA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PtCNA_01 >>>'
go
EXEC sp_procxmode 'PtCNA_01','unchained'
go
