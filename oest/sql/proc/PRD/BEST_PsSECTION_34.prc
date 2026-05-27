use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
 /* DROP PROC PsSECTION_34
*/
IF OBJECT_ID('PsSECTION_34') IS NOT NULL
   BEGIN
   DROP PROC PsSECTION_34
   PRINT '<<< DROPPED PROC PsSECTION_34 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_34
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              USSD_CF
     )
with execute as caller as

/***************************************************

Programme: PsSECTION_34

Fichier script associé : ESSSEC34.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Effacement et remplissage de la table portefeuille TSEGPOR

Parametres: 

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

-------------------------------
-- Portefeuille de segmentation
-------------------------------

DELETE BEST..TSEGPOR
WHERE  SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct

INSERT INTO BEST..TSEGPOR (SSD_CF, SEGTYP_CT, CTR_NF, END_NT, SEC_NF, CTRRET_B, CTRNAT_CT)
SELECT      SSD_CF, SEGTYP_CT, CTR_NF, END_NT, SEC_NF, CTRRET_B, CTRNAT_CT
FROM        BTRAV..ESTPERIRED
WHERE       SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct


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

exec sp_SCOR_INSPRC 'ESSSEC06', 'PsSECTION_34', 'BEST', 'ME31'
go

IF OBJECT_ID('PsSECTION_34') IS NOT NULL
   PRINT '<<< CREATED PROC PsSECTION_34 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC PsSECTION_34 >>>'
go
/*
 * Granting/Revoking Permissions on PsSECTION_34
 */
GRANT EXECUTE ON PsSECTION_34 TO GOMEGA
go

