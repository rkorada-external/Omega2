USE BSAR
go
IF OBJECT_ID('dbo.PsTBOPRSLNK_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTBOPRSLNK_01
    IF OBJECT_ID('dbo.PsTBOPRSLNK_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTBOPRSLNK_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTBOPRSLNK_01 >>>'
END
go
Create Procedure dbo.PsTBOPRSLNK_01
As
/***************************************************
Programme           : PsTBOPRSLNK_01
Version             : 8.2
Auteur              : G. BUISSON
Date de creation    : 28/10/2008
Description         : Spot 16211 : Nouvelle Procédure qui remplace BSTA_PSTTRSLNK car on ne part plus de
                                   la même table ni de la même base.
_________________
MODIFICATION        : 1
Auteur              :
Date                :
Version             :
Description         :
[001]  11/05/2016 S.Behague  :spot:30583 Spira 41148
**************************************************************************************************/

Declare @erreur     Int

Select @erreur = 0

select TRSPFX_CF,
    ACMTRSL0_NT,
    ACMTRSL1_NT,
    ACMTRSL2_NT,
    ACMTRSL3_NT,
    ACMTRSLL1_NT,
    ACMTRSLL2_NT,
    TRSTYP_NT,
    DETTRS_CF,
    PCPTRS_CF,
    TRS_CF,
    SUBTRS_CF,
    ESTIM_NT,
    TRNTYP_CT
From   BSAR..TBOPRSLNK

Select @erreur = @@error
If @erreur != 0
     Begin
          Raiserror 20040 "20040 ; ERROR UPDATE FOR #TTRSLNK; "
          Return 1
     End

return 0
go
EXEC sp_procxmode 'dbo.PsTBOPRSLNK_01', 'unchained'
go
IF OBJECT_ID('dbo.PsTBOPRSLNK_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTBOPRSLNK_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTBOPRSLNK_01 >>>'
go
GRANT EXECUTE ON dbo.PsTBOPRSLNK_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTBOPRSLNK_01 TO GDBBATCH
go
