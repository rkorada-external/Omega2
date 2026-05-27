USE BEST
Go

IF OBJECT_ID('dbo.PsJOBQU_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsJOBQU_02
   PRINT '<<< DROPPED PROC dbo.PsJOBQU_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsJOBQU_02
     (
@p_i_jobuser 	char(5),
@p_i_job 	char(8)
     )
as

/***************************************************

Programme: PsJOBQU_02

Fichier script associé : ESSJOB02.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 08/03/1999

Description du programme: 

      Sélection d'enregistrement dans TTASKCOMPLETION

Parametres: 
    	
@p_i_jobuser 	char(5),
@p_i_job 	char(8),
@p_ssd 	char(30),
@p_segtyp	char(30) 

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
	 @ligne int,
	 @status  tinyint
	

/* On recherche si le job de l'utilisateur est terminé */
SELECT @status = T1.C_TASK_STATUS
FROM BTEC..ttaskcompletion T1
WHERE  T1.Q_TASK_SEQ = 1 AND T1.I_JOB_USER = @p_i_jobuser AND I_JOB = @p_i_job
AND T1.T_JOB_LNCH = (select max(T1.T_JOB_LNCH) 
			 FROM BTEC..ttaskcompletion T1, BTEC..ttask T2
			 WHERE  T1.Q_TASK_SEQ = 1 AND T1.I_JOB_USER = @p_i_jobuser AND I_JOB = @p_i_job)

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TTASKCOMPLETION" 
      return 1
   end


/* On retourne le code retour du job */
select @status

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSJOB02', 'PsJOBQU_02', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsJOBQU_02') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsJOBQU_02 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsJOBQU_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsJOBQU_02
 */
GRANT EXECUTE ON dbo.PsJOBQU_02 TO GOMEGA
go

