USE BEST
go
IF OBJECT_ID('dbo.PsLIFNewBiz_03') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsLIFNewBiz_03
    IF OBJECT_ID('dbo.PsLIFNewBiz_03') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsLIFNewBiz_03 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsLIFNewBiz_03 >>>'
END
go
/*
*  Procedure creation
*/

CREATE PROC dbo.PsLIFNewBiz_03  as
/***************************************************
Domain           : Estimate
Base              : BEST
Version           : 1
Author            : MECHRI Mariem
Creation date    : 02/02/2016
Description    	 : This procedure extract the data of NewBiz from table.

_________________
HISTORIQUE

*****************************************************/


  SELECT t.CTR_NF,
		 t.END_NT,
		 t.SEC_NF,
		 t.ACY_NF,
		 t.ACMTRS_NT,
		 t.CRE_D,
		 t.NEWBIZ_R,
		 t.CREUSR_CF
	FROM BEST..TLIFNEWBIZ t
   WHERE t.CRE_D =
				(SELECT MAX (CRE_D)
				   FROM BEST..TLIFNEWBIZ D
				  WHERE   D.CTR_NF = t.CTR_NF
						AND D.END_NT = t.END_NT
						AND D.SEC_NF = t.SEC_NF
						AND D.ACY_NF = t.ACY_NF
						AND D.ACMTRS_NT = t.ACMTRS_NT)
go
EXEC sp_procxmode 'dbo.PsLIFNewBiz_03', 'unchained'
go
IF OBJECT_ID('dbo.PsLIFNewBiz_03') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsLIFNewBiz_03 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsLIFNewBiz_03 >>>'
go
GRANT EXECUTE ON dbo.PsLIFNewBiz_03 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsLIFNewBiz_03 TO GDBBATCH
go

