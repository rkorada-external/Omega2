USE BEST
go
IF OBJECT_ID('dbo.PiACCSUP_04') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.PiACCSUP_04
    IF OBJECT_ID('dbo.PiACCSUP_04') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.PiACCSUP_04 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.PiACCSUP_04 >>>'
END
go
create procedure PiACCSUP_04(
  @p_ssd_cf USSD_CF,
  @p_usr_cf UUSR_CF,
  @p_batch_mode UL16 = NULL,
  @p_date_d    datetime = NULL)
with execute as caller as 
/***************************************************
Domaine : (ES) Estimation
Base principale : BEST
Auteur: M.NAJI
Date de creation: 06/02/2023

BEST..PiACCSUP_04   @p_ssd_cf=1 , @p_usr_cf='CLA' 

Description du programme:
---------------------------
Contrôles de cohérences lors du chargement massif par fichier d'écritures de service.
Si tout est OK, INSERTion des lignes ds BEST..TACCSUP.
Fonctionnement de la proc : refonte de la proc PiACCSUP_02
----------------------------
[01] 18/08/2022 M.NAJI    :spira 105224 mise à jour des contrôle lors des chargement des AE: période,moi, année post omega et période inventaire 
[02] 05/02/2023 M.NAJI    :spira 108028 refonte de la proc PiACCSUP_02 plus spira 108733 ( correction période IN) 
{03] 16/06/2023 M.NAJI    :SPIRA 109979 correction plantage technique quand ACY < UWY et le tpye de RETSIGSHA_R, ano 2043: contrat ret et autres
{04] 07/08/2023 M.NAJI    :SPIRA 110128 AE - File upload - Improve errors display
{05] 25/08/2023 M.NAJI    :SPIRA 108958 P&C and Life – Create Assistance entries (AE) during Local/Parent extended period 
[06] 04/09/2023 Riyadh    :SPIRA 109065 FRCIFRSBTCH_NT = 1*
[07] 25/08/2023 M.NAJI    :SPIRA 110647 New value for code ANO_CT (estimation)
[08] 11/03/2024 M.NAJI    :SPIRA 111293 Clean TCTRANO, put a SSD parameter in TCTRANO 
[09] 18/03/2024 M.NAJI    :SPIRA 111123 AE with wrong nature and TC
[10] 18/04/2024 M.NAJI	  :SPIRA 111849 The AE amount must be limited by 13 digits
[11] 15/01/2024 M.NAJI	  :SPIRA 112261 L&H- IFRS17 load - Issue with pos end and extended period tests
[12] 18/03/2025 S.behague	:SPIRA 111789 Control/Limit SAS data volume in Omega
[13] 24/03/2025 HR	      :SPIRA 112829 AE : Booking of AE impossible due to error on linked Event / individual claim
[14] 24/03/2025 S.behague	:SPIRA 111789 Control/Limit SAS data volume in Omega
[15] 10/04/2025 HR        :SPIRA 111126 NRT - AE upload - AE booked successfully on Retro contract placement "Commuted" while should be failed
[16] 17/04/2025 HR        :SPIRA 112822 BBNI- impact of AE load
[17] 10/10/2025 S.Behague :US6233 Spira 111627 - L&H-SAS AE load error management (Rollback) + Report spira 112261
[18] 15/10/2025 HR        :US6354 BBNI - Impact of AE load - Spira 112822 - Copie
[20] 04/12/2024 HR        :US7938 PROD-Impossible to load I17 AE on future contracts
[21] 13/01/2026 HR        :US8222 PROD Q4 2025 - impossible to load retro BBNI AE with assumed fac or without any underlying assumed contract
[22] 22/01/2026 HR        :US8023 SERQS - one AE load may create AE on several ssd instead of 1 => abnomalies should be retrieved for all regarded ssd
******************************************************************************************************************************************************/
	
	

CREATE TABLE #TCTRANO_TMP
(
    CTR_NF     UCTR_NF       NULL,
    END_NT     UEND_NT       NULL,
    SEC_NF     USEC_NF       NULL,
    VRS_NF     numeric(10,0) NULL, 
    SSD_CF     USSD_CF       NULL,
    SEGTYP_CT  USEGTYP_CT    DEFAULT '' NULL,
    SEG_NF     USEG_NF       DEFAULT '' NULL,
    ANO_CT     int           NULL,
    NUMLINE_NT int           DEFAULT 0 NULL

)


Declare 
	@MsgAnomalie    varchar(120),
	@NumMsgAnomalie    varchar(120),                                               -- MOD003 Nb Anomalies : Numéros des Erreurs Rencontrées
	@MsgGlobalAnomalie    varchar(240),
    @Post_Omega_Entry_I4I_D                          Char(8) ,
    @Post_Omega_Entry_EBS_D                          Char(8) ,
    @Post_Omega_Entry_I17_D                          Char(8) ,
    @Post_Omega_Yea_I4I_D                            numeric(4,0) ,
    @Post_Omega_Yea_EBS_D                            numeric(4,0) ,
    @Post_Omega_Yea_I17_D                            numeric(4,0) ,
    @Post_Omega_Mth_I4I_D                            numeric(4,0) ,
    @Post_Omega_Mth_EBS_D                            numeric(4,0) ,
    @Post_Omega_Mth_I17_D                            numeric(4,0) ,
    @INV_Entry_I4I_D                                 Char(8) ,
    @INV_Entry_EBS_D                                 Char(8) ,
    @INV_Entry_I17_D                                 Char(8) ,
    @INV_Mth_I4I_D                                   numeric(4,0) ,
    @INV_Mth_EBS_D                                   numeric(4,0) ,
    @INV_Mth_I17_D                                   numeric(4,0) ,
    @INV_Yea_I4I_D                                   numeric(4,0) ,
    @INV_Yea_EBS_D                                   numeric(4,0) ,
    @INV_Yea_I17_D                                   numeric(4,0) ,
    @P_SuffixeTable                                 char(1) ,
    @blcshtyea_nf smallint ,
    @blcshtmth_nf tinyint ,
    @balshtmth_nf tinyint ,
    @spcend_d    datetime, 
    @account_d    datetime, 
    @closing_b    bit ,
    @NORME varchar(20),
    @Verif_d      datetime,
    @entpery_nf   smallint, /* année de saisie */
    @entpermth_nf   tinyint  ,/* mois de saisie */
    @DateInventaireConso   Char(8),   -- Date Libelle Inventaire Pour Saisie Ecriture Conso & Social (Periode T-1)
    @PeriodeConsoAA     numeric(4,0), -- Periode AAAA Pour Saisie Ecriture Conso & Social (Periode T-1)
    @PeriodeConsoMM     numeric(2,0), -- Periode MM Pour Saisie Ecriture Conso & Social (Periode T-1)
	@PeriodeInvAA		numeric(4,0),
	@PeriodeInvMM   	numeric(2,0),
    @DateInventaireService Char(8),    -- Date Libelle Inventaire Pour Saisie Ecriture Service (Periode T)
    --@cre_d      datetime,
    @p_site_cf   char(4)  ,
	@erreur  int,
	@error_type int ,
	--@p_date_t DateTime ,
	@Last_Booking_I4I_D     			 Char(8)  ,              -- Last Booking IFRS4 Q-1	
	@Last_Booking_EBS_D     			 Char(8)  ,             -- Last Booking EBS Q-1 (New)
	@Last_Booking_17_D      			 Char(8)  ,			        	-- Last Booking IFRS 17 Q-1
	@End_POS_I4I_D          			 Char(8)  ,               -- End date of POS IFRS4 Entry Q  
	@End_POS_EBS_D          			 Char(8)  ,               -- End date of POS EBS Entry Q (New)
	@End_POS_I17_D		    			 Char(8)  ,			          -- End date of POS IFRS17 Entry Q 
	@End_POC_I4I_D          			 Char(8)  ,               -- End date of POC IFRS4 Entry Q-1	 
	@End_POC_EBS_D          			 Char(8)  ,               -- End date of POC EBS Entry Q-1 (New)
	@End_POC_I17_D          			 Char(8)  ,               -- End date of POC IFRS17 Entry Q-1 (New)
	@isEnabledPOSocialEbs 		bit  ,
	@isEnabledPOSocialIfrs17 	bit  ,
	@isEnabledPOSocialIfrs 		bit  ,
	@isEnabledPOConsoIfrs		 bit  ,
	@isEnabledPOConsoEbs 		bit  ,
	@isEnabledPOConsoIfrs17 		bit  ,
	@isEnabledServiceIfrs 				bit  ,
	@isEnabledServiceEbs 				bit  ,
	@isEnabledServiceIfrs17 			bit  ,
	@isEnabledServiceLocal 				bit  ,
	@P_Erreur               			int     ,        -- CodeRetour Erreur pour Message Appli
    @site_cf        varchar(10) ,
    @param1         varchar(20),
	@nbligne_tctrano  int ,
    @tran_imbr    bit,
	@PARM5_MAX   tinyint ,    --  count days of POSX
	@sys_date_d      datetime 
select @tran_imbr = 1 



CREATE  TABLE #EST_ESID0801_TESTUTISUP 
(
    TRN_NT          numeric(10,0) NULL,           
    ACCTYP_NF       tinyint       NULL,
    SSD_CF          tinyint       NULL,
    ESB_CF          tinyint       NULL,
    ENTPERY_NF      smallint      NULL,
    ENTPERMTH_NF    tinyint       NULL,
    BALSHEY_NF      smallint      NOT NULL,
    BALSHRMTH_NF    tinyint       NOT NULL,
    BALSHRDAY_NF    tinyint       NOT NULL,
    VALPERY_NF      smallint      NOT NULL, 
    VALPERMTH_NF    tinyint       NOT NULL,
    TRNCOD_CF       char(8)       NOT NULL,
    DBLTRNCOD_CF    varchar(8)    NULL,
    RETAUTGEN_B     bit           NOT NULL,
    CTR_NF          varchar(9)    NULL,
    END_NT          tinyint       NULL,
    SEC_NF          tinyint       NULL,
    UWY_NF          smallint      NULL,
    UW_NT           tinyint       NULL,
    OCCYEA_NF       smallint      NULL,
    ACY_NF          smallint      NULL,
    SCOSTRMTH_NF    tinyint       NULL,
    SCOENDMTH_NF    tinyint       NULL,
    CLM_NF          int           NULL,
    CUR_CF          varchar(3)    NULL,
    AMT_M           decimal(18,3) NULL,
    CED_NF          int           NULL,
    BRK_NF          int           NULL,
    GEMPRMPAY_NF    int           NULL,
    GANPAYORD_NT    varchar(2)    NULL,
    RETCTR_NF       varchar(9)    NULL,
    RETEND_NT       tinyint       NULL,
    RETSEC_NF       tinyint       NULL,
    RTY_NF          smallint      NULL,
    RETUW_NT        tinyint       NULL,
    PLC_NT          int           NULL,
    RETOCCYEA_NF    smallint      NULL,
    RETACY_NF       smallint      NULL,
    RETSCOSTRMTH_NF tinyint       NULL,
    RETSCOENDMTH_NF tinyint       NULL,
    RCL_NF          int           NULL,
    RETCUR_CF       varchar(3)    NULL,
    RETAMT_M        decimal(18,3) NULL,
    RTO_NF          int           NULL,
    INT_NF          int           NULL,
    RETPAY_NF       int           NULL,
    RETKEY_CF       char(1)       NULL,
    ACCTRN_NT       numeric(10,0) NULL,
    COMMAC_LL       varchar(64)   NULL,
    CRE_D           datetime      NULL,
    CREUSR_CF       varchar(4)    NULL,
    LSTUPD_D        datetime      NULL,
    LSTUPDUSR_CF    varchar(4)    NULL,
    NUMLINE_NT      int           NOT NULL,
    SPEENTTYP_CF    tinyint       NULL,
    SPEENTNAT_CT    tinyint       NULL,
    EVT_NF          varchar(10)   NULL,
    REVT_NF         varchar(10)   NULL,
    CTRSTS_CT       tinyint       NULL,
    RETCTRSTS_CT    int           NULL,
    CTRLOB_CF       char(2)       NULL,
    RETLOB_CF       char(2)       NULL,
    TERCTR_B        int           NULL,
    CLMDET_NF       UCLM_NF       NULL,
    --CLMDET_EVT_NF   UEVT_NF       NULL,
    CHECK_21031     char(2)       NULL,
    GEV_NF          UEVT_NF       NULL,
    SUBEVT_NF       UEVT_NF       NULL,
    SUP_B           int           NULL,
    LOCALAE_CT      int 	      NULL,
    CHECK_307       char(2)       NULL,
    CHECK_21033     char(2)       NULL,
    SECSTS_CT       tinyint       NULL,
    SECACCSTS_CT    tinyint       NULL,
    ACCPLC_B        tinyint       NULL,
    PLCSTS_CT       tinyint       NULL,
    RETSIGSHA_R     USHA_R        NULL,
    LCKCLO_B        tinyint       NULL,
    TYPCTR          char(3)       NULL, 
    TYPRETCTR       char(3)       NULL,
	LIFE_CF			tinyint       NULL,
	OPN_B			tinyint		  NULL,
    CHECK_30020     char(2)       NULL,
    CHECK_24        char(2)       NULL,
    CHECK_25        char(2)       NULL,
    CHECK_106       char(2)       NULL,
	CHECK_21030		char(2)       NULL,
	CHECK_21032		char(2)       NULL,
	CHECK_118		char(2)       NULL,
	CHECK_119		char(2)       NULL,
	CHECK_120		char(2)       NULL,
	CHECK_121		char(2)       NULL,
	CHECK_122		char(2)       NULL,
	CHECK_123	char(2)       NULL,
    FRCIFRSBTCH_NT tinyint null,     --MOD06
	IS_BBNI tinyint DEFAULT 0 NULL   --MOD016
)



