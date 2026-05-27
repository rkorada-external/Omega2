USE BSAR
go
IF OBJECT_ID('dbo.PsTUWRETSEC_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTUWRETSEC_01
    IF OBJECT_ID('dbo.PsTUWRETSEC_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTUWRETSEC_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTUWRETSEC_01 >>>'
END
go
/* creation de la procedure */
create procedure dbo.PsTUWRETSEC_01
AS



/***************************************************

Procedure: PsTUWRETSEC_01

Domaine : Utilisation dans REQ12.1 RA calculation

Base principale : BSAR

Version: 1

Auteur: JYP - PERSEE

Date de creation: 08/11/2019
____________
MODIFICATION 1 :

*****************************************************/

declare @erreur int


BEGIN

    -- format RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, CTRNAT_CT, SUBMRK_LS, MRKUNT_NT, SUBMRK_NT ,GRPGRP3_NT
    SELECT DISTINCT RETCTR_NF, '', RETSEC_NF, RTY_NF , '', '', SUBMRK_LS, MRKUNT_NT, SUBMRK_NT ,GRPGRP3_NT
    FROM BSBO..TUWRETSEC t
    ORDER BY RETCTR_NF, RTY_NF, RETSEC_NF asc
	
	
END

return 0
go
EXEC sp_procxmode 'dbo.PsTUWRETSEC_01', 'unchained'
go
IF OBJECT_ID('dbo.PsTUWRETSEC_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTUWRETSEC_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTUWRETSEC_01 >>>'
go
GRANT EXECUTE ON dbo.PsTUWRETSEC_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTUWRETSEC_01 TO GDBBATCH
go
