use BEST
go
if object_id('dbo.PiACCSUP_01_O2') is not null
begin
  drop PROC dbo.PiACCSUP_01_O2
  print '<<< DROPPED PROC dbo.PiACCSUP_01_O2 >>>'
end
go
create procedure PiACCSUP_01_O2
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
 ,@p_ret             char(64)=null output
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
Description du programme:
      * Insertion d'enregistrement dans TACCSUP
      * Appel proc de lancement de job asynchrone de génération des écritures de rétrocession
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1  L.DEBEVER   25/11/1997 Maj numéro de la ligne de participation variable créée suite à maj de base:
                          désormais, les n° d'écriture ne sont plus 'numeric identity' => leur incrémentation n'est plus gérée par SYBASE
2  L.DEBEVER   05/12/1997 Rajout lancement batch asynchrone.
3  L.DEBEVER   31/03/1998 Acces direct à TREQJOB en remplacement du lancement de la proc PsREQJOB_03 (Utilise BTRAV -> Interdit en TP)
4  L.DEBEVER   17/04/1998 Rajout de trn_nt créé en parametre de PiJOBQUEUE_01
5  L.DEBEVER   10/06/1998 retend_nt=0 / retuw_nt=1 systématiquement
6  M.DJELLOULI 27/04/2005 :spot:5084 Ajout de la Zone speenttyp_cf 1
7  M.DJELLOULI 24/06/2005 :spot:5085 Ajout Zone SPEENTNAT_CT
8  Florent     01/02/2012 :spot:22456 EVOLUTION DES REGROUPEMENTS PARENT GAAP
9  Florent     05/03/2012 :spot:23494 correction EVOLUTION DES REGROUPEMENTS PARENT GAAP

_________________
MODIFICATION 10
Auteur:J CHOCHON
Date : 17/02/2012
Version:
Description: Omega 2 SSL Impact
				TSUBTRSH is now obsolet and it's replaced by TSUBTRSESB
_________________				

MODIFICATION 11
Auteur: Amit D
Date : 10/02/2015
Version:
Description: EST 43 a EVO CARD - Added Assume Event Number and Retro Event Number
				

				
*****************************************************/
declare
  @erreur       int
 ,@tran_imbr    bit
 ,@nb_lig       int -- numéro de l'écriture de service créée
 ,@trn_nt       numeric
 ,@getdate      datetime
 ,@user         UUPDUSR_CF
 ,@date         varchar(30)
 ,@ctr_nf       varchar(30)
 ,@end_nt       varchar(30)
 ,@sec_nf       varchar(30)
 ,@uwy_nf       varchar(30)
 ,@uw_nt        varchar(30)
 ,@cur_cf       varchar(30)
 ,@clodat_d     varchar(30)
 ,@pertyp_ct    varchar(30)
 ,@balshey_nf   varchar(30)
 ,@blcshtmth_cf varchar(30)
 ,@blcshtmth_nf smallint
 ,@blcshtyea_nf smallint
 ,@dbclo_d      varchar(30)
 ,@specend_d    varchar(30)
 ,@account_d    varchar(30)
 ,@num_trn      varchar(30)
-- Modif 3 : Variables pour accès TREQJOB
 ,@spcend_d     datetime
 ,@closing_b    bit

select @getdate=getdate(), @user=suser_name(), @erreur=0, @tran_imbr=1
if @@trancount=0
begin
  select @tran_imbr=0
  begin tran
end

-- modif 10
/*if @p_trncod_cf like '_[1-9]%'
   and not exists(select 1 from BREF..TDETTRS d, BREF..TSUBTRSH s
                   where d.dettrs_cf=@p_trncod_cf
                     and s.ssd_cf=@p_ssd_cf
                     and d.pcptrs_cf=s.pcptrs_cf
                     and d.trs_cf=s.trs_cf
                     and d.subtrs_cf=s.subtrs_cf
                     and d.opn_b=1
                     and d.dettrs_cf!=d.ctrscod_cf)		*/
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

