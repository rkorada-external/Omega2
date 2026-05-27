use BEST
go
if object_id('dbo.PiCTRULT_10') IS not null
begin
  drop PROC dbo.PiCTRULT_10
  print '<<< DROPPED PROC dbo.PiCTRULT_10 >>>'
end
go
create procedure PiCTRULT_10
  (
  @p_ctr_nf       UCTR_NF
 ,@p_end_nt       UEND_NT
 ,@p_sec_nf       USEC_NF
 ,@p_uwy_nf       UUWY_NF
 ,@p_uw_nt        UUW_NT
 ,@p_ssd_cf       USSD_CF
 ,@p_cre_d        UUPD_D
 ,@p_admmodprm_ct char(1)
 ,@p_calamtprm_m  UAMT_M
 ,@p_entamtprm_m  UAMT_M
 ,@p_retamtprm_m  UAMT_M
 ,@p_resprm_m     UAMT_M
 ,@p_updusr_cf    char(10)
 ,@p_admmodclm_ct char(1)
 ,@p_oricod_ls    UL16
 ,@p_calamtclm_m  UAMT_M
 ,@p_entamtclm_m  UAMT_M
 ,@p_retamtclm_m  UAMT_M
 ,@p_cur_cf       UCUR_CF
 ,@p_div_nt       UDIV_NT
 ,@p_defsbjprm_m  UAMT_M
 ,@p_egplessco_m  UAMT_M
 ,@p_scoegpcal_b  bit
 ,@p_pmlrat_r     USHORAT_R
 ,@p_scogloegp_m  UAMT_M
 ,@p_estend_b     bit
 ,@p_estupdtyp_ct char(1)
 ,@p_lstupd_d     UUPD_D=null output
 ,@p_lstupdusr_cf UUPDUSR_CF=null output
 ,@p_erreur       varchar(64)=null output
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: ME34 avec Infotool version 2.0 (AUTO)
Date de creation:
Description du programme: - Insertion dans la BEST..TCTRULT
                          - Si contrat de type TRAITE
                            - update BTRT..TSECTION
                            - update BTRT..TFAMCOTP
                            - update BTRT..TFAMLIA
                          - Si contrat de type FAC
                            - update BFAC..TSECTION
Conditions d'execution:
Commentaires:
_________________
HISTORIQUE
1  DEBEVER   27/08/1997 MAJ de cre_d ? la valeur de getdate()
2  L.DEBEVER 09/02/1998 Condition pour d?terminer si un contrat est un Trait?:
                         if @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z% or @p_ctr_nf like "__U%" or @p_ctr_nf like "__W%",
                         au lieu de : if @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%"
                         Il existe des trait?s de type "__U%" et "__W%"
3  Florent   03/06/2006 TRT12471 gestion de la fiche de synth?se, si trt accept? et valide et modif S/P et TRT non vie et exe >=1997 alors cr?ation d'une FDS
4  Florent   30/03/2007 TRT13517 ajout param?tre motif de FDS
5  Vibhas    14/03/2014 TRT04 changes 
*****************************************************/
declare
  @erreur    int
 ,@tran_imbr bit
 ,@nbligne   smallint
 ,@nbtime    smallint
 ,@cre_d     UUPD_D

select @erreur=0, @tran_imbr=1
if @@trancount=0
begin
  select @tran_imbr=0
  begin tran
end

select @cre_d=getdate() -- modif 1

insert into TCTRULT
  (
  ctr_nf,
  end_nt,
  sec_nf,
  uw_nt,
  uwy_nf,
  cre_d,
  admmodclm_ct,
  admmodprm_ct,
  calamtclm_m,
  calamtprm_m,
  creusr_cf,
  cur_cf,
  div_nt,
  entamtclm_m,
  entamtprm_m,
  oricod_ls,
  resprm_m,
  retamtclm_m,
  retamtprm_m,
  ssd_cf,
  updusr_cf,
  lstupd_d,
  lstupdusr_cf
  )
 values
  (
  @p_ctr_nf,
  @p_end_nt,
  @p_sec_nf,
  @p_uw_nt,
  @p_uwy_nf,
  @cre_d,    -- modif 1 (avant : @p_cre_d,)
  @p_admmodclm_ct,
  @p_admmodprm_ct,
  @p_calamtclm_m,
  @p_calamtprm_m,
  suser_name(),
  @p_cur_cf,
  @p_div_nt,
  @p_entamtclm_m,
  @p_entamtprm_m,
  @p_oricod_ls,
  @p_resprm_m,
  @p_retamtclm_m,
  @p_retamtprm_m,
  @p_ssd_cf,
  @p_updusr_cf,
  getdate(),
  suser_name()
  )
select @erreur = @@error
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

/*---------------------------------------
  Si contrat de type TRAITE

    - update BTRT..TSECTION
    - update BTRT..TFAMCOTP
    - update BTRT..TFAMLIA
---------------------------------------*/
-- Modif 2
if @p_ctr_nf like "__T%" or @p_ctr_nf like "__Z%" or @p_ctr_nf like "__U%" or @p_ctr_nf like "__W%"
begin
  update BTRT..TSECTION
   set admmodprm_ct = @p_admmodprm_ct,
       estend_b     = @p_estend_b,
       estupdtyp_ct = @p_estupdtyp_ct,
       lstupd_d     = getdate(),
       lstupdusr_cf = suser_name()
       where ctr_nf = @p_ctr_nf
       and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and uw_nt  = @p_uw_nt
         and uwy_nf = @p_uwy_nf
  select @erreur = @@error, @nbligne = @@rowcount
  if @@transtate = 2
  begin
    select @p_erreur = "ERREUR trigger"
    goto fin
  end
  if @erreur != 0
  begin
    select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
    goto fin
  end

  update BTRT..TFAMCOTP
   set defsbjprm_m = @p_defsbjprm_m,
       lstupd_d = getdate(),
       lstupdusr_cf = suser_name()
       where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and uw_nt = @p_uw_nt
         and uwy_nf = @p_uwy_nf
  select @erreur = @@error, @nbligne = @@rowcount
  if @@transtate = 2
  begin
    select @p_erreur = "ERREUR trigger"
    goto fin
  end
  if @erreur != 0
  begin
    select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
    goto fin
  end

  -- modif 3
  -- MOD 5 starts
 /* if exists (select 1 from BTRT..TCONTR where ctr_nf=@p_ctr_nf and uwy_nf=@p_uwy_nf and uw_nt=@p_uw_nt and end_nt=@p_end_nt and CTRLCK_B=0 and CTRSTS_CT in(14,17,16,19))
  and exists (select 1 from BTRT..TFAMLIA where ctr_nf=@p_ctr_nf and end_nt=@p_end_nt and sec_nf=@p_sec_nf and uw_nt=@p_uw_nt and uwy_nf=@p_uwy_nf
              and isnull(pmlrat_r,-1)!=isnull(@p_pmlrat_r,-1) and CTR_NF not like '[01]4%' and uwy_nf>=1997)
			  
  begin
    exec @erreur=BTRT..PtFDS_02 @p_CTR_NF,@p_UWY_NF,@p_UW_NT,@p_END_NT,0,2,@p_erreur output -- modif 4
    if @erreur!=0 or @@error!=0 goto fin
  end */ -- MOD 5 ends

  update BTRT..TFAMLIA
   set egplessco_m  = @p_egplessco_m,
       scoegpcal_b  = @p_scoegpcal_b,
       pmlrat_r     = @p_pmlrat_r,
       scogloegp_m  = @p_scogloegp_m,
       lstupd_d     = getdate(),
       lstupdusr_cf = suser_name()
   where ctr_nf = @p_ctr_nf
     and end_nt = @p_end_nt
     and sec_nf = @p_sec_nf
     and uw_nt = @p_uw_nt
     and uwy_nf = @p_uwy_nf
  select @erreur = @@error, @nbligne = @@rowcount
  if @@transtate = 2
  begin
    select @p_erreur = "ERREUR trigger"
    goto fin
  end
  if @erreur != 0
  begin
    select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
    goto fin
  end
end

/*-----------------------------------
  Si contrat de type FACULTATIVE
  - update BFAC..TSECTION
-----------------------------------*/
if @p_ctr_nf like "__F%" or @p_ctr_nf like "__G%"
begin
  update BFAC..TSECTION
   set admmodprm_ct = @p_admmodprm_ct,
       estupdtyp_ct = @p_estupdtyp_ct,
       lstupd_d     = getdate(),
       lstupdusr_cf = suser_name()
       where ctr_nf = @p_ctr_nf
       and end_nt = @p_end_nt
         and sec_nf = @p_sec_nf
         and uw_nt  = @p_uw_nt
         and uwy_nf = @p_uwy_nf
  select @erreur = @@error, @nbligne = @@rowcount
  if @@transtate = 2
  begin
    select @p_erreur = "ERREUR trigger"
    goto fin
  end
  if @erreur != 0
  begin
    select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
    goto fin
  end
end

select @p_lstupdusr_cf = lstupdusr_cf,
       @p_lstupd_d = lstupd_d
from TCTRULT
       where ctr_nf = @p_ctr_nf
         and end_nt = @p_end_nt
       and sec_nf = @p_sec_nf
         and uw_nt = @p_uw_nt
         and uwy_nf = @p_uwy_nf
         and cre_d = @cre_d
select @erreur = @@error
if @erreur != 0
   select @p_erreur = "20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

if @tran_imbr = 0
   commit tran
return 0

fin:
if @tran_imbr = 0
   rollback tran
return @erreur
go
if object_id('dbo.PiCTRULT_10') IS not null
  print '<<< CREATED PROC dbo.PiCTRULT_10 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PiCTRULT_10 >>>'
go
grant execute on dbo.PiCTRULT_10 TO GOMEGA
go
grant execute on dbo.PiCTRULT_10 TO GDBBATCH
go