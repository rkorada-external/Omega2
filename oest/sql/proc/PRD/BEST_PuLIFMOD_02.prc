use BEST
go
if object_id('dbo.PuLIFMOD_02') IS NOT null
begin
  drop procedure dbo.PuLIFMOD_02
  if object_id('dbo.PuLIFMOD_02') IS NOT null
    print '<<< FAILED DROPPING procedure dbo.PuLIFMOD_02 >>>'
  else
    print '<<< DROPPED procedure dbo.PuLIFMOD_02 >>>'
end
go
create procedure PuLIFMOD_02
  (
   @p_CTR_NF       UCTR_NF
  ,@p_SEC_NF       USEC_NF
  ,@p_CRE_D        datetime
  ,@p_BALSHEY_NF   smallint
  ,@p_BALSHTMTH_NF tinyint
  ,@p_CMT_NT       UCMT_NT
  ,@p_RETRO_B      bit = 0
  ,@p_erreur       varchar(64)= null output
  )
as
/***************************************************
Domaine : Estimation
Base principale : BEST
Auteur: Florent
Date de creation: 21/09/2004
Description du programme: estimation Vie, suivi dépassement du seuil
Conditions d'execution: par w_reponse_seuil_histo
Commentaires:
_________________
MODIFICATIONS
M  Auteur          Date       Description
*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@lignes    int
 ,@retour    int
 ,@UWGRP_CF  UGRP_CF

select @erreur = 0, @tran_imbr = 1
if @@trancount = 0
begin
  select @tran_imbr = 0
  begin TRAN
end

if @p_RETRO_B=1
begin
  select @UWGRP_CF=b.GRP_CF
   from BRET..TRETCTR a, BREF..TUSRANFN b
    where RETCTR_NF=@p_ctr_nf
      and RTY_NF=(select max(RTY_NF) from BRET..TRETCTR c where c.RETCTR_NF=@p_ctr_nf and RETCTRSTS_CT in (3,19))
      and a.ADMUSR_CF=b.USR_CF
      and b.PCPGRP_B=1
  select @erreur = @@error
  if @erreur != 0
  begin
    select @p_erreur="20005 APPLICATIF;BRET..TRETCTR " + convert(varchar(10),@erreur) + ";"
    return @erreur
  end
end
else
begin
  select @UWGRP_CF=UWGRP_CF
   from BTRT..TCONTR
    where CTR_NF=@p_CTR_NF
      and UWY_NF=(select max(UWY_NF) from BTRT..TCONTR c where c.CTR_NF=@p_ctr_nf and CTRSTS_CT in (14,17,16,19))
  select @erreur=@@error
  if @erreur!=0
  begin
    select @p_erreur="20005 APPLICATIF;BTRT..TCONTR " + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end

update TLIFMOD
 set CMT_NT=@p_CMT_NT
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
  select @p_erreur="20004 APPLICATIF;TLIFMOD" + convert(varchar(10),@erreur) + ";"
  goto fin
end
if @lignes=0
begin
  select @p_erreur="20006 APPLICATIF;TLIFMOD;"
  goto fin
end

exec @retour = BEST..PuLIFPEN_01 @p_CTR_NF=@p_CTR_NF,@p_SEC_NF=@p_SEC_NF,@p_CRE_D=@p_CRE_D,@p_BALSHEY_NF=@p_BALSHEY_NF,
                @p_BALSHTMTH_NF=@p_BALSHTMTH_NF,@p_UWGRP_CF=@UWGRP_CF,@p_depasse=1,@p_erreur=@p_erreur output
select @erreur=@@error
if @erreur!=0 or @retour!=0
begin
  select @p_erreur="20010 APPLICATIF;PuLIFPEN_01 " + convert(varchar(10),@erreur) + ";"
  goto fin
end

if @tran_imbr = 0 COMMIT TRAN
return 0

fin:
if @tran_imbr = 0 ROLLBACK TRAN
return @erreur
go
if object_id('dbo.PuLIFMOD_02') IS NOT null
  print '<<< CREATED procedure dbo.PuLIFMOD_02 >>>'
else
  print '<<< FAILED CREATING procedure dbo.PuLIFMOD_02 >>>'
go
grant execute on dbo.PuLIFMOD_02 TO GOMEGA
go
