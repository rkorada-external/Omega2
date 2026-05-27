USE BEST
go

-- DROP PROC dbo.PiLIFEST_04
IF OBJECT_ID('dbo.PiLIFEST_04') IS NOT NULL
begin
    DROP PROC dbo.PiLIFEST_04
    PRINT '<<< DROPPED PROC dbo.PiLIFEST_04 >>>'
end
go

-- creation de la procedure
create procedure dbo.PiLIFEST_04
(
   @p_balshey_nf    smallint,
   @p_balshtmth_nf  tinyint
)
as
/***************************************************
Programme :               PiLIFEST_04
JOB associé :             ESTD3000
Base principale :         BEST
Version :                 1
Auteur :                  Roger Cassis
Date de creation :        27/11/2009
Description du programme: :spot:18415 Genere mouvements avec montants a zero dans best..tlifest sur les max cre_d des max(bilan/mois)
                          dans la tabe TLIFEST

[002] 13/08/2015 R. Cassis :spot:29223 Ajout colonnes pour l'evol de la TLIFEST

*****************************************************/

IF OBJECT_ID('#TLIFEST') IS NOT NULL
BEGIN
    DROP TABLE #TLIFEST
    IF OBJECT_ID('#TLIFEST') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE #TLIFEST >>>'
    ELSE
        PRINT '<<< DROPPED TABLE #TLIFEST >>>'
END

CREATE TABLE #TLIFEST
(
    CTR_NF        UCTR_NF    NOT NULL,
    END_NT        UEND_NT    NOT NULL,
    SEC_NF        USEC_NF    NOT NULL,
    UWY_NF        UUWY_NF    NOT NULL,
    UW_NT         UUW_NT     NOT NULL,
    CRE_D         UUPD_D     DEFAULT getdate() NOT NULL,
    BALSHEY_NF    smallint   NOT NULL,
    BALSHTMTH_NF  tinyint    NOT NULL,
    ACY_NF        smallint   NOT NULL,
    GAAP_NT       tinyint    NOT NULL,
    DETTRNCOD_CF  char(5)    NOT NULL,
    ACM_NF        tinyint    NOT NULL,
    PRS_CF        smallint   NOT NULL,
    ACMTRS_NT     smallint   NOT NULL,
    SSD_CF        USSD_CF    NOT NULL,
    CUR_CF        UCUR_CF    NOT NULL,
    ESTMNT_M      UAMT_M     NOT NULL,
    INDSUP_B      bit        NOT NULL,
    ORICOD_LS     UL16       NULL,
    CREUSR_CF     UUPDUSR_CF NOT NULL,
    LSTUPD_D      UUPD_D     NOT NULL,
    LSTUPDUSR_CF  UUPDUSR_CF NOT NULL,
    ORICTR_NF     UCTR_NF    NULL,
    ORISEC_NF     USEC_NF    NULL,
    ORIUWY_NF     UUWY_NF    NULL,
    DIFF_M        UAMT_M     NULL,
    PROPAGATION_B bit        NOT NULL,
    CALCULATED_B  bit        NOT NULL,
    BATCH_B       bit        NOT NULL
)

IF OBJECT_ID('#TLIFEST') IS NOT NULL
    PRINT '<<< CREATED TABLE #TLIFEST >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE #TLIFEST >>>'

CREATE UNIQUE CLUSTERED INDEX ILIFEST_00
    ON #TLIFEST(CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,CRE_D,BALSHEY_NF,BALSHTMTH_NF,ACY_NF,PRS_CF,ACMTRS_NT)


declare   @erreur       int,
          @lignes       int,
          @datej        char(20),
          @balshey_nf   smallint,
          @datejour     dateTime

select @balshey_nf = max(balshey_nf) from best..tlifest
select @datejour   = getdate()
--select @balshey_nf = 2009

print '-----> Extraction du périmètre de contrats à traiter'
select ctr_nf
into #ctrscros
from BTRT..TRFCROSSREF
where  (TRFACCSTS_CT = 14 and TRFSTS_CT = 2) OR (TRFACCSTS_CT = 44 and TRFSTS_CT = 14)
UNION
select ctr_nf
from BFAC..TRFCROSSREF
where  (TRFACCSTS_CT = 14 and TRFSTS_CT = 2) OR (TRFACCSTS_CT = 44 and TRFSTS_CT = 14)

select @erreur = @@error, @lignes = @@rowcount, @datej = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8)
if @erreur != 0
begin
   print 'Erreur extraction du périmètre de contrats à traiter'
   return -35000
end
print 'Enregistrements traités : %1!  -  %2!', @lignes, @datej

print '-----> Extrait cles regroupées sur max bilan/mois'
select a.CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CRE_D,
       ACY_NF,
       ACMTRS_NT,
       GAAP_NT,
       DETTRNCOD_CF
into #lifctr1
from best..tlifest a, #ctrscros c
where a.ctr_nf = c.ctr_nf
and   a.balshey_nf = @balshey_nf
and   (a.balshey_nf*100+a.balshtmth_nf) = (select max(balshey_nf*100+balshtmth_nf) from best..tlifest b
                                           where a.CTR_NF       = b.CTR_NF
                                           and   a.END_NT       = b.END_NT
                                           and   a.SEC_NF       = b.SEC_NF
                                           and   a.UWY_NF       = b.UWY_NF
                                           and   a.UW_NT        = b.UW_NT
                                           and   b.BALSHEY_NF   = @balshey_nf
                                           and   a.ACY_NF       = b.ACY_NF
                                           and   a.ACMTRS_NT    = b.ACMTRS_NT
                                           and   a.GAAP_NT      = b.GAAP_NT
                                           and   a.DETTRNCOD_CF = b.DETTRNCOD_CF)
