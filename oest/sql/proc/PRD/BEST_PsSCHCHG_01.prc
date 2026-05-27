
USE BEST
Go

/* DROP PROC dbo.PsSCHCHG_01
*/
IF OBJECT_ID('dbo.PsSCHCHG_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSCHCHG_01
   PRINT '<<< DROPPED PROC dbo.PsSCHCHG_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSCHCHG_01
     (
       @p_usr_cf              UUPDUSR_CF    
      )
as

/***************************************************

Programme: PsSCHCHG_01

Fichier script associé : ESSSCH01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TSCHCHG

Parametres: 
     @p_usr_cf              UUPDUSR_CF    

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


 Select  LOGTYPE_CT,
    LOGMSG_LL,
    LOGDAT_D              
   from BEST..TESTSCH
  where usr_cf =  @p_usr_cf
    

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TESTCHG" /* erreur de selection */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSCH01', 'PsSCHCHG_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsSCHCHG_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSCHCHG_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSCHCHG_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSCHCHG_01
 */
GRANT EXECUTE ON dbo.PsSCHCHG_01 TO GOMEGA
go

