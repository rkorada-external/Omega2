use BEST
go

IF OBJECT_ID('dbo.PsPERITRTSAIS_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsPERITRTSAIS_01
    IF OBJECT_ID('dbo.PsPERITRTSAIS_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPERITRTSAIS_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsPERITRTSAIS_01 >>>'
END
go

/*
 * creation de la procedure */
create procedure PsPERITRTSAIS_01

as
/***************************************************
Programme:          PsPERITRTSAIS_01
Domaine :           Estimations
Base principale :   BEST
Version:            1
Auteur:             PLG
Description du programme:
                    Recherche des taux de saisonnalité par trimestre pour les traités non proportionnels



[001] -=Dch=- 07/08/2013 :spot:25424 -- CENTRALISATION  -- Ajout de la jointure sur la table TBATCHSSD
[002] 05/02/2018 MZM : spira 42213 Arret des estimations pour Traites invalides CTRLCK_B = 1 et Fac Dont Avenant invalides CTRLCK_B =0 

*****************************************************/
declare @erreur int
select @erreur = 0

declare @curr_usr UUPDUSR_CF 
select @curr_usr = user_name()

--[001]
select BATCHUSER_CF, SSD_CF into #ssds from BREF..TBATCHSSD where BATCHUSER_CF = @curr_usr



---------------------------------------------------------------------------------------------------------------------------------
-- Recherche des taux à appliquer pour la saisonnalité des traités non proportionnels avant prise en compte de la durée du traité
---------------------------------------------------------------------------------------------------------------------------------
SELECT CONTR.SSD_CF,
       CONTR.CTR_NF,
       CONTR.END_NT,
       SECTION.SEC_NF,
       CONTR.UWY_NF,
       CONTR.UW_NT,
       CONVERT(char(8), CONTR.CTREXP_D, 112) CTREXP_D,
       CONVERT(float, TECL.COLVAL_LS) TAUX,
       CONVERT(int, SUBSTRING(TECL.COLVAL_CT, CHARINDEX('Q', TECL.COLVAL_CT) + 1, 1)) TRIMESTRE
INTO #SAISONNALITE
FROM BTRT..TSECTION  SECTION,
	  BTRT..TCONTR    CONTR,
     BREF..TBANTECL  TECL,
	  #ssds S   --[001]
WHERE CONTR.CTRSTS_CT IN (14, 16, 17, 19)
  AND CTRLCK_B <> 1 --[002]
  AND CONTR.CTR_NF = SECTION.CTR_NF
  AND CONTR.UWY_NF = SECTION.UWY_NF
  AND CONTR.UW_NT  = SECTION.UW_NT
  AND CONTR.END_NT = SECTION.END_NT
  AND SECTION.SECSTS_CT  IN (14, 16, 17, 19)                                -- Accepté, définitif, renouvelé, résilié
  AND SECTION.LOB_CF NOT IN ('30', '31')                                    -- Exclusion des traités Vie
  AND SECTION.SECQUA4_CF IN (20, 21, 22)                                    -- Qualifiant4 définissant la saisonnalité (US, Asie, Europe)
  AND CONVERT(int, SECTION.NAT_CF) > 29                                     -- Traités non proportionnels
  AND TECL.COLVAL_CT LIKE CONVERT(varchar(5), SECTION.SECQUA4_CF)+'Q[1-4]'  -- Lien avec la saisonnalité répertoriée dans TBANTECL sous la forme 'SECQUA4~Qi' ie qualifiant4~n° trimestre
  AND TECL.COL_LS = 'SAIS_CT'
  AND TECL.LAG_CF = 'E'
  AND CONTR.SSD_CF = S.SSD_CF	 --[001]

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Constitution des taux (linéaires) à appliquer pour les traités pas concernés par la saisonnalité (avant prise en compte de la durée du traité)
-------------------------------------------------------------------------------------------------------------------------------------------------
SELECT CONTR.SSD_CF,
       CONTR.CTR_NF,
       CONTR.END_NT,
       SECTION.SEC_NF,
       CONTR.UWY_NF,
       CONTR.UW_NT,
       CONVERT(char(8), CONTR.CTREXP_D, 112) CTREXP_D,
       25.0 TAUX
INTO #HORS_SAISONNALITE_TMP
FROM BTRT..TSECTION  SECTION,
     BTRT..TCONTR    CONTR,
	  #ssds S   --[001]
WHERE CONTR.CTRSTS_CT IN (14, 16, 17, 19)
  AND CTRLCK_B <> 1 --[002]
  AND CONTR.SSD_CF = S.SSD_CF	   --[001]
  AND CONTR.CTR_NF = SECTION.CTR_NF
  AND CONTR.UWY_NF = SECTION.UWY_NF
  AND CONTR.UW_NT  = SECTION.UW_NT
  AND CONTR.END_NT = SECTION.END_NT
  AND SECTION.SECSTS_CT IN (14, 16, 17, 19)                                 -- Accepté, définitif, renouvelé, résilié
  AND CONVERT(int, SECTION.NAT_CF) > 29                                     -- Traités non proportionnels
  AND (SECTION.SECQUA4_CF NOT IN (20, 21, 22) OR SECTION.SECQUA4_CF IS NULL)-- Qualifiant4 excluant la saisonnalité (US, Asie, Europe)


-- Ajout de la notion de trimestre
SELECT SSD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CTREXP_D,
       TAUX,
       1 TRIMESTRE
INTO #HORS_SAISONNALITE
FROM #HORS_SAISONNALITE_TMP
UNION
SELECT SSD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CTREXP_D,
       TAUX,
       2 TRIMESTRE
FROM #HORS_SAISONNALITE_TMP
UNION
SELECT SSD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CTREXP_D,
       TAUX,
       3 TRIMESTRE
FROM #HORS_SAISONNALITE_TMP
UNION
SELECT SSD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CTREXP_D,
       TAUX,
       4 TRIMESTRE
FROM #HORS_SAISONNALITE_TMP


--------------------------------------------------------------------------------------------------------------------------------
-- Constitution de la table temporaire complète (saisonnalité + hors saisonnalité) avant de prendre en compte la durée du traité
--------------------------------------------------------------------------------------------------------------------------------
SELECT SSD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CTREXP_D,
       TAUX,
       TRIMESTRE
INTO #LISTE_COMPLETE
FROM #SAISONNALITE
UNION
SELECT SSD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CTREXP_D,
       TAUX,
       TRIMESTRE
FROM #HORS_SAISONNALITE


--------------------------------------------------------------------------------------------------------------
-- Constitution de la table temporaire finale qui récapitule les quatre taux pour un traité sur une même ligne
--------------------------------------------------------------------------------------------------------------
SELECT SSD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CTREXP_D,
       0.00000 TAUX_1,    --TAUX / 100 TAUX_1,
       0.00000 TAUX_2,
       0.00000 TAUX_3,
       0.00000 TAUX_4
INTO #TAUX_TRAITES
FROM #LISTE_COMPLETE
WHERE TRIMESTRE = 1

UPDATE #TAUX_TRAITES
   SET a.TAUX_1 = b.TAUX / 100
FROM #TAUX_TRAITES a, #LISTE_COMPLETE b
WHERE a.SSD_CF = b.SSD_CF
  AND a.CTR_NF = b.CTR_NF
  AND a.UWY_NF = b.UWY_NF
  AND a.UW_NT  = b.UW_NT
  AND a.END_NT = b.END_NT
  AND a.SEC_NF = b.SEC_NF
  AND b.TRIMESTRE = 1

UPDATE #TAUX_TRAITES
   SET a.TAUX_2 = b.TAUX / 100
FROM #TAUX_TRAITES a, #LISTE_COMPLETE b
WHERE a.SSD_CF = b.SSD_CF
  AND a.CTR_NF = b.CTR_NF
  AND a.UWY_NF = b.UWY_NF
  AND a.UW_NT  = b.UW_NT
  AND a.END_NT = b.END_NT
  AND a.SEC_NF = b.SEC_NF
  AND b.TRIMESTRE = 2

UPDATE #TAUX_TRAITES
   SET a.TAUX_3 = b.TAUX / 100
FROM #TAUX_TRAITES a, #LISTE_COMPLETE b
WHERE a.SSD_CF = b.SSD_CF
  AND a.CTR_NF = b.CTR_NF
  AND a.UWY_NF = b.UWY_NF
  AND a.UW_NT  = b.UW_NT
  AND a.END_NT = b.END_NT
  AND a.SEC_NF = b.SEC_NF
  AND b.TRIMESTRE = 3

UPDATE #TAUX_TRAITES
   SET a.TAUX_4 = b.TAUX / 100
FROM #TAUX_TRAITES a, #LISTE_COMPLETE b
WHERE a.SSD_CF = b.SSD_CF
  AND a.CTR_NF = b.CTR_NF
  AND a.UWY_NF = b.UWY_NF
  AND a.UW_NT  = b.UW_NT
  AND a.END_NT = b.END_NT
  AND a.SEC_NF = b.SEC_NF
  AND b.TRIMESTRE = 4


-------------------
-- Sélection finale
-------------------
SELECT SSD_CF,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       CTREXP_D,
       TAUX_1,
       TAUX_2,
       TAUX_3,
       TAUX_4
FROM #TAUX_TRAITES
ORDER BY CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT


---------------------------------------------------------------------------------------------------------------------------------
-- Remarque: CTR_NF, END_NT, SEC_NF, UWY_NF et UW_NT sont les champs qui seront synchronisés avec le fichier maître dans ESTM1007
---------------------------------------------------------------------------------------------------------------------------------
select @erreur = @@error
if @erreur != 0
begin
    return @erreur
end

return 0
go
IF OBJECT_ID('dbo.PsPERITRTSAIS_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsPERITRTSAIS_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPERITRTSAIS_01 >>>'
go

EXEC sp_procxmode 'dbo.PsPERITRTSAIS_01','unchained'
go
GRANT EXECUTE ON dbo.PsPERITRTSAIS_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPERITRTSAIS_01 TO GDBBATCH
go

