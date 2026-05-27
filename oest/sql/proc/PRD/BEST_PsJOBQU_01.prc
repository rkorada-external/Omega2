/*
 * DROP PROC dbo.PsJOBQU_01
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsJOBQU_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsJOBQU_01
   PRINT '<<< DROPPED PROC dbo.PsJOBQU_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsJOBQU_01
     (
@p_i_jobuser 	char(5),
@p_i_job 	char(8),
@p_ssd 	char(30),
@p_segtyp	char(30)     
     )
as

/***************************************************

Programme: PsJOBQU_01

Fichier script associé : ESSJOB01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (ME01 - L.DEBEVER)

Date de creation: 02/04/1998

Description du programme: 

      Sélection d'enregistrement dans TJOBQUEUE

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
	 @job  char(8)
	

/* On recherche si un job est en cours pour l'utilisateur */
Select  @job = I_JOB         
   	from BTEC..TJOBQUEUE
  where I_JOB = @p_i_job
	and I_JOB_USER = @p_i_jobuser

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TJOBQUEUE" 
      return 1
   end


/* S'il n'y a pas de job pour l'utilisateur, on recherche si un job est en cours pour */
/* la filiale / type de segment                                                       */
IF  @job is null

BEGIN

 Select  @job = I_JOB         
   	from BTEC..TTASKQUEUE
  where I_JOB = @p_i_job
    and N_PARM_VAL_1 = @p_ssd
    and N_PARM_VAL_2 = @p_segtyp 
   

   select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20003 "APPLICATIF;TTASKQUEUE" 
      return 1
   end

END

select  @job

return 0
go

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESSJOB01', 'PsJOBQU_01', 'BEST', 'ME01'
go

IF OBJECT_ID('dbo.PsJOBQU_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsJOBQU_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsJOBQU_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsJOBQU_01
 */
GRANT EXECUTE ON dbo.PsJOBQU_01 TO GOMEGA
go

