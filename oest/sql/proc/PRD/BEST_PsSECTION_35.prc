use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
GO
 /* DROP PROC dbo.PsSECTION_35
*/
IF OBJECT_ID('dbo.PsSECTION_35') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSECTION_35
   PRINT '<<< DROPPED PROC dbo.PsSECTION_35 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSECTION_35
     (
       @p_segtyp_ct           char(1),
       @p_ssd_cf              USSD_CF,
       @p_seg_d               datetime
     )
as

/***************************************************

Programme: PsSECTION_35

Fichier script associé : ESSSEC35.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      MAJ table de segmentation TPARSEG

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


----------------------------------
-- MAJ de la table de segmentation
----------------------------------

DELETE BEST..TPARSEG
WHERE  SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct

INSERT INTO BEST..TPARSEG (SSD_CF, SEGTYP_CT, SEG_D)
VALUES      (@p_ssd_cf, @p_segtyp_ct, @p_seg_d)



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

exec sp_SCOR_INSPRC 'ESSSEC35', 'PsSECTION_35', 'BEST', 'ME31'
go

IF OBJECT_ID('dbo.PsSECTION_35') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSECTION_35 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSECTION_35 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSECTION_35
 */
GRANT EXECUTE ON dbo.PsSECTION_35 TO GOMEGA
go

