use BEST
go


USE BEST
Go

 /* DROP PROC dbo.PsESTCOM_01
*/
IF OBJECT_ID('dbo.PsESTCOM_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsESTCOM_01
   PRINT '<<< DROPPED PROC dbo.PsESTCOM_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsESTCOM_01
     (
       @p_cmt_nt              UCMT_NT  
     )
as

/***************************************************

Programme: PsESTCOM_01

Fichier script associé : ESSEST01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TESTCOM

Parametres: 
       @p_cmt_nt              UCMT_NT,

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


 Select cmt_nt,
        cmtlin_nt,
        cmt_t
   from TESTCOM
  where cmt_nt = @p_cmt_nt
 

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TESTCOM" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSEST01', 'PsESTCOM_01', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsESTCOM_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsESTCOM_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsESTCOM_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsESTCOM_01
 */
GRANT EXECUTE ON dbo.PsESTCOM_01 TO GOMEGA
go

