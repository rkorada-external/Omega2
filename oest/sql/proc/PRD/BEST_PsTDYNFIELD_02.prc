USE BEST
go
if object_id('PsTDYNFIELD_02') is not null
begin
  drop procedure PsTDYNFIELD_02
  if object_id('PsTDYNFIELD_02') is not null
      print '<<< FAILED DROPPING procedure PsTDYNFIELD_02 >>>'
  else
      print '<<< DROPPED procedure PsTDYNFIELD_02 >>>'
end
go
create procedure PsTDYNFIELD_02
with execute as caller as
/*****
Programme: PsTDYNFIELD_02


Domaine : (Estimation)
Base principale : BRET
Version: 1
Auteur: S.Behague
Date de creation:19/07/2024
Description du programme:

      Proc appelee par le ESFD4030

Parametres:
Conditions d'execution:
Commentaires:
Auteur          | Date        | Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
S.Behague   		| 19/07/2024  | Creation
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
-- 19-07-2024 MOD[001] - S.Behague - 111948 - L&H- change IBNP cancellation granularity for retro

******************************************************************************************************/

-- Extraction temporaire du champ SECQUA10_Cf de TRETSEC pour gérer la Retro
-- Le code de la proc sera amené à être modifié pour fonctionner avec les champs dynamiques comme pour la partie assumed

select t.* 
from  BRET..TRETSEC t
where SECQUA10_CF = 13

PRINT '-- FIN de la procedure bret..PsTDYNFIELD_02'
 
go
EXEC sp_procxmode 'PsTDYNFIELD_02', 'unchained'
go
IF OBJECT_ID('PsTDYNFIELD_02') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsTDYNFIELD_02 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsTDYNFIELD_02 >>>'
go
GRANT EXECUTE ON PsTDYNFIELD_02 TO GOMEGA
go
GRANT EXECUTE ON PsTDYNFIELD_02 TO GDBBATCH
go
