use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go
/* DROP PROC dbo.PsBANTECL_02
*/
IF OBJECT_ID('dbo.PsBANTECL_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsBANTECL_02
   PRINT '<<< DROPPED PROC dbo.PsBANTECL_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsBANTECL_02
     (
       @p_col_ls              UL16
     )
as

/***************************************************

Programme: PsBANTECL_02

Fichier script associé : ESSBAN02.PRC

Domaine : (ES) Estimation

Base principale : BREF

Version: 1

Auteur: ME27 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TBANTECL

Parametres: 
       @p_col_ls              UL16

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1
[001] 27/12/2013 R. cassis :spot:25427 Centralization - ajout Grant

*****************************************************/

declare @erreur int


 Select  LAG_CF,
	convert(int,colval_ct),
	colval_lm
   from BREF..TBANTECL
  where col_ls = @p_col_ls


   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TBANTECL" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */


IF OBJECT_ID('dbo.PsBANTECL_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsBANTECL_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsBANTECL_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsBANTECL_02
 */
GRANT EXECUTE ON dbo.PsBANTECL_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsBANTECL_02 TO GDBBATCH
go

