USE BEST
go
IF OBJECT_ID('dbo.PsTEXPRAT_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTEXPRAT_01
    IF OBJECT_ID('dbo.PsTEXPRAT_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTEXPRAT_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTEXPRAT_01 >>>'
END
go
/*
 * creation de la procedure 
*/

create procedure dbo.PsTEXPRAT_01
(
    @p_norm_cf		char(5),
    @p_clodat_d		datetime,
    @p_per_cf		char(10)
)
as

/***************************************************

Procedure: PsTEXPRAT_01

Domaine : Expenses and Maintenance calculations

Base principale : BEST

Version: 1

Auteur: L.ELFAHIM

Date de creation: 12/2018
____________
MODIFICATION 1

Auteur: L.ELFAIM

Date:  08/07/2019

Version: 

Description: Suite à léechange avec Patrick on a ajouter la jointure avec la table TSEGMT

*****************************************************/

declare @erreur int



BEGIN

	SELECT 	    SSD_CF, ESB_CF, SGMT_LS, NORME_CF, CTRNAT_CT, ACQRAT_R, MAINTRAT_R 
	FROM	    BEST..TEXPRAT a, BEST..TSEGMT b
	WHERE	    NORME_CF 	= @p_norm_cf
   	AND          CLODAT_D 	= @p_clodat_d
   	AND          PER_CF     = @p_per_cf
    	AND          SSD_CF     <> NULL
    	AND          a.SEG_NF   = 108
    	AND          b.SGTVER_NT = 54 
    	AND          a.SEG_NF   = b.SGT_NT

END

return 0
go
EXEC sp_procxmode 'dbo.PsTEXPRAT_01', 'unchained'
go
IF OBJECT_ID('dbo.PsTEXPRAT_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTEXPRAT_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTEXPRAT_01 >>>'
go
GRANT EXECUTE ON dbo.PsTEXPRAT_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTEXPRAT_01 TO GDBBATCH
go

