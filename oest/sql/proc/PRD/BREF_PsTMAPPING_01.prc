USE BREF
go
IF OBJECT_ID('dbo.PsTMAPPING_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTMAPPING_01
    IF OBJECT_ID('dbo.PsTMAPPING_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.TPRSMAP_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.TPRSMAP_01 >>>'
END
go
Create Procedure dbo.PsTMAPPING_01
As
/***************************************************
Programme           : PsTMAPPING_01
Version             : 1
Auteur              : C.SOCIE
Date de creation    : 28/10/2008
Description         : IFRS17 EXT-IFRS17-903240 - REQ 10.03 - Cash flow: Flexibility on patterns to be apply on grouping 3
_________________
MODIFICATION        : 1
Auteur              :
Date                :
Version             :
Description         :
**************************************************************************************************/

Declare @erreur     Int

Select @erreur = 0

select PRS_CF, 
	ACMTRS_NT,
	PARM1,
	PARM2,
	PARM3,
	PARM4,
	PARM5,
	PARM6,
	PARM7,
	PARM8,
	PARM9,
	PARM10
From   BREF..TPRSMAP

Select @erreur = @@error
If @erreur != 0
     Begin
          Raiserror 20040 "20040 ; ERROR UPDATE FOR #TTRSLNK; "
          Return 1
     End

return 0
go
EXEC sp_procxmode 'dbo.PsTMAPPING_01', 'unchained'
go
IF OBJECT_ID('dbo.PsTMAPPING_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTMAPPING_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTMAPPING_01 >>>'
go
GRANT EXECUTE ON dbo.PsTMAPPING_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTMAPPING_01 TO GDBBATCH
go
