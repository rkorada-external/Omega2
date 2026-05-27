USE BSAR
go
IF OBJECT_ID('dbo.PsGetMARKET_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsGetMARKET_01
    IF OBJECT_ID('dbo.PsGetMARKET_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsGetMARKET_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsGetMARKET_01 >>>'
END
go
/* creation de la procedure */
create procedure dbo.PsGetMARKET_01
AS



/***************************************************

Procedure: PsGetMARKET_01

Domaine : Utilisation dans REQ11.1 et REQ11.2

Base principale : BSAR

Version: 1

Auteur: L.ELFAHIM

Date de creation: 14/03/2019
____________
MODIFICATION 1
Auteur       : L.ELFAHIM
Date         : 24/07/2019
Description : Modification de la requette SPIRA 79992 

MODIFICATION 2 : 13/08/2019 : JYP Spira 70377 : IFRS17 req 12.1 : add extraction of field GRPGRP3_NT

*****************************************************/

declare @erreur int


BEGIN

	SELECT DISTINCT CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CTRNAT_CT, SUBMRK_LS, MRKUNT_NT, SUBMRK_NT ,GRPGRP3_NT
    FROM BSBO..TUWSEC
    ORDER BY CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF asc
	
END

return 0
go
EXEC sp_procxmode 'dbo.PsGetMARKET_01', 'unchained'
go
IF OBJECT_ID('dbo.PsGetMARKET_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsGetMARKET_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsGetMARKET_01 >>>'
go
GRANT EXECUTE ON dbo.PsGetMARKET_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsGetMARKET_01 TO GDBBATCH
go
