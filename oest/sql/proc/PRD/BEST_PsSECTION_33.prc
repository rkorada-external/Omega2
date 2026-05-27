use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
 /* DROP PROC dbo.PsSECTION_33
*/
IF OBJECT_ID('dbo.PsSECTION_33') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSECTION_33
   PRINT '<<< DROPPED PROC dbo.PsSECTION_33 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_33
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsSECTION_33

Fichier script associé : ESSSEC33.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Effacement de la table temporaire ESTPERIRED

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

-- Cas multifiliale

if @p_ssd_cf=00
BEGIN
DELETE BTRAV..ESTPERIRED
WHERE  SEGTYP_CT=@p_segtyp_ct
END

-- Cas monofiliale

ELSE
BEGIN
DELETE BTRAV..ESTPERIRED
WHERE  SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
END


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

exec sp_SCOR_INSPRC 'ESSSEC33', 'PsSECTION_33', 'BEST', 'ME31'
go

IF OBJECT_ID('dbo.PsSECTION_33') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSECTION_33 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_33 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_33
 */
GRANT EXECUTE ON dbo.PsSECTION_33 TO GOMEGA
go

