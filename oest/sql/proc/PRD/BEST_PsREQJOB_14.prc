USE BEST
Go

/*
 * DROP PROC dbo.PsREQJOB_14
 */
IF OBJECT_ID('dbo.PsREQJOB_14') IS NOT NULL
BEGIN
    DROP PROC dbo.PsREQJOB_14
    PRINT '<<< DROPPED PROC dbo.PsREQJOB_14 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsREQJOB_14 (
		@p_balsheyea_nf  integer,
		@p_balshtmth_nf  integer,
		@p_clodat_d      datetime,
		@p_cre_d         datetime,
		@p_dbclo_d       datetime,
	  @p_ssd_cf        USSD_CF
                                )
     
as

/***************************************************

Programme: PsREQJOB_14
Fichier script associé : BEST_PsREQJOB_14.prc
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: M. DJELLOULI
Date de creation: 13/09/2005

Description du programme: 	
        Vérification qu'on a demandé une Comptabilisation PostOmega
        
Parametres:
Conditions d'execution: 
Commentaires:
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare 	@erreur int,  @A_traiter     int
declare   @v_codeerrRet    integer

Select @v_codeerrRet = 0

declare @site_cf        varchar(10)
Execute @erreur = BEST..PsSITE_01 @p_ssd_cf,'2',@site_cf output

IF      EXISTS (SELECT 1 FROM BEST..TREQJOB
		   WHERE REQCOD_CT = 'F'
		        and Launch_d = Null
		        and balsheyea_nf = @p_balsheyea_nf
		        and balshtmth_nf = @p_balshtmth_nf
		        and convert(char(8) , clodat_d, 112) = @p_clodat_d
--		        and convert(char(8) , cre_d, 112) = @p_cre_d
--		        and convert(char(8) , dbclo_d, 112) = @p_dbclo_d
            and SITE_CF = @site_cf
                    )
AND EXISTS (SELECT 1 FROM BEST..TREQJOB
		   WHERE REQCOD_CT = 'T'
		        and Launch_d = Null
		        and balsheyea_nf = @p_balsheyea_nf
		        and balshtmth_nf = @p_balshtmth_nf
		        and convert(char(8) , clodat_d, 112) = @p_clodat_d
--		        and convert(char(8) , cre_d, 112) = @p_cre_d
--		        and convert(char(8) , dbclo_d, 112) = @p_dbclo_d
            and SITE_CF = @site_cf
                    )
                    
Begin
    Select @v_codeerrRet = 1
End

fin:

Select @v_codeerrRet

return @v_codeerrRet

go

/*
 * fin de la procedure 
 */

IF OBJECT_ID('dbo.PsREQJOB_14') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsREQJOB_14 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsREQJOB_14 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOB_14
 */
GRANT EXECUTE ON dbo.PsREQJOB_14 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOB_14 TO GDBBATCH
go


