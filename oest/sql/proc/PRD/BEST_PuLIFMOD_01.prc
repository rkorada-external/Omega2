use BEST
go
if object_id('dbo.PuLIFMOD_01') IS NOT null
begin
  drop procedure dbo.PuLIFMOD_01
  if object_id('dbo.PuLIFMOD_01') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PuLIFMOD_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PuLIFMOD_01 >>>'
end
go
create procedure PuLIFMOD_01
  (
   @p_CTR_NF       UCTR_NF
  ,@p_SEC_NF       USEC_NF
  ,@p_CRE_D        datetime
  ,@p_BALSHEY_NF   smallint
  ,@p_BALSHTMTH_NF tinyint
  ,@p_TYPMOD1_CT   tinyint
  ,@p_TYPMOD2_CT   tinyint
  ,@p_erreur       varchar(64)= null output
  )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 01/09/2004
Description du programme: estimation Vie, suivi dépassement du seuil
Conditions d'execution: par w_reponse_seuil_lifmod
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
*****************************************************/
declare
  @erreur    int,
  @tran_imbr bit,
  @lignes    int

select @erreur = 0, @tran_imbr = 1
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end

update TLIFMOD
 set TYPMOD1_CT=@p_TYPMOD1_CT
    ,TYPMOD2_CT=@p_TYPMOD2_CT
    ,ORICOD_LS='TP'
    ,LSTUPD_D=getdate()
    ,LSTUPDUSR_CF=suser_name()
  where CTR_NF=@p_CTR_NF
    and SEC_NF=@p_SEC_NF
    and BALSHEY_NF=@p_BALSHEY_NF
    and BALSHTMTH_NF=@p_BALSHTMTH_NF
    and CRE_D=@p_CRE_D
select @erreur=@@error
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
if object_id('dbo.PuLIFMOD_01') IS NOT null
  print '<<< CREATED procedure dbo.PuLIFMOD_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PuLIFMOD_01 >>>'
go
grant execute on dbo.PuLIFMOD_01 TO GOMEGA
go
