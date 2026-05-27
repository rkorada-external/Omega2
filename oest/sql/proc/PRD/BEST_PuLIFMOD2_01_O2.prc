USE BEST
go
IF OBJECT_ID('dbo.PuLIFMOD2_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuLIFMOD2_01_O2
    IF OBJECT_ID('dbo.PuLIFMOD2_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuLIFMOD2_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuLIFMOD2_01_O2 >>>'
END
go
create procedure dbo.PuLIFMOD2_01_O2
  (
   @p_CTR_NF         UCTR_NF
  ,@p_SEC_NF         USEC_NF
  ,@p_CRE_D          datetime
  ,@p_BALSHEY_NF     smallint
  ,@p_BALSHTMTH_NF   tinyint
  ,@p_ACY_NF         UACCYER_NF
  ,@p_COMACC_B       bit
  ,@p_GAAP_NT		 tinyint -- GAAP_NT
  ,@p_AFTPRMAMT_M    UAMT_M  -- Next rising premium  
  ,@p_AFTRESTECAMT_M UAMT_M -- Following technical result
  ,@p_AFTRESDACAMT_M UAMT_M -- ResTec with following FAR
  ,@p_AFTRESFINAMT_M UAMT_M -- Following Financial results
  ,@p_erreur         varchar(64)= null output
  )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 12/07/2004
Description du programme: estimation Vie, suivi d�passement du seuil
Conditions d'execution: par w_reponse_seuil_lifmod
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
1 Florent   24/01/2012 :spot:23260 interdit la cr�ation de ligne si avant le bilan en cours
_________________
MODIFICATIONS
M  Auteur          Date       Description
2 C.Cros   24/05/2013 :OMEGA2 - spira17580:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2


_________________

MODIFICATIONS
M  Auteur          Date       Description
3 A.Deshpande   27/02/2014 :OMEGA2 - Added GAAP nt for SGLA06 & EST 50 Evo cards

*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@lignes    int
 ,@retour    int
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
  select @p_erreur='30002 ESTIMATION;erreur p�riode bilan/wrong balance sheet period;',@erreur=30002
  goto fin
end

/** OMEGA2 - spira17580:multiply amount by 1000 is no longer required as amount are displayed in unit in omega2 **/
update TLIFMOD2
 set AFTPRMAMT_M=isnull(@p_AFTPRMAMT_M,0)
    ,AFTRESTECAMT_M=isnull(@p_AFTRESTECAMT_M,0)
    ,AFTRESDACAMT_M=isnull(@p_AFTRESDACAMT_M,0)
    ,AFTRESFINAMT_M=isnull(@p_AFTRESFINAMT_M,0)
    ,COMACC_B=@p_COMACC_B
    ,GAAP_NT=@p_GAAP_NT -- GAAP_NT
    ,LSTUPD_D=getdate()
    ,LSTUPDUSR_CF=suser_name()
  where CTR_NF=@p_CTR_NF
    and SEC_NF=@p_SEC_NF
    and BALSHEY_NF=@p_BALSHEY_NF
    and BALSHTMTH_NF=@p_BALSHTMTH_NF
    and CRE_D=@p_CRE_D
    and ACY_NF=@p_ACY_NF
    and GAAP_NT=@p_GAAP_NT -- GAAP_NT when lines !=0
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20004 APPLICATIF;TLIFMOD2" + convert(varchar(10),@erreur) + ";"
  goto fin
end

-- commen on n'enregistre pas toute les acy s'il n'y a pas de montants alors si des montants AFT... sont cr��s :
if @lignes=0
begin
  exec @retour = PiLIFMOD2_01_O2 @p_CTR_NF=@p_CTR_NF, @p_SEC_NF=@p_SEC_NF, @p_CRE_D=@p_CRE_D, @p_BALSHEY_NF=@p_BALSHEY_NF,
    @p_BALSHTMTH_NF=@p_BALSHTMTH_NF, @p_ACY_NF=@p_ACY_NF, @p_COMACC_B=@p_COMACC_B, @p_GAAP_NT=@p_GAAP_NT ,@p_PRIPRMAMT_M=null, @p_AFTPRMAMT_M=@p_AFTPRMAMT_M,
    @p_PRIRESTECAMT_M=null, @p_AFTRESTECAMT_M=@p_AFTRESTECAMT_M, @p_PRIRESDACAMT_M=null,
    @p_AFTRESDACAMT_M=@p_AFTRESDACAMT_M, @p_PRIRESFINAMT_M=null, @p_AFTRESFINAMT_M=@p_AFTRESFINAMT_M,
    @p_erreur=@p_erreur output
  select @erreur=@@error
  if @erreur!=0 or @retour!=0
  begin
    select @p_erreur="20010 APPLICATIF;PiLIFMOD2_01 " + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end

-- dans tous les cas maj de l'ent�te
update TLIFMOD
 set LSTUPD_D=getdate()
    ,LSTUPDUSR_CF=suser_name()
  where CTR_NF=@p_CTR_NF
    and SEC_NF=@p_SEC_NF
    and BALSHEY_NF=@p_BALSHEY_NF
    and BALSHTMTH_NF=@p_BALSHTMTH_NF
    and CRE_D=@p_CRE_D
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20004 APPLICATIF;TLIFMOD" + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
EXEC sp_procxmode 'dbo.PuLIFMOD2_01_O2', 'unchained'
go
IF OBJECT_ID('dbo.PuLIFMOD2_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuLIFMOD2_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuLIFMOD2_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PuLIFMOD2_01_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuLIFMOD2_01_O2 TO GDBBATCH
go
