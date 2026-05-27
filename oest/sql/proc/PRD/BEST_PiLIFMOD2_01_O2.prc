USE BEST
go
IF OBJECT_ID('dbo.PiLIFMOD2_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiLIFMOD2_01_O2
    IF OBJECT_ID('dbo.PiLIFMOD2_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiLIFMOD2_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiLIFMOD2_01_O2 >>>'
END
go
create procedure dbo.PiLIFMOD2_01_O2
  (
   @p_CTR_NF       UCTR_NF
  ,@p_SEC_NF       USEC_NF
  ,@p_CRE_D        datetime
  ,@p_BALSHEY_NF   smallint
  ,@p_BALSHTMTH_NF tinyint
  ,@p_ACY_NF       UACCYER_NF
  ,@p_GAAP_NT 	   tinyint	-- GAAP NT
  ,@p_COMACC_B     bit
  ,@p_PRIPRMAMT_M    UAMT_M
  ,@p_AFTPRMAMT_M    UAMT_M
  ,@p_PRIRESTECAMT_M UAMT_M
  ,@p_AFTRESTECAMT_M UAMT_M
  ,@p_PRIRESDACAMT_M UAMT_M
  ,@p_AFTRESDACAMT_M UAMT_M
  ,@p_PRIRESFINAMT_M UAMT_M
  ,@p_AFTRESFINAMT_M UAMT_M
  ,@p_erreur       varchar(64) = null output
  )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 12/07/2004
Description du programme: estimation Vie, suivi dépassement du seuil
Conditions d'execution: par w_reponse_seuil_lifmod
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
1 Florent   24/01/2012 :spot:20562 interdit la création de ligne si avant le bilan en cours
_________________
MODIFICATIONS
M  Auteur          Date       Description
2 C.Cros   24/05/2013 :OMEGA2 - spira17580:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2

_________________
MODIFICATIONS
M  Auteur          Date       Description
3 A.Deshpande   27/02/2014 :OMEGA2 - Added GAAP NT for EST 50 and SGLA06 evo cards


*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
-- modif 1
 ,@date_jour   datetime
 ,@BLCSHTYEA_NF smallint
 ,@BLCSHTMTH_NF tinyint
 ,@SPECEND_D    datetime
 ,@ACCOUNT_D    datetime
 ,@CLOSING_B    bit

select @erreur = 0, @tran_imbr = 1, @date_jour=getdate()
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end
execute @erreur=BREF..PsCALEND_02 @date_jour,'E',@BLCSHTYEA_NF output,@BLCSHTMTH_NF output,@SPECEND_D output,@ACCOUNT_D output,@CLOSING_B output
if @erreur!=0
begin
  select @p_erreur = "20001 APPLICATIF;BREF..PsCALEND_02 " + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @p_balshey_nf*100 + @p_balshtmth_nf < @BLCSHTYEA_NF*100 + @BLCSHTMTH_NF
begin
  select @p_erreur='30002 ESTIMATION;erreur période bilan/wrong balance sheet period;',@erreur=30002
  goto fin
end

insert TLIFMOD2
  (
   CTR_NF
  ,SEC_NF
  ,CRE_D
  ,BALSHEY_NF
  ,BALSHTMTH_NF
  ,ACY_NF
  ,COMACC_B
  ,GAAP_NT
  ,PRIPRMAMT_M
  ,AFTPRMAMT_M
  ,PRIRESTECAMT_M
  ,AFTRESTECAMT_M
  ,PRIRESDACAMT_M
  ,AFTRESDACAMT_M
  ,PRIRESFINAMT_M
  ,AFTRESFINAMT_M
  ,CREUSR_CF
  ,LSTUPD_D
  ,LSTUPDUSR_CF
  )
select
   @p_CTR_NF
  ,@p_SEC_NF
  ,@p_CRE_D
  ,@p_BALSHEY_NF
  ,@p_BALSHTMTH_NF
  ,@p_ACY_NF
  ,@p_COMACC_B
  ,@p_GAAP_NT
  ,isnull(@p_PRIPRMAMT_M,0) /** OMEGA2 - spira17580:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2 **/
  ,isnull(@p_AFTPRMAMT_M,0)
  ,isnull(@p_PRIRESTECAMT_M,0)
  ,isnull(@p_AFTRESTECAMT_M,0)
  ,isnull(@p_PRIRESDACAMT_M,0)
  ,isnull(@p_AFTRESDACAMT_M,0)
  ,isnull(@p_PRIRESFINAMT_M,0)
  ,isnull(@p_AFTRESFINAMT_M,0)
  ,suser_name()
  ,getdate()
  ,suser_name()
select @erreur=@@error
if @erreur!=0
begin
  if @erreur=2601
    select @p_erreur="20002 APPLICATIF;TLIFMOD2"
  else
    select @p_erreur="20001 APPLICATIF;TLIFMOD2" + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
EXEC sp_procxmode 'dbo.PiLIFMOD2_01_O2', 'unchained'
go
IF OBJECT_ID('dbo.PiLIFMOD2_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiLIFMOD2_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiLIFMOD2_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PiLIFMOD2_01_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiLIFMOD2_01_O2 TO GDBBATCH
go
