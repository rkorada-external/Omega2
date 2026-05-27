use BEST
go
if object_id('dbo.PsACCSUP_01') is not null
begin
  drop PROC dbo.PsACCSUP_01
  print '<<< DROPPED PROC dbo.PsACCSUP_01 >>>'
end
go
create procedure PsACCSUP_01
  (
  @p_trn_nt   numeric
 ,@p_creation bit
 ,@p_date     datetime -- modif 3
  )
as
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Version: 1
Auteur: L.DEBEVER (ME01) avec Infotool version 2.0
Date de creation:
Description du programme: Sélection d'enregistrement dans TACCSUP
Conditions d'execution:
Commentaires:
_________________
MODIFICATIONS
1 M.DJELLOULI 27/04/2005 SPOT 5084 - Ajout Zone SPEENTTYP_CF - MOD001
2 M.DJELLOULI 24/06/2005 SPOT 5085 - Ajout Zone SPEENTNAT_CT - MOD002
3 Florent     14/02/2012 :spot:23390 SOLVENCY II, ajout de la date du jour donnée par le poste client
*****************************************************/
declare
  @erreur          int
 ,@trn_nt          numeric  -- zones TACCSUP
 ,@acctrn_nt       numeric
 ,@acctyp_nf       tinyint
 ,@acy_nf          smallint
 ,@amt_m           UAMT_M
 ,@balshey_nf      smallint
 ,@balshrday_nf    tinyint
 ,@balshrmth_nf    tinyint
 ,@brk_nf          UCLI_NF
 ,@ced_nf          UCLI_NF
 ,@clm_nf          UCLM_NF
 ,@commac_ll       UL64
 ,@cre_d           UUPD_D
 ,@creusr_cf       UUPDUSR_CF
 ,@ctr_nf          UCTR_NF
 ,@cur_cf          UCUR_CF
 ,@dbltrncod_cf    UDETTRS_CF
 ,@end_nt          UEND_NT
 ,@entpermth_nf    tinyint
 ,@entpery_nf      smallint
 ,@esb_cf          UESB_CF
 ,@ganpayord_nt    UPAYORD_NT
 ,@gemprmpay_nf    UCLI_NF
 ,@int_nf          UCLI_NF
 ,@lstupd_d        UUPD_D
 ,@lstupdusr_cf    UUPDUSR_CF
 ,@occyea_nf       smallint
 ,@plc_nt          UPLC_NT
 ,@rcl_nf          UCLM_NF
 ,@retacy_nf       smallint
 ,@retamt_m        UAMT_M
 ,@retautgen_b     bit
 ,@retctr_nf       URETCTR_NF
 ,@retcur_cf       UCUR_CF
 ,@retend_nt       tinyint
 ,@retkey_cf       char(1)
 ,@retoccyea_nf    smallint
 ,@retpay_nf       UCLI_NF
 ,@retrty_nf       UUWY_NF
 ,@retscoendmth_nf tinyint
 ,@retscostrmth_nf tinyint
 ,@retsec_nf       URETSEC_NF
 ,@retuw_nt        tinyint
 ,@rto_nf          UCLI_NF
 ,@scoendmth_nf    tinyint
 ,@scostrmth_nf    tinyint
 ,@sec_nf          USEC_NF
 ,@ssd_cf          USSD_CF
 ,@trncod_cf       UDETTRS_CF
 ,@uw_nt           UUW_NT
 ,@uwy_nf          UUWY_NF
 ,@valpermth_nf    tinyint
 ,@valpery_nf      smallint  -- fin zones TACCSUP
 ,@blcshtyean_nf   smallint  -- BLCSHTYEA_NF normal
 ,@blcshtmthn_nf   tinyint   -- BLCSHTMTH_NF normal
 ,@blcshtyea_nf    smallint  -- BLCSHTYEA_NF exceptionnel
 ,@blcshtmth_nf    tinyint   -- BLCSHTYEA_NF exceptionnel
 ,@specend_d       datetime
 ,@account_d       datetime
 ,@closing_b       bit
 ,@subtrs_hs       UL16    -- zones TSUBTRSH
 ,@SPEENTTYP_CF    tinyint -- MOD01
 ,@SPEENTNAT_CT    tinyint -- MOD02