if @p_date_d = NULL 
	select @p_date_d =getdate()

select @sys_date_d = getdate()


-- deleting by security anomalies lines
--Normally this is also done in the application when sending the request



INSERT INTO #EST_ESID0801_TESTUTISUP(
	TRN_NT          ,
	ACCTYP_NF       ,
	SSD_CF          ,
	ESB_CF          ,
	ENTPERY_NF      ,
	ENTPERMTH_NF    ,
	BALSHEY_NF      ,
	BALSHRMTH_NF    ,
	BALSHRDAY_NF    ,
	VALPERY_NF      ,
	VALPERMTH_NF    ,
	TRNCOD_CF       ,
	DBLTRNCOD_CF    ,
	RETAUTGEN_B     ,
	CTR_NF          ,
	END_NT          ,
	SEC_NF          ,
	UWY_NF          ,
	UW_NT           ,
	OCCYEA_NF       ,
	ACY_NF          ,
	SCOSTRMTH_NF    ,
	SCOENDMTH_NF    ,
	CLM_NF          ,
	CUR_CF          ,
	AMT_M           ,
	CED_NF          ,
	BRK_NF          ,
	GEMPRMPAY_NF    ,
	GANPAYORD_NT    ,
	RETCTR_NF       ,
	RETEND_NT       ,
	RETSEC_NF       ,
	RTY_NF          ,
	RETUW_NT        ,
	PLC_NT          ,
	RETOCCYEA_NF    ,
	RETACY_NF       ,
	RETSCOSTRMTH_NF ,
	RETSCOENDMTH_NF ,
	RCL_NF          ,
	RETCUR_CF       ,
	RETAMT_M        ,
	RTO_NF          ,
	INT_NF          ,
	RETPAY_NF       ,
	RETKEY_CF       ,
	ACCTRN_NT       ,
	COMMAC_LL       ,
	CRE_D           ,
	CREUSR_CF       ,
	LSTUPD_D        ,
	LSTUPDUSR_CF    ,
	NUMLINE_NT      ,
	SPEENTTYP_CF    ,
	SPEENTNAT_CT    ,
	EVT_NF          ,
	REVT_NF   )      
SELECT *
from BTRAV..EST_ESID0801_TESTUTISUP 
where
    SSD_CF= @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur  création de la table tempo #EST_ESID0801_TESTUTISUP'
    goto ErreurNorm
END



	------------ Temporaire juste pour les TNR----------------------------------------------------------------------

--Execute PiACCSUP_02_TMP @p_ssd_cf,@p_usr_cf

----------------------------------------------------------------------------------


Execute BEST..PdCTRANO_05 @p_usr_cf


-- we remove from btrav..TESTUTISUP all subsidiary lines different from the subsidiary
-- use as parameter, it is normally rarely fall in this case, it means
-- that the user has mistakenly entered several subsidiaries in the file

-- Delete the existing lines from BTRAV..EST_ESID0801_TESTUTISUP with the appropriate subsidiary from input file and last updated usr_cf


DELETE btrav..EST_ESID0801_TESTUTISUP
where
    SSD_CF       != @p_ssd_cf
and LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur  delete  de la table btrav..EST_ESID0801_TESTUTISUP'
    goto ErreurNorm
END


--Select @p_date_t = GetDate(), @cre_d = getdate()
--Select @Verif_d  = GetDate()




-- *************************************************************************************
--
--       FIRST STEP : AUTOMATIC UPDATING IN SOME FIELDS
--
-- *************************************************************************************

-- access to the  BREF..TCALEND table to determinate the entry period
-- -------------------------------------------------------------------

Execute @erreur = BREF..PsCALEND_02
      @p_date_d , --  @cre_d,
      'C',
      @entpery_nf output,
      @entpermth_nf output,
      @spcend_d output,
      @account_d output,
      @closing_b output

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur BREF..PsCALEND_02'
    goto ErreurNorm
END



-- SPOT 16657 JR 29 06 2009    MOD017
-- ---------------------------------------------------------
-- test if we are between the end of exceptional period and the accounting date
-- ---------------------------------------------------------
--[025]
--if (@p_date_t > @spcend_d and @p_date_t <= @account_d)

-- [050]: Checking Exceptional period for non local AE only
If EXISTS (SELECT 1 FROM BTRAV..EST_ESID0801_TESTUTISUP
                    WHERE
                       SPEENTNAT_CT NOT IN (7, 8) AND
                       SSD_CF       = @p_ssd_cf AND
                       LSTUPDUSR_CF = @p_usr_cf)
    begin
        if (convert(Char(10),@p_date_d,112) > convert(Char(10),@spcend_d,112) and convert(Char(10),@p_date_d,112) <= convert(Char(10),@account_d,112) )
            begin
              select @MsgAnomalie = 'Erreur No AEs are allowed before booking'
              goto ErreurNorm 
            end
    end

-- FIN SPOT 16657 JR 29 06 2009      MOD017

----------------------------------------------------------------------------------
    
select  @param1 = convert(varchar,@p_ssd_cf)
execute @erreur = BEST..PsSITE_01 @param1,'2',@site_cf output

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur BEST..PsSITE_01'
    goto ErreurNorm
END


Select 
 @NORME =
CASE
    WHEN SPEENTNAT_CT in (9,10,11)  THEN "IFRS17"
    WHEN SPEENTNAT_CT in (4,5,6)  THEN "EBS"
    WHEN SPEENTNAT_CT in (1,2,3)  THEN "IFRS4"
END
FROM #EST_ESID0801_TESTUTISUP

--Select @p_date_t = getdate()
Select @Verif_d  = GetDate()


				   
If EXISTS (Select 1 FROM btrav..EST_ESID0801_TESTUTISUP
                    where
                       SSD_CF       = @p_ssd_cf
                   and LSTUPDUSR_CF = @p_usr_cf)

   Begin
							   
	Execute @erreur =  BEST..PtREQJOB_I17_05 
		@sys_date_d ,-- @p_date_t               			,
		@site_cf              			,
		@Last_Booking_I4I_D     	output ,              -- Last Booking IFRS4 Q-1	
		@Last_Booking_EBS_D     	output ,             -- Last Booking EBS Q-1 (New)
		@Last_Booking_17_D      	output ,			        	-- Last Booking IFRS 17 Q-1
		@End_POS_I4I_D          	output ,               -- End date of POS IFRS4 Entry Q  
		@End_POS_EBS_D          	output ,               -- End date of POS EBS Entry Q (New)
		@End_POS_I17_D		    	output ,			          -- End date of POS IFRS17 Entry Q 
		@End_POC_I4I_D          	output ,               -- End date of POC IFRS4 Entry Q-1	 
		@End_POC_EBS_D          	output ,               -- End date of POC EBS Entry Q-1 (New)
		@End_POC_I17_D          	output ,               -- End date of POC IFRS17 Entry Q-1 (New)
		@Post_Omega_Entry_I4I_D 	output ,               -- Quarter post omega IFRS4 (New)
		@Post_Omega_Entry_EBS_D 	output ,               -- Quarter post omega EBS (New)
		@Post_Omega_Entry_I17_D 	output ,               -- Quarter post omega IFRS17 (New)
		@Post_Omega_Yea_I4I_D   	output   ,   -- Year post omega IFRS4 (New)
		@Post_Omega_Yea_EBS_D   	output   ,   -- Year post omega EBS (New)
		@Post_Omega_Yea_I17_D   	output   ,   -- Year post omega IFRS17 (New)
		@Post_Omega_Mth_I4I_D   	output    ,  -- Month post omega IFRS4 (New)
		@Post_Omega_Mth_EBS_D   	output  ,    -- Month post omega EBS (New)
		@Post_Omega_Mth_I17_D   	output   ,   -- Month post omega IFRS17 (New)
		@INV_Entry_I4I_D        	output ,               -- Quarter INV IFRS4 (New)
		@INV_Entry_EBS_D        	output ,               -- Quarter INV EBS (New)
		@INV_Entry_I17_D        	output ,               -- Quarter INV IFRS17 (New)
		@INV_Mth_I4I_D          	output   ,  -- Month INV IFRS4 (New)
		@INV_Mth_EBS_D          	output  ,   -- Month INV EBS (New)
		@INV_Mth_I17_D          	output  ,   -- Month INV IFRS17 (New)
		@INV_Yea_I4I_D          	output  ,   -- Year INV IFRS4 (New)
		@INV_Yea_EBS_D          	output  ,   -- Year INV EBS (New)
		@INV_Yea_I17_D          	output   ,  -- Year INV IFRS17 (New)
		@isEnabledPOSocialEbs 		output ,
		@isEnabledPOSocialIfrs17 	output ,
		@isEnabledPOSocialIfrs 		output ,
		@isEnabledPOConsoIfrs		output ,
		@isEnabledPOConsoEbs 		output ,
		@isEnabledPOConsoIfrs17 	output ,
		@isEnabledServiceIfrs 		output ,
		@isEnabledServiceEbs 		output ,
		@isEnabledServiceIfrs17 	output ,
		@isEnabledServiceLocal 		output ,
		@P_SuffixeTable         	output ,               -- Nom de Suffixe de TABLE : '0' si Erreur
		@P_Erreur               	output          -- CodeRetour Erreur pour Message Appli
								   
        select @erreur = @@error


			   
			   
	    Select
		   @DateInventaireConso= CASE
									WHEN @NORME = "IFRS17"  THEN @Post_Omega_Entry_I17_D
									WHEN @NORME = "EBS"   	THEN @Post_Omega_Entry_EBS_D
									WHEN @NORME = "IFRS4"   THEN @Post_Omega_Entry_I4I_D
								 END,
		   @PeriodeConsoAA= 	 CASE
									WHEN @NORME = "IFRS17"  THEN @Post_Omega_Yea_I17_D
									WHEN @NORME = "EBS"   	THEN @Post_Omega_Yea_EBS_D
									WHEN @NORME = "IFRS4"   THEN @Post_Omega_Yea_I4I_D
								END,
		   @PeriodeConsoMM= 	 CASE
									WHEN @NORME = "IFRS17"  THEN @Post_Omega_Mth_I17_D
									WHEN @NORME = "EBS"   	THEN @Post_Omega_Mth_EBS_D
									WHEN @NORME = "IFRS4"   THEN @Post_Omega_Mth_I4I_D
								END,
			-- SPIRA 108733
		   	@PeriodeInvAA= 	 	CASE
									WHEN @NORME = "IFRS17"  THEN @INV_Yea_I17_D
									WHEN @NORME = "EBS"   	THEN @INV_Yea_EBS_D
									WHEN @NORME = "IFRS4"   THEN @INV_Yea_I4I_D
								END,
		   @PeriodeInvMM= 	 	CASE
									WHEN @NORME = "IFRS17"  THEN @INV_Mth_I17_D
									WHEN @NORME = "EBS"   	THEN @INV_Mth_EBS_D
									WHEN @NORME = "IFRS4"   THEN @INV_Mth_I4I_D
								END,	
			-- END SPIRA 108733
		   @DateInventaireService= CASE
									WHEN @NORME = "IFRS17"  THEN @INV_Entry_I17_D
									WHEN @NORME = "EBS"   	THEN @INV_Entry_EBS_D
									WHEN @NORME = "IFRS4"   THEN @INV_Entry_I4I_D
								END
