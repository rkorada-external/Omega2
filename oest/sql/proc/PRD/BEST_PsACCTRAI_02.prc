use BEST
go

IF OBJECT_ID('PsACCTRAI_02') IS NOT NULL
BEGIN
    DROP PROC PsACCTRAI_02
    PRINT '<<< DROPPED PROC PsACCTRAI_02 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsACCTRAI_02 
  (  @p_BALSHEY_NF     smallint )


with execute as caller as

/***************************************************

Programme: PsACCTRAI_02
Fichier script associé : ESSACI02.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: O.GIRAUX 
Date de creation: 04/01/2000
Description du programme: 
	On met à jour les lignes avec le taux de versement de taccshrp pour celles qui ont
  	la même devise
        
Parametres: la date bilan
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1
Auteur: 
Date:   
Version:
Description: 
_________________
MODIFICATION - Removed dbo and added ‘with execute as caller as’
*****************************************************/

declare @erreur int
declare @ret int

/*On se donne une table temporaire*/
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

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TACCTRAI" 
      return @erreur
   end


/*On recupere toutes les lignes de TACCTRAI qui ont un lien avec TACCSHRP*/
INSERT #TREGROUP
(
   RETCTR_NF,
    RTY_NF,
    RETSEC_NF,
    SSD_CF,
    CTR_NF,
    END_NT,
    SEC_NF,
    UW_NT,
    UWY_NF,
    SCOENDMTH_NF,
    SCOSTRMTH_NF,
    ACCYER_NF,
    BLCSHT_D,
    CLM_NF,
    TRNCOD_CF,
    ACPCUR_CF,
    CED_M,
    RETACT_CT,
    OCCYEA_NF,
    CNVCUR_CF,
    CNVAMT_M,
    RETACCYER_NF,
    ACCTRTCUR_R,
    ACC_D,
    LNKTRS_NT
)
select  retctr_nf,
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
        convert(char(8),acc_d,112),
        LNKTRS_NT
from bret..TACCTRAI a, btrav..testssd b
where a.ssd_cf=b.ssd_cf
AND   A.EXTTRTCUR_B=1
AND   datepart(yy,A.ACC_D) = @p_BALSHEY_NF
AND   A.PLC_NT = NULL

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TACCTRAI" 
      return @erreur
   end

/* execution de la proc faisant les insertiions dans la table #TREGROUP*/
    exec @ret = BEST..PsACCTRAI_03 @p_BALSHEY_NF with recompile

   select @erreur = @@error

   if @erreur != 0 or @ret != 0
   begin
      raiserror 20007 "APPLICATIF;TACCTRAI" 
      return @erreur
   end



/*On peut se debarasser de la table*/
DROP TABLE #TREGROUP 

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20015 "APPLICATIF;TACCTRAI" 
      return @erreur
   end

return 0
go

IF OBJECT_ID('PsACCTRAI_02') IS NOT NULL
    PRINT '<<< CREATED PROC PsACCTRAI_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsACCTRAI_02 >>>'
go
/*
 * Granting/Revoking Permissions on PsACCTRAI_02
 */
GRANT EXECUTE ON PsACCTRAI_02 TO GOMEGA
go
GRANT EXECUTE ON PsACCTRAI_02 TO GDBBATCH
go

