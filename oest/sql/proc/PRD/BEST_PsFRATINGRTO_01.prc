USE BEST
go
IF OBJECT_ID('dbo.PsFRATINGRTO_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsFRATINGRTO_01
    IF OBJECT_ID('dbo.PsFRATINGRTO_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsFRATINGRTO_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsFRATINGRTO_01 >>>'
END
go
create procedure dbo.PsFRATINGRTO_01
as
/***************************************************
Domaine                  : (ES) Estimation
Base principale          : BEST
Auteur                   : R. Cassis
Date de creation         : 01/10/2012
Description du programme : :spot:24041 Génération du fichier FRANTINGRTO (SOLVENCY)
Conditions d'execution   :
Commentaires             :
_________________
MODIFICATIONS
[xxx] jj/mm/aaaa Prog name    :spot:xxxxx - Commentaires
[001] 04/12/2012 Solvency 2   :spot:24041  Liste des clients (retrocessionnaires) et leurs cotations
[002] 12/03/2013 Roger Cassis :spot:24952  Modification proc selon medele PhP

MODIFICATION    [002]
Auteur:         Aditi Pawase
Date:           29/05/2013
Version:        1.02
Description:    Obsolete table changes

[003] 05/12/2014 C. DESPRET   :spot:26391  Modification proc suite demande F. Schwach : nouveau mode de calcul du rating
[004] 29/05/2015 Florent      :spot:26391  Validation finale de F. Schwach
[005] 09/08/2016 -=Dch=-      :spot:31041  Remplacement de TCLREPCR par TCLINTSU

*****************************************************/
--
-- table de sortie des résultats

-- Creation des tables temporaires
CREATE TABLE #RATING ( 
  RTO int, 
  RATING_SCOR CHAR(3) NULL, 
  RATING_S_P  CHAR(3) NULL, /*STANDARD'S & POOR*/
  RATING_AMB  CHAR(3) NULL, /*AMB*/
  SP_RATING   INTEGER NULL,
  AM_RATING   INTEGER NULL,
  SP_RATING2  INTEGER NULL,
  AM_RATING2  INTEGER NULL,
  SF_RATING   INTEGER NULL
)

CREATE TABLE #RATING2 ( 
  RTO int, 
  RATING_SCOR CHAR(3) NULL, 
  RATING_S_P  CHAR(3) NULL, /*STANDARD'S & POOR*/
  RATING_AMB  CHAR(3) NULL, /*AMB*/
  SP_RATING   INTEGER NULL,
  AM_RATING   INTEGER NULL,
  SP_RATING2  INTEGER NULL,
  AM_RATING2  INTEGER NULL,
  SF_RATING   INTEGER NULL
)  

--------------------------------- 
-- Gestion des exceptions : 
--  Tous les clients SCOR sont en rating group SCOR (« A ») 
--  On gère les retrocessionaires qui sont 100% collateralisés en leur assignant un rating « AAA »

-- Clients SCOR
INSERT INTO #RATING 
  (RTO, RATING_SCOR)
SELECT 
  CLI.CLI_NF RTO, --CLISSD_CF FROM BCLI..TCLIENT A 
  "A" RATING
FROM 
  BCLI..TCLIENT CLI
WHERE 
  CLI.CLISSD_CF IS NOT NULL AND 
  CLI.CLI_NF <> 0

-- Retrocessionnaires 100% collateral
INSERT INTO #RATING 
  (RTO, RATING_SCOR)
SELECT 
  CLI.CLI_NF RTO, --CLISSD_CF FROM BCLI..TCLIENT A 
  "AAA" RATING
FROM 
  BCLI..TCLIENT CLI,
  BCLI..TCLSTABI STA