--               @P_Erreur                as 'P_Erreur',
			   
			   

        if @erreur != 0
            begin
              select @MsgAnomalie  = 'Erreur Accès BEST..PtREQJOB_05'
               goto ErreurNorm
            end

        If (@P_SuffixeTable = '0') or (@P_SuffixeTable = Null)
                Begin
                    select @MsgAnomalie = "Erreur Paramètres CONSO/SOCIAL Incorrect" + Convert(Char(5), @P_Erreur)
                    goto ErreurNorm
                End
            Else
                Begin
                  If EXISTS (Select 1 FROM #EST_ESID0801_TESTUTISUP
                                      where
                                           SPEENTNAT_CT not in(1,4,9))   --[23390]
                    Begin
                       Select @entpery_nf = @PeriodeConsoAA
                       Select @entpermth_nf = @PeriodeConsoMM
                       Select @Verif_d = DateAdd(Day, -1, @DateInventaireConso)
                    End
					
                  Else
                    Begin
					   Select @entpery_nf = @PeriodeInvAA
                       Select @entpermth_nf = @PeriodeInvMM
                       Select @Verif_d = DateAdd(Day, -1, @DateInventaireService)
					   
                    End
                End
    End





--select @cre_d = getdate()

-- MN 05
UPDATE  #EST_ESID0801_TESTUTISUP
SET ENTPERY_NF   = @entpery_nf,
  ENTPERMTH_NF = @entpermth_nf,
  CRE_D        = @sys_date_d ,--@cre_d,
  LSTUPD_D     = @sys_date_d ,--@cre_d,
  CREUSR_CF    = @p_usr_cf                  -- MOD012-11/04/2006 CREUSR_CF = "DSK"

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur update #EST_ESID0801_TESTUTISUP / set ENTPERY_NF .....'
    goto ErreurNorm
END




UPDATE #EST_ESID0801_TESTUTISUP
SET SSD_CF = B.SSD_CF,
  ESB_CF = B.ACCESB_CF,
  CED_NF = B.CED_NF,
  BRK_NF = B.PRD_NF,
  GEMPRMPAY_NF = B.GENPRMPAY_NF,
  GANPAYORD_NT = B.GANPAYORD_NT,
  TYPCTR ="FAC",
  CTRSTS_CT = B.CTRSTS_CT
FROM  #EST_ESID0801_TESTUTISUP A, 
    BFAC..TCONTR B
where
    A.CTR_NF        = B.CTR_NF
and A.END_NT        = B.END_NT
and A.UWY_NF        = B.UWY_NF
and A.UW_NT         = B.UW_NT

                        

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 06'
    goto ErreurNorm
END 


UPDATE #EST_ESID0801_TESTUTISUP
SET SSD_CF = B.SSD_CF,
  ESB_CF = B.ACCESB_CF,
  CED_NF = B.CED_NF,
  BRK_NF = B.PRD_NF,
  GEMPRMPAY_NF = B.GENPRMPAY_NF,
  GANPAYORD_NT = B.GANPAYORD_NT,
 TYPCTR ="TRT",
  CTRSTS_CT = B.CTRSTS_CT
FROM  #EST_ESID0801_TESTUTISUP A,
        btrt..TCONTR B
where
    A.CTR_NF       = B.CTR_NF
and A.END_NT       = B.END_NT
and A.UWY_NF       = B.UWY_NF
and A.UW_NT        = B.UW_NT

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 07'
    goto ErreurNorm
END 


UPDATE #EST_ESID0801_TESTUTISUP
SET SSD_CF = B.SSD_CF,
  ESB_CF = B.ESB_CF,
  TYPRETCTR ="RET",
    RETCTRSTS_CT = B.RETCTRSTS_CT,
    TERCTR_B = B.TERCTR_B
FROM  #EST_ESID0801_TESTUTISUP A,
        bret..TRETCTR B
where
     A.RETCTR_NF     = B.RETCTR_NF
and A.RTY_NF        = B.RTY_NF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 08'
    goto ErreurNorm
END 

/********UPDATE FRCIFRSBTCH_NT INFO for TRT/FAC - MOD06******/

UPDATE #EST_ESID0801_TESTUTISUP
SET FRCIFRSBTCH_NT=0

UPDATE #EST_ESID0801_TESTUTISUP
SET FRCIFRSBTCH_NT = 1
FROM #EST_ESID0801_TESTUTISUP T, BTRT..TSECIFRS TS
WHERE    T.CTR_NF      != NULL
and         T.CTR_NF       = TS.CTR_NF
and         T.UWY_NF      = TS.UWY_NF
and         T.END_NT       = TS.END_NT
and         T.UW_NT        = TS.UW_NT
and         T.TYPCTR ="TRT"
and         TS.FRCIFRSBTCH_NT = 1

UPDATE #EST_ESID0801_TESTUTISUP
SET FRCIFRSBTCH_NT = 1
FROM #EST_ESID0801_TESTUTISUP T, BFAC..TSECIFRS TS
WHERE    T.CTR_NF      != NULL
and         T.CTR_NF       = TS.CTR_NF
and         T.UWY_NF      = TS.UWY_NF
and         T.END_NT       = TS.END_NT
and         T.UW_NT        = TS.UW_NT
and         T.TYPCTR ="FAC"
and         TS.FRCIFRSBTCH_NT = 1

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 30'
    goto ErreurNorm
END 

/****************************************************/

UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_24 = "OK"
from #EST_ESID0801_TESTUTISUP A--,  BREF..TCURQUOT B ,  BREF..TEUROCUR C 
where  --( A.CTR_NF != NULL and A.CUR_CF = B.CUR_CF and A.SSD_CF = B.SSD_CF AND A.CUR_CF = C.CUR_CF AND  A.CUR_CF != 'EUR' ) 
    (A.CTR_NF != NULL
and exists( select 1 FROM BREF..TCURQUOT B
                   where  A.CUR_CF = B.CUR_CF
                   and  A.SSD_CF = B.SSD_CF )
and not exists( select 1 FROM BREF..TEUROCUR C
                         where   A.CUR_CF = C.CUR_CF
                         and     A.CUR_CF != 'EUR'  )
   )
--OR   ( A.CTR_NF = NULL OR A.CTR_NF = '')

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 24 1'
    goto ErreurNorm
END

UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_24 = "OK"
where  isnull(CTR_NF,"")  = ""

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 24 2'
    goto ErreurMaj
END


UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_25 = "OK"
from #EST_ESID0801_TESTUTISUP A--,  BREF..TCURQUOT B ,  BREF..TEUROCUR C 
where --( A.RETCTR_NF != NULL and A.RETCUR_CF = B.CUR_CF and A.SSD_CF = B.SSD_CF AND A.RETCUR_CF = C.CUR_CF AND  A.CUR_CF != 'EUR' ) 

    ( A.RETCTR_NF != NULL
and exists( select 1 FROM BREF..TCURQUOT B
                   where  A.RETCUR_CF = B.CUR_CF
                   and  A.SSD_CF = B.SSD_CF )
and not exists(select 1 FROM BREF..TEUROCUR C
                        where   A.RETCUR_CF = C.CUR_CF
                        and     A.RETCUR_CF != 'EUR'  )
   )
--OR ( A.RETCTR_NF = NULL OR A.RETCTR_NF = "")


select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 25 1'
    goto ErreurMaj
END


UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_25 = "OK"
where  isnull(RETCTR_NF,"") = ""

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 25 2'
    goto ErreurMaj
END



UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_21033 = "OK"
 from #EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT      --Mod31
  where  (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")     --Mod31
  and A.REVT_NF = CAST(TCLM.EVT_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF         --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 21033 1'
    goto ErreurMaj
END



UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_21033 = "OK"
 from #EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT      --Mod31
  where (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")           --Mod31
  and A.REVT_NF = "G" + CAST(EVT.GEV_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF        --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 21033 2'
    goto ErreurMaj
END

UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_21033 = "OK"
from #EST_ESID0801_TESTUTISUP A 
 WHERE  (A.REVT_NF is null OR A.RCL_NF is null OR A.REVT_NF is null OR  A.REVT_NF = "")

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 21033 3 '
    goto ErreurMaj
END


UPDATE #EST_ESID0801_TESTUTISUP 
SET CHECK_307 = "OK"
FROM #EST_ESID0801_TESTUTISUP  A
WHERE 
	(SPEENTNAT_CT NOT IN (7,8) OR
    (SPEENTNAT_CT IN (7,8) AND
     TRNCOD_CF IN (SELECT DETTRS_CF
                    FROM BREF..TTRSLNK
                    WHERE
                        ((PRS_CF = 610 AND ACMTRS_NT = 200) and exists (select 1 from BREF..TBANTECESB b where b.SSD_CF = @P_SSD_CF and b.ESB_CF = A.ESB_CF and b.COL_LS='LOCADJLVL_CT' and b.COLVAL_CT in ('1','3'))) OR
                        ((PRS_CF = 605 AND ACMTRS_NT = 300) and exists (select 1 from BREF..TBANTECESB b where b.SSD_CF = @P_SSD_CF and b.ESB_CF = A.ESB_CF and b.COL_LS='LOCADJLVL_CT' and b.COLVAL_CT in ('2','3'))) OR
                        ((PRS_CF = 605 AND ACMTRS_NT = 310) and exists (select 1 from BREF..TBANTECESB b where b.SSD_CF = @P_SSD_CF and b.ESB_CF = A.ESB_CF and b.COL_LS='LOCADJLVL_CT' and b.COLVAL_CT in ('2','3'))) OR
                        ((PRS_CF = 605 AND ACMTRS_NT = 320) and exists (select 1 from BREF..TBANTECESB b where b.SSD_CF = @P_SSD_CF and b.ESB_CF = A.ESB_CF and b.COL_LS='LOCADJLVL_CT' and b.COLVAL_CT in ('2','3'))))))
                        

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 307 '
    goto ErreurMaj
END



UPDATE #EST_ESID0801_TESTUTISUP
SET A.LIFE_CF = B.LIFE_CF 
FROM  	#EST_ESID0801_TESTUTISUP A,  BREF..TESB B
where  	A.SSD_CF   = B.SSD_CF
and 	A.ESB_CF   = B.ESB_Cf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 09'
    goto ErreurMaj
END 


UPDATE #EST_ESID0801_TESTUTISUP
SET A.LOCALAE_CT = B.LOCALAE_CT
FROM  	#EST_ESID0801_TESTUTISUP A,  BREF..TESB B
where  	A.SSD_CF   = B.SSD_CF
and 	A.ESB_Cf   = B.ESB_Cf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 10'
    goto ErreurMaj
END 

UPDATE #EST_ESID0801_TESTUTISUP 
SET CTRLOB_CF =s.LOB_CF,
 SECSTS_CT  =s.SECSTS_CT,
 SECACCSTS_CT=s.SECACCSTS_CT
from #EST_ESID0801_TESTUTISUP  a, btrt..tsection s where
	 a.ctr_nf = s.ctr_nf
 and A.END_NT = s.END_NT
 and a.sec_nf = s.sec_nf
 and a.uwy_nf = s.uwy_nf
 and a.uw_nt = s.uw_nT

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 11'
    goto ErreurMaj
END 

UPDATE #EST_ESID0801_TESTUTISUP 
SET CTRLOB_CF =s.LOB_CF ,
 SECSTS_CT  =s.SECSTS_CT,
 SECACCSTS_CT=s.SECACCSTS_CT
from #EST_ESID0801_TESTUTISUP  a, bfac..tsection s where
	 a.ctr_nf = s.ctr_nf
 and A.END_NT = s.END_NT
 and a.sec_nf = s.sec_nf
 and a.uwy_nf = s.uwy_nf
 and a.uw_nt = s.uw_nT
 
select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 12'
    goto ErreurMaj
END 
select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 13'
    goto ErreurMaj
END 

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 14'
    goto ErreurMaj
END 

UPDATE #EST_ESID0801_TESTUTISUP 
SET RETLOB_CF =s.LOB_CF
from #EST_ESID0801_TESTUTISUP  a, bret..tretsec s where
        a.retctr_nf = s.retctr_nf
 and a.retsec_nf = s.retsec_nf
 and a.rty_nf = s.rty_nf

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 15'
    goto ErreurMaj
END 

-- MN 09
UPDATE #EST_ESID0801_TESTUTISUP
SET OCCYEA_NF = UWY_NF
where
    CTR_NF       != NULL
and OCCYEA_NF    = null


-- MN 10
UPDATE #EST_ESID0801_TESTUTISUP
SET RETOCCYEA_NF = RTY_NF
where
    RETCTR_NF    != NULL
and RETOCCYEA_NF = null


select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 16'
    goto ErreurMaj
END 

-- MN 11
UPDATE #EST_ESID0801_TESTUTISUP
SET a.RTO_NF    = b.RTO_NF,
    a.INT_NF    = b.INT_NF,
    RETPAY_NF = PAY_NF,
    RETKEY_CF = KEY_CF,
    ACCPLC_B  = b.ACCPLC_B,
    PLCSTS_CT = b.PLCSTS_CT,
    RETSIGSHA_R = b.RETSIGSHA_R,
    LCKCLO_B = b.LCKCLO_B
FROM #EST_ESID0801_TESTUTISUP a,
     bret..TPLACEMT b
where
    a.RETCTR_NF = b.RETCTR_NF
    and a.RTY_NF    = b.RTY_NF
    and a.PLC_NT    = b.PLC_NT
    and HIS_B       = 0

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 17'
    goto ErreurMaj
END 


UPDATE #EST_ESID0801_TESTUTISUP
    SET CHECK_30020 = 'OK'
FROM #EST_ESID0801_TESTUTISUP A
where   a.PLC_NT    = NULL
  	AND EXISTS(
        select 1 from BRET..TPLACEMT tpla where tpla.RETCTR_NF = A.RETCTR_NF AND tpla.RTY_NF = A.RTY_NF AND
        (tpla.PLCSTS_CT <> 19 OR
        tpla.RETSIGSHA_R <> 0 )AND
        tpla.HIS_B = 0 AND 
        tpla.ACCPLC_B = 1 )

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 18'
    goto ErreurMaj
END 


 UPDATE #EST_ESID0801_TESTUTISUP
 SET CHECK_30020 = 'OK'
 where PLC_NT !=  NULL
 AND RETCTR_NF != NULL
 AND ( PLCSTS_CT != 19 or RETSIGSHA_R != 0 )
-- AND  HIS_B = 0 
 AND  ACCPLC_B = 1 
 
select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 19'
    goto ErreurMaj
END 

 
UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_30020 = 'OK'
where  RETCTR_NF = NULL  	OR RETCTR_NF = ''
        

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 20'
    goto ErreurMaj
END 


		
-- MN 12        
UPDATE #EST_ESID0801_TESTUTISUP
SET  DBLTRNCOD_CF = CTRSCOD_CF,
	a.OPN_B = b.OPN_B  
FROM #EST_ESID0801_TESTUTISUP a,
     bref..TDETTRS b
where
    b.DETTRS_CF      = a.TRNCOD_CF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 21'
    goto ErreurMaj
END 


-- MN 106
-- potentiel KO 106
UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_106 = "KO"
FROM  #EST_ESID0801_TESTUTISUP A, 
    BFAC..TCONTR B
where
    A.CTR_NF = B.CTR_NF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 22'
    goto ErreurMaj
END 

--remettre à OK ceux qui match avec l'exercice
UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_106 = NULL
FROM  #EST_ESID0801_TESTUTISUP A, 
    BFAC..TCONTR B
where
    A.CTR_NF = B.CTR_NF
AND  A.UWY_NF = B.UWY_NF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 23'
    goto ErreurMaj
END 


-- potentiel KO 106
UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_106 = "KO"
FROM  #EST_ESID0801_TESTUTISUP A, 
    BTRT..TCONTR B
where
    A.CTR_NF = B.CTR_NF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 24'
    goto ErreurMaj
END 

--remettre à OK ceux qui match avec l'exercice
UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_106 = NULL
FROM  #EST_ESID0801_TESTUTISUP A, 
    BTRT..TCONTR B
where
    A.CTR_NF = B.CTR_NF
AND  A.UWY_NF = B.UWY_NF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 25'
    goto ErreurMaj
END 

-- potentiel KO 106
UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_106 = "KO"
FROM  #EST_ESID0801_TESTUTISUP A, 
    BRET..TRETCTR B
where
    A.RETCTR_NF = B.RETCTR_NF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 26'
    goto ErreurMaj
END 

--remettre à OK ceux qui match avec l'exercice
UPDATE #EST_ESID0801_TESTUTISUP
SET CHECK_106 = NULL
FROM  #EST_ESID0801_TESTUTISUP A, 
    BRET..TRETCTR B
where
    A.RETCTR_NF = B.RETCTR_NF
AND  A.RTY_NF = B.RTY_NF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 27'
    goto ErreurMaj
END 


Update #EST_ESID0801_TESTUTISUP
SET CLMDET_NF= CLM.CLMDET_NF ,
      SUBEVT_NF = EVT.SUBEVT_NF,
      GEV_NF = EVT.GEV_NF
from #EST_ESID0801_TESTUTISUP a,
                BCTA..TCLAIM CLM,
                BCTA..TCLMDET CLMDET, 
                BCTA..TEVENT EVT
WHERE 
       EVT.SSD_CF = CLM.SSD_CF 
	     AND  CLM.CLM_NF = a.clm_nf       
       AND  CLM.SSD_CF = a.SSD_CF
       AND  CLM.CLMDET_NF = CLMDET.CLM_NF
       AND  CLMDET.EVT_NF = EVT.SUBEVT_NF
       AND  CLMDET.SSD_CF = EVT.SSD_CF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 28'
    goto ErreurMaj
END 

 -- MN err_21030      
Update #EST_ESID0801_TESTUTISUP       
SET SUP_B =T2.SUP_B 
from #EST_ESID0801_TESTUTISUP A,
    BCTA..TEVTDET T2,
    BCTA..TGRPEVT T7
 WHERE
    T7.GEV_NF = T2.EVT_NF AND
    T7.SSD_CF = T2.SSD_CF AND
    T2.SUP_B = 0 AND
    T2.SSD_CF = 0 AND
    T2.SUP_B = 0 AND
    T2.SSD_CF = 0 AND
  A.EVT_NF = ("G"+CAST( T2.EVT_NF AS VARCHAR(10))) AND
  A.EVT_NF IS NOT NULL AND
  A.EVT_NF <> ""     
       
       
select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur UPDATE #EST_ESID0801_TESTUTISUP 29'
    goto ErreurMaj
END 




--subsidiary event
Update #EST_ESID0801_TESTUTISUP       
SET CHECK_21031 ="OK"
 from #EST_ESID0801_TESTUTISUP A, BCTA..TCLMDET TCLM,BCTA..TCLAIM CLM,BCTA..TEVENT EVT     --Mod31
  where  (A.CLM_NF is not null) and (A.EVT_NF is not null) and  (A.EVT_NF <> "")
  and A.EVT_NF = CAST(TCLM.EVT_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.CLM_NF = CLM.CLM_NF                 --Mod31
    and CLM.CLMDET_NF =  TCLM.CLM_NF     --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF
  and EVT.SSD_CF = CLM.SSD_CF


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to assumed subsidiary events and claims 30"
  goto ErreurAno
end

--group events
Update #EST_ESID0801_TESTUTISUP       
SET CHECK_21031 ="OK"
 from #EST_ESID0801_TESTUTISUP A, BCTA..TCLMDET TCLM,BCTA..TCLAIM CLM,BCTA..TEVENT EVT     --Mod31
  where  (A.CLM_NF is not null) and (A.EVT_NF is not null) and  (A.EVT_NF <> "")
  and A.EVT_NF = "G" + CAST(EVT.GEV_NF AS VARCHAR(10) )
  and A.SSD_CF = TCLM.SSD_CF
  and A.CLM_NF = CLM.CLM_NF                  --Mod31
    and CLM.CLMDET_NF =  TCLM.CLM_NF      --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF
  and EVT.SSD_CF = CLM.SSD_CF


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to assumed group events and claims 31"
  goto ErreurAno
end

-- if the claim is null or the claim is null, there should be no error
Update #EST_ESID0801_TESTUTISUP       
SET CHECK_21031 ="OK"
 from #EST_ESID0801_TESTUTISUP A
 WHERE (A.EVT_NF is null OR A.CLM_NF is null OR A.EVT_NF is null OR  A.EVT_NF = "")

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur Génération TACCSUP1 - Problem linked to assumed and claims 32"
  goto ErreurAno
end

---------------------------------------------------------------------------------------------------------------
--  ERROR 21032 -  Retro Event does not exists 														-- MODIF 30
-- ------------------------------------------------------------------------------------------------------------
-- select "21032", Datediff(MS,@astartTime ,getDate())
-- subsidiary events
Update #EST_ESID0801_TESTUTISUP       
SET CHECK_21032 ="OK"
 from #EST_ESID0801_TESTUTISUP  A, BCTA..TEVENT EVT
  where A.SSD_CF=@p_ssd_cf
    and A.LSTUPDUSR_CF=@p_usr_cf
  and A.REVT_NF is not null
  and A.REVT_NF <> ""
  and A.REVT_NF = CAST( EVT.SUBEVT_NF AS VARCHAR(10))
  and A.SSD_CF = EVT.SSD_CF

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 21032  1 '
    goto ErreurMaj
END 


select  "G"+CAST( T2.EVT_NF AS VARCHAR(10) ) as G_EVT into  #G_EVT
from  
	BCTA..TEVTDET T2,
    BCTA..TGRPEVT T7
where     
	T7.GEV_NF = T2.EVT_NF AND
	T7.SSD_CF = T2.SSD_CF AND
	T2.SUP_B = 0 AND
	T2.SSD_CF = 0 
  

Update #EST_ESID0801_TESTUTISUP       
SET CHECK_21032 ="OK"
from #EST_ESID0801_TESTUTISUP  A,
    #G_EVT G 
WHERE
    A.SSD_CF = @p_ssd_cf AND
    A.LSTUPDUSR_CF = @p_usr_cf and
  A.REVT_NF = G.G_EVT AND
  A.REVT_NF IS NOT NULL AND
  A.REVT_NF <> ""
  
select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 21032 2 '
    goto ErreurMaj
END 

--then if event is null there should be no error
Update #EST_ESID0801_TESTUTISUP       
SET CHECK_21032 ="OK"
from #EST_ESID0801_TESTUTISUP  A
WHERE  A.SSD_CF=@p_ssd_cf
AND A.LSTUPDUSR_CF = @p_usr_cf
and (A.REVT_NF is null OR A.REVT_NF = "")
 
select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 21032 3 '
    goto ErreurMaj
END 

---------------------------------------------------------------------------------------------------
--  ERROR 21030 -  Assumed Event does not exists 								-- MODIF 30
---------------------------------------------------------------------------------------------------
--select "21030", Datediff(MS,@astartTime ,getDate())
-- subsidiary events
Update #EST_ESID0801_TESTUTISUP       
SET CHECK_21030 ="OK"
from #EST_ESID0801_TESTUTISUP  A, BCTA..TEVENT EVT
where A.SSD_CF=@p_ssd_cf
	and A.LSTUPDUSR_CF=@p_usr_cf
	and A.EVT_NF = CAST( EVT.SUBEVT_NF AS VARCHAR(10))
	and A.SSD_CF = EVT.SSD_CF
	and A.EVT_NF IS NOT NULL
	and A.EVT_NF <> ""


select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 21030 1 '
    goto ErreurMaj
END 


Update #EST_ESID0801_TESTUTISUP       
SET CHECK_21030 ="OK"
from #EST_ESID0801_TESTUTISUP  A,
    #G_EVT G
WHERE
	A.SSD_CF = @p_ssd_cf AND
	A.LSTUPDUSR_CF = @p_usr_cf and
	A.EVT_NF = G.G_EVT AND 
	A.EVT_NF IS NOT NULL AND
	A.EVT_NF <> ""

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 21030 2 '
    goto ErreurMaj
END 

Update #EST_ESID0801_TESTUTISUP       
SET CHECK_21030 ="OK"
from #EST_ESID0801_TESTUTISUP  A
WHERE  A.SSD_CF=@p_ssd_cf
AND A.LSTUPDUSR_CF = @p_usr_cf
and (A.EVT_NF is null OR A.EVT_NF = "")    

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check 21030 3 '
    goto ErreurMaj
END 

-------------------------------------------------------------------------------
    
    -- MN 02
    select top 1 @p_site_cf = b.PRDSIT_CF  --, @cre_d = getdate() 
    from bref..TBATCHSSD a, BREF..TBATCHNIGHT b
    where a.BATCHUSER_CF=b.BATCHUSER_CF and a.SSD_CF=@p_SSD_CF

 



select @blcshtmth_nf = blcshtmth_nf+1 from bref..tcalend a
where account_d = (select max(account_d) from bref..tcalend b
                   where account_d <  @sys_date_d ) -- getdate())
				   





-- MN 03
  select @blcshtyea_nf = A.blcshtyea_nf,
     @blcshtmth_nf = A.blcshtmth_nf,            
     
     @spcend_d = A.specend_d,
     @account_d = A.account_d,
     @closing_b = A.closing_b
    from BREF..TCALEND A
      where ((A.blcshtyea_nf * 100) + A.blcshtmth_nf)=(     select min((B.blcshtyea_nf * 100) + B.blcshtmth_nf)
                                                                                from BREF..TCALEND B 
                                                                                where convert(Char(10),B.account_d,112) >= convert(Char(10),@p_date_d,112))



select @blcshtmth_nf = blcshtmth_nf+1 from bref..tcalend a
where account_d = (select max(account_d) from bref..tcalend b
                   where account_d < @sys_date_d ) -- getdate())
                   
                   
                   
                   select @balshtmth_nf = balshtmth_nf from best..treqjob a
where dbclo_d = (select max(dbclo_d) from best..treqjob b
                 where reqcod_ct = 'B'
                 and   site_cf = @p_site_cf
                 and   launch_d is not null)
                 
                 
--print '==> @cre_d = %1! ',  @cre_d
print '==> @sys_date_d = %1! ',  @p_date_d
print '==> @p_date_d = %1! ',  @p_date_d
print '==> @End_POS_I17_D = %1! ',  @End_POS_I17_D
                 
--[05] 
select  @PARM5_MAX=max(convert(int,PARM5)) from BEST..TI17CLOPER
if ( @p_date_d  between convert(date,@End_POS_I17_D) and  dateadd( day, @PARM5_MAX, convert(date,@End_POS_I17_D) )  ) 
BEGIN
    --- Check if all ledgers in upload file are elligible to Extended Local
    Update #EST_ESID0801_TESTUTISUP       
    SET CHECK_118 ="KO"
    from #EST_ESID0801_TESTUTISUP  A, BEST..TI17CLOPER C
    where A.SSD_CF=C.SSD_CF AND
           A.ESB_CF= C.ESB_CF AND
		   A.TRNCOD_CF like '%[KLMN]' AND
           isnull(C.PARM5,'0')  = '0' 
			  
	select @erreur = @@error 
	if @erreur != 0
	BEGIN
		select @MsgAnomalie = 'Erreur check CHECK_118 '
		goto ErreurMaj
	END 

    --la période étendue mais délai atteint 
    Update #EST_ESID0801_TESTUTISUP       
    SET CHECK_119 ="KO"
    from #EST_ESID0801_TESTUTISUP  A, BEST..TI17CLOPER C
    where A.SSD_CF=C.SSD_CF AND
              A.ESB_CF= C.ESB_CF AND
			  A.TRNCOD_CF like '%[KLMN]' AND
              dateAdd( day, convert( int, C.parm5 ), @End_POS_I17_D )  <= @p_date_d --@CRE_D 
	
	select @erreur = @@error
	if @erreur != 0
	BEGIN
		select @MsgAnomalie = 'Erreur check CHECK_119'
		goto ErreurMaj
	END 


    -- Chargement non eligible sur un TrnCode local
    Update #EST_ESID0801_TESTUTISUP       
    SET CHECK_120 ="KO"
    from #EST_ESID0801_TESTUTISUP  A, BEST..TI17CLOPER C
	where A.SSD_CF=C.SSD_CF AND
              A.ESB_CF= C.ESB_CF AND
              C.PARM2 !='1' AND
              A.TRNCOD_CF  like '%[MN]' 
	
	select @erreur = @@error
	if @erreur != 0
	BEGIN
		select @MsgAnomalie = 'Erreur check CHECK_120 '
		goto ErreurMaj
	END 


    -- Chargement non eligible sur un TrnCode Parent
    Update #EST_ESID0801_TESTUTISUP       
    SET CHECK_121 ="KO"
    from #EST_ESID0801_TESTUTISUP  A, BEST..TI17CLOPER C
    where A.SSD_CF=C.SSD_CF AND
              A.ESB_CF= C.ESB_CF AND
              C.PARM1 !='1' AND
              A.TRNCOD_CF  like '%[KL]'  
	
	select @erreur = @@error
	if @erreur != 0
	BEGIN
		select @MsgAnomalie = 'Erreur check CHECK_121'
		goto ErreurMaj
	END 

	
			  
	--  période erronée
	Update #EST_ESID0801_TESTUTISUP       
	SET CHECK_122 ="KO"
	from #EST_ESID0801_TESTUTISUP  A, BEST..TI17CLOPER C
    where A.TRNCOD_CF like '%[KLMN]' AND   
        (A.SPEENTNAT_CT != 10  OR A.BALSHEY_NF*100 +  A.BALSHRMTH_NF != @Post_Omega_Yea_I17_D*100 + @Post_Omega_Mth_I17_D)

	select @erreur = @@error
	if @erreur != 0
	BEGIN
		select @MsgAnomalie = 'Erreur CHECK_122 '
		goto ErreurMaj
	END 

	Update #EST_ESID0801_TESTUTISUP       
	SET CHECK_123 ="KO"
	where  TRNCOD_CF like '%[IJ]' and	
		 (SPEENTNAT_CT != 9 OR 
		  (SPEENTNAT_CT = 9 and BALSHEY_NF*100 +  BALSHRMTH_NF != 
			datepart(Year,dateadd(month,3,@Post_Omega_Entry_I17_D  ))*100 +datepart(month,dateadd(month,3,@Post_Omega_Entry_I17_D)  )
		   )
		 )

	select @erreur = @@error
	if @erreur != 0
	BEGIN
		select @MsgAnomalie = 'Erreur CHECK_123'
		goto ErreurMaj
	END 

 END 


--[05] END 

--[016] [20] BEGIN

Update #EST_ESID0801_TESTUTISUP       
SET IS_BBNI = 1
from #EST_ESID0801_TESTUTISUP  A
    ,BTRT..TSECTION SECTION
   	,BTRT..TCONTR CONTR
where A.SPEENTNAT_CT in (4, 5, 6)
  and (A.RETCTR_NF is null or A.RETCTR_NF = '')  
  and A.CTR_NF=CONTR.CTR_NF     
  and A.END_NT=CONTR.END_NT
  and A.UWY_NF=CONTR.UWY_NF
  and A.UW_NT=CONTR.UW_NT  
  and CONTR.CTRSTS_CT in ( 14, 16, 17, 19) 
  and SECTION.SECSTS_CT in ( 14, 16, 17, 19) 
  and SECTION.CTR_NF=CONTR.CTR_NF     
  and SECTION.END_NT=CONTR.END_NT
  and SECTION.UWY_NF=CONTR.UWY_NF
  and SECTION.UW_NT=CONTR.UW_NT
  and CONTR.CTRLCK_B <> 1
  and CONTR.CTRINC_D > (CONVERT(DATETIME, CAST(A.BALSHEY_NF as VARCHAR(4)) + RIGHT('00' + CAST(A.BALSHRMTH_NF as VARCHAR(2)), 2) + RIGHT('00' + CAST(A.BALSHRDAY_NF as VARCHAR(2)), 2)))

Update #EST_ESID0801_TESTUTISUP       
SET IS_BBNI = 1
from #EST_ESID0801_TESTUTISUP  A
    ,BFAC..TSECTION SECTION
   	,BFAC..TCONTR CONTR
where A.SPEENTNAT_CT in (4, 5, 6) 
  and (A.RETCTR_NF is null or A.RETCTR_NF = '')
  and A.CTR_NF=CONTR.CTR_NF     
  and A.END_NT=CONTR.END_NT
  and A.UWY_NF=CONTR.UWY_NF
  and A.UW_NT=CONTR.UW_NT    
  and CONTR.CTRSTS_CT in ( 14, 16, 18, 19) 
  and SECTION.SECSTS_CT in ( 14, 16, 18, 19) 
  and SECTION.CTR_NF=CONTR.CTR_NF     
  and SECTION.END_NT=CONTR.END_NT
  and SECTION.UWY_NF=CONTR.UWY_NF
  and SECTION.UW_NT=CONTR.UW_NT
  and CONTR.CTRLCK_B <> 0
  and CONTR.CTRINC_D > (CONVERT(DATETIME, CAST(A.BALSHEY_NF as VARCHAR(4)) + RIGHT('00' + CAST(A.BALSHRMTH_NF as VARCHAR(2)), 2) + RIGHT('00' + CAST(A.BALSHRDAY_NF as VARCHAR(2)), 2)))

Update #EST_ESID0801_TESTUTISUP       
SET IS_BBNI = 1
from #EST_ESID0801_TESTUTISUP  A
    ,BTRT..TSECTION SECTION
   	,BTRT..TCONTR CONTR
	,BRET..TRETCTR RETCONTR
where A.SPEENTNAT_CT in (4, 5, 6) 
  and (A.CTR_NF is not null and A.CTR_NF != '' and A.RETCTR_NF is not null and A.RETCTR_NF != '') 
  and A.CTR_NF=CONTR.CTR_NF     
  and A.END_NT=CONTR.END_NT
  and A.UWY_NF=CONTR.UWY_NF
  and A.UW_NT=CONTR.UW_NT    
  and CONTR.CTRSTS_CT in ( 3, 16, 17, 19) 
  and SECTION.SECSTS_CT in ( 14, 16, 17, 19) 
  and SECTION.CTR_NF=CONTR.CTR_NF     
  and SECTION.END_NT=CONTR.END_NT
  and SECTION.UWY_NF=CONTR.UWY_NF
  and SECTION.UW_NT=CONTR.UW_NT
  and CONTR.CTRLCK_B <> 1
  and CONTR.CTRINC_D > (CONVERT(DATETIME, CAST(A.BALSHEY_NF as VARCHAR(4)) + RIGHT('00' + CAST(A.BALSHRMTH_NF as VARCHAR(2)), 2) + RIGHT('00' + CAST(A.BALSHRDAY_NF as VARCHAR(2)), 2)))
  and RETCONTR.RETCTR_NF = A.RETCTR_NF
  and RETCONTR.RTY_NF = A.RTY_NF
  and RETCONTR.TERCTR_B <> 1 
  and RETCONTR.RETCTRSTS_CT in (3, 19)

Update #EST_ESID0801_TESTUTISUP       
SET IS_BBNI = 1
from #EST_ESID0801_TESTUTISUP  A
    ,BFAC..TSECTION SECTION
   	,BFAC..TCONTR CONTR
	,BRET..TRETCTR RETCONTR
where A.SPEENTNAT_CT in (4, 5, 6) 
  and (A.CTR_NF is not null and A.CTR_NF != '' and A.RETCTR_NF is not null and A.RETCTR_NF != '') 
  and A.CTR_NF=CONTR.CTR_NF     
  and A.END_NT=CONTR.END_NT
  and A.UWY_NF=CONTR.UWY_NF
  and A.UW_NT=CONTR.UW_NT    
  and CONTR.CTRSTS_CT in ( 3, 16, 17, 19) 
  and SECTION.SECSTS_CT in ( 14, 16, 17, 19) 
  and SECTION.CTR_NF=CONTR.CTR_NF     
  and SECTION.END_NT=CONTR.END_NT
  and SECTION.UWY_NF=CONTR.UWY_NF
  and SECTION.UW_NT=CONTR.UW_NT
  and CONTR.CTRLCK_B = 1
  and CONTR.CTRINC_D > (CONVERT(DATETIME, CAST(A.BALSHEY_NF as VARCHAR(4)) + RIGHT('00' + CAST(A.BALSHRMTH_NF as VARCHAR(2)), 2) + RIGHT('00' + CAST(A.BALSHRDAY_NF as VARCHAR(2)), 2)))
  and RETCONTR.RETCTR_NF = A.RETCTR_NF
  and RETCONTR.RTY_NF = A.RTY_NF
  and RETCONTR.TERCTR_B <> 1 
  and RETCONTR.RETCTRSTS_CT in (3, 19)
  
Update #EST_ESID0801_TESTUTISUP       
SET IS_BBNI = 1
from #EST_ESID0801_TESTUTISUP  A
	,BRET..TRETCTR RETCONTR
where A.SPEENTNAT_CT in (4, 5, 6) 
  and (A.CTR_NF is null or A.CTR_NF != '') and (A.RETCTR_NF is not null and A.RETCTR_NF != '') 
  and RETCONTR.CTRINCUWY_D > (CONVERT(DATETIME, CAST(A.BALSHEY_NF as VARCHAR(4)) + RIGHT('00' + CAST(A.BALSHRMTH_NF as VARCHAR(2)), 2) + RIGHT('00' + CAST(A.BALSHRDAY_NF as VARCHAR(2)), 2)))
  and RETCONTR.RETCTR_NF = A.RETCTR_NF
  and RETCONTR.RTY_NF = A.RTY_NF
  and RETCONTR.TERCTR_B <> 1 
  and RETCONTR.RETCTRSTS_CT in (3, 19)
  
--[016] [20] END

select A.*  ,
err_000= case when A.SPEENTNAT_CT NOT IN (7, 8) and 
                            convert(Char(10),@p_date_d,112) > convert(Char(10),@spcend_d,112) 
                            and convert(Char(10),@p_date_d,112) <= convert(Char(10),@account_d,112) 
                    then 'Erreur No AEs are allowed before booking'
             end ,
err_19= case  when   SPEENTNAT_CT NOT IN (7,8,9) AND
					(    BALSHEY_NF != ENTPERY_NF
                      OR BALSHRDAY_NF != datepart( dd, dateadd( dd, -1, dateadd( mm, +1, convert( char(6), BALSHEY_NF * 100+ BALSHRMTH_NF ) + '01' ) ) )
                      OR BALSHRMTH_NF < ENTPERMTH_NF            -- MOD003 Vérifier que le Mois de Bilan >= Periode de Bilan En Cours
                      OR ENTPERY_NF = NULL
					  OR ENTPERMTH_NF = NULL      
                                
                    )
                then "Anomalie(s) liee(s) au libelle d''inventaire"
                end ,
err_529= case  when  isdate(convert(char(4),BALSHEY_NF)+ "/" + convert(char(2),BALSHRMTH_NF) + "/" + convert(char(2),BALSHRDAY_NF)) != 1  -- [066] controle validité de date 1 = good
                        then'Bilan origine incorrect'
                        else null
                end ,
--MOD[16]
err_21036= case when A.LIFE_CF=2   
                                    AND (A.TRNCOD_CF LIKE '%[A-Z]' AND NOT (A.TRNCOD_CF LIKE '%G' AND SUBSTRING(A.TRNCOD_CF, 2, 1) IN ('E', 'J')))
                                    AND A.SPEENTNAT_CT NOT IN (9,10,11) --MOD[060]
                            then "Anomalie(s) liee(s) aux  postes comptables"
                    end ,
err_30132 = case  when  A.SPEENTTYP_CF in (8,9) AND A.SPEENTNAT_CT not in (9,10,11)
                            then  "Erreur Génération TACCSUP1 - During check 30132"
                            else NULL
                    end ,
err_30137 = case  when A.TRNCOD_CF not like '%[I-N]' 	AND A.SPEENTTYP_CF in (8,9) 
                            then "Erreur Génération TACCSUP1 - During check 30137"
                    end ,

err_21038 = case when   ACY_NF > BALSHEY_NF  or   RETACY_NF > BALSHEY_NF   
                            then   "A/C year > annee bilan"
                    end,
                    
err_020  =  case when not  (
                                            (
                                                (
                                                    ( --period end of validity >= entry period
                                                        ( VALPERMTH_NF >= DatePart(mm, @Verif_d) and VALPERY_NF = DatePart(yy, @Verif_d) )      -- MOD007
                                                        or ( VALPERY_NF > DatePart(yy, @Verif_d))
													)
													and
													( -- period end of validity <= balance sheet period
														( VALPERMTH_NF >= BALSHRMTH_NF and VALPERY_NF = BALSHEY_NF )
													)
													AND SPEENTNAT_CT NOT IN (7,8) 
												)	
											)	
                                            or  SPEENTNAT_CT in (7,8) /* [CDU] BY-PASS THIS CONTROL FOR LOCAL AE TEMPORARY UNTIL THE CONTROL IS IMPLEMENTED [049] */
                                        )
                         then     'Anomalie(s) liee(s) aux periodes de validite'
                    end ,
err_105  =  case when    DETTRS.DETTRS_CF = null 
                            then  "Erreur Génération TACCSUP1 - Anomalie(s) liee(s) aux  postes comptables"
                    END ,
err_2043_CTR =    case when  isnull(ctr_NF,"")  != "" and isnull(CTRSTS_CT,0) = 22    AND A.LIFE_CF = 1
                       then "Anomalie(s) liee(s) aux  contrats NTU"
                    END ,
err_2043_RET =    case when  isnull(retctr_NF,"")  != "" and isnull(RETCTRSTS_CT,0) = 22  AND  A.LIFE_CF = 1
                       then "Anomalie(s) liee(s) aux  contrats NTU"
                    END ,
---ne pas prendre ceux qui ont err_105
err_33 = case when   NOT (
                                                A.TRNCOD_CF=DETTRS.DETTRS_CF
                                                and DETTRS.OPN_B=1          -- poste open
                                                and (  (A.SPEENTNAT_CT in(4,5,6) and (TRNCOD_CF LIKE '_[EGHJL]%' or TRNCOD_CF LIKE '%G') ) -- EBS MOD029 EBS AE for Solvency (G suffix) should ignore the 2nd prefix test -- MOD033 take into account deposits
                                                    --[09] Si SPEENTNAT in (1,2,3) suffixe ne doit pas être  I,J,K,L,M,N     (IFRS4)
													or (A.SPEENTNAT_CT in(1,2,3) and TRNCOD_CF LIKE '_[4679CNORSUVWXY]%' and TRNCOD_CF not like '%[IJKLMN]')  -- IFRS
													-- [09] Si SPEENTNAT in (9,10,11) suffixe doit être  I,J,K,L,M,N   (IFR
                                                    or (A.SPEENTNAT_CT in(9,10,11) and TRNCOD_CF LIKE '_[456789CNORSUVWXY]%' and TRNCOD_CF like '%[IJKLMN]' )  -- IFRS17
                                                    or (A.SPEENTNAT_CT in(7,8) and TRNCOD_CF LIKE '_[4679CNORSUVWXY]%') ) -- LOCAL IFRS [049]
                                                and (  (CTR_NF!=NULL and RETCTR_NF in(NULL,'') and TRNCOD_CF like '[13]%')
                                                    or (RETCTR_NF!=NULL and TRNCOD_CF like '[24]%') )
                                            )   
                    then "Anomalie(s) liee(s) aux  postes comptables"
                END,
---ne pas prendre ceux qui ont err_105
err_50= case when  A.TRNCOD_CF   = A.DBLTRNCOD_CF  
                      THEN    'Anomalie(s) liee(s) au poste comptable principal = poste de contre-partie'
                      ELSE NULL
             END,
err_49 = case when substring(A.TRNCOD_CF,2,1) in ('5','8') AND ( A.LIFE_CF =2 or (A.LIFE_CF=1 AND SPEENTNAT_CT  NOT IN (9,10,11)))
	THEN 'Anomalie(s) liee(s) aux  postes comptables service' END ,
	
err_46= case when    substring( TRNCOD_CF, 2, 1 ) in ( '7','8','9')          
				and (VALPERMTH_NF != BALSHRMTH_NF or VALPERY_NF != BALSHEY_NF)
			
                    then "Postes Ouvertures : Période Validité <> Période Bilan ! "
                end , 
err_106 = case when CHECK_106 = "KO"
                            then 'Anomalie(s) liee(s) à l''année d''exercice comptable'
                    END,
err_27= case when  RETLOB_CF = null and isnull(retctr_NF,"")  != ""   -- (RETLOB_CF ! ==> match avec TRETSEC )
                     then  ' Contrôle Existance Section Rétro'
            END,
err_28= case when  CTRLOB_CF = null and  isnull(ctr_NF,"")  != ""
                     then "Section acceptation inconnue"
            END,
err_21034= case when  RETCTRSTS_CT  IN (1,2) and  isnull(retctr_NF,"")  != ""
                     then "Anomalie(s) liee(s) aux  postes comptables"
            END,
err_104= case when TERCTR_B !=0  and isnull(RETCTR_NF,"") != ""
                        then "Anomalie(s) liee(s) aux  postes comptables"
                END ,
err_21050 = case when                
                                    A.EVT_NF != ("G"+CAST( GEV_NF AS VARCHAR(10)))
                                AND A.EVT_NF !=  ("G"+CAST( SUBEVT_NF AS VARCHAR(10)))
                                AND A.EVT_NF !=  CAST( SUBEVT_NF AS VARCHAR(10))
                                AND A.CTR_NF !=null
                        then "Cet événement ne correspond pas à ce Sinistre."
                    END ,
err_21030 = case when  CHECK_21030 = null      
				   then "Anomalie(s) liee(s) aux  postes comptables"
				END ,
err_21031 = case when CHECK_21031 = null
                           then  "Anomalie(s) liee(s) aux  postes comptables"
                    END ,
err_21032 = case when CHECK_21032 = null
				then "Anomalie(s) liee(s) aux  postes comptables"
            END ,
err_308 = case when     A.SPEENTNAT_CT in (7,8) AND   A.LOCALAE_CT <= 0 
                      then"Unauthorized Ledger for local "
                      END    ,                                             
err_307 = case when A.CHECK_307 = null
                    then "Anomalie(s) liee(s) aux  postes comptables ES locales"
                END ,
err_300 = case when A.SPEENTNAT_CT IN (7,8) AND A.BALSHEY_NF != A.VALPERY_NF
                       then "Annees de date bilan et de fin de periode de validite doivent etre egales"
                END , 
err_301 = case when A.SPEENTNAT_CT IN (7,8) AND A.BALSHRMTH_NF != A.VALPERMTH_NF
                       then "Mois de date bilan et de fin de periode de validite doivent etre egales"
                END  ,
err_302 = case when A.SPEENTNAT_CT =8 AND A.BALSHRMTH_NF not IN (3, 6, 9, 12)
                       then  "Le mois bilan doit etre un mois de trimestre"
                END  ,
err_303 = case when     A.SPEENTNAT_CT  = 7 AND     ( A.LOCALAE_CT != 1 )
                               then "Cet Etablissement ne peut pas charger d ES locales trimestrielles"
                        END   , 
err_304 = case when     A.SPEENTNAT_CT  = 8 AND    ( A.LOCALAE_CT !=2  )
                               then "Cet Etablissement ne peut pas charger d ES locales mensuelles"
                        END  ,  
err_305 = case when     SPEENTNAT_CT = 7 AND
            (
                (@blcshtmth_nf =  1 AND BALSHRMTH_NF NOT IN (10, 11, 12)) OR
                (@blcshtmth_nf =  2 AND BALSHRMTH_NF NOT IN (10, 11, 12, 1)) OR
                (@blcshtmth_nf =  3 AND BALSHRMTH_NF NOT IN (10, 11, 12, 1, 2)) OR
                (@blcshtmth_nf =  4 AND BALSHRMTH_NF NOT IN (1, 2, 3)) OR
                (@blcshtmth_nf =  5 AND BALSHRMTH_NF NOT IN (1, 2, 3, 4)) OR
                (@blcshtmth_nf =  6 AND BALSHRMTH_NF NOT IN (1, 2, 3 ,4, 5)) OR
                (@blcshtmth_nf =  7 AND BALSHRMTH_NF NOT IN (4, 5, 6)) OR
                (@blcshtmth_nf =  8 AND BALSHRMTH_NF NOT IN (4, 5, 6, 7)) OR
                (@blcshtmth_nf =  9 AND BALSHRMTH_NF NOT IN (4, 5, 6, 7, 8)) OR
                (@blcshtmth_nf = 10 AND BALSHRMTH_NF NOT IN (7, 8, 9)) OR
                (@blcshtmth_nf = 11 AND BALSHRMTH_NF NOT IN (7, 8, 9, 10)) OR
                (@blcshtmth_nf = 12 AND BALSHRMTH_NF NOT IN (7, 8, 9 ,10, 11))
            )
         then 'Anomalie(s) liee(s) au libelle d''inventaire'
        else NULL
    END ,
err_306 = case when  SPEENTNAT_CT = 8 AND BALSHRMTH_NF != @balshtmth_nf
    then "Anomalie(s) liee(s) au libelle d'inventaire"
    END,
err_107 = case when PLC_NT != NULL  and LCKCLO_B = 0
    then "Anomalie(s) liee(s) a l'impact closing"
    END,
err_21033 = case when  CHECK_21033 = null 
	then "Anomalie(s) liee(s) aux  postes comptables"     
	END ,
err_21 = case when isnull( CTR_NF,"")  !=  ""  and  ACY_NF < UWY_NF and  CTRLOB_CF  in ( '30', '31')
    then "Anomalie(s) liee(s) a l'annee de compte acceptation"
    END, 
err_22 = case when isnull( RETCTR_NF,"")  !=  ""  and  RETACY_NF <RTY_NF and  RETLOB_CF  in ( '30', '31')
    then "Anomalie(s) liee(s) a l'annee de compte acceptation"
    END ,
err_48 = case when   
                isnull( CTR_NF,"")  !=  ""  and (SECSTS_CT not in (14, 16, 17, 18, 19) and FRCIFRSBTCH_NT = 0) --MOD06
    then 'Etat section incorrect'
    END ,

err_18 = case when (isnull( CTR_NF,"") !=  "" and CTRLOB_CF= null ) OR 
				   (isnull( RETCTR_NF,"")!=  "" and RETLOB_CF = NULL) then null  -- Quand la section du contrat ASSUMED ou RETRO la lob est nulles , l'erreur 28 est déjà remonté 
			  when isnull( CTR_NF,"")  	!=  "" and isnull( RETCTR_NF,"")="" and A.CTRLOB_CF='30'  and A.TRNCOD_CF like  '3%' then null  --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix)
			--when isnull( CTR_NF,"")  	!=  "" and isnull( RETCTR_NF,"")="" and A.CTRLOB_CF='30'  and A.TRNCOD_CF like  '3%'  then null  --[053] Local AE loading - Incoherence transaction code/lob 
			  when isnull( CTR_NF,"")  	!=  "" and isnull( RETCTR_NF,"")="" and A.CTRLOB_CF='31'  and A.TRNCOD_CF like  '1%' then null  --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix) -- modif 24 pas de poste comptable pour les LOB vie EBS pour le moment
			  when isnull( CTR_NF,"")  	!=  "" and isnull( RETCTR_NF,"")="" and A.CTRLOB_CF!='30' and A.TRNCOD_CF like  '1%'  then null 
			  when isnull( RETCTR_NF,"")!=  "" and A.RETLOB_CF='30'  and A.TRNCOD_CF like  '4%' then null  --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix)
			--when isnull( RETCTR_NF,"")!=  "" and A.RETLOB_CF='30'  and A.TRNCOD_CF like  '4%' then null  --[053] Local AE loading - Incoherence transaction code/lob 
			  when isnull( RETCTR_NF,"")!=  "" and A.RETLOB_CF='31'  and A.TRNCOD_CF like  '2%' then null  --MOD029 EBS AE possible for Life LoBs only for Solvency (G suffix) -- modif 24 pas de poste comptable pour les LOB vie EBS pour le moment
			  when isnull( RETCTR_NF,"")!=  "" and A.RETLOB_CF!='30' and A.TRNCOD_CF like  '2%' then null 
			  else  'Anomalie(s) liee(s) aux  postes comptables'
        END ,
		
err_23 = case when    PLC_NT = NULL or  PLC_NT = 0 or   ( ACCPLC_B = 1 and   PLCSTS_CT  in (16, 19) )
			then null
			else 'CONTROLE DES PLACEMENTS '
    END ,
err_30020 = case when  CHECK_30020 = null
    then 'The placement is disabled for estimates.'
    END ,
err_24 = case when   CHECK_24 = null
    then 'Devise acceptation incorrecte'
    END ,
    
err_25 = case when   CHECK_25 = null
    then "Devise rétro incorrecte"
    END ,
err_47 = case when   SECACCSTS_CT = 9  AND isnull( CTR_NF,"")  !=  "" 
    then 'Affaire terminée comptable'
    END,
--[05]
err_118 = case when  CHECK_118 = 'KO'  
    then 'ledgers not are elligible to Extended Local'
    END ,
err_119 = case when  CHECK_118 = null and CHECK_119 = 'KO'  
    then 'Limit time is eached '
    END ,
err_120 = case when  CHECK_118 = null and CHECK_119 = null and  CHECK_120 = 'KO'  
    then 'Local Transaction code is elligible'
    END ,
err_121 = case when  CHECK_118 = null and CHECK_119 = null and  CHECK_120 = null and CHECK_121 = 'KO' 
    then 'parent Transaction code is elligible'
    END ,
err_122 = case when  CHECK_118 = null and CHECK_119 = null and  CHECK_120 = null and CHECK_121 = null and CHECK_122 = 'KO'
    then 'Period not correct'
    END, 
err_123 = case when   CHECK_118 = null and CHECK_119 = null and  CHECK_120 = null and CHECK_121 = null and CHECK_122 = null and CHECK_123 = 'KO'
    then 'I17G POS not possible '
    END, 
err_812A = case when  isnull(AMT_M,0) > 9999999999999 or 
					  isnull(AMT_M,0) < -9999999999999  
    then 'The value must not exceed the allowed limit (|9 999 999 999 999| §) '
    END	,
err_812R = case when  isnull(RETAMT_M,0) > 9999999999999  or
					  isnull(RETAMT_M,0) < -9999999999999  
    then 'The value must not exceed the allowed limit (|9 999 999 999 999| §) '
    END	,
--[05] END 
--[16] [18] [20] BEGIN
err_20068 = case when A.SPEENTNAT_CT in (4,5,6) and ( NOT (A.LIFE_CF = 2 AND A.IS_BBNI = 1) OR A.LIFE_CF = 1) and A.TRNCOD_CF like '%G' and substring(A.TRNCOD_CF,2,1) in ('E','J')   
    then 'BBNI TC are not authorised on this contract'
    END	,
   
err_20069 = case when A.SPEENTNAT_CT in (4,5,6) and A.LIFE_CF = 2 AND A.IS_BBNI = 1 and (A.TRNCOD_CF not like '%G' or substring(A.TRNCOD_CF,2,1) not in ('E','J'))   
    then 'BBNI contract - Unauthorised transaction'
    END	
--[16] [18] [20] END
   
INTO #EST_TCTRANO_ESID0801_TESTUTISUP
from #EST_ESID0801_TESTUTISUP A
LEFT OUTER JOIN BREF..TESB ESB on  A.SSD_CF=ESB.SSD_CF  AND A.ESB_CF=ESB.ESB_CF
LEFT OUTER JOIN BREF..TDETTRS DETTRS on A.TRNCOD_CF  = DETTRS.DETTRS_CF


--SELECT * from #EST_TCTRANO_ESID0801_TESTUTISUP

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur check insert into EST_TCTRANO_ESID0801_TESTUTISUP '
    goto ErreurMaj
END

--delete BEST..TCTRANO 
--where
--    SSD_CF      = @p_ssd_cf
--and SEG_NF = @p_usr_cf

update #EST_TCTRANO_ESID0801_TESTUTISUP
set
	CTR_NF=ISNULL(CTR_NF, ''), 
	END_NT=ISNULL(END_NT, 0),
	SEC_NF=ISNULL(SEC_NF, 0),  
	--VRS_NF=ISNULL(VRS_NF, 0),
	SSD_CF=ISNULL(SSD_CF, 0)  ,
	--SEGTYP_CT=ISNULL(SEGTYP_CT, ''),
	LSTUPDUSR_CF=ISNULL(LSTUPDUSR_CF, ''),  
	--ANO_CT=ISNULL(ANO_CT, 0),
	NUMLINE_NT=ISNULL(NUMLINE_NT, -1),
	RETCTR_NF=ISNULL(RETCTR_NF, ''),
	RETSEC_NF=ISNULL(RETSEC_NF, 0)


select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur update  EST_TCTRANO_ESID0801_TESTUTISUP '
    goto ErreurMaj
END

--select * from #EST_TCTRANO_ESID0801_TESTUTISUP

select * into #TCTRANO from BEST..TCTRANO where 1=2

INSERT INTO #TCTRANO(
	CTR_NF     ,
	END_NT     ,
	SEC_NF     ,
	VRS_NF     ,
	SSD_CF     ,
	SEGTYP_CT  ,
	SEG_NF     ,
	ANO_CT     ,
	NUMLINE_NT )

