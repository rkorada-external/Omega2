USE BEST
go

IF OBJECT_ID('dbo.PdCTRULT_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdCTRULT_01
   PRINT '<<< DROPPED PROC dbo.PdCTRULT_01 >>>'
END
go


/*
 * creation de la procedure 
*/

create procedure PdCTRULT_01
as
/***************************************************

Programme: PdCTRULT_01
Fichier script associé : ESDULT01.PRC
Domaine : (ES) Estimation
Base principale : BEST

Version: 1
Auteur: O.GIRAUX
Date de creation:04/01/2000 
Description du programme: 
      Purge des facultatives dans les ultimes

Parametres: Aucun
Conditions d'execution: 
Commentaires:

_________________
MODIFICATION 1

Auteur: Florence Charles
Date: 28/11/2000
Version:
Description: On ne supprime pas la 1ère ligne des ultimes

MODIFICATION 3
Auteur: KBagwe
Date: 11/10/2013
Version:
Description:  Phase1b: Removed LIKE from condition and modified with bfac..Tcontr.          
*****************************************************/


declare @erreur int,
	 @tran_on smallint
    
   
        
select @erreur = 0
select @tran_on = 0



/* ------------------------------------------------------------
   Début de la transaction
 -------------------------------------------------------------- */

if @@trancount = 0
  begin
   select @tran_on = 1
   BEGIN TRAN
  end


DELETE BEST..TCTRULT
WHERE  Exists(Select 1 From bfac..Tcontr tcon Where tcon.Ctr_Nf = BEST..TCTRULT.ctr_nf AND
 tcon.UWY_NF = BEST..TCTRULT.UWY_NF AND tcon.UW_NT = BEST..TCTRULT.UW_NT AND tcon.END_NT = BEST..TCTRULT.END_NT)		--MOD3

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20001 "Erreur lors de la suppression de lignes dans best..tctrult" 
    goto fin
end


DELETE BEST..TUNDSTA
WHERE  CTR_NF like "__G%" or CTR_NF like "__F%"

select @erreur = @@error
if @erreur != 0
begin
    raiserror 20002 "Erreur lors de la suppression de lignes dans best..tundsta" 
    goto fin
end



/* ------------------------------------------------------------
   Fin de la transaction
 -------------------------------------------------------------- */

if @tran_on = 1
	 COMMIT TRAN

return 0


fin:
if @tran_on = 1
begin
	 ROLLBACK TRAN
	return @erreur
end

go


/*
 * fin de la procedure 
 */


IF OBJECT_ID('dbo.PdCTRULT_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PdCTRULT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PdCTRULT_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdCTRULT_01
 */
GRANT EXECUTE ON dbo.PdCTRULT_01 TO GOMEGA
go

