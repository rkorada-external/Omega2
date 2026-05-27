USE BEST
Go

IF OBJECT_ID('dbo.PsCALEND_08') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsCALEND_08
   PRINT '<<< DROPPED PROC dbo.PsCALEND_08 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCALEND_08
as

/***************************************************

Programme: PsCALEND_08

Fichier script associé : BEST_PsCALEND_08.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 18 Novembre 1997

Description du programme: 

      Sélection d'enregistrement dans TCALEND (BREF)

Parametres: 


Conditions d'execution: 


Commentaires:
        Attention, la PROC utilise la Date Système, si l'on fait un restart de JOB par rapport à la Date de Création 

*****************************************************/

declare @erreur int, @ligne int

Declare @DATEPARAM Datetime
Select @DATEPARAM = GetDate()

If EXISTS (SELECT 1 FROM BREF..TCALEND
               WHERE SPECEND_D <= @DATEPARAM and  @DATEPARAM <= ACCOUNT_D
--			and CLOSING_B = 1
              )
    Begin
        SELECT 1            -- Suppression Non Autorisée
    End
Else
    Begin
        SELECT 0
    End

  select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TBLCSHTD" 
      return 1
   end


return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSCAL08', 'PsCALEND_08', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsCALEND_08') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsCALEND_08 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsCALEND_08 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsCALEND_08
 */
GRANT EXECUTE ON dbo.PsCALEND_08 TO GOMEGA
go

