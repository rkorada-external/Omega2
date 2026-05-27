use BSTA
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PdIBNR_01
*/

IF OBJECT_ID('dbo.PdIBNR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdIBNR_01
   PRINT '<<< DROPPED PROC dbo.PdIBNR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdIBNR_01
     (
       @p_ssd_cf           USSD_CF
     )
as

/***************************************************

Programme: PdIBNR_01

Fichier script associé : ESDIBN01.PRC


Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)

Date de creation: 

Description du programme: 

      suppression d'enregistrement dans TIBNRSUP

Parametres: 
         @p_ssd_cf           USSD_CF

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

BEGIN TRAN
/* Suppression des enregistrements précédents                                  */

delete BSAR..TIBNRSUP
  where ssd_cf = @p_ssd_cf
	and acctyp_nf in (98,99)

if @@error != 0 goto fin 


COMMIT TRAN

select 0
return 0

fin:
	ROLLBACK TRAN
	select -1
	return -1
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESDIBN01', 'PdIBNR_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PdIBNR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdIBNR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdIBNR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdIBNR_01
 */
GRANT EXECUTE ON dbo.PdIBNR_01 TO GOMEGA
go

