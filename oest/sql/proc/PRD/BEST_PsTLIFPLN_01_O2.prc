USE BEST
go
IF OBJECT_ID('dbo.PsTLIFPLN_01_O2') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PsTLIFPLN_01_O2
    IF OBJECT_ID('dbo.PsTLIFPLN_01_O2') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PsTLIFPLN_01_O2 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PsTLIFPLN_01_O2 >>>'
END
go
create procedure dbo.PsTLIFPLN_01_O2		/* creation de la procedure */
     (
       @p_trn_nt        numeric,
	   @p_lag_cf       char(1),
       @p_creation	    bit)
as

/***************************************************

Programme: PsTLIFPLN_01_O2

Fichier script associé : BEST_PsTLIFPLN_01_O2.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur:M.SPAGNOLI

Date de creation:

Description du programme:

      Sélection d'enregistrement dans TLIFPLN

Parametres:
       @p_trn_nt              numeric,
	 @p_creation		     bit,
	  @p_ssd_cf       USSD_CF,
	 @p_esb_cf       UESB_CF,
 	@p_dir_cf       UDIR_CF,
 	@p_dmn_cf       tinyint

_________________
MODIFICATION 1

Auteur:

Date:

Version:

Description:

_________________
MODIFICATION 2
Auteur:     	T CUER
Date:       	15/02/2012
Description:
O2_SSL_Impact
O2_contract
O2_Column_Label
_________________
MODIFICATION 0003
Auteur: AbdulWaajed Shaikh
Date: 17/09/2014 (DD/MMM/YYYY)
Description: EST48 Changes : new column POSTBPC_B added in table BEST..TLIFPLN. Prefix MOD0003.
_________________
MODIFICATION 0004
Auteur: AbdulWaajed Shaikh
Date: 11/02/2015 (DD/MMM/YYYY)
Description: CR #34454 Changes : datatype of column PLAN_NF changed to numeric from UUWY_NF in table BEST..TLIFPLN. Prefix MOD0004.
*****************************************************/

declare @erreur int,

         @trn_nt              numeric,	/* zones TLIFPLN  */
         @plan_nf             numeric(10,0), --MOD0004
         @acctyp_nf           tinyint,
         @acy_nf              smallint,
         @amt_m               UAMT_M,
         @balshey_nf          smallint,
         @balshrday_nf        tinyint,
         @balshrmth_nf        tinyint,
         @brk_nf              UCLI_NF,
         @ced_nf              UCLI_NF,
         @commac_ll           UL64,
         @cre_d               UUPD_D,
         @creusr_cf           UUPDUSR_CF,
         @ctr_nf              UCTR_NF,
         @cur_cf              UCUR_CF,
         @dbltrncod_cf        UDETTRS_CF,
         @end_nt              UEND_NT,
         @esb_cf              UESB_CF,
         @ganpayord_nt        UPAYORD_NT,
         @gemprmpay_nf        UCLI_NF,
         @int_nf              UCLI_NF,
         @lstupd_d            UUPD_D,
         @lstupdusr_cf        UUPDUSR_CF,
         @occyea_nf           smallint,
         @plc_nt              UPLC_NT,
         @retacy_nf           smallint,
         @retamt_m            UAMT_M,
         @retctr_nf           URETCTR_NF,
         @retcur_cf           UCUR_CF,
         @retend_nt           tinyint,
         @retkey_cf           char(1),
         @retoccyea_nf        smallint,
         @retpay_nf           UCLI_NF,
         @retrty_nf           UUWY_NF,
         @retscoendmth_nf     tinyint,
         @retscostrmth_nf     tinyint,
         @retsec_nf           URETSEC_NF,
         @retuw_nt            tinyint,
         @rto_nf              UCLI_NF,
         @scoendmth_nf        tinyint,
         @scostrmth_nf        tinyint,
         @sec_nf              USEC_NF,
         @ssd_cf              USSD_CF,
         @trncod_cf           UDETTRS_CF,
         @uw_nt               UUW_NT,
         @uwy_nf              UUWY_NF,
	/* fin zones TLIFPLN  */
        @blcshtyean_nf smallint,	/* BLCSHTYEA_NF  normal */
        @blcshtmthn_nf tinyint,		/* BLCSHTMTH_NF  normal */
        @blcshtyea_nf smallint,		/* BLCSHTYEA_NF  exceptionnel */
        @blcshtmth_nf tinyint,		/* BLCSHTYEA_NF   exceptionnel */
        @specend_d   datetime,
        @account_d    datetime,
        @closing_b    bit,
        @date  datetime,

        @subtrs_gs UL16,  /* zones TSUBTRSL  */
		@p_postbpc_b	bit --MOD0003