-- maj numéro de la ligne de participation variable créée
select @nb_lig=max(TRN_NT)+1 from TACCSUP
select @erreur=@@error
if @erreur!= 0 goto fin

-- init nb_lig si aucun enreg
if @nb_lig=null select @nb_lig=1

insert into TACCSUP
  (
  trn_nt
 ,acctrn_nt
 ,acctyp_nf
 ,acy_nf
 ,amt_m
 ,balshey_nf
 ,balshrday_nf
 ,balshrmth_nf
 ,brk_nf
 ,ced_nf
 ,clm_nf
 ,commac_ll
 ,cre_d
 ,creusr_cf
 ,ctr_nf
 ,cur_cf
 ,dbltrncod_cf
 ,end_nt
 ,entpermth_nf
 ,entpery_nf
 ,esb_cf
 ,ganpayord_nt
 ,gemprmpay_nf
 ,int_nf
 ,lstupd_d
 ,lstupdusr_cf
 ,occyea_nf
 ,plc_nt
 ,rcl_nf
 ,retacy_nf
 ,retamt_m
 ,retautgen_b
 ,retctr_nf
 ,retcur_cf
 ,retend_nt
 ,retkey_cf
 ,retoccyea_nf
 ,retpay_nf
 ,retrty_nf
 ,retscoendmth_nf
 ,retscostrmth_nf
 ,retsec_nf
 ,retuw_nt
 ,rto_nf
 ,scoendmth_nf
 ,scostrmth_nf
 ,sec_nf
 ,ssd_cf
 ,trncod_cf
 ,uw_nt
 ,uwy_nf
 ,valpermth_nf
 ,valpery_nf
 ,speenttyp_cf -- MOD06
 ,SPEENTNAT_CT -- MOD07
 ,EVT_NF -- MOD11
 ,REVT_NF -- MOD11
  )
 values
  (
  @nb_lig
 ,@p_acctrn_nt
 ,@p_acctyp_nf
 ,@p_acy_nf
 ,@p_amt_m
 ,@p_balshey_nf
 ,@p_balshrday_nf
 ,@p_balshrmth_nf
 ,@p_brk_nf
 ,@p_ced_nf
 ,@p_clm_nf
 ,@p_commac_ll
 ,@getdate
 ,@user
 ,@p_ctr_nf
 ,@p_cur_cf
 ,@p_dbltrncod_cf
 ,@p_end_nt
 ,@p_entpermth_nf
 ,@p_entpery_nf
 ,@p_esb_cf
 ,@p_ganpayord_nt
 ,@p_gemprmpay_nf
 ,@p_int_nf
 ,@getdate
 ,@user
 ,@p_occyea_nf
 ,@p_plc_nt
 ,@p_rcl_nf
 ,@p_retacy_nf
 ,@p_retamt_m
 ,@p_retautgen_b
 ,@p_retctr_nf
 ,@p_retcur_cf
 ,0
 ,@p_retkey_cf
 ,@p_retoccyea_nf
 ,@p_retpay_nf
 ,@p_retrty_nf
 ,@p_retscoendmth_nf
 ,@p_retscostrmth_nf
 ,@p_retsec_nf
 ,1
 ,@p_rto_nf
 ,@p_scoendmth_nf
 ,@p_scostrmth_nf
 ,@p_sec_nf
 ,@p_ssd_cf
 ,@p_trncod_cf
 ,@p_uw_nt
 ,@p_uwy_nf
 ,@p_valpermth_nf
 ,@p_valpery_nf
 ,@p_speenttyp_cf -- MOD06
 ,@p_SPEENTNAT_CT -- MOD07
 ,@p_evtNf -- MOD11
 ,@p_revtNf -- MOD11
  )
select @erreur=@@error
if @@transtate=2
begin
  select @p_erreur='ERREUR trigger'
  goto fin
end
if @erreur != 0
begin
  if @erreur=2601
    select @p_erreur='20002 APPLICATIF;2601;'
  else
    select @p_erreur='20001 APPLICATIF;' + convert(varchar(10),@erreur) + ';'
  goto fin
end

