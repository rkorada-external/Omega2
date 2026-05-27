USE BSTA
Go
/*
 * Si modification de la proc : supprimer l'option AUTO dans l'auteur
 */
 /* DROP PROC dbo.PiIBNR_01
*/
IF OBJECT_ID('dbo.PiIBNR_01') IS NOT NULL
   BEGIN
   DROP PROC dbo.PiIBNR_01
   PRINT '<<< DROPPED PROC dbo.PiIBNR_01 >>>'
END
go

/*
 * creation de la procedure 
*/

create procedure PiIBNR_01
     (
    @p_ACCTYP_NF       tinyint,
    @p_SSD_CF          USSD_CF,
    @p_ESB_CF          UESB_CF,
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
    @p_OCCYEA_NF	     smallint,
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
    @p_erreur	      varchar(64)=NULL output
     )
as

/***************************************************

Programme: PiIBNR_01

Fichier script associé : ESIBNR01.PRC

Domaine : (ES) Estimation

Base principale : BEST

Version: 1

Auteur: ME01 avec Infotool version 2.0 (L.DEBEVER) 

Date de creation: 

Description du programme: 

      Insertion d'enregistrement dans BSAR..TIBNRSUP

Parametres: 
    @p_ACCTYP_NF       tinyint,
    @p_SSD_CF          USSD_CF,
    @p_ESB_CF          UESB_CF,
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
    @p_BRK_NF          UCLI_NF,
    @p_GEMPRMPAY_NF    UCLI_NF,
    @p_GANPAYORD_NT    UPAYORD_NT,
    @p_erreur	      varchar(64)=NULL output

Conditions d'execution: 


Commentaires:

_________________
MODIFICATION 1

Auteur: 

Date: 

Version:

Description: 

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
   from BSAR..TIBNRSUP

	select @erreur = @@error
  	if @erreur!= 0
		goto fin	


/* init nb_lig si aucun enreg. */

  If @nb_lig is null
	select @nb_lig = 1 

/* Insertion dans BSAR..TIBNRSUP */

insert into BSAR..TIBNRSUP
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
    RETRTY_NF,
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
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
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

/*
 * fin de la procedure 
 */

/*    Insertion dans la table des procedures
 *-------------------------------------------*/

--exec sp_SCOR_INSPRC 'ESIBNR01', 'PiIBNR_01', 'BEST', 'ME01'
--go

IF OBJECT_ID('dbo.PiIBNR_01') IS NOT NULL
   PRINT '<<< CREATED PROC dbo.PiIBNR_01 >>>'
ELSE
   PRINT '<<< FAILED CREATING PROC dbo.PiIBNR_01 >>>'
go
/*
 * Granting/Revoking Permissions on dbo.PiIBNR_01
 */
GRANT EXECUTE ON dbo.PiIBNR_01 TO GOMEGA
go

