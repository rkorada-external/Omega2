--Ajout des champs
USE BSTA
ALTER TABLE BSTA..TLIFSTAREP
ADD CBP2MNT_M UAMT_M NULL
ALTER TABLE BSTA..TLIFSTAREP
ADD CBP3MNT_M UAMT_M NULL
ALTER TABLE BSTA..TLIFSTAREP
ADD CBP4MNT_M UAMT_M NULL
ALTER TABLE BSTA..TLIFSTAREP
ADD CBP5MNT_M UAMT_M NULL

ALTER TABLE BSTA..TLIFSTAREP
ADD PA1MNTNB_M UAMT_M NULL
ALTER TABLE BSTA..TLIFSTAREP
ADD PA3MNTNB_M UAMT_M NULL
ALTER TABLE BSTA..TLIFSTAREP
ADD PA4MNTNB_M UAMT_M NULL
ALTER TABLE BSTA..TLIFSTAREP
ADD PA5MNTNB_M UAMT_M NULL

ALTER TABLE BSTA..TLIFSTAREP
ADD PR1MNTNB_M UAMT_M NULL
ALTER TABLE BSTA..TLIFSTAREP
ADD PR3MNTNB_M UAMT_M NULL
ALTER TABLE BSTA..TLIFSTAREP
ADD PR4MNTNB_M UAMT_M NULL
ALTER TABLE BSTA..TLIFSTAREP
ADD PR5MNTNB_M UAMT_M NULL



