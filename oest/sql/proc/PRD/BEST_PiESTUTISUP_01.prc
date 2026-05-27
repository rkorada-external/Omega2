USE BEST
go
/*
 * DROP PROC dbo.PiESTUTISUP_01
 */
IF OBJECT_ID('dbo.PiESTUTISUP_01') IS NOT NULL
BEGIN
    DROP PROC dbo.PiESTUTISUP_01
    PRINT '<<< DROPPED PROC dbo.PiESTUTISUP_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiESTUTISUP_01
     (
    @p_ACCTYP_NF       tinyint,
    @p_SSD_CF          USSD_CF,
    @p_ESB_CF          UESB_CF,
    @p_ENTPERY_NF	  smallint,
    @p_ENTPERMTH_NF    tinyint,
    @p_BALSHEY_NF      smallint,
    @p_BALSHRMTH_NF    tinyint,
    @p_BALSHRDAY_NF    tinyint,
    @p_VALPERY_NF      smallint,
    @p_VALPERMTH_NF    tinyint,
    @p_TRNCOD_CF       UDETTRS_CF,
    @p_DBLTRNCOD_CF	  UDETTRS_CF,
    @p_RETAUTGEN_B	  bit,
    @p_CTR_NF	     	  UCTR_NF,
    @p_END_NT	     	  UEND_NT,
    @p_SEC_NF	     	  USEC_NF,
    @p_UWY_NF          UUWY_NF,
    @p_UW_NT           UUW_NT,
    @p_OCCYEA_NF	  smallint,
    @p_ACY_NF          smallint,
    @p_SCOSTRMTH_NF    tinyint,
    @p_SCOENDMTH_NF    tinyint,
    @p_CLM_NF          UCLM_NF,
    @p_CUR_CF          UCUR_CF,
    @p_AMT_M           UAMT_M,
    @p_CED_NF          UCLI_NF,
    @p_BRK_NF          UCLI_NF,
    @p_GEMPRMPAY_NF    UCLI_NF,
    @p_GANPAYORD_NT    UPAYORD_NT,
    @p_RETCTR_NF       URETCTR_NF,
    @p_RETEND_NT	  UEND_NT,
    @p_RETSEC_NF       URETSEC_NF,
    @p_RTY_NF 	  UUWY_NF,
    @p_RETUW_NT	  UUW_NT,
    @p_PLC_NT		  UPLC_NT,
    @p_RETOCCYEA_NF    UUWY_NF,
    @p_RETACY_NF	  UUWY_NF,
    @p_RETSCOSTRNTH_NF tinyint,
    @p_RETSCOENDMTH_NF tinyint,
    @p_RCL_NF		  UCLM_NF,
    @p_RETCUR_CF	  UCUR_CF,
    @p_RETAMT_M	  UAMT_M,
    @p_RTO_NF		  UCLI_NF,
    @p_INT_NF		  UCLI_NF,
    @p_RETPAY_NF	  UCLI_NF,
    @p_RETKEY_CF	  char(1),
    @p_ACCTRN_NT	  numeric(10,0),
    @p_COMMAC_LL 	  UL64,
       @p_erreur       varchar(64)
     )
as


/***************************************************

Programme: PiESTUTISUP_01

Fichier script associé : ESIUTSUP.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur:Patrick de BOELPAEP 

Date de creation: 28/05/1998

Description du programme: 

      Insertion d'enregistrement dans BTRAV..TESTUTISUP

Parametres: 
    @p_ACCTYP_NF       tinyint,
    @p_SSD_CF          USSD_CF,
    @p_ESB_CF   UESB_CF,
    @p_ENTPERY_NF	smallint,
    @p_ENTPERMTH_NF    tinyint,
    @p_BALSHEY_NF      smallint,
    @p_BALSHRMTH_NF    tinyint,
    @p_BALSHRDAY_NF    tinyint,
    @p_VALPERY_NF      smallint,
    @p_VALPERMTH_NF    tinyint,
    @p_TRNCOD_CF       UDETTRS_CF,
    @p_DBLTRNCOD_CF	UDETTRS_CF,
    @p_RETAUTGEN_B	bit,
    @p_CTR_NF	     UCTR_NF,
    @p_END_NT	     UEND_NT,
    @p_SEC_NF	     USEC_NF,
    @p_UWY_NF          UUWY_NF,
    @p_UW_NT           UUW_NT,
    @p_OCCYEA_NF	  smallint,
    @p_ACY_NF          smallint,
    @p_SCOSTRMTH_NF    tinyint,
    @p_SCOENDMTH_NF    tinyint,
    @p_CLM_NF          UCLM_NF,
    @p_CUR_CF          UCUR_CF,
    @p_AMT_M           UAMT_M,
    @p_CED_NF          UCLI_NF,
    @p_BRK_NF       UCLI_NF,
    @p_GEMPRMPAY_NF    UCLI_NF,
    @p_GANPAYORD_NT    UPAYORD_NT,
    @p_RETCTR_NF       URETCTR_NF,
    @p_RETEND_NT	  UEND_NT,
    @p_RETSEC_NF       URETSEC_NF,
    @p_RTY_NF 	  UUWY_NF,
    @p_RETUW_NT	  UUW_NT,
    @p_PLC_NT		  UPLC_NT,
    @p_RETOCCYEA_NF    UUWY_NF,
    @p_RETACY_NF	  UUWY_NF,
    @p_RETSCOSTRNTH_NF tinyint,
    @p_RETSCOENDMTH_NF tinyint,
    @p_RCL_NF		  UCLM_NF,
    @p_RETCUR_CF	  UCUR_CF,
    @p_RETAMT_M	  UAMT_M
    @p_RTO_NF		  UCLI_NF,
    @p_INT_NF		  UCLI_NF,
    @p_RETPAY_NF	  UCLI_NF,
    @p_RETKEY_CF	  char(1),
    @p_ACCTRN_NT	  numeric(10,0),
    @p_COMMAC_LL 	  UL64

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1
Auteur:         M.DJELLOULI 
Date:           27/04/2005
Version:        5.1
Description:    SPOT 11445  - EST_ESID0801_TESTUTISUP remplace TESTUTISUP

*****************************************************/

