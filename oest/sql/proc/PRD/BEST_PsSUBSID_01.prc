use BEST
go


USE BEST
Go

 /* DROP PROC dbo.PsSUBSID_01
*/
IF OBJECT_ID('dbo.PsSUBSID_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSUBSID_01
   PRINT '<<< DROPPED PROC dbo.PsSUBSID_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSUBSID_01
     
as

/***************************************************

Programme: PsSUBSID_01

Fichier script associé : ESSSUB01.PRC

Domaine : (ES) Estimation

Base principale : BREF

Version: 1

Auteur: Gordana DIMCEA avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TSUBSID

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


 Select ssd_cf,
        ssd_ll,
        ssd_ls,
        ssdomglag_cf
   from BREF..TSUBSID
  
   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TSUBSID" /* erreur de selection */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSUB01', 'PsSUBSID_01', 'BEST', 'ME08'
go

IF OBJECT_ID('dbo.PsSUBSID_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSUBSID_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSUBSID_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSUBSID_01
 */
GRANT EXECUTE ON dbo.PsSUBSID_01 TO GOMEGA
go

