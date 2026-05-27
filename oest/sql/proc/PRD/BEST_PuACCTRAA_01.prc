use BEST
go

/*
 * DROP PROC PuACCTRAA_01
 */
IF OBJECT_ID('PuACCTRAA_01') IS NOT NULL
BEGIN
    DROP PROC PuACCTRAA_01
    PRINT '<<< DROPPED PROC PuACCTRAA_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PuACCTRAA_01
@p_blshtyea_nf  smallint
with execute as caller as

/***************************************************

Programme: PuACCTRAA_01
Fichier script associé : ESUACA01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: CGI (C.Soulier) 
Date de creation: 15 janvier 1998
Description du programme: 

	Remise a "O" du top RETACC_CT dans BRET..TACCTRAA lorsque
	celui-ci vaut "P"
            
Parametres: aucun
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1
Auteur:
Date:
Version:
Description:
_________________
Modification - Removed dbo and added ‘with execute as caller as’ 
*****************************************************/

declare @erreur int

BEGIN TRAN

update bret..tacctraa
set retact_ct="O"
from bret..tacctraa a, btrav..testssd b
where a.retact_ct="P"
and a.ssd_cf=b.ssd_cf
and datepart(yy,a.acc_d)= @p_blshtyea_nf

   select @erreur = @@error

   if @erreur != 0
   begin
      ROLLBACK TRAN
      return @erreur
   end

COMMIT TRAN

return 0
go

IF OBJECT_ID('PuACCTRAA_01') IS NOT NULL
    PRINT '<<< CREATED PROC PuACCTRAA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PuACCTRAA_01 >>>'
go
/*
 * Granting/Revoking Permissions on À_01
 */
GRANT EXECUTE ON PuACCTRAA_01 TO GOMEGA
go

