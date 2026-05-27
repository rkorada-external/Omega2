USE BEST
Go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
 /* DROP PROC dbo.PdCTRGRO_01
*/
IF OBJECT_ID('dbo.PdCTRGRO_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdCTRGRO_01
   PRINT '<<< DROPPED PROC dbo.PdCTRGRO_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdCTRGRO_01
     (
       @p_ssd_cf              USSD_CF,
       @p_vrs_nf              numeric(10,0),
       @p_segtyp_ct           char(1),
       @p_option              tinyint
     )
as

/***************************************************

Programme: PdCTRGRO_01

Fichier script associé : ESDCTR01.PRC

Domaine : Estimations

Base principale : BEST

Version: 1

Auteur: ME31 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Suppression totale d'une version

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
declare @tran_on smallint

select @erreur = 0
select @tran_on = 0
-- Suppression totale version

begin tran
select @tran_on = 1


IF (@p_option=0)
BEGIN
EXECUTE @erreur = BEST..PdCTRGRO_02 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct
if @erreur != 0
goto fin
END

-- Suppression totale version et rechargement total

ELSE IF (@p_option=1)
BEGIN
EXECUTE @erreur = BEST..PdCTRGRO_03 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct
if @erreur != 0
goto fin
END

-- Suppression partielle version et rechargement partiel

ELSE IF (@p_option=2)
BEGIN
EXECUTE @erreur = BEST..PdCTRGRO_04 @p_ssd_cf, @p_vrs_nf, @p_segtyp_ct
if @erreur != 0
goto fin
END
  
fin:
    if @erreur != 0
      begin
      if @tran_on = 1
      rollback tran
      raiserror 20005 "FAILD: PdCTRGRO_01"
      return @erreur
   end

if @tran_on = 1
   commit tran
       
return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESDCTR01', 'PdCTRGRO_01', 'BEST', 'ME31'
go

IF OBJECT_ID('dbo.PdCTRGRO_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdCTRGRO_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdCTRGRO_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdCTRGRO_01
 */
GRANT EXECUTE ON dbo.PdCTRGRO_01 TO GOMEGA
go

