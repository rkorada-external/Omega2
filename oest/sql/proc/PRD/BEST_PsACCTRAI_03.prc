use BEST
go

/*
 * DROP PROC dbo.PsACCTRAI_03
 */
IF OBJECT_ID('dbo.PsACCTRAI_03') IS NOT NULL
BEGIN
    DROP PROC dbo.PsACCTRAI_03
    PRINT '<<< DROPPED PROC dbo.PsACCTRAI_03 >>>'
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

/*
 * creation de la procedure
 */

create procedure PsACCTRAI_03
   (@p_BALSHEY_NF  smallint)
as

/***************************************************

Programme: PsACCTRAI_03
Fichier script associé : ESSACI03.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: O.GIRAUX
Date de creation: 05/01/2000
Description du programme:

        Extraction de la table TACCTRAI de BRET
        (table des mouvements saisis ou calcules comptabilises)

Parametres: la date bilan
Conditions d'execution:
Commentaires:

_________________
MODIFICATION 1
    13/03/2008  J. Ribot SPOT15180 ajout d'un order by après le group by en respectant les mêmes champs
*****************************************************/


/* Table tempo pour faire des sommes */
create table #TREGROUP_SUM (
LNKTRS_NT numeric (10,0) NOT NULL,
SUMTAUX_R USHA_R         default 0)

declare @erreur int,
        @ret int

/* On passe par une table temporaire pour faire la somme
   des taux de TACCSHRP Puis, on ajoutera dans la proc
   suivante cette somme au taux de #tregroup   */
INSERT into #TREGROUP_SUM
SELECT a.lnktrs_nt,
       sum ( isnull(b.cedsha_r, 0))
FROM #TREGROUP a,
     BRET..TACCSHRP b
WHERE A.LNKTRS_NT=B.LNKTRS_NT
AND   A.CNVCUR_CF=B.CNVCUR_CF
group by a.lnktrs_nt
order by a.lnktrs_nt

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20010 "APPLICATIF;TACCTRAI"
      return @erreur
   end

/* execution de la proc faisant la mise à jour de la table #TREGROUP
   et le select final */
    exec @ret = BEST..PsACCTRAI_04 @p_BALSHEY_NF  with recompile

   select @erreur = @@error

   if @erreur != 0 or @ret != 0
   begin
      raiserror 20007 "APPLICATIF;TACCTRAI"
      return @erreur
   end



return 0
go

DROP TABLE #TREGROUP
go

IF OBJECT_ID('dbo.PsACCTRAI_03') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsACCTRAI_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsACCTRAI_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsACCTRAI_03
 */
GRANT EXECUTE ON dbo.PsACCTRAI_03 TO GOMEGA
go