----------------------------------------------------------------------------------
-- En création
----------------------------------------------------------------------------------
if @p_creation = 1
begin
  -- Recherche de la période de comptabilisation (service) par rapport à la date du jour
  execute @erreur=BREF..PsCALEND_02 @p_date,'C',@blcshtyea_nf output,@blcshtmth_nf output,@specend_d output,@account_d output,@closing_b output
  if @erreur != 0
  begin
    raiserror 20005 "APPLICATIF;TACCSUP/TCALEND"
    return @erreur
  end
end
else
----------------------------------------------------------------------------------
-- En mise à jour
----------------------------------------------------------------------------------
begin
  -- Demande de travaux
  select
    @trn_nt = trn_nt
   ,@acctrn_nt = acctrn_nt
   ,@acctyp_nf = acctyp_nf
   ,@acy_nf = acy_nf
   ,@amt_m = amt_m
   ,@balshey_nf = balshey_nf
   ,@balshrday_nf = balshrday_nf
   ,@balshrmth_nf = balshrmth_nf
   ,@brk_nf = brk_nf
   ,@ced_nf = ced_nf
   ,@clm_nf = clm_nf
   ,@commac_ll = commac_ll
   ,@cre_d = cre_d
   ,@creusr_cf = creusr_cf
   ,@ctr_nf = ctr_nf
   ,@cur_cf = cur_cf
   ,@dbltrncod_cf = dbltrncod_cf
   ,@end_nt = end_nt
   ,@entpermth_nf = entpermth_nf
   ,@entpery_nf = entpery_nf
   ,@esb_cf = esb_cf
   ,@ganpayord_nt = ganpayord_nt
   ,@gemprmpay_nf = gemprmpay_nf
   ,@int_nf = int_nf
   ,@lstupd_d = lstupd_d
   ,@lstupdusr_cf = lstupdusr_cf
   ,@occyea_nf = occyea_nf
   ,@plc_nt = plc_nt
   ,@rcl_nf = rcl_nf
   ,@retacy_nf = retacy_nf
   ,@retamt_m = retamt_m
   ,@retautgen_b = retautgen_b
   ,@retctr_nf = retctr_nf
   ,@retcur_cf = retcur_cf
   ,@retend_nt = retend_nt
   ,@retkey_cf = retkey_cf
   ,@retoccyea_nf = retoccyea_nf
   ,@retpay_nf = retpay_nf
   ,@retrty_nf = retrty_nf
   ,@retscoendmth_nf = retscoendmth_nf
   ,@retscostrmth_nf = retscostrmth_nf
   ,@retsec_nf = retsec_nf
   ,@retuw_nt = retuw_nt
   ,@rto_nf = rto_nf
   ,@scoendmth_nf = scoendmth_nf
   ,@scostrmth_nf = scostrmth_nf
   ,@sec_nf = sec_nf
   ,@ssd_cf = ssd_cf
   ,@trncod_cf = trncod_cf
   ,@uw_nt = uw_nt
   ,@uwy_nf = uwy_nf
   ,@valpermth_nf = valpermth_nf
   ,@valpery_nf = valpery_nf
   ,@SPEENTTYP_CF = SPEENTTYP_CF        -- MOD01
   ,@SPEENTNAT_CT = SPEENTNAT_CT        -- MOD02
   from TACCSUP
    where trn_nt = @p_trn_nt
  select @erreur = @@error
  if @erreur != 0
  begin
    raiserror 20005 "APPLICATIF;TACCSUP"
    return @erreur
  end

  -- Harmonisation des noms 'période de saisie' avec mode création
  select @blcshtmth_nf = @ENTPERMTH_NF, @blcshtyea_nf = @ENTPERY_NF

  -- Libellé poste comptable
  select @subtrs_hs = t2.subtrs_hs
   from BREF..TDETTRS t1, BREF..TSUBTRSH t2
    where t1.dettrs_cf = @trncod_cf
      and t1.pcptrs_cf = t2.pcptrs_cf
      and t1.trs_cf = t2.trs_cf
      and t1.subtrs_cf = t2.subtrs_cf
      and t1.opn_b = 1
      and t2.ssd_cf = @ssd_cf
  select @erreur = @@error
  if @erreur != 0
  begin
    raiserror 20005 "APPLICATIF;TSUBTRSH" /* erreur de lecture */
    return @erreur
  end
