USE BEST
go
if object_id('PsTCUR_01') is not null
begin
  drop procedure PsTCUR_01
  if object_id('PsTCUR_01') is not null
      print '<<< FAILED DROPPING procedure PsTCUR_01 >>>'
  else
      print '<<< DROPPED procedure PsTCUR_01 >>>'
end
go
create procedure PsTCUR_01
with execute as caller as
/*****
Programme: PsTCUR_01


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
S.Behague   		| 19/01/2026  | Creation
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
-- 16-01-2026 MOD[001] - S.Behague - US7172 - L&H- FWH accruals complement- Accounting extraction issue

******************************************************************************************************/

-- Extraction Table BREF..TCUR

SELECT CUR_CF, PCPCTYCUR_CF, CUREXP_D, CURINC_D, RPDCUR_CF, DECNBR_NB
FROM BREF..TCUR


PRINT '-- FIN de la procedure best..PsTCUR_01'
 
go
EXEC sp_procxmode 'PsTCUR_01', 'unchained'
go

IF OBJECT_ID('PsTCUR_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsTCUR_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsTCUR_01 >>>'
go
GRANT EXECUTE ON PsTCUR_01 TO GOMEGA
go
GRANT EXECUTE ON PsTCUR_01 TO GDBBATCH
go
