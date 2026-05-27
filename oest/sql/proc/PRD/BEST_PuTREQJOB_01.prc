USE BEST
go

IF OBJECT_ID('dbo.PuTREQJOB_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PuTREQJOB_01
    PRINT '<<< DROPPED PROC dbo.PuTREQJOB_01 >>>'
END
go
  
/*
 * creation de la procedure  */
create procedure PuTREQJOB_01 (
    @date_t UUPD_D,
    @blcshtyea smallint, --issu de la proc PsTREQJOB_01
    @blcshtmth tinyint   --issu de la proc PsTREQJOB_01
)

as
/***************************************************
Programme:                  PuTREQJOB_01
Fichier script associé :    ESURJB01.PRC
Domaine :                   (RT) Rétro
Baseprincipale :            BEST
Version:                    1
Auteur:                     S.LLORENTE ( NON AUTO)
Date de creation:           10/2000 
Description du programme:   Update de la table TREQJOB+TREQJOBPLAN pour les demandes V
Parametres:                 3
Conditions d'execution: 
Commentaires:
_________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA
Date:           05/10/2010
Version:        ESTDOM19070 V10 scheduler pour le lancement des inventaires

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/
declare @n_CdRet int
select @n_Cdret = 0

declare @site_cf        varchar(10),
        @erreur         int
declare @suser_Name     varchar(20)
select  @suser_Name = suser_Name()
Execute @erreur = BEST..PsSITE_01 @suser_Name,'0',@site_cf output

 /* update de la table */
 update BEST..TREQJOB
   set LAUNCH_D = @date_t
 where REQCOD_CT = 'V'
   and LAUNCH_D = NULL
   and BALSHEYEA_NF = @blcshtyea
   and BALSHTMTH_NF = @blcshtmth
   and SITE_CF      = @site_cf
        
select @n_CdRet = @@error
  if @n_CdRet != 0 
  begin
     raiserror 20003 "Error in update/PuTREQJOB_01"
     return 1
  end
   

 /*[001] Pareil pour la TREQJOBPLAN */
 update BEST..TREQJOBPLAN
   set LAUNCH_D = @date_t,
       END_D    = @date_t
 where REQCOD_CT = 'V'
   and LAUNCH_D = NULL
   and BALSHEYEA_NF = @blcshtyea
   and BALSHTMTH_NF = @blcshtmth
   and SITE_CF      = @site_cf
        
select @n_CdRet = @@error
  if @n_CdRet != 0 
  begin
     raiserror 20003 "Error 2 in update/PuTREQJOB_01"
     return 1
  end
   
                            
return @n_Cdret

go
IF OBJECT_ID('dbo.PuTREQJOB_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuTREQJOB_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuTREQJOB_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PuTREQJOB_01
 */
GRANT EXECUTE ON dbo.PuTREQJOB_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuTREQJOB_01 TO GDBBATCH
go
