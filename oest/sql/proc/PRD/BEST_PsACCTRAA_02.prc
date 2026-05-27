use BEST
go

/*
 * DROP PROC dbo.PsACCTRAA_02
 */
IF OBJECT_ID('dbo.PsACCTRAA_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PsACCTRAA_02
    PRINT '<<< DROPPED PROC dbo.PsACCTRAA_02 >>>'
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

/*
 * creation de la procedure
 */

create procedure PsACCTRAA_02
   (@p_BALSHEY_NF  smallint)
as

/***************************************************

Programme: PsACCTRAA_02
Fichier script associé : ESSACA02.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: Fabien TALMA (IBM)
Date de creation: 06 janvier 1999
Description du programme:
            On met à jour avec les lignes avec le taux de versement de taccshrp pour celle qui joignent
  sur de lignes de même devise

MODIFICATION 1
Auteur: O. GIRAUX
Date: 30/12/1999
Version:
Description: Ajout d'un paramètre à la proc

Parametres: Date bilan
Conditions d'execution:
Commentaires:

modification 2

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
      raiserror 20010 "APPLICATIF;TACCTRAA"
      return @erreur
   end

/* execution de la proc faisant la mise à jour de la table #TREGROUP
   et le select final */
    exec @ret = BEST..PsACCTRAA_03 @p_BALSHEY_NF  with recompile

   select @erreur = @@error

   if @erreur != 0 or @ret != 0
   begin
      raiserror 20007 "APPLICATIF;TACCTRAA"
      return @erreur
   end



return 0
go

DROP TABLE #TREGROUP
go

IF OBJECT_ID('dbo.PsACCTRAA_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsACCTRAA_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsACCTRAA_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsACCTRAA_02
 */
GRANT EXECUTE ON dbo.PsACCTRAA_02 TO GOMEGA
go
