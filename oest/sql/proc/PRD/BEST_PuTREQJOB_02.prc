/*
 * DROP PROC dbo.PuTREQJOB_02
 */

use BEST

IF OBJECT_ID('dbo.PuTREQJOB_02') IS NOT NULL
BEGIN
    DROP PROC dbo.PuTREQJOB_02
    PRINT '<<< DROPPED PROC dbo.PuTREQJOB_02 >>>'
END
go
  
/* creation de la procedure  */

create procedure PuTREQJOB_02
(
    @date_t UUPD_D
)
as

declare @n_CdRet int
select @n_Cdret = 0


/***************************************************

Programme: PuTREQJOB_02

Fichier script associé : BEST_PuTREQJOB_02.PRC
Domaine : (RT) Rétro
Baseprincipale : BEST
Version: 1
Auteur: S.LLORENTE ( NON AUTO)
Date de creation: 10/2000 
Description du programme: Update de la table TREQJOB DEMANDES O

Parametres: 1
Conditions d'execution: 
Commentaires:
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @site_cf        varchar(10),
        @erreur         int
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

 /* update de la table */
 update BEST..TREQJOB
   set LAUNCH_D  = @date_t
 where REQCOD_CT = 'O'
   and LAUNCH_D  = NULL
   AND SITE_CF   = @site_cf
  

        
select @n_CdRet = @@error
  if @n_CdRet != 0 
  begin
     raiserror 20003 "Error in update/PuTREQJOB_02"
     return 1
  end
   
                            
return @n_Cdret

go
IF OBJECT_ID('dbo.PuTREQJOB_02') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuTREQJOB_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuTREQJOB_02 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuTREQJOB_02
 */
GRANT EXECUTE ON dbo.PuTREQJOB_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuTREQJOB_02 TO GDBBATCH
go
