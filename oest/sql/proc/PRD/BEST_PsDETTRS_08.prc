use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsDETTRS_08
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsDETTRS_08') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsDETTRS_08
   PRINT '<<< DROPPED PROC dbo.PsDETTRS_08 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsDETTRS_08
     (
       @p_dettrs_cf    UDETTRS_CF 
     )
as

/***************************************************

Programme: PsDETTRS_08

Fichier script associé : ESSACC08.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: L.DEBEVER (ME01) avec Infotool version 2.0 

Date de creation: 07/01/1998

Description du programme: 

      Sélection poste de contrepartie

Parametres: 
     @p_dettrs_cf    UDETTRS_CF 

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
	 
    

/* poste de contrepartie  */
select ctrscod_cf from BREF..TDETTRS 
where dettrs_cf = @p_dettrs_cf 

select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TDETTRS" /* erreur de lecture */
      return @erreur
   end


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSACC08', 'PsDETTRS_08', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsDETTRS_08') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsDETTRS_08 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsDETTRS_08 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsDETTRS_08
 */
GRANT EXECUTE ON dbo.PsDETTRS_08 TO GOMEGA
go

