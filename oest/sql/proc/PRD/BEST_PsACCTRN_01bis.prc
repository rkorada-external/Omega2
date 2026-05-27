use BEST
go

/*
 * DROP PROC  */
IF OBJECT_ID('PsACCTRN_01bis') IS NOT NULL
BEGIN
    DROP PROC PsACCTRN_01bis
    PRINT '<<< DROPPED PROC PsACCTRN_01bis >>>'
END
go

/*
 * creation de la procedure PsACCTRN_01bis */
create procedure PsACCTRN_01bis
as

/***************************************************
Programme:              PsACCTRN_01bis
Domaine :               (ES) Estimation
Base principale :       BEST
Version:                10.2
Auteur:                 D.GATIBELZA
Date de creation:       09/12/2010
Description du programme:       Sélection d'enregistrement dans TACCTRN même si l'exercice n'existe pas.
                                ESTDOM20828: mouvements comptables non venus dans GLT  sur exercices ou numero ordre  FACULTATIVE  supprimé
_________________
MODIFICATION    :
Auteur          :
Date            :
Version         :
Description     :
*****************************************************/

declare @erreur int


CREATE TABLE #GTA(
    TRN_NT          numeric(10,0)   NOT NULL,
    SSD_CF          USSD_CF         NOT NULL,
    ESB_CF          UESB_CF         NOT NULL,
    BLCSHT_D        datetime            NULL,
    TRNCOD_CF       UDETTRS_CF                  DEFAULT '',
    CTRNCOD_CF      UDETTRS_CF                  DEFAULT '',
    CTR_NF          UCTR_NF         NOT NULL,
    END_NT          UEND_NT                     DEFAULT 0,
    SEC_NF          USEC_NF             NULL,
    UWY_NF          UUWY_NF         NOT NULL,
    UW_NT           UUW_NT                      DEFAULT 1,
    OCCYEA_NF       smallint            NULL,
    ACY_NF          smallint        NOT NULL,
    SCOSTRMTH_NF    tinyint         NOT NULL,
    SCOENDMTH_NF    tinyint         NOT NULL,
    CLM_NF          int                 NULL,
    CUR_CF          UCUR_CF                     DEFAULT '',
    ORICURAMT_M     UAMT_M          NOT NULL,
    CED_NF          UCLI_NF         NOT NULL,
    PRD_NF          UCLI_NF             NULL,
    GENPRMPAY_NF    UCLI_NF             NULL,
    GANPAYORD_NT    UPAYORD_NT                  DEFAULT 'A',
    TRNSTS_CT       tinyint         NOT NULL
)

CREATE TABLE #GTAT(
    TRN_NT          numeric(10,0)   NOT NULL,
    SSD_CF          USSD_CF         NOT NULL,
    ESB_CF          UESB_CF         NOT NULL,
    BLCSHT_D        datetime            NULL,
    TRNCOD_CF       UDETTRS_CF                  DEFAULT '',
    CTRNCOD_CF      UDETTRS_CF                  DEFAULT '',
    CTR_NF          UCTR_NF         NOT NULL,
    END_NT          UEND_NT                     DEFAULT 0,
    SEC_NF          USEC_NF             NULL,
    UWY_NF          UUWY_NF         NOT NULL,
    UW_NT           UUW_NT                      DEFAULT 1,
    OCCYEA_NF       smallint            NULL,
    ACY_NF          smallint        NOT NULL,
    SCOSTRMTH_NF    tinyint         NOT NULL,
    SCOENDMTH_NF    tinyint         NOT NULL,
    CLM_NF          int                 NULL,
    CUR_CF          UCUR_CF                     DEFAULT '',
    ORICURAMT_M     UAMT_M          NOT NULL,
    CED_NF          UCLI_NF         NOT NULL,
    PRD_NF          UCLI_NF             NULL,
    GENPRMPAY_NF    UCLI_NF             NULL,
    GANPAYORD_NT    UPAYORD_NT                  DEFAULT 'A',
    TRNSTS_CT       tinyint         NOT NULL
)

