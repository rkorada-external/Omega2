use BEST
go
if object_id('dbo.PuTSEGEST_01') is not null
begin
  drop PROC dbo.PuTSEGEST_01
  print '<<< DROPPED PROC dbo.PuTSEGEST_01 >>>'
end
go
create procedure PuTSEGEST_01
  (
  @p_vers_nf      numeric
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
 ,@p_acy_nf       UUWY_NF
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
Description du programme: Insertion d'enregistrement dans TSEGEST
Conditions d'execution: le segtyp_ct A de TSEGMENT joint sur le segtyp_ct A ou/et S de TSEGEST
Commentaires:
_________________
1  Florent   14/02/2012 :spot:23390 SOLVENCY II
2  KBagwe    22/05/2015 :EST39 evo card changes
*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@getdate   datetime
 ,@user      UUPDUSR_CF
 ,@s_CRE_D     varchar(30)
 ,@s_typemaj   varchar(30)
 ,@s_ssd_cf    varchar(30)
 ,@s_vers_nf   varchar(30)
 ,@s_seg_nf    varchar(30)
 ,@s_exe       varchar(30)
 ,@s_acy       varchar(30)			-- modif 2

select @getdate=getdate(),@user=suser_name(),@erreur=0,@tran_imbr=1
if @p_cre_d='19000101'
  select @p_cre_d=@getdate

if @@trancount=0
begin
  select @tran_imbr=0
  begin tran
end

update TSEGEST
 set PRMAMT_M=@p_prmamt_m
    ,CLMAMT_M=@p_clmamt_m
    ,LOSRAT_R=@p_losart_r
    ,AMORAT_CT=@p_amorat_ct
    ,CRE_D=@p_cre_d
  where ssd_cf=@p_ssd_cf
    and vrs_nf=@p_vers_nf
    and seg_nf=@p_seg_nf
    and uwy_nf=@p_uwy_nf
    and SEGTYP_CT=@p_segtyp_ct -- modif 1
    and acy_nf = @p_acy_nf	   -- modif 2
select @erreur=@@error
if @@transtate=2
begin
  select @p_erreur="ERREUR trigger"
  goto fin
end
if @erreur!=0
begin
  if @erreur = 2601
    select @p_erreur = "20002 APPLICATIF;2601;"
  else
    select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
  goto fin
end

----------------------------------------------
--Execution ASYNCHRONE
----------------------------------------------
select
  @s_CRE_D="'"+convert(varchar(30),@p_cre_d,109)+"'" -- pour gérer les espaces
 ,@s_typemaj='U'                           -- U = insert / update , D = delete
 ,@s_ssd_cf = convert(varchar(30),@p_ssd_cf)
 ,@s_vers_nf = convert(varchar(30),@p_vers_nf)
 ,@s_seg_nf = "'" + @p_seg_nf + "'"  -- pour gérer les espaces
 ,@s_exe = convert(char(4),@p_uwy_nf)
 ,@s_acy = convert(char(4),@p_acy_nf)			-- modif 2
execute BTEC..Pijobqueue_01 "best10a",@user,null
-- paramètres du job
      ,@s_CRE_D,@s_typemaj,@s_ssd_cf,@s_vers_nf,@s_seg_nf,@s_exe,@p_cur_cf,@p_segtyp_ct,@s_acy,'','','','','','','','','',@p_erreur
if @erreur!=0
  goto fin

select @p_lstupd_d=@getdate,@p_lstupdusr_cf=@user,@p_ret='1'

if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
if object_id('dbo.PuTSEGEST_01') is not null
  print '<<< CREATED PROC dbo.PuTSEGEST_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuTSEGEST_01 >>>'
go
grant execute on dbo.PuTSEGEST_01 TO GOMEGA
go
