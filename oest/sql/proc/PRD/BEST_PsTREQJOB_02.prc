/*
 * DROP PROC dbo.PsTREQJOB_02
 */
 
use BEST

IF OBJECT_ID('dbo.PsTREQJOB_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PsTREQJOB_02
    PRINT '<<< DROPPED PROC dbo.PsTREQJOB_02 >>>'
END
go
 



create procedure PsTREQJOB_02
as
declare @n_CdRet int, 
	    @launch_b char(1)

select @n_Cdret = 0



/***************************************************

Programme: PsTREQJOB_02

Fichier script associé : BEST_PsTREQJOB_02.PRC
Domaine : (RT) Rétro
Base principale : BEST
Version: 1
Auteur: S.LLORENTE ( NON AUTO)
Date de creation: 10/2000 
Description du programme: 
    Determiner le Lancement de ESIJ0010

Parametres: 0
Conditions d'execution: 
Commentaires: Sortie dans un fichier FRES de la valeur de launch_b

_________________
MODIFICATION 1

Auteur:
Date:
Version:                   

*****************************************************/



/* Gestion du bit de lancement */
select @launch_b = '0'
if exists ( select REQCOD_CT from BEST..TREQJOB
                         where REQCOD_CT = 'O'
                           and LAUNCH_D  = NULL
           )
                        
  begin
    select @launch_b = '1'      
  end

select @n_CdRet = @@error
if @n_CdRet != 0 
  begin
    raiserror 20003 "Error in select/PsTREQJOB_02"
    return 1
  end                          


  
fin:

select @launch_b+"~"



return



go
IF OBJECT_ID('dbo.PsTREQJOB_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsTREQJOB_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsTREQJOB_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsTREQJOB_02
 */
GRANT EXECUTE ON dbo.PsTREQJOB_02 TO GOMEGA
go
