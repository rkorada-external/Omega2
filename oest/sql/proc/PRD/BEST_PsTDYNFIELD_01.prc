USE BEST
go
if object_id('PsTDYNFIELD_01') is not null
begin
  drop procedure PsTDYNFIELD_01
  if object_id('PsTDYNFIELD_01') is not null
      print '<<< FAILED DROPPING procedure PsTDYNFIELD_01 >>>'
  else
      print '<<< DROPPED procedure PsTDYNFIELD_01 >>>'
end
go
create procedure PsTDYNFIELD_01
with execute as caller as
/*****
Programme: PsTDYNFIELD_01


Domaine : (Estimation)
Base principale : BTRT
Version: 1
Auteur: S.Behague
Date de creation:13/06/2024
Description du programme:

      Proc appelee par le ESFD4030

Parametres:
Conditions d'execution:
Commentaires:
Auteur          | Date        | Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
S.Behague   		| 13/06/2024  | Creation
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
-- 13-06-2024 MOD[001] - S.Behague - 111175 - L&H- change IBNP cancellation granularity

******************************************************************************************************/

select t.* 
from btrt..TSECTIONDYNVAL t, bref..TDYNFIELD t2
where (t.DYNFIELD_CT=t2.DYNFIELD_CT and t2.DYNFIELD_CF='IF17')
and t.FIELDVAL_B=1

PRINT '-- FIN de la procedure bret..PsTDYNFIELD_01'
 
go
EXEC sp_procxmode 'PsTDYNFIELD_01', 'unchained'
go
IF OBJECT_ID('PsTDYNFIELD_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE PsTDYNFIELD_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE PsTDYNFIELD_01 >>>'
go
GRANT EXECUTE ON PsTDYNFIELD_01 TO GOMEGA
go
GRANT EXECUTE ON PsTDYNFIELD_01 TO GDBBATCH
go
