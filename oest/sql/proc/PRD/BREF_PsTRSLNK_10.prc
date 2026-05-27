USE BREF
go

if object_id('PsTRSLNK_10') is not null
begin
  drop PROC PsTRSLNK_10
  print '<<< DROPPED PROC PsTRSLNK_10 >>>'
end
go

/*
 * creation de la procedure 
*/

create procedure dbo.PsTRSLNK_10
as

/***************************************************
Programme:                PsTRSLNK_10
Fichier script associé :  BREF_PsTRSLNK_10.prc
Domaine :                 Estimation
Base principale :         BREF
Version:                  1
Auteur:                   Roger Cassis
Date de creation:         05/07/2021
Description du programme: :SPIRA:95897 IFRS17- Use grouping 740 for openning exception

      Sélection d'enregistrement dans TTRSLNK - postes comptables omis dans le traitement des annulations et des ouvertures IFRS17
      Prs_cf = 740
      ACMTRS_NT = 100 type 'change'
      ACMTRS_NT = 101 type 'INIT'

Parametres: 
Conditions d'execution: 
Commentaires:
_________________
MODIFICATION 1
[00x] JJ/MM/AAAA Prog. name :spira:xxxxx Comment
*****************************************************/

declare @erreur int


select  dettrs_cf
	 	   ,prs_cf
	 	   ,case When acmtrs_nt = 100 then 'change' else 'INIT' end
from  bref..ttrslnk
where	prs_cf = 740
and	  acmtrs_nt in (100,101)
order by dettrs_cf,acmtrs_nt

select @erreur = @@error

if @erreur = 2601
begin
  raiserror 20009 "APPLICATIF;TTRSLNK" /* aucune ligne trouvée */
  return @erreur 
end

if @erreur != 0
begin
  raiserror 20005 "APPLICATIF;TTRSLNK" /* erreur de modification */
  return @erreur
end


return 0
go
EXEC sp_procxmode 'dbo.PsTRSLNK_10', 'unchained'
go
IF OBJECT_ID('dbo.PsTRSLNK_10') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTRSLNK_10 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTRSLNK_10 >>>'
go
GRANT EXECUTE ON dbo.PsTRSLNK_10 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTRSLNK_10 TO GDBBATCH
go