USE BSTA
GO
--Calcul des complements
SELECT TOP 10 NEWBIZ_R FROM BEST..TLIFNEWBIZ b
SELECT TOP 10 r.COLVAL_LS FROM BREF..TBANTECL r WHERE r.COLVAL_LS like '___1%'
--SELECT convert(char(26),'21/12/2002',103)
--SELECT datepart(year,CLODAT_D) FROM BSTA..TLIFSTAREP
--PRINT CAST(‘2002-12-21' AS DATETIME) 




GO
IF OBJECT_ID('dbo.PuLIFSTAREP_04') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuLIFSTAREP_04
    IF OBJECT_ID('dbo.PuLIFSTAREP_04') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuLIFSTAREP_04 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuLIFSTAREP_04 >>>'
END
GO
create procedure PuLIFSTAREP_04(@P_CLODAT_D datetime = null)
as
/***************************************************************************
Programme                : BSTA_PuLIFSTAREP_04.prc
Auteur                   : D.GATIBELZA
Date de creation         : 04/01/2010
Description du programme : :spot:17932 NEW Business
Parametres               :
Conditions d'execution   : Appelée par le STAD1551.cmd
Commentaires             : ventilation des montants des affaires nouvelles sur 3 années en fonction d'une table de ventilation, A faire - la devise des postes

________________
MODIFICATION   : [001]
Auteur         : P.COPPIN
Date           : 19/08/2013
Version        : 01.1
Description    : :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2.
*****************************************************************/

declare @erreur     Int,
        @lignes     integer,
        @MAJ_M      char(26) -- date pour l'affichage du temps de traitement

-- UNITS TESTS
--declare @P_CLODAT_D datetime
select @P_CLODAT_D= '20021221'
if @P_CLODAT_D= ' '
    set @P_CLODAT_D=null
    
print 'Arg end entree',  @P_CLODAT_D  

create TABLE #LIFSTAREP (
    CLODAT_D     datetime       NOT NULL,
    SSD_CF       USSD_CF        NOT NULL,
    CTR_NF       UCTR_NF        NOT NULL,
    END_NT       UEND_NT        NOT NULL,
    SEC_NF       USEC_NF        NOT NULL,
    UWY_NF       UUWY_NF        NOT NULL,
    UW_NT        UUW_NT         NOT NULL,
    PLC_NT       UPLC_NT        NOT NULL,
    ACCRET_CF    char(1)        NOT NULL,
    ACY_NF       smallint       NOT NULL,
    ACMTRS_NT    smallint       NOT NULL,
    CUR_CF       UCUR_CF        NOT NULL,
    ORDRE_NT     smallint       NOT NULL,
    CALC_NT      smallint       NOT NULL,
    GROUPE_NT    smallint       NOT NULL,
    SIGNE_N      smallint       NOT NULL,
    NEWBIZ_R     USHA_R         NOT NULL,
    PAMNT_M      UAMT_M             NULL,
    PRMNT_M      UAMT_M             NULL,
    PAMNTNB_M    UAMT_M             NULL,
    PRMNTNB_M    UAMT_M             NULL,
    CED_NF       UCLI_NF            NULL,
    SECSTS_CT    UCTRSTS_CT     NOT NULL,
    SECACCSTS_CT UACCSTS_CT         NULL,
    ACCADMTYP_CT UACCADMTYP_CT      NULL,
    ESTCRB_CT    char(1)            NULL,
    ESTCTR_NF    UCTR_NF            NULL,
    ESTSEC_NF    USEC_NF            NULL,
    COMACC_B     bit  DEFAULT 0 NOT NULL,
    AUTUPD_B     bit  DEFAULT 0 NOT NULL,
    YNEWCTR_B    bit  DEFAULT 0 NOT NULL,
    TNEWCTR_B    bit  DEFAULT 0 NOT NULL,
    CLMCUTOFF_B  bit  DEFAULT 0 NOT NULL,
    PRMCUTOFF_B  bit  DEFAULT 0 NOT NULL,
    CLMRUNOFF_B  bit  DEFAULT 0 NOT NULL,
    PRMRUNOFF_B  bit  DEFAULT 0 NOT NULL,
    INSERT_B     bit  NOT NULL,
     -------------------- NOUVEAU CHAMPS NEWBIZ
    DETTRNCOD_CF	char(5)            NOT NULL,
    ORICTR_NF	UCTR_NF			  NOT NULL,
    ORISEC_NF	    USEC_NF              NOT NULL,
    ORIUWY_NF	UUWY_NF             NOT NULL,
    CBP1MNT_M   UAMT_M             NULL,
    CBP3MNT_M   UAMT_M             NULL,
    CBP4MNT_M   UAMT_M             NULL,
    CBP5MNT_M   UAMT_M             NULL,
    PA1MNTNB_M UAMT_M             NULL,
    PA3MNTNB_M UAMT_M             NULL,
    PA4MNTNB_M UAMT_M             NULL,
    PA5MNTNB_M UAMT_M             NULL,
    PR1MNTNB_M UAMT_M             NULL,
    PR3MNTNB_M UAMT_M             NULL,
    PR4MNTNB_M UAMT_M             NULL,
    PR5MNTNB_M UAMT_M             NULL,
    -------------------- NOUVEAU CHAMPS NEWBIZ

    
)

--CREATE UNIQUE CLUSTERED INDEX ILIF_STAREP_00
--    ON #LIFSTAREP(CLODAT_D,SSD_CF,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,PLC_NT,ACCRET_CF,ACY_NF,ACMTRS_NT,CUR_CF)

-- TRIPERT
CREATE TABLE #TUWSEC
(
    CTR_NF       UCTR_NF        NOT NULL,
    UWY_NF       UUWY_NF      NOT NULL,
    SEC_NF       USEC_NF          NOT NULL,
    SSD_CF       USSD_CF          NOT NULL,
    NAT_CF       CHAR(2)          NULL
)


CREATE TABLE #TUWSEC2
(
    CTR_NF       UCTR_NF       NOT NULL
)


INSERT  #TUWSEC
SELECT  a.CTR_NF,
        a.UWY_NF,
        a.SEC_NF,
        a.SSD_CF,
        a.NAT_CF
FROM    BSBO..TUWSEC a, BREF..TBATCHSSD T 