end

----------------------------------------------------------------------------------
-- select final
----------------------------------------------------------------------------------
select
  @TRN_NT TRN_NT
 ,@ACCTRN_NT ACCTRN_NT
 ,@ACCTYP_NF ACCTYP_NF
 ,@ACY_NF ACY_NF
 ,@AMT_M AMT_M
 ,@BALSHEY_NF BALSHEY_NF
 ,@BALSHRDAY_NF BALSHRDAY_NF
 ,@BALSHRMTH_NF BALSHRMTH_NF
 ,@BRK_NF BRK_NF
 ,@CED_NF CED_NF
 ,@CLM_NF CLM_NF
 ,@COMMAC_LL COMMAC_LL
 ,@CRE_D CRE_D
 ,@CREUSR_CF CREUSR_CF
 ,substring(@CTR_NF,3,7) CTR_NF
 ,@CUR_CF CUR_CF
 ,@DBLTRNCOD_CF DBLTRNCOD_CF
 ,@END_NT END_NT
 ,@blcshtmth_nf ENTPERMTH_NF
 ,@blcshtyea_nf ENTPERY_NF
 ,@ESB_CF ESB_CF
 ,@GANPAYORD_NT GANPAYORD_NT
 ,@GEMPRMPAY_NF GEMPRMPAY_NF
 ,@INT_NF INT_NF
 ,@LSTUPD_D LSTUPD_D
 ,@LSTUPDUSR_CF LSTUPDUSR_CF
 ,@OCCYEA_NF OCCYEA_NF
 ,@PLC_NT PLC_NT
 ,@RCL_NF RCL_NF
 ,@RETACY_NF RETACY_NF
 ,@RETAMT_M RETAMT_M
 ,@RETAUTGEN_B RETAUTGEN_B
 ,substring(@RETCTR_NF,3,7) RETCTR_NF
 ,@RETCUR_CF RETCUR_CF
 ,@RETEND_NT RETEND_NT
 ,@RETKEY_CF RETKEY_CF
 ,@RETOCCYEA_NF RETOCCYEA_NF
 ,@RETPAY_NF RETPAY_NF
 ,@RETRTY_NF RETRTY_NF
 ,@RETSCOENDMTH_NF RETSCOENDMTH_NF
 ,@RETSCOSTRMTH_NF RETSCOSTRMTH_NF
 ,@RETSEC_NF RETSEC_NF
 ,@RETUW_NT RETUW_NT
 ,@RTO_NF RTO_NF
 ,@SCOENDMTH_NF SCOENDMTH_NF
 ,@SCOSTRMTH_NF SCOSTRMTH_NF
 ,@SEC_NF SEC_NF
 ,@SSD_CF SSD_CF
 ,@TRNCOD_CF TRNCOD_CF
 ,@UW_NT UW_NT
 ,@UWY_NF UWY_NF
 ,@VALPERMTH_NF VALPERMTH_NF
 ,@VALPERY_NF VALPERY_NF
 ,@subtrs_hs TRNCOD_LB
 ,@p_creation creation
 ,@SPEENTTYP_CF SPEENTTYP_CF --  MOD01
 ,@SPEENTNAT_CT SPEENTNAT_CT -- MOD02

return 0
go
if object_id('dbo.PsACCSUP_01') is not null
  print '<<< CREATED PROC dbo.PsACCSUP_01 >>>'
else
  print '<<< FAILED CREATING PROC dbo.PsACCSUP_01 >>>'
go
grant execute on dbo.PsACCSUP_01 TO GOMEGA
go
