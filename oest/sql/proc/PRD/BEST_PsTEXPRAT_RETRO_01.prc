USE BEST
go
/*
 * creation de la procedure 
*/

create or replace procedure dbo.PsTEXPRAT_RETRO_01
(
    @p_norm_cf		char(5),
    @p_clodat_d		datetime,
    @p_per_cf		char(10)
)
as

/***************************************************

Procedure: PsTEXPRAT_RETRO_01

Domaine : RETRO NP Expenses calculation

Base principale : BEST

Version: 1

Auteur: L.ELFAHIM

Date de creation: 27/03/2020

SPIRA : 79102

*************************************************/


declare @erreur int

BEGIN
	SELECT		SSD_CF, ESB_CF, SEG_NF, NORME_CF, CTRNAT_CT, ACQRAT_R, MAINTRAT_R 
	FROM	  	BEST..TEXPRAT 
	WHERE	   	NORME_CF 	= @p_norm_cf
	AND   		CLODAT_D 	= @p_clodat_d
	AND  		PER_CF		= @p_per_cf
	AND  		SEG_NF   	= 900  
END

select @erreur = @@error
if @erreur != 0
   return @erreur
   
return 0
go
EXEC sp_procxmode 'dbo.PsTEXPRAT_RETRO_01', 'unchained'
go
IF OBJECT_ID('dbo.PsTEXPRAT_RETRO_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTEXPRAT_RETRO_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTEXPRAT_RETRO_01 >>>'
go
GRANT EXECUTE ON dbo.PsTEXPRAT_RETRO_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTEXPRAT_RETRO_01 TO GDBBATCH
go
