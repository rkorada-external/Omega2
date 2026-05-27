USE BEST
go
IF OBJECT_ID('dbo.PsTRARAT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTRARAT_01
    IF OBJECT_ID('dbo.PsTRARAT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTRARAT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTRARAT_01 >>>'
END
go
/*
 * creation de la procedure 
*/

create procedure dbo.PsTRARAT_01
(
    @p_norm_cf		char(5),
    @p_clodat_d		datetime,
    @p_per_cf		char(10)
)
as

/***************************************************

Procedure: PsTRARAT_01

Domaine : ESTIMATIONS - Risk Adjusment Ratios

Base principale : BEST

Version: 1

Auteur: JYP - PERSEE

Date de creation: 12/04/2019
____________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

*****************************************************/

declare @erreur int



BEGIN

	SELECT 	    SSD_CF, ESB_CF, SEG_NF, NORME_CF, CTRNAT_CT, DOMAIN_CF, PRMRAT_R,  RSRVRAT_R
	FROM	    BEST..TRARAT
	WHERE	    NORME_CF = @p_norm_cf
    AND         convert(date, CLODAT_D) = @p_clodat_d
    AND         PER_CF   = @p_per_cf
    AND         SSD_CF <> NULL

END

select @erreur = @@error
if @erreur != 0
   return @erreur
   
return 0
go

IF OBJECT_ID('dbo.PsTRARAT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTRARAT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTRARAT_01 >>>'
go
GRANT EXECUTE ON dbo.PsTRARAT_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTRARAT_01 TO GDBBATCH
go
