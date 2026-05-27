use BEST
go


USE BEST
Go

/* DROP PROC dbo.PsVERPAR_10
*/
IF OBJECT_ID('dbo.PsVERPAR_10') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsVERPAR_10
   PRINT '<<< DROPPED PROC dbo.PsVERPAR_10 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsVERPAR_10
     (
       @p_segtyp_ct           USEGTYP_CT,
       @p_ssd_cf              USSD_CF,
       @p_par_d               datetime = NULL
     )
as

/***************************************************

Programme: PsVERPAR_10

Fichier script associé : ESSVER10.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME34 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TVERPAR

Parametres: 
       @p_segtyp_ct           USEGTYP_CT,     : Type segment
       @p_ssd_cf              USSD_CF         : Filiale
       @p_par_d               datetime = NULL : Date paramètre

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


 SELECT a.ssd_cf, a.segtyp_ct, a.par_d, a.vrs_nf, b.vrs_lm 
   FROM TVERPAR a, TVERSION b
  WHERE a.ssd_cf         = b.ssd_cf  
    AND a.segtyp_ct      = b.segtyp_ct 
    AND a.vrs_nf         = b.vrs_nf 
    AND a.ssd_cf         = @p_ssd_cf
    AND a.segtyp_ct      = @p_segtyp_ct
    AND (a.par_d         >= @p_par_d OR @p_par_d is null )   
 
   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TVERPAR" /* erreur de sélection */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSVER10', 'PsVERPAR_10', 'BEST', 'ME34'
go

IF OBJECT_ID('dbo.PsVERPAR_10') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsVERPAR_10 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsVERPAR_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsVERPAR_10
 */
GRANT EXECUTE ON dbo.PsVERPAR_10 TO GOMEGA
go