WHERE a.SSD_CF = T.SSD_CF 
and   T.BATCHUSER_CF = suser_name()

select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Insertion TUWSEC',@lignes,@MAJ_M



INSERT  #TUWSEC
SELECT  a.RETCTR_NF,
        a.RTY_NF,
        a.RETSEC_NF,
        a.SSD_CF,
        a.NAT_CF
FROM    BSBO..TUWRETSEC a, BREF..TBATCHSSD T

WHERE a.SSD_CF = T.SSD_CF 
and   T.BATCHUSER_CF = suser_name()


select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Insertion TUWRETSEC',@lignes,@MAJ_M



INSERT  #TUWSEC2
SELECT  distinct a.CTR_NF
FROM    #TUWSEC a, best..tlifnewbiz b
where   a.CTR_NF = b.CTR_NF


select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Insertion #TUWSEC2',@lignes,@MAJ_M



-- TRIPERT

--insert #LIFSTAREP
select a.CLODAT_D
      ,a.SSD_CF
      ,a.CTR_NF
      ,a.END_NT
      ,a.SEC_NF
      ,a.UWY_NF
      ,a.UW_NT
      ,a.PLC_NT
      ,a.ACCRET_CF
      ,a.ACY_NF
      ,a.ACMTRS_NT
      ,a.CUR_CF
      ,ORDRE_NT=convert(smallint,substring(r.COLVAL_LS,1,2))
      ,CALC_NT=convert(tinyint,substring(r.COLVAL_LS,4,1))
      ,GROUPE_NT=convert(tinyint,substring(r.COLVAL_LS,9,1))                                                                                 -- le signe est inversé pour la retrocession
      ,SIGNE_N=case when isnull((select ADJSIG_B from BEST..TACCPAR where ACMTRS_NT=convert(smallint,r.COLVAL_CT)),1)=0 then -1 else 1 end * case when a.ACCRET_CF='R' then -1 else 1 end
      ,b.NEWBIZ_R
      ,a.PAMNT_M
      ,a.PRMNT_M
      ,PAMNTNB_M=case when r.COLVAL_LS like '___1%' then round(a.PAMNT_M * b.NEWBIZ_R,3) else 0 end
      ,PRMNTNB_M=case when r.COLVAL_LS like '___1%' then round(a.PRMNT_M * b.NEWBIZ_R,3) else 0 end
      ,CED_NF
      ,SECSTS_CT
      ,SECACCSTS_CT
      ,ACCADMTYP_CT
      ,ESTCRB_CT
      ,ESTCTR_NF
      ,ESTSEC_NF
      ,COMACC_B
      ,AUTUPD_B
      ,YNEWCTR_B
      ,TNEWCTR_B
      ,CLMCUTOFF_B
      ,PRMCUTOFF_B
      ,CLMRUNOFF_B
      ,PRMRUNOFF_B
      ,INSERT_B=0
     -------------------- NOUVEAU CHAMPS NEWBIZ
    ,DETTRNCOD_CF
    ,ORICTR_NF
    ,ORISEC_NF
    ,ORIUWY_NF
    ,CBP1MNT_M
    ,CBP3MNT_M
    ,CBP4MNT_M
    ,CBP5MNT_M
    ,PA1MNTNB_M=case when r.COLVAL_LS like '___1%' then round(a.PA1MNT_M * b.NEWBIZ_R,3) else 0 end
    ,PA3MNTNB_M=case when r.COLVAL_LS like '___1%' then round(a.PA3MNT_M * b.NEWBIZ_R,3) else 0 end
    ,PA4MNTNB_M=case when r.COLVAL_LS like '___1%' then round(a.PA4MNT_M * b.NEWBIZ_R,3) else 0 end
    ,PA5MNTNB_M=case when r.COLVAL_LS like '___1%' then round(a.PA5MNT_M * b.NEWBIZ_R,3) else 0 end
    ,PR1MNTNB_M
    ,PR3MNTNB_M
    ,PR4MNTNB_M
    ,PR5MNTNB_M
    -------------------- NOUVEAU CHAMPS NEWBIZ