WHERE 
  CLI.CLI_NF <> 0 and
  CLI.CLIRETCESS_B = 1 AND -- Retrocessionnaire
  CLI.CLI_NF = STA.CLI_NF AND 
  STA.ISICURRAT_CT = 10 AND -- 100% collateral 
  CLI.CLI_NF NOT IN (SELECT RTO FROM #RATING)

-- Tous les autres clients pour lesquels on veut un reporting
INSERT INTO #RATING (RTO, RATING_SCOR)
SELECT DISTINCT 
  RTO = CLI.CLI_NF,
  RATING = CASE 
    WHEN REP.SREPCRI_LS IN ("AAA+","AAA-") THEN "AAA" 
    WHEN REP.SREPCRI_LS IN ("AA+","AA-") THEN "AA" 
    WHEN REP.SREPCRI_LS IN ("A+","A-") THEN "A" 
    WHEN REP.SREPCRI_LS IN ("BBB+","BBB-") THEN "BBB" 
    WHEN REP.SREPCRI_LS IN ("BB+","BB-") THEN "BB" 
    WHEN REP.SREPCRI_LS IN ("B+","B-") THEN "B" 
    WHEN REP.SREPCRI_LS IN ("CCC+","CCC-") THEN "CCC" 
    WHEN REP.SREPCRI_LS IN ("CC+","CC-") THEN "CC" 
    WHEN REP.SREPCRI_LS IN ("C+","C-") THEN "C" 
    WHEN REP.SREPCRI_LS IN ("NO RATING") THEN "NR" 
    ELSE REP.SREPCRI_LS 
  END
FROM 
  BCLI..TCLINTSU CLI, 
  BCLI..TSREPCRI REP 
WHERE 
  CLI.SORDNBR_NT = REP.SORDNBR_NT AND
  REP.SSD_CF = 3 AND   -- CONSTANTE DES RATINGS POUR TSREPCRI : LA SSD_CF EST UNIQUEMENT SUR 3 , PAS DE JOINTURE AVEC LA TABLE CLIENT DONC
  REP.SREPCRI_LS IS NOT NULL AND 
  CLI.CLI_NF NOT IN (SELECT RTO FROM #RATING)


--------------------------------- 
-- Recuperation des cotations et libelles pour les autres agences de cotations ( Standard & Poors , AM Best) 
--
SELECT 	
  RETRO = COL_LS, 
  COLVAL_CT = CONVERT(INT, COLVAL_CT), 
  RATING = LTRIM(RTRIM(COLVAL_LS)) 
INTO 
  #COTATION 
FROM 
  BREF..TBANALL 
WHERE 
  COL_LS IN ('SPCURRAT_CT', 'AMBCURRAT_CT')

---------------------------------
-- Clients et leurs cotation Standard & Poors et AMB
--
INSERT INTO #RATING2 
  (RTO, RATING_S_P, RATING_AMB, SP_RATING, AM_RATING)
SELECT DISTINCT 
  RTO = CLI.CLI_NF, 
  RATING_S_P = CASE WHEN CLI.SPCURRAT_CT IS NOT NULL THEN SAP.RATING ELSE NULL END ,
  RATING_AMB = CASE WHEN CLI.AMBCURRAT_CT IS NOT NULL THEN AMB.RATING ELSE NULL END ,
  CLI.SPCURRAT_CT, 
  CLI.AMBCURRAT_CT 
FROM 
  BCLI..TCLSTABI CLI
  LEFT JOIN #COTATION SAP ON 
    SAP.RETRO     = 'SPCURRAT_CT' AND 
    SAP.COLVAL_CT = CLI.SPCURRAT_CT
  LEFT JOIN #COTATION AMB ON 
    AMB.RETRO     = 'AMBCURRAT_CT' AND 
    AMB.COLVAL_CT = CLI.AMBCURRAT_CT
WHERE 
  ISNULL(CLI.SPCURRAT_CT, CLI.AMBCURRAT_CT) IS NOT NULL
 
---------------------------------
-- Classification suivant le mapping AM BEST / S&P fourni par l’équipe actuarial modelling
--
UPDATE #RATING2
  SET
  SP_RATING2 = 	
  CASE  
    WHEN SP_RATING IN  (11,12,13,34,37,39) THEN 1
    WHEN SP_RATING IN  (15)                THEN 2
    WHEN SP_RATING IN  (14,43)             THEN 3
    WHEN SP_RATING IN  (16,79)             THEN 4
    WHEN SP_RATING IN  (18)                THEN 5
    WHEN SP_RATING IN  (17,48)             THEN 6
    WHEN SP_RATING IN  (19,78)             THEN 7
    WHEN SP_RATING IN  (22)                THEN 8
    WHEN SP_RATING IN  (21,53)             THEN 9
    WHEN SP_RATING IN  (23,55)             THEN 10
    WHEN SP_RATING IN  (25)                THEN 11
    WHEN SP_RATING IN  (24,58)             THEN 12
    WHEN SP_RATING IN  (26,58)             THEN 13
    WHEN SP_RATING IN  (28)                THEN 14
    WHEN SP_RATING IN  (27,63)             THEN 15
    WHEN SP_RATING IN  (29)                THEN 16
    WHEN SP_RATING IN  (32)                THEN 17
    WHEN SP_RATING IN  (31,69)             THEN 18
    WHEN SP_RATING IN  (33)                THEN 19
    WHEN SP_RATING IN  (72,74,76)          THEN 20
    ELSE                                        99
  END,
  AM_RATING2 = 	
  CASE  
    WHEN AM_RATING IN  (11,53)  THEN 1
    WHEN AM_RATING IN  (12,63)  THEN 3
    WHEN AM_RATING IN  (13,81) THEN 6
    WHEN AM_RATING IN  (14,82)  THEN 7
    WHEN AM_RATING IN  (21,83)  THEN 9
    WHEN AM_RATING IN  (22,84)  THEN 10
    WHEN AM_RATING IN  (23,85)  THEN 12
    WHEN AM_RATING IN  (24,93)  THEN 13
    WHEN AM_RATING IN  (31,121) THEN 14
    WHEN AM_RATING IN  (32,123) THEN 15
    WHEN AM_RATING IN  (33,125) THEN 16
    WHEN AM_RATING IN  (34,127) THEN 17
    WHEN AM_RATING IN  (43,129) THEN 18
    WHEN AM_RATING IN  (130)    THEN 21
    WHEN AM_RATING IN  (131)    THEN 22
    ELSE                             99
  END
  

-- MAJ du SF_RATING
UPDATE #RATING2
SET SF_RATING = 
  CASE 
    WHEN SP_RATING2 = 99 AND AM_RATING2 = 99 THEN 99
    WHEN SP_RATING2 = 99 AND AM_RATING2 < 99 THEN AM_RATING2
    WHEN SP_RATING2 < 99 AND AM_RATING2 = 99 THEN SP_RATING2
    WHEN SP_RATING2 < AM_RATING2             THEN AM_RATING2 
    ELSE                                          SP_RATING2
  END
  
  
---------------------------------
-- Update #rating 
--

-- MAJ des ratings pour les exceptions deja dans la table #RATING
UPDATE #RATING
SET 
  RATING_S_P = RAT2.RATING_S_P,
  RATING_AMB = RAT2.RATING_AMB,
  SP_RATING  = RAT2.SP_RATING,
  AM_RATING  = RAT2.AM_RATING,
  SP_RATING2 = RAT2.SP_RATING2,
  AM_RATING2 = RAT2.AM_RATING2,
  SF_RATING  = RAT2.SF_RATING
FROM 
  #RATING  RAT1, 
  #RATING2 RAT2
WHERE 
  RAT1.RTO = RAT2.RTO

-- Insersion des ratings qui n'etaient pas encore dans la table : i.e. ceux qui ne sont pas des exceptions 
INSERT INTO #RATING
SELECT 
  RTO, 
  RATING_SCOR, 
  RATING_S_P, 
  RATING_AMB, 
  SP_RATING,
  AM_RATING, 
  SP_RATING2, 
  AM_RATING2, 
  SF_RATING
FROM 
  #RATING2 R
WHERE 
  R.RTO NOT IN (SELECT DISTINCT RTO FROM #RATING)
 
---------------------------------
-- Create Final Table
--

-- Choix du rating a prendre en compte
SELECT 
  RTO,
  RATING = isnull(RATING_SCOR, "NR"),
  RATING_SCOR,
  RATING_S_P,
  RATING_AMB,
  SP_RATING,
  AM_RATING,
  SP_RATING2,
  AM_RATING2,
  SF_RATING 
INTO 
  #FINALE  
FROM 
  #RATING 
   
  
-- Choix final du rating avec un affichage de type 'lettre' : 'AAA', 'AA'...
SELECT 
  RTO, 
  RATING_RTO = 
  CASE 
    WHEN RATING NOT IN ("AAA","AA","A","BBB","BB","B", "CCC", "CC", "C") THEN 
      CASE  
        WHEN SF_RATING IN  (1)        THEN "AAA"
        WHEN SF_RATING IN  (2,3,4)    THEN "AA"
        WHEN SF_RATING IN  (5,6,7)    THEN "A"
        WHEN SF_RATING IN  (8,9,10)   THEN "BBB"
        WHEN SF_RATING IN  (11,12,13) THEN "BB"
        WHEN SF_RATING IN  (14,15,16) THEN "B"
        WHEN SF_RATING IN  (17,18,19) THEN "CCC"
        WHEN SF_RATING IN  (20)       THEN "CC"
        ELSE                               "NR"
      END
    ELSE RATING
  END
FROM 
  #FINALE 
GROUP BY 
  RTO, RATING
ORDER BY RTO  
  

 
/*
Table de mapping d’actuarial modelling
S&P	AMBest	Numeric rating
AAA	A++	1
AA+	 	2
AA	A+	3
AA-	 	4
A+	 	5
A	A	6
A-	A-	7
BBB+	 	8
BBB	B++	9
BBB-	B+	10
BB+	 	11
BB	B	12
BB-	B-	13
B+	C++	14
B	C+	15
B-	C	16
CCC+	C-	17
CCC	D	18
CCC-	 	19
CC	 	20
C	E	21
D	F	22

*/

if @@error != 0
begin
   raiserror 20005 "APPLICATIF;CLREPCR"
   return @@error
end

return 0
go
EXEC sp_procxmode 'dbo.PsFRATINGRTO_01', 'unchained'
go
IF OBJECT_ID('dbo.PsFRATINGRTO_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsFRATINGRTO_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsFRATINGRTO_01 >>>'
go
GRANT EXECUTE ON dbo.PsFRATINGRTO_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsFRATINGRTO_01 TO GDBBATCH
go