-- Récup n° d'écriture créé
select @trn_nt=max(trn_nt) from TACCSUP
select @erreur=@@error
if @erreur!=0 goto fin
select @p_lstupdusr_cf=lstupdusr_cf, @p_lstupd_d=lstupd_d
 from TACCSUP
  where trn_nt=@trn_nt
select @erreur=@@error
if @erreur != 0
begin
  select @p_erreur='20011 APPLICATIF;' + convert(varchar(10),@erreur) + ';'
  goto fin
end

-- Retourner via le paramètre @_ret, le numéro d'écriture affecté lors de l'insert
select @p_ret=convert(char(64),@trn_nt)

-- Si un contrat acceptation est saisi et si 'génération automatique rétrocession':
-- Lancement procedure batch asynchrone : >>>>> insert dans BTEC..PiJOBQUEUE_02 <<<<<
if (@p_ctr_nf is not null and @p_ctr_nf <> '') and @p_retautgen_b=1
begin
  -- Recherche des autres paramètres necessaires au batch dans TREQJOB
  -- Modif 3 : REMPLACEMENT PROC BEST..PsREQJOB_03
  -- Recherche de l'année et de la période du libellé d'inventaire principal.
  execute @erreur=BREF..PsCALEND_02 @getdate,'C',@blcshtyea_nf output,@blcshtmth_nf output,@spcend_d output,@account_d output,@closing_b output
  if @erreur!=0
  begin
    select @p_erreur = '20005 APPLICATIF;TACCSUP/TCALEND ' + convert(varchar(10),@erreur) + ';'
    return @erreur
  end
  -- LIBELLE INVENTAIRE :
  -- remplacer la premier jour du mois par le dernier jour du même mois pour
  -- obtenir le vrai libéllé d'inventaire principal
  select @clodat_d=convert(char(8),dateadd(dd,-1,dateadd(mm,1,convert(char(6),@blcshtyea_nf*100 + @blcshtmth_nf) + '01')),112)
  -- Recherche si en période de service
  select @pertyp_ct='H', @dbclo_d=convert(char(8),@getdate,112)
  if @dbclo_d > @spcend_d select @pertyp_ct='S', @dbclo_d=@spcend_d
  -- Modif 3 : FIN REMPLACEMENT PROC BEST..PsREQJOB_03
  --Convertion variable output necessaires au batch
  select
    @date      =convert(varchar(30),@getdate,112)
   ,@ctr_nf    =convert(varchar(30),@p_ctr_nf)
   ,@end_nt    =convert(varchar(30),@p_end_nt)
   ,@sec_nf    =convert(varchar(30),@p_sec_nf)
   ,@uwy_nf    =convert(varchar(30),@p_uwy_nf)
   ,@uw_nt     =convert(varchar(30),@p_uw_nt)
   ,@cur_cf    =convert(varchar(30),@p_cur_cf)
   ,@balshey_nf=convert(varchar(30),@p_balshey_nf)
   ,@num_trn   =convert(varchar(30),@trn_nt)
   ,@blcshtmth_cf=convert(varchar(30),@blcshtmth_nf)
  exec @erreur=BTEC..PiJOBQUEUE_01 'best03a',@user,@getdate,@date,@ctr_nf,@end_nt,@sec_nf,@uwy_nf,@uw_nt
                                   ,@cur_cf,@clodat_d,@balshey_nf,@pertyp_ct,@blcshtmth_cf,@dbclo_d,@num_trn,'','','','',''
  if @erreur != 0
  begin
    select @p_erreur='20001 APPLICATIF;BTEC..PiJOBQUEUE_01' + convert(varchar(10),@erreur) + ';'
    goto fin
  end
end
if @tran_imbr=0 commit tran
return 0

fin:
if @tran_imbr=0 rollback tran
return @erreur
go
if object_id('dbo.PiACCSUP_01_O2') is not null
  print '<<< CREATED PROC dbo.PiACCSUP_01_O2 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PiACCSUP_01_O2 >>>'
go
grant execute on dbo.PiACCSUP_01_O2 TO GOMEGA
go
