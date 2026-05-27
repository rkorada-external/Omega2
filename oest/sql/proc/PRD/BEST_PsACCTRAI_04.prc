use BEST
go

/*
 * DROP PROC dbo.PsACCTRAI_04
 */
IF OBJECT_ID('dbo.PsACCTRAI_04') IS NOT NULL
BEGIN
    DROP PROC dbo.PsACCTRAI_04
    PRINT '<<< DROPPED PROC dbo.PsACCTRAI_04 >>>'
END
go

CREATE TABLE #TREGROUP
(
   RETCTR_NF    URETCTR_NF           NOT NULL,
    RTY_NF       UUWY_NF              NOT NULL,
    RETSEC_NF    URETSEC_NF           NOT NULL,
    SSD_CF       USSD_CF              NOT NULL,
    CTR_NF       URETCTR_NF           DEFAULT '',
    END_NT       UEND_NT              DEFAULT 0,
    SEC_NF       USEC_NF              NULL,
    UW_NT        UUW_NT               DEFAULT 1,
    UWY_NF       UUWY_NF              NULL,
    SCOENDMTH_NF tinyint              NULL,
    SCOSTRMTH_NF tinyint              NOT NULL,
    ACCYER_NF    UACCYER_NF           NULL,
    BLCSHT_D     datetime             NOT NULL,
    CLM_NF       int                      NULL,
    TRNCOD_CF    char(8)              DEFAULT '',
    ACPCUR_CF    UCUR_CF              DEFAULT '',
    CED_M        UAMT_M               NULL,
    RETACT_CT    URETACT_CT           DEFAULT '',
    OCCYEA_NF    UOCCYEA_NF               NULL,
    CNVCUR_CF    UCUR_CF              DEFAULT '',
    CNVAMT_M     UAMT_M               NULL,
    RETACCYER_NF URETACCYER_NT        NULL,
    ACCTRTCUR_R  USHA_R               NULL,
    ACC_D        datetime             NULL,
    LNKTRS_NT    numeric(10,0)        NOT NULL
)
go

create table #TREGROUP_SUM (
LNKTRS_NT numeric (10,0) NOT NULL,
SUMTAUX_R USHA_R         default 0)
go

/*
 * creation de la procedure 
 */

create procedure PsACCTRAI_04
  ( @p_BALSHEY_NF  smallint)

with execute as caller as

/***************************************************

Programme: PsACCTRAI_04
Fichier script associé : ESSACI04.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: O.GIRAUX
Date de creation: 05/01/2000
Description du programme: 
  On met à jour les lignes avec le taux de versement de taccshrp pour celles qui ont 
  la même devise

[001] 05/11/2013 R. Cassis spot:25427: Ajout execute as caller pour centralization
*****************************************************/

declare @erreur int

/*On met à jour avec les lignes avec le taux de versement de taccshrp 
  pour celle qui joignent sur de lignes de même devise, on passe par 
  la table temporaire ou l on a fait des sommes*/
UPDATE #TREGROUP
SET acctrtcur_r=A.acctrtcur_r + B.sumtaux_r
FROM #TREGROUP A, 
     #TREGROUP_SUM B
WHERE A.LNKTRS_NT=B.LNKTRS_NT

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20007 "APPLICATIF;TACCTRAI" 
      return @erreur
   end

/* Select pour le bcp */
/*On commence par celles de TACCTRAI qui n'ont pas de lien avec TACCSHRP*/
select      retctr_nf,
        rty_nf,
        retsec_nf,
        A.ssd_cf,
        ctr_nf,
        end_nt,
        sec_nf,
        uw_nt,
        uwy_nf,
        12,
        12,
        accyer_nf,
        '',
        rcl_nf,
        trncod_cf,
        cur_cf,
        trn_m,
        '',
        occyea_nf,
        cnvcur_cf,
        cnvamt_m,
        retaccyer_nf,
        acctrtcur_cf,
        convert(char(8),acc_d,112)
from bret..TACCTRAI a, btrav..testssd b
where a.ssd_cf=b.ssd_cf
AND   A.EXTTRTCUR_B=0
AND   datepart(yy,A.ACC_D) = @p_BALSHEY_NF
AND   A.PLC_NT=NULL
/*Puis on prend les lignes qui ont un lien ou les taux ont été mis à jour lorsque 
  cela était nécéssaire*/
UNION ALL
select      retctr_nf,
        rty_nf,
        retsec_nf,
        ssd_cf,
        ctr_nf,
        end_nt,
        sec_nf,
        uw_nt,
        uwy_nf,
        scostrmth_nf,
        scoendmth_nf,
        accyer_nf,
        convert(char(8),blcsht_d,112),
        clm_nf,
        trncod_cf,
        acpcur_cf,
        ced_m,
        retact_ct,
        occyea_nf,
        cnvcur_cf,
        cnvamt_m,
        retaccyer_nf,
        acctrtcur_r,
        convert(char(8),acc_d,112)
from #TREGROUP
/*On prend toutes celle qui ont un lien avec TACCSHRP  et une devise differente*/
UNION ALL
select      C.retctr_nf,
        C.rty_nf,
        A.retsec_nf,
        C.ssd_cf,
        A.ctr_nf,
        A.end_nt,
        A.sec_nf,
        A.uw_nt,
        A.uwy_nf,
        A.scostrmth_nf,
        A.scoendmth_nf,
        A.accyer_nf,
        convert(char(8),A.blcsht_d,112),
        A.clm_nf,
        A.trncod_cf,
        C.acpcur_cf,
        C.ced_m,
        A.retact_ct,
        A.occyea_nf,
        C.cnvcur_cf,
        C.cnvamt_m,
        A.retaccyer_nf,
        C.cedsha_r,
        convert(char(8),A.acc_d,112)
from #TREGROUP a,BRET..TACCSHRP C
where   A.LNKTRS_NT=C.LNKTRS_NT
AND     A.CNVCUR_CF!=C.CNVCUR_CF

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20010 "APPLICATIF;TACCTRAI" 
      return @erreur
   end

return 0
go

DROP TABLE #TREGROUP
DROP TABLE #TREGROUP_SUM
go

IF OBJECT_ID('dbo.PsACCTRAI_04') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsACCTRAI_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsACCTRAI_04 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsACCTRAI_04
 */
GRANT EXECUTE ON dbo.PsACCTRAI_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCTRAI_04 TO GDBBATCH
go