declare @erreur int,
        @tran_imbr	bit,
	 @nb_lig int   /* numéro de l'écriture créée  */

select @erreur = 0
select @tran_imbr = 1		 		
if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end 


/* maj numéro de la ligne de participation variable créée */	

   Select @nb_lig = max(TRN_NT)+1 
   from BTRAV..EST_ESID0801_TESTUTISUP

	select @erreur = @@error
  	if @erreur!= 0
		goto fin	


/* init nb_lig si aucun enreg. */

  If @nb_lig is null
	select @nb_lig = 1 


/* Insertion dans BTRAV..TESTUTISUP */

insert into BTRAV..EST_ESID0801_TESTUTISUP
      (
    TRN_NT,
    ACCTYP_NF,
    SSD_CF,
    ESB_CF,
    ENTPERY_NF,
    ENTPERMTH_NF,
    BALSHEY_NF,
    BALSHRMTH_NF,
    BALSHRDAY_NF,
    VALPERY_NF,
    VALPERMTH_NF,
    TRNCOD_CF,
    DBLTRNCOD_CF,
    RETAUTGEN_B,
    CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
    UW_NT,
    OCCYEA_NF,
    ACY_NF,
    SCOSTRMTH_NF,
    SCOENDMTH_NF,
    CLM_NF,
    CUR_CF,
    AMT_M,
    CED_NF,
    BRK_NF,
    GEMPRMPAY_NF,
    GANPAYORD_NT,
    RETCTR_NF,
    RETEND_NT,
    RETSEC_NF,
    RTY_NF,
    RETUW_NT,
    PLC_NT,
    RETOCCYEA_NF,
    RETACY_NF,
    RETSCOSTRMTH_NF,
    RETSCOENDMTH_NF,
    RCL_NF,
    RETCUR_CF,
    RETAMT_M,
    RTO_NF,
    INT_NF,
    RETPAY_NF,
    RETKEY_CF,
    ACCTRN_NT,
    COMMAC_LL,
    CRE_D,
    CREUSR_CF,
    LSTUPD_D,
    LSTUPDUSR_CF 
      )
 values
      (
    @nb_lig,
    @p_ACCTYP_NF,
    @p_SSD_CF,
    @p_ESB_CF,
    @p_ENTPERY_NF,
    @p_ENTPERMTH_NF,
    @p_BALSHEY_NF,
    @p_BALSHRMTH_NF,
    @p_BALSHRDAY_NF,
    @p_VALPERY_NF,
    @p_VALPERMTH_NF,
    @p_TRNCOD_CF,
    @p_DBLTRNCOD_CF,
    @p_RETAUTGEN_B,
    @p_CTR_NF,
    @p_END_NT,
    @p_SEC_NF,
    @p_UWY_NF,
    @p_UW_NT,
    @p_OCCYEA_NF,
    @p_ACY_NF,
    @p_SCOSTRMTH_NF,
    @p_SCOENDMTH_NF,
    @p_CLM_NF,
    @p_CUR_CF,
    @p_AMT_M,
    @p_CED_NF,
    @p_BRK_NF,
    @p_GEMPRMPAY_NF,
    @p_GANPAYORD_NT,
    @p_RETCTR_NF,
    @p_RETEND_NT,
    @p_RETSEC_NF,
    @p_RTY_NF,
    @p_RETUW_NT,
    @p_PLC_NT,
    @p_RETOCCYEA_NF,
    @p_RETACY_NF,
    @p_RETSCOSTRNTH_NF,
    @p_RETSCOENDMTH_NF,
    @p_RCL_NF,
    @p_RETCUR_CF,
    @p_RETAMT_M,
    @p_RTO_NF,
    @p_INT_NF,
    @p_RETPAY_NF,
    @p_RETKEY_CF,
    @p_ACCTRN_NT,
    @p_COMMAC_LL,
    Getdate(),
    user,
    Getdate(),
    user
      )

select @erreur = @@error
if @@transtate = 2
  begin
   select @p_erreur = "ERREUR TRIGGER"
   goto fin
  end

if @erreur != 0 
  begin 
   if @erreur = 2601
 	   select @p_erreur = "20002 APPLICATIF;2601;"   /* cle dupliquée */
   else
 	   select @p_erreur = "20001 APPLICATIF;" + convert(varchar(10),@erreur) + ";"

   goto fin
  end

if @tran_imbr = 0
   COMMIT TRAN

return 0

fin:
if @tran_imbr = 0
   ROLLBACK TRAN

return @erreur

go
IF OBJECT_ID('dbo.PiESTUTISUP_01') IS NOT NULL
    PRINT '<<< CREATED PROC dbo.PiESTUTISUP_01 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROC dbo.PiESTUTISUP_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiESTUTISUP_01
 */
GRANT EXECUTE ON dbo.PiESTUTISUP_01 TO GOMEGA
go