--ACCEPT
	  SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 0       , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_000      != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 19      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_19       != NULL --and isnull(CTR_NF,"") != ""
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 529     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_529      != NULL --
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21036   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21036    != NULL --and isnull(CTR_NF,"") != ""
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 30132   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_30132    != NULL --
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 30137   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_30137    != NULL --
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21036	 , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21036bis != NULL-- 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21038   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21038    != NULL --and isnull(CTR_NF,"") != ""
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 020     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_020      != NULL -- 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 105     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_105      != NULL --and isnull(RETCTR_NF,"") = ""
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 2043    , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_2043_CTR != NULL --
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 33      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_33       != NULL --and isnull(CTR_NF,"") != ""
-- UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 50      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_50    != NULL --
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 49      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_49       != NULL --
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 46      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_46       != NULL --  and isnull(CTR_NF,"") != ""
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 106     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_106      != NULL -- and isnull(CTR_NF,"") != ""
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 27      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_27       != NULL -- 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 28      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_28       != NULL --
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21034   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21034  != NULL 
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 104     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_104    != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21050   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21050    != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21030   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21030    != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21031   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21031    != NULL 
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21032   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21032  != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 308     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_308      != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 307     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_307      != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 300     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_300      != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 301     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_301      != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 302     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_302      != NULL 
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 303     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_303    != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 304     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_304      != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 305     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_305      != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 306     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_306      != NULL 
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 107     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_107    != NULL 
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21033   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21033  != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21       != NULL 
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 22      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_22     != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 48      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_48       != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 18      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_18       != NULL   --and isnull(CTR_NF,"") != ""
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 23      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_23     != NULL 
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 30020   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_30020  != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 24      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_24 	  != NULL 
--UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 25      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_25 	  != NULL  
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 47      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_47  	  != NULL 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 812      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_812A  	  != NULL 

