USE BEST
go

IF OBJECT_ID('dbo.PsTI17CLOPER_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTI17CLOPER_01
    IF OBJECT_ID('dbo.PsTI17CLOPER_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTI17CLOPER_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTI17CLOPER_01 >>>'
END
go

create procedure dbo.PsTI17CLOPER_01

as

/***************************************************
Domaine:					Estimations
Base principale:			BEST
Version:					1
Auteur:						CAS
Date de creation:			22/11/2019
Description du programme:	Extract param1 and param2 from TI17CLOPER
Conditions d'execution:		
Commentaires: 				SPIRA #89105
*****************************************************/

DECLARE @erreur int
SELECT @erreur = 0

SELECT 
SSD_CF,
ESB_CF,
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
FROM BEST..TI17CLOPER

select @erreur = @@error
if @erreur != 0
begin
    return @erreur
end

return 0
go

IF OBJECT_ID('dbo.PsTI17CLOPER_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTI17CLOPER_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTI17CLOPER_01 >>>'
go

GRANT EXECUTE ON dbo.PsTI17CLOPER_01 TO GOMEGA
go

GRANT EXECUTE ON dbo.PsTI17CLOPER_01 TO GDBBATCH
go
