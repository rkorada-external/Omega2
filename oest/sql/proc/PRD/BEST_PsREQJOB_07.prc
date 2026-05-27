use BEST
go

/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 *
 * DROP PROC dbo.PsREQJOB_07
*/

USE BEST
Go

IF OBJECT_ID('dbo.PsREQJOB_07') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsREQJOB_07
   PRINT '<<< DROPPED PROC dbo.PsREQJOB_07 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsREQJOB_07
     (
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF
     )
as

/***************************************************

Programme: PsREQJOB_07

Fichier script associé : ESSREQ07.PRC
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)
Date de creation: 
Description du programme: 
      Sélection d'enregistrement dans TREQJOB

Parametres: 
       @p_balsheyea_nf        smallint,
       @p_balshtmth_nf        tinyint,
       @p_clodat_d            datetime,
       @p_cre_d               UUPD_D,
       @p_reqcod_ct           char(1),
       @p_ssd_cf              USSD_CF

Conditions d'execution: 
Commentaires:
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare @erreur int


 Select balsheyea_nf,
        balshtmth_nf,
        clodat_d,
        cre_d,
        reqcod_ct,
        ssd_cf,
        cloper_ls,
        dbclo_d,
        launch_d,
        updusr_cf,
        vrs_nf
   from BEST..TREQJOB
  where balsheyea_nf = @p_balsheyea_nf
    and balshtmth_nf = @p_balshtmth_nf
    and clodat_d = @p_clodat_d
    and cre_d = @p_cre_d
    and reqcod_ct = @p_reqcod_ct
    and ssd_cf = @p_ssd_cf

   select @erreur = @@error

   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TREQJOB" /* erreur de modification */
      return @erreur
   end



return 0
go

/*
 * fin de la procedure 
 */

IF OBJECT_ID('dbo.PsREQJOB_07') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PsREQJOB_07 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PsREQJOB_07 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOB_07
 */
GRANT EXECUTE ON dbo.PsREQJOB_07 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_07 TO GDBBATCH
go

