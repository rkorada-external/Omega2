USE BSEG
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
    @p_per_cf		    char(10)
)
as

/***************************************************

Procedure: PsTEXPRAT_01

Domaine : Expenses and Maintenance calculations

Base principale : BSEG

Version: 1

Auteur: L.ELFAHIM

Date de creation: 12/2018
____________
MODIFICATION 1
Auteur: L.ELFAIM
Date:  08/07/2019
Description: Suite a l echange avec Patrick on a ajoute la jointure avec la table TSEGMT

____________
MODIFICATION 2
Auteur: L.ELFAIM
Date:  09/07/2019
Description: Deplacement de la proc de BEST TP a BSEG dans infocentre

____________
MODIFICATION 3
Auteur: L.ELFAIM
Date:  23/07/2019
Description: SPIRA 79992 MAJ de la requete pour ramener les ratios correctes
*****************************************************/

declare @erreur int



BEGIN

	SELECT		SSD_CF, ESB_CF, SGMT_NF, SGMT_LL, SGMT_LS, NORME_CF, CTRNAT_CT, ACQRAT_R, MAINTRAT_R 
	FROM	  	BEST..TEXPRAT a, BEST..TSEGMT b
	WHERE	   	NORME_CF 	= @p_norm_cf
	AND   		CLODAT_D 	= @p_clodat_d
	AND  		PER_CF		= @p_per_cf
	AND  		b.SGT_NT   	= 108
	AND  		a.SEG_NF   	= b.SGMT_NF  
	AND			b.SGTVER_NT IN 
	(			SELECT 	SGTVER_NT
				FROM BSEG..TSEGRUN
				WHERE SGTRUN_NT=(SELECT max(SGTRUN_NT) FROM BSEG..TSEGRUN WHERE SGT_NT=108 AND SGTRUNSTS_CT='5' AND SGTEVAL_B=1 AND SGTSIMU_B=0) -- 108 = segmentation submarket
	)

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
GRANT EXECUTE ON dbo.PsTEXPRAT_01 TO GDBBATCH
go
GRANT EXECUTE ON dbo.PsTEXPRAT_01 TO GOMEGA
go

