use BEST
go


USE BEST
Go

/* DROP PROC dbo.PsAUTPAR_01
*/
IF OBJECT_ID('dbo.PsAUTPAR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsAUTPAR_01
   PRINT '<<< DROPPED PROC dbo.PsAUTPAR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsAUTPAR_01
     ( 	@p_ssd_cf              USSD_CF     )
as

/***************************************************

Programme: PsAUTPAR_01

Fichier script associé : ESSAUT01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: Gordana DIMCEA avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TAUTPAR

Parametres: 
       @p_ssd_cf              USSD_CF

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


 Select ctrnat_ct,
        lob_cf,
        pcprsktry_cf,
        sob_cf,
        limper_r * 100,
        quanum_nb,
        ssd_cf
  from TAUTPAR
  where  ssd_cf = @p_ssd_cf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TAUTPAR" /* erreur de selection */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSAUT01', 'PsAUTPAR_01', 'BEST', 'ME08'
go

IF OBJECT_ID('dbo.PsAUTPAR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsAUTPAR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsAUTPAR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsAUTPAR_01
 */
GRANT EXECUTE ON dbo.PsAUTPAR_01 TO GOMEGA
go

