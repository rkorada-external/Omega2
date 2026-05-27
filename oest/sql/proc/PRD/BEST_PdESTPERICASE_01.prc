use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
USE BEST
Go

/* DROP PROC dbo.PdESTPERICASE_01
 */
IF OBJECT_ID('dbo.PdESTPERICASE_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PdESTPERICASE_01
   PRINT '<<< DROPPED PROC dbo.PdESTPERICASE_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PdESTPERICASE_01
as

/***************************************************

Programme: PdESTPERICASE_01

Fichier script associé : ESDPER01.PRC


Domaine : (ES) Estimation

Base principale : BTRAV

Version: 1

Auteur: ME27 avec Infotool version 2.0 (AUTO)

Date de creation: 

Description du programme: 

      Suppression des enregistrements dans les tables de travail
	estimations apres le passage de la generation retrocession.

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

truncate table BTRAV..TESTPERICASE

truncate table BTRAV..TESTLIFEST

truncate table BTRAV..TESTPLACEMT

go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESDPER01', 'PdESTPERICASE_01', 'BTRAV', 'ME27'
go

IF OBJECT_ID('dbo.PdESTPERICASE_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PdESTPERICASE_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PdESTPERICASE_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PdESTPERICASE_01
 */
GRANT EXECUTE ON dbo.PdESTPERICASE_01 TO GOMEGA
go

