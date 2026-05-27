use BEST
go

/*
 * DROP PROC PsACCTRAA_01
 */
IF OBJECT_ID('PsACCTRAA_01') IS NOT NULL
BEGIN
    DROP PROC PsACCTRAA_01
    PRINT '<<< DROPPED PROC PsACCTRAA_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PsACCTRAA_01 
  (  @p_BALSHEY_NF     smallint )


with execute as caller as

/***************************************************

Programme: PsACCTRAA_01
Fichier script associé : ESSACA01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: CGI (C.Soulier) 
Date de creation: 30 septembre 1997
Description du programme: 

        Extraction de la table TACCTRAA de BRET
        (table des mouvements retro a 100% comptabilises)
            
Parametres: la date bilan (modif du 30/12/99)
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1
Auteur: Fabien TALMA (IBM)
Date:   5/01/1999
Version:
Description: En plus du mouvements comptabilisé au 100%
On recupere la ligne en jointure dans TACCSHRP si elle existe.
Cette ligne contient la part placé pour les placements ayant des devise de compte différente 
de la devise de compte au niveau contrat. Si cette devise apparaissant dans TACCSHRP est la même 
on cumule la part placée dans la ligne en sortie.

MODIFICATION 2
Auteur: O. GIRAUX
Date:   30/12/1999
Version:
Description: On rajoute une condition supplémentaire a la requete: ACC_D = BALSHEY_NF
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

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TACCTRAA" 
      return @erreur
   end


/*On recupere toutes les lignes de TACCTRAA qui ont un lien avec TACCSHRP*/
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
        convert(char(8),acc_d,112),
        LNKTRS_NT
from bret..TACCTRAA a, btrav..testssd b
where a.ssd_cf=b.ssd_cf
AND   A.EXTTRTCUR_B=1
AND   datepart(yy,A.ACC_D) = @p_BALSHEY_NF

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TACCTRAA" 
      return @erreur
   end

/* execution de la proc faisant les insertiions dans la table #TREGROUP*/
    exec @ret = BEST..PsACCTRAA_02 @p_BALSHEY_NF with recompile

   select @erreur = @@error

   if @erreur != 0 or @ret != 0
   begin
      raiserror 20007 "APPLICATIF;TACCTRAA" 
      return @erreur
   end



/*On peut se debarasser de la table*/
DROP TABLE #TREGROUP 

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20015 "APPLICATIF;TACCTRAA" 
      return @erreur
   end

return 0
go

IF OBJECT_ID('PsACCTRAA_01') IS NOT NULL
    PRINT '<<< CREATED PROC PsACCTRAA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsACCTRAA_01 >>>'
go
/*
 * Granting/Revoking Permissions on PsACCTRAA_01
 */
GRANT EXECUTE ON PsACCTRAA_01 TO GOMEGA
go
GRANT EXECUTE ON PsACCTRAA_01 TO GDBBATCH
go

