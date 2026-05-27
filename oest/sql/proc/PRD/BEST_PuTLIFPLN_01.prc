USE BEST
go
IF OBJECT_ID('dbo.PuTLIFPLN_01') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PuTLIFPLN_01
    IF OBJECT_ID('dbo.PuTLIFPLN_01') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PuTLIFPLN_01 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PuTLIFPLN_01 >>>'
END
go
/*
 * creation de la procedure
*/

create procedure PuTLIFPLN_01
     (
       @p_TRN_NT          numeric   ,
       @p_ACCTYP_NF       tinyint   ,
       @p_SSD_CF          USSD_CF   ,
       @p_ESB_CF          UESB_CF   ,
       @p_PLAN_NF         numeric(10,0)   , --MOD0004
       @p_BALSHEY_NF      smallint  ,
       @p_BALSHRMTH_NF    tinyint   ,
       @p_BALSHRDAY_NF    tinyint   ,
       @p_TRNCOD_CF       UDETTRS_CF,
       @p_DBLTRNCOD_CF    UDETTRS_CF,
       @p_CTR_NF          UCTR_NF   ,
       @p_END_NT          UEND_NT   ,
       @p_SEC_NF          USEC_NF   ,
       @p_UWY_NF          UUWY_NF   ,
       @p_UW_NT           UUW_NT    ,
       @p_OCCYEA_NF       smallint  ,
       @p_ACY_NF          smallint  ,
       @p_SCOSTRMTH_NF    tinyint   ,
       @p_SCOENDMTH_NF    tinyint   ,
       @p_CUR_CF          UCUR_CF   ,
       @p_AMT_M           UAMT_M    ,
       @p_CED_NF          UCLI_NF   ,
       @p_BRK_NF          UCLI_NF   ,
       @p_GEMPRMPAY_NF    UCLI_NF   ,
       @p_GANPAYORD_NT    UPAYORD_NT,
       @p_RETCTR_NF       URETCTR_NF,
       @p_RETEND_NT       tinyint   ,
       @p_RETSEC_NF       URETSEC_NF,
       @p_RETRTY_NF       UUWY_NF   ,
       @p_RETUW_NT        tinyint   ,
       @p_PLC_NT          UPLC_NT   ,
       @p_RETOCCYEA_NF    smallint  ,
       @p_RETACY_NF       smallint  ,
       @p_RETSCOSTRMTH_NF tinyint   ,
       @p_RETSCOENDMTH_NF tinyint   ,
       @p_RETCUR_CF       UCUR_CF   ,
       @p_RETAMT_M        UAMT_M    ,
       @p_RTO_NF          UCLI_NF   ,
       @p_INT_NF          UCLI_NF   ,
       @p_RETPAY_NF       UCLI_NF   ,
       @p_RETKEY_CF       char(1)   ,
       @p_COMMAC_LL       UL64      ,
      @p_lstupd_d     UUPD_D=NULL output,
       @p_lstupdusr_cf     UUPDUSR_CF=NULL output,
        @p_ret		     char(64) = NULL output,
      @p_erreur       varchar(64)=NULL output,
	   @p_POSTBPC_B		  bit --MOD0003
     )
as