from BSTA..TLIFSTAREP a, BEST..TLIFNEWBIZ b, BREF..TBANTECL r, #TUWSEC c
where r.COL_LS='NEWBIZ_CT'
  and r.LAG_CF='F'
  and b.ACMTRS_NT=convert(smallint,r.COLVAL_CT)
  and b.CTR_NF=a.CTR_NF
  and b.END_NT=a.END_NT
  and b.SEC_NF=a.SEC_NF
  and b.ACMTRS_NT=a.ACMTRS_NT
  and b.CRE_D=(select max(CRE_D) from BEST..TLIFNEWBIZ z where z.CTR_NF=b.CTR_NF and z.END_NT=b.END_NT and z.SEC_NF=b.SEC_NF and z.ACMTRS_NT=b.ACMTRS_NT and z.ACY_NF=b.ACY_NF)
  and a.CLODAT_D=@p_CLODAT_D
  and a.ACCADMTYP_CT in(1,3)
  and a.ACY_NF between datepart(year,a.CLODAT_D) and datepart(year,a.CLODAT_D) + 2
  and a.ACY_NF=b.ACY_NF + datepart(year,a.CLODAT_D)
  and a.CTR_NF=c.CTR_NF
  and a.UWY_NF=c.UWY_NF
  and a.SEC_NF=c.SEC_NF
  and a.SSD_CF=c.SSD_CF
  
-- Proportionnel
  and convert(integer,c.NAT_CF) < 30






select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Insertion #LIFSTAREP, postes existant dans TLIFSTAREP et BEST..TLIFNEWBIZ par TRT/SEC/AC	lignes	%1!	%2!',@lignes,@MAJ_M

delete #LIFSTAREP
from #LIFSTAREP a
where exists ( select 1 from #LIFSTAREP z
               where z.CALC_NT=1
                 and z.PAMNT_M=0
                 and z.PRMNT_M=0
                 and a.CLODAT_D=z.CLODAT_D
                 and a.SSD_CF=z.SSD_CF
                 and a.CTR_NF=z.CTR_NF
                 and a.END_NT=z.END_NT
                 and a.SEC_NF=z.SEC_NF
                 and a.UWY_NF=z.UWY_NF
                 and a.UW_NT=z.UW_NT
                 and a.PLC_NT=z.PLC_NT
                 and a.ACCRET_CF=z.ACCRET_CF
                 and a.ACY_NF=z.ACY_NF
                 and a.CUR_CF=z.CUR_CF )

select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Suppression quand prime(PAMNT_M,PRMNT_M)=0	lignes	-%1!	%2!',@lignes,@MAJ_M

print 'Constrcution de la #LIFNEWBIZS'

select
      a.ctr_nf,
      a.end_nt,
      a.sec_nf,
      datepart(year,@P_CLODAT_D) + a.acy_nf acy_nf_new,
      a.acy_nf,
      a.acmtrs_nt,
      a.cre_d,
      a.newbiz_r
into #LIFNEWBIZ
from best..tlifnewbiz a, #TUWSEC2 b
where a.ctr_nf = b.ctr_nf