IF @p_creation = 1				/* En création :   */

BEGIN
/* Recherche de la période de comptabilisation (service) par rapport à la date du jour */
select @date = getdate()

                Execute @erreur = BREF..PsCALEND_02
                @date ,
                'C',
                @blcshtyea_nf output,
                @blcshtmth_nf output,
                @specend_d output,
                @account_d output,
                @closing_b output


if @erreur != 0
	begin
   		raiserror 20005 "APPLICATIF;TACCSUP/TCALEND" /* erreur de lecture */
        	return @erreur
	end


END



ELSE		/* En mise à jour :  */

BEGIN

/* Demande de travaux */
 Select @trn_nt = trn_nt,
       @plan_nf = plan_nf,
        @acctyp_nf = acctyp_nf,
        @acy_nf = acy_nf,
        @amt_m = amt_m,
        @balshey_nf = balshey_nf,
        @balshrday_nf = balshrday_nf,
        @balshrmth_nf = balshrmth_nf,
        @brk_nf = brk_nf,
        @ced_nf = ced_nf,
        @commac_ll = commac_ll,
        @cre_d = cre_d,
        @creusr_cf = creusr_cf,
        @ctr_nf = ctr_nf,
        @cur_cf = cur_cf,
        @dbltrncod_cf = dbltrncod_cf,
        @end_nt = end_nt,
        @esb_cf = esb_cf,
        @ganpayord_nt = ganpayord_nt,
        @gemprmpay_nf = gemprmpay_nf,
        @int_nf = int_nf,
        @lstupd_d = lstupd_d,
        @lstupdusr_cf = lstupdusr_cf,
        @occyea_nf = occyea_nf,
        @plc_nt = plc_nt,
        @retacy_nf = retacy_nf,
        @retamt_m = retamt_m,
        @retctr_nf = retctr_nf,
        @retcur_cf = retcur_cf,
        @retend_nt = retend_nt,
        @retkey_cf = retkey_cf,
        @retoccyea_nf = retoccyea_nf,
        @retpay_nf = retpay_nf,
        @retrty_nf = retrty_nf,
        @retscoendmth_nf = retscoendmth_nf,
        @retscostrmth_nf = retscostrmth_nf,
        @retsec_nf = retsec_nf,
        @retuw_nt = retuw_nt,
        @rto_nf = rto_nf,
        @scoendmth_nf = scoendmth_nf,
        @scostrmth_nf = scostrmth_nf,
        @sec_nf = sec_nf,
        @ssd_cf = ssd_cf,
        @trncod_cf = trncod_cf,
        @uw_nt = uw_nt,
        @uwy_nf = uwy_nf,
		@p_postbpc_b = postbpc_b --MOD0003
   from TLIFPLN
  where trn_nt = @p_trn_nt

select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TACCSUP" /* erreur de lecture */
      return @erreur
   end

/* Libellé poste comptable  */
select	@subtrs_gs 		= t2.subtrs_gs
from	BREF..TDETTRS t1, BREF..TSUBTRSL t2
where	t1.dettrs_cf 	= @trncod_cf
and 	t1.pcptrs_cf 	= t2.pcptrs_cf
and 	t1.trs_cf 		= t2.trs_cf
and 	t1.subtrs_cf 	= t2.subtrs_cf
and 	t1.opn_b 		= 1
and 	t2.lag_cf 		= @p_lag_cf