--Retro
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21036   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21036    != NULL --and isnull(RETCTR_NF,"") != ""
--UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 19      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_19       != NULL --and isnull(RETCTR_NF,"") != ""
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 2043    , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_2043_RET != NULL --
--UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 105     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_105      != NULL --and isnull(CTR_NF,"") = ""
--UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21038   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21038    != NULL --and isnull(RETCTR_NF,"") != ""
--UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 33      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_33       != NULL --and isnull(RETCTR_NF,"") != ""
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 50      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_50       != NULL --
--UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 46      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_46       != NULL --and isnull(RETCTR_NF,"") != ""
--UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 106     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_106      != NULL --and isnull(RETCTR_NF,"") != ""
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21034   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21034    != NULL --
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 104     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_104      != NULL --
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21032   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21032    != NULL --
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 303     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_303      != NULL --
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 107     , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_107      != NULL --
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 21033   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_21033    != NULL --
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 22      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_22       != NULL --
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 18      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_18       != NULL --and isnull(RETCTR_NF,"") != ""
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 23      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_23       != NULL --
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 30020   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_30020    != NULL 
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 25      , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_25 	  	!= NULL  
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 118   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_118  	!= NULL  
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 119   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_119  	!= NULL  
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 120   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_120  	!= NULL  
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 121   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_121  	!= NULL  
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 122   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_122  	!= NULL  
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 123   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_123  	!= NULL  
UNION SELECT  RETCTR_NF, END_NT, RETSEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 812   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_812R  	!= NULL  
--[16]
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 20068   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_20068  	!= NULL and isnull(CTR_NF,"") != "" 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 20068   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_20068  	!= NULL and isnull(CTR_NF,"") = ""
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 20069   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_20069  	!= NULL and isnull(CTR_NF,"") != "" 
UNION SELECT  CTR_NF, END_NT, SEC_NF, 1, SSD_CF, "A", LSTUPDUSR_CF, 20069   , NUMLINE_NT from #EST_TCTRANO_ESID0801_TESTUTISUP where err_20069  	!= NULL and isnull(CTR_NF,"") = ""