-- ligne modèle est la ligne de prime de TLIFSTAREP
insert #LIFSTAREP
select distinct a.CLODAT_D
               ,a.SSD_CF
               ,a.CTR_NF
               ,a.END_NT
               ,a.SEC_NF
               ,a.UWY_NF
               ,a.UW_NT
               ,a.PLC_NT
               ,a.ACCRET_CF
               ,a.ACY_NF
               ,b.ACMTRS_NT  -- de BEST..TLIFNEWBIZ !
               ,a.CUR_CF
               ,ORDRE_NT=convert(smallint,substring(r.COLVAL_LS,1,2))
               ,CALC_NT=convert(tinyint,substring(r.COLVAL_LS,4,1))
               ,GROUPE_NT=convert(tinyint,substring(r.COLVAL_LS,9,1))                                                                                 -- le signe est inversé pour la retrocession
               ,SIGNE_N=case when isnull((select ADJSIG_B from BEST..TACCPAR where ACMTRS_NT=convert(smallint,r.COLVAL_CT)),1)=0 then -1 else 1 end * case when a.ACCRET_CF='R' then -1 else 1 end
               ,b.NEWBIZ_R
               ,PAMNT_M=0
               ,PRMNT_M=0
               ,PAMNTNB_M=0
               ,PRMNTNB_M=0
               ,CED_NF
               ,SECSTS_CT
               ,SECACCSTS_CT
               ,ACCADMTYP_CT
               ,ESTCRB_CT
               ,ESTCTR_NF
               ,ESTSEC_NF
               ,COMACC_B
               ,AUTUPD_B
               ,YNEWCTR_B
               ,TNEWCTR_B
               ,CLMCUTOFF_B
               ,PRMCUTOFF_B
               ,CLMRUNOFF_B
               ,PRMRUNOFF_B
               ,INSERT_B=1
               -------------------- NOUVEAU CHAMPS NEWBIZ
                ,DETTRNCOD_CF
                ,ORICTR_NF
                ,ORISEC_NF
                ,ORIUWY_NF
                ,CBP1MNT_M
                ,CBP3MNT_M
                ,CBP4MNT_M
                ,CBP5MNT_M
                ,PA1MNTNB_M
                ,PA3MNTNB_M
                ,PA4MNTNB_M
                ,PA5MNTNB_M
                ,PR1MNTNB_M
                ,PR3MNTNB_M
                ,PR4MNTNB_M
                ,PR5MNTNB_M
                -------------------- NOUVEAU CHAMPS NEWBIZ
from #LIFSTAREP a, #LIFNEWBIZ b, BREF..TBANTECL r
where r.COL_LS='NEWBIZ_CT'
  and r.LAG_CF='F'
  and a.CALC_NT=1
  and b.ACMTRS_NT=convert(smallint,r.COLVAL_CT)
  and b.CTR_NF=a.CTR_NF
  and b.END_NT=a.END_NT
  and b.SEC_NF=a.SEC_NF
  and b.acy_nf_new = a.acy_nf
  and not exists ( select 1
                   from #LIFSTAREP y
                   where b.ACMTRS_NT=y.ACMTRS_NT
                     and a.CLODAT_D=y.CLODAT_D
                     and a.SSD_CF=y.SSD_CF
                     and a.CTR_NF=y.CTR_NF
                     and a.END_NT=y.END_NT
                     and a.SEC_NF=y.SEC_NF
                     and a.UWY_NF=y.UWY_NF
                     and a.UW_NT=y.UW_NT
                     and a.PLC_NT=y.PLC_NT
                     and a.ACCRET_CF=y.ACCRET_CF
                     and a.ACY_NF=y.ACY_NF
                     and a.CUR_CF=y.CUR_CF )
  and b.CRE_D = ( select max(CRE_D)
                  from #LIFNEWBIZ z
                  where z.CTR_NF=b.CTR_NF
                    and z.END_NT=b.END_NT
                    and z.SEC_NF=b.SEC_NF
                    and z.ACMTRS_NT=b.ACMTRS_NT
                    and z.ACY_NF=b.ACY_NF )

select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Insertion des postes manquants qu''on a dans BEST..TLIFNEWBIZ mais pas dans TLIFSTAREP	lignes	%1!	%2!',@lignes,@MAJ_M

update #LIFSTAREP
   set PAMNTNB_M=round(z.PAMNTNB_M * a.NEWBIZ_R,3) * a.SIGNE_N
      ,PRMNTNB_M=round(z.PRMNTNB_M * a.NEWBIZ_R,3) * a.SIGNE_N