select @erreur = @@error
   if @erreur != 0
   begin
      raiserror 20005 "APPLICATIF;TSUBTRSL" /* erreur de lecture */
      return @erreur
   end

END

Select 	@TRN_NT 			TRN_NT,									/* Select final :   */
        @PLAN_NF     		PLAN_NF,
        @ACCTYP_NF 			ACCTYP_NF,
        @ACY_NF 			ACY_NF,
        @AMT_M 				AMT_M,
        @BALSHEY_NF 		BALSHEY_NF,
        @BALSHRDAY_NF 		BALSHRDAY_NF,
        @BALSHRMTH_NF 		BALSHRMTH_NF,
        @BRK_NF 			BRK_NF,
        @CED_NF 			CED_NF,
        @COMMAC_LL 			COMMAC_LL,
        @CRE_D 				CRE_D,
        @CREUSR_CF 			CREUSR_CF,
		--Modification 2 ****************
        --substring(@CTR_NF,3,7) CTR_NF,
		@CTR_NF				CTR_NF,
        @CUR_CF 			CUR_CF,
        @DBLTRNCOD_CF 		DBLTRNCOD_CF,
        @END_NT 			END_NT,
        @ESB_CF 			ESB_CF,
        @GANPAYORD_NT 		GANPAYORD_NT,
        @GEMPRMPAY_NF 		GEMPRMPAY_NF,
        @INT_NF 			INT_NF,
        @LSTUPD_D 			LSTUPD_D,
        @LSTUPDUSR_CF 		LSTUPDUSR_CF,
        @OCCYEA_NF 			OCCYEA_NF,
        @PLC_NT 			PLC_NT,
        @RETACY_NF	 		RETACY_NF,
        @RETAMT_M 			RETAMT_M,
        --substring(@RETCTR_NF,3,7) RETCTR_NF,			--MODIFICATION 2
		@RETCTR_NF 			RETCTR_NF,					--MODIFICATION 2
        @RETCUR_CF 			RETCUR_CF,
        @RETEND_NT 			RETEND_NT,
        @RETKEY_CF 			RETKEY_CF,
        @RETOCCYEA_NF 		RETOCCYEA_NF,
        @RETPAY_NF 			RETPAY_NF,
        @RETRTY_NF 			RETRTY_NF,
        @RETSCOENDMTH_NF 	RETSCOENDMTH_NF,
        @RETSCOSTRMTH_NF 	RETSCOSTRMTH_NF,
        @RETSEC_NF 			RETSEC_NF,
        @RETUW_NT 			RETUW_NT,
        @RTO_NF 			RTO_NF,
        @SCOENDMTH_NF 		SCOENDMTH_NF,
        @SCOSTRMTH_NF 		SCOSTRMTH_NF,
        @SEC_NF 			SEC_NF,
        @SSD_CF 			SSD_CF,
        @TRNCOD_CF 			TRNCOD_CF,
        @UW_NT 				UW_NT,
        @UWY_NF 			UWY_NF,
        @subtrs_gs 			SUBTRS_GS, --MODIFICATION 2 @subtrs_hs SUBTRS_HS, 
        @p_creation 		CREATION,
		@p_postbpc_b		POSTBPC_B --MOD0003
		

return 0
go
EXEC sp_procxmode 'dbo.PsTLIFPLN_01_O2', 'unchained'
go
IF OBJECT_ID('dbo.PsTLIFPLN_01_O2') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PsTLIFPLN_01_O2 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PsTLIFPLN_01_O2 >>>'
go
GRANT EXECUTE ON dbo.PsTLIFPLN_01_O2 TO GOMEGA
go
GRANT EXECUTE ON dbo.PsTLIFPLN_01_O2 TO GDBBATCH
go