select @erreur = @@error
if @erreur != 0
BEGIN
    select @MsgAnomalie = 'Erreur  insert #TCTRANO'
    goto ErreurMaj
END


-- si le CTR_NF de la table ano est null  on prend le RETCTR_NF
Update #TCTRANO       
SET ANO.CTR_NF =  A.RETCTR_NF     ,
	ANO.END_NT =  A.RETEND_NT ,
	ANO.SEC_NF =  A.RETSEC_NF
from #EST_ESID0801_TESTUTISUP  A, #TCTRANO  ANO
where A.NUMLINE_NT= ANO.NUMLINE_NT
AND   isnull(ANO.CTR_NF,"") = ""
AND   isnull(A.CTR_NF,"") = ""

-- si le CTR de la table ano est null et le RETCTR du fichier est null  on prend le CTR_NF
Update #TCTRANO       
SET ANO.CTR_NF =  A.CTR_NF     ,
	ANO.END_NT =  A.END_NT ,
	ANO.SEC_NF =  A.SEC_NF
from #EST_ESID0801_TESTUTISUP  A, #TCTRANO  ANO
where A.NUMLINE_NT= ANO.NUMLINE_NT
AND   isnull(ANO.CTR_NF,"") = ""
AND   isnull(A.RETCTR_NF,"") = ""


