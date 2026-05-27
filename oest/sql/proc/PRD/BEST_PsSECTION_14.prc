use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
GO
/* DROP PROC PsSECTION_14 */
IF OBJECT_ID('PsSECTION_14') IS NOT NULL
   BEGIN
   DROP PROC PsSECTION_14
   PRINT '<<< DROPPED PROC PsSECTION_14 >>>'
END
GO
/*
 * creation de la procedure 
*/

create procedure PsSECTION_14
     (
       @p_segtyp_ct           char(1)
     )
with execute as caller as

/***************************************************

Programme: PsSECTION_14

Fichier script associé : ESSSEC14.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 
      Descente de la table TLABOCY en inventaire

Parametres: 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description : Removed dbo and added ‘with execute as caller as’

*****************************************************/

declare @erreur int


-- La liste des filiales est dans la table BTRAV..TESTSSD


SELECT LABOCY.VRS_NF, LABOCY.SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, CONVERT(char(8), CRE_D, 112), OCCYEA_NF, SPIRAT_R
FROM   BEST..TLABOCY LABOCY, BTRAV..TESTSSD ESTSSD
WHERE  SEGTYP_CT=@p_segtyp_ct       
       and LABOCY.SSD_CF=ESTSSD.SSD_CF
       and LABOCY.VRS_NF=ESTSSD.VRS_NF


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

exec sp_SCOR_INSPRC 'ESSSEC14', 'PsSECTION_14', 'BEST', 'ME31'
GO

IF OBJECT_ID('PsSECTION_14') IS NOT NULL
   PRINT '<<< CREATED PROC PsSECTION_14 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC PsSECTION_14 >>>'
GO
/*
 * Granting/Revoking Permissions on PsSECTION_14
 */
GRANT EXECUTE ON PsSECTION_14 TO GOMEGA
GO

