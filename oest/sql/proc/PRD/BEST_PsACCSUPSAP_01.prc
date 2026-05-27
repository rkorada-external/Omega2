USE BEST
go
IF OBJECT_ID('PsACCSUPSAP_01') IS NOT NULL
BEGIN
  DROP PROC PsACCSUPSAP_01
  PRINT '<<< DROPPED PROC PsACCSUPSAP_01 >>>'
END
go
create procedure PsACCSUPSAP_01(
  @p_balshtyea_nf varchar(4),
  @p_balshtmth_nf tinyint
)
with execute as caller as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: S.Behague
Date de creation: 02/04/2025
Description du programme: 	
   - Extraction TACCSUP sur le trimestre courant
Conditions d'execution: 

_________________
Auteur          | Date        | Description
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
----------------|-------------|-----------------------------------------------------------------------------------------------------------------------
-- 02-04-2025 MOD[001] - S.Behague - 111789 - Control/Limit SAS data volume in Omega
*****************************************************/
declare @erreur       int,
        @tran_imbr    bit

select @tran_imbr = 1 
select @erreur=0

print 'PsACCSUPSAP_01 ==> @p_balshtyea_nf = %1!  ',  @p_balshtyea_nf
print 'PsACCSUPSAP_01 ==> @p_balshtmth_nf = %1!  ',  @p_balshtmth_nf

select TRN_NT, CTR_NF, SEC_NF, UWY_NF from BEST..TACCSUPSAP
where sended_b = 0

go

EXEC sp_procxmode 'dbo.PsACCSUPSAP_01', 'unchained'
go
IF OBJECT_ID('dbo.PsACCSUPSAP_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsACCSUPSAP_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsACCSUPSAP_01 >>>'
go
GRANT EXECUTE ON dbo.PsACCSUPSAP_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsACCSUPSAP_01 TO GDBBATCH
go