from #LIFSTAREP a, #LIFSTAREP z
where a.CALC_NT=2
  and z.CALC_NT=1
  and a.CLODAT_D=z.CLODAT_D
  and a.SSD_CF=z.SSD_CF
  and a.CTR_NF=z.CTR_NF
  and a.END_NT=z.END_NT
  and a.SEC_NF=z.SEC_NF
  and a.UWY_NF=z.UWY_NF
  and a.UW_NT=z.UW_NT
  and a.PLC_NT=z.PLC_NT
  and a.ACCRET_CF=z.ACCRET_CF
  and a.ACY_NF=z.ACY_NF
  and a.CUR_CF=z.CUR_CF

select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Maj pour le calcul type 2	lignes	%1!	%2!',@lignes,@MAJ_M

select CLODAT_D,
       SSD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       PLC_NT,
       ACCRET_CF,
       ACY_NF,
       CUR_CF,
       PAMNTNB_M=sum(PAMNTNB_M),
       PRMNTNB_M=sum(PRMNTNB_M)
into #res_LIFSTAREP
from #LIFSTAREP
where GROUPE_NT=1
group by CLODAT_D,SSD_CF,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,PLC_NT,ACCRET_CF,ACY_NF,CUR_CF
order by CLODAT_D,SSD_CF,CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,PLC_NT,ACCRET_CF,ACY_NF,CUR_CF

select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Insert #res_LIFSTAREP, sommes des postes de réserves	lignes	%1!	%2!',@lignes,@MAJ_M

update #LIFSTAREP
   set PAMNTNB_M=round(z.PAMNTNB_M * a.NEWBIZ_R,3),
       PRMNTNB_M=round(z.PRMNTNB_M * a.NEWBIZ_R,3)
from #LIFSTAREP a, #res_LIFSTAREP z
where a.CALC_NT=4
  and a.CLODAT_D=z.CLODAT_D
  and a.SSD_CF=z.SSD_CF
  and a.CTR_NF=z.CTR_NF
  and a.END_NT=z.END_NT
  and a.SEC_NF=z.SEC_NF
  and a.UWY_NF=z.UWY_NF
  and a.UW_NT=z.UW_NT
  and a.PLC_NT=z.PLC_NT
  and a.ACCRET_CF=z.ACCRET_CF
  and a.ACY_NF=z.ACY_NF
  and a.CUR_CF=z.CUR_CF

select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Maj dépots	lignes	%1!	%2!',@lignes,@MAJ_M

update #LIFSTAREP
   set PAMNTNB_M=round(z.PAMNTNB_M * a.NEWBIZ_R * -1,3),
       PRMNTNB_M=round(z.PRMNTNB_M * a.NEWBIZ_R * -1,3)
from #LIFSTAREP a, #LIFSTAREP z
where a.CALC_NT=5
  and z.CALC_NT=4
  and a.CLODAT_D=z.CLODAT_D
  and a.SSD_CF=z.SSD_CF
  and a.CTR_NF=z.CTR_NF
  and a.END_NT=z.END_NT
  and a.SEC_NF=z.SEC_NF
  and a.UWY_NF=z.UWY_NF
  and a.UW_NT=z.UW_NT
  and a.PLC_NT=z.PLC_NT
  and a.ACCRET_CF=z.ACCRET_CF
  and a.ACY_NF=z.ACY_NF
  and a.CUR_CF=z.CUR_CF

select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
if @erreur!=0
    goto fin_erreur
print 'Maj interêts sur dépots	lignes	%1!	%2!',@lignes,@MAJ_M

