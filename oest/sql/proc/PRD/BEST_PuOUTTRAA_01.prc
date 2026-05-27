use BEST
go

/*
 * DROP PROC PuOUTTRAA_01
 */
IF OBJECT_ID('PuOUTTRAA_01') IS NOT NULL
BEGIN
    DROP PROC PuOUTTRAA_01
    PRINT '<<< DROPPED PROC PuOUTTRAA_01 >>>'
END
go

/*
 * creation de la procedure 
 */

create procedure PuOUTTRAA_01(
    @specend_d datetime
)
with execute as caller as

/***************************************************

Programme: PuOUTTRAA_01
Fichier script associé : ESUOAT01.PRC
Domaine : (ES) Estimation
Base principale : BRET
Version: 1
Auteur: CGI (C.Soulier) 
Date de creation: 15 janvier 1998
Description du programme: 

	Remise a "O" du top RETACC_CT dans BRET..TOUTTRAA lorsque
	celui-ci vaut "P"
            
Parametres: aucun
Conditions d'execution: 
Commentaires: 

_________________
MODIFICATION 1 -> MOD01
Auteur:O.GIRAUX
Date:03/04/2001
Version:
Description: Ajout du test sur la fin de periode exceptionnelle specend_d
_________________
Modification - Removed dbo and added ‘with execute as caller as’ 
*****************************************************/

declare @erreur int

BEGIN TRAN

update bret..touttraa
set retact_ct="O"
from bret..touttraa a, btrav..testssd b
where a.retact_ct="P"
and a.ssd_cf=b.ssd_cf
and datepart(yy,a.cre_d) <= datepart(yy,@specend_d)  -- MOD01

   select @erreur = @@error

   if @erreur != 0
   begin
      ROLLBACK TRAN 
      return @erreur
   end

COMMIT TRAN

return 0
go

IF OBJECT_ID('PuOUTTRAA_01') IS NOT NULL
    PRINT '<<< CREATED PROC PuOUTTRAA_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PuOUTTRAA_01 >>>'
go
/*
 * Granting/Revoking Permissions on PuOUTTRAA_01
 */
GRANT EXECUTE ON PuOUTTRAA_01 TO GOMEGA
go

