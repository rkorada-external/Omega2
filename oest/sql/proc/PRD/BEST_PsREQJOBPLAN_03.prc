USE BEST
Go

/*
 * DROP PROC dbo.PsREQJOBPLAN_03
 */
IF OBJECT_ID('dbo.PsREQJOBPLAN_03') IS NOT NULL
BEGIN
    DROP PROC dbo.PsREQJOBPLAN_03
    PRINT '<<< DROPPED PROC dbo.PsREQJOBPLAN_03 >>>'
END
go

/*
 * creation de la procedure
*/

create procedure PsREQJOBPLAN_03 (
		@p_balsheyea_nf  integer,
		@p_balshtmth_nf  integer,
		@p_clodat_d      datetime,
		@p_cre_d         datetime,
		@p_dbclo_d       datetime,
		@p_site_cf       varchar(10)
                                )

as

/***************************************************

Programme:                 PsREQJOBPLAN_03
Fichier script associé :   BEST_PsREQJOB_14.prc
Domaine :                  (ES) Estimation
Base principale :          BEST
Version:                   1
Auteur:                    Tony RIPERT
Date de creation:          24/08/2010

Description du programme:
        Vérification qu'on a demandé une Comptabilisation PostOmega

Parametres:
Conditions d'execution:
Commentaires:
Modifications:
_________________

[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
*****************************************************/

declare  @erreur        int,
         @A_traiter     int,
         @v_codeerrRet  int

Select @v_codeerrRet = 0

IF      EXISTS (SELECT 1 FROM BEST..TREQJOB
		   WHERE REQCOD_CT = 'F'
		        and Launch_d = Null
		        and balsheyea_nf = @p_balsheyea_nf
		        and balshtmth_nf = @p_balshtmth_nf
		        and convert(char(8) , clodat_d, 112) = @p_clodat_d
		        and site_cf      = @p_site_cf
--		        and convert(char(8) , cre_d, 112) = @p_cre_d
--		        and convert(char(8) , dbclo_d, 112) = @p_dbclo_d
                    )
AND EXISTS (SELECT 1 FROM BEST..TREQJOB
		   WHERE REQCOD_CT = 'T'
		        and Launch_d = Null
		        and balsheyea_nf = @p_balsheyea_nf
		        and balshtmth_nf = @p_balshtmth_nf
		        and convert(char(8) , clodat_d, 112) = @p_clodat_d
		        and site_cf      = @p_site_cf
--		        and convert(char(8) , cre_d, 112) = @p_cre_d
--		        and convert(char(8) , dbclo_d, 112) = @p_dbclo_d
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


IF OBJECT_ID('dbo.PsREQJOBPLAN_03') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PsREQJOBPLAN_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PsREQJOBPLAN_03 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PsREQJOBPLAN_03
 */
GRANT EXECUTE ON dbo.PsREQJOBPLAN_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsREQJOBPLAN_03 TO GDBBATCH
go


