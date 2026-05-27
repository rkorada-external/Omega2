USE BEST
Go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */

 /* DROP PROC dbo.PdCTRGRO_05
*/
IF OBJECT_ID('dbo.PdCTRGRO_05') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdCTRGRO_05
   PRINT '<<< DROPPED PROC dbo.PdCTRGRO_05 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdCTRGRO_05
     (
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric(10,0),
       @p_segtyp_ct           char(1)
     )
as

/***************************************************

Programme: PdCTRGRO_05

Fichier script associé : ESDCTR05.PRC
Domaine : Estimations
Base principale : BEST

Version: 1

Auteur: M. DJELLOULI
Date de creation: 07/10/2004

Description du programme: 

      Suppression Partielle pour Rechargement BEST08a - ESED0411

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

select @erreur  = 0
-- Suppression totale version


DELETE BEST..TCTRANO
WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
select @erreur = @@error
if @erreur != 0
   goto fin

DELETE BEST..TSEGANO
WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
select @erreur = @@error
if @erreur != 0
   goto fin

DELETE BEST..TSEGMENT
WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
select @erreur = @@error
if @erreur != 0
   goto fin

DELETE BEST..TCTRGRO
WHERE  VRS_NF=@p_vrs_nf and SSD_CF=@p_ssd_cf and SEGTYP_CT=@p_segtyp_ct
select @erreur = @@error
if @erreur != 0
   goto fin

fin:  
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

exec sp_SCOR_INSPRC 'ESDCTR05', 'PdCTRGRO_05', 'BEST', 'ME31'
go

IF OBJECT_ID('dbo.PdCTRGRO_05') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdCTRGRO_05 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdCTRGRO_05 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdCTRGRO_05
 */
GRANT EXECUTE ON dbo.PdCTRGRO_05 TO GOMEGA
go

