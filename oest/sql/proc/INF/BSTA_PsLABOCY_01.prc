USE BSTA
Go

/* DROP PROC dbo.PsLABOCY_01
 */
IF OBJECT_ID('dbo.PsLABOCY_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsLABOCY_01
   PRINT '<<< DROPPED PROC dbo.PsLABOCY_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsLABOCY_01
    (
    @p_ssd_cf       USSD_CF,
    @p_vrs_nf       numeric( 10, 0 ),
    @p_segtyp_ct    USEGTYP_CT,
    @p_cre_d        UUPD_D
    )
as

/***************************************************

Programme: PsLABOCY_01

Fichier script associé : ESLABO01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME27 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 
    - Extraction de la table BSAR..TLABOCY, avec mise au format de BEST..TLABOCY    

Parametres: 
    - @p_vrs_nf : version
    - @p_segtyp_ct : type de la segmentation
    - @p_cre_d : date du traitement
    - @p_ssd_cf : filiale

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: 

Date: 

Version:

Description: 

*****************************************************/
declare @erreur      int        

select @erreur = 0

/* 
   Selection d'enregistrements de BSAR..TLABOCY au format 
   de BEST..TLABOCY .

*/

select @p_vrs_nf, 
       SSD_CF, 
       SEGTYP_CT, 
       SEG_NF, 
       UWY_NF, 
       @p_cre_d, 
       OCCYEA_NF, 
       SPIRAT_R
from BSAR..TLABOCY labocy
where labocy.SSD_CF    = @p_ssd_cf
and   labocy.SEGTYP_CT = @p_segtyp_ct

select @erreur = @@error
if @erreur != 0  
   goto fin

fin:
   if @erreur != 0
      begin
      raiserror 20005 "FAILED: PsLABOCY_01"
      return @erreur
   end

return 0
go


/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESLABO01', 'PsLABOCY_01', 'BSTA', 'ME27'
go

IF OBJECT_ID('dbo.PsLABOCY_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsLABOCY_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsLABOCY_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsLABOCY_01
 */
GRANT EXECUTE ON dbo.PsLABOCY_01 TO GOMEGA
go

