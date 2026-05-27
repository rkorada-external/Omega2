USE BEST
go
/*
 * creation de la procedure 
*/

create or replace procedure dbo.PsTEXPRAT_02
(
    @p_norm_cf		char(5),
    @p_clodat_d		datetime,
    @p_per_cf		char(10)
)
as

/***************************************************

Procedure: PsTEXPRAT_02
Domaine : Expenses and Maintenance calculations
Base principale : BEST
Auteur: LEL
Date de creation: 12/2018
_______________
MODIFICATION 1

Auteur: LEL
Date:  08/07/2019
Description: Suite A echange avec Patrick on a ajouter la jointure avec la 
table TSEGMT et deplacer la proc sur infocentre

_______________
MODIFICATION 2
Auteur : LEL
Date :  25/08/2021
SPIRA : 97351
Description : ACF/PCA: Expenses calculation

*****************************************************/

declare @erreur int

BEGIN

	SELECT 	    SSD_CF, ESB_CF, SEG_NF, NORME_CF, CTRNAT_CT, ACQRAT_R, MAINTRAT_R, MAINTRATINI_R, UWY_NF
	FROM	    BEST..TEXPRAT
	WHERE	    NORME_CF 	= @p_norm_cf
   	AND      	CLODAT_D 	= @p_clodat_d
   	AND       	PER_CF   	= @p_per_cf
    AND       	SSD_CF    	<> NULL 
END

return 0
go
EXEC sp_procxmode 'dbo.PsTEXPRAT_02', 'unchained'
go
IF OBJECT_ID('dbo.PsTEXPRAT_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTEXPRAT_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTEXPRAT_02 >>>'
go
GRANT EXECUTE ON dbo.PsTEXPRAT_02 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTEXPRAT_02 TO GDBBATCH
go