CREATE TABLE #GTAF(
    TRN_NT          numeric(10,0)   NOT NULL,
    SSD_CF          USSD_CF         NOT NULL,
    ESB_CF          UESB_CF         NOT NULL,
    BLCSHT_D        datetime            NULL,
    TRNCOD_CF       UDETTRS_CF                  DEFAULT '',
    CTRNCOD_CF      UDETTRS_CF                  DEFAULT '',
    CTR_NF          UCTR_NF         NOT NULL,
    END_NT          UEND_NT                     DEFAULT 0,
    SEC_NF          USEC_NF             NULL,
    UWY_NF          UUWY_NF         NOT NULL,
    UW_NT           UUW_NT                      DEFAULT 1,
    OCCYEA_NF       smallint            NULL,
    ACY_NF          smallint        NOT NULL,
    SCOSTRMTH_NF    tinyint         NOT NULL,
    SCOENDMTH_NF    tinyint         NOT NULL,
    CLM_NF          int                 NULL,
    CUR_CF          UCUR_CF                     DEFAULT '',
    ORICURAMT_M     UAMT_M          NOT NULL,
    CED_NF          UCLI_NF         NOT NULL,
    PRD_NF          UCLI_NF             NULL,
    GENPRMPAY_NF    UCLI_NF             NULL,
    GANPAYORD_NT    UPAYORD_NT                  DEFAULT 'A',
    TRNSTS_CT       tinyint         NOT NULL
)


-- ----------------------------------------------------------------------------- --
-- Selection des mouvements de BCTA..TACCTRN flagués dans BCTA..TDRYTRN
-- en l'enrichissant avec d'autres info du contrat acceptation ( FAC et Traité )

-- TRAITE
insert into #GTAT
select dry.TRN_NT,
       dry.SSD_CF,
       dry.ESB_CF,
       convert(char(8), getdate(), 112),
       acc.TRNCOD_CF,
       acc.CTRNCOD_CF,
       acc.CTR_NF,
       acc.END_NT,
       acc.SEC_NF,
       acc.UWY_NF,
       acc.UW_NT,
       acc.OCCYEA_NF,
       acc.ACY_NF,
       acc.SCOSTRMTH_NF,
       acc.SCOENDMTH_NF,
       acc.CLM_NF,
       acc.CUR_CF,
       acc.ORICURAMT_M,
       acc.CED_NF,
       ctr.PRD_NF,
       ctr.GENPRMPAY_NF,
       isnull(ctr.GANPAYORD_NT, 'A'),
       acc.TRNSTS_CT
from BCTA..TDRYTRN dry, BCTA..TACCTRN acc, BTRT..TCONTR ctr
where dry.TRN_NT    = acc.TRN_NT
  and dry.SSD_CF    = acc.SSD_CF
  and dry.ESB_CF    = acc.ESB_CF
  and acc.CTR_NF    *= ctr.CTR_NF
  and acc.UWY_NF    *= ctr.UWY_NF
  and acc.UW_NT     *= ctr.UW_NT
  and acc.END_NT    *= ctr.END_NT
  and dry.ESTFLG_B   = 0
  and acc.blcsht_d  <  "20101208" 
  and acc.blcsht_d  >= "20100101" 


select @erreur = @@error
if @erreur != 0
begin
    raiserror 20005 "APPLICATIF;TACCTRN_TRT" /* erreur de modification */
    return @erreur
end


delete #GTAT
from #GTAT t
where not exists ( select null
                   from BTRT..TCONTR a
                   where t.CTR_NF = a.CTR_NF )


insert into	#GTAF
select dry.TRN_NT,
       dry.SSD_CF,
       dry.ESB_CF,
       convert(char(8), getdate(), 112),
       acc.TRNCOD_CF,
       acc.CTRNCOD_CF,
       acc.CTR_NF,
       acc.END_NT,
       acc.SEC_NF,
       acc.UWY_NF,
       acc.UW_NT,
       acc.OCCYEA_NF,
       acc.ACY_NF,
       acc.SCOSTRMTH_NF,
       acc.SCOENDMTH_NF,
       acc.CLM_NF,
       acc.CUR_CF,
       acc.ORICURAMT_M,
       acc.CED_NF,
       ctr.PRD_NF,
       ctr.GENPRMPAY_NF,
       isnull(ctr.GANPAYORD_NT, 'A'),
       acc.TRNSTS_CT
from BCTA..TDRYTRN dry, BCTA..TACCTRN acc, BFAC..TCONTR ctr
where dry.TRN_NT    = acc.TRN_NT
  and dry.SSD_CF    = acc.SSD_CF
  and dry.ESB_CF    = acc.ESB_CF
  and acc.CTR_NF    *= ctr.CTR_NF
  and acc.UWY_NF    *= ctr.UWY_NF
  and acc.UW_NT     *= ctr.UW_NT
  and acc.END_NT    *= ctr.END_NT
  and dry.ESTFLG_B  = 0
  and acc.blcsht_d  <  "20101208" 
  and acc.blcsht_d  >= "20100101" 

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20005 "APPLICATIF;TACCTRN_FAC" /* erreur de modification */
    return @erreur
end


