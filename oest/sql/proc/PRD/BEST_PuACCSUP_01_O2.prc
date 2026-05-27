use BEST
go
if object_id('dbo.PuACCSUP_01_O2') is not null
begin
  drop PROC dbo.PuACCSUP_01_O2
  print '<<< DROPPED PROC dbo.PuACCSUP_01_O2 >>>'
end
go
create procedure PuACCSUP_01_O2
  (
  @p_trn_nt          numeric
 ,@p_acctrn_nt       numeric
 ,@p_acctyp_nf       tinyint
 ,@p_acy_nf          smallint
 ,@p_amt_m           UAMT_M
 ,@p_balshey_nf      smallint
 ,@p_balshrday_nf    tinyint
 ,@p_balshrmth_nf    tinyint
 ,@p_brk_nf          UCLI_NF
 ,@p_ced_nf          UCLI_NF
 ,@p_clm_nf          UCLM_NF
 ,@p_commac_ll       UL64
 ,@p_cre_d           UUPD_D
 ,@p_creusr_cf       UUPDUSR_CF
 ,@p_ctr_nf          UCTR_NF
 ,@p_cur_cf          UCUR_CF
 ,@p_dbltrncod_cf    UDETTRS_CF
 ,@p_end_nt          UEND_NT
 ,@p_entpermth_nf    tinyint
 ,@p_entpery_nf      smallint
 ,@p_esb_cf          UESB_CF
 ,@p_ganpayord_nt    UPAYORD_NT
 ,@p_gemprmpay_nf    UCLI_NF
 ,@p_int_nf          UCLI_NF
 ,@p_occyea_nf       smallint
 ,@p_plc_nt          UPLC_NT
 ,@p_rcl_nf          UCLM_NF
 ,@p_retacy_nf       smallint
 ,@p_retamt_m        UAMT_M
 ,@p_retautgen_b     bit
 ,@p_retctr_nf       URETCTR_NF
 ,@p_retcur_cf       UCUR_CF
 ,@p_retend_nt       tinyint
 ,@p_retkey_cf       char(1)
 ,@p_retoccyea_nf    smallint
 ,@p_retpay_nf       UCLI_NF
 ,@p_retrty_nf       UUWY_NF
 ,@p_retscoendmth_nf tinyint
 ,@p_retscostrmth_nf tinyint
 ,@p_retsec_nf       URETSEC_NF
 ,@p_retuw_nt        tinyint
 ,@p_rto_nf          UCLI_NF
 ,@p_scoendmth_nf    tinyint
 ,@p_scostrmth_nf    tinyint
 ,@p_sec_nf          USEC_NF
 ,@p_ssd_cf          USSD_CF
 ,@p_trncod_cf       UDETTRS_CF
 ,@p_uw_nt           UUW_NT
 ,@p_uwy_nf          UUWY_NF
 ,@p_valpermth_nf    tinyint
 ,@p_valpery_nf      smallint
 ,@p_speenttyp_cf    tinyint
 ,@p_SPEENTNAT_CT    tinyint
 ,@p_lstupd_d        UUPD_D=null output
 ,@p_lstupdusr_cf    UUPDUSR_CF=null output
 ,@p_erreur          varchar(64)=null output
 ,@p_evtNf           char(64)
 ,@p_revtNf          char(64) 
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER)
Date de creation:
Description du programme: Modification d'enregistrement dansTACCSUP
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  LC          05/01/1999 retend_nt=0 / retuw_nt=1 systématiquement
2  M.DJELLOULI 27/04/2005 :spot:5084 Ajout de la Zone speenttyp_cf
3  M.DJELLOULI 24/06/2005 :spot:5085 Ajout Zone SPEENTNAT_CT
4  Florent     01/02/2012 :spot:22456 EVOLUTION DES REGROUPEMENTS PARENT GAAP
5  Florent     05/03/2012 :spot:23494 correction EVOLUTION DES REGROUPEMENTS PARENT GAAP
_________________
MODIFICATION 6
Auteur:J CHOCHON
Date : 17/02/2012
Version:
Description: Omega 2 SSL Impact
				TSUBTRSH is now obsolet and it's replaced by TSUBTRSESB
_________________				
				
MODIFICATION 7
Auteur: Amit D
Date : 10/02/2015
Version:
Description: EST 43 a EVO CARD - Added Assume Event Number and Retro Event Number
				
				
				
*****************************************************/
declare
 @erreur    int
,@tran_imbr bit
,@nbligne   smallint
,@nbtime    smallint

select @erreur=0, @tran_imbr=1
if @@trancount=0
begin
  select @tran_imbr=0
  begin tran
end

-- modif 4, modif 5
/* if @p_trncod_cf like '_[1-9]%'													--Modif 06
   and not exists(select 1 from BREF..TDETTRS d, BREF..TSUBTRSH s
                   where d.dettrs_cf=@p_trncod_cf
                     and s.ssd_cf=@p_ssd_cf
                     and d.pcptrs_cf=s.pcptrs_cf
                     and d.trs_cf=s.trs_cf
                     and d.subtrs_cf=s.subtrs_cf
                     and d.opn_b=1
                     and d.dettrs_cf!=d.ctrscod_cf)
															*/
															
