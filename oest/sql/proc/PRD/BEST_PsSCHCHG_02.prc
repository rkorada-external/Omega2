
USE BEST
Go

/* DROP PROC dbo.PsSCHCHG_02
*/
IF OBJECT_ID('dbo.PsSCHCHG_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsSCHCHG_02
   PRINT '<<< DROPPED PROC dbo.PsSCHCHG_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsSCHCHG_02
     (
       @p_ssd_cf              USSD_CF   
      )
as

/***************************************************

Programme: PsSCHCHG_2

Fichier script associé : ESSSCH02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TADDIP

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

declare @erreur int,
	 @PRDSIT_CF  char(4)


 Select  @PRDSIT_CF = PRDSIT_CF
   from BREF..TSUBSID 
  where SSD_CF =  @p_ssd_cf

  select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TSUBSID" /* erreur de selection */
      return @erreur
   end


 Select  PRTUSR_CF,
	  PRTPWD_CF,
	  PRTCDFTP_CF,
	  PRTADDIP_CF,
	  PRTENDADR_CF 
 from BREF..TADDIP A
 where  PRDSIT_CF = @PRDSIT_CF and
	 GEOSIT_CF = 'Ibnr'	 

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TADDIP" /* erreur de selection */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSSCH02', 'PsSCHCHG_02', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsSCHCHG_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsSCHCHG_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsSCHCHG_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsSCHCHG_02
 */
GRANT EXECUTE ON dbo.PsSCHCHG_02 TO GOMEGA
go