begin tran
    -- TRIPERT 28/04/2010
    update BSTA..TLIFSTAREP
       set PAMNTNB_M=0,
           PRMNTNB_M=0
           from BSTA..TLIFSTAREP a, BREF..TBATCHSSD T
           where a.clodat_d = @P_CLODAT_D
           and   a.SSD_CF = T.SSD_CF
           and   T.BATCHUSER_CF = suser_name()
    -- FIN TRIPERT


    update BSTA..TLIFSTAREP
       set PAMNTNB_M=b.PAMNTNB_M,
           PRMNTNB_M=b.PRMNTNB_M,
           LSTUPD_D=getdate()
    from BSTA..TLIFSTAREP a, #LIFSTAREP b
    where a.CLODAT_D=b.CLODAT_D
      and a.SSD_CF=b.SSD_CF
      and a.CTR_NF=b.CTR_NF
      and a.END_NT=b.END_NT
      and a.SEC_NF=b.SEC_NF
      and a.UWY_NF=b.UWY_NF
      and a.UW_NT=b.UW_NT
      and a.PLC_NT=b.PLC_NT
      and a.ACCRET_CF =b.ACCRET_CF
      and a.ACY_NF=b.ACY_NF
      and a.ACMTRS_NT =b.ACMTRS_NT
      and a.CUR_CF=b.CUR_CF

    select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
    if @erreur!=0
        goto fin_erreur
    print 'Maj TLIFSTAREP	lignes	%1!	%2!',@lignes,@MAJ_M

   insert BSTA..TLIFSTAREP ( CLODAT_D ,SSD_CF ,CTR_NF ,END_NT ,SEC_NF ,UWY_NF ,UW_NT ,PLC_NT ,ACCRET_CF ,ACY_NF ,ACMTRS_NT ,CUR_CF ,
                        CBNMNT_M ,CBPMNT_M ,PCMNT_M ,PAMNT_M ,PRMNT_M ,CED_NF ,SECSTS_CT ,SECACCSTS_CT ,ACCADMTYP_CT ,ESTCRB_CT,
                        ESTCTR_NF ,ESTSEC_NF ,COMACC_B ,AUTUPD_B ,YNEWCTR_B ,TNEWCTR_B ,CLMCUTOFF_B ,PRMCUTOFF_B ,CLMRUNOFF_B,
                        PRMRUNOFF_B ,LSTUPD_D ,PAMNTNB_M ,PRMNTNB_M,
                        ---------------------------------------------------------
                        DETTRNCOD_CF,
                        ORICTR_NF,
                        ORISEC_NF,
                        ORIUWY_NF,
                        CBP1MNT_M,
                        CBP3MNT_M,
                        CBP4MNT_M,
                        CBP5MNT_M,
                        PA1MNTNB_M,
                        PA3MNTNB_M,
                        PA4MNTNB_M,
                        PA5MNTNB_M,
                        PR1MNTNB_M,
                        PR3MNTNB_M,
                        PR4MNTNB_M,
                        PR5MNTNB_M
                        ---------------------------------------------------------------
                        )
    select CLODAT_D ,
                        SSD_CF ,
                        CTR_NF ,
                        END_NT ,
                        SEC_NF ,
                        UWY_NF,
                        UW_NT ,PLC_NT ,ACCRET_CF ,ACY_NF ,ACMTRS_NT ,CUR_CF,
                        CBNMNT_M=0,
                        CBPMNT_M=0,
                        PCMNT_M = 0,
                        PAMNT_M = 0,
                        PRMNT_M = 0,
                        CED_NF ,
                        SECSTS_CT ,
                        SECACCSTS_CT ,
                        ACCADMTYP_CT ,
                        ESTCRB_CT,
                        ESTCTR_NF ,
                        ESTSEC_NF ,
                        COMACC_B ,
                        AUTUPD_B ,
                        YNEWCTR_B ,
                        TNEWCTR_B ,
                        CLMCUTOFF_B ,
                        PRMCUTOFF_B ,
                        CLMRUNOFF_B,
                        PRMRUNOFF_B ,
                        LSTUPD_D=getdate(),
                        PAMNTNB_M,
                        PRMNTNB_M,
                        ------------------------------------------------
                        DETTRNCOD_CF,
                        ORICTR_NF,
                        ORISEC_NF,
                        ORIUWY_NF,
                        CBP1MNT_M,
                        CBP3MNT_M,
                        CBP4MNT_M,
                        CBP5MNT_M,
                        PA1MNTNB_M,
                        PA3MNTNB_M,
                        PA4MNTNB_M,
                        PA5MNTNB_M,
                        PR1MNTNB_M,
                        PR3MNTNB_M,
                        PR4MNTNB_M,
                        PR5MNTNB_M
                        ------------------------------------------------
    from #LIFSTAREP a
    where a.INSERT_B=1
      and not exists ( select 1
                       from BSTA..TLIFSTAREP b
                       where b.CLODAT_D = a.CLODAT_D
                         and b.SSD_CF   = a.SSD_CF
                         and b.CTR_NF   = a.CTR_NF
                         and b.END_NT   = a.END_NT
                         and b.SEC_NF   = a.SEC_NF
                         and b.UWY_NF   = a.UWY_NF
                         and b.UW_NT    = a.UW_NT
                         and b.PLC_NT   = a.PLC_NT
                         and b.ACCRET_CF= a.ACCRET_CF
                         and b.ACY_NF   = a.ACY_NF
                         and b.ACMTRS_NT= a.ACMTRS_NT )
                         
                         
                       

    select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
    if @erreur!=0
        goto fin_erreur
    print 'insertion TLIFSTAREP, postes manquants de TLIFNEWBIZ	lignes	%1!	%2!',@lignes,@MAJ_M

    

    update BSTA..TLIFSTAREP
       set PAMNTNB_M=PAMNT_M,
           PRMNTNB_M=PRMNT_M
      from BSTA..TLIFSTAREP a, #TUWSEC b
     where a.CLODAT_D=@P_CLODAT_D
       and a.ACY_NF between datepart(year,CLODAT_D) and datepart(year,CLODAT_D) + 2
       and a.ACCADMTYP_CT=2
       and a.ACY_NF = a.UWY_NF
       and a.CTR_NF = b.CTR_NF
       and a.UWY_NF = b.UWY_NF
       and a.SEC_NF = b.SEC_NF


   

    update BSTA..TLIFSTAREP
       set PAMNTNB_M=PAMNT_M,
           PRMNTNB_M=PRMNT_M
      from BSTA..TLIFSTAREP a, #TUWSEC b
     where a.CLODAT_D=@P_CLODAT_D
       and a.ACY_NF between datepart(year,CLODAT_D) and datepart(year,CLODAT_D) + 2
       and a.ACCADMTYP_CT in (1,3)
       and a.CTR_NF   = b.CTR_NF
       and a.UWY_NF   = b.UWY_NF
       and a.SEC_NF   = b.SEC_NF
       and convert(integer,b.NAT_CF) >= 30

    select @erreur=@@error,@lignes=@@rowcount,@MAJ_M=convert(char(26),getdate(),109)
    if @erreur!=0
        goto fin_erreur
    print 'Maj TLIFSTAREP NON PROP ACCADMTYP_CT in (1,3) et ACY_NF=UWY_NF	lignes	%1!	%2!',@lignes,@MAJ_M

if @@trancount > 0
    commit tran
return 0

fin_erreur:
select @erreur=@@error,@MAJ_M=convert(char(26),getdate(),109)
print 'Fin erreur PuLIFSTAREP_04	lignes	%1!	%2!',@lignes,@MAJ_M
if @@trancount > 0
    rollback tran
return 1
GO
EXEC sp_procxmode 'dbo.PuLIFSTAREP_04', 'unchained'
GO
IF OBJECT_ID('dbo.PuLIFSTAREP_04') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuLIFSTAREP_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuLIFSTAREP_04 >>>'
GO

GRANT EXECUTE ON dbo.PuLIFSTAREP_04 TO GOMEGA
GO

GRANT EXECUTE ON dbo.PuLIFSTAREP_04 TO GDBBATCH
GO