if @p_trncod_cf like '_[1-9]%'
   and not exists( select 1 from BREF..TDETTRS d, BREF..TSUBTRSESB s
                   where d.dettrs_cf= @p_trncod_cf
                     and s.ssd_cf= @p_ssd_cf
                     and s.ESB_CF= @p_esb_cf
                     and d.pcptrs_cf=s.pcptrs_cf
                     and d.trs_cf=s.trs_cf
                     and d.subtrs_cf=s.subtrs_cf
                     and d.opn_b=1
                     and d.dettrs_cf!=d.ctrscod_cf)
					 
begin
  select @p_erreur='30003 ESTIMATION;;',@erreur=30003
  goto fin
end


update TACCSUP
 set acctrn_nt=@p_acctrn_nt
    ,acctyp_nf=@p_acctyp_nf
    ,acy_nf=@p_acy_nf
    ,amt_m=@p_amt_m
    ,balshey_nf=@p_balshey_nf
    ,balshrday_nf=@p_balshrday_nf
    ,balshrmth_nf=@p_balshrmth_nf
    ,brk_nf=@p_brk_nf
    ,ced_nf=@p_ced_nf
    ,clm_nf=@p_clm_nf
    ,commac_ll=@p_commac_ll
    ,cre_d=@p_cre_d
    ,creusr_cf=@p_creusr_cf
    ,ctr_nf=@p_ctr_nf
    ,cur_cf=@p_cur_cf
    ,dbltrncod_cf=@p_dbltrncod_cf
    ,end_nt=@p_end_nt
    ,entpermth_nf=@p_entpermth_nf
    ,entpery_nf=@p_entpery_nf
    ,esb_cf=@p_esb_cf
    ,ganpayord_nt=@p_ganpayord_nt
    ,gemprmpay_nf=@p_gemprmpay_nf
    ,int_nf=@p_int_nf
    ,lstupd_d=getdate()
    ,lstupdusr_cf=user
    ,occyea_nf=@p_occyea_nf
    ,plc_nt=@p_plc_nt
    ,rcl_nf=@p_rcl_nf
    ,retacy_nf=@p_retacy_nf
    ,retamt_m=@p_retamt_m
    ,retautgen_b=@p_retautgen_b
    ,retctr_nf=@p_retctr_nf
    ,retcur_cf=@p_retcur_cf
--,retend_nt=@p_retend_nt
    ,retend_nt=0
    ,retkey_cf=@p_retkey_cf
    ,retoccyea_nf=@p_retoccyea_nf
    ,retpay_nf=@p_retpay_nf
    ,retrty_nf=@p_retrty_nf
    ,retscoendmth_nf=@p_retscoendmth_nf
    ,retscostrmth_nf=@p_retscostrmth_nf
    ,retsec_nf=@p_retsec_nf
--,retuw_nt=@p_retuw_nt
    ,retuw_nt=1
    ,rto_nf=@p_rto_nf
    ,scoendmth_nf=@p_scoendmth_nf
    ,scostrmth_nf=@p_scostrmth_nf
    ,sec_nf=@p_sec_nf
    ,ssd_cf=@p_ssd_cf
    ,trncod_cf=@p_trncod_cf
    ,uw_nt=@p_uw_nt
    ,uwy_nf=@p_uwy_nf
    ,valpermth_nf=@p_valpermth_nf
    ,valpery_nf=@p_valpery_nf
    ,speenttyp_cf=@p_speenttyp_cf    -- MOD02
    ,SPEENTNAT_CT=@p_SPEENTNAT_CT    -- MOD03
	,EVT_NF=@p_evtNf        --MODIF07
	,REVT_NF=@p_revtNf      --MODIF07
   where trn_nt=@p_trn_nt
select @erreur=@@error, @nbligne=@@rowcount
if @@transtate=2
begin
  select @p_erreur="ERREUR trigger"
  goto fin
end
if @erreur != 0
begin
  select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
  goto fin
end
select @p_lstupdusr_cf=lstupdusr_cf, @p_lstupd_d=lstupd_d
 from TACCSUP
  where trn_nt=@p_trn_nt
select @erreur=@@error, @nbtime=@@rowcount
if @erreur != 0
  select @p_erreur="20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
if @nbligne=0
begin
  if @nbtime=0
  begin
    select @p_erreur="20012 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
  else
  begin
    select @p_erreur="20013 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
    goto fin
  end
end
if @tran_imbr=0
  commit tran
return @erreur

fin:
if @tran_imbr=0
  rollback tran
return @erreur
go
if object_id('dbo.PuACCSUP_01_O2') is not null
  print '<<< CREATED PROC dbo.PuACCSUP_01_O2 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PuACCSUP_01_O2 >>>'
go
grant execute on dbo.PuACCSUP_01_O2 TO GOMEGA
go
