use BEST
go
if object_id('dbo.PuLIFMOD2_01') IS NOT null
begin
  drop procedure dbo.PuLIFMOD2_01
  if object_id('dbo.PuLIFMOD2_01') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PuLIFMOD2_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PuLIFMOD2_01 >>>'
end
go
create procedure PuLIFMOD2_01
  (
   @p_CTR_NF         UCTR_NF
  ,@p_SEC_NF         USEC_NF
  ,@p_CRE_D          datetime
  ,@p_BALSHEY_NF     smallint
  ,@p_BALSHTMTH_NF   tinyint
  ,@p_ACY_NF         UACCYER_NF
  ,@p_COMACC_B       bit
  ,@p_AFTPRMAMT_M    UAMT_M
  ,@p_AFTRESTECAMT_M UAMT_M
  ,@p_AFTRESDACAMT_M UAMT_M
  ,@p_AFTRESFINAMT_M UAMT_M
  ,@p_erreur         varchar(64)= null output
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
1 Florent   24/01/2012 :spot:23260 interdit la création de ligne si avant le bilan en cours
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
  select @p_erreur='30002 ESTIMATION;erreur période bilan/wrong balance sheet period;',@erreur=30002
  goto fin
end

update TLIFMOD2
 set AFTPRMAMT_M=isnull(@p_AFTPRMAMT_M*1000,0)
    ,AFTRESTECAMT_M=isnull(@p_AFTRESTECAMT_M*1000,0)
    ,AFTRESDACAMT_M=isnull(@p_AFTRESDACAMT_M*1000,0)
    ,AFTRESFINAMT_M=isnull(@p_AFTRESFINAMT_M*1000,0)
    ,COMACC_B=@p_COMACC_B
    ,LSTUPD_D=getdate()
    ,LSTUPDUSR_CF=suser_name()
  where CTR_NF=@p_CTR_NF
    and SEC_NF=@p_SEC_NF
    and BALSHEY_NF=@p_BALSHEY_NF
    and BALSHTMTH_NF=@p_BALSHTMTH_NF
    and CRE_D=@p_CRE_D
    and ACY_NF=@p_ACY_NF
select @erreur=@@error, @lignes=@@rowcount
if @erreur!=0
begin
  select @p_erreur="20004 APPLICATIF;TLIFMOD2" + convert(varchar(10),@erreur) + ";"
  goto fin
end

-- commen on n'enregistre pas toute les acy s'il n'y a pas de montants alors si des montants AFT... sont créés :
if @lignes=0
begin
  exec @retour = PiLIFMOD2_01 @p_CTR_NF=@p_CTR_NF, @p_SEC_NF=@p_SEC_NF, @p_CRE_D=@p_CRE_D, @p_BALSHEY_NF=@p_BALSHEY_NF,
    @p_BALSHTMTH_NF=@p_BALSHTMTH_NF, @p_ACY_NF=@p_ACY_NF, @p_COMACC_B=@p_COMACC_B, @p_PRIPRMAMT_M=null, @p_AFTPRMAMT_M=@p_AFTPRMAMT_M,
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

-- dans tous les cas maj de l'entête
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
if object_id('dbo.PuLIFMOD2_01') IS NOT null
  print '<<< CREATED procedure dbo.PuLIFMOD2_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PuLIFMOD2_01 >>>'
go
grant execute on dbo.PuLIFMOD2_01 TO GOMEGA
go