INSERT into BEST..TCTRANO
SELECT DISTINCT * from #TCTRANO 

--{08]
update #TCTRANO SET SSD_CF = @p_ssd_cf


-- on reconduit pas cette règle de l'ancienne version 

	--select distinct * into   #TCTRANO_CLEAN from #TCTRANO where ANO_CT in (105,106 ) 

	-- insert into TCTRANO_CLEAN select * from #TCTRANO 
	-- where NUMLINE_NT not in (select NUMLINE_NT from #TCTRANO where ANO_CT = 105)
	-- and ANO_CT in (33,50  )

	-- insert into TCTRANO_CLEAN select * from #TCTRANO 
	-- where NUMLINE_NT not in (select NUMLINE_NT from #TCTRANO =where ANO_CT = 106 )
	-- and ANO_CT in (,27,28,21034,104)  )
	-- 



/* writing of type 1 */
/* pure acceptance    */
/* ------------------- */
UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 1
where ( CTR_NF != NULL AND CTR_NF != "")
and ( RETCTR_NF = NULL OR RETCTR_NF = "")
--or SPEENTTYP_CF in (8,9)

select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 1 "
goto ErreurMaj
end



/* pure acceptance */
/* pure retro 100%      */
/* ------------------- */

UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 2,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF = NULL OR CTR_NF = "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT = NULL OR PLC_NT = 0)           -- 100%


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 2 "
goto ErreurMaj
end
/* writing of type 3 */
/* acceptance and retro 100%*/
/* ------------------- */


UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 3,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF != NULL AND CTR_NF != "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT = NULL OR PLC_NT = 0)      -- 100%


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 3 "
goto ErreurMaj
end

/* Writing of type 4 */
/* REtro pure à la part */
/* ------------------- */

UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 4,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF = NULL OR CTR_NF = "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT != NULL AND PLC_NT != 0)


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 4 "
goto ErreurMaj
end
/* writing of type 5 */
/* Accept et rétro à la part */
/* ------------------- */

UPDATE #EST_ESID0801_TESTUTISUP
SET ACCTYP_NF = 5,
  AMT_M = RETAMT_M,
  CUR_CF = RETCUR_CF
where ( CTR_NF != NULL AND CTR_NF != "")
and ( RETCTR_NF != NULL AND RETCTR_NF != "")
and ( PLC_NT != NULL AND PLC_NT != 0)


select @erreur = @@error
if @erreur != 0
begin
  select @MsgAnomalie = "Erreur UPDATE TACCSUP1 - 3eme Etape - Ecriture de TYPE 5 "
goto ErreurMaj
end
Update #EST_ESID0801_TESTUTISUP
   set ENTPERY_NF = BALSHEY_NF
      ,ENTPERMTH_NF = BALSHRMTH_NF
where SPEENTNAT_CT  in (7,8)



-------------------------------------------------------------------------------------------------------------------
-- ERROR 21033 The retro event does not correspond to the Retro single Claim  						  -- MODIF 30 
-------------------------------------------------------------------------------------------------------------------
-- select "21033", Datediff(MS,@astartTime ,getDate())
--subsidiary event

select @nbligne_tctrano = count(*)
FROM BEST..TCTRANO 
where SSD_CF = @p_ssd_cf 
and SEGTYP_CT ="A" 
and SEG_NF = @p_usr_cf 

if ( @nbligne_tctrano > 0 )
BEGIN
    select @MsgGlobalAnomalie = 'Voir les erreurs dans  dans la table BEST..TCTRANO :   SELECT * from BEST..TCTRANO   WHERE SSD_CF ='+ convert(varchar(3),@p_ssd_cf) + '  and SEG_NF = "' + @p_usr_cf +'"'
    goto FIN
END 
    
    
declare     @max_trn_nt   numeric( 10, 0 )
select @max_trn_nt = isnull(max( TRN_NT ),0)
FROM  BEST..TACCSUP

if @@trancount = 0
  begin
   select @tran_imbr = 0
   BEGIN TRAN
  end
  
INSERT into BEST..TACCSUP
( TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF,
  BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF,
  END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M,
  CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RETRTY_NF,
  RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF,
  RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D,
  CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF)                                     -- MOD005 26/04/2005 -- MOD007
select A.TRN_NT+@max_trn_nt, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from #EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT      --Mod31
  where   (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")     --Mod31
  and A.REVT_NF = CAST(TCLM.EVT_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF         --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF
UNION
select A.TRN_NT+@max_trn_nt, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from #EST_ESID0801_TESTUTISUP A, BCTA..TRETCLM TCLM, BCTA..TEVENT EVT      --Mod31
  where  (A.RCL_NF is not null) and (A.REVT_NF is not null) and  (A.REVT_NF <> "")           --Mod31
  and A.REVT_NF = "G" + CAST(EVT.GEV_NF AS VARCHAR(10))
  and A.SSD_CF = TCLM.SSD_CF
  and A.RCL_NF = TCLM.RCL_NF        --Mod31
  and EVT.SUBEVT_NF = TCLM.EVT_NF
  and EVT.SSD_CF = TCLM.SSD_CF 

UNION
-- if the claim is null or the claim is null, there should be no error
select A.TRN_NT+@max_trn_nt, A.ACCTYP_NF, A.SSD_CF, A.ESB_CF, A.ENTPERY_NF, A.ENTPERMTH_NF, A.BALSHEY_NF, A.BALSHRMTH_NF,
  A.BALSHRDAY_NF, A.VALPERY_NF, A.VALPERMTH_NF, A.TRNCOD_CF, A.DBLTRNCOD_CF, A.RETAUTGEN_B, A.CTR_NF,
  A.END_NT, A.SEC_NF, A.UWY_NF, A.UW_NT, A.OCCYEA_NF, A.ACY_NF, A.SCOSTRMTH_NF, A.SCOENDMTH_NF , A.CLM_NF,
  A.CUR_CF, A.AMT_M, A.CED_NF, A.BRK_NF, A.GEMPRMPAY_NF, A.GANPAYORD_NT, A.RETCTR_NF, A.RETEND_NT, A.RETSEC_NF,
  A.RTY_NF, A.RETUW_NT, A.PLC_NT, A.RETOCCYEA_NF, A.RETACY_NF, A.RETSCOSTRMTH_NF, A.RETSCOENDMTH_NF, A.RCL_NF,
  A.RETCUR_CF, A.RETAMT_M, A.RTO_NF, A.INT_NF, A.RETPAY_NF, A.RETKEY_CF, A.ACCTRN_NT, A.COMMAC_LL, A.CRE_D,
  A.CREUSR_CF, A.LSTUPD_D, A.LSTUPDUSR_CF, A.SPEENTTYP_CF, A.SPEENTNAT_CT, A.EVT_NF, A.REVT_NF
 from #EST_ESID0801_TESTUTISUP A
 WHERE  (A.REVT_NF is null OR A.RCL_NF is null OR A.REVT_NF is null OR  A.REVT_NF = "")

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

DELETE btrav..EST_ESID0801_TESTUTISUP 
where
  SSD_CF       = @p_ssd_cf
  and LSTUPDUSR_CF = @p_usr_cf

select @erreur = @@error
if @erreur != 0  goto ErreurMAJ

-- -----------------------------------------------------------
--  End of the transaction 
------------------------------------------------------------
   
--	MOD034

Fin:
     if ( @MsgGlobalAnomalie != null )
        print @MsgGlobalAnomalie
    if @tran_imbr = 0
        COMMIT TRAN
    return 0
	

ErreurNorm:
    Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie 
    raiserror 20113 @MsgGlobalAnomalie
    return 1




ErreurAno:
-- MOD034 anomaly insertion removed from this

-- [026]
    if @p_batch_mode != 'batch'
        BEGIN
            Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie 
            raiserror 20113 @MsgGlobalAnomalie
        END
    return 1

ErreurMAJ:
    if @tran_imbr = 0 ROLLBACK TRAN

    Select @MsgGlobalAnomalie = 'Derniere Anomalie : ' +  @MsgAnomalie 
    raiserror 20113 @MsgGlobalAnomalie
    Select @MsgGlobalAnomalie 
    return 1
go

EXEC sp_procxmode 'dbo.PiACCSUP_04', 'unchained'
go
IF OBJECT_ID('dbo.PiACCSUP_04') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.PiACCSUP_04 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PiACCSUP_04 >>>'
go
GRANT EXECUTE ON dbo.PiACCSUP_04 TO GOMEGA
go
GRANT EXECUTE ON dbo.PiACCSUP_04 TO GDBBATCH
go
