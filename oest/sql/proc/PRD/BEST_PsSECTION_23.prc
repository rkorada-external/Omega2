use BEST
go


/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
 /* DROP PROC dbo.PsSECTION_23
*/
IF OBJECT_ID('dbo.PsSECTION_23') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSECTION_23
   PRINT '<<< DROPPED PROC dbo.PsSECTION_23 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_23
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsSECTION_23

Fichier script associé : ESSSEC23.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 


Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int


----------------------------------------
-- Génération du fichier du portefeuille
----------------------------------------

SELECT *
FROM   BEST..TSEGPOR
WHERE  SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct

   select @erreur = @@error

   if @erreur != 0
   begin
      return @erreur
   end

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSEC23', 'PsSECTION_23', 'BEST', 'ME31'
go

IF OBJECT_ID('dbo.PsSECTION_23') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSECTION_23 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_23 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_23
 */
GRANT EXECUTE ON dbo.PsSECTION_23 TO GOMEGA
go

