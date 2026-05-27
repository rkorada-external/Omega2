use BEST
go

/*
 * DROP PROC dbo.PsACCTRAA_03
 */
IF OBJECT_ID('dbo.PsACCTRAA_03') IS NOT NULL
BEGIN
    DROP PROC dbo.PsACCTRAA_03
    PRINT '<<< DROPPED PROC dbo.PsACCTRAA_03 >>>'
END
go

CREATE TABLE #TREGROUP
(
   RETCTR_NF    URETCTR_NF           NOT NULL,
    RTY_NF       UUWY_NF              NOT NULL,
    RETSEC_NF    URETSEC_NF           NOT NULL,
    SSD_CF       USSD_CF              NOT NULL,
    CTR_NF       URETCTR_NF           NOT NULL,
    END_NT       UEND_NT              DEFAULT 0,
    SEC_NF       USEC_NF              NOT NULL,
    UW_NT        UUW_NT               DEFAULT 1,
    UWY_NF       UUWY_NF              NOT NULL,
    SCOENDMTH_NF tinyint              NOT NULL,
    SCOSTRMTH_NF tinyint              NOT NULL,
    ACCYER_NF    UACCYER_NF           NOT NULL,
    BLCSHT_D     datetime             NOT NULL,
    CLM_NF       int                      NULL,
    TRNCOD_CF    char(8)              DEFAULT '',
    ACPCUR_CF    UCUR_CF              DEFAULT '',
    CED_M        UAMT_M               NOT NULL,
    RETACT_CT    URETACT_CT           DEFAULT '',
    OCCYEA_NF    UOCCYEA_NF               NULL,
    CNVCUR_CF    UCUR_CF              DEFAULT '',
    CNVAMT_M     UAMT_M               NOT NULL,
    RETACCYER_NF URETACCYER_NT        NOT NULL,
    ACCTRTCUR_R  USHA_R               NOT NULL,
    ACC_D        datetime             NOT NULL,
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

create procedure PsACCTRAA_03
  ( @p_BALSHEY_NF  smallint)

with execute as caller as

/***************************************************

Programme: PsACCTRAA_03
Fichier script associé : ESSACA03.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: Fabien TALMA (IBM)
Date de creation: 06 janvier 1999
Description du programme: 
            On met à jour avec les lignes avec le taux de versement de taccshrp pour celle qui joignent
  sur de lignes de même devise

_________________
MODIFICATION 1
Auteur: O. GIRAUX
Date: 30/12/1999
Version:
Description: Ajout d'un paramètre à la proc 
	=> condition supplémentaire: ACC_D = BALSHEY_NF

Parametres: Date bilan
Conditions d'execution: 
Commentaires: 

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
      raiserror 20007 "APPLICATIF;TACCTRAA" 
      return @erreur
   end

/* Select pour le bcp */
/*On commence par celle de TACCTRAA qui n'ont pas de lien avec TACCSHRP*/
select      retctr_nf,
        rty_nf,
        retsec_nf,
        A.ssd_cf,
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
from bret..TACCTRAA a, btrav..testssd b
where a.ssd_cf=b.ssd_cf
AND   A.EXTTRTCUR_B=0
AND   datepart(yy,A.ACC_D) = @p_BALSHEY_NF
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
select  C.retctr_nf,
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
      raiserror 20010 "APPLICATIF;TACCTRAA" 
      return @erreur
   end

return 0
go

DROP TABLE #TREGROUP
DROP TABLE #TREGROUP_SUM
go

IF OBJECT_ID('dbo.PsACCTRAA_03') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsACCTRAA_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsACCTRAA_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsACCTRAA_03
 */
GRANT EXECUTE ON dbo.PsACCTRAA_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCTRAA_03 TO GDBBATCH
go


