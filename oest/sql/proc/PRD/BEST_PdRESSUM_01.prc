use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go

 /* DROP PROC dbo.PdRESSUM_01
*/
IF OBJECT_ID('dbo.PdRESSUM_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdRESSUM_01
   PRINT '<<< DROPPED PROC dbo.PdRESSUM_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdRESSUM_01
     
as

/***************************************************

Programme: PdRESSUM_01

Fichier script associé : ESDRES01.PRC


Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME69 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 
      - purge des tables TRESSUM, TIPPORT, TCALPRE, TEARIPP, TLOARAT, TPRMLOA, TCONPAR
à chaque passage de l'inventaire principal

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
        
select @erreur = 0


/* ---------------------------------------------------------------------
   purge des tables TRESSUM, TIPPORT, TCALPRE, TEARIPP, TLOARAT, TPRMLOA
   --------------------------------------------------------------------- */
truncate table BEST..TRESSUM
truncate table BEST..TIPPORT
truncate table BEST..TCALPRE
truncate table BEST..TEARIPP
truncate table BEST..TLOARAT
truncate table BEST..TPRMLOA
truncate table BEST..TCONPAR

select @erreur = @@error

return @erreur
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESDRES01', 'PdRESSUM_01', 'BEST', 'ME69'
go

IF OBJECT_ID('dbo.PdRESSUM_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdRESSUM_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdRESSUM_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdRESSUM_01
 */
GRANT EXECUTE ON dbo.PdRESSUM_01 TO GOMEGA
go