delete #GTAF
from #GTAF t
where not exists ( select null
                   from BFAC..TCONTR a
                   where t.CTR_NF = a.CTR_NF )


insert #GTA
select * from #GTAT
union
select * from #GTAF


/**************** Mise en commentaire jusqu'à la livraison d'estimation ********************/
------ Préparation d'une table temporaire avec les affaires ( FAC et TRT ) extraits
select distinct CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
into #TCTRACC
from #GTA
where TRNSTS_CT = 1

if @erreur != 0
begin
    raiserror 20005 "APPLICATIF;TACCTRN" /* erreur de modification */
    return @erreur
end


/*******************************************************************************************/
begin tran
    ------ Mise à jour du flag ESTFLG_B pour les mouvements extraits ------------------------------
    UPDATE BCTA..TDRYTRN
       SET dry.ESTFLG_B = 1
    from BCTA..TDRYTRN dry, #GTA acc
    where dry.TRN_NT    = acc.TRN_NT
      and dry.SSD_CF    = acc.SSD_CF
      and dry.ESB_CF    = acc.ESB_CF
      and acc.TRNSTS_CT = 1

    if @erreur != 0
    begin
        rollback tran
        raiserror 20005 "APPLICATIF;TACCTRN" /* erreur de modification */
        return @erreur
    end


    select @erreur = @@error
    if @erreur != 0
    begin
        rollback tran
        raiserror 20005 "APPLICATIF;TACCTRN" /* erreur de modification */
        return @erreur
    end


    /**************** Mise en commentaire jusqu'à la livraison d'estimation ********************/
    ------ Suppression des affaires de la table temporaire qui sont aussi dans TCTRACC pour eviter
    ------ de les réinsérer et avoir un message d'insertion de doublons
    DELETE #TCTRACC
    from #TCTRACC, BEST..TCTRACC acc
    WHERE #TCTRACC.CTR_NF = acc.CTR_NF
      and #TCTRACC.SEC_NF = acc.SEC_NF
      and #TCTRACC.UWY_NF = acc.UWY_NF
      and #TCTRACC.UW_NT  = acc.UW_NT
      and #TCTRACC.END_NT = acc.END_NT


    INSERT INTO BEST..TCTRACC( CTR_NF, END_NT, SEC_NF, UW_NT, UWY_NF )
    SELECT CTR_NF,
           END_NT,
           SEC_NF,
           UW_NT,
           UWY_NF
    FROM #TCTRACC

    select @erreur = @@error
    if @erreur != 0
    begin
        rollback tran
        raiserror 20005 "APPLICATIF;TACCTRN" /* erreur de modification */
        return @erreur
    end
    /*******************************************************************************************/


    select SSD_CF,
           ESB_CF,
           datepart(yy, BLCSHT_D),
           datepart(mm, BLCSHT_D),
           datepart(dd, BLCSHT_D),
           TRNCOD_CF,
           CTRNCOD_CF,
           CTR_NF,
           END_NT,
           SEC_NF,
           UWY_NF,
           UW_NT,
           OCCYEA_NF,
           ACY_NF,
           SCOSTRMTH_NF,
           SCOENDMTH_NF,
           CLM_NF,
           CUR_CF,
           ORICURAMT_M,
           CED_NF,
           PRD_NF,
           GENPRMPAY_NF,
           GANPAYORD_NT,
           NULL RETCTR_NF,
           NULL RETEND_NT,
           NULL RETSEC_NF,
           NULL RETRTY_NF,
           NULL RETUW_NT,
           NULL RETOCCYEA_NF,
           NULL RETACY_NF,
           NULL RETSCOSTRMTH_NF,
           NULL RETSCOENDMTH_NF,
           NULL RCL_NF,
           NULL RETCUR_CF,
           NULL RETAMT_M,
           NULL PLC_NT,
           NULL RTO_NF,
           NULL INT_NF,
           NULL RETPAY_NF,
           NULL RETKEY_CF,
           0.000              --- montant retro interne 24/01/2003 JR
    from #GTA
    where TRNSTS_CT = 1

    select @erreur = @@error
    if @erreur != 0
    begin
        rollback tran
        raiserror 20005 "APPLICATIF;TACCTRN" /* erreur de modification */
        return @erreur
    end

commit

drop TABLE #GTA

return 0
go
IF OBJECT_ID('PsACCTRN_01bis') IS NOT NULL
    PRINT '<<< CREATED PROC PsACCTRN_01bis >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsACCTRN_01bis >>>'
go

/*
 * Granting/Revoking Permissions on PsACCTRN_01bis */
GRANT EXECUTE ON PsACCTRN_01bis TO GOMEGA
go

