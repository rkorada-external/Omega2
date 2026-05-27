use BEST
go
if object_id('dbo.PuLIFPEN_01') IS NOT null
begin
  drop procedure dbo.PuLIFPEN_01
  if object_id('dbo.PuLIFPEN_01') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PuLIFPEN_01 >>>'
  else
    print '<<< DROPPED procedure dbo.PuLIFPEN_01 >>>'
end
go
create procedure PuLIFPEN_01
  (
   @p_CTR_NF       UCTR_NF
  ,@p_SEC_NF       USEC_NF
  ,@p_CRE_D        datetime
  ,@p_BALSHEY_NF   smallint
  ,@p_BALSHTMTH_NF tinyint
  ,@p_UWGRP_CF     UGRP_CF
  ,@p_depasse      bit
  ,@p_erreur       varchar(64)= null output
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

--si dépassement du seuil, le commentaire ou types de modif ont changés
if @p_depasse=1
begin
  --on devra renvoyer un autre emel
  update TLIFPEN
   set PENSTS_CT=1 --emel à envoyer
      ,LSTUPD_D=getdate()
      ,LSTUPDUSR_CF=suser_name()
    where CTR_NF=@p_CTR_NF
      and SEC_NF=@p_SEC_NF
      and BALSHEY_NF=@p_BALSHEY_NF
      and BALSHTMTH_NF=@p_BALSHTMTH_NF
      and CRE_D=@p_CRE_D
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur!=0
  begin
    select @p_erreur="20004 APPLICATIF;TLIFPEN" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
  if @lignes=0
  begin
    insert TLIFPEN
      (
       USR_CF
      ,CTR_NF
      ,SEC_NF
      ,CRE_D
      ,BALSHEY_NF
      ,BALSHTMTH_NF
      ,PENSTS_CT
      ,UWGRP_CF
      ,CREUSR_CF
      ,LSTUPD_D
      ,LSTUPDUSR_CF
      )
    select
       suser_name()
      ,@p_CTR_NF
      ,@p_SEC_NF
      ,@p_CRE_D
      ,@p_BALSHEY_NF
      ,@p_BALSHTMTH_NF
      ,PENSTS_CT=1 --emel à envoyer
      ,@p_UWGRP_CF
      ,suser_name()
      ,getdate()
      ,suser_name()
    select @erreur=@@error
    if @erreur!=0
    begin
      if @erreur=2601
        select @p_erreur="20002 APPLICATIF;TLIFPEN"
      else
        select @p_erreur="20001 APPLICATIF;TLIFPEN" + convert(varchar(10),@erreur) + ";"
      goto fin
    end
  end
end
else -- pas de TLIFPEN à gérer
begin
  delete TLIFPEN --dans le cas où ne ne dépasse plus le seuil
    where CTR_NF=@p_CTR_NF
      and SEC_NF=@p_SEC_NF
      and BALSHEY_NF=@p_BALSHEY_NF
      and BALSHTMTH_NF=@p_BALSHTMTH_NF
      and CRE_D=@p_CRE_D
  select @erreur=@@error, @lignes=@@rowcount
  if @erreur!=0
  begin
    select @p_erreur="20003 APPLICATIF;TLIFPEN" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PuLIFPEN_01') IS NOT null
  print '<<< CREATED procedure dbo.PuLIFPEN_01 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PuLIFPEN_01 >>>'
go
grant execute on dbo.PuLIFPEN_01 TO GOMEGA
go
