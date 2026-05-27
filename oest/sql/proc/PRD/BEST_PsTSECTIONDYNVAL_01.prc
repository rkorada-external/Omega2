USE BEST
go
if object_id('PsTSECTIONDYNVAL_01') is not null
begin
  drop procedure PsTSECTIONDYNVAL_01
  if object_id('PsTSECTIONDYNVAL_01') is not null
      print '<<< FAILED DROPPING procedure PsTSECTIONDYNVAL_01 >>>'
  else
      print '<<< DROPPED procedure PsTSECTIONDYNVAL_01 >>>'
end
go
create procedure PsTSECTIONDYNVAL_01
with execute as caller as
/*****
Programme: PsTSECTIONDYNVAL_01


Domaine : (Estimation)
Base principale : BTRT
Version: 1
Auteur: S.Behague
Date de creation:14/01/2025
Description du programme:

      Proc appelee par le ESFD0560

Parametres:
Conditions d'execution:
Commentaires:
Auteur          | Date        | Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
S.Behague   		| 14/01/2025  | Creation
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
-- 14-01-2025 MOD[001] - S.Behague - 111434 - [OMEGA Life] FWH - Accrual adjustment

******************************************************************************************************/

-- ASSUMED
-- Liste contrats LRC
SELECT CTR_NF,SEC_NF, UWY_NF, DYNFIELD_CT, FIELDVAL_B
INTO #TMPLRC
FROM BTRT..TSECTIONDYNVAL 
WHERE DYNFIELD_CT = 36 AND FIELDVAL_B = 1


select distinct CTR_NF,SEC_NF, UWY_NF, 'LIC' AS MODELINGTYP_CF
INTO #TMPDYNVAL
FROM BTRT..TSECTIONDYNVAL 


UPDATE #TMPDYNVAL 
SET MODELINGTYP_CF = 'LRC'
FROM #TMPDYNVAL dyn, #TMPLRC lrc
WHERE 
dyn.CTR_NF = lrc.CTR_NF
AND dyn.SEC_NF = lrc.SEC_NF
AND dyn.UWY_NF = lrc.UWY_NF


select CTR_NF,SEC_NF, UWY_NF, MODELINGTYP_CF, 'A' AS ACCRET
INTO #TMPDYNVALFINAL
FROM #TMPDYNVAL
UNION
-- RETRO 
SELECT RETCTR_NF, RETSEC_NF, RTY_NF,
            CASE
            WHEN SECQUA10_CF = 13 THEN 'LRC'
            ELSE 'LIC'
            END , 'R'
            
FROM BRET..TRETSEC

select * from #TMPDYNVALFINAL

PRINT '-- FIN de la procedure bret..PsTSECTIONDYNVAL_01'
 
go
EXEC sp_procxmode 'PsTSECTIONDYNVAL_01', 'unchained'
go
IF OBJECT_ID('PsTSECTIONDYNVAL_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsTSECTIONDYNVAL_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsTSECTIONDYNVAL_01 >>>'
go
GRANT EXECUTE ON PsTSECTIONDYNVAL_01 TO GOMEGA
go
GRANT EXECUTE ON PsTSECTIONDYNVAL_01 TO GDBBATCH
go