/***************************************************

Programme: PuTLIFPLN_01

Fichier script associé : ESUSUP01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME57

Date de creation:

Description du programme:

      Modification d'enregistrement dansTLIFPLN

Parametres:
       --@p_trn_nt              numeric,
       @p_acctyp_nf           tinyint,
       @p_acy_nf              smallint,
       @p_amt_m               UAMT_M,
       @p_balshey_nf          smallint,
       @p_balshrday_nf        tinyint,
       @p_balshrmth_nf        tinyint,
       @p_brk_nf              UCLI_NF,
       @p_ced_nf              UCLI_NF,
       @p_commac_ll           UL64,
       @p_ctr_nf              UCTR_NF,
       @p_cur_cf              UCUR_CF,
       @p_dbltrncod_cf        UDETTRS_CF,
       @p_end_nt              UEND_NT,
       @p_esb_cf              UESB_CF,
       @p_ganpayord_nt        UPAYORD_NT,
       @p_gemprmpay_nf        UCLI_NF,
       @p_int_nf              UCLI_NF,
       @p_occyea_nf           smallint,
       @p_plc_nt              UPLC_NT,
       @p_retacy_nf           smallint,
       @p_retamt_m            UAMT_M,
       @p_retctr_nf           URETCTR_NF,
       @p_retcur_cf           UCUR_CF,
       @p_retend_nt           tinyint,
       @p_retkey_cf           char(1),
       @p_retoccyea_nf        smallint,
       @p_retpay_nf           UCLI_NF,
       @p_retrty_nf           UUWY_NF,
       @p_retscoendmth_nf     tinyint,
       @p_retscostrmth_nf     tinyint,
       @p_retsec_nf           URETSEC_NF,
       @p_retuw_nt            tinyint,
       @p_rto_nf              UCLI_NF,
       @p_scoendmth_nf        tinyint,
       @p_scostrmth_nf        tinyint,
       @p_sec_nf              USEC_NF,
       @p_ssd_cf              USSD_CF,
       @p_trncod_cf           UDETTRS_CF,
       @p_uw_nt               UUW_NT,
       @p_uwy_nf              UUWY_NF,
      @p_lstupd_d     UUPD_D=NULL output,
       @p_lstupdusr_cf     UUPDUSR_CF=NULL output,
      @p_erreur       varchar(64)=NULL output

Conditions d'execution:


Commentaires:

_________________
MODIFICATION 1

Auteur: LC
Date: 05/01/1999
Version:
Description: retend_nt = 0 / retuw_nt = 1 systématiquement
_________________
MODIFICATION 2

Auteur: M SPAGNOLI

Date: 23/06/2004

Version:

Description: Nouvelle proc qui a étét faite avec la proc existente suivante : PuACCSUP_01
+ Mise en commentaire de la gestion des erreurs spécifique à la non vie.
_________________
MODIFICATION 0003
Auteur: AbdulWaajed Shaikh
Date: 16/09/2014 (DD/MMM/YYYY)
Description: EST48 Changes : new column POSTBPC_B added in table BEST..TLIFPLN. Prefix MOD0003.
_________________
MODIFICATION 0004
Auteur: AbdulWaajed Shaikh
Date: 11/02/2015 (DD/MMM/YYYY)
Description: CR #34454 Changes : datatype of column PLAN_NF changed to numeric from UUWY_NF in table BEST..TLIFPLN. Prefix MOD0004.
*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
        @nbligne  smallint,
        @nbtime  smallint

select @erreur = 0
select @tran_imbr = 1

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end

update TLIFPLN
    set  acctyp_nf = @p_acctyp_nf,
       acy_nf = @p_acy_nf,
       amt_m = @p_amt_m,
       balshey_nf = @p_balshey_nf,
       balshrday_nf = @p_balshrday_nf,
       balshrmth_nf = @p_balshrmth_nf,
       brk_nf = @p_brk_nf,
       ced_nf = @p_ced_nf,
       commac_ll = @p_commac_ll,
       ctr_nf = @p_ctr_nf,
       cur_cf = @p_cur_cf,
       dbltrncod_cf = @p_dbltrncod_cf,
       end_nt = @p_end_nt,
       esb_cf = @p_esb_cf,
       ganpayord_nt = @p_ganpayord_nt,
       gemprmpay_nf = @p_gemprmpay_nf,
       int_nf = @p_int_nf,
       lstupd_d = getdate(),
       lstupdusr_cf = user,
       occyea_nf = @p_occyea_nf,
       plc_nt = @p_plc_nt,
       retacy_nf = @p_retacy_nf,
       retamt_m = @p_retamt_m,
       retctr_nf = @p_retctr_nf,
       retcur_cf = @p_retcur_cf,
--       retend_nt = @p_retend_nt,
       retend_nt = 0,
       retkey_cf = @p_retkey_cf,
       retoccyea_nf = @p_retoccyea_nf,
       retpay_nf = @p_retpay_nf,
       retrty_nf = @p_retrty_nf,
       retscoendmth_nf = @p_retscoendmth_nf,
       retscostrmth_nf = @p_retscostrmth_nf,
       retsec_nf = @p_retsec_nf,
--       retuw_nt = @p_retuw_nt,
       retuw_nt = 1,
       rto_nf = @p_rto_nf,
       scoendmth_nf = @p_scoendmth_nf,
       scostrmth_nf = @p_scostrmth_nf,
       sec_nf = @p_sec_nf,
       ssd_cf = @p_ssd_cf,
       trncod_cf = @p_trncod_cf,
       uw_nt = @p_uw_nt,
       uwy_nf = @p_uwy_nf,
	   postbpc_b = @p_POSTBPC_B, --MOD0003
	   plan_nf = @p_PLAN_NF --MOD0003
	   
   where trn_nt = @p_trn_nt

select @erreur = @@error, @nbligne = @@rowcount

if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0
  begin
   select @p_erreur="20004 APPLICATIF;" + convert(varchar(10), @erreur) + ";"
   goto fin
  end


/*select @p_lstupdusr_cf = lstupdusr_cf,
       @p_lstupd_d = lstupd_d
from TACCSUP
       where trn_nt = @p_trn_nt
select @erreur = @@error, @nbtime = @@rowcount
if @erreur != 0
   select @p_erreur = "20011 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

if @nbligne = 0
  begin
   if @nbtime = 0
     begin
      select @p_erreur = "20012 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
      goto fin
     end
   else
     begin
      select @p_erreur = "20013 APPLICATIF;" + convert(varchar(10),@erreur) + ";"
      goto fin
     end
  end      */

if @tran_imbr = 0
	COMMIT TRAN

return @erreur

fin:
if @tran_imbr = 0
	ROLLBACK TRAN

return @erreur
go

/*
 * fin de la procedure
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

exec sp_SCOR_INSPRC 'ESUSUP01', 'PuTLIFPLN_01', 'BEST', 'ME01'
go
IF OBJECT_ID('dbo.PuTLIFPLN_01') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PuTLIFPLN_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PuTLIFPLN_01 >>>'
go
GRANT EXECUTE ON dbo.PuTLIFPLN_01 TO GOMEGA
go
GRANT EXECUTE ON dbo.PuTLIFPLN_01 TO GDBBATCH
go
