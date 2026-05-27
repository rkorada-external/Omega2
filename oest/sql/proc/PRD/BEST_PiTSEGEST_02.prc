use BEST
go
if object_id('dbo.PiTSEGEST_02') is not null
begin
  drop PROC dbo.PiTSEGEST_02
  print '<<< DROPPED PROC dbo.PiTSEGEST_02 >>>'
end
go
create procedure PiTSEGEST_02
  (
  @p_vers_nf  numeric
 ,@p_ssd_cf       USSD_CF
 ,@p_segtyp_ct    USEGTYP_CT
 ,@p_seg_nf       USEG_NF
 ,@p_uwy_nf       UUWY_NF
 ,@p_cre_d        UUPD_D
 ,@p_cur_cf       UCUR_CF
 ,@p_prmamt_m     UAMT_M
 ,@p_clmamt_m     UAMT_M
 ,@p_losart_r     USHORAT_R
 ,@p_amorat_ct    char(1)
 ,@p_seg_ll       UL64
 ,@p_segnat_ct    char(1)
 ,@p_ctrret_b     bit
 ,@p_retro_np     bit
 ,@p_lstupd_d     UUPD_D=null output
 ,@p_lstupdusr_cf UUPDUSR_CF=null output
 ,@p_ret          char(64) = null output
 ,@p_erreur       varchar(64)=null output
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME57
Date de creation:03/08/2004
Description du programme:  Insertion d'enregistrement dans TSEGEST et dans TSEGMENT
Conditions d'execution: le segtyp_ct A de TSEGMENT joint sur le segtyp_ct A ou/et S de TSEGEST
Commentaires:
_________________
1  Florent   14/02/2012 :spot:23390 SOLVENCY II
*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@getdate   datetime
 ,@user      UUPDUSR_CF
 ,@segtyp    USEGTYP_CT     -- modif 1
 ,@s_CRE_D     varchar(30)
 ,@s_typemaj   varchar(30)
 ,@s_ssd_cf    varchar(30)
 ,@s_vers_nf   varchar(30)
 ,@s_seg_nf    varchar(30)
 ,@s_exe       varchar(30)

-- pour les jointures sur les autres table que TSEGEST il faut prendre le A si on a S
if @p_segtyp_ct='S'
  select @segtyp='A'
else
  select @segtyp=@p_segtyp_ct

select @getdate=getdate(),@user=suser_name(),@erreur=0,@tran_imbr=1
if @@trancount=0
begin
  select @tran_imbr=0
  begin tran
end

insert into TSEGEST
  (
  VRS_NF
 ,SSD_CF
 ,SEGTYP_CT
 ,SEG_NF
 ,UWY_NF
 ,CRE_D
 ,CUR_CF
 ,PRMAMT_M
 ,CLMAMT_M
 ,LOSRAT_R
 ,AMORAT_CT
  )
 values
  (
  @p_vers_nf
 ,@p_ssd_cf
 ,@p_segtyp_ct
 ,@p_seg_nf
 ,@p_uwy_nf
 ,@p_cre_d
 ,@p_cur_cf
 ,@p_prmamt_m
 ,@p_clmamt_m
 ,@p_losart_r
 ,@p_amorat_ct
  )
select @erreur=@@error
if @@transtate=2
begin
  select @p_erreur="ERREUR trigger"
  goto fin
end
if @erreur != 0
begin
  if @erreur = 2601
    select @p_erreur = "20002 APPLICATIF;2601;"
  else
    select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
  goto fin
end

--Verifier qu'il n'existe aucune ligne dans tsegment : insert sinon update
if not exists (select 1 from TSEGMENT where vrs_nf=@p_vers_nf and ssd_cf=@p_ssd_cf and segtyp_ct=@segtyp and seg_nf=@p_seg_nf) -- modif 1
begin
  insert into BEST..TSEGMENT
  (
  VRS_NF
 ,SSD_CF
 ,SEGTYP_CT
 ,SEG_NF
 ,SEG_LL
 ,CUR_CF
 ,SEGNAT_CT
 ,CTRRET_B
 ,ANO_B
 ,RETRO_NP -- modif 1
  )
  values
   (
   @p_vers_nf
  ,@p_ssd_cf
  ,@segtyp      -- modif 1
  ,@p_seg_nf
  ,@p_seg_ll
  ,@p_cur_cf
  ,@p_segnat_ct
  ,@p_ctrret_b
  ,0 --ano_b
  ,@p_retro_np -- modif 1
   )
  select @erreur=@@error
  if @@transtate=2
  begin
   select @p_erreur="ERREUR trigger"
   goto fin
  end
  if @erreur!=0
  begin
    if @erreur=2601
      select @p_erreur="20002 APPLICATIF;2601;"
    else
      select @p_erreur="20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end
else --Il existe des lignes dans tsegment
begin
  update TSEGMENT
   set CUR_CF=@p_cur_cf
      ,CTRRET_B=@p_ctrret_b
      ,RETRO_NP=@p_retro_np
    where VRS_NF=@p_vers_nf
      and SSD_CF=@p_ssd_cf
      and SEGTYP_CT=@segtyp -- modif 1
      and SEG_NF=@p_seg_nf
  select @erreur=@@error
  if @@transtate=2
  begin
    select @p_erreur = "ERREUR trigger"
    goto fin
  end
  if @erreur != 0
  begin
    if @erreur = 2601
      select @p_erreur = "20002 APPLICATIF;2601;"
    else
      select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end

----------------------------------------------
-- Execution ASYNCHRONE
----------------------------------------------
select
  @s_CRE_D="'"+convert(varchar(30),@p_cre_d,109)+"'" -- pour gérer les espaces
 ,@s_typemaj='U'                           -- U = insert / update , D = delete
 ,@s_ssd_cf = convert(varchar(30),@p_ssd_cf)
 ,@s_vers_nf = convert(varchar(30),@p_vers_nf)
 ,@s_seg_nf = "'" + @p_seg_nf + "'"  -- pour gérer les espaces
 ,@s_exe = convert(char(4),@p_uwy_nf)
execute BTEC..Pijobqueue_01 "best10a",@user,null
-- paramètres du job
      ,@s_CRE_D,@s_typemaj,@s_ssd_cf,@s_vers_nf,@s_seg_nf,@s_exe,@p_cur_cf,@p_segtyp_ct,'','','','','','','','','','',@p_erreur
if @erreur!=0
  goto fin

select @p_lstupd_d=@getdate,@p_lstupdusr_cf=@user,@p_ret='1'
-------------------------------------------------------------------------
-- Fin transaction
-------------------------------------------------------------------------
if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
if object_id('dbo.PiTSEGEST_02') is not null
  print '<<< CREATED PROC dbo.PiTSEGEST_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PiTSEGEST_02 >>>'
go
grant execute on dbo.PiTSEGEST_02 TO GOMEGA
go

