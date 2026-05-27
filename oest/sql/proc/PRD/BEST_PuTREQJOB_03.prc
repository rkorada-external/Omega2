use BEST
go

/*
 * DROP PROC dbo.PuTREQJOB_03 */
IF OBJECT_ID('dbo.PuTREQJOB_03') IS NOT NULL
BEGIN
    DROP PROC dbo.PuTREQJOB_03
    PRINT '<<< DROPPED PROC dbo.PuTREQJOB_03 >>>'
END
go
  
/*
 * creation de la procedure  */
create procedure PuTREQJOB_03 (
    @date_t datetime
)

as
/***************************************************
Programme :         PuTREQJOB_03
Baseprincipale :    BEST
Auteur :            D.GATIBELZA
Date de creation :  25/05/2010
Description :       ESTDOM12363 Revoir le mécanisme de lancement de la comptabilisation des réglements, de lancement des inventaires
                    - On remet à null le chanpd LAUNCH_D de TREQJOB pour déclencher les demandes d'inventaires qui ont été lancées
                      pendant la comptabilisation mensuelle.
_________________
[001] 24/05/2012 Roger Cassis :spot:23802 - Modifications pour Solvency Ajout 'E'.
*****************************************************/

    /* update de la table */
    update best..TREQJOB
       set LAUNCH_D = null
    where REQCOD_CT in ('D','E','I','J','L')  -- [001]
      and LAUNCH_D is not null
      and CRE_D >= @date_t
           
    if @@error != 0 
    begin
        raiserror 20003 "Error in update/PuTREQJOB_03"
        return 1
    end


return 0
go

IF OBJECT_ID('dbo.PuTREQJOB_03') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PuTREQJOB_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PuTREQJOB_03 >>>'
go

/*
 * Granting/Revoking Permissions on dbo.PuTREQJOB_03 */
GRANT EXECUTE ON dbo.PuTREQJOB_03 TO GOMEGA
go



