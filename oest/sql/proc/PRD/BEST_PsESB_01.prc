use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsESB_01
*/
IF OBJECT_ID('dbo.PsESB_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsESB_01
   PRINT '<<< DROPPED PROC dbo.PsESB_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsESB_01
     (
 @p_SSD_CF       USSD_CF,
 @p_ESB_CF       UESB_CF
     )
as

/***************************************************

Programme: PsESB_01

Fichier script associé : ESSESB01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 03/04/2000

Description du programme: 

      Recherche du libellé d'un établissement

Parametres: 

 @p_SSD_CF       USSD_CF,
 @p_ESB_CF       UESB_CF
 

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int,
	 @ligne int
	

/********************************************************************************************/
/* Select dans TESB                                                                         */    
/********************************************************************************************/


 Select ESB_LS
   	from BREF..TESB
  where SSD_CF = @p_SSD_CF
    and ESB_CF = @p_ESB_CF
    
   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TESB" 
      return 1
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSESB01', 'PsESB_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsESB_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsESB_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsESB_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsESB_01
 */
GRANT EXECUTE ON dbo.PsESB_01 TO GOMEGA
go

