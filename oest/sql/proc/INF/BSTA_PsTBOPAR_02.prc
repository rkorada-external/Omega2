USE BSTA
go


/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */

/* DROP PROC dbo.PsTBOPAR_02
*/
IF OBJECT_ID('dbo.PsTBOPAR_02') IS NOT NULL
   BEGIN
   DROP PROC dbo.PsTBOPAR_02
   PRINT '<<< DROPPED PROC dbo.PsTBOPAR_02 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PsTBOPAR_02
	@DOM_CF		char(3)
as

/***************************************************

Programme: PsTBOPAR_02
Fichier script associ‚ : BEST_PsTBOPAR_02.PRC
Base principale : BSTA  / INFOMEGA
Version: 1
Auteur: M. DJELLOULI
Date de creation: 27/04/2004
Description du programme: 
      Selection des Tables par Période d'Inventaire Pour PB
      
Parametres: 
Conditions d'execution: 
Commentaires:

______________________
MODIFICATION 1
Auteur: M. DJELLOULI
Date de Modification: 21/09/2004
Description du programme: 
      Modification de la Sélection de la Date de Modification Utilisateur
[001] 22/03/2013 R. cassis  :spot:25006 Fiabilisation dans l'affichage des tables ttecleda à l'ecran
[002] 03/04/2013 P. Pezout  :spot:25006 Fiabilisation dans l'affichage des tables ttecleda à l'ecran mettre group by
*****************************************************/
/*
Select Distinct Right(TABCIBLE_CF, 1) as CodeTable, FIELD1_CF, FIELD2_CF, Max(LSTUPD_D) as LSTUPD_D, LSTUPDUSR_CF
FROM BSAR..TBOPAR
where Right(TABCIBLE_CF, 1) in ('A', 'B', 'C', 'D', 'E', 'F', 'G') 
  And DMN_CF=@DOM_CF and PAR_D = Null
  and LSTUPDUSR_CF is not null
Group by Right(TABCIBLE_CF, 1), FIELD1_CF, FIELD2_CF, LSTUPDUSR_CF
order by FIELD1_CF DESC
*/

Select Right(TABCIBLE_CF, 1) as CodeTable, FIELD1_CF, FIELD2_CF, Max(LSTUPD_D) as LSTUPD_D, max(LSTUPDUSR_CF) as LSTUPDUSR_CF
FROM BSAR..TBOPAR
where Right(TABCIBLE_CF, 1) in ('A', 'B', 'C', 'D', 'E', 'F', 'G') 
  And DMN_CF=@DOM_CF and PAR_D = Null
Group by Right(TABCIBLE_CF, 1), FIELD1_CF, FIELD2_CF
order by FIELD1_CF DESC

-- Return 0
	
go

IF OBJECT_ID('dbo.PsTBOPAR_02') IS NOT NULL
   BEGIN
   PRINT '<<< CREATED PROC dbo.PsTBOPAR_02 >>>'
END
go

GRANT EXECUTE ON dbo.PsTBOPAR_02 TO GOMEGA
go
