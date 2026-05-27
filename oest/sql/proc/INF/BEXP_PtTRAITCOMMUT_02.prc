USE BEXP
go
IF OBJECT_ID('btravi..CNC_CNCD2000_COMMUTCTRPROP') IS NOT NULL
DROP TABLE btravi..CNC_CNCD2000_COMMUTCTRPROP
go
CREATE TABLE btravi..CNC_CNCD2000_COMMUTCTRPROP
(
    CTR_NF           UCTR_NF     NOT NULL,     -- 1
    NAT_CF           char(02)    NOT NULL,     -- 2
    ACY_NF           smallint    NOT NULL,     -- 3
    SCOSTRMTH_NF     tinyint     NOT NULL,     -- 4
    SCOENDMTH_NF     tinyint     NOT NULL,     -- 5

    M_ACY_NF         smallint    NOT NULL,     -- 6
    M_SCOSTRMTH_NF   tinyint     NOT NULL,     -- 7
    M_SCOENDMTH_NF   tinyint     NOT NULL,     -- 8

    GLT_ACY_NF       smallint    NOT NULL,     -- 9
    GLT_SCOSTRMTH_NF tinyint     NOT NULL,     --10
    GLT_SCOENDMTH_NF tinyint     NOT NULL      --11
)
go

-- //////////////////////////////////////////////////////////////////////////////
IF OBJECT_ID('dbo.PtTRAITCOMMUT_02') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PtTRAITCOMMUT_02
    IF OBJECT_ID('dbo.PtTRAITCOMMUT_02') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PtTRAITCOMMUT_02 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PtTRAITCOMMUT_02 >>>'
END
go
/* creation de la procedure */
create procedure PtTRAITCOMMUT_02
(
@acy_nf    smallint
)
as

/***************************************************

Programme: PtTRAITCOMMUT_02

Fichier script associé : BEXP_PtTRAITCOMMUT_02.prc

Base principale : BCTA

Version: 1

Auteur: JFVDE

Date de creation: 04/10/2006

Description du programme:

              gestion des années de comptes pour les comptes complets
              génération des AC manquantes
Parametres:
Commentaires:

Auteur          | Date        |Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 19/07/2007  | [001] MAJ de la dernière période des CC pour la commutation C.N.A. ===> (1 6 2007)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
J. Ribot        | 13/03/2008  | [15180] ajout d'un order by après le group by en respectant les mêmes champs
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 20/05/2010  | [19484] MAJ de la dernière période des CC pour la commutation RELIANCE ===> (1 3 2010)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
van de velde    | 11/03/2011  | [21461] MAJ de la dernière période des CC pour la commutation AXA ===> (1 3 2011)
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------


*****************************************************/

declare @erreur int

IF OBJECT_ID('#TCTRCED_CC') is not null DROP TABLE #TCTRCED_CC
IF OBJECT_ID('#TCC_ANO') is not null DROP TABLE #TCC_ANO

create table #TCTRCED_CC
    (
    SSD_CF          ussd_cf,
    ESB_CF          uesb_cf,
    CTR_NF          uctr_nf,
    CED_NF          ucli_nf  NULL
    )

create table #TCC_ANO
(
    minACY      int,
    maxACY      int,
    ctr_nf      uctr_nf
)

-- select "La liste des contrats repris:  "
INSERT into #TCTRCED_CC
SELECT distinct
       tcontr.SSD_CF,
       tcontr.ACCESB_CF,
       tcontr.CTR_NF,
       null

FROM	btrt..TCONTR tcontr,
	    btravi..CNC_CNCD2000_COMMUTCTRPROP commut

where tcontr.CTR_NF = commut.CTR_NF
and (m_acy_nf != 9999 or glt_acy_nf != 9999)  -- contrats avec mvts compta technique ou avec réserve (glt)


update #TCTRCED_CC
SET t0.CED_NF = t1.CED_NF

FROM #TCTRCED_CC t0,
     btrt..TCONTR t1
WHERE  t0.CTR_NF = t1.CTR_NF
and    t1.UWY_NF = (select max(UWY_NF) from btrt..TCONTR t2
                    where  t2.CTR_NF = t0.CTR_NF)

-- sélection de min(a.ACY_NF) et max(a.ACY_NF) pour ces contrats"
--***************************************************************

insert into #TCC_ANO
select distinct min(a.ACY_NF) minACY,
		max(a.ACY_NF) maxACY,
		a.CTR_NF --, NULL

FROM 	bexp..EXP_ACT_TABLE a,
		  #TCTRCED_CC b

WHERE a.CTR_NF = b.CTR_NF
group by a.CTR_NF
order by a.CTR_NF

--from bcta..TACCTRN a ,btravi..CNC_CNCD2000_COMMUTCTRPROP b
--select * from  #TCC_ANO order by minacy,maxacy,ctr_nf

--sélection ACY_min et max absent
--*******************************
select distinct b.CTR_NF,
                12                                      SCOENDMTH_NF,
                1                                       SCOSTRMTH_NF,
                b.minACY                                ACY_NF,
                a.SSD_CF,
                a.ESB_CF,
                --convert(char(4),b.minACY+1) + "1231"    BLCSHT_D,
                getdate() 				                      BLCSHT_D,
                a.ced_nf                                CED_NF,
                convert(char(8),getdate(),112)          LSTUPD_D,
                'DBC'                                   LSTUPDUSR_CF,
                1 PRNSTS_B
