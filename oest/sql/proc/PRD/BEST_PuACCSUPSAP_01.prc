USE BEST
go
IF OBJECT_ID('PuACCSUPSAP_01') IS NOT NULL
BEGIN
  DROP PROC PuACCSUPSAP_01
  PRINT '<<< DROPPED PROC PuACCSUPSAP_01 >>>'
END
go
create procedure PuACCSUPSAP_01

with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: S.Behague
Date de creation: 03/04/2025
Description du programme: 	
   - Extraction TACCSUP sur le trimestre courant
Conditions d'execution: 

_________________
Auteur          | Date        | Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
-- 03-04-2025 MOD[001] - S.Behague - 111789 - Control/Limit SAS data volume in Omega
*****************************************************/
declare @erreur       int,
        @tran_imbr    bit

select @tran_imbr = 1 
select @erreur=0


update BEST..TACCSUPSAP
set sended_b = 1,
    lstupd_d = getdate(),
    LSTUPDUSR_CF = suser_name(),
    POSTING_D = pos.POSTING_D
from BEST..TACCSUPSAP sap, BTRAV..TACCSUPSAPPOS pos
where
sap.TRN_NT = pos.TRN_NT

go

EXEC sp_procxmode 'dbo.PuACCSUPSAP_01', 'unchained'
go
IF OBJECT_ID('dbo.PuACCSUPSAP_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuACCSUPSAP_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuACCSUPSAP_01 >>>'
go
GRANT EXECUTE ON dbo.PuACCSUPSAP_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuACCSUPSAP_01 TO GDBBATCH
go
