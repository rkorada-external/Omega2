use BEST
go
if object_id('dbo.PdTSEGEST_02') is not null
begin
  drop PROC dbo.PdTSEGEST_02
  print '<<< DROPPED PROC dbo.PdTSEGEST_02 >>>'
end
go
create procedure PdTSEGEST_02
  (
  @p_vers_nf      numeric
 ,@p_ssd_cf       USSD_CF
 ,@p_segtyp_ct    USEGTYP_CT
 ,@p_seg_nf       USEG_NF
 ,@p_uwy_nf       UUWY_NF
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
Date de creation:09/08/2004
Description du programme: Supression d'enregistrements dans TSEGEST  et TSEGMENT si necessaire.
Conditions d'execution: le segtyp_ct A de TSEGMENT joint sur le segtyp_ct A ou/et S de TSEGEST
Commentaires:
_________________
1  Florent   14/02/2012 :spot:23390 SOLVENCY II
*****************************************************/
declare
  @erreur      int
 ,@tran_imbr   bit
 ,@getdate     datetime
 ,@user        UUPDUSR_CF
 ,@segtyp      USEGTYP_CT   -- modif 1
 ,@segSolvency USEGTYP_CT   -- modif 1
 ,@s_CRE_D     varchar(30)
 ,@s_typemaj   varchar(30)
 ,@s_ssd_cf    varchar(30)
 ,@s_vers_nf   varchar(30)
 ,@s_seg_nf    varchar(30)
 ,@s_exe       varchar(30)
 ,@s_cur       varchar(30)

-- modif 1 -- on prend aussi le segment S quand le type est A
if @p_segtyp_ct='A'
  select @segSolvency='S'
else
  select @segSolvency=@p_segtyp_ct
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

delete TSEGEST
 where vrs_nf=@p_vers_nf
   and ssd_cf=@p_ssd_cf
   and segtyp_ct=@p_segtyp_ct
   and seg_nf=@p_seg_nf
   and uwy_nf=@p_uwy_nf
select @erreur=@@error
if @@transtate=2
begin
   select @p_erreur="ERREUR trigger"
   goto fin
end
if @erreur!=0
begin
   select @p_erreur="20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
   goto fin
end

if not exists (select 1 from TSEGEST where vrs_nf=@p_vers_nf and ssd_cf=@p_ssd_cf and segtyp_ct in(@p_segtyp_ct,@segSolvency) and seg_nf=@p_seg_nf) -- modif 1
begin
  delete TSEGMENT
   where vrs_nf=@p_vers_nf
     and ssd_cf=@p_ssd_cf
     and segtyp_ct=@segtyp
     and seg_nf=@p_seg_nf -- modif 1
  select @erreur=@@error
  if @@transtate=2
  begin
    select @p_erreur="ERREUR trigger"
    goto fin
  end
  if @erreur!=0
  begin
    select @p_erreur="20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
   ----------------------------------------------
   -- Execution ASYNCHRONE
   -- -------------------------------------------
  select
    @s_CRE_D="''"
   ,@s_typemaj = 'D'                           -- U = insert / update , D = delete
   ,@s_ssd_cf = convert(varchar(30),@p_ssd_cf)
   ,@s_vers_nf = convert(varchar(30),@p_vers_nf)
   ,@s_seg_nf = "'" + @p_seg_nf + "'"  -- pour gérer les espaces
   ,@s_exe = convert(char(4),@p_uwy_nf)
   ,@s_cur = ''
  execute BTEC..Pijobqueue_01 "best10a",@user,null
  -- paramètres du job
        ,@s_CRE_D,@s_typemaj,@s_ssd_cf,@s_vers_nf,@s_seg_nf,@s_exe,@s_cur,@p_segtyp_ct,'','','','','','','','','','',@p_erreur
  if @erreur!=0
    goto fin
end

select
  @p_lstupd_d=@getdate
 ,@p_lstupdusr_cf=@user
 ,@p_ret='1' --on ne l'utilise pas
----------------------------------------------------------------------------
-- Fin transaction
----------------------------------------------------------------------------
if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
if object_id('dbo.PdTSEGEST_02') is not null
  print '<<< CREATED PROC dbo.PdTSEGEST_02 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PdTSEGEST_02 >>>'
go
grant execute on dbo.PdTSEGEST_02 TO GOMEGA
go
