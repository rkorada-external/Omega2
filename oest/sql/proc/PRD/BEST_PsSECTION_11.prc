use BEST
go

use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
 /* DROP PROC dbo.PsSECTION_11
*/
IF OBJECT_ID('dbo.PsSECTION_11') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSECTION_11
   PRINT '<<< DROPPED PROC dbo.PsSECTION_11 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_11
     (
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsSECTION_11

Fichier script associé : ESSSEC11.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Descente de la table TCTRULT

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


-- Cas multifiliale (inventaire)
-- La liste des filiales est dans la table BTRAV..TESTSSD

if @p_ssd_cf = 99
BEGIN

SELECT *
FROM   BEST..TCTRULT CTRULT, BTRAV..TESTSSD ESTSSD
GROUP  BY CTR_NF, END_NT, SEC_NF, UW_NT, UWY_NF
HAVING CTRULT.SSD_CF=ESTSSD.SSD_CF
       and CRE_D=MAX(CRE_D)

END


-- Cas monofiliale (segmentation)
-- La filiale est passée en paramètre

ELSE
BEGIN

SELECT *
FROM   BEST..TCTRULT CTRULT
GROUP  BY CTR_NF, END_NT, SEC_NF, UW_NT, UWY_NF
HAVING SSD_CF=@p_ssd_cf
       and CRE_D=MAX(CRE_D)

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

exec sp_SCOR_INSPRC 'ESSSEC11', 'PsSECTION_11', 'BEST', 'ME31'
go

IF OBJECT_ID('dbo.PsSECTION_11') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSECTION_11 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_11 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_11
 */
GRANT EXECUTE ON dbo.PsSECTION_11 TO GOMEGA
go

