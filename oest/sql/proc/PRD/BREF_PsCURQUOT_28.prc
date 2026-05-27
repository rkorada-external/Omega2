USE BREF
go

IF OBJECT_ID('dbo.PsCURQUOT_28') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsCURQUOT_28
    IF OBJECT_ID('dbo.PsCURQUOT_28') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsCURQUOT_28 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsCURQUOT_28 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsCURQUOT_28 (
                                              @DateParam Datetime
                                              )
                                              

as

/***************************************************

Programme: PsCURQUOT_28

Fichier script associé : BEST_PsCURQUOT_28

Domaine : (ES) Estimation
Base principale : BREF
Version: 1
Auteur: M. DJELLOULI
Date de creation: 06-10-2005

Description du programme: 
      Récupération de la Date de TCURQUOT

Parametres: 
Conditions d'execution: 
Commentaires:

*****************************************************/

declare @erreur int

declare	@RetourProc     int

declare @D_DateSDD           Datetime
declare @T_DateTcurquot      Char(8)

select @erreur = 0
select @RetourProc = 0

/* Verification si Mise à Jour de Ligne dans TREQJOB */ 
select distinct @D_DateSDD = max(exc_d)
from   BREF..TCURQUOT
WHERE  ssd_cf in (2, 3) and Convert(char(8), EXC_D, 112) <= @DateParam


select @erreur = @@error
 if @erreur != 0
   begin
       Select @T_DateTcurquot = '0'
      goto fin 
   end

Select @T_DateTcurquot = convert(char(8), @D_DateSDD, 112)

fin:
select @T_DateTcurquot

return 0
go
GRANT EXECUTE ON dbo.PsCURQUOT_28 TO GOMEGA
go
IF OBJECT_ID('dbo.PsCURQUOT_28') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsCURQUOT_28 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsCURQUOT_28 >>>'
go
EXEC sp_procxmode 'dbo.PsCURQUOT_28','unchained'
go