FROM #TCC_ANO b,
     #TCTRCED_CC a

WHERE not exists ( select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.minACY)
  and not exists ( select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.maxACY)
  and b.ctr_nf = a.ctr_nf

UNION

select distinct b.CTR_NF,
                12                                      SCOENDMTH_NF,
                1                                       SCOSTRMTH_NF,
                b.maxACY                                ACY_NF,
                a.SSD_CF,
                a.ESB_CF,
                --convert(char(4),b.maxACY+1) + "1231"  BLCSHT_D,
                getdate()				BLCSHT_D,
                a.ced_nf                                CED_NF,
                convert(char(8),getdate(),112)          LSTUPD_D,
                'DBC'                                   LSTUPDUSR_CF,
                1 PRNSTS_B

FROM #TCC_ANO b,
     #TCTRCED_CC a

WHERE not exists ( select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.minACY)
  and not exists ( select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.maxACY)
  and b.ctr_nf = a.ctr_nf

UNION

-- selection ACY_min absent uniquement
--************************************
select distinct b.CTR_NF,
                12                                     SCOENDMTH_NF,
                1                                      SCOSTRMTH_NF,
                b.minACY                               ACY_NF,
                a.SSD_CF,
                a.ESB_CF,
                --convert(char(4),b.minACY+1) + "1231" BLCSHT_D,
                getdate()				                       BLCSHT_D,
                a.ced_nf                               CED_NF,
                convert(char(8),getdate(),112)         LSTUPD_D,
                'DBC'                                  LSTUPDUSR_CF,
                1                                      PRNSTS_B
FROM #TCC_ANO b,
     #TCTRCED_CC a

WHERE not exists (select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.minACY)
      and exists (select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.maxACY)
      and b.ctr_nf = a.ctr_nf
UNION

-- selection ACY_max absent uniquement
--*************************************
select distinct b.CTR_NF,
                12                                     SCOENDMTH_NF,
                1                                      SCOSTRMTH_NF,
                b.maxACY                               ACY_NF,
                a.SSD_CF,
                a.ESB_CF,
                --convert(char(4),b.maxACY+1) + "1231" BLCSHT_D,
                getdate()				                       BLCSHT_D,
                a.ced_nf                               CED_NF,
                convert(char(8),getdate(),112)         LSTUPD_D,
                'DBC'                                  LSTUPDUSR_CF,
                1                                      PRNSTS_B

FROM #TCC_ANO b,
     #TCTRCED_CC a

WHERE exists ( select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.minACY)
  and not exists ( select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.maxACY)
  and b.ctr_nf = a.ctr_nf
and not exists ( select 1 from bcta..TCPLACC tcp where tcp.CTR_NF = b.CTR_NF and tcp.SSD_CF = a.SSD_CF
                     and tcp.ACY_NF = b.maxACY-1 )

UNION
--selection ACY min présent mais pas de première période
--*******************************************************
select distinct b.CTR_NF,
                1                                       SCOENDMTH_NF,
                1                                       SCOSTRMTH_NF,
                b.minACY                                ACY_NF,
                a.SSD_CF,
                a.ESB_CF,
                --convert(char(4),b.minACY+1) + "0101"  BLCSHT_D,
                getdate()				                        BLCSHT_D,
                a.ced_nf                                CED_NF,
                convert(char(8),getdate(),112)          LSTUPD_D,
                'DBC'                                   LSTUPDUSR_CF,
                1 PRNSTS_B

FROM #TCC_ANO b,
     #TCTRCED_CC a

WHERE exists (select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.minACY)
  and not exists ( select 1 from bcta..TCPLACC c where c.CTR_NF = b.CTR_NF and c.ACY_NF = b.minACY
                    and SCOSTRMTH_NF = 1)
  and b.ctr_nf = a.ctr_nf

--génération de la dernière AC cc 1-3-AAAA pour tous les contrats commutés AXA
-- possédant au mois une dernière AC
UNION
-- INSERT into bcta..TCPLACC
select distinct b.CTR_NF,
                3                                       SCOENDMTH_NF,		-- [21461]
                1                                       SCOSTRMTH_NF,		-- [21461]
                @ACY_NF                                 ACY_NF,
                a.SSD_CF,
                a.ESB_CF,
                getdate()                               BLCSHT_D,
                b.ced_nf                                CED_NF,
                convert(char(8),getdate(),112)          LSTUPD_D,
                'DBC'                                   LSTUPDUSR_CF,
                1                                       PRNSTS_B
FROM bcta..TCPLACC a,
     #TCTRCED_CC b

WHERE b.ctr_nf = a.ctr_nf
go

-- Granting/Revoking Permissions on dbo.PtTRAITCOMMUT_02

GRANT EXECUTE ON dbo.PtTRAITCOMMUT_02 TO GOMEGA
go
IF OBJECT_ID('dbo.PtTRAITCOMMUT_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PtTRAITCOMMUT_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PtTRAITCOMMUT_02 >>>'
go
