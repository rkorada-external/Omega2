use BEST
go
IF OBJECT_ID('dbo.PsPERIRETSAIS_01') IS NOT NULL
BEGIN
  DROP PROCEDURE dbo.PsPERIRETSAIS_01
  IF OBJECT_ID('dbo.PsPERIRETSAIS_01') IS NOT NULL
    PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsPERIRETSAIS_01 >>>'
  ELSE
    PRINT '<<< DROPPED PROCEDURE dbo.PsPERIRETSAIS_01 >>>'
END
go
create procedure PsPERIRETSAIS_01
as
/***************************************************
Domaine :           Estimations
Base principale :   BEST
Auteur:             Florent
Description du programme: :spot:29176 Recherche des taux de saisonnalité par trimestre pour la rétro non proportionnels
_____________
MODIFICATIONS
*****************************************************/
declare @erreur int
select @erreur = 0

create table #QUARTER (TRIMESTRE smallint)
insert #QUARTER values(1)
insert #QUARTER values(2)
insert #QUARTER values(3)
insert #QUARTER values(4)

SELECT distinct SSD_CF,RETCTR_NF,RETSEC_NF,RTY_NF,CTRINCUWY_D,CTREXP_D
 ,TAUX_1=sum(case when TRIMESTRE=1 then TAUX end)
 ,TAUX_2=sum(case when TRIMESTRE=2 then TAUX end)
 ,TAUX_3=sum(case when TRIMESTRE=3 then TAUX end)
 ,TAUX_4=sum(case when TRIMESTRE=4 then TAUX end)
 from (
      ---------------------------------------------------------------------------------------------------------------------------------
      -- Recherche des taux à appliquer pour la saisonnalité des traités non proportionnels avant prise en compte de la durée du traité
      ---------------------------------------------------------------------------------------------------------------------------------
      SELECT
        c.SSD_CF,
        c.RETCTR_NF,
        e.RETSEC_NF,
        c.RTY_NF,
        CTRINCUWY_D=CONVERT(char(8),CTRINCUWY_D,112),
        CTREXP_D=CONVERT(char(8),isnull(c.CTREXP_D, dateadd(year,1,CTRINCUWY_D)),112),
        TAUX=round(convert(decimal,t.COLVAL_LS) / 100,8),   -- taux en 0 à 100 %
        TRIMESTRE=CONVERT(int, SUBSTRING(t.COLVAL_CT, CHARINDEX('Q', t.COLVAL_CT) + 1, 1))
       FROM BRET..TRETSEC e, BRET..TRETCTR c, BREF..TBANTECL t, BREF..TBATCHSSD s
        WHERE c.RETCTRSTS_CT IN (3, 19)
          AND c.RETCTR_NF = e.RETCTR_NF
          AND c.RTY_NF = e.RTY_NF
          AND e.LOB_CF NOT IN ('30', '31')                                 -- Exclusion des traités Vie
          AND e.SECQUA4_CF between 200 and 219                             -- Qualifiant4 définissant la saisonnalité (US, Asie, Europe)
          AND c.RETCTRCAT_CF='02'                                        -- Traités non proportionnels
          AND t.COLVAL_CT LIKE CONVERT(varchar(5), e.SECQUA4_CF)+'Q[1-4]'  -- Lien avec la saisonnalité répertoriée dans TBANTECL sous la forme 'SECQUA4~Qi' ie qualifiant4~n° trimestre
          AND t.COL_LS = 'SAISRET_CT'
          AND t.LAG_CF = 'E'
          AND c.SSD_CF = S.SSD_CF
          and s.BATCHUSER_CF = suser_name()
      
      union all
      -------------------------------------------------------------------------------------------------------------------------------------------------
      -- Constitution des taux (linéaires) à appliquer pour les traités pas concernés par la saisonnalité (avant prise en compte de la durée du traité)
      -------------------------------------------------------------------------------------------------------------------------------------------------
      SELECT
       c.SSD_CF,
       c.RETCTR_NF,
       e.RETSEC_NF,
       c.RTY_NF,
       CTRINCUWY_D=CONVERT(char(8),CTRINCUWY_D,112),
       CTREXP_D=CONVERT(char(8),isnull(c.CTREXP_D, dateadd(year,1,CTRINCUWY_D)),112),
       TAUX=0.25,
       x.TRIMESTRE
       FROM BRET..TRETSEC e, BRET..TRETCTR c, BREF..TBATCHSSD s, #QUARTER x
        WHERE c.RETCTRSTS_CT IN (3, 19)
          AND c.RETCTR_NF = e.RETCTR_NF
          AND c.RTY_NF = e.RTY_NF
          AND c.RETCTRCAT_CF='02'                                     -- Traités non proportionnels
          AND e.LOB_CF NOT IN ('30', '31')                           -- Exclusion des traités Vie
          AND (e.SECQUA4_CF not between 200 and 219 OR e.SECQUA4_CF=NULL)-- Qualifiant4 excluant la saisonnalité (US, Asie, Europe)
          AND c.SSD_CF = s.SSD_CF
          and s.BATCHUSER_CF = suser_name()
      ) a
GROUP BY RETCTR_NF, RETSEC_NF, RTY_NF
ORDER BY RETCTR_NF, RETSEC_NF, RTY_NF
if  @@error != 0 return @erreur

---------------------------------------------------------------------------------------------------------------------------------
-- Remarque: RETCTR_NF, RETSEC_NF, RTY_NF sont les champs qui seront synchronisés avec le fichier maître dans ESTM1007
---------------------------------------------------------------------------------------------------------------------------------
return 0
go
IF OBJECT_ID('dbo.PsPERIRETSAIS_01') IS NOT NULL
  PRINT '<<< CREATED PROCEDURE dbo.PsPERIRETSAIS_01 >>>'
ELSE
  PRINT '<<< FAILED CREATING PROCEDURE dbo.PsPERIRETSAIS_01 >>>'
go
GRANT EXECUTE ON dbo.PsPERIRETSAIS_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsPERIRETSAIS_01 TO GDBBATCH
go

