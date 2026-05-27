use BEST
go

IF OBJECT_ID('dbo.PiLIFEST_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiLIFEST_03
    IF OBJECT_ID('dbo.PiLIFEST_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiLIFEST_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiLIFEST_03 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PiLIFEST_03
     (
       @p_BILAN          smallint,
       @p_AC             smallint
     )
as

/***************************************************

Programme: PiLIFEST_03

Fichier script associé : ESILIF03.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: J. Ribot

Date de creation: 27/04/2006

Description du programme:

      Insertion d'enregistrement dans TLIFEST          */
/* *************************************************** */
/*                                                     */
/* Initialisation des estimations vie pour AC 2008     */
/* a partir des estimations de AC 2007 pour bilan 2006 */
/* Ne concerne que les affaires de type 1 et type 3    */
/* Pour type 1 on selectionne tous les mouvements sauf */
/* les liberations                                     */
/* Pour type 3 on ne selectionne que les mouvements de */
/* type primes                                         */
/* On ne fait rien sur les autres affaires             */
/*                                                     */
/* ATTENTION : Modif du 02/02/2004 parametrage du      */
/*             bilan et de l'AC                        */
/*                                                     */
/* *************************************************** */
/*
________________
MODIFICATIONS
  Auteur   Date       Description
[001] 16/08/2013 P. COPPIN  :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
*****************************************************/


declare @erreur int

select @erreur = 0

IF OBJECT_ID('#gb1') IS NOT NULL
  drop table #gb1

select distinct a.ctr_nf, a.sec_nf
into   #gb1
from   best..tlifest a, BREF..TBATCHSSD T
where  a.balshey_nf = @P_BILAN
and    a.acy_nf     = @P_AC
and    a.SSD_CF     = T.SSD_CF
and    T.BATCHUSER_CF = suser_name()

order by a.ctr_nf, a.sec_nf

-- On recupere les informations section pour ces traites

IF OBJECT_ID('#gb2') IS NOT NULL
  drop table #gb2

select a.ctr_nf, a.sec_nf, a.uwy_nf, a.accadmtyp_ct,
       a.secsts_ct, a.secaccsts_ct
into   #gb2
from   btrt..tsection a, #gb1 b
where  a.ctr_nf = b.ctr_nf
and    a.sec_nf = b.sec_nf
and    a.secsts_ct in (14, 16, 17, 18, 19)

-- On ne garde que les informations du dernier ex

IF OBJECT_ID('#gb3') IS NOT NULL
  drop table #gb3

select a.ctr_nf, a.sec_nf, a.uwy_nf, a.accadmtyp_ct, a.secsts_ct, a.secaccsts_ct
into   #gb3
from   #gb2 a
where  a.uwy_nf = (select max(b.uwy_nf)
                   from   #gb2 b
                   where  a.ctr_nf = b.ctr_nf
                   and    a.sec_nf = b.sec_nf)

-- On selectionne les estimations sur traites de type 1

IF OBJECT_ID('#gb4') IS NOT NULL
  drop table #gb4

select a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CRE_D, a.BALSHEY_NF, a.BALSHTMTH_NF, a.ACY_NF, a.PRS_CF, a.ACMTRS_NT, a.SSD_CF, a.CUR_CF, a.ESTMNT_M, a.INDSUP_B, a.ORICOD_LS, a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF
into   #gb4
from   best..tlifest a, #gb3 b
where  a.ctr_nf = b.ctr_nf
and    a.sec_nf = b.sec_nf
and    a.balshey_nf = @P_BILAN
and    a.acy_nf     = @P_AC
and    b.accadmtyp_ct = 1
and    substring(convert(char(4), a.acmtrs_nt), 4, 1) != '4'

-- on regarde les traites avec ex different AC

--select 'EST TRT ACCEPT TYPE 1 NON RENOUVELEES', #gb4.CTR_NF, #gb4.END_NT, #gb4.SEC_NF, #gb4.UWY_NF, #gb4.UW_NT, #gb4.CRE_D, #gb4.BALSHEY_NF, #gb4.BALSHTMTH_NF, #gb4.ACY_NF, #gb4.PRS_CF, #gb4.ACMTRS_NT, #gb4.SSD_CF, #gb4.CUR_CF, #gb4.ESTMNT_M, #gb4.INDSUP_B, #gb4.ORICOD_LS, #gb4.CREUSR_CF, #gb4.LSTUPD_D, #gb4.LSTUPDUSR_CF
--from   #gb4
--where  uwy_nf != acy_nf

-- et on les supprime des estimations a transformer

delete #gb4
where  uwy_nf != acy_nf

-- on les transforme en estimations 2006

update #gb4
set    uwy_nf       = @P_AC + 1,
       acy_nf       = @P_AC + 1,
       creusr_cf    = 'INFA',
       lstupd_d     = getdate(),
       lstupdusr_cf = 'INFA'
from   #gb4

-- On selectionne les estimations sur traites de type 3

IF OBJECT_ID('#gb5') IS NOT NULL
  drop table #gb5

select a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CRE_D, a.BALSHEY_NF, a.BALSHTMTH_NF, a.ACY_NF, a.PRS_CF, a.ACMTRS_NT, a.SSD_CF, a.CUR_CF, a.ESTMNT_M, a.INDSUP_B, a.ORICOD_LS, a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF
into   #gb5
from   best..tlifest a, #gb3 b
where  a.ctr_nf = b.ctr_nf
and    a.sec_nf = b.sec_nf
and    a.balshey_nf = @P_BILAN
and    a.acy_nf     = @P_AC
and    b.accadmtyp_ct = 3
and    substring(convert(char(4), a.acmtrs_nt), 4, 1) != '4'
and   (substring(convert(char(4), a.acmtrs_nt), 2, 1)  = '0'
or     substring(convert(char(4), a.acmtrs_nt), 2, 1)  = '1'
or     substring(convert(char(4), a.acmtrs_nt), 2, 1)  = '5'
or     substring(convert(char(4), a.acmtrs_nt), 2, 1)  = '6')

-- on regarde les traites avec ex different AC

--select 'EST TRT ACCEPT TYPE 3 NON RENOUVELEES', #gb5.CTR_NF, #gb5.END_NT, #gb5.SEC_NF, #gb5.UWY_NF, #gb5.UW_NT, #gb5.CRE_D, #gb5.BALSHEY_NF, #gb5.BALSHTMTH_NF, #gb5.ACY_NF, #gb5.PRS_CF, #gb5.ACMTRS_NT, #gb5.SSD_CF, #gb5.CUR_CF, #gb5.ESTMNT_M, #gb5.INDSUP_B, #gb5.ORICOD_LS, #gb5.CREUSR_CF, #gb5.LSTUPD_D, #gb5.LSTUPDUSR_CF
--from   #gb5
--where  uwy_nf != acy_nf

-- et on les supprime des estimations a transformer

delete #gb5
where  uwy_nf != acy_nf

-- on les transforme en estimations 2006

update #gb5
set    uwy_nf       = @P_AC + 1,
       acy_nf       = @P_AC + 1,
       creusr_cf    = 'INFA',
       lstupd_d     = getdate(),
       lstupdusr_cf = 'INFA'
from   #gb5


-- on recupere les traites de retro

IF OBJECT_ID('#gb6') IS NOT NULL
  drop table #gb6

select a.ctr_nf, a.sec_nf
into   #gb6
from   #gb1 a
where not exists (select 1
                  from   #gb3 b
                  where  a.ctr_nf = b.ctr_nf
                  and    a.sec_nf = b.sec_nf)

-- On recupere les informations traite pour ces traites

IF OBJECT_ID('#gb7') IS NOT NULL
  drop table #gb7

select distinct a.retctr_nf, a.rty_nf, a.retacctyp_ct,
       a.retctrsts_ct
into   #gb7
from   bret..tretctr a, #gb6 b, BREF..TBATCHSSD T
where  a.retctr_nf     = b.ctr_nf
and    a.SSD_CF        = T.SSD_CF
and    T.BATCHUSER_CF = suser_name()

-- On ne garde que les informations du dernier ex

IF OBJECT_ID('#gb8') IS NOT NULL
  drop table #gb8

select a.retctr_nf, a.rty_nf, a.retacctyp_ct, a.retctrsts_ct
into   #gb8
from   #gb7 a
where  a.rty_nf = (select max(b.rty_nf)
                   from   #gb7 b
                   where  a.retctr_nf = b.retctr_nf)

-- On selectionne les estimations sur traites de type 1

IF OBJECT_ID('#gb9') IS NOT NULL
  drop table #gb9

select a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CRE_D, a.BALSHEY_NF, a.BALSHTMTH_NF, a.ACY_NF, a.PRS_CF, a.ACMTRS_NT, a.SSD_CF, a.CUR_CF, a.ESTMNT_M, a.INDSUP_B, a.ORICOD_LS, a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF
into   #gb9
from   best..tlifest a, #gb8 b, BREF..TBATCHSSD T
where  a.ctr_nf = b.retctr_nf
and    a.balshey_nf = @P_BILAN
and    a.acy_nf     = @P_AC
and    b.retacctyp_ct = 1
and    substring(convert(char(4), a.acmtrs_nt), 4, 1) != '4'

and    a.SSD_CF        = T.SSD_CF
and    T.BATCHUSER_CF = suser_name()


-- on regarde les traites avec ex different AC

--select 'EST TRT RETRO TYPE 1 NON RENOUVELEES', #gb9.CTR_NF, #gb9.END_NT, #gb9.SEC_NF, #gb9.UWY_NF, #gb9.UW_NT, #gb9.CRE_D, #gb9.BALSHEY_NF, #gb9.BALSHTMTH_NF, #gb9.ACY_NF, #gb9.PRS_CF, #gb9.ACMTRS_NT, #gb9.SSD_CF, #gb9.CUR_CF, #gb9.ESTMNT_M, #gb9.INDSUP_B, #gb9.ORICOD_LS, #gb9.CREUSR_CF, #gb9.LSTUPD_D, #gb9.LSTUPDUSR_CF
--from   #gb9
--where  uwy_nf != acy_nf

-- et on les supprime des estimations a transformer

delete #gb9
where  uwy_nf != acy_nf

-- on les transforme en estimations 2006

update #gb9
set    uwy_nf       = @P_AC + 1,
       acy_nf       = @P_AC + 1,
       creusr_cf    = 'INFA',
       lstupd_d     = getdate(),
       lstupdusr_cf = 'INFA'
from   #gb9

-- On selectionne les estimations sur traites de type 3

IF OBJECT_ID('#gb10') IS NOT NULL
  drop table #gb10

select a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CRE_D, a.BALSHEY_NF, a.BALSHTMTH_NF, a.ACY_NF, a.PRS_CF, a.ACMTRS_NT, a.SSD_CF, a.CUR_CF, a.ESTMNT_M, a.INDSUP_B, a.ORICOD_LS, a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF
into   #gb10
from   best..tlifest a, #gb8 b, BREF..TBATCHSSD T
where  a.ctr_nf = b.retctr_nf
and    a.balshey_nf = @P_BILAN
and    a.acy_nf     = @P_AC
and    b.retacctyp_ct = 3
and    substring(convert(char(4), a.acmtrs_nt), 4, 1) != '4'
and   (substring(convert(char(4), a.acmtrs_nt), 2, 1)  = '0'
or     substring(convert(char(4), a.acmtrs_nt), 2, 1)  = '1'
or     substring(convert(char(4), a.acmtrs_nt), 2, 1)  = '5'
or     substring(convert(char(4), a.acmtrs_nt), 2, 1)  = '6')

and    a.SSD_CF        = T.SSD_CF
and    T.BATCHUSER_CF = suser_name()

-- on regarde les traites avec ex different AC

--select 'EST TRT RETRO TYPE 3 NON RENOUVELEES', #gb10.CTR_NF, #gb10.END_NT, #gb10.SEC_NF, #gb10.UWY_NF, #gb10.UW_NT, #gb10.CRE_D, #gb10.BALSHEY_NF, #gb10.BALSHTMTH_NF, #gb10.ACY_NF, #gb10.PRS_CF, #gb10.ACMTRS_NT, #gb10.SSD_CF, #gb10.CUR_CF, #gb10.ESTMNT_M, #gb10.INDSUP_B, #gb10.ORICOD_LS, #gb10.CREUSR_CF, #gb10.LSTUPD_D, #gb10.LSTUPDUSR_CF
--from   #gb10
--where  uwy_nf != acy_nf

-- et on les supprime des estimations a transformer

delete #gb10
where  uwy_nf != acy_nf

-- on les transforme en estimations 2006

update #gb10
set    uwy_nf       = @P_AC + 1,
       acy_nf       = @P_AC + 1,
       creusr_cf    = 'INFA',
       lstupd_d     = getdate(),
       lstupdusr_cf = 'INFA'
from   #gb10

-- Liste des estimations à injecter

-- on liste les estimations acceptation type 1 qui existent deja

--select 'EST ACC TYPE 1 EXISTANT', a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CRE_D, a.BALSHEY_NF, a.BALSHTMTH_NF, a.ACY_NF, a.PRS_CF, a.ACMTRS_NT, a.SSD_CF, a.CUR_CF, a.ESTMNT_M, a.INDSUP_B, a.ORICOD_LS, a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF
--from   #gb4 a
--where exists (select 1
--              from   best..tlifest b
--              where  a.balshey_nf = b.balshey_nf
--              and    a.uwy_nf     = b.uwy_nf
--              and    a.acy_nf     = b.acy_nf
--              and    a.ctr_nf     = b.ctr_nf
--              and    a.sec_nf     = b.sec_nf
--              and    a.cre_d      = b.cre_d
--              and    a.acmtrs_nt  = b.acmtrs_nt)

-- et on les supprime

delete #gb4
from   #gb4 a
where exists (select 1
              from   best..tlifest b, BREF..TBATCHSSD T
              where  a.balshey_nf = b.balshey_nf
              and    a.uwy_nf     = b.uwy_nf
              and    a.acy_nf     = b.acy_nf
              and    a.ctr_nf     = b.ctr_nf
              and    a.sec_nf     = b.sec_nf
              and    a.cre_d      = b.cre_d
              and    a.acmtrs_nt  = b.acmtrs_nt
              
              and    b.SSD_CF     = T.SSD_CF
              and    T.BATCHUSER_CF = suser_name() )

-- Estimation Acceptation de type 1

--select 'EST ACC 2006 TYPE 1 ', #gb4.CTR_NF, #gb4.END_NT, #gb4.SEC_NF, #gb4.UWY_NF, #gb4.UW_NT, #gb4.CRE_D, #gb4.BALSHEY_NF, #gb4.BALSHTMTH_NF, #gb4.ACY_NF, #gb4.PRS_CF, #gb4.ACMTRS_NT, #gb4.SSD_CF, #gb4.CUR_CF, #gb4.ESTMNT_M, #gb4.INDSUP_B, #gb4.ORICOD_LS, #gb4.CREUSR_CF, #gb4.LSTUPD_D, #gb4.LSTUPDUSR_CF
--from   #gb4
--order by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt, cre_d, balshey_nf,
--         balshtmth_nf, acy_nf, prs_cf, acmtrs_nt

-- on les injecte
/* 27 04 2006
insert into best..tlifest
select *
from   #gb4
*/
select #gb4.CTR_NF, #gb4.END_NT, #gb4.SEC_NF, #gb4.UWY_NF, #gb4.UW_NT, #gb4.CRE_D, #gb4.BALSHEY_NF, #gb4.BALSHTMTH_NF, #gb4.ACY_NF, #gb4.PRS_CF, #gb4.ACMTRS_NT, #gb4.SSD_CF, #gb4.CUR_CF, #gb4.ESTMNT_M, #gb4.INDSUP_B, #gb4.ORICOD_LS, #gb4.CREUSR_CF, #gb4.LSTUPD_D, #gb4.LSTUPDUSR_CF  into  #gb15
     from  #gb4

-- on liste les estimations acceptation type 3 qui existent deja

--select 'EST ACC TYPE 3 EXISTANT', a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CRE_D, a.BALSHEY_NF, a.BALSHTMTH_NF, a.ACY_NF, a.PRS_CF, a.ACMTRS_NT, a.SSD_CF, a.CUR_CF, a.ESTMNT_M, a.INDSUP_B, a.ORICOD_LS, a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF
--from   #gb5 a
--where exists (select 1
--              from   best..tlifest b
--              where  a.balshey_nf = b.balshey_nf
--              and    a.uwy_nf     = b.uwy_nf
--              and    a.acy_nf     = b.acy_nf
--              and    a.ctr_nf     = b.ctr_nf
--              and    a.sec_nf     = b.sec_nf
--              and    a.cre_d      = b.cre_d
--              and    a.acmtrs_nt  = b.acmtrs_nt)
--
-- et on les supprime

delete #gb5
from   #gb5 a
where exists (select 1
              from   best..tlifest b, BREF..TBATCHSSD T
              where  a.balshey_nf = b.balshey_nf
              and    a.uwy_nf     = b.uwy_nf
              and    a.acy_nf     = b.acy_nf
              and    a.ctr_nf     = b.ctr_nf
              and    a.sec_nf     = b.sec_nf
              and    a.cre_d      = b.cre_d
              and    a.acmtrs_nt  = b.acmtrs_nt

              and    b.SSD_CF     = T.SSD_CF
              and    T.BATCHUSER_CF = suser_name() )

-- Estimation Acceptation de type 3

--select 'EST ACC 2006 TYPE 3 ', #gb5.CTR_NF, #gb5.END_NT, #gb5.SEC_NF, #gb5.UWY_NF, #gb5.UW_NT, #gb5.CRE_D, #gb5.BALSHEY_NF, #gb5.BALSHTMTH_NF, #gb5.ACY_NF, #gb5.PRS_CF, #gb5.ACMTRS_NT, #gb5.SSD_CF, #gb5.CUR_CF, #gb5.ESTMNT_M, #gb5.INDSUP_B, #gb5.ORICOD_LS, #gb5.CREUSR_CF, #gb5.LSTUPD_D, #gb5.LSTUPDUSR_CF
--from   #gb5
--order by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt, cre_d, balshey_nf,
--         balshtmth_nf, acy_nf, prs_cf, acmtrs_nt

-- on les injecte

insert into #gb15  --best..tlifest
select #gb5.CTR_NF, #gb5.END_NT, #gb5.SEC_NF, #gb5.UWY_NF, #gb5.UW_NT, #gb5.CRE_D, #gb5.BALSHEY_NF, #gb5.BALSHTMTH_NF, #gb5.ACY_NF, #gb5.PRS_CF, #gb5.ACMTRS_NT, #gb5.SSD_CF, #gb5.CUR_CF, #gb5.ESTMNT_M, #gb5.INDSUP_B, #gb5.ORICOD_LS, #gb5.CREUSR_CF, #gb5.LSTUPD_D, #gb5.LSTUPDUSR_CF
from   #gb5

-- on liste les estimations retro type 1 qui existent deja

--select 'EST RETRO TYPE 1 EXISTANT', a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CRE_D, a.BALSHEY_NF, a.BALSHTMTH_NF, a.ACY_NF, a.PRS_CF, a.ACMTRS_NT, a.SSD_CF, a.CUR_CF, a.ESTMNT_M, a.INDSUP_B, a.ORICOD_LS, a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF
--from   #gb9 a
--where exists (select 1
--              from   best..tlifest b
--              where  a.balshey_nf = b.balshey_nf
--              and    a.uwy_nf     = b.uwy_nf
--              and    a.acy_nf     = b.acy_nf
--              and    a.ctr_nf     = b.ctr_nf
--              and    a.sec_nf     = b.sec_nf
--              and    a.cre_d      = b.cre_d
--              and    a.acmtrs_nt  = b.acmtrs_nt)
--
-- et on les supprime

delete #gb9
from   #gb9 a
where exists (select 1
              from   best..tlifest b, BREF..TBATCHSSD T
              where  a.balshey_nf = b.balshey_nf
              and    a.uwy_nf     = b.uwy_nf
              and    a.acy_nf     = b.acy_nf
              and    a.ctr_nf     = b.ctr_nf
              and    a.sec_nf     = b.sec_nf
              and    a.cre_d      = b.cre_d
              and    a.acmtrs_nt  = b.acmtrs_nt

              and    b.SSD_CF     = T.SSD_CF
              and    T.BATCHUSER_CF = suser_name() )

-- Estimation Retro de type 1

--select 'EST RET 2006 TYPE 1 ', #gb9.CTR_NF, #gb9.END_NT, #gb9.SEC_NF, #gb9.UWY_NF, #gb9.UW_NT, #gb9.CRE_D, #gb9.BALSHEY_NF, #gb9.BALSHTMTH_NF, #gb9.ACY_NF, #gb9.PRS_CF, #gb9.ACMTRS_NT, #gb9.SSD_CF, #gb9.CUR_CF, #gb9.ESTMNT_M, #gb9.INDSUP_B, #gb9.ORICOD_LS, #gb9.CREUSR_CF, #gb9.LSTUPD_D, #gb9.LSTUPDUSR_CF
--from   #gb9
--order by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt, cre_d, balshey_nf,
--         balshtmth_nf, acy_nf, prs_cf, acmtrs_nt

-- on les injecte

insert into #gb15 --best..tlifest
select #gb9.CTR_NF, #gb9.END_NT, #gb9.SEC_NF, #gb9.UWY_NF, #gb9.UW_NT, #gb9.CRE_D, #gb9.BALSHEY_NF, #gb9.BALSHTMTH_NF, #gb9.ACY_NF, #gb9.PRS_CF, #gb9.ACMTRS_NT, #gb9.SSD_CF, #gb9.CUR_CF, #gb9.ESTMNT_M, #gb9.INDSUP_B, #gb9.ORICOD_LS, #gb9.CREUSR_CF, #gb9.LSTUPD_D, #gb9.LSTUPDUSR_CF
from   #gb9

-- on liste les estimations retro type 3 qui existent deja

--select 'EST RETRO TYPE 3 EXISTANT', a.CTR_NF, a.END_NT, a.SEC_NF, a.UWY_NF, a.UW_NT, a.CRE_D, a.BALSHEY_NF, a.BALSHTMTH_NF, a.ACY_NF, a.PRS_CF, a.ACMTRS_NT, a.SSD_CF, a.CUR_CF, a.ESTMNT_M, a.INDSUP_B, a.ORICOD_LS, a.CREUSR_CF, a.LSTUPD_D, a.LSTUPDUSR_CF
--from   #gb10 a
--where exists (select 1
--              from   best..tlifest b
--              where  a.balshey_nf = b.balshey_nf
--              and    a.uwy_nf     = b.uwy_nf
--              and    a.acy_nf     = b.acy_nf
--              and    a.ctr_nf     = b.ctr_nf
--              and    a.sec_nf     = b.sec_nf
--              and    a.cre_d      = b.cre_d
--              and    a.acmtrs_nt  = b.acmtrs_nt)

-- et on les supprime

delete #gb10
from   #gb10 a
where exists (select 1
              from   best..tlifest b, BREF..TBATCHSSD T
              where  a.balshey_nf = b.balshey_nf
              and    a.uwy_nf     = b.uwy_nf
              and    a.acy_nf     = b.acy_nf
              and    a.ctr_nf     = b.ctr_nf
              and    a.sec_nf     = b.sec_nf
              and    a.cre_d      = b.cre_d
              and    a.acmtrs_nt  = b.acmtrs_nt

              and    b.SSD_CF     = T.SSD_CF
              and    T.BATCHUSER_CF = suser_name() )
              
-- Estimation Retro de type 3

--select 'EST RET 2006 TYPE 3 ', #gb10.CTR_NF, #gb10.END_NT, #gb10.SEC_NF, #gb10.UWY_NF, #gb10.UW_NT, #gb10.CRE_D, #gb10.BALSHEY_NF, #gb10.BALSHTMTH_NF, #gb10.ACY_NF, #gb10.PRS_CF, #gb10.ACMTRS_NT, #gb10.SSD_CF, #gb10.CUR_CF, #gb10.ESTMNT_M, #gb10.INDSUP_B, #gb10.ORICOD_LS, #gb10.CREUSR_CF, #gb10.LSTUPD_D, #gb10.LSTUPDUSR_CF
--from   #gb10
--order by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt, cre_d, balshey_nf,
--         balshtmth_nf, acy_nf, prs_cf, acmtrs_nt

-- on les injecte

insert into #gb15 --best..tlifest
select #gb10.CTR_NF, #gb10.END_NT, #gb10.SEC_NF, #gb10.UWY_NF, #gb10.UW_NT, #gb10.CRE_D, #gb10.BALSHEY_NF, #gb10.BALSHTMTH_NF, #gb10.ACY_NF, #gb10.PRS_CF, #gb10.ACMTRS_NT, #gb10.SSD_CF, #gb10.CUR_CF, #gb10.ESTMNT_M, #gb10.INDSUP_B, #gb10.ORICOD_LS, #gb10.CREUSR_CF, #gb10.LSTUPD_D, #gb10.LSTUPDUSR_CF
from   #gb10

-- extraction fichier final
select #gb15.CTR_NF, #gb15.END_NT, #gb15.SEC_NF, #gb15.UWY_NF, #gb15.UW_NT, #gb15.CRE_D, #gb15.BALSHEY_NF, #gb15.BALSHTMTH_NF, #gb15.ACY_NF, #gb15.PRS_CF, #gb15.ACMTRS_NT, #gb15.SSD_CF, #gb15.CUR_CF, #gb15.ESTMNT_M, #gb15.INDSUP_B, #gb15.ORICOD_LS, #gb15.CREUSR_CF, #gb15.LSTUPD_D, #gb15.LSTUPDUSR_CF from #gb15
order by ctr_nf, end_nt, sec_nf, uwy_nf, uw_nt, cre_d, balshey_nf,
         balshtmth_nf, acy_nf, prs_cf, acmtrs_nt

return 0

fin:
return @erreur

go
IF OBJECT_ID('dbo.PiLIFEST_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiLIFEST_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiLIFEST_03 >>>'
go
EXEC sp_procxmode 'dbo.PiLIFEST_03','unchained'
go
GRANT EXECUTE ON dbo.PiLIFEST_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiLIFEST_03 TO GDBBATCH
go


