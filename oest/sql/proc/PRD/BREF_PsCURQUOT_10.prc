use BREF
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsCURQUOT_10
*/
IF OBJECT_ID('dbo.PsCURQUOT_10') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCURQUOT_10
   PRINT '<<< DROPPED PROC dbo.PsCURQUOT_10 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCURQUOT_10
     (
       @p_cur_cf              UCUR_CF,
       @p_exc_d               datetime,
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsCURQUOT_10

Fichier script associé : RFSCUR10.PRC

Domaine : (RF) Références

Base principale : BREF

Version: 1

Auteur: ME65 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Sélection d'enregistrement dans TCURQUOT

Parametres: 
       @p_cur_cf              UCUR_CF,
       @p_exc_d               datetime,
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


 Select cur_cf,
        exc_d,
        ssd_cf,
        actcod_b,
        exc_r,
        excori_cf,
        exctyp_cf,
        lstupd_d,
        lstupdusr_cf,
        convert(char(21), convert(numeric(19,4),convert(money,timestamp)))
   from TCURQUOT
  where cur_cf = @p_cur_cf
    and exc_d = @p_exc_d
    and ssd_cf = @p_ssd_cf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TCURQUOT" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'RFSCUR10', 'PsCURQUOT_10', 'BREF', 'ME65'
go

IF OBJECT_ID('dbo.PsCURQUOT_10') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCURQUOT_10 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCURQUOT_10 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCURQUOT_10
 */
GRANT EXECUTE ON dbo.PsCURQUOT_10 TO GOMEGA
go

