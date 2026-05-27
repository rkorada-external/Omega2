use BEST
go
/*
 * DROP PROC PsSECTION_25
 */
IF OBJECT_ID('PsSECTION_25') IS NOT NULL
BEGIN
    DROP PROC PsSECTION_25
    PRINT '<<< DROPPED PROC PsSECTION_25 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_25
with execute as caller as

/***************************************************

Programme: PsSECTION_25

Fichier script associé : ESSSEC25.PRC



Domaine : Estimations

Base principale : BEST


Version: 1

Auteur: ME31 avec Infotool version 2.0  

Date de creation: 

Description du programme: 
   Descente de la table BRET..TRACCSEN avec selection de la filiale

Parametres: 


Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: ANB

Date: 01/10/1998

Version: 2.0

Description: Sélection des seuls comptes comptabilisés à l'aide du code état

_________________
MODIFICATION 2
Description : Removed dbo and added ‘with execute as caller as’
*****************************************************/

declare @erreur int


SELECT RETCTR_NF, SCOENDMTH_NF, RETACCYER_NF
FROM   BRET..TRACCSEN r , BTRAV..TESTSSD e
WHERE  r.SSD_CF= e.SSD_CF
AND    r.ACCSENSTS_CT = 5

   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0


go
IF OBJECT_ID('PsSECTION_25') IS NOT NULL
    PRINT '<<< CREATED PROC PsSECTION_25 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC PsSECTION_25 >>>'
go
/*
 * Granting/Revoking Permissions on PsSECTION_25
 */
GRANT EXECUTE ON PsSECTION_25 TO GOMEGA
go