-- On ne traite pas ceux ayant un compte complet, et la maj auto décochée sur le max année bilan
and   not exists (select 1 from best..tlifdri t1
                  Where t1.ctr_nf = a.ctr_nf
                  and   t1.sec_nf = a.sec_nf
                  and   t1.acy_nf = a.acy_nf
                  and   t1.balshey_nf = (select max(balshey_nf) from best..tlifdri t2
                                         Where t2.ctr_nf = t1.ctr_nf
                                         and   t2.sec_nf = t1.sec_nf
                                         and   t2.acy_nf = t1.acy_nf)
                  and   t1.autupd_b = 0
                  and   t1.comacc_b = 1)

group by a.CTR_NF,
         END_NT,
         SEC_NF,
         UWY_NF,
         UW_NT,
         CRE_D,
         ACY_NF,
         ACMTRS_NT,
         GAAP_NT,
         DETTRNCOD_CF

select @erreur = @@error, @lignes = @@rowcount, @datej = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8)
if @erreur != 0
begin
   print 'Erreur Extraction cles regroupées sur max bilan/mois'
   return -35000
end
print 'Enregistrements traités : %1!  -  %2!', @lignes, @datej

print '-----> Extrait cles regroupées sur max cre_d'
select CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CRE_D=max(CRE_D),
       ACY_NF,
       ACMTRS_NT,
       GAAP_NT,
       DETTRNCOD_CF
into #lifctr2
from #lifctr1
group by CTR_NF,
         END_NT,
         SEC_NF,
         UWY_NF,
         UW_NT,
         ACY_NF,
         ACMTRS_NT,
         GAAP_NT,
         DETTRNCOD_CF

select @erreur = @@error, @lignes = @@rowcount, @datej = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8)
if @erreur != 0
begin
   print 'Erreur Extraction cles regroupées sur max cre_d'
   return -35000
end
print 'Enregistrements traités : %1!  -  %2!', @lignes, @datej

print '-----> Insere dans table temporaire'
insert #TLIFEST
(
     CTR_NF
    ,END_NT
    ,SEC_NF
    ,UWY_NF
    ,UW_NT
    ,CRE_D
    ,BALSHEY_NF
    ,BALSHTMTH_NF
    ,ACY_NF
    ,GAAP_NT
    ,DETTRNCOD_CF
    ,ACM_NF
    ,PRS_CF
    ,ACMTRS_NT
    ,SSD_CF
    ,CUR_CF
    ,ESTMNT_M
    ,INDSUP_B
    ,ORICOD_LS
    ,CREUSR_CF
    ,LSTUPD_D
    ,LSTUPDUSR_CF
    ,ORICTR_NF
    ,ORISEC_NF
    ,ORIUWY_NF
    ,DIFF_M
    ,PROPAGATION_B
    ,CALCULATED_B
    ,BATCH_B
)
select
       b.CTR_NF       ,
       b.END_NT       ,
       b.SEC_NF       ,
       b.UWY_NF       ,
       b.UW_NT        ,
       @datejour,       -- b.CRE_D        ,
       @p_balshey_nf  ,
       @p_balshtmth_nf,
       b.ACY_NF       ,
       b.GAAP_NT      ,
       b.DETTRNCOD_CF ,
       b.ACM_NF       ,
       b.PRS_CF       ,
       b.ACMTRS_NT    ,
       b.SSD_CF       ,
       b.CUR_CF       ,
       0,               -- b.ESTMNT_M     ,
       b.INDSUP_B     ,
       b.ORICOD_LS    ,
       'TRAN',          -- b.CREUSR_CF    ,
       @datejour,       -- b.LSTUPD_D     ,
       'TRAN',          -- b.LSTUPDUSR_CF
       ORICTR_NF      ,
       ORISEC_NF      ,
       ORIUWY_NF      ,
       DIFF_M         ,
       PROPAGATION_B  ,
       CALCULATED_B   ,
       BATCH_B
from best..tlifest b,
     #lifctr2 a
Where a.CTR_NF       = b.CTR_NF
and   a.END_NT       = b.END_NT
and   a.SEC_NF       = b.SEC_NF
and   a.UWY_NF       = b.UWY_NF
and   a.UW_NT        = b.UW_NT
and   a.CRE_D        = b.CRE_D
and   b.BALSHEY_NF   = @balshey_nf
and   a.ACY_NF       = b.ACY_NF
and   a.ACMTRS_NT    = b.ACMTRS_NT
and   a.GAAP_NT      = b.GAAP_NT
and   a.DETTRNCOD_CF = b.DETTRNCOD_CF

select @erreur = @@error, @lignes = @@rowcount, @datej = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8)
if @erreur != 0
begin
   print 'Erreur Insertion dans table temporaire'
   return -35000
end
print 'Enregistrements traités : %1!  -  %2!', @lignes, @datej

BEGIN TRAN

print '-----> Insere dans BEST..TLIFEST'
insert Best..Tlifest
select * from #TLIFEST

select @erreur = @@error, @lignes = @@rowcount, @datej = convert(char(9),getdate(),6)+' '+ convert(char(9),getdate(),8)
if @erreur != 0
begin
   ROLLBACK TRAN
   print 'Erreur Insertion dans BEST..TLIFEST'
   return -35000
end
print 'Enregistrements traités : %1!  -  %2!', @lignes, @datej

COMMIT TRAN

return 0
go

IF OBJECT_ID('dbo.PiLIFEST_04') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PiLIFEST_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiLIFEST_04 >>>'
go
 -- Granting/Revoking Permissions on dbo.PiLIFEST_04
GRANT EXECUTE ON dbo.PiLIFEST_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiLIFEST_04 TO GDBBATCH
go
